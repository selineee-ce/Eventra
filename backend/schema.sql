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

-- Users table for authentication and account data
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

-- NOTE: The sample seed below uses a placeholder password hash. Replace with a real bcrypt hash when creating real users.
INSERT INTO users (username, email, phone, password_hash, membership_title, location, avatar_url, upcoming_events_count, role, is_verified)
VALUES ('sabrina', 'sabrina@example.com', NULL, '$2b$10$exampleplaceholderhash......', 'DIAMOND MEMBER | NYC', 'New York City, USA', NULL, 24, 'user', 1)
ON DUPLICATE KEY UPDATE email = VALUES(email);


CREATE TABLE IF NOT EXISTS featured_events (
  id INT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  subtitle TEXT NOT NULL,
  image TEXT NOT NULL,
  tag1 VARCHAR(50) NOT NULL,
  tag2 VARCHAR(50) NULL,
  button VARCHAR(50) NOT NULL,
  sort_order INT NOT NULL,
  is_favorite TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS pass_packages (
  id INT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  price VARCHAR(40) NOT NULL,
  sort_order INT NOT NULL,
  is_favorite TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS nearby_events (
  id INT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  date_label VARCHAR(40) NOT NULL,
  place VARCHAR(120) NOT NULL,
  price VARCHAR(40) NOT NULL,
  image TEXT NOT NULL,
  sort_order INT NOT NULL,
  is_favorite TINYINT(1) NOT NULL DEFAULT 0
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
  sort_order INT NOT NULL
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

INSERT INTO profile (id, name, membership_title, location, upcoming_events_count, avatar_url)
VALUES (1, 'Sabrina Aryan', 'DIAMOND MEMBER | NYC', 'New York City, USA', 24, NULL)
ON DUPLICATE KEY UPDATE name = VALUES(name);

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

INSERT INTO artists (id, name, followers, monthly_listeners, events_count, genre, description, image_url, sort_order) VALUES
(1, 'VON DAX', '4.8M Followers', '4.8M', '123', 'Industrial Techno', 'Von Dax is a pioneer of the melodic techno movement, seamlessly weaving ethereal vocal textures into driving industrial rhythms. His sound defines the modern underground, capturing the pulse of the digital age with a soul that remains unmistakably human.', 'https://images.unsplash.com/photo-1516873240891-4bf014598ab4?w=800&auto=format&fit=crop&q=80', 1),
(2, 'ELARA VOSS', '1.9M Followers', '1.9M', '64', 'Melodic Techno', 'Elara Voss delivers atmospheric and deeply emotional melodic techno. Her cinematic synth swells and hypnotic percussion create an immersive sonic journey designed for massive festival stages and late-night stargazing.', 'https://images.unsplash.com/photo-1574169208507-84376144848b?w=800&auto=format&fit=crop&q=80', 2),
(3, 'MORPHEUS', '3.0M Followers', '3.0M', '89', 'Acid House', 'Morpheus bends reality with nostalgic 303 acid basslines fused with modern neonelectro aesthetics. Known for high-energy underground raves, his tracks bridge the gap between 90s warehouse culture and futuristic cyber soundscapes.', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&auto=format&fit=crop&q=80', 3),
(4, 'CYBERIAN', '1.5M Followers', '1.5M', '42', 'Hard Techno', 'Fast, aggressive, and uncompromising. Cyberian commands the underground scene with relentless 150 BPM industrial beats and dark, metallic sound designs that push audio systems to their absolute limits.', 'https://images.unsplash.com/photo-1598387181032-a3103a2db5b3?w=800&auto=format&fit=crop&q=80', 4),
(5, 'NOVA RAINE', '1.2M Followers', '1.2M', '51', 'Melodic House', 'Nova Raine blends uplifting progressive melodies with deep, organic house grooves. Her music captures the warmth of a beach sunrise, mixed with the sleek production of modern electronic club tracks.', 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&auto=format&fit=crop&q=80', 5),
(6, 'VOIDWALKER', '980K Followers', '980K', '35', 'Dark Techno', 'Emerging from the deep shadows of the digital subculture, Voidwalker crafts eerie, minimalist techno tracks utilizing heavy sub-bass and haunting ambient layers that test the boundaries of dark electronic art.', 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=800&auto=format&fit=crop&q=80', 6),
(7, 'LUNA CRYSTAL', '850K Followers', '850K', '29', 'Ambient Techno', 'Luna Crystal provides a dreamy, space-like escape with lush soundscapes and soft, drifting rhythmic beats. Perfect for deep focus or late-night decompression under a neon sky.', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80', 7),
(8, 'VECTOR BLITZ', '720K Followers', '720K', '47', 'Glitch Tech', 'A chaotic yet perfectly engineered fusion of digitized glitch effects and rapid techno percussion. Vector Blitz redefines cyberpunk sonics with glitchy modular synthesizer experiments.', 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&auto=format&fit=crop&q=80', 8),
(9, 'OXYGEN 7', '610K Followers', '610K', '18', 'Deep House', 'Smooth chord progressions, deep basslines, and soulful vocal chops form the identity of Oxygen 7. A breath of fresh air tailored for intimate lounge spaces and premium rooftop events.', 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80', 9),
(10, 'DEEP STATE', '540K Followers', '540K', '22', 'Minimal Techno', 'Deep State practices the art of restraint. Using micro-samples and strict, clinical loop arrangements, they build hypnotic, evolving rhythms that lock dancefloors into deep, long-lasting trances.', 'https://images.unsplash.com/photo-1484755560693-a4074577af3a?w=800&auto=format&fit=crop&q=80', 10),
(11, 'KRYPTIC', '430K Followers', '430K', '15', 'Dubstep / Leftfield', 'Heavy system music engineered for massive subwoofers. Kryptic drops deep, dark, spacey basslines combined with crisp syncopated garage beats that echo the UK underground rave heritage.', 'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800&auto=format&fit=crop&q=80', 11),
(12, 'ECHO PULSE', '390K Followers', '390K', '31', 'Synthwave', 'Nostalgic 1980s retro-futurism re-imagined for 2026. Echo Pulse drives neon-soaked basslines, retro drums, and emotional analog leads straight into the hearts of cyberpunk fans worldwide.', 'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=800&auto=format&fit=crop&q=80', 12)
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO artist_events (id, artist_id, title, lineup, venue, location, date_label, sort_order) VALUES
(1, 1, 'Echoes of Solace', 'Von Dax, Anyma, Tale Of Us', 'SKY ARENA', 'Marina Bay, Singapore', 'MAY 20', 1),
(2, 1, 'Neon Eclipse', 'Von Dax Live Set', 'THE GRAND', 'Tokyo, Japan', 'JUN 14', 2),
(3, 2, 'Echoes of Solace', 'Elara Voss, Mind Against', 'SKY ARENA', 'Marina Bay, Singapore', 'MAY 20', 1),
(4, 3, 'Acid Awakening', 'Morpheus, Peggy Gou', 'THE HIVE', 'Seoul, South Korea', 'MAY 28', 1),
(5, 4, 'Subterranean Overdrive', 'Cyberian, Sara Landry', 'BASEMENT 9', 'Berlin, Germany', 'JUN 02', 1),
(6, 5, 'Horizon Sunset Sessions', 'Nova Raine', 'OCEAN DOME', 'Bali, Indonesia', 'JUL 19', 1),
(7, 7, 'Stardust Echoes', 'Luna Crystal', 'NEBULA LOUNGE', 'Kyoto, Japan', 'AUG 05', 1),
(8, 12, 'Midnight Drive Tour', 'Echo Pulse, Kavinsky', 'RETRO DOME', 'Los Angeles, USA', 'SEP 12', 1)
ON DUPLICATE KEY UPDATE title = VALUES(title);
