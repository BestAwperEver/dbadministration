USE AdventureWorks2012;
DROP FUNCTION IF EXISTS get_permissions;
GO

CREATE FUNCTION get_permissions(@dbName nvarchar(128))
RETURNS @rtrnTbl TABLE 
	(
		entity_name nvarchar(128),
		subentity_name nvarchar(128),
		permission_name nvarchar(128)
	)
AS
BEGIN
	DECLARE tblCursor CURSOR FOR
		SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_TYPE = 'BASE TABLE'
		AND TABLE_CATALOG = @dbName;
	OPEN tblCursor;

	DECLARE @tblName nvarchar(128);
	FETCH NEXT FROM tblCursor INTO @tblName;

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