-- ##################################### --
-- Sixth part, recreate user-friends.csv --
-- ##################################### --

COPY
(SELECT *
FROM	(SELECT
		record_type.user_friends_type AS record_type,
     		U_friends.user_id,U_info.name,U_friends.friend_id
	FROM U_friends,U_info,record_type
	WHERE U_friends.user_id=U_info.user_id
	) AS friends_table
ORDER BY user_id)
TO '/tmp/user-friends.csv'
CSV HEADER

;
