
CREATE DATABASE IT_ServiceCenter_Practice;
GO
USE IT_ServiceCenter_Practice;
GO



CREATE TABLE Clients (
    ClientId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Phone NVARCHAR(30) NULL,
    City NVARCHAR(100) NULL
);
GO

CREATE TABLE Employees (
    EmployeeId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Position NVARCHAR(100) NULL,
    HireDate DATE NULL
);
GO

CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE RequestStatuses (
    StatusId INT IDENTITY(1,1) PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE ServiceRequests (
    RequestId INT IDENTITY(1,1) PRIMARY KEY,
    ClientId INT NOT NULL,
    EmployeeId INT NULL,
    CategoryId INT NOT NULL,
    StatusId INT NOT NULL,
    Description NVARCHAR(1000) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CompletedAt DATETIME2 NULL,
    Cost DECIMAL(10,2) NULL,
    CONSTRAINT FK_Requests_Clients FOREIGN KEY (ClientId) REFERENCES Clients(ClientId),
    CONSTRAINT FK_Requests_Employees FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId),
    CONSTRAINT FK_Requests_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT FK_Requests_Statuses FOREIGN KEY (StatusId) REFERENCES RequestStatuses(StatusId)
);
GO



INSERT INTO Clients (FullName, Phone, City) VALUES
(N'Иванов Иван Иванович',   N'+7-900-111-22-33', N'Москва'),
(N'Петрова Анна Сергеевна', N'+7-900-222-33-44', N'Санкт-Петербург'),
(N'Сидоров Пётр Алексеевич', N'+7-900-333-44-55', N'Казань'),
(N'Кузнецова Мария Ивановна', N'+7-900-444-55-66', N'Москва'),
(N'Смирнов Алексей Викторович', N'+7-900-555-66-77', N'Новосибирск');
GO

INSERT INTO Employees (FullName, Position, HireDate) VALUES
(N'Орлов Дмитрий Сергеевич', N'Старший инженер', '2020-03-15'),
(N'Фёдорова Елена Павловна', N'Инженер',          '2021-07-01'),
(N'Гусев Максим Игоревич',  N'Системный администратор', '2019-11-20');
GO

INSERT INTO Categories (CategoryName) VALUES
(N'Сеть'),
(N'Оборудование'),
(N'Программное обеспечение'),
(N'Периферия');
GO

INSERT INTO RequestStatuses (StatusName) VALUES
(N'Новая'),
(N'В работе'),
(N'Выполнена'),
(N'Отклонена');
GO

INSERT INTO ServiceRequests (ClientId, EmployeeId, CategoryId, StatusId, Description, CreatedAt, CompletedAt, Cost) VALUES
(1, 1,    1, 1, N'Не работает интернет, требуется настройка роутера', '2026-02-10 09:15:00', NULL, NULL),
(2, NULL, 4, 1, N'Не работает принтер HP LaserJet',                    '2026-02-11 10:30:00', NULL, NULL),
(3, 2,    1, 2, N'Пропадает Wi-Fi соединение в офисе',                 '2026-02-05 14:00:00', NULL, 1500.00),
(4, 3,    2, 3, N'Замена блока питания в системном блоке',             '2026-01-20 11:00:00', '2026-01-22 16:30:00', 3200.00),
(5, 1,    1, 3, N'Настройка локальной сети для нового отдела',         '2026-01-15 08:45:00', '2026-01-18 17:00:00', 5400.00),
(1, 2,    3, 2, N'Установка и настройка Microsoft Office',              '2026-02-08 13:10:00', NULL, 800.00),
(2, 3,    4, 3, N'Заправка картриджа принтера Kyocera',                '2026-01-25 09:00:00', '2026-01-25 12:00:00', 600.00),
(3, NULL, 1, 1, N'Не работает интернет после грозы',                    '2026-02-12 16:20:00', NULL, NULL),
(5, 2,    3, 4, N'Ошибка при запуске 1С:Предприятие',                   '2026-01-10 10:00:00', '2026-01-12 15:00:00', 2200.00),
(4, 1,    1, 2, N'Настройка VPN для удалённых сотрудников',            '2026-02-09 15:40:00', NULL, 4500.00);
GO


-- Запрос 1. Полный список заявок
SELECT 
    RequestId,
    Description,
    CreatedAt,
    Cost
FROM ServiceRequests
ORDER BY CreatedAt DESC;
GO

-- Запрос 2. Новые заявки (статус «Новая» через JOIN)
SELECT 
    sr.RequestId,
    sr.Description,
    sr.CreatedAt
FROM ServiceRequests sr
INNER JOIN RequestStatuses rs ON rs.StatusId = sr.StatusId
WHERE rs.StatusName = N'Новая';
GO

-- Запрос 3. Дорогие сетевые обращения (категория «Сеть», стоимость > 1000)
SELECT 
    sr.RequestId,
    sr.Description,
    sr.Cost,
    c.CategoryName
FROM ServiceRequests sr
INNER JOIN Categories c ON c.CategoryId = sr.CategoryId
WHERE c.CategoryName = N'Сеть'
  AND sr.Cost > 1000;
GO

-- Запрос 4. Поиск по фрагменту текста (слово «принтер» в описании)
SELECT 
    RequestId,
    Description,
    CreatedAt
FROM ServiceRequests
WHERE Description LIKE N'%принтер%';
GO

-- Запрос 5. Подробный отчёт по заявкам (несколько JOIN и LEFT JOIN)
SELECT 
    sr.RequestId,
    cl.FullName AS ClientName,
    cat.CategoryName,
    sr.Description,
    st.StatusName,
    emp.FullName AS EmployeeName,
    sr.Cost
FROM ServiceRequests sr
JOIN Clients cl        ON cl.ClientId = sr.ClientId
JOIN Categories cat    ON cat.CategoryId = sr.CategoryId
JOIN RequestStatuses st ON st.StatusId = sr.StatusId
LEFT JOIN Employees emp ON emp.EmployeeId = sr.EmployeeId
ORDER BY sr.RequestId;
GO

-- Запрос 6. Заявки без назначенного сотрудника
SELECT 
    sr.RequestId,
    sr.Description,
    sr.CreatedAt,
    cl.FullName AS ClientName
FROM ServiceRequests sr
JOIN Clients cl ON cl.ClientId = sr.ClientId
WHERE sr.EmployeeId IS NULL
ORDER BY sr.CreatedAt ASC;
GO

-- Запрос 7. Количество заявок по статусам
SELECT 
    rs.StatusName,
    COUNT(*) AS RequestsCount
FROM ServiceRequests sr
JOIN RequestStatuses rs ON rs.StatusId = sr.StatusId
GROUP BY rs.StatusName
ORDER BY RequestsCount DESC;
GO

-- Запрос 8. Анализ стоимости по категориям (средняя > 1000)
SELECT 
    c.CategoryName,
    AVG(sr.Cost) AS AvgCost,
    MAX(sr.Cost) AS MaxCost
FROM ServiceRequests sr
JOIN Categories c ON c.CategoryId = sr.CategoryId
WHERE sr.Cost IS NOT NULL
GROUP BY c.CategoryName
HAVING AVG(sr.Cost) > 1000
ORDER BY AvgCost DESC;
GO

-- Запрос 9. Клиенты с несколькими обращениями (не менее 2 заявок)
SELECT 
    cl.FullName AS ClientName,
    COUNT(sr.RequestId) AS RequestsCount
FROM Clients cl
JOIN ServiceRequests sr ON sr.ClientId = cl.ClientId
GROUP BY cl.FullName
HAVING COUNT(sr.RequestId) >= 2
ORDER BY RequestsCount DESC;
GO

-- Запрос 10. Клиенты без заявок
SELECT 
    cl.FullName,
    cl.City
FROM Clients cl
LEFT JOIN ServiceRequests sr ON sr.ClientId = cl.ClientId
WHERE sr.RequestId IS NULL;
GO