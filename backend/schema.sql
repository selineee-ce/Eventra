CREATE DATABASE IF NOT EXISTS eventra CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eventra;

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(120) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30) NULL,
    password_hash VARCHAR(255) NOT NULL,
    bio TEXT NULL,
    location VARCHAR(120) NULL,
    avatar_url TEXT NULL,
    followers_count INT NOT NULL DEFAULT 0,
    events_count INT NOT NULL DEFAULT 0,
    upcoming_events_count INT NOT NULL DEFAULT 0,
    genre VARCHAR(120) NULL,
    description TEXT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    is_verified TINYINT(1) NOT NULL DEFAULT 0,
    sort_order INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS app_config (
    config_key VARCHAR(120) PRIMARY KEY,
    config_value TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    title VARCHAR(200) NOT NULL,
    lineup VARCHAR(200) NULL,
    venue VARCHAR(120) NOT NULL,
    city VARCHAR(120) NOT NULL,
    date_label VARCHAR(40) NOT NULL,
    show_time VARCHAR(80) NULL,
    price VARCHAR(40) NULL,
    image TEXT NULL,
    detail_image TEXT NULL,
    venue_layout VARCHAR(160) NULL,
    description TEXT NULL,
    source_url TEXT NULL,
    tag1 VARCHAR(50) NULL,
    tag2 VARCHAR(50) NULL,
    button VARCHAR(50) NULL,
    is_featured TINYINT(1) NOT NULL DEFAULT 0,
    is_limited TINYINT(1) NOT NULL DEFAULT 0,
    remaining_seats INT NOT NULL DEFAULT 0,
    sort_order INT NOT NULL DEFAULT 0,
    is_favorite TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT fk_events_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pass_packages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(120) NOT NULL,
    description TEXT NOT NULL,
    price VARCHAR(50) NOT NULL,
    sort_order INT NOT NULL,
    is_favorite TINYINT(1) NOT NULL DEFAULT 0
);

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
    CONSTRAINT fk_ticket_types_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    image TEXT NOT NULL,
    date_label VARCHAR(40) NOT NULL,
    time_label VARCHAR(40) NOT NULL,
    venue VARCHAR(120) NOT NULL,
    section VARCHAR(40) NOT NULL,
    row_label VARCHAR(40) NOT NULL,
    seat_label VARCHAR(40) NOT NULL,
    qr_data VARCHAR(255) NOT NULL,
    ticket_type VARCHAR(100) NOT NULL,
    ticket_status VARCHAR(50) NOT NULL DEFAULT 'UPCOMING',
    sort_order INT NOT NULL
);

CREATE TABLE IF NOT EXISTS payment_orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT NOT NULL,
    payment_method ENUM('qris','gopay','ovo','visa') NOT NULL,
    payment_status ENUM('PENDING','SUCCESS','FAILED') NOT NULL DEFAULT 'PENDING',
    subtotal INT NOT NULL,
    service_fee INT NOT NULL,
    total INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payment_order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    payment_order_id INT NOT NULL,
    ticket_type_id INT NOT NULL,
    ticket_name VARCHAR(120) NOT NULL,
    quantity INT NOT NULL,
    unit_price INT NOT NULL,
    CONSTRAINT fk_payment_items_order FOREIGN KEY (payment_order_id) REFERENCES payment_orders(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS exclusive_drops (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(120) NOT NULL,
    badge VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    image TEXT NOT NULL,
    venue VARCHAR(120) NOT NULL,
    city VARCHAR(120) NOT NULL,
    event_date DATE NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'ticket',
    countdown_seconds INT NOT NULL DEFAULT 0,
    remaining_seats INT NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    sort_order INT NOT NULL
);

CREATE TABLE IF NOT EXISTS notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    subtitle TEXT NOT NULL,
    sort_order INT NOT NULL
);

INSERT INTO users (id, username, name, email, phone, password_hash, bio, location, avatar_url, followers_count, events_count, upcoming_events_count, genre, description, role, is_verified, sort_order) VALUES
(1, 'sabrina', 'Sabrina Carpenter', 'sabrina@eventra.local', '+12135550143', '$2b$10$7RmsbXfI6fK9Z8gHY2VvUe1A6rN9A7e4Z3x1Wv8h8G2Yc7OWp7xyz', 'Short n Sweet', 'Los Angeles, USA', 'assets/artists/sabrina.jpg', 45000000, 150, 12, 'Pop', 'Espresso-fueled pop anthems and witty lyricism taking over the global charts.', 'promoter', 1, 0),
(2, 'coldplay', 'COLDPLAY', 'coldplay@eventra.local', '+442079460192', '$2b$10$7RmsbXfI6fK9Z8gHY2VvUe1A6rN9A7e4Z3x1Wv8h8G2Yc7OWp7xyz', 'Music of the Spheres', 'London, United Kingdom', 'assets/artists/coldplay.jpg', 65000000, 800, 25, 'Alternative Rock', 'British rock legends known for their historic, colorful, and record-breaking stadium tours.', 'promoter', 1, 0),
(3, 'brunomars', 'BRUNO MARS', 'bruno@eventra.local', '+13105550198', '$2b$10$7RmsbXfI6fK9Z8gHY2VvUe1A6rN9A7e4Z3x1Wv8h8G2Yc7OWp7xyz', '24K Magic in the Air', 'Los Angeles, USA', 'assets/artists/brunomars.jpg', 35000000, 450, 14, 'Pop / Funk', 'The ultimate showman blending retro funk, soul, and modern pop.', 'promoter', 1, 0),
(5, 'seventeen', 'SEVENTEEN', 'svt@eventra.local', '+8225550123', '$2b$10$7RmsbXfI6fK9Z8gHY2VvUe1A6rN9A7e4Z3x1Wv8h8G2Yc7OWp7xyz', 'Say the name, SEVENTEEN!', 'Seoul, South Korea', 'assets/artists/seventeen.jpg', 14000000, 300, 8, 'K-Pop', 'Self-producing K-Pop powerhouse known for their synchronized choreography.', 'promoter', 1, 0),
(7, 'fiersabesari', 'Fiersa Besari', 'fiersa@eventra.local', '+628112233445', '$2b$10$7RmsbXfI6fK9Z8gHY2VvUe1A6rN9A7e4Z3x1Wv8h8G2Yc7OWp7xyz', 'Garis Waktu', 'Bandung, Indonesia', 'assets/artists/fiersabesari.jpg', 12000000, 500, 5, 'Indie Folk', 'Indonesian indie-folk singer-songwriter known for his poetic lyrics.', 'promoter', 1, 0),
(8, 'sheilaon7', 'Sheila On 7', 'so7@eventra.local', '+628123456789', '$2b$10$7RmsbXfI6fK9Z8gHY2VvUe1A6rN9A7e4Z3x1Wv8h8G2Yc7OWp7xyz', 'Kisah Klasik Untuk Masa Depan', 'Yogyakarta, Indonesia', 'assets/artists/sheilaon7.jpg', 6000000, 900, 4, 'Pop Rock', 'The ultimate timeless band of Indonesia. Every concert is a massive karaoke session.', 'promoter', 1, 0),
(13, 'laufey', 'LAUFEY', 'laufey@eventra.local', '+3545551234', '$2b$10$7RmsbXfI6fK9Z8gHY2VvUe1A6rN9A7e4Z3x1Wv8h8G2Yc7OWp7xyz', 'Bewitched', 'Reykjavik, Iceland', 'assets/artists/laufey.jpg', 5000000, 180, 13, 'Jazz', 'Bringing jazz back to Gen Z with cinematic cello lines and classic vocals.', 'promoter', 1, 0),
(15, 'hindia', 'Hindia', 'hindia@eventra.local', '+628129988776', '$2b$10$7RmsbXfI6fK9Z8gHY2VvUe1A6rN9A7e4Z3x1Wv8h8G2Yc7OWp7xyz', 'Lagipula Hidup Akan Berakhir', 'Jakarta, Indonesia', 'assets/artists/hindia.jpg', 5500000, 450, 14, 'Indie Rock', 'Baskara Putra delivers alternative indie rock that defines modern youth anxiety.', 'promoter', 1, 0)
ON DUPLICATE KEY UPDATE username=VALUES(username), name=VALUES(name), email=VALUES(email), password_hash=VALUES(password_hash);

SET @rank := 0;
UPDATE users SET sort_order = (@rank := @rank + 1) ORDER BY followers_count DESC;

INSERT INTO events (id, user_id, title, lineup, venue, city, date_label, show_time, price, image, detail_image, description, source_url, tag1, tag2, button, is_featured, is_limited, remaining_seats, is_favorite) VALUES
(1, 13, 'Laufey: Bewitched Tour', 'Laufey', 'NICE PIK 2', 'Tangerang', '2026-05-29', '20:00 WIB', 'Rp850.000', 'assets/events/laufey_jiexpo.webp', 'assets/events/laufey_jiexpo.webp', 'Annual international jazz festival featuring global and Indonesian artists at its new home in NICE, PIK 2.', 'https://www.javajazzfestival.com/aboutus', 'JAZZ FESTIVAL', 'OFFICIAL 2026', 'GET TICKETS', 1, 1, 48, 1),
(2, NULL, 'Pestapora 2026', 'Hindia, Sheila On 7, Tulus, Fiersa Besari', 'Gambir Expo & Hall D2 JIExpo', 'Jakarta', '2026-09-25', '15:00 WIB', 'Rp450.000', 'assets/events/wtf2026.jpg', 'assets/events/wtf2026.jpg', 'Three-day Indonesian music celebration by Boss Creator with a wide local lineup.', 'https://pestapora.com/about-us/', 'LOCAL FEST', 'THREE DAYS', 'BOOK NOW', 1, 0, 0, 1),
(3, NULL, 'Djakarta Warehouse Project 2026', 'DWP Lineup TBA', 'GWK Cultural Park', 'Bali', '2026-12-31', '18:00 WIB', 'Rp1.200.000', 'assets/events/alan_walker.jpg', 'assets/events/alan_walker.jpg', 'DWP is one of Indonesia prominent electronic dance music festival brands.', 'https://hub.ekraf.go.id/agenda-kreatif/detail/djakarta-warehouse-project-2026', 'EDM FESTIVAL', 'YEAR END', 'EXPLORE', 1, 1, 80, 0),
(4, 2, 'Coldplay: Music Of The Spheres Jakarta', 'Coldplay', 'Gelora Bung Karno Stadium', 'Jakarta', '2023-11-15', '20:00 WIB', 'Rp800.000', 'assets/events/seventeen_concert.jpeg', 'assets/events/seventeen_concert.jpeg', 'Archive listing for Coldplay first Indonesia performance on the Music Of The Spheres World Tour.', 'https://www.coldplay.com/asia-australia-dates-announced/', 'ARCHIVE', 'WORLD TOUR', 'VIEW DETAIL', 0, 0, 0, 0),
(5, 8, 'Sheila On 7: Tunggu Aku Di Jakarta', 'Sheila On 7', 'Gelora Bung Karno (GBK) Main Stadium', 'Jakarta', '2026-12-25', '19:00 WIB', 'Rp600.000', 'assets/events/so7_gbk.webp', 'assets/events/so7_gbk.webp', 'Multi-genre Indonesian music festival listing prepared for Eventra discovery.', 'https://www.synchronizefestival.com/', 'LOCAL ROCK', 'SOLO CONCERT', 'BUY TICKETS', 0, 0, 0, 1)
ON DUPLICATE KEY UPDATE title=VALUES(title), date_label=VALUES(date_label), venue=VALUES(venue), price=VALUES(price);

SET @rank := 0;
UPDATE events SET sort_order = (@rank := @rank + 1) ORDER BY STR_TO_DATE(date_label, '%Y-%m-%d') ASC;

INSERT INTO event_ticket_types (id, event_id, name, badge, badge_color, description, bullet1, bullet2, bullet3, price, stock_remaining, max_per_order, sort_order) VALUES
(1, 1, 'Daily Pass', 'BEST VALUE', '#20B486', 'Single-day festival access.', 'Valid for one selected festival day', 'General admission area', 'Digital ticket with QR verification', 850000, 120, 6, 1),
(2, 1, '3-Day Pass', 'POPULAR', '#F59E0B', 'Full festival weekend access.', 'Access for 29-31 May 2026', 'Multiple stages and festival area', 'Best for out-of-town visitors', 1850000, 80, 4, 2),
(3, 2, 'Daily Pass', 'LIMITED', '#EF4444', 'Single-day Pestapora access.', 'Valid for one selected day', 'Festival ground access', 'Official digital ticket', 450000, 160, 6, 1),
(4, 2, '3-Day Pass', 'FAN PICK', '#8B5CF6', 'Three-day Pestapora access.', 'Access for 25-27 Sep 2026', 'All regular stages', 'Digital ticket with QR verification', 950000, 90, 4, 2)
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price);

INSERT INTO tickets (id, title, image, date_label, time_label, venue, section, row_label, seat_label, qr_data, ticket_type, ticket_status, sort_order) VALUES
(1, 'Laufey: Bewitched Tour', 'assets/events/laufey_jiexpo.webp', 'Jun 12,\n2026', '07:30 PM', 'JIExpo Theatre, Jakarta', 'VIP', 'CENTER', 'A-08', 'Eventra-Laufey-VIP-Center-A08', 'DAILY PASS', 'UPCOMING', 1),
(2, 'DJAKARTA WAREHOUSE PROJECT', 'assets/events/featured_events/featured_dwp.jpg', 'Dec 11,\n2026', '05:00 PM', 'JIExpo Kemayoran, Jakarta', 'GA', 'FESTIVAL', 'Free', 'Eventra-DWP2026-GA-Festival-Free', 'VIP DECK', 'UPCOMING', 2),
(3, 'Sheila On 7: Tunggu Aku Di Jakarta', 'assets/events/so7_gbk.webp', 'Dec 25,\n2026', '08:00 PM', 'Gelora Bung Karno Main Stadium', 'CAT 2', 'WEST', 'B-14', 'Eventra-SO7-GBK-CAT2-West-B14', '3-DAY PASS', 'UPCOMING', 3)
ON DUPLICATE KEY UPDATE title=VALUES(title), venue=VALUES(venue);

INSERT INTO notifications (id, title, subtitle, sort_order) VALUES
(1, 'We The Fest 2026 Ticket Status', 'Your ticket for WTF 2026 is ready. Check your ticket wallet now!', 1),
(2, 'Concert Reminder!', 'Laufey: Bewitched Tour at JIExpo Theatre starts in 5 hours. Prepare your QR Code.', 2),
(3, 'Presorder Tickets Open', 'Preorder tickets for NIKI: Buzz World Tour Jakarta are now available for VIP users.', 3),
(4, 'Ticket War Reminder! 📢', 'General Sales for SEVENTEEN: Right Here World Tour Jakarta starts in 30 minutes. Get ready!', 4),
(5, 'Schedule Update 🗓️', 'Alan Walker: Walkerworld Tour Bali has updated its gate-open time to 04:00 PM.', 5),
(6, 'Exclusive Merch Drop 👕', 'Official Hindia: Lagipula Hidup Akan Berakhir merchandise is now available for pre-order.', 6),
(7, 'Cashback Promo! 🎟️', 'Get 15% cashback for every ticket purchase using Eventra Pay this week. Don''t miss out!', 7),
(8, 'Waitlist Alert ✨', 'Additional CAT 1 tickets for Taylor Swift: The Eras Tour have been released. Grab them fast!', 8)
ON DUPLICATE KEY UPDATE title=VALUES(title), subtitle=VALUES(subtitle);

INSERT INTO exclusive_drops (id, title, badge, description, image, venue, city, event_date, type, countdown_seconds, remaining_seats, is_active, sort_order) VALUES
(1, 'Java Jazz 3-Day Priority Pass', 'PRIORITY', 'Early access allocation for Java Jazz 2026 3-day passes.', 'assets/events/laufey_jiexpo.webp', 'NICE PIK 2', 'Tangerang', '2026-05-29', 'ticket', 9912, 48, 1, 1),
(2, 'Pestapora Weekend Bundle', 'MEMBER DROP', 'Bundle access for three-day Pestapora 2026 discovery users.', 'assets/events/wtf2026.jpg', 'Gambir Expo & Hall D2 JIExpo', 'Jakarta', '2026-09-25', 'ticket', 45000, 20, 1, 2)
ON DUPLICATE KEY UPDATE title=VALUES(title);

INSERT INTO app_config (config_key, config_value) VALUES
('home.hero_title', 'Your Personal Concert Hub'),
('home.hero_subtitle', 'Discover official concert info, curated drops, and ticket reminders in one place.'),
('home.featured_title', 'Featured Concerts'),
('home.exclusive_title', 'Exclusive Drops'),
('home.exclusive_subtitle', 'Limited access for selected members.'),
('home.pass_title', 'Eventra Pass'),
('home.pass_subtitle', 'Choose access that matches your concert habit.'),
('home.nearby_title', 'Happening Near You'),
('home.view_all', 'VIEW ALL'),
('artists.title', 'Trending Artists'),
('search.hint', 'Search events, artists, tickets...')
ON DUPLICATE KEY UPDATE config_value = VALUES(config_value);