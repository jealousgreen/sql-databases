-- База данных 4. Структура организации
-- PostgreSQL / tasks.sql

--------------------------------------------
-- Задача 1
-- Все сотрудники, подчиняющиеся Ивану Иванову,
-- включая его самого
--------------------------------------------
WITH RECURSIVE employee_hierarchy AS (
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    WHERE e.EmployeeID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    JOIN employee_hierarchy eh
        ON e.ManagerID = eh.EmployeeID
)
SELECT
    eh.EmployeeID,
    eh.Name AS EmployeeName,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    (
        SELECT STRING_AGG(p.ProjectName, ', ' ORDER BY p.ProjectName)
        FROM Projects p
        WHERE p.DepartmentID = eh.DepartmentID
    ) AS ProjectNames,
    (
        SELECT STRING_AGG(t.TaskName, ', ' ORDER BY t.TaskName)
        FROM Tasks t
        WHERE t.AssignedTo = eh.EmployeeID
    ) AS TaskNames
FROM employee_hierarchy eh
LEFT JOIN Departments d
    ON d.DepartmentID = eh.DepartmentID
LEFT JOIN Roles r
    ON r.RoleID = eh.RoleID
ORDER BY eh.Name;


--------------------------------------------
-- Задача 2
-- Все сотрудники, подчиняющиеся Ивану Иванову,
-- с количеством задач и прямых подчиненных
--------------------------------------------
WITH RECURSIVE employee_hierarchy AS (
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    WHERE e.EmployeeID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    JOIN employee_hierarchy eh
        ON e.ManagerID = eh.EmployeeID
)
SELECT
    eh.EmployeeID,
    eh.Name AS EmployeeName,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    (
        SELECT STRING_AGG(p.ProjectName, ', ' ORDER BY p.ProjectName)
        FROM Projects p
        WHERE p.DepartmentID = eh.DepartmentID
    ) AS ProjectNames,
    (
        SELECT STRING_AGG(t.TaskName, ', ' ORDER BY t.TaskName)
        FROM Tasks t
        WHERE t.AssignedTo = eh.EmployeeID
    ) AS TaskNames,
    (
        SELECT COUNT(*)
        FROM Tasks t
        WHERE t.AssignedTo = eh.EmployeeID
    ) AS TotalTasks,
    (
        SELECT COUNT(*)
        FROM Employees e
        WHERE e.ManagerID = eh.EmployeeID
    ) AS TotalSubordinates
FROM employee_hierarchy eh
LEFT JOIN Departments d
    ON d.DepartmentID = eh.DepartmentID
LEFT JOIN Roles r
    ON r.RoleID = eh.RoleID
ORDER BY eh.Name;


-- ------------------------------------------
-- Задача 3
-- Менеджеры, имеющие подчинённых,
-- с общим количеством подчиненных всех уровней
-- ------------------------------------------
WITH RECURSIVE subordinates AS (
    SELECT
        e.EmployeeID AS manager_id,
        e.EmployeeID AS employee_id
    FROM Employees e
    JOIN Roles r ON r.RoleID = e.RoleID
    WHERE r.RoleName = 'Менеджер'

    UNION ALL

    SELECT
        s.manager_id,
        e.EmployeeID
    FROM subordinates s
    JOIN Employees e
        ON e.ManagerID = s.employee_id
),
subordinate_counts AS (
    SELECT
        manager_id,
        COUNT(*) - 1 AS TotalSubordinates
    FROM subordinates
    GROUP BY manager_id
    HAVING COUNT(*) - 1 > 0
)
SELECT
    e.EmployeeID,
    e.Name AS EmployeeName,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    (
        SELECT STRING_AGG(p.ProjectName, ', ' ORDER BY p.ProjectName)
        FROM Projects p
        WHERE p.DepartmentID = e.DepartmentID
    ) AS ProjectNames,
    (
        SELECT STRING_AGG(t.TaskName, ', ' ORDER BY t.TaskName)
        FROM Tasks t
        WHERE t.AssignedTo = e.EmployeeID
    ) AS TaskNames,
    sc.TotalSubordinates
FROM subordinate_counts sc
JOIN Employees e
    ON e.EmployeeID = sc.manager_id
JOIN Departments d
    ON d.DepartmentID = e.DepartmentID
JOIN Roles r
    ON r.RoleID = e.RoleID
ORDER BY e.Name;