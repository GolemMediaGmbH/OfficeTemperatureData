/* Ignore all values outside the time frame */
UPDATE ot SET f_ignore = 1 WHERE dt < '2016-04-19 12:00:00' OR dt > '2017-04-30 23:59:59';

/* Ignore all insane temperature values */
UPDATE ot SET f_ignore = 1 WHERE r_temp < 1 OR r_temp > 600;