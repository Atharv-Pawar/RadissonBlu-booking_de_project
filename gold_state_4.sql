-- ============================================================
-- GOLD STATE 4
-- YEARLY & QUARTERLY BOOKING CANCELLATION RATE
--
-- Business Requirement:
--
-- Cancellation Rate =
-- Total Cancelled Bookings
-- -------------------------------- × 100
-- Total Confirmed Bookings
--
-- Analysis:
--   1. Yearly cancellation rate
--   2. Quarterly cancellation rate
-- ============================================================


USE DATABASE RADISSONBLU_DB;
USE SCHEMA _HOTEL;

SELECT * FROM SILVER_HOTEL_BOOKING;

-- ============================================================
-- 1. YEARLY CANCELLATION RATE
-- ============================================================

CREATE OR REPLACE TABLE GOLD_YEARLY_CANCELLATION_RATE AS

WITH YEARLY_BOOKINGS AS (

    SELECT

        YEAR(CHECK_IN_TIMESTAMP) AS BOOKING_YEAR,

        -- Total bookings
        COUNT(*) AS TOTAL_BOOKINGS,

        -- Confirmed bookings
        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'confirmed'
        ) AS TOTAL_CONFIRMED_BOOKINGS,

        -- Cancelled bookings
        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'cancelled'
        ) AS TOTAL_CANCELLED_BOOKINGS,

        -- Completed bookings
        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'completed'
        ) AS TOTAL_COMPLETED_BOOKINGS,

        -- Pending bookings
        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'pending'
        ) AS TOTAL_PENDING_BOOKINGS

    FROM SILVER_HOTEL_BOOKING

    GROUP BY
        YEAR(CHECK_IN_TIMESTAMP)
)

SELECT

    BOOKING_YEAR,

    TOTAL_BOOKINGS,

    TOTAL_CONFIRMED_BOOKINGS,

    TOTAL_CANCELLED_BOOKINGS,

    TOTAL_COMPLETED_BOOKINGS,

    TOTAL_PENDING_BOOKINGS,

    -- ========================================================
    -- Difference between confirmed and cancelled
    -- ========================================================

    TOTAL_CONFIRMED_BOOKINGS
        - TOTAL_CANCELLED_BOOKINGS
        AS CONFIRMED_MINUS_CANCELLED,


    -- ========================================================
    -- CANCELLATION RATE
    --
    -- Cancelled / Confirmed × 100
    -- ========================================================

    ROUND(

        TOTAL_CANCELLED_BOOKINGS * 100.0

        /

        NULLIF(
            TOTAL_CONFIRMED_BOOKINGS,
            0
        ),

        2

    ) AS CANCELLATION_RATE_PCT

FROM YEARLY_BOOKINGS

ORDER BY BOOKING_YEAR;


-- ============================================================
-- 2. QUARTERLY CANCELLATION RATE
-- ============================================================

CREATE OR REPLACE TABLE GOLD_QUARTERLY_CANCELLATION_RATE AS

WITH QUARTERLY_BOOKINGS AS (

    SELECT

        DATE_TRUNC(
            'QUARTER',
            CHECK_IN_TIMESTAMP
        ) AS BOOKING_QUARTER,

        YEAR(CHECK_IN_TIMESTAMP) AS BOOKING_YEAR,

        QUARTER(CHECK_IN_TIMESTAMP) AS QUARTER_NUMBER,

        -- Total bookings
        COUNT(*) AS TOTAL_BOOKINGS,

        -- Confirmed bookings
        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'confirmed'
        ) AS TOTAL_CONFIRMED_BOOKINGS,

        -- Cancelled bookings
        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'cancelled'
        ) AS TOTAL_CANCELLED_BOOKINGS,

        -- Completed bookings
        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'completed'
        ) AS TOTAL_COMPLETED_BOOKINGS,

        -- Pending bookings
        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'pending'
        ) AS TOTAL_PENDING_BOOKINGS

    FROM SILVER_HOTEL_BOOKING

    GROUP BY

        DATE_TRUNC(
            'QUARTER',
            CHECK_IN_TIMESTAMP
        ),

        YEAR(CHECK_IN_TIMESTAMP),

        QUARTER(CHECK_IN_TIMESTAMP)
)

SELECT

    BOOKING_QUARTER,

    BOOKING_YEAR,

    QUARTER_NUMBER,

    TOTAL_BOOKINGS,

    TOTAL_CONFIRMED_BOOKINGS,

    TOTAL_CANCELLED_BOOKINGS,

    TOTAL_COMPLETED_BOOKINGS,

    TOTAL_PENDING_BOOKINGS,


    -- ========================================================
    -- Difference between confirmed and cancelled
    -- ========================================================

    TOTAL_CONFIRMED_BOOKINGS
        - TOTAL_CANCELLED_BOOKINGS
        AS CONFIRMED_MINUS_CANCELLED,


    -- ========================================================
    -- CANCELLATION RATE
    --
    -- Cancelled / Confirmed × 100
    -- ========================================================

    ROUND(

        TOTAL_CANCELLED_BOOKINGS * 100.0

        /

        NULLIF(
            TOTAL_CONFIRMED_BOOKINGS,
            0
        ),

        2

    ) AS CANCELLATION_RATE_PCT

FROM QUARTERLY_BOOKINGS

ORDER BY BOOKING_QUARTER;


-- ============================================================
-- 3. YEARLY RESULT
-- ============================================================

SELECT *

FROM GOLD_YEARLY_CANCELLATION_RATE

ORDER BY BOOKING_YEAR;


-- ============================================================
-- 4. QUARTERLY RESULT
-- ============================================================

SELECT *

FROM GOLD_QUARTERLY_CANCELLATION_RATE

ORDER BY BOOKING_QUARTER;


-- ============================================================
-- 5. HIGHEST CANCELLATION YEARS
-- ============================================================

SELECT

    BOOKING_YEAR,

    TOTAL_CONFIRMED_BOOKINGS,

    TOTAL_CANCELLED_BOOKINGS,

    CANCELLATION_RATE_PCT

FROM GOLD_YEARLY_CANCELLATION_RATE

ORDER BY CANCELLATION_RATE_PCT DESC;


-- ============================================================
-- 6. HIGHEST CANCELLATION QUARTERS
-- ============================================================

SELECT

    BOOKING_QUARTER,

    BOOKING_YEAR,

    QUARTER_NUMBER,

    TOTAL_CONFIRMED_BOOKINGS,

    TOTAL_CANCELLED_BOOKINGS,

    CANCELLATION_RATE_PCT

FROM GOLD_QUARTERLY_CANCELLATION_RATE

ORDER BY CANCELLATION_RATE_PCT DESC;