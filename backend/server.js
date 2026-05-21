import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
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
    const rows = await query('SELECT id, title, subtitle, image, tag1, tag2, button, sort_order, is_favorite FROM featured_events ORDER BY sort_order ASC');
    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/home/passes', async (_req, res, next) => {
  try {
    const rows = await query('SELECT id, title, description AS desc, price, sort_order, is_favorite FROM pass_packages ORDER BY sort_order ASC');
    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/home/nearby-events', async (_req, res, next) => {
  try {
    const rows = await query('SELECT id, title, date_label AS date, place, price, image, sort_order, is_favorite FROM nearby_events ORDER BY sort_order ASC');
    res.json({ data: rows });
  } catch (error) {
    next(error);
  }
});

app.get('/api/tickets', async (_req, res, next) => {
  try {
    const rows = await query('SELECT id, title, image, date_label, time_label, venue, section, row_label, seat_label, qr_data, sort_order FROM tickets ORDER BY sort_order ASC');
    res.json({ data: rows });
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
    const [row] = await query('SELECT id, name, membership_title, location, upcoming_events_count, avatar_url FROM profile ORDER BY id ASC LIMIT 1');
    res.json({ profile: row || {} });
  } catch (error) {
    next(error);
  }
});

app.get('/api/artists', async (_req, res, next) => {
  try {
    const artists = await query('SELECT id, name, followers, monthly_listeners AS monthlyListeners, events_count AS eventsCount, genre, description, image_url AS imageUrl, sort_order FROM artists ORDER BY sort_order ASC');
    const [events] = await pool.query('SELECT artist_id, title, lineup, venue, location, date_label AS date FROM artist_events ORDER BY sort_order ASC');

    const groupedEvents = events.reduce((accumulator, event) => {
      const key = String(event.artist_id);
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
      followers: artist.followers,
      monthlyListeners: artist.monthlyListeners,
      eventsCount: artist.eventsCount,
      genre: artist.genre,
      description: artist.description,
      imageUrl: artist.imageUrl,
      upcomingEvents: groupedEvents[String(artist.id)] || [],
    }));

    res.json({ data });
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
    await query('UPDATE nearby_events SET is_favorite = ? WHERE id = ?', [isFavorite, eventId]);
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

app.use((error, _req, res, _next) => {
  res.status(500).json({ error: error.message || 'Internal server error' });
});

app.listen(port, () => {
  console.log(`Eventra API listening on port ${port}`);
});
