/*
		QUERY 13 - Per ogni utente, per ogni categoria di attività da lui recensita, restituire gli amici il quale voto medio per le attività della stessa categoria sia mediamente 3 o più.
`user_id` | `category` | `user_id friend` | `average review rating`
		
*/
--with tabella as(

with voto_medio AS
     (
      SELECT a.user_id AS user_id, AVG(stars) AS ast, b.category AS category
      FROM r_stars a JOIN b_category b ON (a.business_id = b.business_id)
      GROUP BY a.user_id, b.category
     )
      --INDEX mio_hash
      --ON voto_medio
      --USING hash (user_id)
SELECT u.user_id AS "user_id",
       v2.category AS "category",
       u.friend_id AS "user_id friend",
       v2.ast AS "average review rating" 
FROM voto_medio v1, voto_medio v2, u_friends u
WHERE u.friend_id = v2.user_id
      AND v1.user_id = u.user_id
      AND v2.ast >= 3
      AND v1.category = v2.category
--) select count (*) from tabella
;
