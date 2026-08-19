USE RADISSONBLU_DB._HOTEL;

-- ============================================================
-- RADISSON BLU HOTEL BOOKING PROJECT
-- SILVER LAYER
-- ============================================================

USE DATABASE RADISSONBLU_DB;
USE SCHEMA _HOTEL;


-- ============================================================
-- 1. DROP / CREATE SILVER TABLE
--    Same column sequence as BRONZE_HOTEL_BOOKING
-- ============================================================

CREATE OR REPLACE TABLE SILVER_HOTEL_BOOKING (
    BOOKING_ID                  VARCHAR(300),
    HOTEL_NAME                  VARCHAR(255),
    HOTEL_CITY                  VARCHAR(100),
    HOTEL_STATE                 VARCHAR(150),
    HOTEL_ZIPCODE               VARCHAR(20),
    HOTEL_COUNTRY               VARCHAR(100),
    BOOKING_FOR                 VARCHAR(50),
    NUMBERS_OF_PERSONS          NUMBER(5,0),
    ADULTS                      NUMBER(5,0),
    CHILDRENS                   NUMBER(5,0),
    DAYS_OF_STAYS               NUMBER(5,0),
    CHECK_IN_TIMESTAMP          TIMESTAMP_NTZ,
    CHECK_OUT_TIMESTAMP         TIMESTAMP_NTZ,
    REQUIRES_TRAVELS_FACILITY   VARCHAR(10),
    MODE_OF_TRAVELS             VARCHAR(100),
    AMOUNT                      NUMBER(18,2),
    DISCOUNT_CATEGORY           VARCHAR(100),
    SPECIAL_DISCOUNT            NUMBER(18,2),
    TAX                         NUMBER(18,2),
    TOTAL_AMOUNTS               NUMBER(18,2),
    ROOMS_BOOKED                NUMBER(5,0),
    ROOM_TYPE                   VARCHAR(100),
    BOOKING_SOURCE              VARCHAR(100),
    PAYMENT_METHOD              VARCHAR(50),
    GUEST_EMAIL                 VARCHAR(255),
    BOOKING_STATUS              VARCHAR(50),
    ROOM_NUMBER                 VARCHAR(20),
    GUEST_TYPE                  VARCHAR(50),
    GUEST_AGE                   NUMBER(5,0),
    GUEST_GENDER                VARCHAR(20)
);


-- ============================================================
-- 2. CREATE QUARANTINE TABLE
--
-- Stores records which fail one or more DQ rules.
-- ============================================================

CREATE OR REPLACE TABLE QUARANTINE_HOTEL_BOOKING (
    BOOKING_ID                  VARCHAR(300),
    HOTEL_NAME                  VARCHAR(255),
    HOTEL_CITY                  VARCHAR(100),
    HOTEL_STATE                 VARCHAR(150),
    HOTEL_ZIPCODE               VARCHAR(20),
    HOTEL_COUNTRY               VARCHAR(100),
    BOOKING_FOR                 VARCHAR(50),
    NUMBERS_OF_PERSONS          NUMBER(5,0),
    ADULTS                      NUMBER(5,0),
    CHILDRENS                   NUMBER(5,0),
    DAYS_OF_STAYS               NUMBER(5,0),
    CHECK_IN_TIMESTAMP          TIMESTAMP_NTZ,
    CHECK_OUT_TIMESTAMP         TIMESTAMP_NTZ,
    REQUIRES_TRAVELS_FACILITY   VARCHAR(10),
    MODE_OF_TRAVELS             VARCHAR(100),
    AMOUNT                      NUMBER(18,2),
    DISCOUNT_CATEGORY           VARCHAR(100),
    SPECIAL_DISCOUNT            NUMBER(18,2),
    TAX                         NUMBER(18,2),
    TOTAL_AMOUNTS               NUMBER(18,2),
    ROOMS_BOOKED                NUMBER(5,0),
    ROOM_TYPE                   VARCHAR(100),
    BOOKING_SOURCE              VARCHAR(100),
    PAYMENT_METHOD              VARCHAR(50),
    GUEST_EMAIL                 VARCHAR(255),
    BOOKING_STATUS              VARCHAR(50),
    ROOM_NUMBER                 VARCHAR(20),
    GUEST_TYPE                  VARCHAR(50),
    GUEST_AGE                   NUMBER(5,0),
    GUEST_GENDER                VARCHAR(20),

    REJECTION_REASON            VARCHAR(2000),
    REJECTED_AT                 TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);


-- ============================================================
-- 3. DATA QUALITY CHECKS
--    These SELECT statements allow us to inspect bad records
--    before inserting them into Silver / Quarantine.
-- ============================================================


-- ------------------------------------------------------------
-- 3.1 NULL / BLANK BOOKING_ID
-- ------------------------------------------------------------

SELECT *
FROM BRONZE_HOTEL_BOOKING
WHERE BOOKING_ID IS NULL
   OR TRIM(BOOKING_ID) = '';


-- ------------------------------------------------------------
-- 3.2 NULL / INVALID EMAIL
--
-- Invalid patterns:
-- invalid-email
-- user@
-- @example.com
-- guest.example.com
-- user@@example.com
-- user@.com
-- user domain@example.com
-- guest#example.com
-- missing-at-sign.com
-- user@example
-- None
-- ''
-- john..doe@example.com
-- user@domain..com
-- ------------------------------------------------------------

SELECT
    BOOKING_ID,
    GUEST_EMAIL
FROM BRONZE_HOTEL_BOOKING
WHERE
       GUEST_EMAIL IS NULL
    OR TRIM(GUEST_EMAIL) = ''
    OR LOWER(TRIM(GUEST_EMAIL)) = 'none'
    OR GUEST_EMAIL NOT LIKE '%_@_%.__%'
    OR GUEST_EMAIL LIKE '% %'
    OR GUEST_EMAIL LIKE '%@@%'
    OR GUEST_EMAIL LIKE '%@.%'
    OR GUEST_EMAIL LIKE '%#%'
    OR GUEST_EMAIL LIKE '%..%';


-- ------------------------------------------------------------
-- 3.3 NEGATIVE AMOUNT
-- ------------------------------------------------------------

SELECT
    BOOKING_ID,
    AMOUNT
FROM BRONZE_HOTEL_BOOKING
WHERE AMOUNT < 0;


-- ------------------------------------------------------------
-- 3.4 NEGATIVE SPECIAL DISCOUNT
-- ------------------------------------------------------------

SELECT
    BOOKING_ID,
    SPECIAL_DISCOUNT
FROM BRONZE_HOTEL_BOOKING
WHERE SPECIAL_DISCOUNT < 0;


-- ------------------------------------------------------------
-- 3.5 NEGATIVE TAX
-- ------------------------------------------------------------

SELECT
    BOOKING_ID,
    TAX
FROM BRONZE_HOTEL_BOOKING
WHERE TAX < 0;


-- ------------------------------------------------------------
-- 3.6 TOTAL AMOUNT MUST BE GREATER THAN ZERO
-- ------------------------------------------------------------

SELECT
    BOOKING_ID,
    TOTAL_AMOUNTS
FROM BRONZE_HOTEL_BOOKING
WHERE TOTAL_AMOUNTS <= 0
   OR TOTAL_AMOUNTS IS NULL;


-- ------------------------------------------------------------
-- 3.7 CHECK-OUT MUST BE GREATER THAN CHECK-IN
-- ------------------------------------------------------------

SELECT
    BOOKING_ID,
    CHECK_IN_TIMESTAMP,
    CHECK_OUT_TIMESTAMP
FROM BRONZE_HOTEL_BOOKING
WHERE CHECK_IN_TIMESTAMP IS NULL
   OR CHECK_OUT_TIMESTAMP IS NULL
   OR CHECK_OUT_TIMESTAMP <= CHECK_IN_TIMESTAMP;


-- ------------------------------------------------------------
-- 3.8 DAYS OF STAY MUST BE GREATER THAN ZERO
-- ------------------------------------------------------------

SELECT
    BOOKING_ID,
    DAYS_OF_STAYS
FROM BRONZE_HOTEL_BOOKING
WHERE DAYS_OF_STAYS IS NULL
   OR DAYS_OF_STAYS <= 0;


-- ------------------------------------------------------------
-- 3.9 NUMBER OF PERSONS MUST BE GREATER THAN ZERO
-- ------------------------------------------------------------

SELECT
    BOOKING_ID,
    NUMBERS_OF_PERSONS
FROM BRONZE_HOTEL_BOOKING
WHERE NUMBERS_OF_PERSONS IS NULL
   OR NUMBERS_OF_PERSONS <= 0;


-- ------------------------------------------------------------
-- 3.10 ADULTS + CHILDRENS MUST EQUAL NUMBERS_OF_PERSONS
-- ------------------------------------------------------------

SELECT
    BOOKING_ID,
    NUMBERS_OF_PERSONS,
    ADULTS,
    CHILDRENS
FROM BRONZE_HOTEL_BOOKING
WHERE COALESCE(ADULTS, 0) + COALESCE(CHILDRENS, 0)
      <> NUMBERS_OF_PERSONS;


-- ------------------------------------------------------------
-- 3.11 ROOMS BOOKED MUST BE GREATER THAN ZERO
-- ------------------------------------------------------------

SELECT
    BOOKING_ID,
    ROOMS_BOOKED
FROM BRONZE_HOTEL_BOOKING
WHERE ROOMS_BOOKED IS NULL
   OR ROOMS_BOOKED <= 0;


-- ============================================================
-- 4. DUPLICATE CHECK
--
-- BOOKING_ID + BOOKING_STATUS must be unique
-- ============================================================

SELECT
    BOOKING_ID,
    BOOKING_STATUS,
    COUNT(*) AS DUPLICATE_COUNT
FROM BRONZE_HOTEL_BOOKING
GROUP BY
    BOOKING_ID,
    BOOKING_STATUS
HAVING COUNT(*) > 1
ORDER BY DUPLICATE_COUNT DESC;


-- ============================================================
-- 5. INSERT INVALID RECORDS INTO QUARANTINE
--
-- A record can have multiple DQ failures.
-- ARRAY_CONSTRUCT_COMPACT is used so we can preserve
-- multiple rejection reasons.
-- ============================================================

INSERT INTO QUARANTINE_HOTEL_BOOKING (
    BOOKING_ID,
    HOTEL_NAME,
    HOTEL_CITY,
    HOTEL_STATE,
    HOTEL_ZIPCODE,
    HOTEL_COUNTRY,
    BOOKING_FOR,
    NUMBERS_OF_PERSONS,
    ADULTS,
    CHILDRENS,
    DAYS_OF_STAYS,
    CHECK_IN_TIMESTAMP,
    CHECK_OUT_TIMESTAMP,
    REQUIRES_TRAVELS_FACILITY,
    MODE_OF_TRAVELS,
    AMOUNT,
    DISCOUNT_CATEGORY,
    SPECIAL_DISCOUNT,
    TAX,
    TOTAL_AMOUNTS,
    ROOMS_BOOKED,
    ROOM_TYPE,
    BOOKING_SOURCE,
    PAYMENT_METHOD,
    GUEST_EMAIL,
    BOOKING_STATUS,
    ROOM_NUMBER,
    GUEST_TYPE,
    GUEST_AGE,
    GUEST_GENDER,
    REJECTION_REASON
)

WITH DUPLICATES AS (

    SELECT
        BOOKING_ID,
        BOOKING_STATUS
    FROM BRONZE_HOTEL_BOOKING
    GROUP BY
        BOOKING_ID,
        BOOKING_STATUS
    HAVING COUNT(*) > 1

),

DQ AS (

    SELECT
        B.*,

        ARRAY_TO_STRING(
            ARRAY_CONSTRUCT_COMPACT(

                IFF(
                    B.BOOKING_ID IS NULL
                    OR TRIM(B.BOOKING_ID) = '',
                    'NULL_OR_BLANK_BOOKING_ID',
                    NULL
                ),

                IFF(
                    B.GUEST_EMAIL IS NULL
                    OR TRIM(B.GUEST_EMAIL) = '',
                    'NULL_OR_BLANK_EMAIL',
                    NULL
                ),

                IFF(
                    LOWER(TRIM(COALESCE(B.GUEST_EMAIL, ''))) = 'none',
                    'INVALID_EMAIL_NONE',
                    NULL
                ),

                IFF(
                    B.GUEST_EMAIL IS NOT NULL
                    AND TRIM(B.GUEST_EMAIL) <> ''
                    AND LOWER(TRIM(B.GUEST_EMAIL)) <> 'none'
                    AND (
                        B.GUEST_EMAIL NOT LIKE '%_@_%.__%'
                        OR B.GUEST_EMAIL LIKE '% %'
                        OR B.GUEST_EMAIL LIKE '%@@%'
                        OR B.GUEST_EMAIL LIKE '%@.%'
                        OR B.GUEST_EMAIL LIKE '%#%'
                        OR B.GUEST_EMAIL LIKE '%..%'
                    ),
                    'INVALID_EMAIL_FORMAT',
                    NULL
                ),

                IFF(
                    B.AMOUNT IS NULL
                    OR B.AMOUNT < 0,
                    'NEGATIVE_OR_NULL_AMOUNT',
                    NULL
                ),

                IFF(
                    B.SPECIAL_DISCOUNT IS NOT NULL
                    AND B.SPECIAL_DISCOUNT < 0,
                    'NEGATIVE_SPECIAL_DISCOUNT',
                    NULL
                ),

                IFF(
                    B.TAX IS NOT NULL
                    AND B.TAX < 0,
                    'NEGATIVE_TAX',
                    NULL
                ),

                IFF(
                    B.TOTAL_AMOUNTS IS NULL
                    OR B.TOTAL_AMOUNTS <= 0,
                    'INVALID_TOTAL_AMOUNT',
                    NULL
                ),

                IFF(
                    B.CHECK_IN_TIMESTAMP IS NULL
                    OR B.CHECK_OUT_TIMESTAMP IS NULL,
                    'NULL_CHECK_IN_OR_CHECK_OUT',
                    NULL
                ),

                IFF(
                    B.CHECK_IN_TIMESTAMP IS NOT NULL
                    AND B.CHECK_OUT_TIMESTAMP IS NOT NULL
                    AND B.CHECK_OUT_TIMESTAMP <= B.CHECK_IN_TIMESTAMP,
                    'CHECKOUT_NOT_GREATER_THAN_CHECKIN',
                    NULL
                ),

                IFF(
                    B.DAYS_OF_STAYS IS NULL
                    OR B.DAYS_OF_STAYS <= 0,
                    'INVALID_DAYS_OF_STAY',
                    NULL
                ),

                IFF(
                    B.NUMBERS_OF_PERSONS IS NULL
                    OR B.NUMBERS_OF_PERSONS <= 0,
                    'INVALID_NUMBER_OF_PERSONS',
                    NULL
                ),

                IFF(
                    COALESCE(B.ADULTS, 0)
                    + COALESCE(B.CHILDRENS, 0)
                    <> B.NUMBERS_OF_PERSONS,
                    'PERSON_COUNT_MISMATCH',
                    NULL
                ),

                IFF(
                    B.ROOMS_BOOKED IS NULL
                    OR B.ROOMS_BOOKED <= 0,
                    'INVALID_ROOMS_BOOKED',
                    NULL
                ),

                IFF(
                    D.BOOKING_ID IS NOT NULL,
                    'DUPLICATE_BOOKING_ID_STATUS',
                    NULL
                )

            ),
            ' | '
        ) AS REJECTION_REASON

    FROM BRONZE_HOTEL_BOOKING B

    LEFT JOIN DUPLICATES D
        ON B.BOOKING_ID = D.BOOKING_ID
       AND B.BOOKING_STATUS = D.BOOKING_STATUS
)

SELECT
    BOOKING_ID,
    HOTEL_NAME,
    HOTEL_CITY,
    HOTEL_STATE,
    HOTEL_ZIPCODE,
    HOTEL_COUNTRY,
    BOOKING_FOR,
    NUMBERS_OF_PERSONS,
    ADULTS,
    CHILDRENS,
    DAYS_OF_STAYS,
    CHECK_IN_TIMESTAMP,
    CHECK_OUT_TIMESTAMP,
    REQUIRES_TRAVELS_FACILITY,
    MODE_OF_TRAVELS,
    AMOUNT,
    DISCOUNT_CATEGORY,
    SPECIAL_DISCOUNT,
    TAX,
    TOTAL_AMOUNTS,
    ROOMS_BOOKED,
    ROOM_TYPE,
    BOOKING_SOURCE,
    PAYMENT_METHOD,
    GUEST_EMAIL,
    BOOKING_STATUS,
    ROOM_NUMBER,
    GUEST_TYPE,
    GUEST_AGE,
    GUEST_GENDER,
    REJECTION_REASON

FROM DQ

WHERE REJECTION_REASON IS NOT NULL
  AND TRIM(REJECTION_REASON) <> '';


-- ============================================================
-- 6. INSERT CLEAN RECORDS INTO SILVER
--
-- Only records which pass ALL DQ rules.
--
-- ROW_NUMBER() is used to handle duplicate
-- BOOKING_ID + BOOKING_STATUS combinations.
-- ============================================================

INSERT INTO SILVER_HOTEL_BOOKING (
    BOOKING_ID,
    HOTEL_NAME,
    HOTEL_CITY,
    HOTEL_STATE,
    HOTEL_ZIPCODE,
    HOTEL_COUNTRY,
    BOOKING_FOR,
    NUMBERS_OF_PERSONS,
    ADULTS,
    CHILDRENS,
    DAYS_OF_STAYS,
    CHECK_IN_TIMESTAMP,
    CHECK_OUT_TIMESTAMP,
    REQUIRES_TRAVELS_FACILITY,
    MODE_OF_TRAVELS,
    AMOUNT,
    DISCOUNT_CATEGORY,
    SPECIAL_DISCOUNT,
    TAX,
    TOTAL_AMOUNTS,
    ROOMS_BOOKED,
    ROOM_TYPE,
    BOOKING_SOURCE,
    PAYMENT_METHOD,
    GUEST_EMAIL,
    BOOKING_STATUS,
    ROOM_NUMBER,
    GUEST_TYPE,
    GUEST_AGE,
    GUEST_GENDER
)

WITH DEDUPLICATED AS (

    SELECT
        B.*,

        ROW_NUMBER() OVER (
            PARTITION BY
                B.BOOKING_ID,
                B.BOOKING_STATUS
            ORDER BY
                B.CHECK_IN_TIMESTAMP DESC,
                B.CHECK_OUT_TIMESTAMP DESC
        ) AS RN

    FROM BRONZE_HOTEL_BOOKING B
)

SELECT

    LOWER(TRIM(BOOKING_ID)),

    NULLIF(TRIM(HOTEL_NAME), ''),

    INITCAP(TRIM(HOTEL_CITY)),

    INITCAP(TRIM(HOTEL_STATE)),

    TRIM(HOTEL_ZIPCODE),

    INITCAP(TRIM(HOTEL_COUNTRY)),

    INITCAP(TRIM(BOOKING_FOR)),

    NUMBERS_OF_PERSONS,

    ADULTS,

    CHILDRENS,

    DAYS_OF_STAYS,

    CHECK_IN_TIMESTAMP,

    CHECK_OUT_TIMESTAMP,

    INITCAP(TRIM(REQUIRES_TRAVELS_FACILITY)),

    INITCAP(TRIM(MODE_OF_TRAVELS)),

    AMOUNT,

    INITCAP(TRIM(DISCOUNT_CATEGORY)),

    SPECIAL_DISCOUNT,

    TAX,

    TOTAL_AMOUNTS,

    ROOMS_BOOKED,

    INITCAP(TRIM(ROOM_TYPE)),

    INITCAP(TRIM(BOOKING_SOURCE)),

    INITCAP(TRIM(PAYMENT_METHOD)),

    LOWER(TRIM(GUEST_EMAIL)),

    INITCAP(TRIM(BOOKING_STATUS)),

    TRIM(ROOM_NUMBER),

    INITCAP(TRIM(GUEST_TYPE)),

    GUEST_AGE,

    INITCAP(TRIM(GUEST_GENDER))

FROM DEDUPLICATED

WHERE RN = 1

AND BOOKING_ID IS NOT NULL
AND TRIM(BOOKING_ID) <> ''

-- Email validation
AND GUEST_EMAIL IS NOT NULL
AND TRIM(GUEST_EMAIL) <> ''
AND LOWER(TRIM(GUEST_EMAIL)) <> 'none'
AND GUEST_EMAIL LIKE '%_@_%.__%'
AND GUEST_EMAIL NOT LIKE '% %'
AND GUEST_EMAIL NOT LIKE '%@@%'
AND GUEST_EMAIL NOT LIKE '%@.%'
AND GUEST_EMAIL NOT LIKE '%#%'
AND GUEST_EMAIL NOT LIKE '%..%'

-- Amount validation
AND AMOUNT IS NOT NULL
AND AMOUNT >= 0

AND (
    SPECIAL_DISCOUNT IS NULL
    OR SPECIAL_DISCOUNT >= 0
)

AND (
    TAX IS NULL
    OR TAX >= 0
)

AND TOTAL_AMOUNTS IS NOT NULL
AND TOTAL_AMOUNTS > 0

-- Date validation
AND CHECK_IN_TIMESTAMP IS NOT NULL
AND CHECK_OUT_TIMESTAMP IS NOT NULL
AND CHECK_OUT_TIMESTAMP > CHECK_IN_TIMESTAMP

-- Stay validation
AND DAYS_OF_STAYS IS NOT NULL
AND DAYS_OF_STAYS > 0

-- Person validation
AND NUMBERS_OF_PERSONS IS NOT NULL
AND NUMBERS_OF_PERSONS > 0

AND COALESCE(ADULTS, 0)
    + COALESCE(CHILDRENS, 0)
    = NUMBERS_OF_PERSONS

-- Room validation
AND ROOMS_BOOKED IS NOT NULL
AND ROOMS_BOOKED > 0;


-- ============================================================
-- 7. VERIFY SILVER TABLE
-- ============================================================

SELECT COUNT(*) AS SILVER_RECORD_COUNT
FROM SILVER_HOTEL_BOOKING;


-- ============================================================
-- 8. VERIFY QUARANTINE TABLE
-- ============================================================

SELECT COUNT(*) AS QUARANTINE_RECORD_COUNT
FROM QUARANTINE_HOTEL_BOOKING;


-- ============================================================
-- 9. COMPARE BRONZE / SILVER / QUARANTINE
-- ============================================================

SELECT 'BRONZE' AS LAYER, COUNT(*) AS RECORD_COUNT
FROM BRONZE_HOTEL_BOOKING

UNION ALL

SELECT 'SILVER', COUNT(*)
FROM SILVER_HOTEL_BOOKING

UNION ALL

SELECT 'QUARANTINE', COUNT(*)
FROM QUARANTINE_HOTEL_BOOKING;


-- ============================================================
-- 10. DQ REJECTION ANALYSIS
-- ============================================================

SELECT
    REJECTION_REASON,
    COUNT(*) AS REJECTED_RECORDS,
    ROUND(
        COUNT(*) * 100.0 /
        NULLIF(
            (SELECT COUNT(*) FROM BRONZE_HOTEL_BOOKING),
            0
        ),
        2
    ) AS REJECTION_PERCENTAGE
FROM QUARANTINE_HOTEL_BOOKING
GROUP BY REJECTION_REASON
ORDER BY REJECTED_RECORDS DESC;


-- ============================================================
-- 11. DQ ANALYSIS BY BOOKING STATUS
-- ============================================================

SELECT
    BOOKING_STATUS,
    REJECTION_REASON,
    COUNT(*) AS REJECTED_RECORDS
FROM QUARANTINE_HOTEL_BOOKING
GROUP BY
    BOOKING_STATUS,
    REJECTION_REASON
ORDER BY
    REJECTED_RECORDS DESC;


-- ============================================================
-- 12. DQ ANALYSIS BY HOTEL CITY
-- ============================================================

SELECT
    HOTEL_CITY,
    REJECTION_REASON,
    COUNT(*) AS REJECTED_RECORDS
FROM QUARANTINE_HOTEL_BOOKING
GROUP BY
    HOTEL_CITY,
    REJECTION_REASON
ORDER BY
    REJECTED_RECORDS DESC;


-- ============================================================
-- 13. VIEW SILVER DATA
-- ============================================================

SELECT *
FROM SILVER_HOTEL_BOOKING
LIMIT 20;


-- ============================================================
-- 14. VIEW QUARANTINED DATA
-- ============================================================

SELECT *
FROM QUARANTINE_HOTEL_BOOKING
ORDER BY REJECTED_AT DESC
LIMIT 20;

-- ============================================================
-- 15. TOTAL RECORDS IN EACH TABLE
-- ============================================================

SELECT COUNT(*) FROM SILVER_HOTEL_BOOKING;

SELECT COUNT(*) FROM QUARANTINE_HOTEL_BOOKING;

SELECT booking_id, COUNT(*) AS cnt FROM QUARANTINE_HOTEL_BOOKING GROUP BY booking_id
ORDER BY cnt DESC;


