USE eventra;

UPDATE profile
SET location = 'Jakarta, Indonesia',
    membership_title = 'DIAMOND MEMBER | JAKARTA',
    upcoming_events_count = 6
WHERE id = 1;

SET @add_artist_event_image := (
  SELECT IF(
    COUNT(*) = 0,
    'ALTER TABLE artist_events ADD COLUMN image TEXT NULL',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'artist_events'
    AND COLUMN_NAME = 'image'
);
PREPARE artist_event_image_stmt FROM @add_artist_event_image;
EXECUTE artist_event_image_stmt;
DEALLOCATE PREPARE artist_event_image_stmt;

DELETE FROM artist_events;
DELETE FROM artists;

INSERT INTO artists (id, name, followers, monthly_listeners, events_count, genre, description, image_url, sort_order) VALUES
(1, 'Taylor Swift', '110M', '95M', '40 Events', 'Pop / Country', 'Global pop icon breaking records with massive stadium tours.', 'assets/artists/TaylorSwift.jpg', 1),
(2, 'Coldplay', '65M', '70M', '25 Events', 'Alternative Rock', 'British rock legends known for colorful, record-breaking stadium tours.', 'assets/artists/Coldplay.jpg', 2),
(3, 'Billie Eilish', '58M', '68M', '19 Events', 'Alternative Pop', 'Dark, bass-heavy avant-pop paired with whispery vocals.', 'assets/artists/BillieEilish.jpg', 3),
(4, 'Sabrina Carpenter', '45M', '72M', '12 Events', 'Pop', 'Espresso-fueled pop anthems and witty lyricism taking over global charts.', 'assets/artists/SabrinaCarpenter.jpg', 4),
(5, 'Ed Sheeran', '42M', '78M', '18 Events', 'Pop / Acoustic', 'Armed with a guitar and loop pedal, Ed commands massive stages.', 'assets/artists/EdSheeran.jpg', 5),
(6, 'BRUNO MARS', '35M', '74M', '14 Events', 'Pop / Funk', 'The ultimate showman blending retro funk, soul, and modern pop.', 'assets/artists/BrunoMars.jpg', 6),
(7, 'Alan Walker', '28M', '42M', '22 Events', 'EDM', 'Masked hitmaker behind Faded delivering high-energy festival sets.', 'assets/artists/AlanWalker.jpg', 7),
(8, 'SEVENTEEN', '14M', '18M', '8 Events', 'K-Pop', 'Self-producing K-Pop powerhouse known for synchronized choreography.', 'assets/artists/Seventeen.jpg', 8),
(9, 'NIKI', '7M', '12M', '12 Events', 'R&B / Pop', 'Indonesias 88rising star bringing smooth R&B storytelling.', 'assets/artists/Niki.jpg', 9),
(10, 'Cigarettes After Sex', '6.5M', '16M', '10 Events', 'Dream Pop', 'Slow, cinematic, monochrome dream pop with melancholic atmosphere.', 'assets/artists/CigarettesAfterSex.jpg', 10),
(11, 'Sheila On 7', '6M', '9M', '4 Events', 'Pop Rock', 'A timeless Indonesian band whose concerts become massive karaoke sessions.', 'assets/artists/SheilaOn7.jpg', 11),
(12, 'Hindia', '5.5M', '8M', '14 Events', 'Indie Rock', 'Baskara Putra delivers alternative indie rock defining youth anxiety.', 'assets/artists/Hindia.jpg', 12),
(13, 'LAUFEY', '5M', '15M', '13 Events', 'Jazz', 'Bringing jazz back to Gen Z with cinematic arrangements.', 'assets/artists/Laufey.jpg', 13),
(14, 'KESHI', '4.8M', '11M', '15 Events', 'Lo-Fi / R&B', 'The king of falsettos and lo-fi aesthetics with moody R&B tracks.', 'assets/artists/Keshi.jpg', 14),
(15, 'TULUS', '9.5M', '10M', '6 Events', 'Pop / Soul', 'Award-winning Indonesian singer-songwriter with deep emotional soul.', 'assets/artists/Tulus.jpg', 15);

INSERT INTO artist_events (id, artist_id, title, lineup, venue, location, date_label, sort_order, image) VALUES
(1, 1, 'Taylor Swift: The Eras Tour Extended', 'Taylor Swift', 'Jakarta International Stadium', 'Jakarta, Indonesia', '2026-10-15', 1, 'assets/events/taylor_eras.webp'),
(2, 2, 'Coldplay: Music Of The Spheres Jakarta', 'Coldplay', 'Gelora Bung Karno Stadium', 'Jakarta, Indonesia', '2026-11-15', 2, 'assets/events/featured_events/featured_coldplay.jpg'),
(3, 3, 'Billie Eilish: HIT ME HARD AND SOFT Tour', 'Billie Eilish', 'ICE BSD', 'Tangerang, Indonesia', '2026-11-05', 3, 'assets/events/billie_ice.jpg'),
(4, 4, 'Sabrina Carpenter: Short n Sweet Tour', 'Sabrina Carpenter', 'ICE BSD', 'Tangerang, Indonesia', '2026-06-18', 4, 'assets/events/featured_events/featured_sabrina.jpg'),
(5, 5, 'Ed Sheeran: Mathematics Tour Plus', 'Ed Sheeran', 'Stadion Utama Gelora Bung Karno', 'Jakarta, Indonesia', '2026-08-12', 5, 'assets/events/ed_gbk.webp'),
(6, 6, 'Bruno Mars: Live in Jakarta 2026', 'Bruno Mars', 'Jakarta International Stadium', 'Jakarta, Indonesia', '2026-07-24', 6, 'assets/events/bruno_jis.webp'),
(7, 7, 'Djakarta Warehouse Project 2026', 'Alan Walker, Martin Garrix, Hardwell', 'GWK Cultural Park', 'Bali, Indonesia', '2026-12-31', 7, 'assets/events/featured_events/featured_dwp.jpg'),
(8, 8, 'SEVENTEEN: Right Here World Tour Jakarta', 'SEVENTEEN', 'Jakarta International Stadium', 'Jakarta, Indonesia', '2026-09-15', 8, 'assets/events/seventeen_concert.jpeg'),
(9, 9, 'NIKI: Buzz World Tour Jakarta', 'NIKI', 'Beach City International Stadium', 'Jakarta, Indonesia', '2026-08-05', 9, 'assets/events/niki_buzz.jpeg'),
(10, 10, 'Cigarettes After Sex: Xs Tour', 'Cigarettes After Sex', 'Beach City International Stadium', 'Jakarta, Indonesia', '2026-12-04', 10, 'assets/events/cas_jakarta.jpg'),
(11, 11, 'Sheila On 7: Tunggu Aku Di Jakarta', 'Sheila On 7', 'Stadion Utama Gelora Bung Karno', 'Jakarta, Indonesia', '2026-12-25', 11, 'assets/events/so7_gbk.webp'),
(12, 12, 'Hindia: Lagipula Hidup Akan Berakhir', 'Hindia', 'Tennis Indoor Senayan', 'Jakarta, Indonesia', '2027-02-14', 12, 'assets/events/hindia_tennis_indoor.jpeg'),
(13, 13, 'Laufey: Bewitched Tour', 'Laufey', 'JIExpo Theatre', 'Jakarta, Indonesia', '2026-06-02', 13, 'assets/events/laufey_solo.jpg'),
(14, 14, 'Keshi: Requiem Tour', 'Keshi', 'Istora Senayan', 'Jakarta, Indonesia', '2027-01-18', 14, 'assets/events/keshi_istora.jpg'),
(15, 15, 'TULUS: Tur Manusia Jakarta', 'TULUS', 'Santhika Hall Kelapa Gading', 'Jakarta, Indonesia', '2026-08-20', 15, 'assets/events/tulus.jpg');

DELETE FROM featured_events;
INSERT INTO featured_events (id, title, subtitle, image, venue, city, event_date, tag1, tag2, button, price_start, is_limited, remaining_seats, sort_order, is_favorite) VALUES
(1, 'Sabrina Carpenter: Short n Sweet Tour', 'Pop spectacle at ICE BSD with limited access packages.', 'assets/events/featured_events/featured_sabrina.jpg', 'ICE BSD', 'Tangerang', '2026-06-18', 'POP', 'WORLD TOUR', 'GET TICKETS', 'Rp1.250.000', 1, 25, 1, 0),
(2, 'Bruno Mars: Live in Jakarta 2026', '24K Magic returns with a stadium-scale funk and pop show.', 'assets/events/bruno_jis.webp', 'Jakarta International Stadium', 'Jakarta', '2026-07-24', 'FUNK / POP', 'STADIUM SHOW', 'BUY TICKETS', 'Rp1.500.000', 0, 350, 2, 1),
(3, 'Taylor Swift: The Eras Tour Extended', 'Additional CAT 1 tickets released for the Jakarta stadium date.', 'assets/events/taylor_eras.webp', 'Jakarta International Stadium', 'Jakarta', '2026-10-15', 'POP', 'STADIUM TOUR', 'BUY TICKETS', 'Rp2.100.000', 1, 5, 3, 1),
(4, 'Djakarta Warehouse Project 2026', 'Experience Southeast Asias biggest electronic dance music festival.', 'assets/events/featured_events/featured_dwp.jpg', 'GWK Cultural Park', 'Bali', '2026-12-31', 'EDM FESTIVAL', 'YEAR END', 'EXPLORE', 'Rp1.200.000', 1, 80, 4, 0);

DELETE FROM nearby_events;
INSERT INTO nearby_events (id, title, date_label, place, city, price, image, is_limited, remaining_seats, sort_order, is_favorite, detail_image, artist_name, show_time, description, venue_layout) VALUES
(1, 'NIKI: Buzz World Tour Jakarta', '2026-08-05', 'Beach City International Stadium', 'Jakarta', 'Rp950.000', 'assets/events/niki_buzz.jpeg', 0, 45, 1, 0, 'assets/events/niki_buzz.jpeg', 'NIKI', '20:00 WIB', 'NIKI brings the Buzz World Tour experience to Jakarta with official digital ticket entry.', 'assets/stadiums/jis_layout.jpg'),
(2, 'SEVENTEEN: Right Here World Tour Jakarta', '2026-09-15', 'Jakarta International Stadium', 'Jakarta', 'Rp1.800.000', 'assets/events/seventeen_concert.jpeg', 0, 500, 2, 0, 'assets/events/seventeen_concert.jpeg', 'SEVENTEEN', '18:30 WIB', 'A stadium-scale K-Pop concert with synchronized choreography and premium seating.', 'assets/stadiums/jis_layout.jpg'),
(3, 'Bring Me The Horizon: Live in Jakarta', '2026-11-20', 'Ancol Carnaval Circuit', 'Jakarta', 'Rp1.250.000', 'assets/events/bmth_ancol.jpg', 0, 75, 3, 0, 'assets/events/bmth_ancol.jpg', 'Bring Me The Horizon', '20:00 WIB', 'Heavy alternative rock and electronic energy live in Jakarta.', 'assets/stadiums/grand_layout.jpg'),
(4, 'Cigarettes After Sex: Xs Tour', '2026-12-04', 'Beach City International Stadium', 'Jakarta', 'Rp1.100.000', 'assets/events/cas_jakarta.jpg', 0, 130, 4, 0, 'assets/events/cas_jakarta.jpg', 'Cigarettes After Sex', '21:00 WIB', 'Slow, cinematic dream pop in an intimate arena setting.', 'assets/stadiums/jis_layout.jpg'),
(5, 'Keshi: Requiem Tour', '2027-01-18', 'Istora Senayan', 'Jakarta', 'Rp1.350.000', 'assets/events/keshi_istora.jpg', 0, 85, 5, 0, 'assets/events/keshi_istora.jpg', 'KESHI', '20:00 WIB', 'Moody R&B tracks from the king of falsettos.', 'assets/stadiums/tennis_layout.jpg'),
(6, 'Hindia: Lagipula Hidup Akan Berakhir', '2027-02-14', 'Tennis Indoor Senayan', 'Jakarta', 'Rp450.000', 'assets/events/hindia_tennis_indoor.jpeg', 0, 140, 6, 1, 'assets/events/hindia_tennis_indoor.jpeg', 'Hindia', '19:30 WIB', 'Official Hindia concert with alternative indie rock anthems.', 'assets/stadiums/tennis_layout.jpg'),
(7, 'Dewa 19: 30 Tahun Karaoke Massal', '2026-11-28', 'Stadion Utama Gelora Bung Karno', 'Jakarta', 'Rp350.000', 'assets/events/dewa_gbk.webp', 0, 400, 7, 1, 'assets/events/dewa_gbk.webp', 'Dewa 19', '19:30 WIB', 'Indonesian rock royalty celebrating their best anthems.', 'assets/stadiums/gbk_layout.jpg'),
(8, 'TULUS: Tur Manusia Jakarta', '2026-08-20', 'Santhika Hall Kelapa Gading', 'Jakarta', 'Rp550.000', 'assets/events/tulus.jpg', 0, 55, 8, 0, 'assets/events/tulus.jpg', 'TULUS', '20:00 WIB', 'Award-winning singer-songwriter with deep emotional soul tracks.', 'assets/stadiums/grand_layout.jpg');

DELETE FROM event_ticket_types;
INSERT INTO event_ticket_types (id, nearby_event_id, name, badge, badge_color, description, bullet1, bullet2, bullet3, price, stock_remaining, max_per_order, sort_order) VALUES
(1, 1, 'CAT 1', 'POPULAR', '#8B5CF6', 'Premium reserved seating.', 'Assigned seat category', 'Digital QR entry', 'Official ID verification required', 950000, 80, 4, 1),
(2, 1, 'VIP Package', 'VIP', '#EAB308', 'VIP package with priority entry.', 'Premium viewing area', 'Dedicated entry lane', 'Limited merch bundle', 1850000, 30, 2, 2),
(3, 2, 'CAT 1', 'HOT', '#EF4444', 'Reserved seating for SEVENTEEN Jakarta.', 'Assigned seat category', 'Digital QR entry', 'Official ID verification required', 1800000, 120, 4, 1),
(4, 2, 'VIP Soundcheck', 'SOUNDCHECK', '#EC4899', 'VIP package with soundcheck access.', 'Soundcheck session', 'VIP laminate and merch', 'Priority entry lane', 3500000, 25, 2, 2),
(5, 6, 'Festival', 'LOCAL PICK', '#22C55E', 'General admission Hindia concert access.', 'Festival standing area', 'Digital ticket with QR', 'Reminder enabled', 450000, 140, 6, 1),
(6, 8, 'Regular', 'DISCOVERY', '#22C55E', 'Regular TULUS tour access.', 'General admission area', 'Digital ticket with QR', 'Official entry verification', 550000, 55, 4, 1);
