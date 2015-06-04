/*
		SCRIPT PER L'IMPORTAZIONE DEI DATI
*/

--########################################################################################--
-- First part. Using more than one temp_table since there are different set of business_id
-- for every csv.
--#########################################################################################--

CREATE temporary TABLE t (
	record_type char(8),
	business_id char(22),
	name varchar(60),
	full_address text,
	city varchar(25),
	state char(3),
	stars real,
	review_count smallint,
	open boolean,
	category varchar(40)
	)
;

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-categories.csv' 
DELIMITER ',' CSV HEADER;

CREATE temporary TABLE s (
	record_type char(8),
	business_id char(22),
	name varchar(60),
	city varchar(25),
	state char(3),
	latitude double precision,
	longitude double precision,
	neighborhood varchar(25)
	)
;

COPY s
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-neighborhoods.csv' 
DELIMITER ',' CSV HEADER;

CREATE temporary TABLE p (
	record_type char(10),
	business_id char(22),
	name varchar(60),
	full_address text,
	city varchar(25),
	state char(3),
	open boolean,
	day char(9),
	opens time,  
	closes time
	)
;

COPY p
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-openhours.csv' 
DELIMITER ',' CSV HEADER;


SELECT COUNT(*)
FROM ( SELECT DISTINCT business_id FROM s) a
;

SELECT COUNT(*)
FROM ( SELECT DISTINCT business_id FROM t) a
;

SELECT COUNT(*)
FROM ( SELECT DISTINCT business_id FROM p) a
;

SELECT COUNT(*)
FROM ( (SELECT DISTINCT business_id FROM s)
		UNION
		(SELECT DISTINCT business_id FROM t)
		UNION
		(SELECT DISTINCT business_id FROM p)) a
;

SELECT DISTINCT business_id
FROM s
WHERE business_id NOT IN (SELECT business_id
							FROM t)
;								

	

DROP TABLE t
;

DROP TABLE s
;

DROP TABLE p
;
