import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import bcrypt from 'bcrypt';
import mysql from 'mysql2/promise';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const port = Number(process.env.PORT || 3000);

const pool = mysql.createPool({
  host: process.env.MYSQL_HOST || 'localhost',
  port: Number(process.env.MYSQL_PORT || 3306),
  user: process.env.MYSQL_USER || 'root',
  password: process.env.MYSQL_PASSWORD || '',
  database: process.env.MYSQL_DATABASE || 'eventra',
  waitForConnections: true,
  connectionLimit: 10,
  namedPlaceholders: true,
});

async function query(sql, params = []) {
  const [rows] = await pool.execute(sql, params);
  return rows;
}

async function tableExists(tableName) {
  const rows = await query(
    `SELECT TABLE_NAME
     FROM information_schema.TABLES
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?
     LIMIT 1`,
    [tableName],
  );
  return rows.length > 0;
}

async function columnExists(tableName, columnName) {
  const rows = await query(
    `SELECT COLUMN_NAME
     FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = ?
       AND COLUMN_NAME = ?
     LIMIT 1`,
    [tableName, columnName],
  );
  return rows.length > 0;
}

async function ensurePaymentTables() {
  if (await tableExists('users')) {
    const requiredUserColumns = [
      { name: 'name', type: 'VARCHAR(120) NOT NULL', after: 'username', defaultValue: 'username' },
      { name: 'bio', type: 'TEXT NULL', after: 'password_hash' },
      { name: 'location', type: 'VARCHAR(120) NULL', after: 'bio' },
      { name: 'avatar_url', type: 'TEXT NULL', after: 'location' },
      { name: 'followers_count', type: 'INT NOT NULL DEFAULT 0', after: 'avatar_url' },
      { name: 'events_count', type: 'INT NOT NULL DEFAULT 0', after: 'followers_count' },
      { name: 'upcoming_events_count', type: 'INT NOT NULL DEFAULT 0', after: 'events_count' },
      { name: 'genre', type: 'VARCHAR(120) NULL', after: 'upcoming_events_count' },
      { name: 'description', type: 'TEXT NULL', after: 'genre' },
      { name: 'role', type: "VARCHAR(50) NOT NULL DEFAULT 'user'", after: 'description' },
      { name: 'is_verified', type: 'TINYINT(1) NOT NULL DEFAULT 0', after: 'role' },
      { name: 'sort_order', type: 'INT NOT NULL DEFAULT 0', after: 'is_verified' },
    ];

    for (const col of requiredUserColumns) {
      if (!(await columnExists('users', col.name))) {
        console.log(`Migrating users table: adding "${col.name}" column...`);
        await query(`ALTER TABLE users ADD COLUMN ${col.name} ${col.type} AFTER ${col.after}`);
        if (col.defaultValue === 'username') {
          await query(`UPDATE users SET ${col.name} = username`);
        }
        console.log(`Successfully added "${col.name}" column.`);
      }
    }
  }

  if (await tableExists('events')) {
    const venueLayoutColumn = await query(
      `SELECT COLUMN_NAME
       FROM information_schema.COLUMNS
       WHERE TABLE_SCHEMA = DATABASE()
         AND TABLE_NAME = 'events'
         AND COLUMN_NAME = 'venue_layout'
       LIMIT 1`,
    );

    if (venueLayoutColumn.length === 0) {
      await query('ALTER TABLE events ADD COLUMN venue_layout VARCHAR(160) NULL AFTER detail_image');
    }
  }

  if (await tableExists('events')) {
    const imageColumnType = await query(
      `SELECT DATA_TYPE FROM information_schema.COLUMNS
       WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'events' AND COLUMN_NAME = 'image'`
    );
    if (imageColumnType[0]?.DATA_TYPE === 'text') {
      console.log('Migrating events table: image column to LONGTEXT...');
      await query('ALTER TABLE events MODIFY COLUMN image LONGTEXT NULL');
    }
  }

  await query(`
    CREATE TABLE IF NOT EXISTS event_ticket_types (
      id INT PRIMARY KEY AUTO_INCREMENT,
      event_id INT NOT NULL,
      name VARCHAR(120) NOT NULL,
      badge VARCHAR(80) NULL,
      badge_color VARCHAR(30) NULL,
      description TEXT NULL,
      bullet1 VARCHAR(160) NULL,
      bullet2 VARCHAR(160) NULL,
      bullet3 VARCHAR(160) NULL,
      price INT NOT NULL,
      stock_remaining INT NOT NULL DEFAULT 0,
      max_per_order INT NOT NULL DEFAULT 4,
      sort_order INT NOT NULL,
      CONSTRAINT fk_ticket_types_event_api FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
    )
  `);

  if (await tableExists('promotor_ticket_types')) {
    const ticketTypeColumn = await query(
      `SELECT DATA_TYPE FROM information_schema.COLUMNS
       WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'promotor_ticket_types' AND COLUMN_NAME = 'type'`
    );
    if (ticketTypeColumn[0]?.DATA_TYPE === 'enum') {
      console.log('Migrating promotor_ticket_types: type column to VARCHAR...');
      await query('ALTER TABLE promotor_ticket_types MODIFY COLUMN type VARCHAR(120) NOT NULL');
    }
  }

  const promotorTicketRefColumn = await query(
    `SELECT COLUMN_NAME
     FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'event_ticket_types'
       AND COLUMN_NAME = 'promotor_ticket_type_id'
     LIMIT 1`,
  );

  if (promotorTicketRefColumn.length === 0) {
    await query('ALTER TABLE event_ticket_types ADD COLUMN promotor_ticket_type_id INT NULL AFTER max_per_order');
  }

  const maxPerOrderColumn = await query(
    `SELECT COLUMN_NAME
     FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'event_ticket_types'
       AND COLUMN_NAME = 'max_per_order'
     LIMIT 1`,
  );

  if (maxPerOrderColumn.length === 0) {
    await query('ALTER TABLE event_ticket_types ADD COLUMN max_per_order INT NOT NULL DEFAULT 4 AFTER stock_remaining');
  }

  await query(`
    CREATE TABLE IF NOT EXISTS payment_orders (
      id INT PRIMARY KEY AUTO_INCREMENT,
      user_id INT NULL,
      event_id INT NOT NULL,
      payment_method ENUM('qris','gopay','ovo','visa') NOT NULL,
      payment_status ENUM('PENDING','SUCCESS','FAILED') NOT NULL DEFAULT 'PENDING',
      subtotal INT NOT NULL,
      service_fee INT NOT NULL,
      total INT NOT NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  `);

  const paymentOrdersUserIdColumn = await query(
    `SELECT COLUMN_NAME
     FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'payment_orders'
       AND COLUMN_NAME = 'user_id'
     LIMIT 1`,
  );

  if (paymentOrdersUserIdColumn.length === 0) {
    await query('ALTER TABLE payment_orders ADD COLUMN user_id INT NULL AFTER id');
  }

  await query(`
    CREATE TABLE IF NOT EXISTS user_favorites (
      id INT PRIMARY KEY AUTO_INCREMENT,
      user_id INT NOT NULL,
      favorite_type ENUM('event','pass','artist') NOT NULL,
      item_id INT NOT NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      CONSTRAINT fk_user_favorites_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      UNIQUE KEY uq_user_favorites_item (user_id, favorite_type, item_id)
    )
  `);


  try {
    const [favTypeCol] = await query(
      "SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'user_favorites' AND COLUMN_NAME = 'favorite_type'"
    );
    if (favTypeCol && !favTypeCol.COLUMN_TYPE.includes("'artist'")) {
      console.log('Migrating user_favorites table: adding "artist" to favorite_type ENUM...');
      await query("ALTER TABLE user_favorites MODIFY COLUMN favorite_type ENUM('event','pass','artist') NOT NULL");
    }
  } catch (err) {
    console.error('Failed to migrate user_favorites enum:', err.message);
  }

  await query(`
    ALTER TABLE user_favorites
    MODIFY favorite_type ENUM('event','pass','artist') NOT NULL
  `);

  if (await tableExists('tickets')) {
    const ticketsUserIdColumn = await query(
      `SELECT COLUMN_NAME
       FROM information_schema.COLUMNS
       WHERE TABLE_SCHEMA = DATABASE()
         AND TABLE_NAME = 'tickets'
         AND COLUMN_NAME = 'user_id'
       LIMIT 1`,
    );

    if (ticketsUserIdColumn.length === 0) {
      await query('ALTER TABLE tickets ADD COLUMN user_id INT NULL AFTER id');
    }
  }

  await query(`
    CREATE TABLE IF NOT EXISTS payment_order_items (
      id INT PRIMARY KEY AUTO_INCREMENT,
      payment_order_id INT NOT NULL,
      ticket_type_id INT NOT NULL,
      ticket_name VARCHAR(120) NOT NULL,
      quantity INT NOT NULL,
      unit_price INT NOT NULL,
      CONSTRAINT fk_payment_items_order_api FOREIGN KEY (payment_order_id) REFERENCES payment_orders(id) ON DELETE CASCADE
    )
  `);

  await query(`
    CREATE TABLE IF NOT EXISTS payment_cards (
      id INT PRIMARY KEY AUTO_INCREMENT,
      payment_order_id INT NOT NULL,
      card_holder VARCHAR(120) NOT NULL,
      card_brand VARCHAR(40) NOT NULL,
      card_last4 VARCHAR(4) NOT NULL,
      card_expiry VARCHAR(7) NOT NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  `);
}

function normalizePaymentMethod(method) {
  const normalized = String(method || '').toLowerCase();
  return ['qris', 'gopay', 'ovo', 'visa'].includes(normalized) ? normalized : null;
}

function maskCardNumber(cardNumber) {
  const digits = String(cardNumber || '').replace(/\D/g, '');
  return digits.slice(-4);
}

function normalizeRowLabel(value) {
  return String(value || '').replace(/^ROW\s+/i, '').trim();
}

function normalizeSeatLabel(value) {
  return String(value || '').replace(/^SEAT\s+/i, '').trim();
}

function formatCompactCount(value) {
  const numericValue = Number(value || 0);

  if (!Number.isFinite(numericValue)) {
    return '0';
  }

  return new Intl.NumberFormat('en', {
    notation: 'compact',
    maximumFractionDigits: 1,
  }).format(numericValue);
}

function normalizeTitle(value) {
  return String(value || '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '')
    .trim();
}

function normalizeCityFilter(value) {
  const location = String(value || '').trim();
  const lowered = location.toLowerCase();

  if (!location || lowered === 'set your location' || lowered === 'unknown' || lowered === '-') {
    return '';
  }

  return location.includes(',') ? location.split(',')[0].trim() : location;
}

function parseTicketPrice(value, fallback = 850000) {
  const text = String(value || '').toLowerCase();
  const digits = text.replace(/[^0-9]/g, '');
  const amount = Number(digits);

  if (!Number.isFinite(amount) || amount <= 0) {
    return fallback;
  }

  if (text.includes('k')) {
    return amount * 1000;
  }

  return amount;
}

function roundTicketPrice(value) {
  return Math.max(150000, Math.round(value / 50000) * 50000);
}

function defaultTicketRowsForEvent(event) {
  const title = String(event?.title || '');
  const venue = String(event?.venue || event?.place || '');
  const layout = String(event?.venue_layout || '');
  const haystack = `${title} ${venue} ${layout}`.toLowerCase();
  const basePrice = parseTicketPrice(event?.price);
  const venueLabel = venue || 'venue layout';

  const row = (name, badge, badgeColor, description, priceMultiplier, stock, maxPerOrder, sortOrder) => ({
    name,
    badge,
    badgeColor,
    description,
    bullet1: `${name} section based on ${venueLabel}`,
    bullet2: badge === 'VIP' || badge === 'Ultimate' ? 'Priority entrance lane' : 'Digital QR ticket entry',
    bullet3: 'Official Eventra ticket verification',
    price: roundTicketPrice(basePrice * priceMultiplier),
    stockRemaining: stock,
    maxPerOrder,
    sortOrder,
  });

  if (
    haystack.includes('festival') ||
    haystack.includes('pestapora') ||
    haystack.includes('warehouse') ||
    haystack.includes('we the fest') ||
    haystack.includes('dwp')
  ) {
    return [
      row('Daily Pass', 'Regular', 'purple', `Single-day access for ${title}.`, 1, 180, 6, 1),
      row('VIP Pass', 'VIP', 'orange', `Premium festival access with better entry flow at ${venueLabel}.`, 1.85, 70, 4, 2),
      row('3-Day Pass', 'Best Value', 'red', `Full multi-day access for ${title}.`, 2.35, 55, 4, 3),
    ];
  }

  if (
    haystack.includes('atlas') ||
    haystack.includes('beach') ||
    haystack.includes('gwk') ||
    haystack.includes('club')
  ) {
    return [
      row('VIP Deck', 'VIP', 'red', `Elevated premium viewing deck at ${venueLabel}.`, 2.3, 24, 2, 1),
      row('VIP Table', 'Premium', 'orange', `Premium table-area access for ${title}.`, 1.75, 40, 2, 2),
      row('GA', 'Standard', 'purple', `General admission access at ${venueLabel}.`, 1, 140, 6, 3),
      row('Beach Zone', 'Standard', 'purple', `Open-view zone with wider venue access.`, 0.72, 180, 6, 4),
    ];
  }

  if (
    haystack.includes('stadium') ||
    haystack.includes('stadion') ||
    haystack.includes('gbk') ||
    haystack.includes('jis')
  ) {
    return [
      row('VIP Floor', 'VIP', 'red', `Closest floor category for ${title}.`, 2.4, 28, 2, 1),
      row('Festival Floor', 'Premium', 'orange', `Main floor category behind VIP at ${venueLabel}.`, 1.75, 80, 4, 2),
      row('CAT 1', 'Premium', 'orange', `Side-front reserved category with strong stage sightline.`, 1.35, 120, 4, 3),
      row('CAT 2', 'Standard', 'purple', `Middle reserved category based on stadium layout.`, 1, 160, 6, 4),
      row('CAT 3', 'Standard', 'purple', `Outer lower category for regular access.`, 0.72, 210, 6, 5),
      row('CAT 4 Upper', 'Standard', 'purple', `Upper category with wide stadium view.`, 0.55, 260, 6, 6),
    ];
  }

  return [
    row('VIP', 'VIP', 'red', `Closest category in front of the stage for ${title}.`, 2, 30, 2, 1),
    row('CAT 1', 'Premium', 'orange', `Front-middle category with strong stage sightline.`, 1.45, 80, 4, 2),
    row('CAT 2', 'Standard', 'purple', `Middle category based on ${venueLabel}.`, 1, 140, 6, 3),
    row('CAT 3', 'Standard', 'purple', `Rear and side category for regular access.`, 0.72, 200, 6, 4),
  ];
}

async function eventTicketTypeColumn() {
  return (await columnExists('event_ticket_types', 'event_id'))
    ? 'event_id'
    : 'nearby_event_id';
}

async function ensureTicketTypesForEvent(eventId) {
  const eventColumn = await eventTicketTypeColumn();
  const existingRows = await query(
    `SELECT id FROM event_ticket_types WHERE ${eventColumn} = ? LIMIT 1`,
    [eventId],
  );

  if (existingRows.length > 0) {
    return eventColumn;
  }

  const [event] = await query(
    `SELECT id, title, venue, city, price, venue_layout
     FROM events
     WHERE id = ?
     LIMIT 1`,
    [eventId],
  );

  if (!event) {
    return eventColumn;
  }

  const ticketRows = defaultTicketRowsForEvent(event);

  for (const ticket of ticketRows) {
    await query(
      `INSERT IGNORE INTO event_ticket_types (
        id, ${eventColumn}, name, badge, badge_color, description,
        bullet1, bullet2, bullet3, price, stock_remaining, max_per_order, sort_order
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        eventId * 100 + ticket.sortOrder,
        eventId,
        ticket.name,
        ticket.badge,
        ticket.badgeColor,
        ticket.description,
        ticket.bullet1,
        ticket.bullet2,
        ticket.bullet3,
        ticket.price,
        ticket.stockRemaining,
        ticket.maxPerOrder,
        ticket.sortOrder,
      ],
    );
  }

  return eventColumn;
}

function getRequestUserId(req) {
  const userIdHeader = req.header('x-user-id');
  const parsedUserId = Number(userIdHeader);

  if (!Number.isInteger(parsedUserId) || parsedUserId <= 0) {
    return null;
  }

  return parsedUserId;
}

function requireUserId(req, res) {
  const userId = getRequestUserId(req);

  if (!userId) {
    res.status(401).json({ error: 'Missing user session' });
    return null;
  }

  return userId;
}

app.get('/api/health', async (_req, res) => {
  try {
    await query('SELECT 1 AS ok');
    res.json({ ok: true });
  } catch (error) {
    res.status(500).json({ ok: false, error: error.message });
  }
});

app.get('/api/home/featured-events', async (req, res, next) => {
  try {
    const userId = getRequestUserId(req);

    const rows = (await tableExists('events'))
      ? await query(`
        SELECT
          id,
          title,
          COALESCE(lineup, venue) AS subtitle,
          image,
          tag1,
          tag2,
          button,
          sort_order,
          CASE
            WHEN ? IS NULL THEN is_favorite
            ELSE EXISTS(
              SELECT 1
              FROM user_favorites uf
              WHERE uf.user_id = ?
                AND uf.favorite_type = 'event'
                AND uf.item_id = events.id
            )
          END AS is_favorite
        FROM events
        WHERE is_featured = 1
        ORDER BY sort_order ASC
      `, [userId, userId])
      : await query(`
        SELECT
          id,
          title,
          subtitle,
          image,
          tag1,
          tag2,
          button,
          sort_order,
          is_favorite
        FROM featured_events
        ORDER BY sort_order ASC
      `);
    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/home/passes', async (req, res, next) => {
  try {
    const userId = getRequestUserId(req);

    if (!(await tableExists('pass_packages'))) {
      return res.json({ data: [] });
    }

    const rows = await query(
      `SELECT
        id,
        title,
        description AS \`desc\`,
        price,
        sort_order,
        CASE
          WHEN ? IS NULL THEN is_favorite
          ELSE EXISTS(
            SELECT 1
            FROM user_favorites uf
            WHERE uf.user_id = ?
              AND uf.favorite_type = 'pass'
              AND uf.item_id = pass_packages.id
          )
        END AS is_favorite
      FROM pass_packages
      ORDER BY sort_order ASC`,
      [userId, userId],
    );
    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/home/nearby-events', async (req, res, next) => {
  try {
    const userId = getRequestUserId(req);
    const city = normalizeCityFilter(req.query.location);

    const rows = (await tableExists('events'))
      ? await query(`
        SELECT
          id,
          title,
          CASE
            WHEN date_label REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
              THEN UPPER(DATE_FORMAT(STR_TO_DATE(date_label, '%Y-%m-%d'), '%d %b'))
            ELSE date_label
          END AS date,
          venue AS place,
          city,
          COALESCE(lineup, title) AS artist_name,
          price,
          image,
          sort_order,
          CASE
            WHEN ? IS NULL THEN is_favorite
            ELSE EXISTS(
              SELECT 1
              FROM user_favorites uf
              WHERE uf.user_id = ?
                AND uf.favorite_type = 'event'
                AND uf.item_id = events.id
            )
          END AS is_favorite
        FROM events
        WHERE (? = '' OR LOWER(TRIM(city)) = LOWER(TRIM(?)))
        ORDER BY sort_order ASC
      `, [userId, userId, city, city])
      : await query(`
        SELECT
          id,
          title,
          CASE
            WHEN date_label REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
              THEN UPPER(DATE_FORMAT(STR_TO_DATE(date_label, '%Y-%m-%d'), '%d %b'))
            ELSE date_label
          END AS date,
          place,
          city,
          artist_name,
          price,
          image,
          sort_order,
          is_favorite
        FROM nearby_events
        WHERE (? = '' OR LOWER(TRIM(city)) = LOWER(TRIM(?)))
        ORDER BY sort_order ASC
      `, [city, city]);

    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/tickets', async (req, res, next) => {
  try {
    const userId = requireUserId(req, res);
    if (!userId) {
      return;
    }

    const rows = await query(
      `SELECT id, title, image, date_label, time_label, venue, section, row_label, seat_label, qr_data, ticket_type, ticket_status, sort_order
       FROM tickets
       WHERE user_id = ?
       ORDER BY sort_order ASC`,
      [userId],
    );
    const data = rows.map((ticket) => ({
      ...ticket,
      row_label: normalizeRowLabel(ticket.row_label),
      seat_label: normalizeSeatLabel(ticket.seat_label),
      section: ticket.ticket_type || ticket.section,
    }));
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.get('/api/notifications', async (_req, res, next) => {
  try {
    const rows = await query('SELECT id, title, subtitle, sort_order FROM notifications ORDER BY sort_order ASC');
    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/profile', async (req, res, next) => {
  try {
    const userId = requireUserId(req, res);
    if (!userId) {
      return;
    }

    const [row] = await query(
      `SELECT id, username, name, email, phone, bio, location, avatar_url,
        followers_count, upcoming_events_count, description, role, is_verified
       FROM users
       WHERE id = ?
       LIMIT 1`,
      [userId],
    );
    res.json({ profile: row || {} });
  } catch (error) {
    next(error);
  }
});

app.post('/api/profile/update', async (req, res, next) => {
  try {
    const userId = requireUserId(req, res);
    if (!userId) {
      return;
    }

    const { name, location, avatar_url, description } = req.body || {};

    const updates = [];
    const params = [];

    if (name !== undefined) {
      updates.push('name = ?');
      params.push(name);
    }
    if (location !== undefined) {
      updates.push('location = ?');
      params.push(location);
    }
    if (avatar_url !== undefined) {
      updates.push('avatar_url = ?');
      params.push(avatar_url);
    }
    if (description !== undefined) {
      updates.push('description = ?');
      params.push(description);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    const [oldUser] = await query('SELECT role, name FROM users WHERE id = ?', [userId]);

    params.push(userId);

    await query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = ?`,
      params,
    );

    if (description !== undefined) {
      await query('UPDATE users SET bio = ? WHERE id = ?', [description, userId]);
    }

    if (oldUser && oldUser.role === 'promoter' && (await tableExists('artists'))) {
      const artistUpdates = [];
      const artistParams = [];

      if (name !== undefined) {
        artistUpdates.push('name = ?');
        artistParams.push(name);
      }
      if (avatar_url !== undefined) {
        artistUpdates.push('image_url = ?');
        artistParams.push(avatar_url);
      }
      if (description !== undefined) {
        artistUpdates.push('description = ?');
        artistParams.push(description);
      }

      if (artistUpdates.length > 0) {
        artistParams.push(oldUser.name.trim());
        await query(
          `UPDATE artists SET ${artistUpdates.join(', ')} WHERE LOWER(TRIM(name)) = LOWER(?)`,
          artistParams,
        );
      }
    }

    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

app.get('/api/app-config', async (_req, res, next) => {
  try {
    const rows = await query('SELECT config_key, config_value FROM app_config');
    const config = rows.reduce((accumulator, row) => {
      accumulator[row.config_key] = row.config_value;
      return accumulator;
    }, {});

    res.json({ config });
  } catch (error) {
    next(error);
  }
});

app.get('/api/favorites', async (req, res, next) => {
  try {
    const userId = requireUserId(req, res);
    if (!userId) {
      return;
    }

    const passes = (await tableExists('pass_packages'))
      ? await query(
          `SELECT p.id, p.title, p.description AS subtitle, p.price, NULL AS image, NULL AS date, NULL AS place, NULL AS city, "pass" AS type
           FROM user_favorites uf
           INNER JOIN pass_packages p ON p.id = uf.item_id
           WHERE uf.user_id = ? AND uf.favorite_type = 'pass'
           ORDER BY p.sort_order ASC`,
          [userId],
        )
      : [];
    const events = (await tableExists('events'))
      ? await query(
          `SELECT
            e.id,
            e.title,
            e.venue AS subtitle,
            e.price,
            e.image,
            e.date_label AS date,
            e.venue AS place,
            e.city,
            COALESCE(e.lineup, e.title) AS artist_name,
            "event" AS type
           FROM user_favorites uf
           INNER JOIN events e ON e.id = uf.item_id
           WHERE uf.user_id = ? AND uf.favorite_type = 'event'
           ORDER BY e.sort_order ASC`,
          [userId],
        )
      : await query(
          `SELECT
            e.id,
            e.title,
            e.place AS subtitle,
            e.price,
            e.image,
            e.date_label AS date,
            e.place,
            e.city,
            e.artist_name,
            "event" AS type
           FROM user_favorites uf
           INNER JOIN nearby_events e ON e.id = uf.item_id
           WHERE uf.user_id = ? AND uf.favorite_type = 'event'
           ORDER BY e.sort_order ASC`,
          [userId],
        );

    const artists = (await tableExists('artists'))
      ? await query(
          `SELECT
            a.id,
            a.name AS title,
            a.genre AS subtitle,
            NULL AS price,
            a.image_url AS image,
            NULL AS date,
            NULL AS place,
            NULL AS city,
            a.followers,
            a.genre,
            a.description,
            "artist" AS type
           FROM user_favorites uf
           INNER JOIN artists a ON a.id = uf.item_id
           WHERE uf.user_id = ? AND uf.favorite_type = 'artist'
           ORDER BY a.sort_order ASC`,
          [userId],
        )
      : await query(
          `SELECT
            u.id,
            u.name AS title,
            u.genre AS subtitle,
            NULL AS price,
            u.avatar_url AS image,
            NULL AS date,
            NULL AS place,
            u.location AS city,
            u.followers_count AS followers,
            u.genre,
            u.description,
            "artist" AS type
           FROM user_favorites uf
           INNER JOIN users u ON u.id = uf.item_id
           WHERE uf.user_id = ? AND uf.favorite_type = 'artist'
           ORDER BY u.followers_count DESC`,
          [userId],
        );

    res.json({ data: [...artists, ...events] });
  } catch (error) {
    next(error);
  }
});

app.get('/api/artists', async (req, res, next) => {
  try {
    const userId = getRequestUserId(req);
    if (await tableExists('artists')) {
      // Join with users table to get the latest profile info (source of truth)
      // We match by name for seeded artists
      const artists = await query(`
        SELECT 
          a.id AS artist_id,
          COALESCE(u.id, a.id) AS id,
          COALESCE(u.name, a.name) AS name,
          u.username,
          COALESCE(u.avatar_url, a.image_url) AS avatar_url,
          COALESCE(u.avatar_url, a.image_url) AS imageUrl,
          COALESCE(u.description, a.description) AS description,
          a.followers,
          a.followers AS followers_count,
          a.monthly_listeners,
          a.events_count,
          a.genre,
          a.sort_order,
          CASE
            WHEN ? IS NULL THEN 0
            ELSE EXISTS(
              SELECT 1 FROM user_favorites uf
              WHERE uf.user_id = ?
                AND uf.favorite_type = 'artist'
                AND uf.item_id = a.id
            )
          END AS is_favorite
        FROM artists a
        LEFT JOIN users u ON LOWER(TRIM(u.name)) = LOWER(TRIM(a.name)) AND u.role = 'promoter'
        ORDER BY a.sort_order ASC
      `, [userId, userId]);
      const allEvents = (await tableExists('artist_events'))
        ? await query(`
          SELECT id, artist_id, title, lineup, venue, location, date_label, image, sort_order
          FROM artist_events
          ORDER BY sort_order ASC
        `)
        : [];
      const eventRows = (await tableExists('events'))
        ? await query(`
          SELECT id, title, image, city, venue, price, sort_order,
            CASE
              WHEN ? IS NULL THEN is_favorite
              ELSE EXISTS(
                SELECT 1 FROM user_favorites uf
                WHERE uf.user_id = ?
                  AND uf.favorite_type = 'event'
                  AND uf.item_id = events.id
              )
            END AS is_favorite
          FROM events
        `, [userId, userId])
        : [];
      const nearbyEvents = (await tableExists('nearby_events'))
        ? await query(`
          SELECT id, title, image, city, place AS venue
          FROM nearby_events
        `)
        : [];
      const featuredEvents = (await tableExists('featured_events'))
        ? await query(`
          SELECT id, title, image, city, venue
          FROM featured_events
        `)
        : [];
      const eventImageByTitle = new Map(
        [...eventRows, ...nearbyEvents, ...featuredEvents].map((event) => [
          normalizeTitle(event.title),
          event,
        ]),
      );
      const eventIdByTitle = new Map(
        [...eventRows, ...nearbyEvents, ...featuredEvents].map((event) => [
          normalizeTitle(event.title),
          event.id,
        ]),
      );

      const responseData = artists.map((artist) => ({
        id: artist.id,
        artist_id: artist.artist_id,
        name: artist.name,
        username: null,
        avatar_url: artist.image_url,
        imageUrl: artist.image_url,
        genre: artist.genre,
        description: artist.description,
        followers: artist.followers,
        followers_count: artist.followers,
        monthly_listeners: artist.monthly_listeners,
        events_count: artist.events_count,
        is_favorite: artist.is_favorite,
        upcomingEvents: allEvents
          .filter((event) => Number(event.artist_id) === Number(artist.artist_id))
          .map((event) => {
            const matchedEvent = eventImageByTitle.get(normalizeTitle(event.title));
            const locationParts = String(event.location || '')
              .split(',')
              .map((part) => part.trim());
            return {
              id: event.id,
              event_id: eventIdByTitle.get(normalizeTitle(event.title)) || null,
              title: event.title,
              lineup: event.lineup,
              venue: matchedEvent?.venue || event.venue || locationParts[0] || event.location,
              city: matchedEvent?.city || locationParts[0] || '',
              date_label: event.date_label,
              image: event.image || matchedEvent?.image || artist.image_url,
              price: matchedEvent?.price || '',
              sort_order: matchedEvent?.sort_order || event.sort_order,
              is_favorite: matchedEvent?.is_favorite || 0,
            };
          }),
      }));

      return res.json({ data: responseData });
    }

    const artists = await query(
      `SELECT id, username, name, followers_count, description, genre, avatar_url,
        CASE
          WHEN ? IS NULL THEN 0
          ELSE EXISTS(
            SELECT 1 FROM user_favorites uf
            WHERE uf.user_id = ?
              AND uf.favorite_type = 'artist'
              AND uf.item_id = users.id
          )
        END AS is_favorite
        FROM users
        WHERE role = ?
        ORDER BY followers_count DESC
      `,
      [userId, userId, 'promoter'],
    );
    const allEvents = (await tableExists('events'))
      ? await query(`
        SELECT id, user_id, title, lineup, venue, city, date_label, image,
          CASE
            WHEN ? IS NULL THEN is_favorite
            ELSE EXISTS(
              SELECT 1 FROM user_favorites uf
              WHERE uf.user_id = ?
                AND uf.favorite_type = 'event'
                AND uf.item_id = events.id
            )
          END AS is_favorite
        FROM events
        ORDER BY sort_order ASC
      `, [userId, userId])
      : [];

    const responseData = artists.map(artist => {
      const upcomingEvents = allEvents.filter(event => {
        // Cocokkan berdasarkan user_id ATAU cek jika nama artis ada di dalam string lineup
        const isCreatedByArtist = event.user_id === artist.id;
        const isIncludedInLineup = event.lineup && event.lineup.toLowerCase().includes(artist.name.toLowerCase());
        
        return isCreatedByArtist || isIncludedInLineup;
      });

      return {
        id: artist.id,
        name: artist.name,
        username: artist.username,
        avatar_url: artist.avatar_url,
        imageUrl: artist.avatar_url,
        genre: artist.genre,
        description: artist.description,
        followers: formatCompactCount(artist.followers_count),
        followers_count: formatCompactCount(artist.followers_count),
        is_favorite: artist.is_favorite,
        upcomingEvents: upcomingEvents.map(event => ({
          id: event.id,
          title: event.title,
          lineup: event.lineup,
          venue: event.venue,
          city: event.city,
          date_label: event.date_label,
          image: event.image,
          is_favorite: event.is_favorite
        }))
      };
    });

    res.json({ data: responseData });

  } catch (error) {
    next(error);
  }
});

app.get('/api/home/exclusive-drops', async (_req, res, next) => {
  try {
    const rows = (await tableExists('events'))
      ? await query(`
        SELECT
          id,
          title,
          COALESCE(tag1, 'EVENT') AS badge,
          COALESCE(description, CONCAT('Live at ', venue, ', ', city)) AS description,
          'ticket' AS type,
          image,
          CASE id
            WHEN 9 THEN 9912
            WHEN 10 THEN 45000
            ELSE 75000
          END AS countdown_seconds,
          sort_order
        FROM events
        WHERE is_featured = 0
          AND id IN (9, 10, 30)
        ORDER BY FIELD(id, 9, 10, 30)
      `)
      : await query(
          'SELECT id, title, badge, description, type, image, countdown_seconds, sort_order FROM exclusive_drops WHERE is_active = 1 ORDER BY sort_order ASC'
        );
    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/nearby-events/:id/ticket-types', async (req, res, next) => {
  try {
    const eventId = Number(req.params.id);
    const eventColumn = await ensureTicketTypesForEvent(eventId);
    const rows = await query(
      `SELECT id, name, badge, badge_color, description, bullet1, bullet2, bullet3, price, stock_remaining, max_per_order FROM event_ticket_types WHERE ${eventColumn} = ? ORDER BY sort_order ASC`,
      [eventId]
    );
    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/nearby-events/:id/detail', async (req, res, next) => {
  try {
    const eventId = Number(req.params.id);
    const [row] = (await tableExists('events'))
      ? await query(
          `SELECT
            id,
            title,
            date_label,
            venue,
            venue AS place,
            city,
            price,
            image,
            detail_image,
            venue_layout,
            lineup,
            COALESCE(lineup, title) AS artist_name,
            show_time,
            description
           FROM events
           WHERE id = ?`,
          [eventId]
        )
      : await query(
          `SELECT
            id,
            title,
            date_label,
            place AS venue,
            place,
            city,
            price,
            image,
            detail_image,
            venue_layout,
            artist_name AS lineup,
            artist_name,
            show_time,
            description
           FROM nearby_events
           WHERE id = ?`,
          [eventId]
        );
    res.json({ data: row || {} });
  } catch (error) {
    next(error);
  }
});

app.post('/api/passes/:id/favorite', async (req, res, next) => {
  try {
    const userId = requireUserId(req, res);
    if (!userId) {
      return;
    }

    const passId = Number(req.params.id);
    const isFavorite = req.body?.isFavorite;

    if (!passId) {
      return res.status(400).json({ error: 'Invalid pass id' });
    }

    if (isFavorite) {
      await query(
        `INSERT INTO user_favorites (user_id, favorite_type, item_id)
         VALUES (?, 'pass', ?)
         ON DUPLICATE KEY UPDATE created_at = CURRENT_TIMESTAMP`,
        [userId, passId],
      );
    } else {
      await query(
        'DELETE FROM user_favorites WHERE user_id = ? AND favorite_type = ? AND item_id = ?',
        [userId, 'pass', passId],
      );
    }

    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

app.post('/api/nearby-events/:id/favorite', async (req, res, next) => {
  try {
    const userId = requireUserId(req, res);
    if (!userId) {
      return;
    }

    const eventId = Number(req.params.id);
    const isFavorite = req.body?.isFavorite;

    if (!eventId) {
      return res.status(400).json({ error: 'Invalid event id' });
    }

    if (isFavorite) {
      await query(
        `INSERT INTO user_favorites (user_id, favorite_type, item_id)
         VALUES (?, 'event', ?)
         ON DUPLICATE KEY UPDATE created_at = CURRENT_TIMESTAMP`,
        [userId, eventId],
      );
    } else {
      await query(
        'DELETE FROM user_favorites WHERE user_id = ? AND favorite_type = ? AND item_id = ?',
        [userId, 'event', eventId],
      );
    }

    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

app.post('/api/artists/:id/favorite', async (req, res, next) => {
  try {
    const userId = requireUserId(req, res);
    if (!userId) {
      return;
    }

    const artistId = Number(req.params.id);
    const isFavorite = req.body?.isFavorite;

    if (!artistId) {
      return res.status(400).json({ error: 'Invalid artist id' });
    }

    if (isFavorite) {
      await query(
        `INSERT INTO user_favorites (user_id, favorite_type, item_id)
         VALUES (?, 'artist', ?)
         ON DUPLICATE KEY UPDATE created_at = CURRENT_TIMESTAMP`,
        [userId, artistId],
      );
    } else {
      await query(
        'DELETE FROM user_favorites WHERE user_id = ? AND favorite_type = ? AND item_id = ?',
        [userId, 'artist', artistId],
      );
    }

    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

app.post('/api/payments/checkout', async (req, res, next) => {
  const connection = await pool.getConnection();

  try {
    const userId = requireUserId(req, res);
    if (!userId) {
      return;
    }

    const eventId = Number(req.body?.eventId);
    const method = normalizePaymentMethod(req.body?.paymentMethod);
    const items = Array.isArray(req.body?.items) ? req.body.items : [];
    const card = req.body?.card || {};

    if (!eventId || !method || items.length === 0) {
      return res.status(400).json({ error: 'Event, payment method, and ticket items are required' });
    }

    const eventColumn = await ensureTicketTypesForEvent(eventId);

    if (method === 'visa') {
      const last4 = maskCardNumber(card.cardNumber);
      if (!card.cardHolder || !card.expiry || !card.cvv || last4.length !== 4) {
        return res.status(400).json({ error: 'Valid Visa card details are required' });
      }
    }

    await connection.beginTransaction();

    const [events] = await connection.execute(
      'SELECT id, title, image, date_label, venue AS place, show_time FROM events WHERE id = ? LIMIT 1',
      [eventId]
    );
    const event = events[0];

    if (!event) {
      await connection.rollback();
      return res.status(404).json({ error: 'Event not found' });
    }

    const ticketIds = items.map((item) => Number(item.ticketTypeId)).filter(Boolean);
    if (ticketIds.length === 0) {
      await connection.rollback();
      return res.status(400).json({ error: 'Invalid ticket selection' });
    }

    const placeholders = ticketIds.map(() => '?').join(',');
    const [ticketTypes] = await connection.execute(
      `SELECT id, name, price, stock_remaining, max_per_order, promotor_ticket_type_id FROM event_ticket_types WHERE ${eventColumn} = ? AND id IN (${placeholders}) FOR UPDATE`,
      [eventId, ...ticketIds]
    );
    const ticketMap = new Map(ticketTypes.map((ticket) => [Number(ticket.id), ticket]));

    let subtotal = 0;
    const normalizedItems = [];

    for (const item of items) {
      const ticketTypeId = Number(item.ticketTypeId);
      const quantity = Number(item.quantity);
      const ticket = ticketMap.get(ticketTypeId);

      if (!ticket || !quantity || quantity < 1) {
        await connection.rollback();
        return res.status(400).json({ error: 'Invalid ticket selection' });
      }

      if (ticket.stock_remaining < quantity) {
        await connection.rollback();
        return res.status(409).json({ error: `${ticket.name} only has ${ticket.stock_remaining} tickets left` });
      }

      const maxPerOrder = Number(ticket.max_per_order || 4);
      if (maxPerOrder > 0 && quantity > maxPerOrder) {
        await connection.rollback();
        return res.status(400).json({ error: `${ticket.name} has a maximum purchase of ${maxPerOrder} tickets per order` });
      }

      subtotal += ticket.price * quantity;
      normalizedItems.push({ ticket, quantity });
    }

    const serviceFee = Math.round(subtotal * 0.035);
    const total = subtotal + serviceFee;

    const [orderResult] = await connection.execute(
      `INSERT INTO payment_orders (user_id, event_id, payment_method, payment_status, subtotal, service_fee, total)
       VALUES (?, ?, ?, 'SUCCESS', ?, ?, ?)`,
      [userId, eventId, method, subtotal, serviceFee, total]
    );
    const paymentOrderId = orderResult.insertId;

    if (method === 'visa') {
      await connection.execute(
        `INSERT INTO payment_cards (payment_order_id, card_holder, card_brand, card_last4, card_expiry)
         VALUES (?, ?, 'Visa', ?, ?)`,
        [paymentOrderId, card.cardHolder, maskCardNumber(card.cardNumber), card.expiry]
      );
    }

    const [[ticketCounter]] = await connection.query('SELECT COALESCE(MAX(id), 0) AS max_id FROM tickets');
    let nextTicketId = Number(ticketCounter.max_id) + 1;

    for (const item of normalizedItems) {
      await connection.execute(
        `INSERT INTO payment_order_items (payment_order_id, ticket_type_id, ticket_name, quantity, unit_price)
         VALUES (?, ?, ?, ?, ?)`,
        [paymentOrderId, item.ticket.id, item.ticket.name, item.quantity, item.ticket.price]
      );

      await connection.execute(
        'UPDATE event_ticket_types SET stock_remaining = stock_remaining - ? WHERE id = ?',
        [item.quantity, item.ticket.id]
      );

      if (item.ticket.promotor_ticket_type_id) {
        await connection.execute(
          'UPDATE promotor_ticket_types SET sold = sold + ? WHERE id = ?',
          [item.quantity, item.ticket.promotor_ticket_type_id]
        );
      }

      for (let index = 1; index <= item.quantity; index++) {
        const rowLabel = String.fromCharCode(64 + (((nextTicketId - 1) % 6) + 1));
        const seatLabel = String(((nextTicketId - 1) % 30) + 1).padStart(2, '0');
        await connection.execute(
          `INSERT INTO tickets (
            id, user_id, title, image, date_label, time_label, venue, section, row_label, seat_label,
            qr_data, ticket_type, ticket_status, sort_order
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'UPCOMING', ?)`,
          [
            nextTicketId,
            userId,
            event.title,
            event.image,
            event.date_label,
            event.show_time || '19:00 WIB',
            event.place,
            item.ticket.name,
            rowLabel,
            seatLabel,
            `EVT-${eventId}-${paymentOrderId}-${nextTicketId}`,
            item.ticket.name,
            nextTicketId,
          ]
        );
        nextTicketId++;
      }
    }

    await connection.commit();

    res.status(201).json({
      payment: {
        id: paymentOrderId,
        status: 'SUCCESS',
        method,
        subtotal,
        serviceFee,
        total,
        qrisPayload: method === 'qris' ? `EVENTRA-QRIS-${paymentOrderId}` : null,
      },
    });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
});

app.get('/api/cities', async (_req, res, next) => {
  try {
    const rows = await query('SELECT DISTINCT city FROM events ORDER BY city ASC');
    const cities = rows.map((row) => row.city);
    res.json({ data: cities });
  } catch (error) {
    next(error);
  }
});

app.post('/api/auth/register', async (req, res, next) => {
  try {
    const { username, email, phone, password, location } = req.body || {};
    const userLocation = normalizeCityFilter(location) || 'Set your location';
    if (!username || !email || !password) {
      return res.status(400).json({ error: 'Username, email, and password are required' });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const [result] = await pool.execute(
      `INSERT INTO users (username, name, email, phone, password_hash, location, avatar_url, followers_count, upcoming_events_count, description, role, is_verified, sort_order)
       VALUES (?, ?, ?, ?, ?, ?, NULL, 0, 0, NULL, 'user', 1, 0)`,
      [username, username, email, phone || null, passwordHash, location || 'Set your location'],
    );

    res.status(201).json({
      user: {
        id: result.insertId,
        username,
        name: username,
        email,
        phone: phone || null,
        location: 'Set your location' || userLocation,
        avatar_url: null,
        followers_count: 0,
        upcoming_events_count: 0,
        description: null,
        role: 'user',
        is_verified: 1,
      },
    });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Username or email already exists' });
    }

    next(error);
  }
});

app.post('/api/auth/login', async (req, res, next) => {
  try {
    const { identifier, password } = req.body || {};

    if (!identifier || !password) {
      return res.status(400).json({ error: 'Email, phone, or username and password are required' });
    }

    const [user] = await query(
      `SELECT id, username, name, email, phone, password_hash, location, avatar_url, followers_count, upcoming_events_count, description, role, is_verified
       FROM users
       WHERE email = ? OR phone = ? OR username = ?
       LIMIT 1`,
      [identifier, identifier, identifier],
    );

    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    delete user.password_hash;
    res.json({ user });
  } catch (error) {
    next(error);
  }
});

app.post('/api/promotor/register', async (req, res, next) => {
  try {
    const { organization_name, contact_email, portfolio_link } = req.body || {};

    if (!organization_name || !contact_email || !portfolio_link) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    const [result] = await pool.execute(
      `INSERT INTO promotor_applications (organization_name, contact_email, portfolio_link)
       VALUES (?, ?, ?)`,
      [organization_name, contact_email, portfolio_link]
    );

    res.status(201).json({
      ok: true,
      application: {
        id: result.insertId,
        organization_name,
        contact_email,
        portfolio_link,
        status: 'pending',
      }
    });
  } catch (error) {
    next(error);
  }
});

app.get('/api/promotor/dashboard', async (req, res, next) => {
  try {
    const userId = requireUserId(req, res);
    if (!userId) return;

    const events = await query(
      `SELECT id, status FROM promotor_events WHERE user_id = ?`,
      [userId]
    );

    const eventIds = events.map(e => e.id);
    const activeEvents = events.filter(e => e.status === 'live').length;

    let totalRevenue = 0;
    let ticketSold = 0;

    if (eventIds.length > 0) {
      const placeholders = eventIds.map(() => '?').join(',');
      const revenueRows = await query(
        `SELECT COALESCE(SUM(pt.price * pt.sold), 0) AS total_revenue,
                COALESCE(SUM(pt.sold), 0) AS ticket_sold
         FROM promotor_ticket_types pt
         WHERE pt.promotor_event_id IN (${placeholders})`,
        eventIds
      );
      totalRevenue = revenueRows[0]?.total_revenue || 0;
      ticketSold = revenueRows[0]?.ticket_sold || 0;
    }

    res.json({
      dashboard: {
        total_revenue: totalRevenue,
        ticket_sold: ticketSold,
        active_events: activeEvents,
      }
    });
  } catch (error) {
    next(error);
  }
});

app.get('/api/promotor/events', async (req, res, next) => {
  try {
    const userId = requireUserId(req, res);
    if (!userId) return;

    const events = await query(
      `SELECT pe.id, pe.title, pe.artist_name, pe.venue, pe.image, pe.description, pe.location, pe.event_date,
              pe.event_time, pe.status, pe.created_at,
              COALESCE(SUM(pt.sold), 0) AS ticket_sold,
              COALESCE(SUM(pt.available), 0) AS ticket_total,
              COALESCE(SUM(pt.price * pt.sold), 0) AS revenue
       FROM promotor_events pe
       LEFT JOIN promotor_ticket_types pt ON pt.promotor_event_id = pe.id
       WHERE pe.user_id = ?
       GROUP BY pe.id
       ORDER BY pe.created_at DESC`,
      [userId]
    );

    const eventIds = events.map(e => e.id);
    let ticketTypes = [];
    if (eventIds.length > 0) {
      const placeholders = eventIds.map(() => '?').join(',');
      ticketTypes = await query(
        `SELECT * FROM promotor_ticket_types WHERE promotor_event_id IN (${placeholders})`,
        eventIds
      );
    }

    const data = events.map(event => ({
      ...event,
      tickets: ticketTypes.filter(t => t.promotor_event_id === event.id),
    }));

    res.json({ data });
  } catch (error) {
    next(error);
  }
});

async function syncPromotorEventToPublic(connection, promotorEventId) {
  const [rows] = await connection.execute(
    `SELECT * FROM promotor_events WHERE id = ? LIMIT 1`,
    [promotorEventId]
  );
  const event = rows[0];
  if (!event || event.status !== 'live') return;

  const dateLabel = event.event_date instanceof Date
    ? event.event_date.toISOString().split('T')[0]
    : String(event.event_date);

  const showTime = `${event.event_time} WIB`;

  const [ticketRows] = await connection.execute(
    `SELECT * FROM promotor_ticket_types WHERE promotor_event_id = ? ORDER BY id ASC`,
    [promotorEventId]
  );

  const minPrice = ticketRows.length > 0
    ? Math.min(...ticketRows.map((t) => Number(t.price)))
    : null;
  const priceLabel = minPrice ? `Rp${Number(minPrice).toLocaleString('id-ID')}` : null;

  const sourceMarker = `promotor:${promotorEventId}`;
  const [existing] = await connection.execute(
    `SELECT id FROM events WHERE source_url = ? LIMIT 1`,
    [sourceMarker]
  );

  let publicEventId;

  if (existing.length > 0) {
    publicEventId = existing[0].id;
    await connection.execute(
      `UPDATE events
       SET title = ?, lineup = ?, venue = ?, city = ?, date_label = ?, show_time = ?,
           price = ?, image = ?, description = ?
       WHERE id = ?`,
      [
        event.title,
        event.artist_name || event.title,
        event.venue || event.location,
        event.location,
        dateLabel,
        showTime,
        priceLabel,
        event.image,
        event.description,
        publicEventId,
      ]
    );
  } else {
    const [maxSort] = await connection.execute(`SELECT COALESCE(MAX(sort_order), 0) AS max_sort FROM events`);
    const nextSort = (maxSort[0]?.max_sort || 0) + 1;

    const [insertResult] = await connection.execute(
      `INSERT INTO events (title, lineup, venue, city, date_label, show_time, price, image, description,
                            tag1, tag2, button, is_featured, is_limited, remaining_seats, sort_order, is_favorite, source_url)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'EVENT', 'PROMOTOR', 'GET TICKETS', 0, 0, 0, ?, 0, ?)`,
      [
        event.title,
        event.artist_name || event.title,
        event.venue || event.location,
        event.location,
        dateLabel,
        showTime,
        priceLabel,
        event.image,
        event.description,
        nextSort,
        sourceMarker,
      ]
    );
    publicEventId = insertResult.insertId;
  }

  const [existingTicketTypes] = await connection.execute(
    `SELECT id, promotor_ticket_type_id, stock_remaining FROM event_ticket_types WHERE event_id = ?`,
    [publicEventId]
  );
  const existingByPromotorId = new Map(
    existingTicketTypes
      .filter((row) => row.promotor_ticket_type_id != null)
      .map((row) => [row.promotor_ticket_type_id, row])
  );

  const keepIds = [];

  for (let i = 0; i < ticketRows.length; i++) {
    const ticket = ticketRows[i];
    const sortOrder = i + 1;
    const stockRemaining = Math.max(0, Number(ticket.available) - Number(ticket.sold));

    const existingTT = existingByPromotorId.get(ticket.id);

    if (existingTT) {
      await connection.execute(
        `UPDATE event_ticket_types
         SET name = ?, price = ?, stock_remaining = ?, sort_order = ?
         WHERE id = ?`,
        [ticket.type, ticket.price, stockRemaining, sortOrder, existingTT.id]
      );
      keepIds.push(existingTT.id);
    } else {
      const [insertTT] = await connection.execute(
        `INSERT INTO event_ticket_types (
          event_id, name, badge, badge_color, description,
          bullet1, bullet2, bullet3, price, stock_remaining, max_per_order, promotor_ticket_type_id, sort_order
        ) VALUES (?, ?, NULL, NULL, NULL, NULL, NULL, NULL, ?, ?, 4, ?, ?)`,
        [publicEventId, ticket.type, ticket.price, stockRemaining, ticket.id, sortOrder]
      );
      keepIds.push(insertTT.insertId);
    }
  }

  if (keepIds.length > 0) {
    const placeholders = keepIds.map(() => '?').join(',');
    await connection.execute(
      `DELETE FROM event_ticket_types WHERE event_id = ? AND id NOT IN (${placeholders})`,
      [publicEventId, ...keepIds]
    );
  } else {
    await connection.execute(
      `DELETE FROM event_ticket_types WHERE event_id = ?`,
      [publicEventId]
    );
  }
}

app.post('/api/promotor/events', async (req, res, next) => {
  const connection = await pool.getConnection();
  try {
    const userId = requireUserId(req, res);
    if (!userId) return;

    const { title, artist_name, venue, description, location, event_date, event_time, image, status, tickets } = req.body || {};

    if (!title || !location || !event_date || !event_time) {
      return res.status(400).json({ error: 'Title, location, date, and time are required' });
    }

    const eventStatus = status === 'live' ? 'live' : 'draft';

    await connection.beginTransaction();

    const [result] = await connection.execute(
      `INSERT INTO promotor_events (user_id, title, artist_name, venue, description, location, event_date, event_time, image, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [userId, title, artist_name || null, venue || null, description || null, location, event_date, event_time, image || null, eventStatus]
    );

    const eventId = result.insertId;

    if (Array.isArray(tickets) && tickets.length > 0) {
      for (const ticket of tickets) {
        await connection.execute(
          `INSERT INTO promotor_ticket_types (promotor_event_id, type, price, available, sales_end_date, sales_end_time)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [
            eventId,
            ticket.type,
            Number(ticket.price) || 0,
            Number(ticket.available) || 0,
            ticket.sales_end_date || null,
            ticket.sales_end_time || null,
          ]
        );
      }
    }

    if (eventStatus === 'live') {
      await syncPromotorEventToPublic(connection, eventId);
    }

    await connection.commit();

    res.status(201).json({
      ok: true,
      event: { id: eventId, title, status: eventStatus }
    });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
});

app.put('/api/promotor/events/:id', async (req, res, next) => {
  const connection = await pool.getConnection();
  try {
    const userId = requireUserId(req, res);
    if (!userId) return;

    const eventId = Number(req.params.id);
    const { title, artist_name, venue, description, location, event_date, event_time, image, status, tickets } = req.body || {};

    const [existing] = await query(
      `SELECT id FROM promotor_events WHERE id = ? AND user_id = ? LIMIT 1`,
      [eventId, userId]
    );
    if (!existing) {
      return res.status(404).json({ error: 'Event not found' });
    }

    await connection.beginTransaction();

    await connection.execute(
      `UPDATE promotor_events
       SET title = COALESCE(?, title),
           artist_name = COALESCE(?, artist_name),
           venue = COALESCE(?, venue),
           description = COALESCE(?, description),
           location = COALESCE(?, location),
           event_date = COALESCE(?, event_date),
           event_time = COALESCE(?, event_time),
           image = COALESCE(?, image),
           status = COALESCE(?, status)
       WHERE id = ?`,
      [title, artist_name, venue, description, location, event_date, event_time, image, status, eventId]
    );

    if (Array.isArray(tickets)) {
      await connection.execute(
        `DELETE FROM promotor_ticket_types WHERE promotor_event_id = ?`,
        [eventId]
      );
      for (const ticket of tickets) {
        await connection.execute(
          `INSERT INTO promotor_ticket_types (promotor_event_id, type, price, available, sales_end_date, sales_end_time)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [
            eventId,
            ticket.type,
            Number(ticket.price) || 0,
            Number(ticket.available) || 0,
            ticket.sales_end_date || null,
            ticket.sales_end_time || null,
          ]
        );
      }
    }

    if (Array.isArray(tickets)) {
      await connection.execute(
        `DELETE FROM promotor_ticket_types WHERE promotor_event_id = ?`,
        [eventId]
      );
      for (const ticket of tickets) {
        await connection.execute(
          `INSERT INTO promotor_ticket_types (promotor_event_id, type, price, available, sales_end_date, sales_end_time)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [
            eventId,
            ticket.type,
            Number(ticket.price) || 0,
            Number(ticket.available) || 0,
            ticket.sales_end_date || null,
            ticket.sales_end_time || null,
          ]
        );
      }
    }

    const [finalRow] = await connection.execute(`SELECT status FROM promotor_events WHERE id = ?`, [eventId]);
    if (finalRow[0]?.status === 'live') {
      await syncPromotorEventToPublic(connection, eventId);
    }

    await connection.commit();
    res.json({ ok: true });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
});

app.delete('/api/promotor/events/:id', async (req, res, next) => {
  try {
    const userId = requireUserId(req, res);
    if (!userId) return;

    const eventId = Number(req.params.id);

    const [existing] = await query(
      `SELECT id FROM promotor_events WHERE id = ? AND user_id = ? LIMIT 1`,
      [eventId, userId]
    );
    if (!existing) {
      return res.status(404).json({ error: 'Event not found' });
    }

    await query(`DELETE FROM promotor_events WHERE id = ?`, [eventId]);
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

app.get('/api/promotor/events/:id/public-id', async (req, res, next) => {
  try {
    const promotorEventId = Number(req.params.id);
    const sourceMarker = `promotor:${promotorEventId}`;

    const [row] = await query(
      `SELECT id FROM events WHERE source_url = ? LIMIT 1`,
      [sourceMarker]
    );

    if (!row) {
      return res.status(404).json({ error: 'Public event not found' });
    }

    res.json({ eventId: row.id });
  } catch (error) {
    next(error);
  }
});

app.get('/api/promotor/application-status', async (req, res, next) => {
  try {
    const userId = requireUserId(req, res);
    if (!userId) return;

    const [user] = await query(
      `SELECT email, role FROM users WHERE id = ? LIMIT 1`,
      [userId]
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (user.role === 'promoter') {
      return res.json({ status: 'approved' });
    }

    const [application] = await query(
      `SELECT status FROM promotor_applications WHERE contact_email = ? ORDER BY created_at DESC LIMIT 1`,
      [user.email]
    );

    if (application) {
      return res.json({ status: application.status }); 
    }

    return res.json({ status: 'none' });
  } catch (error) {
    next(error);
  }
});

app.use((error, _req, res, _next) => {
  res.status(500).json({ error: error.message || 'Internal server error' });
});

if (await tableExists('tickets')) {
  const ticketImageType = await query(
    `SELECT DATA_TYPE FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tickets' AND COLUMN_NAME = 'image'`
  );
  if (ticketImageType[0]?.DATA_TYPE === 'text') {
    console.log('Migrating tickets table: image column to LONGTEXT...');
    await query('ALTER TABLE tickets MODIFY COLUMN image LONGTEXT NOT NULL');
  }
}

ensurePaymentTables()
  .then(() => {
    app.listen(port, () => {
      console.log(`Eventra API listening on port ${port}`);
    });
  })
  .catch((error) => {
    console.error('Failed to initialize payment tables:', error);
    process.exit(1);
  });
