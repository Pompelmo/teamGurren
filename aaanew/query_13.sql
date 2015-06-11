/*
	Query 13 - Hipster
	**Good taste**: Per ogni utente, per ogni categoria di attività da lui recensita, 
	restituire gli amici il quale voto medio per 
	le attività della stessa categoria sia mediamente 3 o più.
	Schema risultato:
	`user_id` | `category` | `user_id friend` | `average review rating`
*/

WITH rev_category AS (SELECT user_id, B.category, AVG(R.stars) AS mstars
					  FROM b_category B JOIN r_stars R ON (B.business_id = R.business_id)
					  GROUP BY user_id, category
					 )
	 SELECT DISTINCT A1.user_id, A1.category, friend_id, A2.mstars AS average_review_rating
	 FROM (rev_category A1 JOIN u_friends F ON (A1.user_id = F.user_id)) JOIN 
			rev_category A2 ON (F.friend_id = A2.user_id AND A1.category = A2.category)
	 WHERE A2.mstars >= 3
	 ORDER BY A1.user_id	
;

