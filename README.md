# Google Capstone Project: Cyclistic
![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/67ff3da9-3c59-496d-bf96-8897c752d80e)

[Pexels](https://www.pexels.com/photo/woman-and-man-riding-on-bike-386024/)

## Introduction and Background
Completing a capstone project (case study) on the [Cyclistic data](https://divvy-tripdata.s3.amazonaws.com/index.html) is part of the Google Data Analytics Professional course that I have undertaken. In this project, I processed, cleaned and analysed the data using MySQL and then imported the data into Google Sheets for visualisation.

Cyclistic is a fictional company that offers a bike-share service located in Chicago. There are over 5,800 bicycles and 600 docking stations all across the state. The company currently offers 3 pricing plans: single-ride passes, full-day passes and annual memberships. Customers who purchase single-ride or full-day passes are referred to as casual riders. Customers who purchase annual memberships are Cyclistic members.

### Key Stakeholders
**Lily Moreno:** The director of marketing and my manager. Moreno is responsible for the development of campaigns and initiatives to promote the bike-share program. These may include email, social media, and other channels.

**Cyclistic marketing analytics team:** A team of data analysts who are responsible for collecting, analysing, and reporting data that helps guide Cyclistic marketing strategy. I joined this team six months ago and have been busy learning about Cyclistic’s mission and business goals — as well as how I, as a junior data analyst, can help Cyclistic achieve them.

**Cyclistic executive team:** The notoriously detail-oriented executive team will decide whether to approve the recommended marketing program.

_In this scenario, I am a junior data analyst working on the marketing analyst team at Cyclistic. The director of marketing believes that the company’s future success depends on **maximising the number of annual memberships.**_

#### There are 3 questions that will guide future marketing programmes:
1. How do annual members and casual riders use Cyclistic bikes differently?

2. Why would casual riders buy Cyclistic annual memberships?

3. How can Cyclistic use digital media to influence casual riders to become members?

Moreno has assigned me the first question to answer:
**How do annual members and casual riders use Cyclistic bikes differently?**

The business task is to investigate how annual members and casual riders use Cyclistic bikes differently.

## Preparation
When I began this project, the data from January 2023 to December 2023 were available. I downloaded the previous 12 months of [Cyclistic trip data](https://divvy-tripdata.s3.amazonaws.com/index.html).

![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/07eff294-8df7-48cc-8782-13346b2df5d6)
#### Does your data ROCCC? Yes
**Reliable:** All of the rows in the data set have unique IDs which suggests that the data is likely to be reliable.

**Original:** The dataset has been made available by Motivate International Inc.

**Comprehensive:** The dataset contains many aspects of each ride such as ride id, rideable type, station names and the start and end time. This information is necessary for the analysis.

**Current:** The source website has regularly been updated with new datasets and the dataset that I used in this project is the most recent ones from 2023.

**Cited:** Click [here](https://divvybikes.com/data-license-agreement) for the license of the data.

_**Note:** Data-privacy issues prohibit people from using riders’ personally identifiable information. This means that pass purchases’ details and credit card numbers are not made available to determine if casual riders live in the Cyclistic service area or if they have purchased multiple single passes._

## Processing, cleaning and manipulation
MySQL is the tool that I utilised throughout the processing, cleaning and analysing stages as the Cyclistic data has over 5 millions rows and 13 columns in total.

I began processing this data by importing the dataset for each month of 2023 into MySQL and combined them into one table named tripdata2023 by using the following query.

```
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
```

The `tripdata2023` table had `5,719,877` rows and 13 columns. I began cleaning the dataset by looking into each column and filtering out any incomplete or faulty data and fixing any errors.
### Columns in the dataset
`ride_id` is a unique id created for each ride. There are no duplicate values and no empty cells in this column.

`rideable_type` shows the type of bikes used by each user. There are 3 possible values for this column: `electric_bike`, `classic_bike` and `docked_bike`. No empty values are found in this column.

`started_at` column contains a timestamp for when the ride began.

`ended_at` column specifies a timestamp for when a ride ended.

`start_station_name` column contains the name of the station that riders started their session at. There are 875,716 rows with an empty value in this column and `1,593` unique station names.

`start_station_id` contains the ids of the stations that riders started their sessions at. There originally were `875,848` rows with empty `start_station_id`. However, it appears that some of the empty values, in fact, have its corresponding `start_station_name` data which are `Elizabeth St & Randolph St` and `Stony Island Ave & 63rd St`. I ran the below query to find the correct ids for each of these stations.

```
SELECT
  start_station_id,
  start_station_name
FROM
  tripdata2023
WHERE
  start_station_id <> ''
  AND start_station_name = 'Stony Island Ave & 63rd St';
```

I updated the dataset using the below query to reflect this.

```
UPDATE tripdata2023
SET
  start_station_id = '653B'
WHERE
  start_station_name = 'Stony Island Ave & 63rd St'
  AND start_station_id <> '653B';
```

The same cleaning step was also done for the `Elizabeth St & Randolph St` station. After I updated the dataset with the missing values, there were `875,716` rows with empty `start_station_id` remaining.

`end_station_id` contains the ids of the stations that riders finished their sessions at. There were `929,343` rows with empty `end_station_id`. After replacing some of the rows with empty `end_station_id` values rows with the correct station ids (similar query to the ones used for `start_station_id`), there were `929,202` rows with empty `end_station_id`.

`end_station_name` contains the name of the station that the riders return the bikes at. There were `1,598` unique station names and `929,202` rows with empty `end_station_name`.

`start_lat` latitude of the start location

`end_lat` latitude of the end location

`start_lng` longitude of the start location

`end_lng` longitude of the end location

`member_casual` contains 2 types of riders: `member` or `casual`.

### Creating a new table
```
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
```

I used the query shown above to create a new table which includes the following new columns; `route`, `day_of_the_week` (`0` = Monday, … , `6` = Sunday) and `duration` and filtered out all the non-complete rows from the original dataset.

As it is unlikely that any ride could be finished in under a minute, I also filtered out any rows that had a duration of a ride under one minute to avoid potential misleading insights and observations. The new table has `4,168,852` rows and `16` columns.

## Analysis
### Number of rides
I calculated the number of rides based on the following different criteria.

#### 1. Type of riders
All the ride ids in this dataset were counted as `num_of_rides` and grouped by the type of riders to compare the number of rides between annual members and casual riders.
```
SELECT
  member_casual,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
GROUP by
  member_casual;
```

#### 2. Day of the week
The number of rides were grouped and counted based on the day of the week that a rider started their session.
```
SELECT
  day_of_week,
  COUNT(ride_id) AS num_of_riders
FROM
  tripdata_year2023
GROUP BY
  day_of_week
ORDER BY
  num_of_rides DESC;
```

The number of rides for each day was also separated by the member types to compare any difference between them.
```
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
```

#### 3. Time of day
The number of rides were grouped and counted based on the time of the day (from 00:00 to 23:59) that a rider started their session. Hours are extracted from the starting time as `time_of_day`. I looked at both the total number of rides and the numbers separated by the member types.

```
SELECT
  member_casual,
  EXTRACT(HOUR FROM started_at) AS time_of_day,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  time_of_day
ORDER BY
  time_of_day ASC;
```

#### 4. Month
The month name is obtained from the starting time as month. The number of rides were grouped and counted based on each `month` in a year. The total numbers had been separated by the member types.
```
SELECT
  member_casual,
  EXTRACT(MONTH FROM started_at) AS month,
  COUNT(ride_id) AS num_of_rides
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  month
ORDER BY
  month ASC;
```

#### 5. Type of bikes
The number of rides were grouped and counted based on the type of rides. The total numbers had been separated by the member types.
```
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
```

### Duration
The duration of rides are calculated based on the following different criteria.

#### 1. Type of riders
`MAX`, `MIN`, `AVG` and `SUM` were calculated based on the member types.
```
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
```

#### 2. Day of the week
The average duration of rides was calculated for each day of the week separated by the member types.
```
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
```

#### 3. Time of day
The average duration of rides was calculated for rides starting in each hour of the day separated by the member types.
```
SELECT
  member_casual,
  EXTRACT(HOUR FROM started_at) AS time_of_day,
  AVG(duration) AS avg_duration
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  time_of_day
ORDER BY
  time_of_day ASC;
```

#### 4. Month
The average duration of rides was calculated for each month separated by the member types.
```
SELECT
  member_casual,
  EXTRACT(MONTH FROM started_at) AS month,
  AVG(duration) AS avg_duration
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  month
ORDER BY
  month ASC;
```

#### 5. Types of bikes
The average duration of rides was calculated for different types of bikes separated by the member types.
```
SELECT
  member_casual,
  rideable_type,
  AVG(duration) AS avg_duration
FROM
  tripdata_year2023
GROUP BY
  member_casual,
  rideable_type;
```

### Top 10 most popular routes traveled by annual members and casual riders.
The number of rides calculated based on different routes that riders traveled. This was also separated based on the member types.
```
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
```

```
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
```

To view all of the queries that I used in this project, please view on [GitHub](https://github.com/ksadangrit/google_capstone_project/blob/master/cyclistic_queries.sql).

## Visualisations and findings
For this stage, I imported all the results from my analysis from **MySQL** and created visualisations using **Google sheets**.

![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/88044abd-4bca-4a0b-a292-f65cdd37d518)

In 2023, **64.3%** of the rides made by using the Cyclistic bikes were from annual members, while casual riders only contributed to **36.7%** of all the trips made in that year.

![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/e626e548-cf55-4d25-8059-0b6ceb2d66dc)

However, when we compared the duration of all the rides between annual members and casual riders, we can see that casual riders appear to use the Cyclistic bikes longer than annual members. This observation is true for the maximum, average and summation of the duration calculated.

### Day of week


![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/44a80870-62bd-4705-8d1e-5f0be0fb834f)

In terms of days of the week, Cyclistic bikes were used the most on **Saturday** with **637,028** rides in total followed by **Thursday** and **Wednesday** with **626,297** and **611,837** rides respectively.


![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/a045e09e-9348-4a42-833a-af35b095bcf9)

When we look at the number of rides separated by the member types, we can see the trends in the above chart that the number of rides made by **annual members** for each day of the week is higher than the casual members. Cyclistic bikes were most used by the members on **Wednesdays** and the number dropped slightly towards the weekends. In contrast, the number of rides made by **casual members** was at its lowest at the beginning of the week and the number gradually increased and reached its peak on **Saturdays**, then it dropped slightly on Sundays.


![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/f4545f4d-4fe6-407c-82ac-600a979a38a2)

Nevertheless, when comparing the duration that the Cyclistic bikes were used throughout the week, we can see that casual riders typically rode the bikes longer than annual members every day of the week in 2023. The highest average duration of the rides for both member types was on **Sunday**.

### Time of day

![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/e47a0891-1657-42e3-8f21-399f57f74698)

The peak hours that both member types used the bikes were between **3pm to 7pm**. There is also a smaller peak period for members between **7am and 9am**, but not for casual riders.


![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/c4d3418e-34ba-4737-b3cf-a8feaa3f74cc)

In terms of the average duration, casual riders still generally used the bikes longer than annual riders throughout the day with the longest time used being from 10am to 3pm.

While the duration that members used the bikes was quite consistent throughout the day, casual riders used the bikes for a shorter duration after 3am.

### Month

![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/ed6b28c1-ba51-4b53-a7da-b34702efb59b)

Cyclistic bikes were used the most during **June to September** for both types of riders. The most popular month that the bikes were used was in August for the annual members and **July** for the casual riders.


![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/6371b544-4802-4d73-8dfd-a22e33e7493e)

Similar to the previous observations when it comes to the duration that different types of members used the bikes, casual riders still used the bikes for a longer duration throughout the year. They used the bikes for a longer duration between March and September and shorter duration from September to March.

### Types of bikes


![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/4d2fcf0c-cd46-4d69-bc00-1d9f17f4b4f3)


![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/3f35796b-f2f9-4bcb-bead-fcce21cb6541)

**Docked bikes** were only used by the casual riders and even though this was the least used compared to electric bikes and classic bikes, the average duration that a docked bike is used is **54.25** minutes which is more than the average duration of an electric bike and a classic bike combined. **Classic bikes** were used the most often among both the annual members and casual riders. For annual members, classic bikes were used almost twice as often as electric bikes.

### Top 10 popular routes

![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/2a583f11-6ccc-498a-ae0b-278876bb11d0)

![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/db42031a-7ab3-416b-bfec-de53bacd4d6a)

The most popular routes for annual members was `Ellis Ave & 60th St to University Ave & 57th St` with 5203 rides being taken. This route also ranked 9 in the top 10 routes most used by casual riders. Other than this route, no other routes from annual member’s top 10 made it to the casual riders’ list. For casual riders, `Streeter Dr & Grand Ave to Streeter Dr & Grand Ave` was the number 1 most popular route used by them.

### Recommendations

- As casual riders tend to ride a bike for longer durations, the company should consider cheaper pricing for annual members when riding for long durations as an incentive for casual riders to join membership. e.g. 50% off per minute pricing for each minute over 15 minutes
- Saturday is the busiest day for all riders. For casual riders, they also use the bikes more on weekends. Offering a half price or discount for members on weekends will likely increase the number of annual members.
- The company should consider allocating more funding for advertisement at the stations that were in the top 10 most popular routes list for casual riders as those stations are often traveled by casual riders.

### Dashboard

![image](https://github.com/ksadangrit/google_capstone_project/assets/156267785/1aa41251-cfc0-4611-ac83-1a3ebdd18af3)
