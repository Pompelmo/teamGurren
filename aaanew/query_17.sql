SELECT t1.user_id, t2.friend_id AS suggested_user_id
FROM U_friends t1,U_friends t2
WHERE t1.friend_id = t2.user_id
AND t2.friend_id NOT IN
       (SELECT t3.friend_id
       FROM U_friends t3
       WHERE t3.user_id = t1.user_id)
;
