-- ============================================================
-- GOLD STATE 3
-- GUEST SEGMENT & ROOM CAPACITY PLANNING
--
-- Business Requirements:
--
-- 1. Monthly:
--      - Corporate guest bookings
--      - Regular guest bookings
--      - VIP guest bookings
--      - Other guest bookings
--      - MoM growth
--
-- 2. Quarterly:
--      - Corporate guest bookings
--      - Regular guest bookings
--      - VIP guest bookings
--      - Other guest bookings
--      - QoQ growth
--
-- 3. Yearly:
--      - Corporate guest bookings
--      - Regular guest bookings
--      - VIP guest bookings
--      - Other guest bookings
--      - YoY growth
--
-- 4. Identify:
--      - Top months for VIP/CORPORATE bookings
--      - Top quarters for VIP/CORPORATE bookings
--
-- 5. Capacity Planning:
--      - Estimate rooms that should be reserved for
--        VIP and Corporate guests in future periods.
--
-- Source:
--      SILVER_HOTEL_BOOKING
-- ============================================================


USE DATABASE RADISSONBLU_DB;
USE SCHEMA _HOTEL;

SELECT * FROM SILVER_HOTEL_BOOKING;

-- ============================================================
-- 1. MONTHLY GUEST SEGMENT ANALYSIS
-- ============================================================

CREATE OR REPLACE TABLE GOLD_MONTHLY_GUEST_SEGMENT AS

WITH MONTHLY_DATA AS (

    SELECT

        DATE_TRUNC(
            'MONTH',
            CHECK_IN_TIMESTAMP
        ) AS BOOKING_MONTH,

        YEAR(CHECK_IN_TIMESTAMP) AS BOOKING_YEAR,

        MONTH(CHECK_IN_TIMESTAMP) AS MONTH_NUMBER,

        -- ----------------------------------------------------
        -- Total bookings
        -- ----------------------------------------------------

        COUNT(*) AS TOTAL_BOOKINGS,

        -- ----------------------------------------------------
        -- Guest segments
        -- ----------------------------------------------------

        COUNT_IF(
            LOWER(TRIM(GUEST_TYPE)) = 'regular'
        ) AS REGULAR_GUEST_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(GUEST_TYPE)) = 'corporate'
        ) AS CORPORATE_GUEST_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(GUEST_TYPE)) = 'vip'
        ) AS VIP_GUEST_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(GUEST_TYPE))
            NOT IN ('regular', 'corporate', 'vip')
            OR GUEST_TYPE IS NULL
        ) AS OTHER_GUEST_BOOKINGS,

        -- ----------------------------------------------------
        -- Rooms
        -- ----------------------------------------------------

        SUM(ROOMS_BOOKED) AS TOTAL_ROOMS_BOOKED,

        SUM(
            CASE
                WHEN LOWER(TRIM(GUEST_TYPE))
                    IN ('vip', 'corporate')
                THEN ROOMS_BOOKED
                ELSE 0
            END
        ) AS VIP_CORPORATE_ROOMS_BOOKED,

        -- ----------------------------------------------------
        -- Revenue
        -- ----------------------------------------------------

        SUM(
            CASE
                WHEN LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'
                THEN TOTAL_AMOUNTS
                ELSE 0
            END
        ) AS NON_CANCELLED_REVENUE

    FROM SILVER_HOTEL_BOOKING

    WHERE LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'

    GROUP BY

        DATE_TRUNC(
            'MONTH',
            CHECK_IN_TIMESTAMP
        ),

        YEAR(CHECK_IN_TIMESTAMP),

        MONTH(CHECK_IN_TIMESTAMP)
)

SELECT

    BOOKING_MONTH,

    BOOKING_YEAR,

    MONTH_NUMBER,

    TOTAL_BOOKINGS,

    REGULAR_GUEST_BOOKINGS,

    CORPORATE_GUEST_BOOKINGS,

    VIP_GUEST_BOOKINGS,

    OTHER_GUEST_BOOKINGS,

    TOTAL_ROOMS_BOOKED,

    VIP_CORPORATE_ROOMS_BOOKED,

    NON_CANCELLED_REVENUE,


    -- ========================================================
    -- VIP + Corporate combined
    -- ========================================================

    (
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    ) AS VIP_CORPORATE_BOOKINGS,


    -- ========================================================
    -- VIP + Corporate percentage
    -- ========================================================

    ROUND(
        (
            VIP_GUEST_BOOKINGS
            + CORPORATE_GUEST_BOOKINGS
        ) * 100.0
        /
        NULLIF(TOTAL_BOOKINGS, 0),
        2
    ) AS VIP_CORPORATE_BOOKING_PCT,


    -- ========================================================
    -- Previous month
    -- ========================================================

    LAG(
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    )
    OVER (
        ORDER BY BOOKING_MONTH
    ) AS PREVIOUS_MONTH_VIP_CORPORATE_BOOKINGS,


    -- ========================================================
    -- MoM absolute growth
    -- ========================================================

    (
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    )
    -
    LAG(
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    )
    OVER (
        ORDER BY BOOKING_MONTH
    ) AS MOM_VIP_CORPORATE_GROWTH,


    -- ========================================================
    -- MoM percentage growth
    -- ========================================================

    ROUND(

        (
            (
                VIP_GUEST_BOOKINGS
                + CORPORATE_GUEST_BOOKINGS
            )
            -
            LAG(
                VIP_GUEST_BOOKINGS
                + CORPORATE_GUEST_BOOKINGS
            )
            OVER (
                ORDER BY BOOKING_MONTH
            )
        )
        * 100.0

        /

        NULLIF(
            LAG(
                VIP_GUEST_BOOKINGS
                + CORPORATE_GUEST_BOOKINGS
            )
            OVER (
                ORDER BY BOOKING_MONTH
            ),
            0
        ),

        2

    ) AS MOM_VIP_CORPORATE_GROWTH_PCT


FROM MONTHLY_DATA

ORDER BY BOOKING_MONTH;


-- ============================================================
-- 2. QUARTERLY GUEST SEGMENT ANALYSIS
-- ============================================================

CREATE OR REPLACE TABLE GOLD_QUARTERLY_GUEST_SEGMENT AS

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
            LOWER(TRIM(GUEST_TYPE)) = 'regular'
        ) AS REGULAR_GUEST_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(GUEST_TYPE)) = 'corporate'
        ) AS CORPORATE_GUEST_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(GUEST_TYPE)) = 'vip'
        ) AS VIP_GUEST_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(GUEST_TYPE))
            NOT IN ('regular', 'corporate', 'vip')
            OR GUEST_TYPE IS NULL
        ) AS OTHER_GUEST_BOOKINGS,

        SUM(ROOMS_BOOKED) AS TOTAL_ROOMS_BOOKED,

        SUM(
            CASE
                WHEN LOWER(TRIM(GUEST_TYPE))
                    IN ('vip', 'corporate')
                THEN ROOMS_BOOKED
                ELSE 0
            END
        ) AS VIP_CORPORATE_ROOMS_BOOKED,

        SUM(TOTAL_AMOUNTS) AS TOTAL_REVENUE

    FROM SILVER_HOTEL_BOOKING

    WHERE LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'

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

    REGULAR_GUEST_BOOKINGS,

    CORPORATE_GUEST_BOOKINGS,

    VIP_GUEST_BOOKINGS,

    OTHER_GUEST_BOOKINGS,

    TOTAL_ROOMS_BOOKED,

    VIP_CORPORATE_ROOMS_BOOKED,

    TOTAL_REVENUE,

    (
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    ) AS VIP_CORPORATE_BOOKINGS,

    ROUND(
        (
            VIP_GUEST_BOOKINGS
            + CORPORATE_GUEST_BOOKINGS
        ) * 100.0
        /
        NULLIF(TOTAL_BOOKINGS, 0),
        2
    ) AS VIP_CORPORATE_BOOKING_PCT,


    -- ========================================================
    -- Previous quarter
    -- ========================================================

    LAG(
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    )
    OVER (
        ORDER BY BOOKING_QUARTER
    ) AS PREVIOUS_QUARTER_VIP_CORPORATE_BOOKINGS,


    -- ========================================================
    -- QoQ growth
    -- ========================================================

    (
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    )
    -
    LAG(
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    )
    OVER (
        ORDER BY BOOKING_QUARTER
    ) AS QOQ_VIP_CORPORATE_GROWTH,


    ROUND(

        (
            (
                VIP_GUEST_BOOKINGS
                + CORPORATE_GUEST_BOOKINGS
            )
            -
            LAG(
                VIP_GUEST_BOOKINGS
                + CORPORATE_GUEST_BOOKINGS
            )
            OVER (
                ORDER BY BOOKING_QUARTER
            )
        )
        * 100.0

        /

        NULLIF(
            LAG(
                VIP_GUEST_BOOKINGS
                + CORPORATE_GUEST_BOOKINGS
            )
            OVER (
                ORDER BY BOOKING_QUARTER
            ),
            0
        ),

        2

    ) AS QOQ_VIP_CORPORATE_GROWTH_PCT


FROM QUARTERLY_DATA

ORDER BY BOOKING_QUARTER;


-- ============================================================
-- 3. YEARLY GUEST SEGMENT ANALYSIS
-- ============================================================

CREATE OR REPLACE TABLE GOLD_YEARLY_GUEST_SEGMENT AS

WITH YEARLY_DATA AS (

    SELECT

        YEAR(CHECK_IN_TIMESTAMP) AS BOOKING_YEAR,

        COUNT(*) AS TOTAL_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(GUEST_TYPE)) = 'regular'
        ) AS REGULAR_GUEST_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(GUEST_TYPE)) = 'corporate'
        ) AS CORPORATE_GUEST_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(GUEST_TYPE)) = 'vip'
        ) AS VIP_GUEST_BOOKINGS,

        COUNT_IF(
            LOWER(TRIM(GUEST_TYPE))
            NOT IN ('regular', 'corporate', 'vip')
            OR GUEST_TYPE IS NULL
        ) AS OTHER_GUEST_BOOKINGS,

        SUM(ROOMS_BOOKED) AS TOTAL_ROOMS_BOOKED,

        SUM(
            CASE
                WHEN LOWER(TRIM(GUEST_TYPE))
                    IN ('vip', 'corporate')
                THEN ROOMS_BOOKED
                ELSE 0
            END
        ) AS VIP_CORPORATE_ROOMS_BOOKED,

        SUM(TOTAL_AMOUNTS) AS TOTAL_REVENUE

    FROM SILVER_HOTEL_BOOKING

    WHERE LOWER(TRIM(BOOKING_STATUS)) <> 'cancelled'

    GROUP BY
        YEAR(CHECK_IN_TIMESTAMP)
)

SELECT

    BOOKING_YEAR,

    TOTAL_BOOKINGS,

    REGULAR_GUEST_BOOKINGS,

    CORPORATE_GUEST_BOOKINGS,

    VIP_GUEST_BOOKINGS,

    OTHER_GUEST_BOOKINGS,

    TOTAL_ROOMS_BOOKED,

    VIP_CORPORATE_ROOMS_BOOKED,

    TOTAL_REVENUE,

    (
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    ) AS VIP_CORPORATE_BOOKINGS,

    ROUND(
        (
            VIP_GUEST_BOOKINGS
            + CORPORATE_GUEST_BOOKINGS
        ) * 100.0
        /
        NULLIF(TOTAL_BOOKINGS, 0),
        2
    ) AS VIP_CORPORATE_BOOKING_PCT,


    -- ========================================================
    -- Previous year
    -- ========================================================

    LAG(
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    )
    OVER (
        ORDER BY BOOKING_YEAR
    ) AS PREVIOUS_YEAR_VIP_CORPORATE_BOOKINGS,


    -- ========================================================
    -- YoY growth
    -- ========================================================

    (
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    )
    -
    LAG(
        VIP_GUEST_BOOKINGS
        + CORPORATE_GUEST_BOOKINGS
    )
    OVER (
        ORDER BY BOOKING_YEAR
    ) AS YOY_VIP_CORPORATE_GROWTH,


    ROUND(

        (
            (
                VIP_GUEST_BOOKINGS
                + CORPORATE_GUEST_BOOKINGS
            )
            -
            LAG(
                VIP_GUEST_BOOKINGS
                + CORPORATE_GUEST_BOOKINGS
            )
            OVER (
                ORDER BY BOOKING_YEAR
            )
        )
        * 100.0

        /

        NULLIF(
            LAG(
                VIP_GUEST_BOOKINGS
                + CORPORATE_GUEST_BOOKINGS
            )
            OVER (
                ORDER BY BOOKING_YEAR
            ),
            0
        ),

        2

    ) AS YOY_VIP_CORPORATE_GROWTH_PCT


FROM YEARLY_DATA

ORDER BY BOOKING_YEAR;


-- ============================================================
-- 4. TOP MONTHS FOR VIP + CORPORATE BOOKINGS
-- ============================================================

CREATE OR REPLACE TABLE GOLD_TOP_MONTHS_VIP_CORPORATE AS

SELECT

    MONTH_NUMBER,

    TO_CHAR(
        BOOKING_MONTH,
        'MMMM'
    ) AS MONTH_NAME,

    SUM(VIP_CORPORATE_BOOKINGS)
        AS TOTAL_VIP_CORPORATE_BOOKINGS,

    SUM(VIP_CORPORATE_ROOMS_BOOKED)
        AS TOTAL_VIP_CORPORATE_ROOMS,

    ROUND(
        AVG(VIP_CORPORATE_BOOKING_PCT),
        2
    ) AS AVG_VIP_CORPORATE_BOOKING_PCT,

    RANK()
        OVER (
            ORDER BY
                SUM(VIP_CORPORATE_BOOKINGS) DESC
        ) AS MONTH_RANK

FROM GOLD_MONTHLY_GUEST_SEGMENT

GROUP BY
    MONTH_NUMBER,
    TO_CHAR(BOOKING_MONTH, 'MMMM')

ORDER BY MONTH_RANK;


-- ============================================================
-- 5. TOP QUARTERS FOR VIP + CORPORATE BOOKINGS
-- ============================================================

CREATE OR REPLACE TABLE GOLD_TOP_QUARTERS_VIP_CORPORATE AS

SELECT

    QUARTER_NUMBER,

    'Q' || QUARTER_NUMBER AS QUARTER_NAME,

    SUM(VIP_CORPORATE_BOOKINGS)
        AS TOTAL_VIP_CORPORATE_BOOKINGS,

    SUM(VIP_CORPORATE_ROOMS_BOOKED)
        AS TOTAL_VIP_CORPORATE_ROOMS,

    ROUND(
        AVG(VIP_CORPORATE_BOOKING_PCT),
        2
    ) AS AVG_VIP_CORPORATE_BOOKING_PCT,

    RANK()
        OVER (
            ORDER BY
                SUM(VIP_CORPORATE_BOOKINGS) DESC
        ) AS QUARTER_RANK

FROM GOLD_QUARTERLY_GUEST_SEGMENT

GROUP BY
    QUARTER_NUMBER

ORDER BY QUARTER_RANK;


-- ============================================================
-- 6. ROOM CAPACITY RECOMMENDATION BY MONTH
--
-- Logic:
--
-- Calculate the historical average number of rooms booked
-- by VIP + Corporate guests for each calendar month.
--
-- Recommended rooms =
-- CEIL(historical average rooms * 1.20)
--
-- 20% buffer is maintained for future demand.
-- ============================================================

CREATE OR REPLACE TABLE GOLD_MONTHLY_ROOM_CAPACITY_PLAN AS

SELECT

    MONTH_NUMBER,

    TO_CHAR(
        BOOKING_MONTH,
        'MMMM'
    ) AS MONTH_NAME,

    ROUND(
        AVG(VIP_CORPORATE_ROOMS_BOOKED),
        2
    ) AS AVG_VIP_CORPORATE_ROOMS,

    CEIL(
        AVG(VIP_CORPORATE_ROOMS_BOOKED) * 1.20
    ) AS RECOMMENDED_RESERVED_ROOMS,

    20 AS SAFETY_BUFFER_PERCENT,

    CASE

        WHEN AVG(VIP_CORPORATE_ROOMS_BOOKED) >= 10
            THEN 'HIGH PRIORITY'

        WHEN AVG(VIP_CORPORATE_ROOMS_BOOKED) >= 5
            THEN 'MEDIUM PRIORITY'

        ELSE 'LOW PRIORITY'

    END AS ROOM_ALLOCATION_PRIORITY

FROM GOLD_MONTHLY_GUEST_SEGMENT

GROUP BY

    MONTH_NUMBER,

    TO_CHAR(
        BOOKING_MONTH,
        'MMMM'
    )

ORDER BY MONTH_NUMBER;


-- ============================================================
-- 7. ROOM CAPACITY RECOMMENDATION BY QUARTER
-- ============================================================

CREATE OR REPLACE TABLE GOLD_QUARTERLY_ROOM_CAPACITY_PLAN AS

SELECT

    QUARTER_NUMBER,

    'Q' || QUARTER_NUMBER AS QUARTER_NAME,

    ROUND(
        AVG(VIP_CORPORATE_ROOMS_BOOKED),
        2
    ) AS AVG_VIP_CORPORATE_ROOMS,

    CEIL(
        AVG(VIP_CORPORATE_ROOMS_BOOKED) * 1.20
    ) AS RECOMMENDED_RESERVED_ROOMS,

    20 AS SAFETY_BUFFER_PERCENT,

    CASE

        WHEN AVG(VIP_CORPORATE_ROOMS_BOOKED) >= 30
            THEN 'HIGH PRIORITY'

        WHEN AVG(VIP_CORPORATE_ROOMS_BOOKED) >= 15
            THEN 'MEDIUM PRIORITY'

        ELSE 'LOW PRIORITY'

    END AS ROOM_ALLOCATION_PRIORITY

FROM GOLD_QUARTERLY_GUEST_SEGMENT

GROUP BY QUARTER_NUMBER

ORDER BY QUARTER_NUMBER;


-- ============================================================
-- 8. FINAL MONTHLY REPORT
-- ============================================================

SELECT *

FROM GOLD_MONTHLY_GUEST_SEGMENT

ORDER BY BOOKING_MONTH;


-- ============================================================
-- 9. FINAL QUARTERLY REPORT
-- ============================================================

SELECT *

FROM GOLD_QUARTERLY_GUEST_SEGMENT

ORDER BY BOOKING_QUARTER;


-- ============================================================
-- 10. FINAL YEARLY REPORT
-- ============================================================

SELECT *

FROM GOLD_YEARLY_GUEST_SEGMENT

ORDER BY BOOKING_YEAR;


-- ============================================================
-- 11. TOP MONTHS
-- ============================================================

SELECT *

FROM GOLD_TOP_MONTHS_VIP_CORPORATE

ORDER BY MONTH_RANK;


-- ============================================================
-- 12. TOP QUARTERS
-- ============================================================

SELECT *

FROM GOLD_TOP_QUARTERS_VIP_CORPORATE

ORDER BY QUARTER_RANK;


-- ============================================================
-- 13. ROOM ALLOCATION PLAN
-- ============================================================

SELECT *

FROM GOLD_MONTHLY_ROOM_CAPACITY_PLAN

ORDER BY MONTH_NUMBER;


-- ============================================================
-- 14. QUARTERLY ROOM ALLOCATION PLAN
-- ============================================================

SELECT *

FROM GOLD_QUARTERLY_ROOM_CAPACITY_PLAN

ORDER BY QUARTER_NUMBER;