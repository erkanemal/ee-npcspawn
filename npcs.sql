CREATE TABLE IF NOT EXISTS `npcs` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `model` varchar(50) NOT NULL,
    `coords_x` float NOT NULL,
    `coords_y` float NOT NULL,
    `coords_z` float NOT NULL,
    `heading` float NOT NULL,
    `anim_dict` varchar(50) DEFAULT NULL,
    `anim_name` varchar(50) DEFAULT NULL,
    PRIMARY KEY (`id`)
); 