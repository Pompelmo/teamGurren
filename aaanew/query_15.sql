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
	c2 AS (SELECT DISTINCT R.user_id, COUNT(R.business_id) AS rev
	      FROM R_stars R
	      GROUP BY R.user_id),
	-- numero di recensioni per utente in quelli meno recensiti
	c3 AS (SELECT DISTINCT R.user_id, COUNT(R.business_id) AS revh
	      FROM R_stars R
	      WHERE R.business_id IN
	      (
		-- qua dobbiamo fare un check per vedere che prendiamo tutti quelli con la stessa recension count
		SELECT business_id
	      	FROM B_address
	      	ORDER BY review_count ASC
	      	LIMIT (SELECT (COUNT(*)/10) AS INTEGER FROM B_address)
	      )
	      GROUP BY R.user_id),
 AA AS (SELECT DISTINCT A.user_id, rev, revh
FROM c2 A JOIN c3 B ON (A.user_id = B.user_id)
WHERE B.revh >= 0.75 * A.rev)

select count (*) from AA
;
--808,001 ms
--297 rows
