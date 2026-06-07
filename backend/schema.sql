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
    is_featured TINYINT(1) NOT NULL DEFAULT 0, -- 1 untuk Carousel Atas, 0 untuk List Bawah
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

CREATE TABLE IF NOT EXISTS user_favorites (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    favorite_type ENUM('event', 'pass') NOT NULL,
    item_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_favorites_user_seed FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_favorites_item (user_id, favorite_type, item_id)
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
    user_id INT NULL,
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
    sort_order INT NOT NULL,
    CONSTRAINT fk_tickets_user_seed FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
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

-- Seed Data Users (Misalkan Semua Artis adalah Promoter)
INSERT INTO users (id, username, name, email, phone, password_hash, bio, location, avatar_url, followers_count, events_count, upcoming_events_count, genre, description, role, is_verified) VALUES
(1, 'sabrina', 'Sabrina Carpenter', 'sabrina@eventra.local', '+12135550143', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Short n Sweet', 'Los Angeles, USA', 'assets/artists/SabrinaCarpenter.jpg', 45000000, 150, 12, 'Pop', 'Espresso-fueled pop anthems and witty lyricism taking over the global charts.', 'promoter', 1),
(2, 'coldplay', 'COLDPLAY', 'coldplay@eventra.local', '+442079460192', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Music of the Spheres', 'London, United Kingdom', 'assets/artists/Coldplay.jpg', 65000000, 800, 25, 'Alternative Rock', 'British rock legends known for their historic, colorful, and record-breaking stadium tours.', 'promoter', 1),
(3, 'brunomars', 'BRUNO MARS', 'bruno@eventra.local', '+13105550198', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', '24K Magic in the Air', 'Los Angeles, USA', 'assets/artists/BrunoMars.jpg', 35000000, 450, 14, 'Pop / Funk', 'The ultimate showman blending retro funk, soul, and modern pop.', 'promoter', 1),
(4, 'edsheeran', 'ED SHEERAN', 'ed@eventra.local', '+441632960031', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Mathematics Tour', 'Framlingham, United Kingdom', 'assets/artists/EdSheeran.jpg', 42000000, 600, 18, 'Pop / Acoustic', 'Armed with just a guitar and a loop pedal, Ed commands massive stages.', 'promoter', 1),
(5, 'seventeen', 'SEVENTEEN', 'svt@eventra.local', '+8225550123', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Say the name, SEVENTEEN!', 'Seoul, South Korea', 'assets/artists/Seventeen.jpg', 14000000, 300, 8, 'K-Pop', 'Self-producing K-Pop powerhouse known for synchronized choreography.', 'promoter', 1),
(6, 'bmth', 'Bring Me The Horizon', 'bmth@eventra.local', '+441144960145', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Post Human Nex Gen', 'Sheffield, United Kingdom', 'assets/artists/bmth.jpg', 8500000, 400, 11, 'Alternative Metal', 'Pushing boundaries of heavy music, infusing electronic beats.', 'promoter', 1),
(7, 'fiersabesari', 'Fiersa Besari', 'fiersa@eventra.local', '+628112233445', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Garis Waktu', 'Bandung, Indonesia', 'assets/artists/FiersaBesari.jpg', 12000000, 500, 5, 'Indie Folk', 'Indonesian indie-folk singer-songwriter known for poetic lyrics.', 'promoter', 1),
(8, 'sheilaon7', 'Sheila On 7', 'so7@eventra.local', '+628123456789', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Kisah Klasik Untuk Masa Depan', 'Yogyakarta, Indonesia', 'assets/artists/SheilaOn7.jpg', 6000000, 900, 4, 'Pop Rock', 'The ultimate timeless band of Indonesia. Concert is a massive karaoke session.', 'promoter', 1),
(9, 'ndarboy', 'Ndarboy Genk', 'ndarboy@eventra.local', '+628139876543', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Mendung Tanpo Udan', 'Yogyakarta, Indonesia', 'assets/artists/Ndarboy.jpg', 2500000, 350, 9, 'Dangdut Koplo', 'Bringing traditional Javanese sounds into modern pop.', 'promoter', 1),
(10, 'tulus', 'TULUS', 'tulus@eventra.local', '+628115556677', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Manusia', 'Bandung, Indonesia', 'assets/artists/Tulus.jpg', 9500000, 600, 6, 'Pop / Soul', 'Award-winning Indonesian singer-songwriter with deep, emotional soul.', 'promoter', 1),
(11, 'keshi', 'KESHI', 'keshi@eventra.local', '+17135550122', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Requiem Tour', 'Houston, USA', 'assets/artists/Keshi.jpg', 4800000, 200, 15, 'Lo-Fi / R&B', 'The king of falsettos and lo-fi aesthetics with moody R&B tracks.', 'promoter', 1),
(12, 'cigarettesafter', 'Cigarettes After Sex', 'cas@eventra.local', '+19155550176', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'X''s', 'El Paso, USA', 'assets/artists/CigarettesAfterSex.jpg', 6500000, 250, 10, 'Dream Pop', 'Slow, cinematic, monochrome aesthetics and deeply melancholic.', 'promoter', 1),
(13, 'laufey', 'LAUFEY', 'laufey@eventra.local', '+3545551234', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Bewitched', 'Reykjavik, Iceland', 'assets/artists/Laufey.jpg', 5000000, 180, 13, 'Jazz', 'Bringing jazz back to Gen Z with cinematic cello lines.', 'promoter', 1),
(14, 'taylorswift', 'Taylor Swift', 'taylor@eventra.local', '+16155550111', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'The Eras Tour', 'Nashville, USA', 'assets/artists/TaylorSwift.jpg', 110000000, 1200, 40, 'Pop / Country', 'Global pop icon breaking economic records with Eras stadium tour.', 'promoter', 1),
(15, 'hindia', 'Hindia', 'hindia@eventra.local', '+628129988776', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Lagipula Hidup Akan Berakhir', 'Jakarta, Indonesia', 'assets/artists/Hindia.jpg', 5500000, 450, 14, 'Indie Rock', 'Baskara Putra delivers alternative indie rock defining youth anxiety.', 'promoter', 1),
(16, 'newjeans', 'NewJeans', 'newjeans@eventra.local', '+8225550987', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Bunnies, ATTENTION!', 'Seoul, South Korea', 'assets/artists/NewJeans.jpg', 12000000, 150, 10, 'K-Pop', 'Pioneering easy-listening Y2K R&B revival in K-Pop.', 'promoter', 1),
(17, 'billieeilish', 'Billie Eilish', 'billie@eventra.local', '+13105550155', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'HIT ME HARD AND SOFT', 'Los Angeles, USA', 'assets/artists/BillieEilish.jpg', 58000000, 280, 19, 'Alternative Pop', 'Dark, bass-heavy avant-pop paired with whispery vocals.', 'promoter', 1),
(18, 'niki', 'NIKI', 'niki@eventra.local', '+628135554433', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Buzz Tour', 'Jakarta, Indonesia', 'assets/artists/Niki.jpg', 7000000, 220, 12, 'R&B / Pop', 'Indonesia''s finest 88rising star bringing smooth R&B storytelling.', 'promoter', 1),
(19, 'alanwalker', 'Alan Walker', 'alan@eventra.local', '+4721000123', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Walkerworld', 'Bergen, Norway', 'assets/artists/AlanWalker.jpg', 28000000, 700, 22, 'EDM', 'Masked hitmaker behind Faded delivering high-energy tracks.', 'promoter', 1),
(20, 'dewa19', 'Dewa 19', 'dewa19@eventra.local', '+628119909876', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', '30 Tahun Dewa 19', 'Surabaya, Indonesia', 'assets/artists/Dewa19.jpg', 4500000, 1100, 5, 'Classic Rock', 'Indonesian rock royalty. Anthems engraved in cultural DNA.', 'promoter', 1)
ON DUPLICATE KEY UPDATE username=VALUES(username), name=VALUES(name), email=VALUES(email), password_hash=VALUES(password_hash), bio=VALUES(bio), location=VALUES(location), avatar_url=VALUES(avatar_url), followers_count=VALUES(followers_count), events_count=VALUES(events_count), upcoming_events_count=VALUES(upcoming_events_count), genre=VALUES(genre), description=VALUES(description), role=VALUES(role), is_verified=VALUES(is_verified);

SET @rank := 0;
UPDATE users SET sort_order = (@rank := @rank + 1) ORDER BY followers_count DESC;

-- Seed Data Semua Customer
INSERT INTO users (username, name, email, phone, password_hash, bio, location, avatar_url, role) VALUES 
('jessica01', 'Jessica Tan', 'jessica.tan@email.com', '081234567801', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Usually spends weekends looking for live music, food festivals, and local events around the city.', 'Jakarta', 'https://i.pravatar.cc/300?img=1', 'user'), 
('kevinlim', 'Kevin Lim', 'kevin.lim@email.com', '081234567802', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Big fan of concerts and stand-up comedy shows. Always searching for something fun to do with friends.', 'Bandung', 'https://i.pravatar.cc/300?img=2', 'user'),
('sarahwijaya', 'Sarah Wijaya', 'sarah.wijaya@email.com', '081234567803', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Loves pop music, traveling, and discovering new events whenever visiting a new city.', 'Surabaya', 'https://i.pravatar.cc/300?img=3', 'user'), 
('davidong', 'David Ong', 'david.ong@email.com', '081234567804', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Enjoys cultural festivals, community gatherings, and outdoor events with family.', 'Tangerang', 'https://i.pravatar.cc/300?img=4', 'user'), 
('oliviaputra', 'Olivia Putra', 'olivia.putra@email.com', '081234567805', '$2b$10$k6OmwwSy4VzNOkOA05RpOuxaOq22iJ2dRZkHqBEt4Ghd3KHlAieS2', 'Concert enthusiast who never misses a chance to attend music festivals and special performances.', 'Bekasi', 'https://i.pravatar.cc/300?img=5', 'user');


-- Seed Data Semua Events (Featured dan Nearby Dilebur Disini)
INSERT INTO events (id, user_id, title, lineup, venue, city, date_label, show_time, price, image, description, tag1, tag2, button, is_featured, is_limited, remaining_seats, is_favorite) VALUES
(1, 13, 'myBCA Java Jazz Festival 2026', 'Laufey, Java Jazz Lineup', 'NICE PIK 2, Tangerang', 'Tangerang', '2026-05-29', '20:00 WIB', 'Rp850.000', 'assets/events/laufey_jiexpo.webp', 'Festival dates are set for 29-31 May 2026 at NICE, PIK 2.', 'JAZZ FESTIVAL', 'OFFICIAL 2026', 'GET TICKETS', 1, 1, 48, 1),

(2, 15, 'Pestapora 2026', 'Hindia, Sheila On 7, Tulus, Fiersa Besari', 'Gambir Expo JIExpo', 'Jakarta', '2026-09-25', '15:00 WIB', 'Rp450.000', 'assets/events/wtf2026.jpg', 'Save 25-27 September 2026 for the three-day Indonesian music celebration.', 'LOCAL FEST', 'THREE DAYS', 'BOOK NOW', 1, 0, 150, 1),

(6, 19, 'Djakarta Warehouse Project 2026', 'Alan Walker, Martin Garrix, Hardwell', 'GWK Cultural Park', 'Bali', '2026-12-31', '18:00 WIB', 'Rp1.200.000', 'assets/events/featured_events/featured_dwp.jpg', 'Djakarta Warehouse Project 2026 is now listed in Eventra discovery.', 'EDM FESTIVAL', 'YEAR END', 'EXPLORE', 1, 1, 80, 0),

(7, 2, 'Coldplay: Music Of The Spheres Jakarta', 'Coldplay', 'Gelora Bung Karno Stadium', 'Jakarta', '2023-11-15', '20:00 WIB', 'Rp800.000', 'assets/events/featured_events/featured_coldplay.jpg', 'Coldplay first Indonesia stadium show archive listing.', 'ARCHIVE', 'WORLD TOUR', 'VIEW DETAIL', 0, 0, 0, 0),

(8, 8, 'Sheila On 7: Tunggu Aku Di Jakarta', 'Sheila On 7', 'Stadion Utama Gelora Bung Karno', 'Jakarta', '2026-12-25', '19:00 WIB', 'Rp600.000', 'assets/events/so7_gbk.webp', 'Every concert is a massive karaoke session across generations.', 'LOCAL ROCK', 'SOLO CONCERT', 'BUY TICKETS', 0, 0, 200, 1),

(9, 18, 'NIKI: Buzz World Tour Jakarta', 'NIKI', 'Beach City International Stadium', 'Jakarta', '2026-08-05', '20:00 WIB', 'IDR 950k', 'assets/events/niki_buzz.jpeg', 'Preorder tickets for NIKI: Buzz World Tour Jakarta are now available for VIP users.', 'R&B', 'WORLD TOUR', 'BUY NOW', 0, 0, 45, 0),

(10, 5, 'SEVENTEEN: Right Here World Tour Jakarta', 'SEVENTEEN', 'Jakarta International Stadium', 'Jakarta', '2026-09-15', '18:30 WIB', 'IDR 1.800k', 'assets/events/seventeen_concert.jpeg', 'General Sales for SEVENTEEN: Right Here World Tour Jakarta starts in 30 minutes. Get ready!', 'K-POP', 'STADIUM', 'BUY TICKETS', 0, 0, 500, 0),

(11, 19, 'Alan Walker: Walkerworld Tour Bali', 'Alan Walker', 'Atlas Beach Club, Badung', 'Bali', '2026-10-10', '16:00 WITA', 'IDR 750k', 'assets/events/alan_walker2.jpg', 'Alan Walker: Walkerworld Tour Bali has updated its gate-open time to 04:00 PM.', 'EDM', 'CLUB SHOW', 'BOOK NOW', 0, 0, 110, 0),

(12, 6, 'Bring Me The Horizon: Live in Jakarta', 'Bring Me The Horizon', 'Ancol Carnaval Circuit', 'Jakarta', '2026-11-20', '20:00 WIB', 'IDR 1.250k', 'assets/events/bmth_ancol.jpg', 'Pushing the boundaries of heavy alternative rock music.', 'ROCK', 'LIVE', 'GET TICKETS', 0, 0, 75, 0),

(13, 12, 'Cigarettes After Sex: X''s Tour', 'Cigarettes After Sex', 'Beach City International Stadium', 'Jakarta', '2026-12-04', '21:00 WIB', 'IDR 1.100k', 'assets/events/cas_jakarta.jpg', 'Slow, cinematic, and deeply melancholic ambient dream pop.', 'DREAM POP', 'AMBIENT', 'BUY TICKETS', 0, 0, 130, 0),

(14, 11, 'Keshi: Requiem Tour', 'Keshi', 'Istora Senayan', 'Jakarta', '2027-01-18', '20:00 WIB', 'IDR 1.350k', 'assets/events/keshi_istora.jpg', 'Moody, guitar-driven R&B tracks from the king of falsettos.', 'R&B', 'LO-FI', 'GET TICKETS', 0, 0, 85, 0),

(15, 8, 'We The Fest 2026', 'Sheila On 7, Dewa 19, TULUS, NIKI, Hindia', 'GBK Sports Complex', 'Jakarta', '2026-07-19', '14:00 WIB', 'Rp1.500.000', 'assets/events/wtf2026.jpg', 'Festival musik musim panas terbesar di Indonesia kembali hadir dengan lineup lokal legendaris!', 'FESTIVAL', 'SUMMER', 'GET TICKETS', 0, 1, 30, 0),

(20, 1, 'Sabrina Carpenter: Short n Sweet Tour', 'Sabrina Carpenter', 'ICE BSD', 'Tangerang', '2026-06-18', '19:30 WIB', 'Rp1.250.000', 'assets/events/sabrina_ice.avif', 'Espresso-fueled pop anthems live in Jakarta.', 'POP', 'WORLD TOUR', 'GET TICKETS', 1, 1, 25, 0),

(21, 3, 'Bruno Mars: Live in Jakarta 2026', 'Bruno Mars', 'Jakarta International Stadium', 'Jakarta', '2026-07-24', '20:00 WIB', 'Rp1.500.000', 'assets/events/bruno_jis.webp', 'The ultimate showman bringing 24K Magic back to the stage.', 'FUNK / POP', 'STADIUM SHOW', 'BUY TICKETS', 1, 0, 350, 1),

(22, 4, 'Ed Sheeran: Mathematics Tour Plus', 'Ed Sheeran', 'Stadion Utama Gelora Bung Karno', 'Jakarta', '2026-08-12', '19:00 WIB', 'Rp900.000', 'assets/events/ed_gbk.webp', 'Armed with just a guitar and a loop pedal, Ed commands the 360 stage.', 'ACOUSTIC', '360 STAGE', 'BOOK NOW', 0, 1, 15, 0),

(23, 14, 'Taylor Swift: The Eras Tour (Extended)', 'Taylor Swift', 'Jakarta International Stadium', 'Jakarta', '2026-10-15', '18:00 WIB', 'Rp2.100.000', 'assets/events/taylor_eras.webp', 'Additional CAT 1 tickets for Taylor Swift: The Eras Tour have been released. Grab them fast!', 'POP', 'STADIUM TOUR', 'BUY TICKETS', 1, 1, 5, 1),

(24, 17, 'Billie Eilish: HIT ME HARD AND SOFT Tour', 'Billie Eilish', 'ICE BSD', 'Tangerang', '2026-11-05', '20:00 WIB', 'Rp1.650.000', 'assets/events/billie_ice.jpg', 'Dark, bass-heavy avant-pop paired with whispery emotional vocals.', 'ALTERNATIVE', 'LIVE IN INDO', 'GET TICKETS', 0, 0, 180, 0),

(25, 20, 'Dewa 19: 30 Tahun Karaoke Massal', 'Dewa 19', 'Stadion Utama Gelora Bung Karno', 'Jakarta', '2026-11-28', '19:30 WIB', 'Rp350.000', 'assets/events/dewa_gbk.webp', 'Indonesian rock royalty celebrating their best anthems.', 'CLASSIC ROCK', 'ANNIVERSARY', 'BUY TICKETS', 0, 0, 400, 1),

(26, 3, 'Bruno Mars: Live in Bali 2026', 'Bruno Mars', 'GWK Cultural Park, Bali', 'Bali', '2026-12-31', '18:00 WIB', 'Rp2.500.000', 'assets/events/featured_events/featured_bruno.png',  'The ultimate showman bringing 24K Magic back to the stage.', 'FUNK / POP', 'STADIUM SHOW', 'BUY TICKETS', 1, 1, 45, 0),

(27, 10, 'TULUS: Tur Manusia Jakarta', 'TULUS', 'Santhika Hall Kelapa Gading', 'Jakarta', '2026-08-20', '20:00 WIB', 'Rp550.000', 'assets/events/tulus.jpg', 'Award-winning singer-songwriter with deep, emotional soul tracks.', 'SOUL / POP', 'SOLO TOUR', 'BOOK NOW', 0, 0, 55, 0),

(28, 16, 'NewJeans: Bunnies Party in Jakarta', 'NewJeans', 'Beach City International Stadium', 'Jakarta', '2026-07-04', '17:00 WIB', 'Rp1.300.000', 'assets/events/newjeans.webp', 'Pioneering easy-listening Y2K R&B revival fan-meeting event.', 'K-POP', 'FAN MEETING', 'GET TICKETS', 0, 1, 30, 0),

(29, 13, 'Laufey: Bewitched Tour', 'Laufey', 'JIExpo Theatre', 'Jakarta', '2026-06-02', '20:30 WIB', 'Rp1.100.000', 'assets/events/laufey_solo.jpg', 'Laufey: Bewitched Tour at JIExpo Theatre starts in 5 hours. Prepare your QR Code.', 'JAZZ', 'SOLO SHOW', 'GET TICKETS', 0, 0, 12, 1),

(30, 15, 'Hindia: Lagipula Hidup Akan Berakhir', 'Hindia', 'Tennis Indoor Senayan', 'Jakarta', '2027-02-14', '19:30 WIB', 'IDR 450k', 'assets/events/hindia_tennis_indoor.jpeg', 'Official Hindia: Lagipula Hidup Akan Berakhir merchandise is now available for pre-order.', 'INDIE', 'LOCAL', 'BUY TICKETS', 0, 0, 140, 1),

(31, 19, 'Djakarta Warehouse Project 2026 Deluxe', 'Alan Walker, Martin Garrix, Hardwell', 'GWK Cultural Park, Bali', 'Bali', '2026-12-31', '18:00 WIB', 'Rp1.200.000', 'assets/events/featured_events/featured_dwp.jpg', 'Experience South East Asia''s biggest electronic dance music festival.', 'EDM FESTIVAL', 'DAY ONE', 'EXPLORE', 0, 0, 300, 0)
ON DUPLICATE KEY UPDATE title=VALUES(title), lineup=VALUES(lineup), venue=VALUES(venue), city=VALUES(city), date_label=VALUES(date_label), show_time=VALUES(show_time), price=VALUES(price), image=VALUES(image), description=VALUES(description), tag1=VALUES(tag1), tag2=VALUES(tag2), button=VALUES(button), is_featured=VALUES(is_featured), is_limited=VALUES(is_limited), remaining_seats=VALUES(remaining_seats), is_favorite=VALUES(is_favorite);

DELETE FROM events WHERE id IN (3, 4, 5, 16, 17, 18, 19);
-- Mengurutkan berdasarkan tanggal kalender secara otomatis
SET @rank := 0;
UPDATE events SET sort_order = (@rank := @rank + 1) ORDER BY STR_TO_DATE(date_label, '%Y-%m-%d') ASC;

-- Seed Ticket Types terhubung ke Master ID Event
INSERT INTO event_ticket_types (id, event_id, name, badge, badge_color, description, bullet1, bullet2, bullet3, price, stock_remaining, max_per_order, sort_order) VALUES
(1, 1, 'Daily Pass', 'BEST VALUE', '#20B486', 'Single-day festival access.', 'Valid for one selected festival day', 'General admission area', 'Digital ticket with QR verification', 850000, 120, 6, 1),
(2, 1, '3-Day Pass', 'POPULAR', '#F59E0B', 'Full festival weekend access.', 'Access for 29-31 May 2026', 'Multiple stages and festival area', 'Best for out-of-town visitors', 1850000, 80, 4, 2),
(3, 2, 'Daily Pass', 'LIMITED', '#EF4444', 'Single-day Pestapora access.', 'Valid for one selected day', 'Festival ground access', 'Official digital ticket', 450000, 160, 6, 1),
(4, 2, '3-Day Pass', 'FAN PICK', '#8B5CF6', 'Three-day Pestapora access.', 'Access for 25-27 Sep 2026', 'All regular stages', 'Digital ticket with QR verification', 950000, 90, 4, 2),
(5, 6, 'GA Pass', 'EARLY BIRD', '#06B6D4', 'General admission access for DWP.', 'Festival ground access', 'Digital ticket delivery', 'Official ID verification required', 1200000, 100, 4, 1),
(6, 6, 'VIP Deck', 'VIP', '#EAB308', 'Premium viewing and lounge access.', 'Elevated viewing deck', 'Dedicated entry lane', 'Selected hospitality access', 2500000, 40, 2, 2),
(7, 21, 'CAT 1', 'HOT', '#EF4444', 'Reserved seating for Bruno Mars Jakarta.', 'Assigned seat category', 'Digital QR entry', 'Official ID verification required', 1500000, 70, 4, 1),
(8, 21, 'VIP Experience', 'VIP', '#EC4899', 'VIP package with premium viewing access.', 'Premium viewing section', 'VIP laminate and merch', 'Priority entry lane', 3500000, 20, 2, 2),
(9, 7, 'Festival Seating', 'ARCHIVE', '#64748B', 'Archive ticket category from public sale reference.', 'Historical listing', 'GBK stadium event', 'Digital ticket sample', 800000, 50, 4, 1),
(10, 15, 'Regular Pass', 'DISCOVERY', '#22C55E', 'We The Fest regular access.', 'Festival ground access', 'Digital ticket with QR', 'Reminder enabled', 500000, 130, 6, 1)
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price);

-- Seed Data Tickets Dompet User
INSERT INTO tickets (id, user_id, title, image, date_label, time_label, venue, section, row_label, seat_label, qr_data, ticket_type, ticket_status, sort_order) VALUES
(1, (SELECT id FROM users WHERE username = 'jessica01' LIMIT 1), 'Laufey: Bewitched Tour', 'assets/events/laufey_jiexpo.webp', 'Jun 12,\n2026', '07:30 PM', 'JIExpo Theatre, Jakarta', 'VIP', 'CENTER', 'A-08', 'Eventra-Laufey-VIP-Center-A08', 'DAILY PASS', 'UPCOMING', 1),
(2, (SELECT id FROM users WHERE username = 'jessica01' LIMIT 1), 'DJAKARTA WAREHOUSE PROJECT', 'assets/events/featured_events/featured_dwp.jpg', 'Dec 11,\n2026', '05:00 PM', 'JIExpo Kemayoran, Jakarta', 'GA', 'FESTIVAL', 'Free', 'Eventra-DWP2026-GA-Festival-Free', 'VIP DECK', 'UPCOMING', 2),
(3, (SELECT id FROM users WHERE username = 'jessica01' LIMIT 1), 'Sheila On 7: Tunggu Aku Di Jakarta', 'assets/events/so7_gbk.webp', 'Dec 25,\n2026', '08:00 PM', 'Gelora Bung Karno Main Stadium', 'CAT 2', 'WEST', 'B-14', 'Eventra-SO7-GBK-CAT2-West-B14', '3-DAY PASS', 'UPCOMING', 3)
ON DUPLICATE KEY UPDATE user_id=VALUES(user_id), title=VALUES(title), venue=VALUES(venue);

-- Seed User Favorites
INSERT INTO user_favorites (user_id, favorite_type, item_id)
SELECT id, 'event', 1 FROM users WHERE username = 'jessica01'
UNION ALL
SELECT id, 'event', 2 FROM users WHERE username = 'jessica01'
UNION ALL
SELECT id, 'pass', 1 FROM users WHERE username = 'jessica01'
ON DUPLICATE KEY UPDATE created_at = CURRENT_TIMESTAMP;

-- Seed Data Notifications
INSERT INTO notifications (id, title, subtitle, sort_order) VALUES
(1, 'We The Fest 2026 Ticket Status', 'Your ticket for WTF 2026 is ready. Check your ticket wallet now!', 1),
(2, 'Concert Reminder!', 'Laufey: Bewitched Tour at JIExpo Theatre starts in 5 hours. Prepare your QR Code.', 2),
(3, 'Pre-order Tickets Open', 'Preorder tickets for NIKI: Buzz World Tour Jakarta are now available for VIP users.', 3),
(4, 'Ticket War Reminder!', 'General Sales for SEVENTEEN: Right Here World Tour Jakarta starts in 30 minutes. Get ready!', 4),
(5, 'Schedule Update', 'Alan Walker: Walkerworld Tour Bali has updated its gate-open time to 04:00 PM.', 5),
(6, 'Exclusive Merch Drop', 'Official Hindia: Lagipula Hidup Akan Beakhir merchandise is now available for pre-order.', 6),
(7, 'Cashback Promo!', 'Get 15% cashback for every ticket purchase using Eventra Pay this week. Don''t miss out!', 7),
(8, 'Waitlist Alert ', 'Additional CAT 1 tickets for Taylor Swift: The Eras Tour have been released. Grab them fast!', 8),
(9, 'Java Jazz 2026 is live', 'Festival dates are set for 29-31 May 2026 at NICE, PIK 2.', 1),
(10, 'Pestapora 2026 reminder', 'Save 25-27 September 2026 for the three-day Indonesian music celebration.', 2),
(11, 'DWP 2026 added', 'Djakarta Warehouse Project 2026 is now listed in Eventra discovery.', 3)
ON DUPLICATE KEY UPDATE title=VALUES(title), subtitle=VALUES(subtitle);

-- Seed Data Exclusive Drops
INSERT INTO exclusive_drops (id, title, badge, description, image, venue, city, event_date, type, countdown_seconds, remaining_seats, is_active, sort_order) VALUES
(1, 'LIMITED TICKET', 'ASIA TOUR JAKARTA', 'Additional Section B tickets released', 'assets/events/laufey_jiexpo.webp', 'NICE PIK 2', 'Tangerang', '2026-06-03', 'ticket', 9912, 48, 1, 1),
(2, 'EVENT PLACEMENT', 'SPONSORED EVENT PLACEMENT', 'Experience immersive visuals and live performances from local Indonesian artists', 'assets/events/wtf2026.jpg', 'Gambir Expo & Hall D2 JIExpo', 'Jakarta', '2026-06-03', 'ticket', 45000, 20, 1, 2),
(3, 'MERCH PRESALE', 'THE WEEKND - AFTER HOURS TIL DAWN', 'Exclusive preorders of the new WEEKND drop', 'assets/events/so7_gbk.webp', 'Gelora Bung Karno Main Stadium', 'Jakarta', '2026-06-03', 'merch', 75000, 10, 1, 3)
ON DUPLICATE KEY UPDATE title = VALUES(title), badge = VALUES(badge), description = VALUES(description), image = VALUES(image), event_date = VALUES(event_date), type = VALUES(type), countdown_seconds = VALUES(countdown_seconds), remaining_seats = VALUES(remaining_seats);

-- Seed Data App Config
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
