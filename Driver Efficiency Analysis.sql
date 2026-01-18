'''

This MySQL query calculates driver efficiency for the first and second half of the year based on the `trips` and `drivers` tables. It identifies drivers who have **improved efficiency** in the second half compared to the first half and returns the results in a readable format.

The output includes driver ID, name, first-half average efficiency, second-half average efficiency, and the improvement amount.

The results are **sorted by efficiency improvement in descending order** and then by driver name in ascending order.

---

## Input Tables

**1. drivers**

| Column Name | Type    |
| ----------- | ------- |
| driver_id   | INT     |
| driver_name | VARCHAR |

**2. trips**

| Column Name   | Type  |
| ------------- | ----- |
| trip_id       | INT   |
| driver_id     | INT   |
| trip_date     | DATE  |
| distance_km   | FLOAT |
| fuel_consumed | FLOAT |

---
'''
## Query Code..............................................................................................................................................................................................
..............................................................................................................................................................................................
```sql
WITH first_half AS (
    SELECT
        driver_id,
        AVG(distance_km / fuel_consumed) AS first_half_avg
    FROM trips
    WHERE MONTH(trip_date) BETWEEN 1 AND 6
      AND fuel_consumed > 0
    GROUP BY driver_id
),
second_half AS (
    SELECT
        driver_id,
        AVG(distance_km / fuel_consumed) AS second_half_avg
    FROM trips
    WHERE MONTH(trip_date) BETWEEN 7 AND 12
      AND fuel_consumed > 0
    GROUP BY driver_id
)
SELECT
    d.driver_id,
    d.driver_name,
    ROUND(f.first_half_avg, 2) AS first_half_avg,
    ROUND(s.second_half_avg, 2) AS second_half_avg,
    ROUND(s.second_half_avg - f.first_half_avg, 2) AS efficiency_improvement
FROM first_half f
INNER JOIN second_half s
    ON f.driver_id = s.driver_id
INNER JOIN drivers d
    ON d.driver_id = f.driver_id
WHERE s.second_half_avg > f.first_half_avg  -- Only drivers with positive improvement
ORDER BY
    efficiency_improvement DESC,       -- Highest improvement first
    d.driver_name ASC;                  -- Secondary sort by name
```

---

## Output Example............................................................................................................................................................................
                
| driver_id | driver_name   | first_half_avg | second_half_avg | efficiency_improvement |
| --------- | ------------- | -------------- | --------------- | ---------------------- |
| 109876    | Bob Smith     | 11.24          | 13.33           | 2.10                   |
| 65321     | Alice Johnson | 11.97          | 14.02           | 2.05                   |

---

##  Key Points...........................................................................................................................................................................................

1. Uses **CTEs** (`WITH` clause) for clarity and separation of first and second half calculations.
2. Removes any driver with **negative or zero improvement**.
3. Rounds average efficiency and improvement values to **2 decimal places** for reporting clarity.
4. Ensures output is **human-readable** with driver names and ordered logically.
5. Can be easily modified to add **percentage improvement** or **filter by top N performers**.

