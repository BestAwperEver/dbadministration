-- резервное копирование и восстановление

/* 
«адание - написать 2 хранимые процедуры:
1) ƒл€ создани€ резервной копии (полной или разностной) Ѕƒ
2) ƒл€ воостановлени€ Ѕƒ из хранимого набора резервных копий с указанием даты, на которую надо восстановить Ѕƒ

*/

/*

ѕри создании бэкапа мы указываем backup device - файл. 
ѕри указании одного и того же девайса (в частности - файла) дл€ нескольких
последовательно сделанных резервных копий (неважно - полных или разностных), 
они не переписывают его содержание, а просто добавл€ютс€ в конец (видимо, наследство работы с пленкой "TO TAPE").
“ак в одном файле по€вл€етс€ множество копий, которые различаютс€ по номерам (начина€ с 1).
ƒл€ указани€ номера бэкапа на девайсе в опци€х указывают FILE = 1, 2, ... 
ѕри восстановлении (без указани€ FILE=...) используетс€ всегда перва€ верси€.

 ак этим пользоватьс€ без ошибок: 

1) ”читывать номер резервной копии при восстновлении

2) ¬ BACKUP DATABASE указывать опцию INIT, котора€ позвол€ет переписывать файл заново 

3) давать всем файлам уникальные имена

*/

-- полна€ 
BACKUP DATABASE Secure
TO
DISK = 'c:\temp\secure_full.bak'
WITH INIT;
GO

-- разностна€ (только изменени€ относительно последней полной)
BACKUP DATABASE Secure
TO
DISK = 'c:\temp\secure_diff.bak'
WITH DIFFERENTIAL, INIT;

-- восстановление в исходное место
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

-- восстановление в другую Ѕƒ
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

-- проверка целостности архива и возможности восстановлени€ (без восстановлени€)
RESTORE VERIFYONLY
FROM
DISK = 'c:\temp\secure_diff.bak'
WITH
MOVE 'Secure' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure2.mdf',
MOVE 'Secure_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\secure_log2.ldf';