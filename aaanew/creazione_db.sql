CREATE TABLE b_address 
(
	business_id char(22),
	name varchar(60),
    full_address text,
	city varchar(25),
	state varchar(3),
	stars real,
	review_count smallint,
	open boolean
	)
;

CREATE TABLE b_category
(
	business_id char(22),
	category varchar(40)
	)
;

CREATE TABLE b_coord
(
	business_id char(22),
	latitude double precision,
	longitude double precision,
	neighborhood varchar(25)
	)
;

CREATE TABLE b_opens
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

CREATE TABLE b_closes
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

CREATE TABLE r_stars
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

CREATE TABLE u_info
(
	user_id char(22),
	name varchar(25),
	review_count smallint,
	average_stars real,
	registered_on date,
	fans_count smallint,
	elite_years_count smallint
	)
;

CREATE TABLE u_friends
(
	user_id char(22),
	friend_id char(22)
	)
;

CREATE TABLE u_compliments
(
	user_id char(22),
	compliment_type varchar(10),
	num_compliments_of_this_type smallint
	)
;	

CREATE TABLE u_votes
(
	user_id char(22),
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
	user_friends_type char(6),
	user_votes_type char(9)	
	)
;	