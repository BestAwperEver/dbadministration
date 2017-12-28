USE AdventureWorks2012;
DROP FUNCTION IF EXISTS get_permissions;
GO

-- возвращает таблицу с данными, полученными при помощи fn_my_permissions
CREATE FUNCTION get_permissions(@dbName nvarchar(128))
-- @dbName - имя базы данных, в которой необходимо посмотреть привилегии
RETURNS @rtrnTbl TABLE 
	(
		entity_name nvarchar(128),
		subentity_name nvarchar(128),
		permission_name nvarchar(128)
	)
AS
BEGIN

	-- итератор по именам таблиц внутри указанной бд
	DECLARE tblCursor CURSOR FOR
		SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_CATALOG = @dbName;
	OPEN tblCursor;

	-- переменная для имени таблицы
	DECLARE @tblName nvarchar(128);
	FETCH NEXT FROM tblCursor INTO @tblName;

	-- объединение данных в одну таблицу
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO @rtrnTbl SELECT * FROM fn_my_permissions (@tblName, 'OBJECT');
		FETCH NEXT FROM tblCursor INTO @tblName;
	END

	CLOSE tblCursor;  
	DEALLOCATE tblCursor; 

	RETURN
END
GO

SELECT * FROM get_permissions('AdventureWorks2012');