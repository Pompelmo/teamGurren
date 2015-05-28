-- ####################################### --
-- first part, using business-category.csv --
-- ####################################### --

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
ORDER BY business_id
;

INSERT INTO B_category (business_id, category)
SELECT DISTINCT business_id, category
FROM t
ORDER BY business_id
;
-- manca da mettere B_address...

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
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-neighborhoods.csv' 
DELIMITER ',' CSV HEADER;

INSERT INTO B_coord (business_id, latitude, longitude)
SELECT DISTINCT business_id, latitude, longitude
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

-- qua volevo fare la tabella come dicevo, ma in realtà non ci serve per le query
-- quindi mi sa che dobbiamo trovare un altro modo (?)

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
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/review-votes.csv' 
DELIMITER ',' CSV HEADER;

-- qua c'è da trasformare in funny useful cool
INSERT INTO R_stars (business_id, user_id, stars, data)
SELECT DISTINCT business_id, user_id, stars, data
FROM t
ORDER BY business_id, user_id
;

-- qua ho letto nella mail ci possono essere diversi testi
INSERT INTO R_text (business_id, user_id, testo)
SELECT DISTINCT business_id, user_id, testo
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
	registered_on date,--char(7),
	fans_count int,
	elite_year_count int
	)
;

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/user-profiles.csv' 
DELIMITER ',' CSV HEADER;

-- qua il registered on bisogna vedere lo prenda come data
INSERT INTO U_info (user_id, name, review_count, average_stars, registered_on)
SELECT DISTINCT user_id, name, review_count, average_stars, registered_on
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
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/user-friends.csv' 
DELIMITER ',' CSV HEADER;

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
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/user-compliments.csv' 
DELIMITER ',' CSV HEADER;

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
--FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/user-votes.csv' 
--DELIMITER ',' CSV HEADER;

-- da popolare U_votes


--DROP TABLE t
--;
