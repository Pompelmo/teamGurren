/*
	Query 15 - Hipster
	Trovare gli utenti che hanno scritto almeno 
	il 75% delle review per delle attività tra 
	le 10% meno recensite. [`review_count`].
	Schema risultato:
	`user_id`
*/

-- c2 --> per ogni user_id che ha recensito delle c1, numero di recensioni totali
-- c3 --> per ogni user_id che ha recensito delle c1, numero di recensioni c1
--with tabella as(
WITH reviews AS ( SELECT DISTINCT business_id, user_id, data
				  FROM r_stars	
				),
	 us_review AS (SELECT user_id, COUNT(*) AS review_count
				   FROM reviews	
			 	   GROUP BY user_id
			    ),			
	 few_rec AS ( SELECT business_id
				  FROM B_address
				  ORDER BY review_count ASC
				  LIMIT (SELECT (COUNT(*)*0.1)::integer FROM B_address)	
				 ),
	  rev_fr AS ( SELECT user_id, COUNT(*) AS review_fc
				  FROM few_rec F JOIN reviews R 
						ON (F.business_id = R.business_id)
				  GROUP BY user_id		
				)			
		SELECT DISTINCT F.user_id, F.review_fc, U.review_count
		FROM rev_fr F JOIN  us_review U ON (F.user_id = U.user_id)
		WHERE F.review_fc >= U.review_count * 0.75 AND U.review_count>2

;
