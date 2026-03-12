/*
  This query takes period financial targets and spreads them out into daily values.
  It converts a wide table of period targets into one row per day per account with an evenly distributed value.
*/

/*
[Financial Targets] sample data:

| Account     | P01 FY25-26 | P02 FY25-26 | P03 FY25-26 |
|------------|-------------|-------------|-------------|
| Sales      | 30000       | 28000       | 31000       |
| Marketing  | 15000       | 16000       | 15500       |
*/

/*
[Periods] sample data:

| Name        | StartAt    | EndAt      |
|------------|------------|------------|
| P01 FY25-26 | 2025-04-01 | 2025-04-30 |
| P02 FY25-26 | 2025-05-01 | 2025-05-31 |
*/

/*
-- Sample output of the query for two accounts and two periods:

| PeriodName  | Date       | Account    | DailyValue |
|------------|------------|-----------|------------|
| P01 FY25-26 | 2025-04-01 | Sales     | 1000       |
| P01 FY25-26 | 2025-04-02 | Sales     | 1000       |
| P01 FY25-26 | 2025-04-01 | Marketing | 500        |
| P01 FY25-26 | 2025-04-02 | Marketing | 500        |
| P02 FY25-26 | 2025-05-01 | Sales     | 903.23     |
| P02 FY25-26 | 2025-05-02 | Sales     | 903.23     |
| P02 FY25-26 | 2025-05-01 | Marketing | 516.13     |
| P02 FY25-26 | 2025-05-02 | Marketing | 516.13     |

-- Notes:
-- DailyValue = Period Target / DaysInPeriod
-- Dates repeat for every day in the period
*/

WITH CTE_Unpivoted AS
(
    SELECT
        [Account]
        , Period
        , Value
    FROM [Financial Targets]
    UNPIVOT
    (
        Value FOR Period IN (
         [P01 FY25-26]
        , [P02 FY25-26]
        , [P03 FY25-26]
        , [P04 FY25-26]
        , [P05 FY25-26]
        , [P06 FY25-26]
        , [P07 FY25-26]
        , [P08 FY25-26]
        , [P09 FY25-26]
        , [P10 FY25-26]
        , [P11 FY25-26]
        , [P12 FY25-26]
        )
    ) u
),
CTE_Periods AS (
    SELECT
        [Name] AS 'PeriodName'
        , [StartAt] AS 'StartDate'
        , [EndAt] AS 'EndDate'
        , DATEDIFF(day, [StartAt], [EndAt])+1 AS 'DaysInPeriod'
    FROM [Periods]
)
SELECT
    p.PeriodName
    , DATEADD(day, n.value, p.StartDate) AS [Date]
    , u.Account
    , CAST(u.Value AS FLOAT) / p.DaysInPeriod AS DailyValue
FROM CTE_Unpivoted u
JOIN CTE_Periods p
    ON u.Period = p.PeriodName
JOIN GENERATE_SERIES(0,100) n
    ON n.value < p.DaysInPeriod
