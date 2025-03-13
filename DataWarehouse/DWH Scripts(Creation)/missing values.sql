

INSERT INTO 
DimOrderReview 
(review_id_sk, review_id, order_id, review_score, review_status,
review_creation_date, review_answer_timestamp, is_current,
start_date, end_date)
VALUES (-1, 'UNKNOWN', 'UNKNOWN', NULL, 'No Review', NULL, NULL, 0, 
GETDATE(), NULL);


INSERT INTO DimDate (DateSK, Date, Day, DaySuffix, DayOfWeek, DOWInMonth, 
DayOfYear,WeekOfYear, WeekOfMonth, Month, MonthName, Quarter, QuarterName, Year)
VALUES 
(-1, '1900-01-01', '01', 'st', 'Monday', 1, 1, 1, 1, '01',
'January', 1, 'Q1', 1900);
