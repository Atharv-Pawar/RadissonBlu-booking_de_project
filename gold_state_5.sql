-- ============================================================
-- GOLD STATE 5
-- TOP 10 COUNTRIES BY REVENUE
-- ============================================================

USE DATABASE RADISSONBLU_DB;
USE SCHEMA _HOTEL;

SELECT * FROM SILVER_HOTEL_BOOKING;

-- ============================================================
-- 1. CREATE GOLD TABLE
-- ============================================================

CREATE OR REPLACE TABLE GOLD_TOP_10_COUNTRIES_REVENUE AS

SELECT
    HOTEL_COUNTRY,

    -- Total number of bookings
    COUNT(*) AS TOTAL_BOOKINGS,

    -- Total rooms booked
    SUM(ROOMS_BOOKED) AS TOTAL_ROOMS_BOOKED,

    -- Total revenue
    ROUND(
        SUM(TOTAL_AMOUNTS),
        2
    ) AS TOTAL_REVENUE,

    -- Average revenue per booking
    ROUND(
        AVG(TOTAL_AMOUNTS),
        2
    ) AS AVG_REVENUE_PER_BOOKING,

    -- Percentage contribution to total revenue
    ROUND(
        SUM(TOTAL_AMOUNTS) * 100.0
        /
        NULLIF(
            SUM(SUM(TOTAL_AMOUNTS)) OVER (),
            0
        ),
        2
    ) AS REVENUE_CONTRIBUTION_PCT

FROM SILVER_HOTEL_BOOKING

WHERE
    HOTEL_COUNTRY IS NOT NULL
    AND TOTAL_AMOUNTS > 0

GROUP BY
    HOTEL_COUNTRY

ORDER BY
    TOTAL_REVENUE DESC

LIMIT 10;


-- ============================================================
-- 2. DISPLAY TOP 10 COUNTRIES
-- ============================================================

SELECT
    HOTEL_COUNTRY,
    TOTAL_BOOKINGS,
    TOTAL_ROOMS_BOOKED,
    TOTAL_REVENUE,
    AVG_REVENUE_PER_BOOKING,
    REVENUE_CONTRIBUTION_PCT

FROM GOLD_TOP_10_COUNTRIES_REVENUE

ORDER BY
    TOTAL_REVENUE DESC;