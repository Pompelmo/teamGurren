CREATE INDEX hash_friends ON U_friends USING HASH (user_id);
with tabella as (
SELECT t1.user_id, t2.friend_id AS suggested_user_id
FROM U_friends t1 JOIN U_friends t2 ON (t1.friend_id = t2.user_id)
WHERE t2.friend_id NOT IN
       (SELECT t3.friend_id
       FROM U_friends t3
       WHERE t3.user_id = t1.user_id)
)
--25793 rows
--3545,045 ms
