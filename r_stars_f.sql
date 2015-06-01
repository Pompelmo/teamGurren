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

INSERT INTO R_stars (business_id, user_id, stars, data)
SELECT DISTINCT business_id, user_id, stars, data
FROM t
ORDER BY business_id, user_id
;


CREATE OR REPLACE FUNCTION r_stars_f (
	b_id char(22),
	u_id char(22),
	vote_type char(6),
	count int
)
RETURNS void AS $$

BEGIN
	IF (vote_type = 'funny') THEN
		update r_stars
		set funny = count
		where business_id = b_id AND user_id = u_id;		
	END IF;
	IF (vote_type = 'useful') THEN
		update r_stars
		set useful = count
		where business_id = b_id AND user_id = u_id;
	END IF;
	IF (vote_type = 'cool') THEN
		update r_stars
		set cool = count
		where business_id = b_id AND user_id = u_id;
	END IF;
END
$$ LANGUAGE plpgsql;

SELECT r_stars_f(business_id, user_id, vote_type, count)
FROM t;

--CREATE TRIGGER tr
--BEFORE UPDATE ON t
--FOR EACH ROW EXECUTE PROCEDURE u_votes_f(vote_type,count,user_id);

-- UPDATE ON t;

drop table t;
drop function r_stars_f(
	vote_type char(6),
	count int,
	user_id char(22)
)
;
select * from r_stars limit 10;
