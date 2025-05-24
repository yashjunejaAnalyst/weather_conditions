use weather;

 -- 1 How do weather conditions differ between Los Angeles and Oakland across the year?
SELECT 
    city,
    MONTH(datetime) AS month,
    ROUND(AVG(temp), 2) AS avg_temp,
    ROUND(AVG(humidity), 2) AS avg_humidity,
    ROUND(SUM(precip), 2) AS total_precip,
    ROUND(AVG(sealevelpressure), 2) AS avg_pressure,
    ROUND(AVG(cloudcover), 2) AS avg_cloudcover,
    ROUND(AVG(solarenergy), 2) AS avg_solarenergy,
    ROUND(AVG(uvindex), 2) AS avg_uvindex
FROM (
    SELECT 
        'Los Angeles' AS city,
        datetime,
        temp,
        humidity,
        precip,
        sealevelpressure,
        cloudcover,
        solarenergy,
        uvindex
    FROM los_angeles

    UNION ALL

    SELECT 
        'Oakland' AS city,
        datetime,
        temp,
        humidity,
        precip,
        sealevelpressure,
        cloudcover,
        solarenergy,
        uvindex
    FROM oakland
) AS combined
GROUP BY 
    city, MONTH(datetime)
ORDER BY 
    city, month;

 -- 2 What time of day typically has the most solar energy or UV index in each city?
 
 SELECT 
    city,
    hour,
    ROUND(AVG(solarenergy), 2) AS avg_solarenergy,
    ROUND(AVG(uvindex), 2) AS avg_uvindex
FROM (
    SELECT 
        'Los Angeles' AS city,
        HOUR(datetime) AS hour,
        solarenergy,
        uvindex
    FROM los_angeles

    UNION ALL

    SELECT 
        'Oakland' AS city,
        HOUR(datetime) AS hour,
        solarenergy,
        uvindex
    FROM oakland
) AS combined
GROUP BY 
    city, hour
ORDER BY 
    city, avg_solarenergy DESC;

 -- 3 Are there specific months or seasons with more severe weather risks?
 
 SELECT 
    city,
    CASE 
        WHEN MONTH(datetime) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(datetime) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(datetime) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(datetime) IN (9, 10, 11) THEN 'Fall'
    END AS season,
    COUNT(*) AS observations,
    SUM(CASE WHEN severerisk > 0 THEN 1 ELSE 0 END) AS risk_days,
    ROUND(AVG(severerisk), 2) AS avg_severerisk
FROM (
    SELECT 'Los Angeles' AS city, datetime, severerisk FROM los_angeles
    UNION ALL
    SELECT 'Oakland' AS city, datetime, severerisk FROM oakland
) AS combined
GROUP BY 
    city, season
ORDER BY 
    city, season;
    
 -- 4 How do cloud cover and visibility impact conditions in these cities?
 
 SELECT 
    city,
    conditions,
    ROUND(AVG(cloudcover), 2) AS avg_cloudcover,
    ROUND(AVG(visibility), 2) AS avg_visibility,
    COUNT(*) AS observations
FROM (
    SELECT 'Los Angeles' AS city, conditions, cloudcover, visibility FROM los_angeles
    UNION ALL
    SELECT 'Oakland' AS city, conditions, cloudcover, visibility FROM oakland
) AS combined
GROUP BY 
    city, conditions
ORDER BY 
    city, avg_cloudcover DESC;

 -- OR
    
    SELECT 
    city,
    conditions,
    CASE
        WHEN visibility >= 10 THEN 'High'
        WHEN visibility BETWEEN 5 AND 9.9 THEN 'Moderate'
        ELSE 'Low'
    END AS visibility_level,
    COUNT(*) AS occurrences
FROM (
    SELECT 'Los Angeles' AS city, conditions, visibility FROM los_angeles
    UNION ALL
    SELECT 'Oakland' AS city, conditions, visibility FROM oakland
) AS combined
GROUP BY 
    city, conditions, visibility_level
ORDER BY 
    city, conditions;

    
-- 5 Is there a pattern between dew point and actual precipitation across cities?

SELECT 
    city,
    CASE 
        WHEN dew < 40 THEN 'Low (<40°F)'
        WHEN dew BETWEEN 40 AND 59 THEN 'Moderate (40–59°F)'
        ELSE 'High (≥60°F)'
    END AS dew_point_range,
    ROUND(AVG(precip), 3) AS avg_precip,
    COUNT(*) AS records,
    SUM(CASE WHEN precip > 0 THEN 1 ELSE 0 END) AS rainy_records
FROM (
    SELECT 'Los Angeles' AS city, dew, precip FROM los_angeles
    UNION ALL
    SELECT 'Oakland' AS city, dew, precip FROM oakland
) AS combined
GROUP BY 
    city, dew_point_range
ORDER BY 
    city, dew_point_range;

 -- 6 What are the common weather conditions (e.g., clear, cloudy) in each city?
 
 SELECT 
    city,
    conditions,
    COUNT(*) AS occurrences
FROM (
    SELECT 'Los Angeles' AS city, conditions FROM los_angeles
    UNION ALL
    SELECT 'Oakland' AS city, conditions FROM oakland
) AS combined
GROUP BY 
    city, conditions
ORDER BY 
    city, occurrences DESC;
    
 -- KPI BASED QUESTIONS --
 
-- 1 What is the average daily high and low temperature per month per city?

WITH daily_high_low AS (
    SELECT
        city,
        DATE(datetime) AS date,
        MONTH(datetime) AS month,
        MAX(temp) AS daily_high,
        MIN(temp) AS daily_low
    FROM (
        SELECT 'Los Angeles' AS city, datetime, temp FROM los_angeles
        UNION ALL
        SELECT 'Oakland' AS city, datetime, temp FROM oakland
    ) AS combined
    GROUP BY city, DATE(datetime), MONTH(datetime)
)

SELECT
    city,
    month,
    ROUND(AVG(daily_high), 2) AS avg_daily_high,
    ROUND(AVG(daily_low), 2) AS avg_daily_low
FROM daily_high_low
GROUP BY city, month
ORDER BY city, month;

 -- 2 What is the total monthly precipitation and average daily probability of rain?
 
 WITH daily_stats AS (
    SELECT
        city,
        DATE(datetime) AS date,
        MONTH(datetime) AS month,
        SUM(precip) AS daily_precip,
        AVG(precipprob) AS daily_precip_prob
    FROM (
        SELECT 'Los Angeles' AS city, datetime, precip, precipprob FROM los_angeles
        UNION ALL
        SELECT 'Oakland' AS city, datetime, precip, precipprob FROM oakland
    ) AS combined
    GROUP BY city, DATE(datetime), MONTH(datetime)
)

SELECT
    city,
    month,
    ROUND(SUM(daily_precip), 2) AS total_monthly_precip,
    ROUND(AVG(daily_precip_prob), 2) AS avg_daily_precip_prob
FROM daily_stats
GROUP BY city, month
ORDER BY city, month;

 -- 3 What is the peak solar radiation and energy per day/month?
 
 -- * Peak solar radiation
SELECT 
    'Los Angeles' AS city,
    MAX(solarradiation) AS peak_solar_radiation
FROM los_angeles
UNION
SELECT 
    'Oakland' AS city,
    MAX(solarradiation) AS peak_solar_radiation
FROM oakland;

-- 2. Total solar energy per day
SELECT 
    'Los Angeles' AS city,
    DATE(datetime) AS date,
    SUM(solarenergy) AS total_daily_energy_mj
FROM los_angeles
GROUP BY DATE(datetime)
UNION
SELECT 
    'Oakland' AS city,
    DATE(datetime) AS date,
    SUM(solarenergy) AS total_daily_energy_mj
FROM oakland
GROUP BY DATE(datetime);

-- 3. Total solar energy per month
SELECT 
    'Los Angeles' AS city,
    DATE_FORMAT(datetime, '%Y-%m') AS month,
    SUM(solarenergy) AS total_monthly_energy_mj
FROM los_angeles
GROUP BY DATE_FORMAT(datetime, '%Y-%m')
UNION
SELECT 
    'Oakland' AS city,
    DATE_FORMAT(datetime, '%Y-%m') AS month,
    SUM(solarenergy) AS total_monthly_energy_mj
FROM oakland
GROUP BY DATE_FORMAT(datetime, '%Y-%m');

 -- 4 What is the percentage of days with high UV index (>5)?
 
-- Los Angeles
SELECT 
  'Los Angeles' AS city,
  ROUND(COUNT(*) / (SELECT COUNT(*) FROM (
      SELECT DATE(datetime) AS date, MAX(uvindex) AS max_uv
      FROM los_angeles
      GROUP BY DATE(datetime)
  ) AS all_days) * 100, 2) AS high_uv_day_percentage
FROM (
    SELECT DATE(datetime) AS date, MAX(uvindex) AS max_uv
    FROM los_angeles
    GROUP BY DATE(datetime)
) AS daily_uv
WHERE max_uv > 5;

-- Oakland
SELECT 
  'Oakland' AS city,
  ROUND(COUNT(*) / (SELECT COUNT(*) FROM (
      SELECT DATE(datetime) AS date, MAX(uvindex) AS max_uv
      FROM oakland
      GROUP BY DATE(datetime)
  ) AS all_days) * 100, 2) AS high_uv_day_percentage
FROM (
    SELECT DATE(datetime) AS date, MAX(uvindex) AS max_uv
    FROM oakland
    GROUP BY DATE(datetime)
) AS daily_uv
WHERE max_uv > 5;

 -- 5 What are the average humidity levels per city per season?
 
 -- Los Angeles: average humidity per season
SELECT 
  'Los Angeles' AS city,
  CASE
    WHEN MONTH(datetime) IN (12, 1, 2) THEN 'Winter'
    WHEN MONTH(datetime) IN (3, 4, 5) THEN 'Spring'
    WHEN MONTH(datetime) IN (6, 7, 8) THEN 'Summer'
    WHEN MONTH(datetime) IN (9, 10, 11) THEN 'Fall'
  END AS season,
  ROUND(AVG(humidity), 2) AS avg_humidity
FROM los_angeles
GROUP BY season;

-- Oakland: average humidity per season
SELECT 
  'Oakland' AS city,
  CASE
    WHEN MONTH(datetime) IN (12, 1, 2) THEN 'Winter'
    WHEN MONTH(datetime) IN (3, 4, 5) THEN 'Spring'
    WHEN MONTH(datetime) IN (6, 7, 8) THEN 'Summer'
    WHEN MONTH(datetime) IN (9, 10, 11) THEN 'Fall'
  END AS season,
  ROUND(AVG(humidity), 2) AS avg_humidity
FROM oakland
GROUP BY season;

OR
-- Combined city-season humidity averages
SELECT 
  city,
  season,
  ROUND(AVG(humidity), 2) AS avg_humidity
FROM (
  SELECT 
    'Los Angeles' AS city,
    humidity,
    CASE
      WHEN MONTH(datetime) IN (12, 1, 2) THEN 'Winter'
      WHEN MONTH(datetime) IN (3, 4, 5) THEN 'Spring'
      WHEN MONTH(datetime) IN (6, 7, 8) THEN 'Summer'
      WHEN MONTH(datetime) IN (9, 10, 11) THEN 'Fall'
    END AS season
  FROM los_angeles
  UNION ALL
  SELECT 
    'Oakland' AS city,
    humidity,
    CASE
      WHEN MONTH(datetime) IN (12, 1, 2) THEN 'Winter'
      WHEN MONTH(datetime) IN (3, 4, 5) THEN 'Spring'
      WHEN MONTH(datetime) IN (6, 7, 8) THEN 'Summer'
      WHEN MONTH(datetime) IN (9, 10, 11) THEN 'Fall'
    END AS season
  FROM oakland
) AS combined
GROUP BY city, season;

 -- 6 What is the frequency of “Severe Risk” conditions flagged (if available)?

-- Los Angeles: count and percentage of rows with severe risk flagged
SELECT 
  'Los Angeles' AS city,
  COUNT(*) AS total_records,
  SUM(CASE WHEN severerisk IS NOT NULL AND severerisk != '' THEN 1 ELSE 0 END) AS severe_risk_count,
  ROUND(SUM(CASE WHEN severerisk IS NOT NULL AND severerisk != '' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS severe_risk_percentage
FROM los_angeles;

-- Oakland: count and percentage of rows with severe risk flagged
SELECT 
  'Oakland' AS city,
  COUNT(*) AS total_records,
  SUM(CASE WHEN severerisk IS NOT NULL AND severerisk != '' THEN 1 ELSE 0 END) AS severe_risk_count,
  ROUND(SUM(CASE WHEN severerisk IS NOT NULL AND severerisk != '' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS severe_risk_percentage
FROM oakland;
