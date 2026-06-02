import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import bcrypt from 'bcrypt';
import mysql from 'mysql2/promise';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

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

async function ensurePaymentTables() {
  await query(`
    CREATE TABLE IF NOT EXISTS event_ticket_types (
      id INT PRIMARY KEY,
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
      sort_order INT NOT NULL
    )
  `);

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
      event_id INT NOT NULL,
      payment_method ENUM('qris','gopay','ovo','visa') NOT NULL,
      payment_status ENUM('PENDING','SUCCESS','FAILED') NOT NULL DEFAULT 'PENDING',
      subtotal INT NOT NULL,
      service_fee INT NOT NULL,
      total INT NOT NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await query(`
    CREATE TABLE IF NOT EXISTS payment_order_items (
      id INT PRIMARY KEY AUTO_INCREMENT,
      payment_order_id INT NOT NULL,
      ticket_type_id INT NOT NULL,
      ticket_name VARCHAR(120) NOT NULL,
      quantity INT NOT NULL,
      unit_price INT NOT NULL
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

app.get('/api/health', async (_req, res) => {
  try {
    await query('SELECT 1 AS ok');
    res.json({ ok: true });
  } catch (error) {
    res.status(500).json({ ok: false, error: error.message });
  }
});

  app.get('/api/home/featured-events', async (_req, res, next) => {
  try {
    const rows = await query(`
      SELECT
        id,
        title,
        COALESCE(lineup, venue) AS subtitle,
        image,
        tag1,
        tag2,
        button,
        sort_order,
        is_favorite
      FROM events
      WHERE is_featured = 1
      ORDER BY sort_order ASC
    `);
    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/home/passes', async (_req, res, next) => {
  try {
    if (!(await tableExists('pass_packages'))) {
      return res.json({ data: [] });
    }

    const rows = await query('SELECT id, title, description AS `desc`, price, sort_order, is_favorite FROM pass_packages ORDER BY sort_order ASC');
    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/home/nearby-events', async (_req, res, next) => {
  try {
    const rows = await query(`
      SELECT
        id,
        title,
        date_label AS date,
        venue AS place,
        city,
        COALESCE(lineup, title) AS artist_name,
        price,
        image,
        sort_order,
        is_favorite
      FROM events
      ORDER BY sort_order ASC
    `);
    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/tickets', async (_req, res, next) => {
  try {
    const rows = await query('SELECT id, title, image, date_label, time_label, venue, section, row_label, seat_label, qr_data, ticket_type, ticket_status, sort_order FROM tickets ORDER BY sort_order ASC');
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

app.get('/api/profile', async (_req, res, next) => {
  try {
    const [row] = await query(
      'SELECT id, username, name, email, phone, location, avatar_url, followers_count, upcoming_events_count, description, role, is_verified FROM users ORDER BY id ASC LIMIT 1',
    );
    res.json({ profile: row || {} });
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

app.get('/api/favorites', async (_req, res, next) => {
  try {
    const passes = (await tableExists('pass_packages'))
      ? await query(
          'SELECT id, title, description AS subtitle, price, NULL AS image, NULL AS date, NULL AS place, NULL AS city, "pass" AS type FROM pass_packages WHERE is_favorite = 1 ORDER BY sort_order ASC',
        )
      : [];
    const events = await query(
      `SELECT
        id,
        title,
        venue AS subtitle,
        price,
        image,
        date_label AS date,
        venue AS place,
        city,
        COALESCE(lineup, title) AS artist_name,
        "event" AS type
       FROM events
       WHERE is_favorite = 1
       ORDER BY sort_order ASC`,
    );

    res.json({ data: [...passes, ...events] });
  } catch (error) {
    next(error);
  }
});

app.get('/api/artists', async (_req, res, next) => {
  try {
    const artists = await query(
      'SELECT id, name, followers_count, description, avatar_url AS imageUrl, sort_order FROM users WHERE role = ? ORDER BY sort_order ASC, followers_count DESC',
      ['promoter'],
    );
    const events = await query('SELECT user_id, title, lineup, venue, city AS location, date_label AS date FROM events WHERE user_id IS NOT NULL ORDER BY sort_order ASC');

    const groupedEvents = events.reduce((accumulator, event) => {
      const key = String(event.user_id);
      if (!accumulator[key]) {
        accumulator[key] = [];
      }
      accumulator[key].push({
        title: event.title,
        lineup: event.lineup,
        venue: event.venue,
        location: event.location,
        date: event.date,
      });
      return accumulator;
    }, {});

    const data = artists.map((artist) => ({
      name: artist.name,
      followers: `${formatCompactCount(artist.followers_count)} Followers`,
      description: artist.description,
      imageUrl: artist.imageUrl,
      upcomingEvents: groupedEvents[String(artist.id)] || [],
    }));

    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.get('/api/home/exclusive-drops', async (_req, res, next) => {
  try {
    const rows = await query(
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
    const rows = await query(
      'SELECT id, name, badge, badge_color, description, bullet1, bullet2, bullet3, price, stock_remaining, max_per_order FROM event_ticket_types WHERE event_id = ? ORDER BY sort_order ASC',
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
    const [row] = await query(
      `SELECT
        id,
        title,
        date_label,
        venue AS place,
        city,
        price,
        image,
        detail_image,
        venue_layout,
        COALESCE(lineup, title) AS artist_name,
        show_time,
        description
       FROM events
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
    const passId = Number(req.params.id);
    const isFavorite = req.body?.isFavorite ? 1 : 0;
    await query('UPDATE pass_packages SET is_favorite = ? WHERE id = ?', [isFavorite, passId]);
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

app.post('/api/nearby-events/:id/favorite', async (req, res, next) => {
  try {
    const eventId = Number(req.params.id);
    const isFavorite = req.body?.isFavorite ? 1 : 0;
    await query('UPDATE events SET is_favorite = ? WHERE id = ?', [isFavorite, eventId]);
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

app.post('/api/payments/checkout', async (req, res, next) => {
  const connection = await pool.getConnection();

  try {
    const eventId = Number(req.body?.eventId);
    const method = normalizePaymentMethod(req.body?.paymentMethod);
    const items = Array.isArray(req.body?.items) ? req.body.items : [];
    const card = req.body?.card || {};

    if (!eventId || !method || items.length === 0) {
      return res.status(400).json({ error: 'Event, payment method, and ticket items are required' });
    }

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
      `SELECT id, name, price, stock_remaining, max_per_order FROM event_ticket_types WHERE event_id = ? AND id IN (${placeholders}) FOR UPDATE`,
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
      `INSERT INTO payment_orders (event_id, payment_method, payment_status, subtotal, service_fee, total)
       VALUES (?, ?, 'SUCCESS', ?, ?, ?)`,
      [eventId, method, subtotal, serviceFee, total]
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

      for (let index = 1; index <= item.quantity; index++) {
        const rowLabel = String.fromCharCode(64 + (((nextTicketId - 1) % 6) + 1));
        const seatLabel = String(((nextTicketId - 1) % 30) + 1).padStart(2, '0');
        await connection.execute(
          `INSERT INTO tickets (
            id, title, image, date_label, time_label, venue, section, row_label, seat_label,
            qr_data, ticket_type, ticket_status, sort_order
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'UPCOMING', ?)`,
          [
            nextTicketId,
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

app.post('/api/auth/register', async (req, res, next) => {
  try {
    const { username, email, phone, password } = req.body || {};

    if (!username || !email || !password) {
      return res.status(400).json({ error: 'Username, email, and password are required' });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const [result] = await pool.execute(
      `INSERT INTO users (username, name, email, phone, password_hash, location, avatar_url, followers_count, upcoming_events_count, description, role, is_verified, sort_order)
       VALUES (?, ?, ?, ?, ?, 'Set your location', NULL, 0, 0, NULL, 'user', 1, 0)`,
      [username, username, email, phone || null, passwordHash],
    );

    res.status(201).json({
      user: {
        id: result.insertId,
        username,
        name: username,
        email,
        phone: phone || null,
        location: 'Set your location',
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

app.use((error, _req, res, _next) => {
  res.status(500).json({ error: error.message || 'Internal server error' });
});

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
