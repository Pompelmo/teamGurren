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
	state varchar(3),
	stars real,
	review_count smallint,
	open boolean,
	category varchar(40)
	)
;

COPY t
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-categories.csv' 
DELIMITER ',' CSV HEADER;


INSERT INTO record_type(business_categories_type)
SELECT DISTINCT record_type
FROM t
LIMIT 1
;

CREATE temporary TABLE s (
	record_type char(8),
	business_id char(22),
	name varchar(60),
	city varchar(25),
	state varchar(3),
	latitude double precision,
	longitude double precision,
	neighborhood varchar(25)
	)
;

COPY s
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-neighborhoods.csv' 
DELIMITER ',' CSV HEADER;

update record_type
set business_neighborhoods_type = 
	(SELECT DISTINCT record_type
	FROM s
	LIMIT 1)
;

CREATE temporary TABLE p (
	record_type char(10),
	business_id char(22),
	name varchar(60),
	full_address text,
	city varchar(25),
	state varchar(3),
	open boolean,
	day char(9),
	opens time,  
	closes time
	)
;

COPY p
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/business-openhours.csv' 
DELIMITER ',' CSV HEADER;

update record_type
set business_openhours_type = 
	(SELECT DISTINCT record_type
	FROM p
	LIMIT 1)
;
--SELECT COUNT(*) FROM (select distinct business_id from p) A;
CREATE temporary TABLE q (
	business_id char(22),
	name varchar(60),
	full_address text,
	city varchar(25),
	state varchar(3)
	)
;	

INSERT INTO q
SELECT *
FROM ( (SELECT business_id, name, full_address, city, state
		FROM t)
			UNION
	   (SELECT business_id, name, full_address, city, state
		FROM p)	
	 ) a
;

CREATE temporary TABLE r (
	business_id char(22),
	name varchar(60),
	city varchar(25),
	state varchar(3)
	)
;	

INSERT INTO r
SELECT *
FROM ( (SELECT business_id, name, city, state
		FROM t)
			UNION
	   (SELECT business_id, name, city, state
		FROM s)	
			UNION
	   (SELECT business_id, name, city, state
		FROM p)	 
	 ) a
;
/*   da modificare: così b_coord viene con tanti spazi vuoti. verificare cosa conviene fare.
        			 * tornare ad avere uno con l'intero indirizzo, 1 review count e 1 coord
					 * mettere tutto in B_address (con i 5 stronzi che sono solo su B_coord)
					 * lasciare così.
					 farò i conti domani perché ora ho sonno, buenas noche :)
*/
INSERT INTO B_address (business_id, name, full_address, city, state, stars, review_count, open)
SELECT DISTINCT r.business_id, r.name, q.full_address, r.city, r.state,
 				t.stars, t.review_count, t.open
FROM (r r LEFT OUTER JOIN q q ON (r.business_id = q.business_id)) 
	LEFT OUTER JOIN t t ON (q.business_id = t.business_id) 
--ORDER BY business_id
;

INSERT INTO B_category (business_id, category)
SELECT DISTINCT business_id, category
FROM t
--ORDER BY business_id
;

INSERT INTO B_coord (business_id, latitude, longitude, neighborhood)
SELECT DISTINCT business_id, latitude, longitude, neighborhood
FROM s
--ORDER BY business_id
;


INSERT INTO B_opens (business_id, Monday, Tuesday, Wednesday, Thursday,
						Friday, Saturday, Sunday)
SELECT DISTINCT business_id,
		sum(case when day = 'Monday' then opens end) as Monday,
		sum(case when day = 'Tuesday' then opens end) as Tuesday,
		sum(case when day = 'Wednesday' then opens end) as Wednesday,
		sum(case when day = 'Thursday' then opens end) as Thursday,
		sum(case when day = 'Friday' then opens end) as Friday,
		sum(case when day = 'Saturday' then opens end) as Saturday,
		sum(case when day = 'Sunday' then opens end) as Sunday
FROM p
GROUP BY business_id
--ORDER BY business_id
;

INSERT INTO B_closes (business_id, Monday, Tuesday, Wednesday, Thursday,
						Friday, Saturday, Sunday)
SELECT DISTINCT business_id,
		sum(case when day = 'Monday' then closes end) as Monday,
		sum(case when day = 'Tuesday' then closes end) as Tuesday,
		sum(case when day = 'Wednesday' then closes end) as Wednesday,
		sum(case when day = 'Thursday' then closes end) as Thursday,
		sum(case when day = 'Friday' then closes end) as Friday,
		sum(case when day = 'Saturday' then closes end) as Saturday,
		sum(case when day = 'Sunday' then closes end) as Sunday
FROM p
GROUP BY business_id
--ORDER BY business_id
;

DROP TABLE t
;

DROP TABLE s
;

DROP TABLE p
;

DROP TABLE q
;

DROP TABLE r
;

--########################################################################################--
-- Second part. Here I need just one temp table.
--########################################################################################--

CREATE temporary TABLE t (
	record_type char(6),
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

update record_type
set review_votes_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;

INSERT INTO R_stars (business_id, user_id, stars, data, testo, funny, useful, cool)
SELECT DISTINCT business_id, user_id, stars, data, testo,
			sum(case when vote_type = 'funny' then count end) as funny,
			sum(case when vote_type = 'useful' then count end) as useful,
			sum(case when vote_type = 'cool' then count end) as cool
FROM t
GROUP BY business_id, user_id, stars, data, testo
--ORDER BY business_id, user_id
;

DROP TABLE t
;

--########################################################################################--
-- Third part. 
--########################################################################################--

CREATE temporary TABLE t (
	record_type char(4),
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

update record_type
set user_profiles_type = 
	(SELECT DISTINCT record_type
	FROM t
	LIMIT 1)
;

CREATE temporary TABLE s (
	record_type char(8),
	user_id char(22),
	name varchar(25),
	friend_id char(22)
	)
;

COPY s
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/user-friends.csv' 
DELIMITER ',' CSV HEADER;

update record_type
set user_friends_type = 
	(SELECT DISTINCT record_type
	FROM s
	LIMIT 1)
;

CREATE temporary TABLE p (
	record_type char(10),
	user_id char(22),
	name varchar(25),
	compliment_type varchar(10),
	num_compliments_of_this_type smallint
	)
;

COPY p
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/user-compliments.csv' 
DELIMITER ',' CSV HEADER;

update record_type
set user_compliments_type = 
	(SELECT DISTINCT record_type
	FROM p
	LIMIT 1)
;

CREATE temporary TABLE q (
	record_type char(9),
	user_id char(22),
	name varchar(25),
	vote_type char(6),
    count smallint
	)
;

COPY q
FROM '/Users/Kate/Desktop/SECONDO_SEMESTRE/BASE_DI_DATI/PROGETTO/user-votes.csv' 
DELIMITER ',' CSV HEADER;

update record_type
set user_votes_type = 
	(SELECT DISTINCT record_type
	FROM q
	LIMIT 1)
;


CREATE FUNCTION registered_on_f (
	registered_on char(7)
)
RETURNS date AS $$

BEGIN
	RETURN (to_date(registered_on || '-01', 'YYYY-MM-DD'));
END;
$$ LANGUAGE plpgsql;

CREATE temporary TABLE r (
	user_id char(22),
	name varchar(25)
	)
;	

INSERT INTO r
SELECT *
FROM ( (SELECT user_id, name
		FROM t)
			UNION
	   (SELECT user_id, name
		FROM s)	
			UNION
	   (SELECT user_id, name
		FROM p)
			UNION
   	   (SELECT user_id, name
		FROM q)	
	 ) a
;

INSERT INTO U_info (user_id, name, review_count, average_stars, registered_on, fans_count, elite_year_count)
SELECT DISTINCT r.user_id, r.name, t.review_count, t.average_stars, 
				registered_on_f(t.registered_on), t.fans_count, t.elite_year_count
FROM r r LEFT OUTER JOIN t t ON (r.user_id = t.user_id)
--ORDER BY user_id
;

INSERT INTO U_friends (user_id, friend_id)
SELECT DISTINCT user_id, friend_id
FROM s
--ORDER BY user_id
;

INSERT INTO U_compliments (user_id, compliment_type, num_compliments_of_this_type)
SELECT DISTINCT user_id, compliment_type, num_compliments_of_this_type
FROM p
--ORDER BY user_id
;

INSERT INTO U_votes (user_id, funny, useful, cool)
SELECT DISTINCT user_id,
		sum(case when vote_type = 'funny' then count end) as funny,
		sum(case when vote_type = 'useful' then count end) as useful,
		sum(case when vote_type = 'cool' then count end) as cool
FROM q
GROUP BY user_id
--ORDER BY user_id
;

DROP TABLE t
;

DROP TABLE s
;

DROP TABLE p
;

DROP TABLE q
;

DROP TABLE r
;

drop function registered_on_f(
	registered_on char(7)
)
;