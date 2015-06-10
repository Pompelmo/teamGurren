/*
		QUERY 09 - Benevolent Reviewers
*/

WITH business_stars AS (SELECT business_id, stars
						FROM b_address
						),
	 stars			AS	(SELECT DISTINCT business_id, user_id, data, stars
						FROM r_stars 
						),										
	 user_review  AS   (SELECT user_id, count(*) AS review_count
						-- to deal with reviews that have been edited
						FROM (SELECT DISTINCT business_id, user_id, data
							  FROM stars 
							 )  A	
						GROUP BY user_id
						HAVING count(*) >= 10	
						),					
	 benev_review AS   (SELECT S.user_id, count(*) AS n_b_review
						FROM business_stars B JOIN stars S
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
	
	

	
	