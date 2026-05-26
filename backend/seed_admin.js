const path = require('path');
const dotenv = require('dotenv');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');

dotenv.config({ path: path.join(__dirname, '.env') });

const config = {
  host: process.env.MYSQL_HOST || process.env.DB_HOST || '127.0.0.1',
  user: process.env.MYSQL_USER || process.env.DB_USER || 'root',
  password: process.env.MYSQL_PASSWORD || process.env.DB_PASSWORD || '',
  database: process.env.MYSQL_DATABASE || process.env.DB_NAME || 'eventra',
  port: process.env.MYSQL_PORT ? parseInt(process.env.MYSQL_PORT, 10) : (process.env.DB_PORT ? parseInt(process.env.DB_PORT,10) : 3306),
};

async function main() {
  const conn = await mysql.createConnection(config);
  const username = 'admin';
  const email = 'admin@example.com';
  const password = 'admin';
  const role = 'admin';

  const passwordHash = await bcrypt.hash(password, 10);

  const sql = `INSERT INTO users (username, email, password_hash, role, is_verified)
    VALUES (?, ?, ?, ?, 1)
    ON DUPLICATE KEY UPDATE
      password_hash = VALUES(password_hash),
      email = VALUES(email),
      role = VALUES(role),
      is_verified = VALUES(is_verified)`;

  const [res] = await conn.execute(sql, [username, email, passwordHash, role]);
  console.log('Seed complete. Insert/Update affectedRows:', res.affectedRows);
  await conn.end();
}

main().catch(err => {
  console.error('Seed failed:', err);
  process.exit(1);
});
