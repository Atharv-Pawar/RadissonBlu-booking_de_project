CREATE DATABASE RADISSONBLU_DB;

CREATE SCHEMA _hotel;

CREATE OR REPLACE TABLE RADISSONBLU_DB._hotel.hotel_booking (
    BOOKING_ID                  VARCHAR(300),
    HOTEL_NAME                  VARCHAR(255),
    HOTEL_CITY                  VARCHAR(100),
    HOTEL_STATE                 VARCHAR(100),
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
    GUEST_AGE                   NUMBER(5,1),
    GUEST_GENDER                VARCHAR(20)
);


SELECT * FROM RADISSONBLU_DB._hotel.hotel_booking LIMIT 10;

SELECT COUNT(*) FROM RADISSONBLU_DB._HOTEL.HOTEL_BOOKING;

SELECT COUNT(DISTINCT BOOKING_ID) FROM RADISSONBLU_DB._HOTEL.HOTEL_BOOKING;