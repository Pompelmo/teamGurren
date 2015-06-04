CREATE TABLE B_address 
(
	business_id char(22) PRIMARY KEY,
	name varchar(60),
    full_address varchar(110),
	stars real,
	review_count smallint,
	open boolean
	)
;

CREATE TABLE B_category
(
	business_id char(22),
	category varchar(40),
	PRIMARY KEY (business_id,category)
	)
;

CREATE TABLE B_coord
(
	business_id char(22),
	latitude double precision,
	longitude double precision,
	city varchar(25),
	state char(3),
	neighborhood varchar(25),
	PRIMARY KEY (business_id, neighborhood)
	)
;

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

CREATE TABLE R_stars
(
	business_id char(22),
	user_id char(22),
	stars smallint,
	data date,
	testo text,	
	funny smallint,
	useful smallint,
	cool smallint
	)
;

CREATE TABLE U_info
(
	user_id char(22) PRIMARY KEY,
	name varchar(25),
	review_count smallint,
	average_stars real,
	registered_on date,
	fans_count smallint,
	elite_year_count smallint
	)
;

CREATE TABLE U_friends
(
	user_id char(22),
	friend_id char(22)
	)
;

CREATE TABLE U_compliments
(
	user_id char(22),
	compliment_type varchar(10),
	num_compliments_of_this_type smallint,
	PRIMARY KEY (user_id, compliment_type)
	)
;	

CREATE TABLE U_votes
(
	user_id char(22) PRIMARY KEY,
	funny smallint,
	useful smallint,
	cool smallint
	)	
;

CREATE TABLE record_type
(
	review_votes_type char(6),
	business_categories_type char(8),
	business_neighborhoods_type char(8),
	business_openhours_type char(10),
	user_profiles_type char(4),
	user_compliments_type char(10),
	user_friends_type char(8),
	user_votes_type char(9)	
	)
;	