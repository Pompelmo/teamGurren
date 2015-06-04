/*
		QUERY 00 - Sanity Check
*/

-- ########################################## --
-- First part, recreate business-category.csv --
-- ########################################## --

-- ################################################ --
-- Second part, recreate business-neighborhoods.csv --
-- ################################################ --

-- ########################################### --
-- Third part, recreate business-openhours.csv --
-- ########################################### --
WITH c_name AS ( SELECT column_name AS c
				 FROM information_schema.columns
			 	 WHERE table_name = 'b_opens' AND column_name <> 'business_id'
			    ),
	 b_add  AS ( SELECT business_openhours_type, a.business_id, name, 
							full_address, city, state, open::boolean::text
				  FROM b_address a JOIN b_coord c ON (a.business_id = c.business_id), record_type
				  ORDER BY business_id	
				),
	 b_final AS ( (SELECT a.*, n.c AS day, o.monday AS opens, c.monday AS closes
				   FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
							JOIN b_closes c ON (a.business_id = c.business_id), c_name n
			  	   WHERE n.c = 'monday' AND o.monday IS NOT NULL
			      )	
					UNION
				  (SELECT a.*, n.c AS day, o.tuesday AS opens, c.tuesday AS closes
				   FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
							JOIN b_closes c ON (a.business_id = c.business_id), c_name n
				   WHERE n.c = 'tuesday' AND o.tuesday IS NOT NULL
				   )
					UNION
				  (SELECT a.*, n.c AS day, o.wednesday AS opens, c.wednesday AS closes
				   FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
							JOIN b_closes c ON (a.business_id = c.business_id), c_name n
				   WHERE n.c = 'wednesday' AND o.wednesday IS NOT NULL
				   )
					UNION
				  (SELECT a.*, n.c AS day, o.thursday AS opens, c.thursday AS closes
				   FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
							JOIN b_closes c ON (a.business_id = c.business_id), c_name n
				   WHERE n.c = 'thursday' AND o.thursday IS NOT NULL
				   )
					UNION
				  (SELECT a.*, n.c AS day, o.friday AS opens, c.friday AS closes
				   FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
							JOIN b_closes c ON (a.business_id = c.business_id), c_name n
				   WHERE n.c = 'friday' AND o.friday IS NOT NULL
				   )	
					UNION
				  (SELECT a.*, n.c AS day, o.saturday AS opens, c.saturday AS closes
				   FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
							JOIN b_closes c ON (a.business_id = c.business_id), c_name n
				   WHERE n.c = 'saturday' AND o.saturday IS NOT NULL
				   )
						UNION
				  (SELECT a.*, n.c AS day, o.sunday AS opens, c.sunday AS closes
				   FROM (b_add a JOIN b_opens o ON (a.business_id = o.business_id))  
							JOIN b_closes c ON (a.business_id = c.business_id), c_name n
				   WHERE n.c = 'sunday' AND o.sunday IS NOT NULL
						   )
				  )		
/*
COPY (SELECT * FROM PROJECT.STUDENTI) TO '/TMP/TEST.CSV' WITH CSV;
*/
	
SELECT *
FROM b_final
ORDER BY business_id
LIMIT 10 
;



-- ###################################### --
-- Fourth part, recreate review-votes.csv --
-- ###################################### --

-- ##################################### --
-- Fifth part, recreate user-profile.csv --
-- ##################################### --

-- ##################################### --
-- Sixth part, recreate user-friends.csv --
-- ##################################### --

-- ########################################### --
-- Seventh part, recreate user-compliments.csv --
-- ########################################### --

-- ################################### --
-- Eight part, recreate user-votes.csv --
-- ################################### --
/*
WITH c_name AS ( SELECT column_name AS c
				 FROM information_schema.columns
			 	 WHERE table_name = 'u_votes' AND column_name <> 'user_id'
			    ),
	 u_names AS ( SELECT user_id, name
				  FROM u_info NATURAL JOIN u_votes	
				),
	 u_final AS ( (SELECT user_id, name, c AS vote_type, funny AS count
				   FROM c_name, u_names NATURAL JOIN u_votes
			  	   WHERE c = 'funny'
			      )	
					UNION
				  ( SELECT user_id, name, c AS vote_type, useful AS count
					FROM c_name, u_names NATURAL JOIN u_votes
					WHERE c = 'useful'	
				  )
					UNION
				  ( SELECT user_id, name, c AS vote_type, cool AS count
	 			    FROM c_name, u_names NATURAL JOIN u_votes
					WHERE c = 'cool'
					)
				  )		

COPY (SELECT * FROM PROJECT.STUDENTI) TO '/TMP/TEST.CSV' WITH CSV;

	
SELECT *
FROM u_final
ORDER BY user_id
; */