-- CreateTable
CREATE TABLE `app_config` (
    `config_key` VARCHAR(120) NOT NULL,
    `config_value` TEXT NOT NULL,

    PRIMARY KEY (`config_key`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `event_ticket_types` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `event_id` INTEGER NOT NULL,
    `name` VARCHAR(120) NOT NULL,
    `badge` VARCHAR(80) NULL,
    `badge_color` VARCHAR(30) NULL,
    `description` TEXT NULL,
    `bullet1` VARCHAR(160) NULL,
    `bullet2` VARCHAR(160) NULL,
    `bullet3` VARCHAR(160) NULL,
    `price` INTEGER NOT NULL,
    `stock_remaining` INTEGER NOT NULL DEFAULT 0,
    `max_per_order` INTEGER NOT NULL DEFAULT 4,
    `sort_order` INTEGER NOT NULL,

    INDEX `fk_ticket_types_event`(`event_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `events` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `user_id` INTEGER NULL,
    `title` VARCHAR(200) NOT NULL,
    `lineup` VARCHAR(200) NULL,
    `venue` VARCHAR(120) NOT NULL,
    `city` VARCHAR(120) NOT NULL,
    `date_label` VARCHAR(40) NOT NULL,
    `show_time` VARCHAR(80) NULL,
    `price` VARCHAR(40) NULL,
    `image` TEXT NULL,
    `detail_image` TEXT NULL,
    `venue_layout` VARCHAR(160) NULL,
    `description` TEXT NULL,
    `source_url` TEXT NULL,
    `tag1` VARCHAR(50) NULL,
    `tag2` VARCHAR(50) NULL,
    `button` VARCHAR(50) NULL,
    `is_featured` BOOLEAN NOT NULL DEFAULT false,
    `is_limited` BOOLEAN NOT NULL DEFAULT false,
    `remaining_seats` INTEGER NOT NULL DEFAULT 0,
    `sort_order` INTEGER NOT NULL DEFAULT 0,
    `is_favorite` BOOLEAN NOT NULL DEFAULT false,

    INDEX `fk_events_user`(`user_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `notifications` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(200) NOT NULL,
    `subtitle` TEXT NOT NULL,
    `sort_order` INTEGER NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `pass_packages` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(120) NOT NULL,
    `description` TEXT NOT NULL,
    `price` VARCHAR(50) NOT NULL,
    `sort_order` INTEGER NOT NULL,
    `is_favorite` BOOLEAN NOT NULL DEFAULT false,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `tickets` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `user_id` INTEGER NULL,
    `title` VARCHAR(200) NOT NULL,
    `image` TEXT NOT NULL,
    `date_label` VARCHAR(40) NOT NULL,
    `time_label` VARCHAR(40) NOT NULL,
    `venue` VARCHAR(120) NOT NULL,
    `section` VARCHAR(40) NOT NULL,
    `row_label` VARCHAR(40) NOT NULL,
    `seat_label` VARCHAR(40) NOT NULL,
    `qr_data` VARCHAR(255) NOT NULL,
    `ticket_type` VARCHAR(100) NOT NULL,
    `ticket_status` VARCHAR(50) NOT NULL DEFAULT 'UPCOMING',
    `sort_order` INTEGER NOT NULL,

    INDEX `fk_tickets_user`(`user_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `user_favorites` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `user_id` INTEGER NOT NULL,
    `favorite_type` ENUM('event', 'pass') NOT NULL,
    `item_id` INTEGER NOT NULL,
    `created_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),

    UNIQUE INDEX `uq_user_favorites_item`(`user_id`, `favorite_type`, `item_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `users` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(120) NOT NULL,
    `name` VARCHAR(120) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(30) NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `bio` TEXT NULL,
    `location` VARCHAR(120) NULL,
    `avatar_url` TEXT NULL,
    `followers_count` INTEGER NOT NULL DEFAULT 0,
    `events_count` INTEGER NOT NULL DEFAULT 0,
    `upcoming_events_count` INTEGER NOT NULL DEFAULT 0,
    `genre` VARCHAR(120) NULL,
    `description` TEXT NULL,
    `role` VARCHAR(50) NOT NULL DEFAULT 'user',
    `is_verified` BOOLEAN NOT NULL DEFAULT false,
    `sort_order` INTEGER NOT NULL DEFAULT 0,
    `created_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),

    UNIQUE INDEX `username`(`username`),
    UNIQUE INDEX `email`(`email`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `event_ticket_types` ADD CONSTRAINT `fk_ticket_types_event` FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE `events` ADD CONSTRAINT `fk_events_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE `tickets` ADD CONSTRAINT `fk_tickets_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE `user_favorites` ADD CONSTRAINT `fk_user_favorites_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE RESTRICT;
