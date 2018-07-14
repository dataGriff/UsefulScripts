

DECLARE @hexbin VARBINARY(MAX);
SET @hexbin = (SELECT TOP 1 sid FROM sys.sql_logins)
SELECT '0x' + cast('' as xml).value('xs:hexBinary(sql:variable("@hexbin") )', 'varchar(max)') AS Sid;

go


SELECT  * FROM sys.sql_logins