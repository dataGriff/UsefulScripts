declare @totalSize int = 1000000;
declare @drawSize int = 10000;
 
if OBJECT_ID('tempdb..#idRand') is not null
drop table #idRand;
 
with idGen as (
    select 1 as id
    union all
    select id + 1 from idGen where id < @totalSize
)
select
    id,
    rand(checksum(id)) as randomNumber
into -- drop table
    #idRand
from
    idGen
option (MAXRECURSION 0);
 
if OBJECT_ID('tempdb..#interval') is not null
drop table #interval;
 
select
    id,
    sum(randomNumber) over (order by id) - randomNumber as intervalFrom,
    sum(randomNumber) over (order by id) as intervalTo
into -- drop table
    #interval
from
    #idRand;
 
create unique clustered index uq_intervals on #interval (intervalFrom, intervalTo);
 
if OBJECT_ID('tempdb..#sequence') is not null
drop table #sequence;
 
select
    id,
    sum(randomNumber) over (order by id) as intervalTo
into -- drop table
    #sequence
from
    #idRand;
 
create unique clustered index uq_sequence on #sequence (intervalTo);
 
declare @intervalLength float = (select max(intervalTo) from #interval);
 
if OBJECT_ID('tempdb..#draw') is not null
drop table #draw;
 
select top (@drawSize)
    rand(checksum(newid())) * @intervalLength as luckyNumber
into -- drop table
    #draw
from
    #idRand;
 
create unique clustered index pk_draw on #draw (luckyNumber);
 
if OBJECT_ID('tempdb..#winners_between') is not null
drop table #winners_between;
 
if OBJECT_ID('tempdb..#winners_apply') is not null
drop table #winners_apply;
 
set STATISTICS PROFILE on;
set STATISTICS IO on;
set STATISTICS TIME on;
 
select
    id
into -- drop table
    #winners_between
from
    #interval i
join
    #draw d
on
    d.luckyNumber between i.intervalFrom and i.intervalTo;
 
set STATISTICS TIME off;
set STATISTICS IO off;
set STATISTICS PROFILE off;
 
set STATISTICS PROFILE on;
set STATISTICS IO on;
set STATISTICS TIME on;
 
select
    x.id
into -- drop table
    #winners_apply
from
    #draw d
cross apply (
    select top 1
        i.id
    from
        #sequence i
    where
        d.luckyNumber < i.intervalTo
    order by
        d.luckyNumber desc
) x
 
set STATISTICS TIME off;
set STATISTICS IO off;
set STATISTICS PROFILE off;
 
--select * from #winners_between order by id
--select * from #winners_apply order by id

set STATISTICS PROFILE on;
set STATISTICS IO on;
set STATISTICS TIME on;
 

 DECLARE @Sql NVARCHAR(MAX) = '
select
    x.id
into -- drop table
    #winners_apply
from
    #draw d
cross apply (
    select top 1
        i.id
    from
        #sequence i
    where
        d.luckyNumber < i.intervalTo
    order by
        d.luckyNumber desc
) x'

EXEC sp_executesql @sql
 
set STATISTICS TIME off;
set STATISTICS IO off;
set STATISTICS PROFILE off;
 