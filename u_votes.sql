-- file di prova
-- http://www.postgresql.org/docs/9.2/static/tablefunc.html

CREATE temporary TABLE t (
	record_type char(20),
	user_id char(22),
	name varchar(25),
	vote_type char(6),
        count int
	)
;

COPY t
FROM '/home/sofia/Documenti/db/teamGurren-master/tmp/dati/user-votes.csv' 
DELIMITER ',' CSV HEADER;

CREATE TABLE U_votes
(
	user_id char(22),
	funny int,
	useful int,
	cool int
	)
;


INSERT INTO U_votes(user_id, funny, useful, cool)
SELECT * FROM crosstab(
	'select user_id, vote_type, count from t'
) as (
	user_id char(22),
        "funny" int,
        "useful" int,
	"cool" int

);

drop table t;
