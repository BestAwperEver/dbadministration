USE AdventureWorks2012;
DROP PROCEDURE IF EXISTS backupDB;
GO

DROP TABLE IF EXISTS backup_log;
CREATE TABLE backup_log
	(
	dbName nvarchar(128),	-- имя бд, для которой создан бэкап
	isFull bit,				-- полный бэкап или дифференциальный
	dtTm dateTime2(7),		-- отметка времени
	filePath nvarchar(128),	-- путь к файлу с бэкапом
	PRIMARY KEY(dbName, dtTm)
	);
GO

CREATE PROCEDURE backupDB
	@dbName nvarchar(128),	-- имя бд, для которой создан бэкап
	@full BIT				-- полный бэкап или дифференциальный
AS
BEGIN
	-- текущая отметка времени
	DECLARE @dateTime dateTime2(7) = SYSDATETIME();

	DECLARE @fileName nvarchar(128) = 
	CONCAT('D:\Programs\Microsoft SQL Server\backups\',
		@dbName,						-- имя бд
		REPLACE(@dateTime, ':', ' '),	-- отметка времени
		'.bak');

	-- для каждого бэкапа -- отдельный файл, поэтому INIT не требуется
	if @full = 1
	BEGIN
		BACKUP DATABASE @dbName
		TO
		DISK = @fileName;
	END
	ELSE
	BEGIN
		BACKUP DATABASE @dbName
		TO
		DISK = @fileName
		WITH DIFFERENTIAL;
	END

	-- запись в лог о созданном бэкапе
	INSERT INTO backup_log VALUES
		(@dbName, @full, @dateTime, @fileName);

END
GO

EXEC backupDB @dbName = 'testdb', @full = 1;
GO

USE testdb;
INSERT INTO t1 VALUES (1235);
GO

USE AdventureWorks2012;
EXEC backupDB @dbName = 'testdb', @full = 0;
GO

SELECT * FROM backup_log;
GO