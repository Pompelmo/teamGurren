-- c2 --> per ogni user_id che ha recensito delle c1, numero di recensioni totali
-- c3 --> per ogni user_id che ha recensito delle c1, numero di recensioni c1
with tabella as(
WITH	
	c2 AS (SELECT DISTINCT R.user_id, COUNT(R.business_id)
	      FROM R_stars R
	      GROUP BY R.user_id),
	c3 AS (SELECT DISTINCT R.user_id, COUNT(R.business_id)
	      FROM R_stars R
	      WHERE R.business_id IN
	      (
		SELECT business_id
	      	FROM B_address
	      	ORDER BY review_count ASC
	      	LIMIT (SELECT (COUNT(*)/10) AS INTEGER FROM B_address)
	      )
	      GROUP BY R.user_id)
SELECT DISTINCT c2.user_id
FROM c2,c3
WHERE c3.count = 0.75*c2.count
)select count (*) from tabella
;
--808,001 ms
--297 rows
