-- file di prova
/*
	http://www.postgresql.org/docs/9.2/static/tablefunc.html
*/
CREATE EXTENSION tablefunc;

CREATE TABLE B_opens
(
	business_id char(22) PRIMARY KEY,
	Monday time DEFAULT NULL,
	Tuesday time DEFAULT NULL,
	Wednesday time DEFAULT NULL,
	Thursday time DEFAULT NULL,
	Friday time DEFAULT NULL,
	Saturday time DEFAULT NULL,
	Sunday time DEFAULT NULL
	)
;


CREATE temporary TABLE t (
	record_type char(10),
	business_id char(22),
	name varchar(60),
	full_adress text,
	city varchar(30),
	state char(3),
	open boolean,
	day varchar(9),
	opens time,
	closes time
	)
;

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-openhours.csv' 
DELIMITER ',' CSV HEADER;


SELECT * 
FROM crosstab('SELECT business_id, day, opens FROM t', 
			  'SELECT m FROM generate_series(1,7) m') 
			AS (business_id char(22), 
				 "Monday" time, 
				 "Tuesday" time,
				 "Wednesday" time, 
				 "Thursday" time,
				 "Friday" time, 
				 "Saturday" time, 
				 "Sunday" time) 
LIMIT 5
;								

DROP TABLE t;

























