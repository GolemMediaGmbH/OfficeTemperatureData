DROP TABLE IF EXISTS `ot`;
CREATE TABLE `ot` LIKE `officetemp`;
INSERT `ot` SELECT * FROM `officetemp`;