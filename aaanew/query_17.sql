/*
		QUERY 17 - Friends Finder
		Per ogni utente trovare utenti che sono amici di amici, ma non amici.
		Schema risultato:
		`user_id` | `suggested user_id`
*/
SELECT user_id, friend_id AS suggested_user_id
FROM (
	(SELECT t1.user_id, t2.friend_id
	FROM u_friends t1 JOIN u_friends t2 ON (t1.friend_id = t2.user_id) 
	)
		EXCEPT
	((SELECT *
	  FROM u_friends) 
		UNION
	-- avoid same user_id as main user_id as suggested friend	
	 (SELECT user_id, user_id AS friend_id
	  FROM u_friends))
	) A	
;
