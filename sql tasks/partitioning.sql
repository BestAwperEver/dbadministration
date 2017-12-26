CREATE DATABASE part_demo;

USE part_demo;
GO

-- Partitioning (c��������������, ���������� ������)

-- ��� �������� �������, ����������� �� ������� (������), ����������� ��������� ��������:

-- 1) �������� ����� ������ (���-�� ����� >= ������������ ���-�� ��������)
-- + �������� ������, �������� � ��� ������

ALTER DATABASE part_demo
ADD FILEGROUP g1;

ALTER DATABASE part_demo
ADD FILEGROUP g2;

ALTER DATABASE part_demo
ADD FILEGROUP g3;

-- ���������� ������ � ������ ������
ALTER DATABASE part_demo
ADD FILE
(
NAME = f1,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\f1.ndf'
) TO FILEGROUP g1;

ALTER DATABASE part_demo
ADD FILE
(
NAME = f2,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\f2.ndf'
) TO FILEGROUP g2;

ALTER DATABASE part_demo
ADD FILE
(
NAME = f3,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\f3.ndf'
) TO FILEGROUP g3;

-- 2) �������� ������� ���������� (PARTITION FUNCTION)
-- ������� ���������� - ������� ���������� ������ ������������� ���� �� ��������, ���������� ����� �������� ��������� �������� (�.�. ��������, ������� �� ������� ����������)
-- ���-�� �������� = ���-�� ��������� �������� + 1
CREATE PARTITION FUNCTION my_pf(int) -- ������� ��� ���� ��������
AS
RANGE LEFT
FOR VALUES (10, 20)

-- 3) �������� ����� ���������� (PARTITION SCHEME)
-- ����� ���������� - ������, ����������� ����� ���������� �������� (����� ������) � ���������� ���������� ������ (������� ����������)
-- � ���������� ����� ���������� ������������ ������ ������ ������ ��� ���������� �������
CREATE PARTITION SCHEME my_ps
AS PARTITION my_pf -- ����� �������� �� ������� ���������� my_pf
TO (g1, g2, g3) -- � ������� � ����� �������� ������ (g1, g2, g3)


-- 4) �������� ����� ����������� �������. ������� �������� �� ��������� ����� ����� ����������, ���������� ������� ������ ������� - ���� ����������
-- ��� ����� ���������� ������ ��������� � ����� ��������� ������� ����������

CREATE TABLE t1 (c1 int, c2 int)
ON my_ps(c1);

-- ������ ��������� ������� �������
-- (�� �������� ������ ������� �� ��������, ������������� �������)

DECLARE @i int;
SET @i=30;
WHILE (@i<40)
BEGIN
	INSERT INTO t1(c1, c2)
	VALUES (@i, @i+1);
	
	SET @i = @i + 1;
END;


/*
������ �������� �������� ��������� ������� �� ����� ����� ���������� 
�������� �������� ����������� �������
*/

CREATE CLUSTERED INDEX index_t1_c1
ON t1(c1)
WITH (DROP_EXISTING = ON)
ON my_ps(c1);


-- ��� ��������� ��������� ��������� �������� ������� ���������� (= ������ �������) ��� ���������� ���������
$PARTITION.my_pf(int_value_2_calc_partition)

-- ������ (���-�� ������� � ������ ������ ����������)
SELECT COUNT(*) FROM t1
GROUP BY $PARTITION.my_pf(c1)

-- ��� ��������� �������, ���������� �������� � ��������, �������� ����������, ����������, ������ � �.�.
SELECT * FROM sys.partitions
SELECT * FROM sys.partition_functions
SELECT * FROM sys.partition_parameters
SELECT * FROM sys.partition_range_values
SELECT * FROM sys.partition_schemes
SELECT * FROM sys.data_spaces
SELECT * FROM sys.destination_data_spaces 

------------------------------------------------

-- ��� ���������� ������ ������� ����� �������������� ������ ������
ALTER DATABASE part_demo
	ADD FILEGROUP g4;
GO	

ALTER DATABASE part_demo
ADD FILE
(
NAME = f1,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\f1.ndf'
) TO FILEGROUP g1;

-- ������ ����� ����������, �������� "��������" ������ ��� �������� �������, ���������� ��� NEXT USED
ALTER PARTITION SCHEME ps_t2
NEXT USED g4

-- ��������� ����� ������ � ������� ���������� (��� ��������, ���� � ��������� � ��� ����� ���������� ���� ������ NEXT USED)
ALTER PARTITION FUNCTION my_pf()
SPLIT RANGE (30)

-- ����� ���������� ������� 
ALTER PARTITION FUNCTION my_pf()
MERGE RANGE (30)

-- ����� ��������� ������ ������������� ������� � ���� �� �������� � ����� ����������
ALTER TABLE t2
SWITCH TO my_partition_scheme PARTITION 1;

