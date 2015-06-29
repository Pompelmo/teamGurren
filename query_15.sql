/*
	Query 15 - Hipster
	Trovare gli utenti che hanno scritto almeno 
	il 75% delle review per delle attività tra 
	le 10% meno recensite. [`review_count`].
	Schema risultato:
	`user_id`
*/
WITH
	-- numero di recensioni per utente
	rec_per_user AS (SELECT DISTINCT user_id, COUNT(business_id) AS revu
	      			 FROM r_stars
	                 GROUP BY user_id
					 ),
	-- percentili di recensioni per business							
	percentile AS (SELECT a, max(review_count) AS max_rev
				   FROM (
	   					 SELECT review_count,
	        			    ntile(10) OVER (ORDER BY review_count) AS a 
	   					 FROM b_address
	   					) AS tmp
				   GROUP BY a
				   ORDER BY a
				   ),
	-- contiamo quante recensioni ha fatto ogni utente per questi business con poche recensioni			
	less_rev AS (SELECT DISTINCT user_id, COUNT(business_id) AS revh
	      		 FROM r_stars
	      		 WHERE business_id IN (
									SELECT business_id
	      							FROM b_address
	      							WHERE review_count <= (SELECT max_rev FROM percentile WHERE a = 1)
	      						)
	      		 GROUP BY user_id)	
	-- selezioniamo gli Hipster
 	SELECT DISTINCT A.user_id 
	FROM rec_per_user A JOIN less_rev B ON (A.user_id = B.user_id)
	WHERE B.revh >= 0.75 * A.revu
;
