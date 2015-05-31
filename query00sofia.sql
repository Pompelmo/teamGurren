-- ##################################################### --
-- business-categories.csv (chiave business_id,category) --
-- ##################################################### --

CREATE temporary TABLE t (
	record_type char(8),
	business_id char(22),
	name varchar(60),
	full_address text,
	city varchar(30),
	state char(3),
	stars real,
	review_count int,
	open boolean,
	category varchar(40)
	)
;

INSERT INTO t (business_id)
SELECT DISTINCT business_id
FROM B_stars
;

UPDATE t
SET name = 
	(SELECT DISTINCT name
	FROM b_address
	WHERE business_id=t.business_id)
;

UPDATE t
SET record_type = 
	(SELECT DISTINCT business_categories_type
	FROM record_type)
;

\f ','
\a
\t
\o /home/sofia/Documenti/db/teamGurren-master/tmp/esportati/business-categories.csv
SELECT * FROM t ORDER BY business_id;
DROP TABLE t;
\o
\q

--COPY (SELECT * FROM B_STARS)
--TO '/home/sofia/Documenti/db/teamGurren-master/tmp/esportati/business-categories.csv'
--DELIMITER ',' CSV HEADER
--;

-- ############################################################ --
-- business-neighborhoods.csv (chiave business_id,neighborhood) --
-- ############################################################ --
