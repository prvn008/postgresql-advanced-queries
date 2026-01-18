/*
Problem: 3580 - Find Consistently Improving Employees
Difficulty: Medium
Platform: LeetCode
Database: PostgreSQL

Objective:
Identify employees whose last three performance reviews show
strictly increasing ratings based on review_date.

Key Rules:
- Employee must have at least 3 reviews
- Only the most recent 3 reviews are considered
- Ratings must strictly increase
- Improvement Score = latest_rating - earliest_rating

Concepts Used:
- Window Functions (ROW_NUMBER, LAG)
- CTEs (Common Table Expressions)
- Filtering latest N records per group
- Aggregation with HAVING
- Conditional validation logic

Author: <Your Name>
Last Updated: 2026-01-18
*/
-- Step 1: Rank reviews by recency per employee
WITH ranked_reviews AS (
    SELECT
        pr.employee_id,
        pr.review_date,
        pr.rating,
        ROW_NUMBER() OVER (
            PARTITION BY pr.employee_id
            ORDER BY pr.review_date DESC
        ) AS rn
    FROM performance_reviews pr
),

-- Step 2: Keep only the last 3 reviews and compare ratings
last_three AS (
    SELECT
        employee_id,
        review_date,
        rating,
        LAG(rating) OVER (
            PARTITION BY employee_id
            ORDER BY review_date
        ) AS prev_rating
    FROM ranked_reviews
    WHERE rn <= 3
)

-- Step 3: Validate strict improvement and calculate improvement score
SELECT
    e.employee_id,
    e.name,
    MAX(lt.rating) - MIN(lt.rating) AS improvement_score
FROM last_three lt
JOIN employees e
    ON e.employee_id = lt.employee_id
GROUP BY e.employee_id, e.name
HAVING COUNT(*) = 3
   AND SUM(
        CASE
            WHEN lt.prev_rating IS NULL THEN 0
            WHEN lt.rating > lt.prev_rating THEN 0
            ELSE 1
        END
   ) = 0
ORDER BY improvement_score DESC, e.name ASC;

# Window Function Problems (PostgreSQL)

This folder contains advanced SQL problems solved using
PostgreSQL window functions such as:

- ROW_NUMBER
- RANK / DENSE_RANK
- LAG / LEAD
- Running totals
- Trend analysis

### Included Problems
- 3580 – Consistently Improving Employees  
  (Trend validation using ROW_NUMBER + LAG)

Purpose:
- Interview preparation
- Real-world analytics patterns
- PostgreSQL optimization practice
