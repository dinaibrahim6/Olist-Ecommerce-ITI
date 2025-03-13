use Olist_Ecommerce_DWHG;

-- add fiscal columns to the DimDate table
alter table DimDate add FiscalDay char(2);
alter table DimDate add FiscalMonth char(2);
alter table DimDate add FiscalMonthName varchar(9);
alter table DimDate add FiscalQuarter tinyint;
alter table DimDate add FiscalQuarterName varchar(6);
alter table DimDate add FiscalYear char(4);
go

-- set the fiscal year offset
declare @DaysOffSet int;
select @DaysOffSet = -6; -- adjust this value based on your fiscal year start

declare @StartDate datetime,
        @EndDate datetime,
        @Date datetime,
        @FiscalDate datetime,
        @QuarterName varchar(6),
        @MonthName varchar(9);

-- set the start and end dates based on the DimDate table
select @StartDate = (select min([Date]) from DimDate),
       @EndDate = (select max([Date]) from DimDate);

select @Date = @StartDate;
select @FiscalDate = dateadd(day, @DaysOffSet, @StartDate);

-- loop through each date and update fiscal columns
while @Date < @EndDate
begin
    select @QuarterName =
        case datepart(quarter, @FiscalDate)
            when 1 then 'First'
            when 2 then 'Second'
            when 3 then 'Third'
            when 4 then 'Fourth'
            else 'Error'
        end;

    update DimDate
    set FiscalDay = datepart(day, @FiscalDate),
        FiscalMonth = right('0' + convert(char(2), datepart(month, @FiscalDate)), 2),
        FiscalMonthName = datename(month, @FiscalDate),
        FiscalQuarter = datepart(quarter, @FiscalDate),
        FiscalQuarterName = @QuarterName,
        FiscalYear = datepart(year, @FiscalDate)
    where [Date] = @Date;

    select @Date = dateadd(day, 1, @Date);
    select @FiscalDate = dateadd(day, 1, @FiscalDate);
end;

print convert(varchar, getdate(), 113); -- used for checking run time

-- create indexes for fiscal columns
create nonclustered index IDX_DimDate_FiscalMonth on DimDate (FiscalMonth asc);
create nonclustered index IDX_DimDate_FiscalMonthName on DimDate (FiscalMonthName asc);
create nonclustered index IDX_DimDate_FiscalQuarter on DimDate (FiscalQuarter asc);
create nonclustered index IDX_DimDate_FiscalQuarterName on DimDate (FiscalQuarterName asc);
create nonclustered index IDX_DimDate_FiscalYear on DimDate (FiscalYear asc);

print convert(varchar, getdate(), 113); -- used for checking run time