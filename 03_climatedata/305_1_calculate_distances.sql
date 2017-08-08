/*
 Find which station is nearest to an observer
*/
 
DROP TABLE IF EXISTS tmp_distances;
CREATE TABLE tmp_distances
(
	dwd_station_id_u INTEGER,
	dwd_latlon POINT, 
	temp_latlon POINT DEFAULT NULL,
	distance INTEGER,
	dt_start DATE,
	dt_end DATE
);

INSERT INTO tmp_distances (dwd_station_id_u, dwd_latlon, temp_latlon, dt_start, dt_end)
SELECT 
dwd.station_id_u, 
ST_GeomFromText(CONCAT("POINT(",dwd.lon,' ',dwd.lat,")")),
temp.pt_latlon,
dwd.dt_start,
dwd.dt_end
FROM dwd_station AS dwd
JOIN (SELECT DISTINCT(t.pt_latlon) FROM ot AS t WHERE pt_latlon IS NOT NULL) AS temp;

CREATE INDEX ib_dt_start ON tmp_distances(dt_start) USING BTREE;
CREATE INDEX ib_dt_end ON tmp_distances(dt_end) USING BTREE;

UPDATE tmp_distances SET distance = ST_Distance_Sphere(temp_latlon, dwd_latlon);
CREATE INDEX ib_dist ON tmp_distances(distance) USING BTREE;

DROP TABLE IF EXISTS agg_ot;
CREATE TABLE agg_ot (
	agg_ot_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
	ot_latlon POINT NOT NULL,
	ot_dt DATE NULL NULL,
	dwd_station_id_u INTEGER DEFAULT NULL
);

INSERT INTO agg_ot (ot_latlon, ot_dt)
SELECT
pt_latlon, dt_date
FROM ot
WHERE pt_latlon IS NOT NULL
GROUP BY pt_latlon, dt_date;

DROP PROCEDURE IF EXISTS findNextDWD;
DELIMITER $$
CREATE PROCEDURE findNextDWD()
 BEGIN
 DECLARE done INT DEFAULT FALSE;
 DECLARE latlon POINT;
 DECLARE dt DATE;
 DECLARE aid INTEGER;
 DECLARE curs CURSOR FOR SELECT ot_latlon, ot_dt, agg_ot_id FROM agg_ot;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
 OPEN curs;
 read_loop: LOOP
  FETCH curs INTO latlon, dt, aid;
  IF done THEN 
   LEAVE read_loop; 
  END IF;
  UPDATE agg_ot SET dwd_station_id_u = (SELECT dwd_station_id_u FROM tmp_distances WHERE dt_start <= dt AND dt_end >= dt AND temp_latlon = latlon ORDER BY distance ASC LIMIT 1) WHERE agg_ot_id = aid;
 END LOOP;
 CLOSE curs;
END
$$
DELIMITER ;
CALL findNextDWD();
DROP PROCEDURE findNextDWD;

# will take long
UPDATE ot AS a, agg_ot AS b
SET a.dwd_station_id_u = b.dwd_station_id_u
WHERE a.pt_latlon = b.ot_latlon;

DROP TABLE agg_ot;