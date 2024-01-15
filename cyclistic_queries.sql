/* Create a table containing data from all 12 individual months */
CREATE TABLE
  tripdata2023 AS
SELECT
  *
FROM
  tripdata202301
UNION ALL
SELECT
  *
FROM
  tripdata202302
UNION ALL
SELECT
  *
FROM
  tripdata202303
UNION ALL
SELECT
  *
FROM
  tripdata202304
UNION ALL
SELECT
  *
FROM
  tripdata202305
UNION ALL
SELECT
  *
FROM
  tripdata202306
UNION ALL
SELECT
  *
FROM
  tripdata202307
UNION ALL
SELECT
  *
FROM
  tripdata202308
UNION ALL
SELECT
  *
FROM
  tripdata202309
UNION ALL
SELECT
  *
FROM
  tripdata202310
UNION ALL
SELECT
  *
FROM
  tripdata202311
UNION ALL
SELECT
  *
FROM
  tripdata202312;

/* Clean the dataset */
/* Check whether all ride IDs are unique */
SELECT
  COUNT(DISTINCT (ride_id))
FROM
  tripdata2023;

/* Check for rows with empty start_station_name and non-empty start_station_id */
SELECT
  start_station_name,
  start_station_id
FROM
  tripdata2023
WHERE
  start_station_name = ''
  AND start_station_id <> ''
GROUP BY
  start_station_id;

/* Check for rows with empty start_station_id and non-empty start_station_name */
SELECT
  start_station_id,
  start_station_name
FROM
  tripdata2023
WHERE
  start_station_id = ''
  AND start_station_name <> ''
GROUP BY
  start_station_name;

/* Find all rows with missing start_station_id with Stony Island Ave & 63rd St start_station_name */
/* The same query can also be used for a different station name that has a missing id */
SELECT
  start_station_id,
  start_station_name
FROM
  tripdata2023
WHERE
  start_station_id <> ''
  AND start_station_name = 'Stony Island Ave & 63rd St';

/* Update the empty start_station_id values with the correct station ids acquired from the previous quries. 
The below query can also be used for a different station name that has a missing id */
UPDATE tripdata2023
SET
  start_station_id = '653B'
WHERE
  start_station_name = 'Stony Island Ave & 63rd St'
  AND start_station_id <> '653B';

/* Check for the number rows where the start_station_id is empty */
SELECT
  COUNT(start_station_id)
FROM
  tripdata2023
WHERE
  start_station_id = '';

/* Check for the number rows where the start_station_name is empty */
SELECT
  COUNT(start_station_name)
FROM
  tripdata2023
WHERE
  start_station_name = '';

/* The two numbers from the above queries should match, which means all rows that have an
empty value in either field have both fields empty and are not able to be backfilled */
/* Check for rows with empty end_station_name and non-empty end_station_id */
SELECT
  end_station_name,
  end_station_id
FROM
  tripdata2023
WHERE
  end_station_name = ''
  AND end_station_id <> ''
GROUP BY
  end_station_id;

/* Check for rows with empty end_station_name and non-empty end_station_id */
SELECT
  end_station_id,
  end_station_name
FROM
  tripdata2023
WHERE
  end_station_id = ''
  AND end_station_name <> ''
GROUP BY
  end_station_name;

/* Find all rows with missing end_station_id with Stony Island Ave & 63rd St end_station_name */
/* The same query can also be used for a different station name that has a missing id */
SELECT
  end_station_id,
  end_station_name
FROM
  tripdata2023
WHERE
  end_station_id <> ''
  AND end_station_name = 'Stony Island Ave & 63rd St';

/* Update the empty end_station_id values with the correct station ids acquired from the previous quries. 
The below query can also be used for a different station name that has a missing id */
UPDATE tripdata2023
SET
  end_station_id = '653B'
WHERE
  end_station_name = 'Stony Island Ave & 63rd St'
  AND end_station_id <> '653B';

/* Check for the number rows where the end_station_id is empty */
SELECT
  COUNT(end_station_id)
FROM
  tripdata2023
WHERE
  end_station_id = '';

/* Check for the number rows where the end_station_name is empty */
SELECT
  COUNT(end_station_name)
FROM
  tripdata2023
WHERE
  end_station_name = '';

/* Check whether there are any station names that need to be trimed and updated. */
SELECT
  COUNT(DISTINCT (TRIM(start_station_name))) AS count_trimmed_start_station_name,
  COUNT(DISTINCT (start_station_name)) AS count_start_station_name,
  COUNT(DISTINCT (TRIM(end_station_name))) AS count_trimmed_end_station_name,
  COUNT(DISTINCT (end_station_name)) AS count_end_station_name
FROM
  tripdata2023;

/* Creating a new table with 3 new columns included and filtering out the incomplete rows with empty cells and any duration of a ride under 1 minute 
as it is unlikely that a ride can finish that fast */
CREATE TABLE
  tripdata_year2023 AS
SELECT
  *,
  CONCAT (start_station_name, " to ", end_station_name) AS route,
  WEEKDAY (started_at) AS day_of_week,
  TIMESTAMPDIFF (MINUTE, started_at, ended_at) AS duration
FROM
  tripdata2023
WHERE
  TIMESTAMPDIFF (MINUTE, started_at, ended_at) > 1
  AND started_at <> ''
  AND ended_at <> ''
  AND start_station_id <> ''
  AND start_station_name <> ''
  AND end_station_id <> ''
  AND end_station_name <> ''
  AND start_lat <> ''
  AND start_lng <> ''
  AND end_lat <> ''
  AND end_lng <> '';

/* Analyzing the dataset for trends and insights */
/* First, we will analyze total number of rides and compare the number of rides seperated by member types */
/* Count all number of rides in 2023 */
SELECT
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023;

/* Count number of rides seperated by member types */
SELECT
  member_casual,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
GROUP by
  member_casual;

/* Count total number of rides based on day of the week (0=Monday, 1=Tuesday, ..., 6=Sunday) */
SELECT
  day_of_week,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
GROUP by
  day_of_week
ORDER by
  day_of_week ASC;

/* Compare number of rides between member types based on day of the week */
SELECT
  member_casual,
  day_of_week,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  day_of_week
ORDER BY
  day_of_week ASC;

/* Count total number of rides based on time of the day (hour) */
SELECT
  EXTRACT(
    HOUR
    FROM
      started_at
  ) AS time_of_day,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
GROUP by
  time_of_day
ORDER by
  day_of_week ASC;

/* Compare number of rides between member types based on time of the day (hour) */
SELECT
  member_casual,
  EXTRACT(
    HOUR
    FROM
      started_at
  ) AS time_of_day,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  time_of_day
ORDER BY
  time_of_day ASC;

/* Count total number of rides based on month */
SELECT
  EXTRACT(
    MONTH
    FROM
      started_at
  ) AS month,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
GROUP by
  month
ORDER by
  month ASC;

/* Compare number of rides between member types based on time of the day (hour) */
SELECT
  member_casual,
  EXTRACT(
    MONTH
    FROM
      started_at
  ) AS month,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  month
ORDER BY
  month ASC;

/* Compare type of bikes used between annual members and casual members */
SELECT
  member_casual,
  rideable_type,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
GROUP BY
  rideable_type,
  member_casual
ORDER BY
  num_of_rides DESC;

/* We will now move on to calculating the duration of a ride based on different criteria */
/* Calculate MAX, MIN, AVG and SUM based on the member types */
SELECT
  member_casual,
  MAX(duration) AS max_duration,
  MIN(duration) AS min_duration,
  AVG(duration) AS avg_duration,
  SUM(duration) AS sum_duration
FROM
  tripdata_year2023
GROUP BY
  member_casual;

/* Calculate average duration for each day of the week seperated by member types */
SELECT
  member_casual,
  day_of_week,
  AVG(duration) AS avg_duration
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  day_of_week
ORDER BY
  day_of_week ASC;

/* Calculate average duration for rides starting at each hour of the day seperated by member types */
SELECT
  member_casual,
  EXTRACT(
    HOUR
    FROM
      started_at
  ) AS time_of_day,
  AVG(duration) AS avg_duration
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  time_of_day
ORDER BY
  time_of_day ASC;

/* Calculate average duration of rides for each month seperated by the member types */
SELECT
  member_casual,
  EXTRACT(
    MONTH
    FROM
      started_at
  ) AS month,
  AVG(duration) AS avg_duration
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  month
ORDER BY
  month ASC;

/* Calculate average duration for different types of bikes seperated by member types */
SELECT
  member_casual,
  rideable_type,
  AVG(duration) AS avg_duration
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  rideable_type;

/* Top 10 most popular routes */
/* Traveled by annual members */
SELECT
  route,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
WHERE
  member_casual = "member"
GROUP BY
  route,
  member_casual
ORDER BY
  num_of_rides DESC
LIMIT
  10;

/* Traveled by casual riders */
SELECT
  route,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
WHERE
  member_casual = "casual"
GROUP BY
  route,
  member_casual
ORDER BY
  num_of_rides DESC
LIMIT
  10;