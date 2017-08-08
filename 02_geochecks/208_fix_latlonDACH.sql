ALTER TABLE ot ADD COLUMN t_lat DECIMAL(10,5) DEFAULT NULL;
ALTER TABLE ot ADD COLUMN t_lon DECIMAL(10,5) DEFAULT NULL;
UPDATE ot SET t_lat = f_lon, t_lon = f_lat WHERE f_country in ('DE', 'AT', 'CH') AND f_lat < f_lon; 
UPDATE ot SET f_lat = t_lat, f_lon = t_lon WHERE f_country in ('DE', 'AT', 'CH') AND t_lat IS NOT NULL AND t_lat IS NOT NULL;
ALTER TABLE ot DROP COLUMN t_lat;
ALTER TABLE ot DROP COLUMN t_lon;