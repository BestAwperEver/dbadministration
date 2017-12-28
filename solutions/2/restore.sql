USE AdventureWorks2012;
DROP PROCEDURE IF EXISTS restoreDB;
GO

CREATE PROCEDURE restoreDB
	@dbName nvarchar(128),	-- имя базы данных для восстановления
	@date DATETIME2(7)		-- восстановление на заданный момент времени
AS
BEGIN

	-- таблица, содержащая информацию о необходимых файлах для восстановления
	DECLARE @backups TABLE 
	(
		dbName nvarchar(128),
		isFull BIT,
		dtTm DATETIME2(7),
		filePath nvarchar(128)
		PRIMARY KEY (dtTm)	-- только отметка времени, поскольку вся таблица - для одной базы
	);

	-- сначала ищется последний полный бэкап до указанной даты
	INSERT INTO @backups SELECT TOP 1 * FROM backup_log
		WHERE dbName = @dbName
		AND isFull = 1
		AND dtTm <= @date
		ORDER BY dtTm DESC;

	-- проверка, нашёлся ли хоть один полный бэкап
	DECLARE @found int = (SELECT count(*) FROM @backups);

	IF @found = 0
	BEGIN
		RETURN
	END

	-- путь к файлу с полным бэкапом
	DECLARE @filePathfull nvarchar(128) = (SELECT TOP 1 filePath FROM @backups);

	-- на всякий случай восстановление делается в базу с именем dbname_restored,
	-- а не в ту базу, с которой производился бэкап
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
		REPLACE,	-- иначе ругается на логи
		STATS = 5;
	-- параметры NOUNLOAD и STATS я взял из скрипта, генерируемого автоматически при выполнении
	-- рестора с использованием SSMS

	-- накатывание всех имеющихся дифференциальных бэкапов на полный до указанной даты
	INSERT INTO @backups SELECT * FROM backup_log
		WHERE dbName = @dbName
		AND isFull = 0
		AND dtTm <= @date
		AND dtTm > (SELECT TOP 1 dtTm from @backups)
		ORDER BY dtTm DESC;

	-- удаление лишней строки с полным бэкапом, который уже использован
	DELETE FROM @backups WHERE isFull = 1;

	-- проверка, есть ли дифференциальные бэкапы
	SET @found = (SELECT count(*) FROM @backups);

	IF @found = 0
	BEGIN
		RETURN
	END

	-- итератор по дифференциальным бэкапам
	-- дата выбирается, чтобы отсортировать дифференциальные бэкапы в нужном порядке
	DECLARE backupCursor CURSOR FOR
		SELECT filePath, dtTm FROM @backups ORDER BY dtTm DESC;
	OPEN backupCursor;

	-- путь к нужному файлу
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

EXEC restoreDB @dbName = 'testdb', @date = '10/01/2018';