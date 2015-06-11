/*
		QUERY 00 - Sanity Check
*/

-- ########################################## --
-- First part, recreate business-category.csv --
-- ########################################## --
COPY (
	SELECT r.business_categories_type AS record_type, a.business_id, a.name, 
			a.full_address, a.city, a.state, to_char(a.stars,'FM9.0') AS stars, a.review_count,
	 		initcap(a.open::boolean::varchar(5)) AS open, c.category
	FROM b_address a NATURAL JOIN b_category c, record_type r
	ORDER BY a.business_id
	)
TO '/tmp/output/business-categories.csv'
WITH (FORMAT CSV, HEADER TRUE, FORCE_QUOTE(name, full_address, category)) 
;
	
-- ################################################ --
-- Second part, recreate business-neighborhoods.csv --
-- ################################################ --

COPY (
	SELECT r.business_neighborhoods_type AS record_type, a.business_id, a.name, 
			a.city, a.state, c.latitude, c.longitude, c.neighborhood
	FROM b_address a NATURAL JOIN b_coord c, record_type r
	ORDER BY a.business_id
	)
TO '/tmp/output/business-neighborhoods.csv'
WITH (FORMAT CSV, HEADER TRUE, FORCE_QUOTE(name, city, neighborhood)) 
;

-- ########################################### --
-- Third part, recreate business-openhours.csv --
-- ########################################### --
COPY (
WITH c_name AS ( SELECT column_name AS c
				 FROM information_schema.columns
			 	 WHERE table_name = 'b_opens' AND column_name <> 'business_id'
			    ),
	 b_add  AS ( SELECT business_openhours_type AS record_type, a.business_id, name, 
						full_address, city, state, initcap(open::boolean::varchar(5)) AS open
				  FROM b_address a, record_type
				  ORDER BY business_id	
				)
	SELECT *			
	FROM ( (SELECT a.*, initcap(n.c) AS day, to_char(o.monday,'HH24:MI') AS opens, to_char(c.monday,'HH24:MI') AS closes
			FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
				JOIN b_closes c ON (a.business_id = c.business_id), c_name n
			WHERE n.c = 'monday' AND o.monday IS NOT NULL
			)	
				UNION
			(SELECT a.*, initcap(n.c) AS day, to_char(o.tuesday,'HH24:MI') AS opens, to_char(c.tuesday,'HH24:MI') AS closes
			 FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
				JOIN b_closes c ON (a.business_id = c.business_id), c_name n
  		     WHERE n.c = 'tuesday' AND o.tuesday IS NOT NULL
			)
				UNION
			(SELECT a.*, initcap(n.c) AS day, to_char(o.wednesday,'HH24:MI') AS opens, to_char(c.wednesday,'HH24:MI') AS closes
	 	     FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
				JOIN b_closes c ON (a.business_id = c.business_id), c_name n
			 WHERE n.c = 'wednesday' AND o.wednesday IS NOT NULL
			)
				UNION
			(SELECT a.*, initcap(n.c) AS day, to_char(o.thursday,'HH24:MI') AS opens, to_char(c.thursday,'HH24:MI') AS closes
			 FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
				JOIN b_closes c ON (a.business_id = c.business_id), c_name n
	 	     WHERE n.c = 'thursday' AND o.thursday IS NOT NULL
			)
				UNION
			(SELECT a.*, initcap(n.c) AS day, to_char(o.friday,'HH24:MI') AS opens, to_char(c.friday,'HH24:MI') AS closes
			 FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
				JOIN b_closes c ON (a.business_id = c.business_id), c_name n
			 WHERE n.c = 'friday' AND o.friday IS NOT NULL
			)	
				UNION
			(SELECT a.*, initcap(n.c) AS day, to_char(o.saturday,'HH24:MI') AS opens, to_char(c.saturday,'HH24:MI') AS closes
			 FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
				JOIN b_closes c ON (a.business_id = c.business_id), c_name n
			 WHERE n.c = 'saturday' AND o.saturday IS NOT NULL
			)
				UNION
			(SELECT a.*, initcap(n.c) AS day, to_char(o.sunday,'HH24:MI') AS opens, to_char(c.sunday,'HH24:MI') AS closes
			 FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
				JOIN b_closes c ON (a.business_id = c.business_id), c_name n
			 WHERE n.c = 'sunday' AND o.sunday IS NOT NULL
			)
		) A 
		ORDER BY business_id		
)				
TO '/tmp/output/business-openhours.csv' 
WITH (FORMAT CSV, HEADER TRUE, FORCE_QUOTE(name, full_address)) 
;

-- ###################################### --
-- Fourth part, recreate review-votes.csv --
-- ###################################### --

-- ##################################### --
-- Fifth part, recreate user-profile.csv --
-- ##################################### --
COPY ( SELECT user_profiles_type AS record_type, user_id, name,
			review_count, to_char(average_stars,'FM9.09') AS average_stars,
			to_char(registered_on,'YYYY-MM') AS registered_on, fans_count, elite_years_count
	   FROM u_info, record_type
	   ORDER BY user_id
)
TO '/tmp/output/user-profiles.csv'
WITH (FORMAT CSV, HEADER TRUE, FORCE_QUOTE(name))
;

-- ##################################### --
-- Sixth part, recreate user-friends.csv --
-- ##################################### --

-- ########################################### --
-- Seventh part, recreate user-compliments.csv --
-- ########################################### --

-- ################################### --
-- Eight part, recreate user-votes.csv --
-- ################################### --
COPY (
WITH c_name AS ( SELECT column_name AS c
				 FROM information_schema.columns
			 	 WHERE table_name = 'u_votes' AND column_name <> 'user_id'
			    ),
	 u_names AS ( SELECT user_votes_type AS record_type, user_id, name
				  FROM u_info NATURAL JOIN u_votes, record_type	
				)
	 SELECT *
	 FROM ( (SELECT record_type, user_id, name, c AS vote_type, funny AS count
			 FROM c_name, u_names NATURAL JOIN u_votes
			 WHERE c = 'funny'
			 )	
				UNION
		   ( SELECT record_type, user_id, name, c AS vote_type, useful AS count
			 FROM c_name, u_names NATURAL JOIN u_votes
			 WHERE c = 'useful'	
			 )
				UNION
		   ( SELECT record_type, user_id, name, c AS vote_type, cool AS count
	 	  	 FROM c_name, u_names NATURAL JOIN u_votes
			 WHERE c = 'cool'
			 ) ) A
	  ORDER BY user_id	
)								
TO '/tmp/output/user-votes.csv' 
WITH (FORMAT CSV, HEADER TRUE) 
; 