USE AdventureWorks2012;
GO

DROP TABLE IF EXISTS test_table;

SELECT * INTO test_table
FROM HumanResources.Employee;
GO

ALTER DATABASE AdventureWorks2012  
ADD FILEGROUP group1;  
GO
  
ALTER DATABASE AdventureWorks2012  
ADD FILEGROUP group2;  
GO
  
ALTER DATABASE AdventureWorks2012  
ADD FILEGROUP group3;  
GO   


ALTER DATABASE AdventureWorks2012   
ADD FILE 
(  
    NAME = file1,  
    FILENAME = 'D:\Programs\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\file1.ndf',  
    SIZE = 5MB,  
    MAXSIZE = 100MB,  
    FILEGROWTH = 5MB  
)  
TO FILEGROUP group1;
GO
  
ALTER DATABASE AdventureWorks2012   
ADD FILE   
(  
    NAME = file2,  
    FILENAME = 'D:\Programs\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\file2.ndf',  
    SIZE = 5MB,  
    MAXSIZE = 100MB,  
    FILEGROWTH = 5MB  
)  
TO FILEGROUP group2;  
GO

ALTER DATABASE AdventureWorks2012  
ADD FILE   
(  
    NAME = file3,  
    FILENAME = 'D:\Programs\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\file3.ndf',  
    SIZE = 5MB,  
    MAXSIZE = 100MB,  
    FILEGROWTH = 5MB  
)  
TO FILEGROUP group3;  
GO

CREATE PARTITION FUNCTION my_fn (int)  
    AS RANGE LEFT FOR VALUES (100, 200);  
GO

CREATE PARTITION SCHEME my_ps 
    AS PARTITION my_fn  
    TO (group1, group2, group3);  
GO

CREATE CLUSTERED INDEX ix_test_table_BEid
	ON dbo.test_table(BusinessEntityID)
	--WITH (DROP_EXISTING = ON)
	ON my_ps(BusinessEntityID);
GO

SELECT COUNT(*) FROM test_table
GROUP BY $PARTITION.my_fn(BusinessEntityID);
GO

ALTER DATABASE AdventureWorks2012
	ADD FILEGROUP group4;
GO	

ALTER DATABASE AdventureWorks2012  
ADD FILE   
(  
    NAME = file4,  
    FILENAME = 'D:\Programs\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\file4.ndf',  
    SIZE = 5MB,  
    MAXSIZE = 100MB,  
    FILEGROWTH = 5MB  
)  
TO FILEGROUP group4;  
GO

ALTER PARTITION SCHEME my_ps
NEXT USED group4

ALTER PARTITION FUNCTION my_fn()
SPLIT RANGE (250)
GO

SELECT COUNT(*) FROM test_table
GROUP BY $PARTITION.my_fn(BusinessEntityID);
GO