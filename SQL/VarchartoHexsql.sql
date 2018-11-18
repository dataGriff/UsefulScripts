declare @hexstring varchar(max);

set @hexstring = 'abcedf012439';

select cast('' as xml).value('xs:hexBinary( substring(sql:variable("@hexstring"), sql:column("t.pos")) )', 'varbinary(max)')

from (select case substring(@hexstring, 1, 2) when '0x' then 3 else 0 end) as t(pos)

go