CREATE DATABASE HP_analysis;
USE HP_analysis;
-- Create table 
CREATE TABLE fact_bookings (
    booking_id VARCHAR(50),
    property_id INT,
    booking_date VARCHAR(20), -- Storing as VARCHAR for initial import
    check_in_date VARCHAR(20),
    checkout_date VARCHAR(20),
    no_guests INT,
    room_category VARCHAR(100),
    booking_platform VARCHAR(100),
    ratings_given DECIMAL(3, 2),
    booking_status VARCHAR(50),
    revenue_generated DECIMAL(10, 2),
    revenue_realized DECIMAL(10, 2)
);
commit;
#########################################################################################
-- create  table 
CREATE TABLE dim_hotels (
    property_id INT PRIMARY KEY,       -- Unique identifier for each property
    property_name VARCHAR(255),        -- Name of the property
    category VARCHAR(100),             -- Category of the property (e.g., Hotel, Resort)
    city VARCHAR(100)                  -- City where the property is located
);
-- import data 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_hotels.csv'
INTO TABLE dim_hotels
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
commit;
###########################################################################################################################
-- Create Table dim_rooms
CREATE TABLE dim_rooms (
    room_id VARCHAR(50) PRIMARY KEY,  -- Unique alphanumeric identifier for each room
    room_class VARCHAR(100)          -- Classification of the room (e.g., Deluxe, Standard, Suite)
);
-- import data 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_rooms.csv'
INTO TABLE dim_rooms
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
commit;
##############################################################################################################################
-- create table
CREATE TABLE fact_aggregated_bookings (
    property_id VARCHAR(50),          -- Identifier for the property (linked to dim_hotel table)
    check_in_date VARCHAR(10),        -- Check-in date stored as a string in DD-MM-YYYY format
    room_category VARCHAR(100),       -- Category of the room (e.g., Deluxe, Suite)
    successful_bookings INT,          -- Number of successful bookings
    capacity INT,                     -- Capacity of the property or room category
    PRIMARY KEY (property_id, check_in_date, room_category) -- Composite primary key to ensure uniqueness
);
-- import data 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_aggregated_bookings.csv'
INTO TABLE fact_aggregated_bookings
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
commit;
###########################################################################################################################
-- create table 
CREATE TABLE dim_date (
    date VARCHAR(10),                  -- Store date as string in DD-MM-YYYY format
    mmm_yy VARCHAR(10),                -- Store the month and year (e.g., 01-05-2022)
    week_no VARCHAR(10),               -- Store week number (e.g., W 19)
    day_type VARCHAR(10),              -- Store day type (e.g., weekend, weekday)
    PRIMARY KEY (date)                 -- Unique key for each date
);
-- import data 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_date.csv'
INTO TABLE dim_date
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
commit;
########################################################################################################################
-- 1 Total Revenue
select sum(revenue_realized) as Total_Revenue from fact_bookings;
#######################################################################################
-- 2 Total bookings
select count(*) as total_bookings from fact_bookings;
#####################################################################################
-- 3 b) Total Capacity
select sum(capacity) as Total_Capacity from fact_aggregated_bookings;
######################################################################################
-- 4 Occupancy %
SELECT SUM(successful_bookings) / SUM(capacity) * 100 AS Occupancy_Rate
FROM fact_aggregated_bookings;
#####################################################################################
-- 5 Cancellation%
SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings)) AS Cancellation_Percentage
FROM fact_bookings
WHERE booking_status = 'Cancelled';
##################################################################################################3
-- 6 Total Cancelled bookings
SELECT COUNT(*) AS Total_Cancelled_Bookings
FROM fact_bookings
WHERE booking_status = 'Cancelled';
######################################################################################################
-- 7 Average Rating
select avg(ratings_given) as Average_rating from fact_bookings;
###############################################################
-- Weekday & Weekend Revenue and Booking
SELECT 
    d.day_type,
    SUM(fb.revenue_generated) AS total_revenue,
    COUNT(fb.booking_id) AS total_bookings
FROM 
    fact_bookings fb
JOIN 
    dim_date d ON fb.check_in_date = d.date
GROUP BY 
    d.day_type;
##############################################
-- Revenue by State & Hotel
SELECT 
    h.city AS state,
    h.property_name AS hotel,
    SUM(fb.revenue_generated) AS total_revenue
FROM 
    fact_bookings fb
JOIN 
    dim_hotels h ON fb.property_id = h.property_id
GROUP BY 
    h.city, h.property_name;
#########################################
-- Class Wise Revenue 
SELECT 
    r.room_class AS class,
    SUM(fb.revenue_generated) AS total_revenue
FROM 
    fact_bookings fb
JOIN 
    dim_rooms r ON fb.room_category = r.room_id
GROUP BY 
    r.room_class;
####################################
-- Checked Out, Canceled, No Show
SELECT 
    fb.booking_status,
    COUNT(fb.booking_id) AS total_bookings
FROM 
    fact_bookings fb
GROUP BY 
    fb.booking_status;
