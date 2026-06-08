/*
  Warnings:

  - The values [pass] on the enum `user_favorites_favorite_type` will be removed. If these variants are still used in the database, this will fail.

*/
-- AlterTable
ALTER TABLE `user_favorites` MODIFY `favorite_type` ENUM('event', 'artist') NOT NULL;
