
SELECT a.city AS "city", 
		c.neighborhood, AS "neighborhood"
  		max(latitude) AS "max_lat", 
		max(longitude) AS "max_long",
		min(latitude) AS "min_lat",
		min(longitude) AS "min_long"
FROM B_address a JOIN B_coord c ON (a.business_id = c.business_id)
GROUP BY city, neighborhood
;
