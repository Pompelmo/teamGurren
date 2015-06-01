/*
FILE DI PROVA

http://www.postgresql.org/docs/9.2/static/tablefunc.html

CREATE EXTENSION tablefunc;
*/

CREATE TABLE B_opens
(
	business_id char(22),
	Monday time,
	Tuesday time,
	Wednesday time,
	Thursday time,
	Friday time,
	Saturday time,
	Sunday time
	)
;

CREATE TABLE B_closes
(
	business_id char(22),
	Monday time,
	Tuesday time,
	Wednesday time,
	Thursday time,
	Friday time,
	Saturday time,
	Sunday time
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

CREATE temporary TABLE weekday
(
	day varchar(9)
	)
;
	
INSERT INTO weekday(day) VALUES('Monday'), ('Tuesday'), 
('Wednesday'), ('Thursday'), ('Friday'), ('Saturday'), ('Sunday');

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-openhours.csv' 
DELIMITER ',' CSV HEADER
;

INSERT INTO B_opens
SELECT * 
FROM crosstab('SELECT business_id, day, opens FROM t', 
			  'SELECT day FROM weekday') 
			AS (business_id char(22), 
				 "Monday" time, 
				 "Tuesday" time,
				 "Wednesday" time, 
				 "Thursday" time,
				 "Friday" time, 
				 "Saturday" time, 
				 "Sunday" time) 
ORDER BY business_id				
;

INSERT INTO B_closes
SELECT * 
FROM crosstab('SELECT business_id, day, closes FROM t', 
			  'SELECT day FROM weekday') 
			AS (business_id char(22), 
				 "Monday" time, 
				 "Tuesday" time,
				 "Wednesday" time, 
				 "Thursday" time,
				 "Friday" time, 
				 "Saturday" time, 
				 "Sunday" time) 
ORDER BY business_id				
;	

DROP TABLE weekday;
DROP TABLE t;












