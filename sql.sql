CREATE TABLE IF NOT EXISTS `persistent_npcs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `model` VARCHAR(255) NOT NULL,
    `x` FLOAT NOT NULL,
    `y` FLOAT NOT NULL,
    `z` FLOAT NOT NULL,
    `emote` VARCHAR(255) DEFAULT NULL
);
