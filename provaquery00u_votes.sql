-- QUERY 00 per user_votes(record_type,user_id,name,vote_type,count)

WITH c_name AS ( SELECT column_name AS c
				 FROM information_schema.columns
			 	 WHERE table_name = 'u_votes' AND column_name <> 'user_id'
			    ),
	 u_names AS ( SELECT user_id, name
				  FROM u_info NATURAL JOIN u_votes	
				),
	 u_final AS ( (SELECT user_id, name, c AS vote_types, funny AS count
				   FROM c_name, u_names NATURAL JOIN u_votes
			  	   WHERE c = 'funny'
			      )	
					UNION
				  ( SELECT user_id, name, c AS vote_types, useful AS count
					FROM c_name, u_names NATURAL JOIN u_votes
					WHERE c = 'useful'	
				  )
					UNION
				  ( SELECT user_id, name, c AS vote_types, cool AS count
	 			    FROM c_name, u_names NATURAL JOIN u_votes
					WHERE c = 'cool'
					)
				  )		
	
SELECT *
FROM u_final
ORDER BY user_id
LIMIT 20
;