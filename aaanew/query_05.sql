SELECT
	a.city,
	c.neighborhood,
	max(latitude)	AS "max lat",
	max(longitude) 	AS "max long",
	min(latitude) 	AS "min lat",
	min(longitude) 	AS "min long"
FROM B_address a JOIN B_coord c ON (a.business_id = c.business_id)
WHERE a.open = true
GROUP BY city, neighborhood
;
--2,372 ms
--69 rows
