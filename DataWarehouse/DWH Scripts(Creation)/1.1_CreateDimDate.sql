use Olist_Ecommerce_DWHG;
-- drop the table if it exists
if exists (select * from sys.tables where name = 'DimDate')
	drop table DimDate;
go

-- create the dimension table
create table dbo.DimDate (
    DateSK int not null, -- to make the id the yyyymmdd format
    [Date] datetime not null,
    [Day] char(2) not null,
    DaySuffix varchar(4) not null,
    DayOfWeek varchar(9) not null,
    DOWInMonth tinyint not null,
    DayOfYear int not null,
    WeekOfYear tinyint not null,
    WeekOfMonth tinyint not null,
    [Month] char(2) not null,
    MonthName varchar(9) not null,
    Quarter tinyint not null,
    QuarterName varchar(6) not null,
    [Year] char(4) not null,
    StandardDate varchar(10) null,
    HolidayText varchar(50) null,
    constraint PK_DimDate primary key clustered (DateSK)
) on [primary];
go

-- populate date dimension
truncate table DimDate;

declare @tmpDOW table (DOW int, Cntr int); -- table for counting DOW occurrence in a month
insert into @tmpDOW(DOW, Cntr) values(1,0); -- used in the loop below
insert into @tmpDOW(DOW, Cntr) values(2,0);
insert into @tmpDOW(DOW, Cntr) values(3,0);
insert into @tmpDOW(DOW, Cntr) values(4,0);
insert into @tmpDOW(DOW, Cntr) values(5,0);
insert into @tmpDOW(DOW, Cntr) values(6,0);
insert into @tmpDOW(DOW, Cntr) values(7,0);

declare @StartDate datetime,
        @EndDate datetime,
        @Date datetime,
        @WDofMonth int,
        @CurrentMonth int;

select @StartDate = '2016-01-01',  -- set the start and end date
       @EndDate = '2020-12-31',    -- non-inclusive, stops on the day before this
       @CurrentMonth = 1;          -- counter used in loop below

select @Date = @StartDate;

while @Date < @EndDate
begin
    if datepart(month, @Date) <> @CurrentMonth
    begin
        select @CurrentMonth = datepart(month, @Date);
        update @tmpDOW set Cntr = 0;
    end

    update @tmpDOW
    set Cntr = Cntr + 1
    where DOW = datepart(dw, @Date);

    select @WDofMonth = Cntr
    from @tmpDOW
    where DOW = datepart(dw, @Date);

    insert into DimDate (
        DateSK, -- to make the DateSK the yyyymmdd format
        [Date],
        [Day],
        DaySuffix,
        DayOfWeek,
        DOWInMonth,
        DayOfYear,
        WeekOfYear,
        WeekOfMonth,
        [Month],
        MonthName,
        Quarter,
        QuarterName,
        [Year]
    )
    select convert(varchar, @Date, 112), -- to make the DateSK the yyyymmdd format
           @Date [Date],
           datepart(day, @Date) [Day],
           case 
               when datepart(day, @Date) in (11,12,13) then cast(datepart(day, @Date) as varchar) + 'th'
               when right(datepart(day, @Date), 1) = 1 then cast(datepart(day, @Date) as varchar) + 'st'
               when right(datepart(day, @Date), 1) = 2 then cast(datepart(day, @Date) as varchar) + 'nd'
               when right(datepart(day, @Date), 1) = 3 then cast(datepart(day, @Date) as varchar) + 'rd'
               else cast(datepart(day, @Date) as varchar) + 'th'
           end as DaySuffix,
           case datepart(dw, @Date)
               when 1 then 'Sunday'
               when 2 then 'Monday'
               when 3 then 'Tuesday'
               when 4 then 'Wednesday'
               when 5 then 'Thursday'
               when 6 then 'Friday'
               when 7 then 'Saturday'
           end as DayOfWeek,
           @WDofMonth [DOWInMonth], -- occurrence of this day in this month
           datepart(dy, @Date) [DayOfYear], -- day of the year
           datepart(ww, @Date) [WeekOfYear], -- week of the year
           datepart(ww, @Date) + 1 - datepart(ww, cast(datepart(mm, @Date) as varchar) + '/1/' + cast(datepart(yy, @Date) as varchar)) [WeekOfMonth],
           datepart(month, @Date) [Month], -- to be converted with leading zero later
           datename(month, @Date) [MonthName],
           datepart(qq, @Date) [Quarter], -- calendar quarter
           case datepart(qq, @Date)
               when 1 then 'First'
               when 2 then 'Second'
               when 3 then 'Third'
               when 4 then 'Fourth'
           end as QuarterName,
           datepart(year, @Date) [Year];

    select @Date = dateadd(dd, 1, @Date);
end;

-- update leading zeros for day and month
update dbo.DimDate
set [Day] = '0' + [Day]
where len([Day]) = 1;

update dbo.DimDate
set [Month] = '0' + [Month]
where len([Month]) = 1;

update dbo.DimDate
set StandardDate = [Month] + '/' + [Day] + '/' + [Year];

-- add holidays ----------------------------------------------------------------------------------------------
-- Thanksgiving (Fourth Thursday in November)
update DimDate
set HolidayText = 'Thanksgiving Day'
where [Month] = 11
  and [DayOfWeek] = 'Thursday'
  and DOWInMonth = 4;

-- Christmas
update DimDate
set HolidayText = 'Christmas Day'
where [Month] = 12 and [Day] = 25;

-- 4th of July
update DimDate
set HolidayText = 'Independence Day'
where [Month] = 7 and [Day] = 4;

-- New Year's Day
update DimDate
set HolidayText = 'New Year''s Day'
where [Month] = 1 and [Day] = 1;

-- Memorial Day (Last Monday in May)
update DimDate
set HolidayText = 'Memorial Day'
where DateSK in (
    select max(DateSK)
    from DimDate
    where MonthName = 'May'
      and DayOfWeek = 'Monday'
    group by [Year], [Month]
);

-- Labor Day (First Monday in September)
update DimDate
set HolidayText = 'Labor Day'
where DateSK in (
    select min(DateSK)
    from DimDate
    where MonthName = 'September'
      and DayOfWeek = 'Monday'
    group by [Year], [Month]
);

-- Valentine's Day
update DimDate
set HolidayText = 'Valentine''s Day'
where [Month] = 2 and [Day] = 14;

-- Saint Patrick's Day
update DimDate
set HolidayText = 'Saint Patrick''s Day'
where [Month] = 3 and [Day] = 17;

-- Martin Luther King Jr Day (Third Monday in January starting in 1983)
update DimDate
set HolidayText = 'Martin Luther King Jr Day'
where [Month] = 1
  and DayOfWeek = 'Monday'
  and [Year] >= 1983
  and DOWInMonth = 3;

-- President's Day (Third Monday in February)
update DimDate
set HolidayText = 'President''s Day'
where [Month] = 2
  and DayOfWeek = 'Monday'
  and DOWInMonth = 3;

-- Mother's Day (Second Sunday of May)
update DimDate
set HolidayText = 'Mother''s Day'
where [Month] = 5
  and DayOfWeek = 'Sunday'
  and DOWInMonth = 2;

-- Father's Day (Third Sunday of June)
update DimDate
set HolidayText = 'Father''s Day'
where [Month] = 6
  and DayOfWeek = 'Sunday'
  and DOWInMonth = 3;

-- Halloween
update DimDate
set HolidayText = 'Halloween'
where [Month] = 10 and [Day] = 31;

-- Election Day (The first Tuesday after the first Monday in November)
begin try
    drop table #tmpHoliday;
end try
begin catch
    -- do nothing
end catch;

create table #tmpHoliday(DateSK int identity(1,1), DateID int, Week tinyint, Year char(4), Day char(2));

insert into #tmpHoliday(DateID, [Year], [Day])
select DateSK, [Year], [Day]
from DimDate
where [Month] = 11
  and DayOfWeek = 'Monday'
order by Year, Day;

declare @Cntr int, @Pos int, @StartYear int, @EndYear int, @CurrentYear int, @MinDay int;

select @CurrentYear = min([Year]),
       @StartYear = min([Year]),
       @EndYear = max([Year])
from #tmpHoliday;

while @CurrentYear <= @EndYear
begin
    select @Cntr = count([Year])
    from #tmpHoliday
    where [Year] = @CurrentYear;

    set @Pos = 1;

    while @Pos <= @Cntr
    begin
        select @MinDay = min(Day)
        from #tmpHoliday
        where [Year] = @CurrentYear
          and [Week] is null;

        update #tmpHoliday
        set [Week] = @Pos
        where [Year] = @CurrentYear
          and [Day] = @MinDay;

        set @Pos = @Pos + 1;
    end;

    set @CurrentYear = @CurrentYear + 1;
end;

update DT
set HolidayText = 'Election Day'
from DimDate DT
join #tmpHoliday HL on (HL.DateID + 1) = DT.DateSK
where [Week] = 1;

drop table #tmpHoliday;
go

-- create indexes -------------------------------------------------------------------------------------------
create unique nonclustered index IDX_DimDate_Date on DimDate ([Date] asc);
create nonclustered index IDX_DimDate_Day on DimDate ([Day] asc);
create nonclustered index IDX_DimDate_DayOfWeek on DimDate (DayOfWeek asc);
create nonclustered index IDX_DimDate_DOWInMonth on DimDate (DOWInMonth asc);
create nonclustered index IDX_DimDate_DayOfYear on DimDate (DayOfYear asc);
create nonclustered index IDX_DimDate_WeekOfYear on DimDate (WeekOfYear asc);
create nonclustered index IDX_DimDate_WeekOfMonth on DimDate (WeekOfMonth asc);
create nonclustered index IDX_DimDate_Month on DimDate ([Month] asc);
create nonclustered index IDX_DimDate_MonthName on DimDate (MonthName asc);
create nonclustered index IDX_DimDate_Quarter on DimDate (Quarter asc);
create nonclustered index IDX_DimDate_QuarterName on DimDate (QuarterName asc);
create nonclustered index IDX_DimDate_Year on DimDate ([Year] asc);
create nonclustered index IDX_DimDate_HolidayText on DimDate (HolidayText asc);

print convert(varchar, getdate(), 113); -- used for checking run time