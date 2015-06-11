/*
		QUERY 09 - Benevolent Reviewers
		restituire la lista di tutti i *benevolent reviewers*. Un utente si definisce 
		*benevolent reviewer* se ha scritto almeno 10 recensioni e se in almeno il 
		75% delle sue recensioni ha dato un voto più alto della media per 
		lo stesso esercizio  (attributo [`stars`] in `business-categories.csv`). 
		Ignorare le recensioni per attività per cui non si conosca il voto medio.
		Schema risultato:
		`user_id` | `num review user` | `num review above average`
*/

WITH user_review  AS   (SELECT user_id, COUNT(*) AS review_count
						-- to deal with reviews that have been edited
						FROM (SELECT DISTINCT business_id, user_id, data
							  FROM r_stars 
							 )  A	
						GROUP BY user_id
						HAVING COUNT(*) >= 10	
						),					
	 benev_review AS   (SELECT S.user_id, COUNT(*) AS n_b_review
						FROM b_address B JOIN r_stars S
								ON (B.business_id = S.business_id)
						WHERE S.stars > B.stars
						GROUP BY S.user_id		
						)																				
	 SELECT R.user_id AS "user_id", 
			review_count AS "num review user", 
			n_b_review AS "num review above average"
	 FROM benev_review R JOIN user_review U ON (R.user_id = U.user_id)
	 WHERE n_b_review >= review_count * 0.75
;			
	
	

	
	