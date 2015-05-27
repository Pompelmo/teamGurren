CREATE temporary TABLE t (
	record_type char(8),
	business_id char(22),
	name varchar(60),
	full_adress text,
	city varchar(30),
	state char(3),
	stars real,
	review_count int,
	open boolean,
	category varchar(40)
	)
;

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-categories.csv' 
DELIMITER ',' CSV HEADER;

INSERT INTO B_stars (business_id, stars, review_count, open)
SELECT DISTINCT business_id, stars, review_count, open
FROM t
;

DROP TABLE t
;