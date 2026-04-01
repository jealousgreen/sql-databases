-- База данных 3. Бронирование отелей
-- PostgreSQL / tasks.sql

--------------------------------------------
-- Задача 1
-- Клиенты с более чем двумя бронированиями
-- в разных отелях
--------------------------------------------
SELECT
    c.name,
    c.email,
    c.phone,
    COUNT(*) AS total_bookings,
    STRING_AGG(DISTINCT h.name, ', ' ORDER BY h.name) AS hotel_list,
    ROUND(AVG(b.check_out_date - b.check_in_date), 4) AS average_stay_days
FROM Customer c
JOIN Booking b ON b.ID_customer = c.ID_customer
JOIN Room r ON r.ID_room = b.ID_room
JOIN Hotel h ON h.ID_hotel = r.ID_hotel
GROUP BY c.ID_customer, c.name, c.email, c.phone
HAVING COUNT(*) > 2
   AND COUNT(DISTINCT h.ID_hotel) > 1
ORDER BY total_bookings DESC, c.name;


--------------------------------------------
-- Задача 2
-- Клиенты с более чем двумя бронированиями
-- в разных отелях и суммой трат > 500
--------------------------------------------
WITH customer_booking_stats AS (
    SELECT
        c.ID_customer,
        c.name,
        COUNT(*) AS total_bookings,
        COUNT(DISTINCT h.ID_hotel) AS unique_hotels,
        SUM(r.price * (b.check_out_date - b.check_in_date)) AS total_spent
    FROM Customer c
    JOIN Booking b ON b.ID_customer = c.ID_customer
    JOIN Room r ON r.ID_room = b.ID_room
    JOIN Hotel h ON h.ID_hotel = r.ID_hotel
    GROUP BY c.ID_customer, c.name
),
multi_hotel_customers AS (
    SELECT
        ID_customer,
        name,
        total_bookings,
        unique_hotels,
        total_spent
    FROM customer_booking_stats
    WHERE total_bookings > 2
      AND unique_hotels > 1
),
high_spending_customers AS (
    SELECT
        ID_customer,
        name,
        total_bookings,
        unique_hotels,
        total_spent
    FROM customer_booking_stats
    WHERE total_spent > 500
)
SELECT
    m.ID_customer,
    m.name,
    m.total_bookings,
    ROUND(m.total_spent, 2) AS total_spent,
    m.unique_hotels
FROM multi_hotel_customers m
JOIN high_spending_customers h
    ON m.ID_customer = h.ID_customer
ORDER BY m.total_spent ASC;