USE AdventureWorks2012;
GO

DROP TABLE IF EXISTS test_table;

-- копия таблицы, на которой будет произведено партицирование
SELECT * INTO test_table
FROM HumanResources.Employee;
GO

-- добавление файловых групп
ALTER DATABASE AdventureWorks2012  
ADD FILEGROUP group1;  
GO
  
ALTER DATABASE AdventureWorks2012  
ADD FILEGROUP group2;  
GO
  
ALTER DATABASE AdventureWorks2012  
ADD FILEGROUP group3;  
GO   

-- добавление файлов к файловым группам
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

-- по 100 строк в одной партиции
CREATE PARTITION FUNCTION my_fn (int)  
    AS RANGE LEFT FOR VALUES (100, 200);  
GO

-- создание схемы партицирования
CREATE PARTITION SCHEME my_ps 
    AS PARTITION my_fn  
    TO (group1, group2, group3);  
GO

-- создание кластерного индекса с использованием схемы
CREATE CLUSTERED INDEX ix_test_table_BEid
	ON dbo.test_table(BusinessEntityID)
	WITH (DROP_EXISTING = ON)
	ON my_ps(BusinessEntityID);
GO

-- подсчёт количества строк в каждой партиции
SELECT COUNT(*) FROM test_table
GROUP BY $PARTITION.my_fn(BusinessEntityID);
GO

-- добавление новой файловой группы
ALTER DATABASE AdventureWorks2012
	ADD FILEGROUP group4;
GO	

-- и нового файла для неё
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

-- добавление новой партиции
ALTER PARTITION SCHEME my_ps
NEXT USED group4

-- в которой будут строки после 250-ой
ALTER PARTITION FUNCTION my_fn()
SPLIT RANGE (250)
GO

-- снова подсчитываем количество строк в каждой партиции
SELECT COUNT(*) FROM test_table
GROUP BY $PARTITION.my_fn(BusinessEntityID);
GO