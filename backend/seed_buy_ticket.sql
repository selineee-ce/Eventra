USE eventra;

SET @sql = IF(
  (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'nearby_events' AND COLUMN_NAME = 'detail_image') = 0,
  'ALTER TABLE nearby_events ADD COLUMN detail_image TEXT NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'nearby_events' AND COLUMN_NAME = 'artist_name') = 0,
  'ALTER TABLE nearby_events ADD COLUMN artist_name VARCHAR(160) NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'nearby_events' AND COLUMN_NAME = 'show_time') = 0,
  'ALTER TABLE nearby_events ADD COLUMN show_time VARCHAR(80) NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'nearby_events' AND COLUMN_NAME = 'description') = 0,
  'ALTER TABLE nearby_events ADD COLUMN description TEXT NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'nearby_events' AND COLUMN_NAME = 'venue_layout') = 0,
  'ALTER TABLE nearby_events ADD COLUMN venue_layout VARCHAR(160) NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

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
  sort_order INT NOT NULL
);

SET @sql = IF(
  (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'event_ticket_types' AND COLUMN_NAME = 'stock_remaining') = 0,
  'ALTER TABLE event_ticket_types ADD COLUMN stock_remaining INT NOT NULL DEFAULT 0 AFTER price',
  'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE nearby_events SET
  detail_image = 'https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=1400&q=80',
  artist_name = 'NIKI',
  show_time = 'Saturday, 21 Aug - 19:30 WIB',
  description = 'NIKI brings the Buzz World Tour experience to Jakarta with an intimate arena setup, premium seating, and official digital ticket entry.',
  venue_layout = 'assets/stadiums/tennis_layout.jpg'
WHERE id = 1;

UPDATE nearby_events SET
  detail_image = 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=1400&q=80',
  artist_name = 'Pamungkas',
  show_time = 'Thursday, 04 Sep - 19:00 WIB',
  description = 'Pamungkas performs a full-band Birdy era set in Bandung with seated and standing categories for different viewing preferences.',
  venue_layout = 'assets/stadiums/gbk_layout.jpg'
WHERE id = 2;

UPDATE nearby_events SET
  detail_image = 'https://images.unsplash.com/photo-1501612780327-45045538702b?auto=format&fit=crop&w=1400&q=80',
  artist_name = 'Hindia',
  show_time = 'Saturday, 11 Oct - 19:00 WIB',
  description = 'Hindia returns with a narrative live show in Surabaya, featuring festival floor access and reserved premium categories.',
  venue_layout = 'assets/stadiums/grand_layout.jpg'
WHERE id = 3;

UPDATE nearby_events SET
  detail_image = 'https://images.unsplash.com/photo-1503095396549-807759245b35?auto=format&fit=crop&w=1400&q=80',
  artist_name = 'Reality Club',
  show_time = 'Saturday, 09 Aug - 19:00 WIB',
  description = 'Reality Club performs an intimate Yogyakarta show with regular, priority, and meet-and-greet ticket experiences.',
  venue_layout = 'assets/stadiums/sleman_layout.jpg'
WHERE id = 4;

UPDATE nearby_events SET
  detail_image = 'https://images.unsplash.com/photo-1499364615650-ec38552f4f34?auto=format&fit=crop&w=1400&q=80',
  artist_name = 'Rich Brian',
  show_time = 'Sunday, 02 Nov - 20:00 WITA',
  description = 'Rich Brian headlines a Bali beach-club show with general access, VIP deck, and backstage-style premium access.',
  venue_layout = 'assets/stadiums/atlas_layout.jpg'
WHERE id = 5;

UPDATE nearby_events SET
  detail_image = 'https://images.unsplash.com/photo-1483412033650-1015ddeb83d1?auto=format&fit=crop&w=1400&q=80',
  artist_name = 'Tiara Andini',
  show_time = 'Sunday, 21 Sep - 19:00 WIB',
  description = 'Tiara Andini presents a showcase concert in Medan with accessible seating and premium close-view categories.',
  venue_layout = 'assets/stadiums/gbk_layout.jpg'
WHERE id = 6;

UPDATE nearby_events SET
  detail_image = 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?auto=format&fit=crop&w=1400&q=80',
  artist_name = 'BLACKPINK',
  show_time = 'Sunday, 18 Jan - 19:00 WIB',
  description = 'BLACKPINK brings a stadium-scale world tour production to Jakarta International Stadium with tiered reserved seating and VIP access.',
  venue_layout = 'assets/stadiums/jis_layout.jpg'
WHERE id = 7;

UPDATE nearby_events SET
  detail_image = 'https://images.unsplash.com/photo-1508973378895-6cf7c3d9f1f3?auto=format&fit=crop&w=1400&q=80',
  artist_name = 'Tulus',
  show_time = 'Tuesday, 14 Oct - 19:30 WIB',
  description = 'Tulus presents the Monokrom Experience in Solo with warm arena staging, seated categories, and fan package options.',
  venue_layout = 'assets/stadiums/jiexpo_layout.jpg'
WHERE id = 8;

DELETE FROM event_ticket_types WHERE nearby_event_id BETWEEN 1 AND 8;

INSERT INTO event_ticket_types (
  id, nearby_event_id, name, badge, badge_color, description,
  bullet1, bullet2, bullet3, price, stock_remaining, sort_order
) VALUES
(101,1,'VIP','Ultimate','red','Closest Tennis Indoor category in front of the stage.','VIP center section based on venue layout','Priority entrance lane','Limited allocation only',2500000,24,1),
(102,1,'CAT 1','Premium','orange','Side-front category with strong stage sightline.','CAT 1 pink section on layout','Reserved seating block','Digital QR ticket entry',1450000,64,2),
(103,1,'CAT 2','Standard','purple','Middle category behind VIP area.','CAT 2 yellow section on layout','Standard queue lane','Digital QR ticket entry',950000,120,3),
(104,1,'CAT 3','Standard','purple','Back and side category for budget access.','CAT 3 blue section on layout','Standard queue lane','Digital QR ticket entry',650000,180,4),

(201,2,'VIP Floor','Ultimate','red','Closest floor category to the stage.','VIP floor purple section on layout','Priority entrance lane','Digital QR ticket entry',1250000,36,1),
(202,2,'Festival Floor','Premium','orange','Main standing festival floor behind VIP.','Festival floor pink section on layout','Dedicated entrance lane','Digital QR ticket entry',850000,90,2),
(203,2,'CAT 1','Premium','orange','Side-front seated category near stage.','CAT 1 orange section on layout','Reserved seating block','Digital QR ticket entry',650000,120,3),
(204,2,'CAT 2','Standard','purple','Mid-side seated category.','CAT 2 yellow section on layout','Standard queue lane','Digital QR ticket entry',450000,160,4),
(205,2,'CAT 3','Standard','purple','Outer seated category for value access.','CAT 3 blue section on layout','Standard queue lane','Digital QR ticket entry',350000,220,5),
(206,2,'CAT 4 Upper','Standard','purple','Upper category for wide stadium view.','CAT 4 green upper section on layout','Standard queue lane','Digital QR ticket entry',250000,260,6),

(301,3,'VIP','Ultimate','red','Closest Grand City category in front of the stage.','VIP purple section on layout','Priority entrance lane','Digital QR ticket entry',1350000,28,1),
(302,3,'CAT 1','Premium','orange','Front-middle category behind VIP.','CAT 1 pink section on layout','Reserved seating block','Digital QR ticket entry',850000,80,2),
(303,3,'CAT 2','Standard','purple','Middle category with centered stage view.','CAT 2 yellow section on layout','Standard queue lane','Digital QR ticket entry',500000,140,3),
(304,3,'CAT 3','Standard','purple','Rear and side category for regular entry.','CAT 3 blue section on layout','Standard queue lane','Digital QR ticket entry',350000,200,4),

(401,4,'VIP','Ultimate','red','Closest Sleman City Hall category in front of the stage.','VIP purple section on layout','Priority entrance lane','Digital QR ticket entry',1100000,20,1),
(402,4,'CAT 1','Premium','orange','Front-middle category behind VIP.','CAT 1 pink section on layout','Dedicated entrance lane','Digital QR ticket entry',650000,54,2),
(403,4,'CAT 2','Standard','purple','Side-middle category on both wings.','CAT 2 yellow section on layout','Standard queue lane','Digital QR ticket entry',450000,88,3),
(404,4,'CAT 3','Standard','purple','Rear category for regular access.','CAT 3 blue section on layout','Standard queue lane','Digital QR ticket entry',350000,140,4),

(501,5,'VIP Deck','Ultimate','red','Top premium deck category at Atlas Beach Club.','VIP deck purple section on layout','Priority entrance lane','Selected hospitality access',3000000,16,1),
(502,5,'VIP Table','Premium','orange','Premium table category below VIP deck.','VIP table pink section on layout','Dedicated entrance lane','Table-area access',2200000,30,2),
(503,5,'GA','Standard','purple','General admission area near the main floor.','GA yellow section on layout','Digital QR ticket entry','Sales end on event day, 18:00 WITA',1000000,120,3),
(504,5,'Beach Zone','Standard','purple','Beach zone category with wider venue view.','Beach zone blue section on layout','Digital QR ticket entry','Standard queue lane',750000,180,4),

(601,6,'VIP Floor','Ultimate','red','Closest floor category to the stage.','VIP floor purple section on layout','Priority entrance lane','Digital QR ticket entry',900000,18,1),
(602,6,'Festival Floor','Premium','orange','Main floor category behind VIP.','Festival floor pink section on layout','Dedicated entrance lane','Digital QR ticket entry',650000,70,2),
(603,6,'CAT 1','Premium','orange','Side-front seated category.','CAT 1 orange section on layout','Reserved seating block','Digital QR ticket entry',550000,96,3),
(604,6,'CAT 2','Standard','purple','Mid-side category.','CAT 2 yellow section on layout','Standard queue lane','Digital QR ticket entry',400000,130,4),
(605,6,'CAT 3','Standard','purple','Outer lower category.','CAT 3 blue section on layout','Standard queue lane','Digital QR ticket entry',300000,170,5),
(606,6,'CAT 4 Upper','Standard','purple','Upper-category seating.','CAT 4 green upper section on layout','Standard queue lane','Digital QR ticket entry',225000,240,6),

(701,7,'VIP Floor','Ultimate','red','Closest floor category for BLACKPINK Jakarta.','VIP floor purple section on JIS layout','Priority entrance lane','Official ID verification required',5500000,12,1),
(702,7,'Festival Floor','Premium','orange','Main festival floor behind VIP.','Festival floor pink section on JIS layout','Dedicated entrance lane','Digital QR ticket entry',4200000,42,2),
(703,7,'CAT 1','Premium','orange','Side-front reserved stadium seating.','CAT 1 orange section on JIS layout','Reserved seat category','Digital QR ticket entry',3200000,75,3),
(704,7,'CAT 2','Standard','purple','Mid-side reserved stadium seating.','CAT 2 yellow section on JIS layout','Reserved seat category','Digital QR ticket entry',2500000,120,4),
(705,7,'CAT 3','Standard','purple','Lower outer stadium seating.','CAT 3 blue section on JIS layout','Reserved seat category','Digital QR ticket entry',1900000,160,5),
(706,7,'CAT 4 Upper','Standard','purple','Upper stadium seating category.','CAT 4 green upper section on JIS layout','Reserved seat category','Digital QR ticket entry',1450000,220,6),

(801,8,'VIP Floor','Ultimate','red','Closest category to the stage at JIExpo.','VIP floor purple section on layout','Priority entrance lane','Digital QR ticket entry',1500000,25,1),
(802,8,'Festival Floor','Premium','orange','Main festival floor behind VIP.','Festival floor pink section on layout','Dedicated entrance lane','Digital QR ticket entry',1100000,60,2),
(803,8,'CAT 1','Premium','orange','Side-front category near stage.','CAT 1 orange section on layout','Reserved seating block','Digital QR ticket entry',900000,100,3),
(804,8,'CAT 2','Standard','purple','Middle category with centered view.','CAT 2 yellow section on layout','Standard queue lane','Digital QR ticket entry',650000,150,4),
(805,8,'CAT 3','Standard','purple','Rear and side category for regular access.','CAT 3 blue section on layout','Standard queue lane','Digital QR ticket entry',550000,210,5);
