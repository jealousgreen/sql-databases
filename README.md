# sql-databases
Homework

Этот репозиторий содержит решения SQL-задач по четырем учебным базам данных в **PostgreSQL** :

1. **Транспортные средства**
2. **Автомобильные гонки**
3. **Бронирование отелей**
4. **Структура организации**

Цель проекта - отработать практические навыки написания SQL-запросов разной сложности:

- агрегатные функции
- подзапросы
- `CTE`
- `WITH RECURSIVE` рекурсивные запросы
- сортировка, группировка и фильтрация данных
- объединение результатов

---

## Структура проекта

```text
sql-databases/
│
├── README.md
│
├── database_1_vehicles/
│    ├── create_tables.sql
│    ├── insert_data.sql
│    └── tasks.sql
│
├── database_2_racing/
│    ├── create_tables.sql
│    ├── insert_data.sql
│    └── tasks.sql
│
├── database_3_hotel_booking/
│    ├── create_tables.sql
│    ├── insert_data.sql
│    └── tasks.sql
│
└── database_4_organization_structure/
    ├── create_tables.sql
    ├── insert_data.sql
    └── tasks.sql

---
Состав каждого каталога

В каждой базе данных находятся три основных файла:

create_tables.sql - создание таблиц и ограничений
insert_data.sql - заполнение базы тестовыми данными
tasks.sql - решения задач
