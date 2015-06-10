SELECT a.city,c.neighborhood,max(latitude) AS max_lat,max(longitude) AS max_long,min(latitude) AS min_lat,min(longitude) AS min_long
FROM B_address a, B_coord c
WHERE a.business_id = c.business_id
GROUP BY city, neighborhood
;
