-- ######################################### --
-- Create function to separate address parts --
-- ######################################### --

--CREATE FUNCTION separate_address (
--	address RECORD
--)
--RETURNS void AS $$

--DECLARE
--	_address_1 RECORD,
--	_address_2 RECORD,
--	part text;

--DECLARE percorso varchar(100):= "/home/sofia/Documenti/db/teamGurren-master";

--BEGIN
--	foreach part in string_to_array
--	INSERT INTO B_address (address_1, address_2)
--        VALUES (_address_1,_address_1);
--END;
--$$ LANGUAGE plpgsql;


-- ####################################### --
-- first part, using business-category.csv --
-- ####################################### --

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

COPY t
FROM '/home/sofia/Documenti/db/teamGurren-master/tmp/dati/business-categories.csv' 
DELIMITER ',' CSV HEADER;

INSERT INTO record_type(business_categories_type)
SELECT DISTINCT record_type
FROM t
LIMIT 1
;

INSERT INTO B_stars (business_id, stars, review_count, open)
SELECT DISTINCT business_id, stars, review_count, open
FROM t
ORDER BY business_id
;

INSERT INTO B_category (business_id, category)
SELECT DISTINCT business_id, category
FROM t
ORDER BY business_id
;

INSERT INTO B_address (business_id, name, full_address)
SELECT DISTINCT business_id, name, full_address
FROM t
ORDER BY business_id
;

DROP TABLE t
;

-- ############################################# --
-- Second part, using business-neighborhoods.csv --
-- ############################################# --

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

COPY t
FROM '/home/sofia/Documenti/db/teamGurren-master/tmp/dati/business-neighborhoods.csv' 
DELIMITER ',' CSV HEADER;

update record_type
set business_neighborhoods_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;

--INSERT INTO record_type(business_neighborhoods_type)
--SELECT DISTINCT record_type
--FROM t
--LIMIT 1
--;

INSERT INTO B_coord (business_id, latitude, longitude, city, state)
SELECT DISTINCT business_id, latitude, longitude, city, state
FROM t
ORDER BY business_id
;

INSERT INTO B_neig (business_id, neighborhood)
SELECT business_id, neighborhood
FROM t
ORDER BY business_id
;


DROP TABLE t
;

-- ######################################## --
-- Third part, using business-openhours.csv --
-- ######################################## --

CREATE temporary TABLE t (
	record_type char(10),
	business_id char(22),
	name varchar(60),
	full_address text,
	city varchar(30),
	state char(3),
	open boolean,
	day char(9),
	opens time,  --funziona?
	closes time --funziona?
	)
;

COPY t
FROM '/home/sofia/Documenti/db/teamGurren-master/tmp/dati/business-openhours.csv' 
DELIMITER ',' CSV HEADER;

update record_type
set business_openhours_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;

--INSERT INTO record_type(business_openhours_type)
--SELECT DISTINCT record_type
--FROM t
--LIMIT 1
--;

INSERT INTO R_stars (business_id, user_id, stars, data)
SELECT DISTINCT business_id, user_id, stars, data
FROM t
ORDER BY business_id, user_id
;

--tabella openhours da popolare

DROP TABLE t
;

-- ################################### --
-- Fourth part, using review-votes.csv --
-- ################################### --

CREATE temporary TABLE t (
	record_type char(8),
	business_id char(22),
	user_id char(22),
	stars int,
	testo text,
	data date,
	vote_type char(10),
	count int
	)
;

COPY t
FROM '/home/sofia/Documenti/db/teamGurren-master/tmp/dati/review-votes.csv' 
DELIMITER ',' CSV HEADER;

update record_type
set review_votes_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;

--INSERT INTO record_type(review_votes_type)
--SELECT DISTINCT record_type
--FROM t
--LIMIT 1
--;

-- qua c'è da trasformare in funny useful cool
INSERT INTO R_stars (business_id, user_id, stars, data)
SELECT DISTINCT business_id, user_id, stars, data
FROM t
ORDER BY business_id, user_id
;

-- qua ho letto nella mail ci possono essere diversi testi -> cambiare primary key?
INSERT INTO R_text (business_id, user_id, data, testo)
SELECT DISTINCT business_id, user_id, data, testo
FROM t
ORDER BY business_id, user_id
;

--INSERT INTO R_type (user_id)
--SELECT
--FROM t
--ORDER BY user_id
--;
-- da fare una procedura

DROP TABLE t
;

-- ################################## --
-- Fifth part, using user-profile.csv --
-- ################################## --

CREATE temporary TABLE t (
	record_type char(8),
	user_id char(22),
	name varchar(25),
	review_count int,
	average_stars real,
	registered_on char(7),
	fans_count int,
	elite_year_count int
	)
;

COPY t
FROM '/home/sofia/Documenti/db/teamGurren-master/tmp/dati/user-profiles.csv' 
DELIMITER ',' CSV HEADER;

update record_type
set user_profiles_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;

--INSERT INTO record_type(user_profiles_type)
--SELECT DISTINCT record_type
--FROM t
--LIMIT 1
--;

CREATE FUNCTION registered_on_f (
	registered_on char(7)
)
RETURNS date AS $$

BEGIN
	RETURN (to_date(registered_on || '-02', 'YYYY-MM-DD'));
END;
$$ LANGUAGE plpgsql;

INSERT INTO U_info (user_id, name, review_count, average_stars, registered_on)
SELECT DISTINCT user_id, name, review_count, average_stars, registered_on_f(registered_on)
FROM t
ORDER BY user_id
;

INSERT INTO U_elite (user_id, elite_year_count)
SELECT user_id, elite_year_count
FROM t
WHERE elite_year_count > 0
ORDER BY user_id
;

INSERT INTO U_fans (user_id, fans_count)
SELECT user_id, fans_count
FROM t
WHERE fans_count > 0
ORDER BY user_id
;

DROP TABLE t
;

-- ################################## --
-- Sixth part, using user-friends.csv --
-- ################################## --

CREATE temporary TABLE t (
	record_type char(8),
	user_id char(22),
	name varchar(25),
	friend_id char(22)
	)
;

COPY t
FROM '/home/sofia/Documenti/db/teamGurren-master/tmp/dati/user-friends.csv' 
DELIMITER ',' CSV HEADER;

update record_type
set user_friends_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;

--INSERT INTO record_type(user_friends_type)
--SELECT DISTINCT record_type
--FROM t
--LIMIT 1
--;

INSERT INTO U_friends (user_id, friend_id)
SELECT DISTINCT user_id, friend_id
FROM t
ORDER BY user_id
;

DROP TABLE t
;

-- #################################### --
-- Seventh part, using user-compliments.csv --
-- #################################### --

CREATE temporary TABLE t (
	record_type char(10),
	user_id char(22),
	name varchar(25),
	compliment_type varchar(10),
	num_compliments_of_this_type int
	)
;

COPY t
FROM '/home/sofia/Documenti/db/teamGurren-master/tmp/dati/user-compliments.csv' 
DELIMITER ',' CSV HEADER;

update record_type
set user_compliments_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;

--INSERT INTO record_type(user_compliments_type)
--SELECT DISTINCT record_type
--FROM t
--LIMIT 1
--;

INSERT INTO U_compliments (user_id, compliment_type, num_compliments_of_this_type)
SELECT DISTINCT user_id, compliment_type, num_compliments_of_this_type
FROM t
ORDER BY user_id
;

DROP TABLE t
;

-- ################################# --
-- Eighth part, using user-votes.csv --
-- ################################# --

--CREATE temporary TABLE t (
--	record_type char(8),
--	user_id char(22),
--	name varchar(25),
--	vote_type
--	count
--	)
--;

--COPY t
--FROM '/home/sofia/Documenti/db/teamGurren-master/tmp/dati/user-votes.csv' 
--DELIMITER ',' CSV HEADER;

--update record_type
--set user_votes_type = 
--	(SELECT DISTINCT record_type
--	FROM t
--	LIMIT 1)
--;

----INSERT INTO record_type(user_votes_type)
----SELECT DISTINCT record_type
----FROM t
----LIMIT 1
----;

-- da popolare U_votes


--DROP TABLE t
--;
