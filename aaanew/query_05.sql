/*
		QUERY 05 - eighborhood Limits
		Per ogni quartiere [`neighborhood`] di ogni città trovare la bounding box: 
		ovvero i vertici del rettangolo disegnato con le longitudini e latitudini massime 
		e minime delle attività presenti nel quartiere.
		Schema risultato:
		`city` | `neighborhood ` | `max lat` | `max long` |  `min lat` | `min long`
		
*/

SELECT a.city,
	c.neighborhood,
	max(latitude)	AS "max lat",
	max(longitude) 	AS "max long",
	min(latitude) 	AS "min lat",
	min(longitude) 	AS "min long"
FROM B_address a JOIN B_coord c ON (a.business_id = c.business_id)
WHERE a.open = true
GROUP BY city, neighborhood
;

