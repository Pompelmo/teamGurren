-- ##################################################### --
-- business-categories.csv (chiave business_id,category) --
-- ##################################################### 

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

WITH t1 AS
(SELECT
B_category.business_id,B_category.category,
B_address.name,B_address.full_address,B_address.stars,B_address.review_count,B_address.open
FROM B_category,B_address
WHERE B_category.business_id = B_address.business_id
)
INSERT INTO t (business_id,category,name,full_address,stars,review_count,open)
SELECT DISTINCT
business_id,category,name,full_address,stars,review_count,open
FROM t1
;

UPDATE t
SET city = 
	(SELECT DISTINCT city
	FROM b_coord
	WHERE business_id=t.business_id),
    state =
	(SELECT DISTINCT state
	FROM b_coord
	WHERE business_id=t.business_id)
;

UPDATE t
SET record_type = 
	(SELECT DISTINCT business_categories_type
	FROM record_type)
;

COPY (SELECT * FROM t ORDER BY business_id)
TO '/home/sofia/Documenti/db/teamGurren-master/tmp/esportati/business-categories.csv'
CSV HEADER;
DROP TABLE t;

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
