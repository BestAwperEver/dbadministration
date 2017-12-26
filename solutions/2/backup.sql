USE AdventureWorks2012;
DROP PROCEDURE IF EXISTS backupDB;
GO

TRUNCATE TABLE backup_log;
GO

CREATE PROCEDURE backupDB
	@dbName nvarchar(128),
	@full BIT
AS
BEGIN
	DECLARE @dateTime DATETIME2(0) = SYSDATETIME();

	DECLARE @fileName nvarchar(128) = 
	
	CONCAT('D:\Programs\Microsoft SQL Server\backups\',
		@dbName,
		REPLACE(@dateTime, ':', ' '),
		'.bak');

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