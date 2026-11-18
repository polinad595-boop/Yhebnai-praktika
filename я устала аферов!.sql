-- 1
CREATE DATABASE AuthorizationPractice;
GO
USE AuthorizationPractice;
GO

-- 2
CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);
GO

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Login NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(150) NOT NULL,
    RoleId INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
);
GO

-- 3
INSERT INTO Roles (RoleName) VALUES
(N'Администратор'),
(N'Специалист'),
(N'Пользователь');
GO


INSERT INTO Users (Login, PasswordHash, FullName, RoleId, IsActive)
VALUES
(N'admin',    CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', N'Admin123!'), 2), N'Администратор Системы', 1, 1),
(N'support1', CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', N'Support123!'), 2), N'Специалист Поддержки', 2, 1),
(N'user1',    CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', N'User123!'), 2), N'Тестовый Пользователь', 3, 1);
GO



DECLARE @InputLogin NVARCHAR(50) = N'admin';    
DECLARE @InputPassword NVARCHAR(50) = N'Admin123!'; 

SELECT
    u.UserId,
    u.Login,
    u.FullName,
    r.RoleName,
    u.IsActive
FROM Users u
INNER JOIN Roles r ON r.RoleId = u.RoleId
WHERE
    u.Login = @InputLogin
    AND u.IsActive = 1

    AND u.PasswordHash = CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', @InputPassword), 2);


-- 7
UPDATE Users SET IsActive = 0 WHERE Login = N'user1';
GO

DECLARE @DisabledLogin NVARCHAR(50) = N'user1';
DECLARE @DisabledPassword NVARCHAR(50) = N'User123!';


SELECT u.Login, u.FullName
FROM Users u
WHERE u.Login = @DisabledLogin
  AND u.IsActive = 1 
  AND u.PasswordHash = CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', @DisabledPassword), 2);


UPDATE Users SET IsActive = 1 WHERE Login = N'user1';
GO