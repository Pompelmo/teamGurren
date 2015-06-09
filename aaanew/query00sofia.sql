-- ##################################################### --
-- business-categories.csv (chiave business_id,category) --
-- ##################################################### 

CREATE temporary TABLE t (
	record_type char(8),
	business_id char(22),
	name varchar(60),
	full_address text,
	city varchar(30),
	state varchar(3),
	stars real,
	review_count int,
	open varchar(5),
	category varchar(40)
	)
;

WITH t1 AS
(SELECT
a.business_id,c.category,
a.name,a.full_address,a.city, a.state,a.stars,a.review_count,a.open::boolean::varchar(5)
FROM B_category c,B_address a
WHERE c.business_id = a.business_id
)
INSERT INTO t (business_id,category,name,full_address,city, state,stars,review_count,open)
SELECT DISTINCT
business_id,category,name,full_address,city, state,stars,review_count,open
FROM t1
;

UPDATE t
SET record_type = 
	(SELECT DISTINCT business_categories_type
	FROM record_type)
;

COPY (SELECT * FROM t ORDER BY business_id)
TO '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-categories00.csv'
CSV HEADER;
DROP TABLE t;
/*
--\f ','
--\a
--\t
--\o /home/sofia/Documenti/db/teamGurren-master/tmp/esportati/business-categories.csv
--SELECT *
--FROM t
--ORDER BY business_id;
--DROP TABLE t;
--\o

-- ############################################################ --
-- business-neighborhoods.csv (chiave business_id,neighborhood) --
-- ############################################################ --

CREATE temporary TABLE t (
	record_type char(8),
	business_id char(22),
	name varchar(60),
	city varchar(30),
	state char(3),
	latitude double precision,
	longitude double precision,
	neighborhood varchar(25)
	)
;

WITH t1 AS
(SELECT
B_coord.business_id,B_address.name,B_coord.neighborhood,
B_coord.city,B_coord.state,B_coord.latitude,B_coord.longitude
FROM B_coord,B_address
WHERE B_coord.business_id = B_address.business_id
)
INSERT INTO t (business_id,name,neighborhood,city,state,latitude,longitude)
SELECT DISTINCT business_id,name,neighborhood,city,state,latitude,longitude
FROM t1
;

---i--------------------------------------
INSERT INTO t(business_id,name,city,state,latitude,longitude,neighborhood)
SELECT DISTINCT eccezioni.business_id,eccezioni.name,eccezioni.city,eccezioni.state,eccezioni.latitude,eccezioni.longitude,eccezioni.neighborhood
FROM eccezioni
ORDER BY business_id
;
---f--------------------------------------

UPDATE t
SET record_type = 
	(SELECT DISTINCT business_neighborhoods_type
	FROM record_type)
;

COPY (SELECT * FROM t ORDER BY business_id)
TO '/home/sofia/Documenti/db/teamGurren-master/tmp/esportati/business-neighborhoods.csv'
CSV HEADER;
--DROP TABLE t;
CREATE temporary TABLE t2 (
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

COPY t2
FROM '/home/sofia/Documenti/db/teamGurren-master/tmp/dati/business-neighborhoods.csv' 
DELIMITER ',' CSV HEADER;
SELECT *
FROM t2
WHERE t2.business_id
NOT IN (
	SELECT business_id
	FROM t)
;

--\f ','
--\a
--\t
--\o /home/sofia/Documenti/db/teamGurren-master/tmp/esportati/business-neighborhoods.csv
--SELECT *
--FROM t
--ORDER BY business_id;
--DROP TABLE t;
--\o
--\q
*/