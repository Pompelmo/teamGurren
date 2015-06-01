CREATE TABLE B_address 
(
	business_id char(22) PRIMARY KEY,
	name varchar(60),
    full_address varchar(110)
--	address_1 varchar(100),
--	adress_2 varchar(10)
	)
;

CREATE TABLE B_stars
(
	business_id char(22) PRIMARY KEY,
	stars real,
	review_count int,
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
	business_id char(22) PRIMARY KEY,
	latitude double precision,
	longitude double precision,
	city varchar(30),
	state char(3)
	)
;

CREATE TABLE B_neig
(
	business_id char(22),
	neighborhood varchar(25)
	)
;

CREATE TABLE R_stars
(
	business_id char(22),
	user_id char(22),
	stars int,
	data date,
	funny int,
	useful int,
	cool int,
	PRIMARY KEY(business_id,user_id, data)
	)
;

CREATE TABLE R_text
(
	business_id char(22),
	user_id char(22),
	data date,
	testo text
	)
;

CREATE TABLE U_info
(
	user_id char(22) PRIMARY KEY,
	name varchar(25),
	review_count int,
	average_stars real,
	registered_on date
	)
;

CREATE TABLE U_elite
(
	user_id char(22) PRIMARY KEY,
	elite_year_count int
	)
;

CREATE TABLE U_fans
(
	user_id char(22) PRIMARY KEY,
	fans_count int
	)
;

CREATE TABLE U_friends
(
	user_id char(22),
	friend_id char(22),
	PRIMARY KEY (user_id, friend_id)
	)
;

CREATE TABLE U_compliments
(
	user_id char(22),
	compliment_type varchar(10),
	num_compliments_of_this_type int,
	PRIMARY KEY (user_id, compliment_type)
	)
;	

CREATE TABLE U_votes
(
	user_id char(22) PRIMARY KEY,
	funny int,
	useful int,
	cool int
	)	
;


		
