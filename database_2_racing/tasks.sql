-- База данных 2. Автомобильные гонки
-- PostgreSQL / tasks.sql

--------------------------------------------
-- Задача 1
-- Автомобили с наименьшей средней позицией в каждом классе
--------------------------------------------
WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(*) AS race_count
    FROM Cars c
    JOIN Results r ON r.car = c.name
    GROUP BY c.name, c.class
),
ranked_cars AS (
    SELECT
        car_name,
        car_class,
        average_position,
        race_count,
        RANK() OVER (PARTITION BY car_class ORDER BY average_position) AS rn
    FROM car_stats
)
SELECT
    car_name,
    car_class,
    ROUND(average_position, 4) AS average_position,
    race_count
FROM ranked_cars
WHERE rn = 1
ORDER BY average_position, car_name;


--------------------------------------------
-- Задача 2
-- Автомобиль с наименьшей средней позицией среди всех
--------------------------------------------
SELECT
    c.name AS car_name,
    c.class AS car_class,
    ROUND(AVG(r.position), 4) AS average_position,
    COUNT(*) AS race_count,
    cl.country AS car_country
FROM Cars c
JOIN Results r ON r.car = c.name
JOIN Classes cl ON cl.class = c.class
GROUP BY c.name, c.class, cl.country
ORDER BY average_position ASC, car_name ASC
LIMIT 1;


--------------------------------------------
-- Задача 3
-- Классы с наименьшей средней позицией
--------------------------------------------
WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(*) AS race_count
    FROM Cars c
    JOIN Results r ON r.car = c.name
    GROUP BY c.name, c.class
),
class_stats AS (
    SELECT
        car_class,
        AVG(average_position) AS class_avg_position,
        SUM(race_count) AS total_races
    FROM car_stats
    GROUP BY car_class
),
best_classes AS (
    SELECT car_class, total_races
    FROM class_stats
    WHERE class_avg_position = (
        SELECT MIN(class_avg_position) FROM class_stats
    )
)
SELECT
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count,
    cl.country AS car_country,
    bc.total_races
FROM car_stats cs
JOIN best_classes bc ON bc.car_class = cs.car_class
JOIN Classes cl ON cl.class = cs.car_class
ORDER BY cs.car_name;


--------------------------------------------
-- Задача 4
-- Автомобили, чья средняя позиция лучше средней по классу
--------------------------------------------
WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(*) AS race_count
    FROM Cars c
    JOIN Results r ON r.car = c.name
    GROUP BY c.name, c.class
),
class_avg AS (
    SELECT
        car_class,
        AVG(average_position) AS class_average_position,
        COUNT(*) AS car_count
    FROM car_stats
    GROUP BY car_class
    HAVING COUNT(*) >= 2
)
SELECT
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count,
    cl.country AS car_country
FROM car_stats cs
JOIN class_avg ca ON ca.car_class = cs.car_class
JOIN Classes cl ON cl.class = cs.car_class
WHERE cs.average_position < ca.class_average_position
ORDER BY cs.car_class, cs.average_position;


--------------------------------------------
-- Задача 5
-- Классы с наибольшим количеством автомобилей
-- с низкой средней позицией > 3.0
--------------------------------------------
WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(*) AS race_count
    FROM Cars c
    JOIN Results r ON r.car = c.name
    GROUP BY c.name, c.class
),
class_stats AS (
    SELECT
        car_class,
        SUM(race_count) AS total_races,
        SUM(CASE WHEN average_position > 3.0 THEN 1 ELSE 0 END) AS low_position_count
    FROM car_stats
    GROUP BY car_class
)
SELECT
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count,
    cl.country AS car_country,
    cls.total_races,
    cls.low_position_count
FROM car_stats cs
JOIN class_stats cls
    ON cls.car_class = cs.car_class
JOIN Classes cl
    ON cl.class = cs.car_class
WHERE cs.average_position > 3.0
ORDER BY cls.low_position_count DESC, cs.car_class, cs.car_name;