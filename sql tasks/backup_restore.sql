-- ��������� ����������� � ��������������

/* 
������� - �������� 2 �������� ���������:
1) ��� �������� ��������� ����� (������ ��� ����������) ��
2) ��� �������������� �� �� ��������� ������ ��������� ����� � ��������� ����, �� ������� ���� ������������ ��

*/

/*

��� �������� ������ �� ��������� backup device - ����. 
��� �������� ������ � ���� �� ������� (� ��������� - �����) ��� ����������
��������������� ��������� ��������� ����� (������� - ������ ��� ����������), 
��� �� ������������ ��� ����������, � ������ ����������� � ����� (������, ���������� ������ � ������� "TO TAPE").
��� � ����� ����� ���������� ��������� �����, ������� ����������� �� ������� (������� � 1).
��� �������� ������ ������ �� ������� � ������ ��������� FILE = 1, 2, ... 
��� �������������� (��� �������� FILE=...) ������������ ������ ������ ������.

��� ���� ������������ ��� ������: 

1) ��������� ����� ��������� ����� ��� �������������

2) � BACKUP DATABASE ��������� ����� INIT, ������� ��������� ������������ ���� ������ 

3) ������ ���� ������ ���������� �����

*/

-- ������ 
BACKUP DATABASE Secure
TO
DISK = 'c:\temp\secure_full.bak'
WITH INIT;
GO

-- ���������� (������ ��������� ������������ ��������� ������)
BACKUP DATABASE Secure
TO
DISK = 'c:\temp\secure_diff.bak'
WITH DIFFERENTIAL, INIT;

-- �������������� � �������� �����
RESTORE DATABASE Secure
FROM
DISK = 'c:\temp\secure_full.bak'
WITH
NORECOVERY;
GO

RESTORE DATABASE Secure
FROM
DISK = 'c:\temp\secure_diff.bak'
WITH
RECOVERY;
GO

-- �������������� � ������ ��
RESTORE DATABASE Secure2
FROM
DISK = 'c:\temp\secure_full.bak'
WITH
MOVE 'Secure' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure2.mdf',
MOVE 'Secure_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure_log2.ldf',
NORECOVERY;
GO

RESTORE DATABASE Secure2
FROM
DISK = 'c:\temp\secure_diff.bak'
WITH
MOVE 'Secure' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure2.mdf',
MOVE 'Secure_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure_log2.ldf',
RECOVERY;
GO

-- �������� ����������� ������ � ����������� �������������� (��� ��������������)
RESTORE VERIFYONLY
FROM
DISK = 'c:\temp\secure_diff.bak'
WITH
MOVE 'Secure' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure2.mdf',
MOVE 'Secure_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure_log2.ldf';