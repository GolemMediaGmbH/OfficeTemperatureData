/*
 Add additional timestamp col  mysqltime datatype
*/
ALTER TABLE `ot` ADD COLUMN `dt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP();
UPDATE `ot` SET `dt` = FROM_UNIXTIME(`ts`);

/*
 Use DECIMAL instead of FLOAT
*/
ALTER TABLE `ot` MODIFY lon DECIMAL(10,5);
ALTER TABLE `ot` MODIFY lat DECIMAL(10,5);

/*
 Additional columns to store validated data
*/
ALTER TABLE `ot` ADD COLUMN `r_temp` INTEGER NOT NULL;
ALTER TABLE `ot` ADD COLUMN `f_state` CHAR(4) DEFAULT NULL;
ALTER TABLE `ot` 
ADD COLUMN `f_lat` DECIMAL(10,5) DEFAULT NULL,
ADD COLUMN `f_lon` DECIMAL(10,5) DEFAULT NULL, 
ADD COLUMN`f_country` CHAR(2) DEFAULT NULL,
ADD COLUMN `f_city` CHAR(255) DEFAULT NULL,
ADD COLUMN `f_zip` CHAR(10) DEFAULT NULL;

UPDATE `ot` SET `r_temp` = ROUND(`temp`*10);
UPDATE `ot` SET `f_lon` = `lon`;
UPDATE `ot` SET `f_lat` = `lat`;
UPDATE `ot` SET `f_country` = `country`;
UPDATE `ot` SET `f_city` = `city`;
UPDATE `ot` SET `f_zip` = `zip`;
/*
 Marks an entry with an invalid lon/lat (= 1), city/zip (= 2) entry
 Temperature might be still valid
*/
ALTER TABLE `ot` ADD COLUMN `f_locationwrong` INT(4) NOT NULL DEFAULT 0;

/*
 Entry is invalid, not to be used
*/
ALTER TABLE `ot` ADD COLUMN `f_ignore` INT(1) NOT NULL DEFAULT 0;
