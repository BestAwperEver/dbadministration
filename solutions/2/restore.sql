USE AdventureWorks2012;
DROP PROCEDURE IF EXISTS restoreDB;
GO

CREATE PROCEDURE restoreDB
	@dbName nvarchar(50),
	@date DATETIME2(0)
AS
BEGIN
	DECLARE @backups TABLE 
	(
		dbName nvarchar(128),
		isFull BIT,
		dtTm DATETIME2(0),
		filePath nvarchar(128)
		PRIMARY KEY (dtTm)
	);

	INSERT INTO @backups SELECT TOP 1 * FROM backup_log
	WHERE dbName = @dbName
	AND isFull = 1
	AND dtTm <= @date
	ORDER BY dtTm DESC;

	DECLARE @found int = (SELECT count(*) FROM @backups);

	IF @found = 0
	BEGIN
		RETURN
	END

	DECLARE @filePathfull nvarchar(128) = (SELECT TOP 1 filePath FROM @backups);

	DECLARE @restoreDbName nvarchar(128) = @dbName + '_restored';
	DECLARE @dbNameLog nvarchar(128) = @dbName + '_log';
	DECLARE @mdfPath nvarchar(128) = concat(
		'D:\Programs\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\',
		@dbName,
		'2.mdf');
	DECLARE @ldfPath nvarchar(128) = concat(
		'D:\Programs\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\',
		@dbName,
		'_log2.ldf');

	RESTORE DATABASE @restoreDbName
		FROM  DISK = @filePathfull
		WITH
		MOVE @dbName TO @mdfPath,
		MOVE @dbNameLog TO @ldfPath,
		NORECOVERY,
		NOUNLOAD,
		REPLACE,
		STATS = 5;

	INSERT INTO @backups SELECT * FROM backup_log
	WHERE dbName = @dbName
	AND isFull = 0
	AND dtTm <= @date
	AND dtTm > (SELECT TOP 1 dtTm from @backups)
	ORDER BY dtTm DESC;

	DELETE FROM @backups WHERE isFull = 1;

	SET @found = (SELECT count(*) FROM @backups);

	IF @found = 0
	BEGIN
		RETURN
	END

	DECLARE backupCursor CURSOR FOR
		SELECT filePath, dtTm FROM @backups ORDER BY dtTm DESC;
	OPEN backupCursor;

	DECLARE @fileName nvarchar(128);
	FETCH NEXT FROM backupCursor INTO @fileName, @date;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		RESTORE DATABASE @restoreDbName
			FROM DISK = @fileName
			WITH
			NOUNLOAD,
			STATS = 5;
		FETCH NEXT FROM backupCursor INTO @fileName, @date;
	END

	CLOSE backupCursor;  
	DEALLOCATE backupCursor; 

END
GO

EXEC restoreDB @dbName = 'testdb', @date = '28/12/2017';