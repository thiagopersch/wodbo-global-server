-- Migration: Extended Outfit Fields (Wings, Aura, Shaders, HealthBars, ManaBars)
-- Execute: mysql -u root dbosupreme < data/sql/migration_extoutfits.sql

ALTER TABLE `players`
  ADD COLUMN `lookmount` INT NOT NULL DEFAULT 0 AFTER `lookaddons`,
  ADD COLUMN `lookwings` INT NOT NULL DEFAULT 0 AFTER `lookmount`,
  ADD COLUMN `lookaura` INT NOT NULL DEFAULT 0 AFTER `lookwings`,
  ADD COLUMN `lookshader` INT NOT NULL DEFAULT 0 AFTER `lookaura`,
  ADD COLUMN `lookhealthbar` INT NOT NULL DEFAULT 0 AFTER `lookshader`,
  ADD COLUMN `lookmanabar` INT NOT NULL DEFAULT 0 AFTER `lookhealthbar`;
