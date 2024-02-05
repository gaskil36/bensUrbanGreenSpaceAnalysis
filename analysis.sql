-- Exploring the data to query for parks only within the city of Newark, NJ
SELECT osm_id, place, name as newark_parks, ST_Area(way) as area, leisure, way as city_boundary
FROM planet_osm_polygon
WHERE name in ('Newark','Military Park', 'Lincoln Park', 'Harriet Tubman Square', 'Branch Brook Park', 
			   'Independence Park', 'Ivy Hill Park', 'Vailsburg Park', 'Riverbank Park', 'Veterans Memorial Park'
			   'Weequahic Park', 'West Side Park', 'Peter Francisco Park', 'Nat Turner Park')
ORDER BY area DESC;

-- Cleaning the data
-- Deleting entries where the OSM data held a NULL value for leisure and place.
DELETE FROM planet_osm_polygon
WHERE name in ('Newark','Military Park', 'Lincoln Park', 'Harriet Tubman Square', 'Branch Brook Park', 
			   'Independence Park', 'Ivy Hill Park', 'Vailsburg Park', 'Riverbank Park', 'Veterans Memorial Park'
			   'Weequahic Park', 'West Side Park', 'Peter Francisco Park', 'Nat Turner Park') AND leisure is NULL AND place is NULL;
			   
-- After visualizing entries in QGIS, I identified duplicate names of parks that are in different cities
-- Deleting these entries
-- Exploring the data to query for parks only within the city of Newark, NJ
DELETE FROM planet_osm_polygon
WHERE ST_Area(way) = 31569.52439827191
   OR ST_Area(way) = 1448.7891236321857
   OR ST_Area(way) = 16564.699621195792
   OR ST_Area(way) = 203921.83202167338
   OR ST_Area(way) = 7602.520831999341
   OR ST_Area(way) = 15037.090347355754
   OR ST_Area(way) = 1862464.633198247
   OR ST_Area(way) = 47306.26771780349;

--Create a new table for greenspaces (parks) in Newark, NJ
CREATE TABLE green_spaces (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	location GEOMETRY(Point, 3857),
	area_sq_m NUMERIC
);

-- Populating the new green_spaces table
INSERT INTO green_spaces (name, location, area_sq_m)
SELECT name, ST_Centroid(way), ST_Area(way)
FROM planet_osm_polygon
WHERE name in ('Newark','Military Park', 'Lincoln Park', 'Harriet Tubman Square', 'Branch Brook Park', 
			   'Independence Park', 'Ivy Hill Park', 'Vailsburg Park', 'Riverbank Park', 'Veterans Memorial Park'
			   'Weequahic Park', 'West Side Park', 'Peter Francisco Park', 'Nat Turner Park');
			   
-- Spatial Analysis
-- View all data in the table
SELECT *
FROM green_spaces
ORDER BY area_sq_m DESC;

-- Calculate the total number of parks, total area (converted to sq km), and average area. 
-- Exlcuded one entry for the entire city of Newark from the analysis.
-- Solution for exclusion found here: https://stackoverflow.com/questions/20075910/where-column-is-not-value
SELECT COUNT(*) AS total_parks, ROUND((SUM(area_sq_m)/1e6), 2) AS total_area_sq_km, ROUND((AVG(area_sq_m)/1e6), 2) AS average_area_sq_km
FROM green_spaces
WHERE name <> 'Newark';

-- Select the top 5 largest green spaces
SELECT name, ROUND((area_sq_m/1e6), 2) as area_sq_km
FROM green_spaces
WHERE name <> 'Newark'
ORDER BY area_sq_m DESC
LIMIT 5;