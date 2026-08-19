-- ============================================================
-- GOLD STATE 2
-- HOTEL BOOKING GROWTH ANALYSIS
--
-- Business Requirements:
--
-- 1. Day-by-day booking growth
-- 2. Running sum of all NON-CANCELLED bookings
-- 3. Month-by-month booking growth
-- 4. Quarter-by-quarter booking growth
-- 5. Year-on-year (YoY) booking growth
-- 6. Revenue growth from NON-CANCELLED bookings
--
-- Source:
--     SILVER_HOTEL_BOOKING
-- ============================================================


USE DATABASE RADISSONBLU_DB;
USE SCHEMA _HOTEL;

SELECT * FROM SILVER_HOTEL_BOOKING;

-- ============================================================
-- 1. DAILY BOOKING GROWTH
-- ============================================================

CREATE OR REPLACE TABLE GOLD_DAILY_BOOKING_GROWTH AS

WITH DAILY_DATA AS (

    SELECT

        DATE(CHECK_IN_TIMESTAMP) AS BOOKING_DATE,

        COUNT(*) AS TOTAL_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'
        ) AS NON_CANCELLED_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'cancelled'
        ) AS CANCELLED_BOOKINGS,

        SUM(
            CASE
                WHEN LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'
                THEN TOTAL_AMOUNTS
                ELSE 0
            END
        ) AS NON_CANCELLED_REVENUE,

        SUM(
            CASE
                WHEN LOWER(TRIM(BOOKING_STATUS)) = 'cancelled'
                THEN TOTAL_AMOUNTS
                ELSE 0
            END
        ) AS CANCELLED_REVENUE

    FROM SILVER_HOTEL_BOOKING

    GROUP BY
        DATE(CHECK_IN_TIMESTAMP)
)

SELECT

    BOOKING_DATE,

    TOTAL_BOOKINGS,

    NON_CANCELLED_BOOKINGS,

    CANCELLED_BOOKINGS,

    NON_CANCELLED_REVENUE,

    CANCELLED_REVENUE,

    -- --------------------------------------------------------
    -- Running / cumulative number of non-cancelled bookings
    -- --------------------------------------------------------

    SUM(NON_CANCELLED_BOOKINGS)
        OVER (
            ORDER BY BOOKING_DATE
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS RUNNING_NON_CANCELLED_BOOKINGS,

    -- --------------------------------------------------------
    -- Running revenue
    -- --------------------------------------------------------

    SUM(NON_CANCELLED_REVENUE)
        OVER (
            ORDER BY BOOKING_DATE
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS RUNNING_NON_CANCELLED_REVENUE,

    -- --------------------------------------------------------
    -- Previous day's bookings
    -- --------------------------------------------------------

    LAG(NON_CANCELLED_BOOKINGS)
        OVER (
            ORDER BY BOOKING_DATE
        ) AS PREVIOUS_DAY_BOOKINGS,

    -- --------------------------------------------------------
    -- Day-over-day absolute growth
    -- --------------------------------------------------------

    NON_CANCELLED_BOOKINGS
        - LAG(NON_CANCELLED_BOOKINGS)
            OVER (
                ORDER BY BOOKING_DATE
            ) AS DAY_OVER_DAY_GROWTH,

    -- --------------------------------------------------------
    -- Day-over-day percentage growth
    -- --------------------------------------------------------

    ROUND(
        (
            NON_CANCELLED_BOOKINGS
            - LAG(NON_CANCELLED_BOOKINGS)
                OVER (
                    ORDER BY BOOKING_DATE
                )
        )
        * 100.0
        /
        NULLIF(
            LAG(NON_CANCELLED_BOOKINGS)
                OVER (
                    ORDER BY BOOKING_DATE
                ),
            0
        ),
        2
    ) AS DAY_OVER_DAY_GROWTH_PCT

FROM DAILY_DATA

ORDER BY BOOKING_DATE;


-- ============================================================
-- 2. MONTHLY BOOKING GROWTH
-- ============================================================

CREATE OR REPLACE TABLE GOLD_MONTHLY_BOOKING_GROWTH AS

WITH MONTHLY_DATA AS (

    SELECT

        DATE_TRUNC(
            'MONTH',
            CHECK_IN_TIMESTAMP
        ) AS BOOKING_MONTH,

        YEAR(CHECK_IN_TIMESTAMP) AS BOOKING_YEAR,

        MONTH(CHECK_IN_TIMESTAMP) AS BOOKING_MONTH_NUMBER,

        COUNT(*) AS TOTAL_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'
        ) AS NON_CANCELLED_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'cancelled'
        ) AS CANCELLED_BOOKINGS,

        SUM(
            CASE
                WHEN LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'
                THEN TOTAL_AMOUNTS
                ELSE 0
            END
        ) AS NON_CANCELLED_REVENUE

    FROM SILVER_HOTEL_BOOKING

    GROUP BY
        DATE_TRUNC('MONTH', CHECK_IN_TIMESTAMP),
        YEAR(CHECK_IN_TIMESTAMP),
        MONTH(CHECK_IN_TIMESTAMP)
)

SELECT

    BOOKING_MONTH,

    BOOKING_YEAR,

    BOOKING_MONTH_NUMBER,

    TOTAL_BOOKINGS,

    NON_CANCELLED_BOOKINGS,

    CANCELLED_BOOKINGS,

    NON_CANCELLED_REVENUE,

    -- --------------------------------------------------------
    -- Previous month
    -- --------------------------------------------------------

    LAG(NON_CANCELLED_BOOKINGS)
        OVER (
            ORDER BY BOOKING_MONTH
        ) AS PREVIOUS_MONTH_BOOKINGS,

    -- --------------------------------------------------------
    -- Month-over-month absolute growth
    -- --------------------------------------------------------

    NON_CANCELLED_BOOKINGS
        - LAG(NON_CANCELLED_BOOKINGS)
            OVER (
                ORDER BY BOOKING_MONTH
            ) AS MONTH_OVER_MONTH_GROWTH,

    -- --------------------------------------------------------
    -- Month-over-month percentage growth
    -- --------------------------------------------------------

    ROUND(
        (
            NON_CANCELLED_BOOKINGS
            - LAG(NON_CANCELLED_BOOKINGS)
                OVER (
                    ORDER BY BOOKING_MONTH
                )
        )
        * 100.0
        /
        NULLIF(
            LAG(NON_CANCELLED_BOOKINGS)
                OVER (
                    ORDER BY BOOKING_MONTH
                ),
            0
        ),
        2
    ) AS MONTH_OVER_MONTH_GROWTH_PCT,

    -- --------------------------------------------------------
    -- Running monthly bookings
    -- --------------------------------------------------------

    SUM(NON_CANCELLED_BOOKINGS)
        OVER (
            ORDER BY BOOKING_MONTH
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS RUNNING_NON_CANCELLED_BOOKINGS,

    -- --------------------------------------------------------
    -- Running monthly revenue
    -- --------------------------------------------------------

    SUM(NON_CANCELLED_REVENUE)
        OVER (
            ORDER BY BOOKING_MONTH
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS RUNNING_NON_CANCELLED_REVENUE

FROM MONTHLY_DATA

ORDER BY BOOKING_MONTH;


-- ============================================================
-- 3. QUARTERLY BOOKING GROWTH
-- ============================================================

CREATE OR REPLACE TABLE GOLD_QUARTERLY_BOOKING_GROWTH AS

WITH QUARTERLY_DATA AS (

    SELECT

        DATE_TRUNC(
            'QUARTER',
            CHECK_IN_TIMESTAMP
        ) AS BOOKING_QUARTER,

        YEAR(CHECK_IN_TIMESTAMP) AS BOOKING_YEAR,

        QUARTER(CHECK_IN_TIMESTAMP) AS QUARTER_NUMBER,

        COUNT(*) AS TOTAL_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'
        ) AS NON_CANCELLED_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'cancelled'
        ) AS CANCELLED_BOOKINGS,

        SUM(
            CASE
                WHEN LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'
                THEN TOTAL_AMOUNTS
                ELSE 0
            END
        ) AS NON_CANCELLED_REVENUE

    FROM SILVER_HOTEL_BOOKING

    GROUP BY
        DATE_TRUNC('QUARTER', CHECK_IN_TIMESTAMP),
        YEAR(CHECK_IN_TIMESTAMP),
        QUARTER(CHECK_IN_TIMESTAMP)
)

SELECT

    BOOKING_QUARTER,

    BOOKING_YEAR,

    QUARTER_NUMBER,

    TOTAL_BOOKINGS,

    NON_CANCELLED_BOOKINGS,

    CANCELLED_BOOKINGS,

    NON_CANCELLED_REVENUE,

    -- --------------------------------------------------------
    -- Previous quarter
    -- --------------------------------------------------------

    LAG(NON_CANCELLED_BOOKINGS)
        OVER (
            ORDER BY BOOKING_QUARTER
        ) AS PREVIOUS_QUARTER_BOOKINGS,

    -- --------------------------------------------------------
    -- Quarter-over-quarter growth
    -- --------------------------------------------------------

    NON_CANCELLED_BOOKINGS
        - LAG(NON_CANCELLED_BOOKINGS)
            OVER (
                ORDER BY BOOKING_QUARTER
            ) AS QUARTER_OVER_QUARTER_GROWTH,

    -- --------------------------------------------------------
    -- Quarter-over-quarter percentage
    -- --------------------------------------------------------

    ROUND(
        (
            NON_CANCELLED_BOOKINGS
            - LAG(NON_CANCELLED_BOOKINGS)
                OVER (
                    ORDER BY BOOKING_QUARTER
                )
        )
        * 100.0
        /
        NULLIF(
            LAG(NON_CANCELLED_BOOKINGS)
                OVER (
                    ORDER BY BOOKING_QUARTER
                ),
            0
        ),
        2
    ) AS QUARTER_OVER_QUARTER_GROWTH_PCT,

    -- --------------------------------------------------------
    -- Running quarterly bookings
    -- --------------------------------------------------------

    SUM(NON_CANCELLED_BOOKINGS)
        OVER (
            ORDER BY BOOKING_QUARTER
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS RUNNING_NON_CANCELLED_BOOKINGS,

    -- --------------------------------------------------------
    -- Running quarterly revenue
    -- --------------------------------------------------------

    SUM(NON_CANCELLED_REVENUE)
        OVER (
            ORDER BY BOOKING_QUARTER
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS RUNNING_NON_CANCELLED_REVENUE

FROM QUARTERLY_DATA

ORDER BY BOOKING_QUARTER;


-- ============================================================
-- 4. YEARLY BOOKING GROWTH
-- ============================================================

CREATE OR REPLACE TABLE GOLD_YEARLY_BOOKING_GROWTH AS

WITH YEARLY_DATA AS (

    SELECT

        YEAR(CHECK_IN_TIMESTAMP) AS BOOKING_YEAR,

        COUNT(*) AS TOTAL_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'
        ) AS NON_CANCELLED_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(BOOKING_STATUS)) = 'cancelled'
        ) AS CANCELLED_BOOKINGS,

        SUM(
            CASE
                WHEN LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'
                THEN TOTAL_AMOUNTS
                ELSE 0
            END
        ) AS NON_CANCELLED_REVENUE

    FROM SILVER_HOTEL_BOOKING

    GROUP BY
        YEAR(CHECK_IN_TIMESTAMP)
)

SELECT

    BOOKING_YEAR,

    TOTAL_BOOKINGS,

    NON_CANCELLED_BOOKINGS,

    CANCELLED_BOOKINGS,

    NON_CANCELLED_REVENUE,

    -- --------------------------------------------------------
    -- Previous year
    -- --------------------------------------------------------

    LAG(NON_CANCELLED_BOOKINGS)
        OVER (
            ORDER BY BOOKING_YEAR
        ) AS PREVIOUS_YEAR_BOOKINGS,

    -- --------------------------------------------------------
    -- Year-over-year absolute growth
    -- --------------------------------------------------------

    NON_CANCELLED_BOOKINGS
        - LAG(NON_CANCELLED_BOOKINGS)
            OVER (
                ORDER BY BOOKING_YEAR
            ) AS YEAR_OVER_YEAR_GROWTH,

    -- --------------------------------------------------------
    -- Year-over-year percentage growth
    -- --------------------------------------------------------

    ROUND(
        (
            NON_CANCELLED_BOOKINGS
            - LAG(NON_CANCELLED_BOOKINGS)
                OVER (
                    ORDER BY BOOKING_YEAR
                )
        )
        * 100.0
        /
        NULLIF(
            LAG(NON_CANCELLED_BOOKINGS)
                OVER (
                    ORDER BY BOOKING_YEAR
                ),
            0
        ),
        2
    ) AS YEAR_OVER_YEAR_GROWTH_PCT,

    -- --------------------------------------------------------
    -- Running yearly bookings
    -- --------------------------------------------------------

    SUM(NON_CANCELLED_BOOKINGS)
        OVER (
            ORDER BY BOOKING_YEAR
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS RUNNING_NON_CANCELLED_BOOKINGS,

    -- --------------------------------------------------------
    -- Running yearly revenue
    -- --------------------------------------------------------

    SUM(NON_CANCELLED_REVENUE)
        OVER (
            ORDER BY BOOKING_YEAR
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS RUNNING_NON_CANCELLED_REVENUE

FROM YEARLY_DATA

ORDER BY BOOKING_YEAR;


-- ============================================================
-- 5. DAILY RESULT
-- ============================================================

SELECT *
FROM GOLD_DAILY_BOOKING_GROWTH
ORDER BY BOOKING_DATE;


-- ============================================================
-- 6. MONTHLY RESULT
-- ============================================================

SELECT *
FROM GOLD_MONTHLY_BOOKING_GROWTH
ORDER BY BOOKING_MONTH;


-- ============================================================
-- 7. QUARTERLY RESULT
-- ============================================================

SELECT *
FROM GOLD_QUARTERLY_BOOKING_GROWTH
ORDER BY BOOKING_QUARTER;


-- ============================================================
-- 8. YEARLY RESULT
-- ============================================================

SELECT *
FROM GOLD_YEARLY_BOOKING_GROWTH
ORDER BY BOOKING_YEAR;