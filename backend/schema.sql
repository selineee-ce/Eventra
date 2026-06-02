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
  monthly_listeners_count INT NOT NULL DEFAULT 0,
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
-- NOTE: The sample seed below uses a placeholder password hash. Replace with a real bcrypt hash when creating real users.
INSERT INTO users (id, username, name, email, phone, password_hash, bio, location, avatar_url, followers_count, monthly_listeners_count, events_count, upcoming_events_count, genre, description, role, is_verified, sort_order) VALUES
(1, 'sabrina', 'Sabrina Aryan', 'sabrina@example.com', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'New York City, USA', NULL, 0, 0, 0, 24, NULL, NULL, 'user', 1, 1),
(2, 'vondax', 'VON DAX', 'vondax@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'Berlin, Germany', 'https://images.unsplash.com/photo-1516873240891-4bf014598ab4?w=800&auto=format&fit=crop&q=80', 4800000, 4800000, 123, 2, 'Industrial Techno', 'Von Dax is a pioneer of the melodic techno movement, seamlessly weaving ethereal vocal textures into driving industrial rhythms. His sound defines the modern underground, capturing the pulse of the digital age with a soul that remains unmistakably human.', 'promoter', 1, 1),
(3, 'elaravoss', 'ELARA VOSS', 'elara.voss@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'Amsterdam, Netherlands', 'https://images.unsplash.com/photo-1574169208507-84376144848b?w=800&auto=format&fit=crop&q=80', 1900000, 1900000, 64, 1, 'Melodic Techno', 'Elara Voss delivers atmospheric and deeply emotional melodic techno. Her cinematic synth swells and hypnotic percussion create an immersive sonic journey designed for massive festival stages and late-night stargazing.', 'promoter', 1, 2),
(4, 'morpheus', 'MORPHEUS', 'morpheus@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'London, United Kingdom', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&auto=format&fit=crop&q=80', 3000000, 3000000, 89, 1, 'Acid House', 'Morpheus bends reality with nostalgic 303 acid basslines fused with modern neonelectro aesthetics. Known for high-energy underground raves, his tracks bridge the gap between 90s warehouse culture and futuristic cyber soundscapes.', 'promoter', 1, 3),
(5, 'cyberian', 'CYBERIAN', 'cyberian@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'Berlin, Germany', 'https://images.unsplash.com/photo-1598387181032-a3103a2db5b3?w=800&auto=format&fit=crop&q=80', 1500000, 1500000, 42, 1, 'Hard Techno', 'Fast, aggressive, and uncompromising. Cyberian commands the underground scene with relentless 150 BPM industrial beats and dark, metallic sound designs that push audio systems to their absolute limits.', 'promoter', 1, 4),
(6, 'novaraine', 'NOVA RAINE', 'nova@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'Bali, Indonesia', 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&auto=format&fit=crop&q=80', 1200000, 1200000, 51, 1, 'Melodic House', 'Nova Raine blends uplifting progressive melodies with deep, organic house grooves. Her music captures the warmth of a beach sunrise, mixed with the sleek production of modern electronic club tracks.', 'promoter', 1, 5),
(7, 'voidwalker', 'VOIDWALKER', 'voidwalker@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'Singapore', 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=800&auto=format&fit=crop&q=80', 980000, 980000, 35, 0, 'Dark Techno', 'Emerging from the deep shadows of the digital subculture, Voidwalker crafts eerie, minimalist techno tracks utilizing heavy sub-bass and haunting ambient layers that test the boundaries of dark electronic art.', 'promoter', 1, 6),
(8, 'lunacrystal', 'LUNA CRYSTAL', 'luna@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'Kyoto, Japan', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80', 850000, 850000, 29, 1, 'Ambient Techno', 'Luna Crystal provides a dreamy, space-like escape with lush soundscapes and soft, drifting rhythmic beats. Perfect for deep focus or late-night decompression under a neon sky.', 'promoter', 1, 7),
(9, 'vectorblitz', 'VECTOR BLITZ', 'vector@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'Seoul, South Korea', 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&auto=format&fit=crop&q=80', 720000, 720000, 47, 0, 'Glitch Tech', 'A chaotic yet perfectly engineered fusion of digitized glitch effects and rapid techno percussion. Vector Blitz redefines cyberpunk sonics with glitchy modular synthesizer experiments.', 'promoter', 1, 8),
(10, 'oxygen7', 'OXYGEN 7', 'oxygen7@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'New York City, USA', 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80', 610000, 610000, 18, 0, 'Deep House', 'Smooth chord progressions, deep basslines, and soulful vocal chops form the identity of Oxygen 7. A breath of fresh air tailored for intimate lounge spaces and premium rooftop events.', 'promoter', 1, 9),
(11, 'deepstate', 'DEEP STATE', 'deepstate@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'Los Angeles, USA', 'https://images.unsplash.com/photo-1484755560693-a4074577af3a?w=800&auto=format&fit=crop&q=80', 540000, 540000, 22, 0, 'Minimal Techno', 'Deep State practices the art of restraint. Using micro-samples and strict, clinical loop arrangements, they build hypnotic, evolving rhythms that lock dancefloors into deep, long-lasting trances.', 'promoter', 1, 10),
(12, 'kryptic', 'KRYPTIC', 'kryptic@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'London, United Kingdom', 'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800&auto=format&fit=crop&q=80', 430000, 430000, 15, 0, 'Dubstep / Leftfield', 'Heavy system music engineered for massive subwoofers. Kryptic drops deep, dark, spacey basslines combined with crisp syncopated garage beats that echo the UK underground rave heritage.', 'promoter', 1, 11),
(13, 'echopulse', 'ECHO PULSE', 'echopulse@eventra.local', NULL, '$2b$10$exampleplaceholderhash......', NULL, 'Los Angeles, USA', 'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=800&auto=format&fit=crop&q=80', 390000, 390000, 31, 1, 'Synthwave', 'Nostalgic 1980s retro-futurism re-imagined for 2026. Echo Pulse drives neon-soaked basslines, retro drums, and emotional analog leads straight into the hearts of cyberpunk fans worldwide.', 'promoter', 1, 12)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  email = VALUES(email),
  phone = VALUES(phone),
  password_hash = VALUES(password_hash),
  bio = VALUES(bio),
  location = VALUES(location),
  avatar_url = VALUES(avatar_url),
  followers_count = VALUES(followers_count),
  monthly_listeners_count = VALUES(monthly_listeners_count),
  events_count = VALUES(events_count),
  upcoming_events_count = VALUES(upcoming_events_count),
  genre = VALUES(genre),
  description = VALUES(description),
  role = VALUES(role),
  is_verified = VALUES(is_verified),
  sort_order = VALUES(sort_order);


CREATE TABLE IF NOT EXISTS featured_events (
  id INT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  subtitle TEXT NOT NULL,
  image TEXT NOT NULL,
  venue VARCHAR(200) NOT NULL,
  city VARCHAR(120) NOT NULL,
  event_date DATE NOT NULL,
  source_url TEXT NULL,
  tag1 VARCHAR(50) NOT NULL,
  tag2 VARCHAR(50) NULL,
  button VARCHAR(50) NOT NULL,
  price_start VARCHAR(50) NOT NULL,
  is_limited TINYINT(1) NOT NULL DEFAULT 0,
  remaining_seats INT NOT NULL DEFAULT 0,
  sort_order INT NOT NULL,
  is_favorite TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS nearby_events (
  id INT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  date_label VARCHAR(40) NOT NULL,
  place VARCHAR(120) NOT NULL,
  city VARCHAR(120) NOT NULL,
  price VARCHAR(40) NOT NULL,
  image TEXT NOT NULL,
  detail_image TEXT NULL,
  venue_layout VARCHAR(160) NULL,
  artist_name VARCHAR(160) NULL,
  show_time VARCHAR(80) NULL,
  description TEXT NULL,
  source_url TEXT NULL,
  is_limited TINYINT(1) NOT NULL DEFAULT 0,
  remaining_seats INT NOT NULL DEFAULT 0,
  sort_order INT NOT NULL,
  is_favorite TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS pass_packages (
  id INT PRIMARY KEY,
  title VARCHAR(120) NOT NULL,
  description TEXT NOT NULL,
  price VARCHAR(50) NOT NULL,
  sort_order INT NOT NULL,
  is_favorite TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS event_ticket_types (
  id INT PRIMARY KEY,
  nearby_event_id INT NOT NULL,
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
  CONSTRAINT fk_ticket_types_nearby_event FOREIGN KEY (nearby_event_id) REFERENCES nearby_events(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS tickets (
  id INT PRIMARY KEY,
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

CREATE TABLE IF NOT EXISTS payment_cards (
  id INT PRIMARY KEY AUTO_INCREMENT,
  payment_order_id INT NOT NULL,
  card_holder VARCHAR(120) NOT NULL,
  card_brand VARCHAR(40) NOT NULL,
  card_last4 VARCHAR(4) NOT NULL,
  card_expiry VARCHAR(7) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_cards_order FOREIGN KEY (payment_order_id) REFERENCES payment_orders(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notifications (
  id INT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  subtitle TEXT NOT NULL,
  sort_order INT NOT NULL
);

CREATE TABLE IF NOT EXISTS user_events (
  id INT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  lineup VARCHAR(200) NOT NULL,
  venue VARCHAR(120) NOT NULL,
  location VARCHAR(160) NOT NULL,
  date_label VARCHAR(40) NOT NULL,
  sort_order INT NOT NULL,
  CONSTRAINT fk_user_events_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS exclusive_drops (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  badge VARCHAR(80) NOT NULL,
  description TEXT NOT NULL,
  image TEXT NULL,
  venue VARCHAR(200) NOT NULL,
  city VARCHAR(120) NOT NULL,
  event_date DATE NOT NULL,
  type ENUM('ticket','vip','soundcheck','merch') NOT NULL DEFAULT 'ticket',
  countdown_seconds INT NOT NULL DEFAULT 9912,
  remaining_seats INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0
);

INSERT INTO featured_events (id, title, subtitle, image, tag1, tag2, button, sort_order, is_favorite) VALUES
(1, 'NEON DREAMS:\n2026', 'Experience the pinnacle of immersive audio-visual performance with the season''s most anticipated lineup.', 'assets/images/image2.jpeg', 'FEATURED', 'WORLD TOUR', 'GET TICKETS', 1, 0),
(2, 'SONIC\nHORIZON', 'Journey beyond the edge of sound with an avant-garde showcase of world-class electronic producers and light-bending stage craft.', 'assets/images/image1.jpeg', 'FAVOURITES', 'EUROPE TOUR', 'PREORDER NOW', 2, 0),
(3, 'STARDUST\nECHOES', 'Join thousands for an emotional journey through the year’s most iconic anthems.', 'assets/images/image3.jpeg', 'FAVOURITES', NULL, 'GET TICKETS', 3, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title);

INSERT INTO pass_packages (id, title, description, price, sort_order, is_favorite) VALUES
(1, 'VIP Backstage Pass', 'An all-access journey behind the curtain of the global tour.', '\$4,999', 1, 0),
(2, 'Gold VIP Package', 'Experience the show from the very front row with premium service.', '\$1,200', 2, 1),
(3, 'Infinity Station Access', 'Elevate your viewing experience from our infinity stations.', '\$850', 3, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title);

INSERT INTO nearby_events (id, title, date_label, place, price, image, sort_order, is_favorite) VALUES
(1, 'Astra Project', 'MAY 20', 'THE HIVE', '\$50', 'https://images.unsplash.com/photo-1503095396549-807759245b35?q=80&w=1200&auto=format&fit=crop', 1, 0),
(2, 'Echoes of Solace', 'MAY 29', 'SKY ARENA', '\$80', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?q=80&w=1200&auto=format&fit=crop', 2, 0),
(3, 'Nova Pulse', 'JUN 02', 'LUNA DOME', '\$65', 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=1200&auto=format&fit=crop', 3, 0),
(4, 'Midnight Mirage', 'JUN 10', 'NEON CLUB', '\$90', 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?q=80&w=1200&auto=format&fit=crop', 4, 0),
(5, 'Velvet Frequency', 'JUN 18', 'ORBIT HALL', '\$70', 'https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?q=80&w=1200&auto=format&fit=crop', 5, 0),
(6, 'Lunar Echo', 'JUN 22', 'AETHER STAGE', '\$75', 'https://images.unsplash.com/photo-1499364615650-ec38552f4f34?q=80&w=1200&auto=format&fit=crop', 6, 0),
(7, 'Digital Bloom', 'JUL 01', 'NOVA HALL', '\$60', 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1200&auto=format&fit=crop', 7, 0),
(8, 'Afterlight', 'JUL 08', 'SPECTRA ARENA', '\$95', 'https://images.unsplash.com/photo-1506157786151-b8491531f063?q=80&w=1200&auto=format&fit=crop', 8, 0),
(9, 'Electric Aura', 'JUL 15', 'VOID CLUB', '\$55', 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?q=80&w=1200&auto=format&fit=crop', 9, 0),
(10, 'Celestial Noise', 'JUL 21', 'COSMOS DOME', '\$110', 'https://images.unsplash.com/photo-1507874457470-272b3c8d8ee2?q=80&w=1200&auto=format&fit=crop', 10, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title);

INSERT INTO tickets (id, title, image, date_label, time_label, venue, section, row_label, seat_label, qr_data, sort_order) VALUES
(1, 'THE WEEKND : AFTER HOURS TIL DAWN', 'https://images.unsplash.com/photo-1506157786151-b8491531f063?q=80&w=1200&auto=format&fit=crop', 'Nov 22,\n2025', '10:00 PM', 'France Stadium', '104', 'B', '12', 'Eventra-TheWeeknd-Section104-RowB-Seat12', 1),
(2, 'AFTER DARK : TECHNO SPECIAL', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=600&auto=format&fit=crop', 'Dec 05,\n2025', '11:30 PM', 'Fabric London', 'REAR', '12', 'Free', 'Eventra-AfterDark-SectionREAR-Row12', 2),
(3, 'BLUE NOTE SESSIONS : JAZZ NIGHT', 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?q=80&w=600&auto=format&fit=crop', 'Jan 18,\n2026', '08:00 PM', 'The Jazz Cafe', 'VIP', 'TABLE', '04', 'Eventra-BlueNote-VIP-Table04', 3)
ON DUPLICATE KEY UPDATE title = VALUES(title);

INSERT INTO notifications (id, title, subtitle, sort_order) VALUES
(1, 'New VIP Access Released', 'Exclusive backstage passes are now available.', 1),
(2, 'Event Reminder', 'Neon Dreams starts in 5 hours.', 2),
(3, 'Preorder Open', 'Preorder tickets for World Tour Tokyo.', 3)
ON DUPLICATE KEY UPDATE title = VALUES(title);

INSERT INTO user_events (id, user_id, title, lineup, venue, location, date_label, sort_order) VALUES
(1, 2, 'Echoes of Solace', 'Von Dax, Anyma, Tale Of Us', 'SKY ARENA', 'Marina Bay, Singapore', 'MAY 20', 1),
(2, 2, 'Neon Eclipse', 'Von Dax Live Set', 'THE GRAND', 'Tokyo, Japan', 'JUN 14', 2),
(3, 3, 'Echoes of Solace', 'Elara Voss, Mind Against', 'SKY ARENA', 'Marina Bay, Singapore', 'MAY 20', 1),
(4, 4, 'Acid Awakening', 'Morpheus, Peggy Gou', 'THE HIVE', 'Seoul, South Korea', 'MAY 28', 1),
(5, 5, 'Subterranean Overdrive', 'Cyberian, Sara Landry', 'BASEMENT 9', 'Berlin, Germany', 'JUN 02', 1),
(6, 6, 'Horizon Sunset Sessions', 'Nova Raine', 'OCEAN DOME', 'Bali, Indonesia', 'JUL 19', 1),
(7, 8, 'Stardust Echoes', 'Luna Crystal', 'NEBULA LOUNGE', 'Kyoto, Japan', 'AUG 05', 1),
(8, 13, 'Midnight Drive Tour', 'Echo Pulse, Kavinsky', 'RETRO DOME', 'Los Angeles, USA', 'SEP 12', 1)
ON DUPLICATE KEY UPDATE
  title = VALUES(title),
  lineup = VALUES(lineup),
  venue = VALUES(venue),
  location = VALUES(location),
  date_label = VALUES(date_label),
  sort_order = VALUES(sort_order);

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
('home.ticket_snackbar', 'Tickets Clicked'),
('artists.title', 'Trending Artists'),
('artists.subtitle', 'The architects of sound currently shaping the global underground landscape'),
('tickets.title', 'Your Tickets'),
('tickets.subtitle', 'Ready for the night of your life? Access all your passes here'),
('tickets.search_hint', 'Find a ticket...'),
('tickets.buy_more', 'Buy More Tickets'),
('tickets.view_pass', 'VIEW PASS'),
('notifications.title', 'Notifications'),
('profile.edit', 'EDIT PROFILE'),
('profile.stats.upcoming', 'UPCOMING EVENTS'),
('profile.stats.followers', 'FOLLOWERS'),
('profile.settings.title', 'ACCOUNT SETTINGS'),
('profile.logout', 'LOG OUT'),
('favorites.title', 'Favorites'),
('favorites.empty', 'Your saved passes and events will appear here.'),
('search.hint', 'Search events, artists, tickets...')
ON DUPLICATE KEY UPDATE config_value = VALUES(config_value);

INSERT INTO featured_events (
  id, title, subtitle, image, venue, city, event_date, source_url,
  tag1, tag2, button, price_start, is_limited, remaining_seats, sort_order, is_favorite
) VALUES
(1,'myBCA Java Jazz Festival 2026','The 21st edition of Jakarta International Java Jazz Festival moves to NICE, PIK 2 on 29-31 May 2026.','https://images.unsplash.com/photo-1511192336575-5a79af67a629?auto=format&fit=crop&w=1200&q=80','NICE PIK 2','Tangerang','2026-05-29','https://www.javajazzfestival.com/aboutus','JAZZ FESTIVAL','OFFICIAL 2026','GET TICKETS','Rp850.000',1,48,1,0),
(2,'Pestapora 2026','Boss Creator returns with a three-day Indonesian music celebration on 25-27 September 2026.','https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=1200&q=80','Gambir Expo & Hall D2 JIExpo','Jakarta','2026-09-25','https://pestapora.com/about-us/','LOCAL FEST','THREE DAYS','BOOK NOW','Rp450.000',0,0,2,0),
(3,'Djakarta Warehouse Project 2026','Indonesia electronic dance music festival brand returns for its 2026 edition.','https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=1200&q=80','Jakarta / Bali','Indonesia','2026-12-31','https://hub.ekraf.go.id/agenda-kreatif/detail/djakarta-warehouse-project-2026','EDM FESTIVAL','YEAR END','EXPLORE','Rp1.200.000',1,80,3,0),
(4,'Coldplay Music Of The Spheres Jakarta','Coldplay first Indonesia stadium show took place at Gelora Bung Karno on 15 November 2023.','https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=1200&q=80','Gelora Bung Karno Stadium','Jakarta','2023-11-15','https://www.coldplay.com/asia-australia-dates-announced/','ARCHIVE','WORLD TOUR','VIEW DETAIL','Rp800.000',0,0,4,0);

INSERT INTO nearby_events (
  id, title, date_label, place, city, price, image, detail_image, artist_name,
  show_time, description, source_url, is_limited, remaining_seats, sort_order, is_favorite
) VALUES
(1,'Java Jazz Festival 2026','29 MAY','NICE PIK 2','Tangerang','Rp850.000','https://images.unsplash.com/photo-1511192336575-5a79af67a629?auto=format&fit=crop&w=900&q=80','https://images.unsplash.com/photo-1511192336575-5a79af67a629?auto=format&fit=crop&w=1400&q=80','Java Jazz Festival','29-31 May 2026','Annual international jazz festival featuring global and Indonesian artists at its new home in NICE, PIK 2.','https://www.javajazzfestival.com/aboutus',1,48,1,0),
(2,'Pestapora 2026','25 SEP','Gambir Expo & Hall D2 JIExpo','Jakarta','Rp450.000','https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=900&q=80','https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=1400&q=80','Pestapora','25-27 Sep 2026','Three-day Indonesian music celebration by Boss Creator with a wide local lineup.','https://pestapora.com/about-us/',0,0,2,1),
(3,'Djakarta Warehouse Project 2026','31 DEC','Festival Venue TBA','Indonesia','Rp1.200.000','https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=900&q=80','https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=1400&q=80','DWP','31 Dec 2026 - 1 Jan 2027','DWP is one of Indonesia prominent electronic dance music festival brands.','https://hub.ekraf.go.id/agenda-kreatif/detail/djakarta-warehouse-project-2026',1,80,3,0),
(4,'BLACKPINK WORLD TOUR DEADLINE in Jakarta','01 NOV','Gelora Bung Karno Main Stadium','Jakarta','Rp1.450.000','https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?auto=format&fit=crop&w=900&q=80','https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?auto=format&fit=crop&w=1400&q=80','BLACKPINK','1-2 Nov 2025','BLACKPINK DEADLINE tour stop in Jakarta at Gelora Bung Karno Main Stadium.','https://www.blackpinkmusic.com/',1,12,4,0),
(5,'Coldplay Music Of The Spheres Jakarta','15 NOV','Gelora Bung Karno Stadium','Jakarta','Rp800.000','https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=900&q=80','https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=1400&q=80','Coldplay','15 Nov 2023, 20:00 WIB','Archive listing for Coldplay first Indonesia performance on the Music Of The Spheres World Tour.','https://www.coldplay.com/asia-australia-dates-announced/',0,0,5,1),
(6,'Synchronize Fest 2026','02 OCT','Gambir Expo Kemayoran','Jakarta','Rp500.000','https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=900&q=80','https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=1400&q=80','Synchronize Fest','2-4 Oct 2026','Multi-genre Indonesian music festival listing prepared for Eventra discovery.','https://www.synchronizefestival.com/',0,0,6,0);

INSERT INTO pass_packages (id, title, description, price, sort_order, is_favorite) VALUES
(1,'Festival Explorer','Early reminder, wishlist sync, and curated festival discovery.','Rp49.000/mo',1,0),
(2,'Priority Queue','Priority purchase window for selected ticket drops and VIP alerts.','Rp99.000/mo',2,1),
(3,'Ultimate Access','Premium concierge support, exclusive drops, and merch priority.','Rp199.000/mo',3,0);

INSERT INTO event_ticket_types (
  id, nearby_event_id, name, badge, badge_color, description,
  bullet1, bullet2, bullet3, price, stock_remaining, max_per_order, sort_order
) VALUES
(1,1,'Daily Pass','BEST VALUE','#20B486','Single-day festival access.','Valid for one selected festival day','General admission area','Digital ticket with QR verification',850000,120,6,1),
(2,1,'3-Day Pass','POPULAR','#F59E0B','Full festival weekend access.','Access for 29-31 May 2026','Multiple stages and festival area','Best for out-of-town visitors',1850000,80,4,2),
(3,2,'Daily Pass','LIMITED','#EF4444','Single-day Pestapora access.','Valid for one selected day','Festival ground access','Official digital ticket',450000,160,6,1),
(4,2,'3-Day Pass','FAN PICK','#8B5CF6','Three-day Pestapora access.','Access for 25-27 Sep 2026','All regular stages','Digital ticket with QR verification',950000,90,4,2),
(5,3,'GA Pass','EARLY BIRD','#06B6D4','General admission access for DWP.','Festival ground access','Digital ticket delivery','Official ID verification required',1200000,100,4,1),
(6,3,'VIP Deck','VIP','#EAB308','Premium viewing and lounge access.','Elevated viewing deck','Dedicated entry lane','Selected hospitality access',2500000,40,2,2),
(7,4,'CAT 1','HOT','#EF4444','Reserved seating for BLACKPINK Jakarta.','Assigned seat category','Digital QR entry','Official ID verification required',2900000,70,4,1),
(8,4,'VIP Soundcheck','SOUNDCHECK','#EC4899','VIP package with soundcheck access.','Soundcheck session','VIP laminate and merch','Priority entry lane',5500000,20,2,2),
(9,5,'Festival Seating','ARCHIVE','#64748B','Archive ticket category from public sale reference.','Historical listing','GBK stadium event','Digital ticket sample',800000,50,4,1),
(10,6,'Regular Pass','DISCOVERY','#22C55E','Regular Synchronize Fest access.','Festival ground access','Digital ticket with QR','Reminder enabled',500000,130,6,1);

INSERT INTO artists (
  id, name, followers, description,
  image_url, source_url, sort_order
) VALUES
(1,'Coldplay','48M','British band known for stadium-sized live shows and the Music Of The Spheres tour.','https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=900&q=80','https://www.coldplay.com/asia-australia-dates-announced/',1),
(2,'BLACKPINK','56M','South Korean girl group with global stadium-scale tours and a Jakarta stop in the DEADLINE tour cycle.','https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?auto=format&fit=crop&w=900&q=80','https://www.blackpinkmusic.com/',2),
(3,'Java Jazz Festival','1M','Indonesia long-running international jazz festival with its 21st edition scheduled for 29-31 May 2026.','https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?auto=format&fit=crop&w=900&q=80','https://www.javajazzfestival.com/aboutus',3),
(4,'Pestapora','700K','Three-day Indonesian music festival by Boss Creator scheduled for 25-27 September 2026.','https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=900&q=80','https://pestapora.com/about-us/',4),
(5,'Djakarta Warehouse Project','900K','Prominent Indonesian EDM festival brand listed for the 2026 creative economy agenda.','https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=900&q=80','https://hub.ekraf.go.id/agenda-kreatif/detail/djakarta-warehouse-project-2026',5);

INSERT INTO artist_events (
  id, artist_id, title, lineup, venue, location, date_label, sort_order
) VALUES
(1,1,'Coldplay Music Of The Spheres Jakarta','Coldplay','Gelora Bung Karno Stadium','Jakarta, Indonesia','15 NOV 2023',1),
(2,2,'BLACKPINK WORLD TOUR DEADLINE in Jakarta','BLACKPINK','Gelora Bung Karno Main Stadium','Jakarta, Indonesia','01 NOV 2025',2),
(3,3,'myBCA Java Jazz Festival 2026','Java Jazz Festival Lineup','NICE PIK 2','Tangerang, Indonesia','29 MAY 2026',3),
(4,4,'Pestapora 2026','Indonesian Artists Lineup','Gambir Expo & Hall D2 JIExpo','Jakarta, Indonesia','25 SEP 2026',4),
(5,5,'Djakarta Warehouse Project 2026','DWP Lineup','Festival Venue TBA','Indonesia','31 DEC 2026',5);

INSERT INTO tickets (
  id, title, image, date_label, time_label, venue, section, row_label,
  seat_label, qr_data, ticket_type, ticket_status, sort_order
) VALUES
(1,'Java Jazz Festival 2026','https://images.unsplash.com/photo-1511192336575-5a79af67a629?auto=format&fit=crop&w=900&q=80','29 MAY 2026','17:00 WIB','NICE PIK 2','DAILY PASS','GATE A','ENTRY 01','EVT-JJF-2026-001','DAILY PASS','UPCOMING',1),
(2,'Pestapora 2026','https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=900&q=80','25 SEP 2026','15:00 WIB','Gambir Expo & Hall D2 JIExpo','3-DAY PASS','GATE B','ENTRY 18','EVT-PESTAPORA-2026-002','3-DAY PASS','UPCOMING',2),
(3,'Djakarta Warehouse Project 2026','https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=900&q=80','31 DEC 2026','20:00 WIB','Festival Venue TBA','VIP DECK','LANE V','ENTRY 08','EVT-DWP-2026-003','VIP DECK','UPCOMING',3);

INSERT INTO notifications (id, title, subtitle, sort_order) VALUES
(1,'Java Jazz 2026 is live','Festival dates are set for 29-31 May 2026 at NICE, PIK 2.',1),
(2,'Pestapora 2026 reminder','Save 25-27 September 2026 for the three-day Indonesian music celebration.',2),
(3,'DWP 2026 added','Djakarta Warehouse Project 2026 is now listed in Eventra discovery.',3),
(4,'BLACKPINK archive updated','Jakarta DEADLINE tour data is available in artist profiles.',4);

INSERT INTO exclusive_drops (
  title, badge, description, image, venue, city, event_date, type,
  countdown_seconds, remaining_seats, is_active, sort_order
) VALUES
('Java Jazz 3-Day Priority Pass','PRIORITY','Early access allocation for Java Jazz 2026 3-day passes.','https://images.unsplash.com/photo-1511192336575-5a79af67a629?auto=format&fit=crop&w=900&q=80','NICE PIK 2','Tangerang','2026-05-29','ticket',9912,48,1,1),
('Pestapora Weekend Bundle','MEMBER DROP','Bundle access for three-day Pestapora 2026 discovery users.','https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=900&q=80','Gambir Expo & Hall D2 JIExpo','Jakarta','2026-09-25','ticket',12450,35,1,2),
('DWP VIP Deck Allocation','VIP','Limited VIP deck allocation for DWP 2026.','https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=900&q=80','Festival Venue TBA','Indonesia','2026-12-31','vip',8420,80,1,3);
