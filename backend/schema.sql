CREATE DATABASE IF NOT EXISTS eventra CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eventra;

CREATE TABLE IF NOT EXISTS profile (
  id INT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  membership_title VARCHAR(120) NOT NULL,
  location VARCHAR(120) NOT NULL,
  upcoming_events_count INT NOT NULL,
  avatar_url TEXT NULL
);

CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(120) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(30) NULL,
  password_hash VARCHAR(255) NOT NULL,
  membership_title VARCHAR(120) NULL,
  location VARCHAR(120) NULL,
  avatar_url TEXT NULL,
  upcoming_events_count INT NOT NULL DEFAULT 0,
  role VARCHAR(50) NOT NULL DEFAULT 'user',
  is_verified TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS app_config (
  config_key VARCHAR(120) PRIMARY KEY,
  config_value TEXT NOT NULL
);

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

CREATE TABLE IF NOT EXISTS artists (
  id INT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  followers VARCHAR(60) NOT NULL,
  monthly_listeners VARCHAR(60) NOT NULL,
  events_count VARCHAR(60) NOT NULL,
  genre VARCHAR(120) NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT NOT NULL,
  source_url TEXT NULL,
  sort_order INT NOT NULL
);

CREATE TABLE IF NOT EXISTS artist_events (
  id INT PRIMARY KEY,
  artist_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  lineup VARCHAR(200) NOT NULL,
  venue VARCHAR(120) NOT NULL,
  location VARCHAR(160) NOT NULL,
  date_label VARCHAR(40) NOT NULL,
  sort_order INT NOT NULL,
  CONSTRAINT fk_artist_events_artist FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE CASCADE
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

INSERT INTO users (
  username, email, phone, password_hash, membership_title, location,
  avatar_url, upcoming_events_count, role, is_verified
) VALUES (
  'edwin',
  'edwin@eventra.id',
  '081234567890',
  '$2b$10$exampleplaceholderhash......',
  'DIAMOND MEMBER | JAKARTA',
  'Jakarta, Indonesia',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
  6,
  'user',
  1
);

INSERT INTO profile (
  id, name, membership_title, location, upcoming_events_count, avatar_url
) VALUES (
  1,
  'Edwin Winarto',
  'DIAMOND MEMBER | JAKARTA',
  'Jakarta, Indonesia',
  6,
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80'
);

INSERT INTO app_config (config_key, config_value) VALUES
('home.hero_title', 'Your Personal Concert Hub'),
('home.hero_subtitle', 'Discover official concert info, curated drops, and ticket reminders in one place.'),
('home.featured_title', 'Featured Concerts'),
('home.exclusive_title', 'Exclusive Drops'),
('home.exclusive_subtitle', 'Limited access for selected members.'),
('home.pass_title', 'Eventra Pass'),
('home.pass_subtitle', 'Choose access that matches your concert habit.'),
('home.nearby_title', 'Happening Near You'),
('home.nearby_subtitle', 'Real Indonesian events and venues to explore.');

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
  bullet1, bullet2, bullet3, price, sort_order
) VALUES
(1,1,'Daily Pass','BEST VALUE','#20B486','Single-day festival access.','Valid for one selected festival day','General admission area','Digital ticket with QR verification',850000,1),
(2,1,'3-Day Pass','POPULAR','#F59E0B','Full festival weekend access.','Access for 29-31 May 2026','Multiple stages and festival area','Best for out-of-town visitors',1850000,2),
(3,2,'Daily Pass','LIMITED','#EF4444','Single-day Pestapora access.','Valid for one selected day','Festival ground access','Official digital ticket',450000,1),
(4,2,'3-Day Pass','FAN PICK','#8B5CF6','Three-day Pestapora access.','Access for 25-27 Sep 2026','All regular stages','Digital ticket with QR verification',950000,2),
(5,3,'GA Pass','EARLY BIRD','#06B6D4','General admission access for DWP.','Festival ground access','Digital ticket delivery','Official ID verification required',1200000,1),
(6,3,'VIP Deck','VIP','#EAB308','Premium viewing and lounge access.','Elevated viewing deck','Dedicated entry lane','Selected hospitality access',2500000,2),
(7,4,'CAT 1','HOT','#EF4444','Reserved seating for BLACKPINK Jakarta.','Assigned seat category','Digital QR entry','Official ID verification required',2900000,1),
(8,4,'VIP Soundcheck','SOUNDCHECK','#EC4899','VIP package with soundcheck access.','Soundcheck session','VIP laminate and merch','Priority entry lane',5500000,2),
(9,5,'Festival Seating','ARCHIVE','#64748B','Archive ticket category from public sale reference.','Historical listing','GBK stadium event','Digital ticket sample',800000,1),
(10,6,'Regular Pass','DISCOVERY','#22C55E','Regular Synchronize Fest access.','Festival ground access','Digital ticket with QR','Reminder enabled',500000,1);

INSERT INTO artists (
  id, name, followers, monthly_listeners, events_count, genre, description,
  image_url, source_url, sort_order
) VALUES
(1,'Coldplay','48M','62M','1 Event','Alternative Rock','British band known for stadium-sized live shows and the Music Of The Spheres tour.','https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=900&q=80','https://www.coldplay.com/asia-australia-dates-announced/',1),
(2,'BLACKPINK','56M','20M','1 Event','K-Pop','South Korean girl group with global stadium-scale tours and a Jakarta stop in the DEADLINE tour cycle.','https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?auto=format&fit=crop&w=900&q=80','https://www.blackpinkmusic.com/',2),
(3,'Java Jazz Festival','1M','Festival','1 Event','Jazz / R&B / Soul','Indonesia long-running international jazz festival with its 21st edition scheduled for 29-31 May 2026.','https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?auto=format&fit=crop&w=900&q=80','https://www.javajazzfestival.com/aboutus',3),
(4,'Pestapora','700K','Festival','1 Event','Indonesian Pop / Rock / Indie','Three-day Indonesian music festival by Boss Creator scheduled for 25-27 September 2026.','https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=900&q=80','https://pestapora.com/about-us/',4),
(5,'Djakarta Warehouse Project','900K','Festival','1 Event','Electronic Dance Music','Prominent Indonesian EDM festival brand listed for the 2026 creative economy agenda.','https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=900&q=80','https://hub.ekraf.go.id/agenda-kreatif/detail/djakarta-warehouse-project-2026',5);

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
