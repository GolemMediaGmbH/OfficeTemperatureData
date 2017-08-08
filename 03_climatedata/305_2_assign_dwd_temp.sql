/*
 Assign a temperature from the dwd table to the corresponding office value
*/
DROP TABLE IF EXISTS mem_ot;

CREATE TABLE mem_ot (
tid INTEGER NOT NULL,
dt DATETIME NOT NULL,
dwd_station_id_u INTEGER NOT NULL,
dwd_temp INTEGER DEFAULT NULL
) ENGINE=MEMORY;

CREATE INDEX ix_dt ON mem_ot(dt);
CREATE INDEX ix_sidu ON mem_ot(dwd_station_id_u);
 
INSERT INTO mem_ot (tid, dt, dwd_station_id_u)
SELECT tid, dt_round, dwd_station_id_u
FROM ot
WHERE dwd_station_id_u IS NOT NULL;

# will take long
UPDATE mem_ot AS o, dwd_tempdata AS t, dwd_station AS s
SET o.dwd_temp = t.temp
WHERE o.dt = t.dt
AND
o.dwd_station_id_u = s.station_id_u
AND 
t.station_id = s.station_id;

UPDATE ot AS o, mem_ot AS m
SET o.dwd_temp = m.dwd_temp
WHERE o.tid = m.tid;

DROP TABLE mem_ot;