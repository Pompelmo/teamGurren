/*
		SCRIPT PER L'IMPORTAZIONE DEI DATI
*/

-- ####################################### --
-- First part, using business-category.csv --
-- Populating B_stars, B_category,		   --
-- and B_address						   --
-- ####################################### --

CREATE temporary TABLE t (
	record_type char(8),
	business_id char(22),
	name varchar(60),
	full_address varchar(110),
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

/*
INSERT INTO record_type(business_categories_type)
SELECT DISTINCT record_type
FROM t
LIMIT 1
;
*/

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
-- Populating B_coord and B_neig			     --
-- ############################################# --

CREATE temporary TABLE t (
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

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-neighborhoods.csv' 
DELIMITER ',' CSV HEADER;

/*
update record_type
set business_neighborhoods_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;
*/

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
-- Populating R_stars, B_opens,	  		    --
-- and B_closes						        --
-- ######################################## --

CREATE temporary TABLE t (
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

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-openhours.csv' 
DELIMITER ',' CSV HEADER;

/*
update record_type
set business_openhours_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;
*/

--tabella openhours da popolare

DROP TABLE t
;

-- ################################### --
-- Fourth part, using review-votes.csv --
-- Populating R_stars and R_text	   --
-- ################################### --

CREATE temporary TABLE t (
	record_type char(8),
	business_id char(22),
	user_id char(22),
	stars smallint,
	testo text,
	data date,
	vote_type char(10),
	count smallint
	)
;

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/review-votes.csv' 
DELIMITER ',' CSV HEADER;
/*
update record_type
set review_votes_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;
*/
-- ################## R_stars with function r_stars_f ################## --

SELECT COUNT(*)
FROM (SELECT DISTINCT *
	FROM t) A
;


INSERT INTO R_stars (business_id, user_id, stars, data, funny, useful, cool)
SELECT DISTINCT business_id, user_id, stars, data,
			sum(case when vote_type = 'funny' then count end) as funny,
			sum(case when vote_type = 'useful' then count end) as useful,
			sum(case when vote_type = 'cool' then count end) as cool
FROM t
GROUP BY business_id, user_id, stars, data
ORDER BY business_id, user_id
;

INSERT INTO R_text (business_id, user_id, data, testo)
SELECT DISTINCT business_id, user_id, data, testo
FROM t
ORDER BY business_id, user_id
;

DROP TABLE t
;

-- ################################## --
-- Fifth part, using user-profile.csv --
-- Populating U_info, U_elite         --
-- and U_fans		 				  --
-- ################################## --

CREATE temporary TABLE t (
	record_type char(8),
	user_id char(22),
	name varchar(25),
	review_count int,
	average_stars real,
	registered_on char(7),
	fans_count smallint,
	elite_year_count smallint
	)
;

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/user-profiles.csv' 
DELIMITER ',' CSV HEADER;

/*
update record_type
set user_profiles_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;
*/

CREATE FUNCTION registered_on_f (
	registered_on char(7)
)
RETURNS date AS $$

BEGIN
	RETURN (to_date(registered_on || '-01', 'YYYY-MM-DD'));
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

drop function registered_on_f(
	registered_on char(7)
)
;


DROP TABLE t
;

-- ################################## --
-- Sixth part, using user-friends.csv --
-- Populating U_friends				  --
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

/*
update record_type
set user_friends_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;
*/

INSERT INTO U_friends (user_id, friend_id)
SELECT DISTINCT user_id, friend_id
FROM t
ORDER BY user_id
;

DROP TABLE t
;

-- ######################################## --
-- Seventh part, using user-compliments.csv --
-- Populating U_icompliments	 		    --
-- ######################################## --

CREATE temporary TABLE t (
	record_type char(10),
	user_id char(22),
	name varchar(25),
	compliment_type varchar(10),
	num_compliments_of_this_type smallint
	)
;

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/user-compliments.csv' 
DELIMITER ',' CSV HEADER;

/*
update record_type
set user_compliments_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;
*/

INSERT INTO U_compliments (user_id, compliment_type, num_compliments_of_this_type)
SELECT DISTINCT user_id, compliment_type, num_compliments_of_this_type
FROM t
ORDER BY user_id
;

DROP TABLE t
;

-- ################################# --
-- Eighth part, using user-votes.csv --
-- Populating U_votes
-- ################################# --

CREATE temporary TABLE t (
	record_type char(20),
	user_id char(22),
	name varchar(25),
	vote_type char(6),
    count smallint
	)
;

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/user-votes.csv' 
DELIMITER ',' CSV HEADER;

INSERT INTO U_votes (user_id,funny,useful,cool)
SELECT DISTINCT user_id,
		sum(case when vote_type = 'funny' then count end) as funny,
		sum(case when vote_type = 'useful' then count end) as useful,
		sum(case when vote_type = 'cool' then count end) as cool
FROM t
GROUP BY user_id
ORDER BY user_id
;

DROP TABLE t;


