-- 1. Создание базы
CREATE DATABASE HelpDesk_DenLis;
GO
USE HelpDesk_Ivanov;
GO

-- 2. Создание таблиц
CREATE TABLE Roles (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE Categories (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE Priorities (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL UNIQUE,
    SortOrder INT NOT NULL
);
CREATE TABLE Statuses (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Login NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(150) NOT NULL,
    RoleId INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES Roles(Id)
);
CREATE TABLE Tickets (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    CategoryId INT NOT NULL,
    Description NVARCHAR(1000) NOT NULL,
    PriorityId INT NOT NULL,
    StatusId INT NOT NULL,
    AssignedUserId INT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Tickets_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
    CONSTRAINT FK_Tickets_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(Id),
    CONSTRAINT FK_Tickets_Priorities FOREIGN KEY (PriorityId) REFERENCES Priorities(Id),
    CONSTRAINT FK_Tickets_Statuses FOREIGN KEY (StatusId) REFERENCES Statuses(Id),
    CONSTRAINT FK_Tickets_AssignedUser FOREIGN KEY (AssignedUserId) REFERENCES Users(Id)
);
GO

-- 3. Вставка данных
INSERT INTO Roles (Name) VALUES (N'Пользователь'),(N'Специалист'),(N'Администратор');
INSERT INTO Categories (Name) VALUES (N'Оборудование'),(N'Программное обеспечение'),(N'Сеть'),(N'Учётная запись'),(N'Периферия'),(N'Другое');
INSERT INTO Priorities (Name, SortOrder) VALUES (N'Низкий',1),(N'Средний',2),(N'Высокий',3);
INSERT INTO Statuses (Name) VALUES (N'Новая'),(N'В работе'),(N'Выполнена'),(N'Отклонена');

INSERT INTO Users (Login, PasswordHash, FullName, RoleId, IsActive) VALUES
(N'admin', N'TEMP_ADMIN', N'Администратор системы', 3, 1),
(N'support1', N'TEMP_SUPPORT', N'Специалист технической поддержки', 2, 1),
(N'user1', N'TEMP_USER', N'Тестовый пользователь', 1, 1);

INSERT INTO Tickets (UserId, CategoryId, Description, PriorityId, StatusId, AssignedUserId) VALUES
(3, 3, N'Нет доступа в Интернет', 3, 1, NULL),
(3, 2, N'Не запускается Microsoft Word', 2, 2, 2),
(3, 1, N'Не включается компьютер', 3, 2, 2),
(3, 5, N'Не работает принтер', 2, 1, NULL),
(3, 4, N'Не удаётся войти в учётную запись', 3, 4, 2);
GO

-- 4. ВЫВОД ДАННЫХ ДЛЯ СКРИНШОТА (Часть VIII, Задание 29)

PRINT '--- Проверка: Таблица Roles ---';
SELECT * FROM Roles;

PRINT '--- Проверка: Таблица Users ---';
SELECT * FROM Users;

PRINT '--- Проверка: Таблица Categories ---';
SELECT * FROM Categories;

PRINT '--- Проверка: Таблица Priorities ---';
SELECT * FROM Priorities ORDER BY SortOrder;

PRINT '--- Проверка: Таблица Statuses ---';
SELECT * FROM Statuses;

PRINT '--- Проверка: Таблица Tickets ---';
SELECT * FROM Tickets;

PRINT '--- Проверка JOIN (Задание 21) ---';
SELECT
    t.Id AS TicketId,
    t.Description AS Описание,
    c.Name AS Категория,
    p.Name AS Приоритет,
    s.Name AS Статус,
    u.FullName AS Автор,
    a.FullName AS Исполнитель
FROM Tickets t
JOIN Categories c ON c.Id = t.CategoryId
JOIN Priorities p ON p.Id = t.PriorityId
JOIN Statuses s ON s.Id = t.StatusId
JOIN Users u ON u.Id = t.UserId
LEFT JOIN Users a ON a.Id = t.AssignedUserId
ORDER BY t.Id;

PRINT '--- Проверка: список таблиц (Задание 24) ---';
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE' 
ORDER BY TABLE_NAME;