-- 1st clue: You vaguely remember that the crime was a ​murder​ that occurred sometime on ​Jan.15, 2018​ and that it took place in ​SQL City​

SELECT *
FROM crime_scene_report
WHERE date = 20180115 
	AND type = 'murder'
	AND city = 'SQL City'

-- 2nd Clue: 
-- - First witness address_street_name = "Northwestern Dr", on the last house.
-- - Second witness name : Annabel, address_street_name = "Franklin Ave".

SELECT p.name, p.id, i.transcript
FROM interview as i
JOIN person as p
ON p.id = i.person_id
WHERE (p.address_street_name = 'Northwestern Dr'
       AND p.address_number = (SELECT MAX(address_number)
                               FROM person
                               WHERE address_street_name = 'Northwestern Dr'))
   OR (p.name LIKE '%Annab_l%'
       AND p.address_street_name = 'Franklin Ave');

-- 3rd Clue: 
-- - Membership: %48Z% 
-- - type: gold
-- - driver licence plate_number: ...H42W...
-- - check in 9th Jan 2018

WITH suspect AS(
	SELECT a.person_id, a.name
	FROM get_fit_now_member as a
	JOIN get_fit_now_check_in as b 
	ON a.id = b.membership_id
	WHERE b.check_in_date = 20180109
		AND membership_status = 'gold'
		AND a.id LIKE '%48Z%')
             
SELECT p.id, p.name, transcript
FROM person AS p
JOIN suspect AS s ON s.person_id = p.id
JOIN interview as i ON i.person_id = p.id
WHERE p.license_id IN (
    SELECT id 
    FROM drivers_license
    WHERE plate_number LIKE '%H42W%'
)

-- 4th Clue:
-- - a lot of annual_income
-- - height: 5'5 / 65" OR 5'7 / 67"
-- - hair_color = red
-- - car_model = S
-- - car_make = Tesla
-- - event_name = 'SQL Symphony Concert' 3x in Dec 17

SELECT p.name
FROM person as p
JOIN drivers_license as d ON p.license_id = d.id
WHERE gender = 'female'
	AND p.id IN (SELECT person_id
				FROM facebook_event_checkin f1
				WHERE event_name = 'SQL Symphony Concert'
  					AND date BETWEEN 20171201 AND 20171231
				GROUP BY person_id
				HAVING COUNT(*) = 3)

  -- The murderer is Jeremy Bowers, who were hired by Miranda Priestly to murder someone.



