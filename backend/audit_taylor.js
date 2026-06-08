import mysql from 'mysql2/promise';

async function audit() {
  const pool = mysql.createPool({
    host: 'localhost',
    port: 3307,
    user: 'eventra',
    password: 'eventra',
    database: 'eventra',
  });

  try {
    console.log('--- USER DATA (taylorswift) ---');
    const [users] = await pool.query('SELECT id, username, name, bio, description, role FROM users WHERE username = "taylorswift" OR name LIKE "%Taylor%"');
    console.log(JSON.stringify(users, null, 2));

    console.log('\n--- ARTIST DATA (Taylor Swift) ---');
    if (await tableExists(pool, 'artists')) {
      const [artists] = await pool.query('SELECT id, name, description FROM artists WHERE name LIKE "%Taylor%"');
      console.log(JSON.stringify(artists, null, 2));
    }

    console.log('\n--- EVENT DATA (Taylor Swift) ---');
    if (await tableExists(pool, 'events')) {
      const [events] = await pool.query('SELECT id, title, lineup, description FROM events WHERE lineup LIKE "%Taylor%" OR title LIKE "%Taylor%"');
      console.log(JSON.stringify(events, null, 2));
    }

  } catch (err) {
    console.error(err);
  } finally {
    await pool.end();
  }
}

async function tableExists(pool, tableName) {
  const [rows] = await pool.query(
    'SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = "eventra" AND TABLE_NAME = ?',
    [tableName]
  );
  return rows.length > 0;
}

audit();
