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

CREATE OR REPLACE FUNCTION u_votes_f (
	vote_type char(6),
	count int,
	id char(22)
)
RETURNS void AS $$

BEGIN
	IF (vote_type = 'funny') THEN
		INSERT INTO U_votes(user_id, funny)
		VALUES (id, count);		
	END IF;
	IF (vote_type = 'useful') THEN
		update U_votes
		set useful=count
		where user_id = id;
	END IF;
	IF (vote_type = 'cool') THEN
		update U_votes
		set cool=count
		where user_id = id;
	END IF;
END
$$ LANGUAGE plpgsql;

SELECT u_votes_f(vote_type,count,user_id)
FROM t;

--CREATE TRIGGER tr
--BEFORE UPDATE ON t
--FOR EACH ROW EXECUTE PROCEDURE u_votes_f(vote_type,count,user_id);

UPDATE ON t;

drop table t;
drop function u_votes_f(
	vote_type char(6),
	count int,
	user_id char(22)
)
;
select * from u_votes limit 10;
