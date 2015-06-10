/*
		QUERY 17 - Friends Finder
*/

SELECT user_id, friend_id AS suggested_user_id
FROM (
	(SELECT t1.user_id, t2.friend_id
	FROM u_friends t1 JOIN u_friends t2 ON (t1.friend_id = t2.user_id) 
	)
		EXCEPT
	(SELECT *
	FROM u_friends) 
	) A
;
