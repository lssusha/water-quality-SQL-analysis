-- Project 2: Water Source Access & Well Analysis
-- Author: Lissan Meles
-- Description: This project analyzes water source access across towns and provinces,
-- including well pollution and population served by each type of water source.
-- Date: 2025-10-03

------------------------------------------------------------
-- Step 1: Combine location, visits, water source, and well pollution
------------------------------------------------------------
-- Create a combined view to analyze water access and well pollution
CREATE OR REPLACE VIEW combined_analysis_table AS
SELECT
    water_source.type_of_water_source,
    location.town_name,
    location.province_name,
    location.location_type,
    water_source.number_of_people_served,
    visits.time_in_queue,
    well_pollution.results
FROM visits
LEFT JOIN well_pollution
    ON well_pollution.source_id = visits.source_id
INNER JOIN location
    ON location.location_id = visits.location_id
INNER JOIN water_source
    ON water_source.source_id = visits.source_id
WHERE visits.visit_count = 1;

-- Preview the combined view
SELECT * FROM combined_analysis_table;

------------------------------------------------------------
-- Step 2: Aggregate by province
------------------------------------------------------------
-- Calculate total population served per province and percentage by water source type
WITH province_totals AS (
    SELECT
        province_name,
        SUM(number_of_people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name
)
SELECT
    ct.province_name,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'river'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'shared_tap'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'tap_in_home'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'tap_in_home_broken'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'well'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN province_totals pt ON ct.province_name = pt.province_name
GROUP BY ct.province_name
ORDER BY ct.province_name;

------------------------------------------------------------
-- Step 3: Aggregate by town
------------------------------------------------------------
WITH town_totals AS (
    SELECT
        province_name,
        town_name,
        SUM(number_of_people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name, town_name
)
SELECT
    ct.province_name,
    ct.town_name,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'river'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'shared_tap'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'tap_in_home'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'tap_in_home_broken'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'well'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN town_totals tt 
    ON ct.province_name = tt.province_name
   AND ct.town_name = tt.town_name
GROUP BY ct.province_name, ct.town_name
ORDER BY ct.town_name;

------------------------------------------------------------
-- Step 4: Optional - Create temporary table for town aggregation
------------------------------------------------------------
CREATE TEMPORARY TABLE Town_aggregated_water_access AS
WITH town_totals AS (
    SELECT
        province_name,
        town_name,
        SUM(number_of_people_served) AS total_ppl_serv
    FROM combined_analysis_table
    GROUP BY province_name, town_name
)
SELECT
    ct.province_name,
    ct.town_name,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'river'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'shared_tap'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'tap_in_home'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'tap_in_home_broken'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN ct.type_of_water_source = 'well'
                    THEN ct.number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN town_totals tt 
    ON ct.province_name = tt.province_name
   AND ct.town_name = tt.town_name
GROUP BY ct.province_name, ct.town_name
ORDER BY ct.town_name;

------------------------------------------------------------
-- END OF PROJECT 2
------------------------------------------------------------
