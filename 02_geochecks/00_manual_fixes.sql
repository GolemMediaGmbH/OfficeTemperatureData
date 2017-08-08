/*
several fixes to the db found while working
*/

UPDATE ot SET f_ignore = 1 WHERE f_lon = 78544 AND f_lat = 15643;
UPDATE ot SET f_ignore = 1 WHERE f_lon = 1337;

UPDATE OT SET f_city = NULL WHERE f_city = "Walkersbach";

UPDATE ot SET f_country = 'DE' WHERE f_city = 'Hausach';
UPDATE ot SET f_country = 'DE' WHERE f_city = 'Uhingen';
UPDATE ot SET f_country = 'DE' WHERE f_city = 'Hildesheim';
UPDATE ot SET f_country = 'DE' WHERE f_city = 'Hannover';
UPDATE ot SET f_country = 'DE' WHERE f_city = 'Magdeburg';
UPDATE ot SET f_country = 'DE' WHERE f_city = 'Emlichheim';
UPDATE ot SET f_country = 'DE' WHERE f_city = 'Münster';
UPDATE ot SET f_country = 'DE' WHERE f_city = 'Bad Vilbel';
UPDATE ot SET f_country = 'DE' WHERE f_city = 'Glashütte';
UPDATE ot SET f_country = 'DE' WHERE f_city = 'Lalendorf';
UPDATE ot SET f_country = 'DE' WHERE f_city = 'Nürnberg';
UPDATE ot SET f_country = 'DE' WHERE f_city = 'Waldkirch';

UPDATE ot SET f_country = 'AT' WHERE f_city = 'Salzburg';

UPDATE ot SET f_country = 'DE' WHERE city = 'Dargelin' AND country = 'MV';

UPDATE ot SET f_country = 'DE', f_lon = 7.47490, f_lat = 51.51608 WHERE city = 'Dortmund' AND f_lon IS NULL;
UPDATE ot SET f_country = 'DE', f_lon = 7.59419, f_lat = 51.96320 WHERE city = 'Münster' AND f_lon IS NULL;
UPDATE ot SET f_lat = 48.56205, f_lon = 12.08386 WHERE f_country = 'DE' AND f_city = 'Altdorf';
UPDATE ot SET f_lat = 51.51313, f_lon = 6.84712 WHERE f_country = 'DE' AND f_city = 'Oberhausen';
UPDATE ot SET f_lat = 18.70471, f_lon = 99.9092 WHERE f_country = 'TH' AND f_city = 'Ban Pong';
UPDATE ot SET f_lat = 52.3007, f_lon = 8.89837 WHERE f_country = 'DE' AND f_city = 'Minden';
UPDATE ot SET f_lat = 49.30162, f_lon = 8.63226 WHERE f_country = 'DE' AND f_city = 'Walldorf';

UPDATE ot SET f_city = 'Lauterbach (Hessen)' WHERE city = 'Lauterbach' AND f_country = 'DE';

UPDATE ot SET f_lat = 52.35, f_lon = 9.8 WHERE lat = 9.8 AND lon = 52.35 AND country = 'DE';
UPDATE ot SET f_lat = 52.15, f_lon = 9.97 WHERE lat = 9.97 AND lon = 52.15 AND country = 'DE';
UPDATE ot SET f_lat = 48.35, f_lon = 10.9 WHERE lat = 10.9 AND lon = 48.35 AND country = 'DE';
UPDATE ot SET f_lat = 52.15, f_lon = 11.57 WHERE lat = 11.57 AND lon = 52.15 AND country = 'DE';
UPDATE ot SET f_lat = 52.46, f_lon = 13.3 WHERE lat = 13.3 AND lon = 52.46 AND country = 'DE';
UPDATE ot SET f_lat = 52.54, f_lon = 13.39 WHERE lat = 13.39 AND lon = 52.54 AND country = 'DE';

UPDATE ot SET f_lon =  6.07925, f_lat = 49.84789 WHERE f_lat =  6.07925 AND f_lon = 49.84789; 
UPDATE ot SET f_lon = 6.45000, f_lat = 49.70000 WHERE f_lat = 6.45000 AND f_lon = 49.70000;
UPDATE ot SET f_lon = 6.25069, f_lat = 49.70936 WHERE f_lat = 6.25069 AND f_lon = 49.70936;

UPDATE ot SET f_lon = 75.61892, f_lat = 15.42022 WHERE f_lat = 75.61892  AND f_lon = 15.42022;

UPDATE ot SET f_lat = 43.42, f_lon = -79.24, country = 'CA' WHERE lat = 79.24 AND lon = 43.42;

UPDATE ot SET f_lat = 52.2625, f_lon = 10.2144 WHERE f_lat = 10.2144 AND f_lon = 52.2625;

UPDATE ot SET f_city = 'Luxemburg' WHERE f_lat = 49.59920  AND f_lon =  6.13183;

/*
 Data invalid, drop completly
 */
UPDATE ot SET f_ignore = 1 WHERE 
	city = 'Breiten-1.27000000F 02Baden' OR
	city = 'Breiten1.9937500F 01Baden' OR
	city = 'Breiten/Baden' OR
	city = 'A' OR
	city = 'Teststadt' OR
	city = 'mÃ¼nch ' OR
	city = 'XXX';
/*
 Most of invalid data are translations and miss spellings or names of suburbs
*/
UPDATE ot SET f_city = 'Böblingen' WHERE city = 'BÃ¶blingen';
UPDATE ot SET f_city = 'Rüsselsheim' WHERE city = 'RÃ¼sselsheim';
UPDATE ot SET f_city = 'Hünstetten' WHERE city = 'HÃ¼nstetten';
UPDATE ot SET f_city = 'Glashütte' WHERE city = 'GlashÃ¼tte';
UPDATE ot SET f_city = 'Hückelhoven' WHERE city = 'HÃ¼ckelhoven';
UPDATE ot SET f_city = 'Fuldabrück' WHERE city = 'FuldabrÃ¼ck';
UPDATE ot SET f_city = 'Osnabrück' WHERE city = 'OsnabrÃ¼ck';
UPDATE ot SET f_city = 'Zürich' WHERE city = 'ZÃ¼rich';
UPDATE ot SET f_city = 'Würgl' WHERE city = 'WÃ¶rgl';
UPDATE ot SET f_city = 'Göttingen' WHERE city = 'GÃ¶ttingen';
UPDATE ot SET f_city = 'Schänis' WHERE city = 'SchÃ¤nis';
UPDATE ot SET f_city = 'Frankfurt (Oder)' WHERE city = 'Frankfurt Oder';
UPDATE ot SET f_city = 'Münster' WHERE city = 'Muenster' OR city = 'MÃ¼nster';
UPDATE ot SET f_city = 'Schwäbisch Hall' WHERE city = 'SchwÃ¤bisch Hall';
UPDATE ot SET f_city = 'München' WHERE city = 'Munich' OR city = 'Muenchen' OR city = 'MÃ¼nchen';
UPDATE ot SET f_city = 'Hürth' WHERE city = 'Huerth' OR city = 'HÃ¼rth' OR city = 'H%Ã%¼rth';
UPDATE ot SET f_city = 'Freiburg im Breisgau' WHERE city = 'Freiburg';
UPDATE ot SET f_city = 'Nürnberg' WHERE city = 'N%Ã%¼rnberg' OR city = 'NÃ¼rnberg ' OR city = 'Nuernberg';
UPDATE ot SET f_city = 'Berlin' WHERE city = 'Berlin - East';
UPDATE ot SET f_city = 'Fröndenberg/Ruhr' WHERE city = 'Langschede';
UPDATE ot SET f_city = 'Hamminkeln' WHERE city = 'Dingden';
UPDATE ot SET f_city = 'Düsseldorf' WHERE city = 'Duesseldorf' OR city = 'DÃ¼sseldorf';
UPDATE ot SET f_city = 'Himberg' WHERE city = 'Velm' AND f_country = 'AT';
UPDATE ot SET f_city = 'Wetter (Ruhr)' WHERE city = 'Wetter';
UPDATE ot SET f_city = 'Hofheim am Taunus' WHERE city = 'Hofheim' AND zip = '65719';
UPDATE ot SET f_city = 'Dreieich' WHERE city = 'Dreieich' AND zip = '63303';
UPDATE ot SET f_city = 'Landau in der Pfalz' WHERE city = 'Landau';
UPDATE ot SET f_city = 'Würzburg' WHERE city = 'würzburg' OR city = 'wÃ¼rzburg';
UPDATE ot SET f_city = 'Lübeck' WHERE city = 'Luebeck';
UPDATE ot SET f_city = 'Ludwigsburg' WHERE city = 'Ludwigsburg (WÃ¼rttemberg)';
UPDATE ot SET f_city = 'Saarbrücken' WHERE city = 'saarbrÃ¼ck';
UPDATE ot SET f_city = 'Frankfurt am Main' WHERE city = 'Frankfurt';
UPDATE ot SET f_city = 'Bad Vilbel' WHERE city = 'BadVilbel';
UPDATE ot SET f_city = 'Gadag' WHERE city = 'GADAG';
UPDATE ot SET f_city = 'Wendlingen am Neckar' WHERE city = 'Wendlingen';
UPDATE ot SET f_city = 'Staufenberg' WHERE city = 'Mainzlar';
UPDATE ot SET f_city = 'Dessau-Roßlau' WHERE city = 'Dessau' OR city = 'Dessau-RoÃŸlau';
UPDATE ot SET f_city = 'Faßberg' WHERE city = 'FaÃŸberg';
UPDATE ot SET f_city = 'Lübbecke' WHERE city = 'Luebbecke';
UPDATE ot SET f_city = 'Köln' WHERE city = 'Koeln' OR city = 'KÃ¶ln';
UPDATE ot SET f_city = 'Berlin' WHERE city = 'Be';
UPDATE ot SET f_city = 'Ingenbohl' WHERE city = 'Ingenbohl';
UPDATE ot SET f_city = 'Ellwangen (Jagst)' WHERE city = 'Ellwangen';
UPDATE ot SET f_city = 'Sankt Pölten' WHERE city = 'St.Poelten';
UPDATE ot SET f_city = 'Lalendorf' WHERE city = 'Reinshagen';
UPDATE ot SET f_city = 'Wädenswil' WHERE city = 'Au ZH';
UPDATE ot SET f_city = 'Vienna' WHERE city = 'Vienna';
UPDATE ot SET f_city = 'Luzern', f_zip = '6047' WHERE city = 'Luzern%zip=6047';
UPDATE ot SET f_city = 'Leinfelden-Echterdingen' WHERE city = 'Leinfelden';
UPDATE ot SET f_city = 'Worms' WHERE city = 'worms';
UPDATE ot SET f_city = NULL WHERE city = 'ka';