/*
  Using the AdventureWorks2022 db found https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms
  I needed to create multiple datasets for some testing - this script uses the Sales data and created multiple views named 'vSalesC*' 1-50.
*/

USE [AdventureWorks2022];
GO

DECLARE @i INT = 1;
DECLARE @sql NVARCHAR(MAX);

WHILE @i <= 50
BEGIN
    -- Drop the view if it exists
    SET @sql = '
    IF OBJECT_ID(''Sales.vSalesC' + CAST(@i AS VARCHAR(2)) + ''', ''V'') IS NOT NULL
        DROP VIEW Sales.vSalesC' + CAST(@i AS VARCHAR(2)) + ';
    ';
    EXEC(@sql);

    -- Create the view (must be first in batch)
    SET @sql = '
    CREATE VIEW [Sales].[vSalesC' + CAST(@i AS VARCHAR(2)) + '] 
    AS 
    SELECT [SalesOrderID]
          ,[RevisionNumber]
          ,[OrderDate]
          ,[DueDate]
          ,[ShipDate]
          ,[Status]
          ,[OnlineOrderFlag]
          ,[SalesOrderNumber]
          ,[PurchaseOrderNumber]
          ,[AccountNumber]
          ,[CustomerID]
          ,[SalesPersonID]
          ,[TerritoryID]
          ,[BillToAddressID]
          ,[ShipToAddressID]
          ,[ShipMethodID]
          ,[CreditCardID]
          ,[CreditCardApprovalCode]
          ,[CurrencyRateID]
          ,[SubTotal]
          ,[TaxAmt]
          ,[Freight]
          ,[TotalDue]
          ,[Comment]
          ,[rowguid]
          ,[ModifiedDate]
          , ''C' + CAST(@i AS VARCHAR(2)) + ''' AS CompanyID
    FROM [AdventureWorks2022].[Sales].[SalesOrderHeader];
    ';
    EXEC(@sql);

    -- Extended property for documentation
    SET @sql = '
    EXEC sys.sp_addextendedproperty 
        @name = N''MS_Description'', 
        @value = N''Sales view hardcoded with CompanyID = C' + CAST(@i AS VARCHAR(2)) + '.'',
        @level0type = N''SCHEMA'', @level0name = N''Sales'', 
        @level1type = N''VIEW'', @level1name = N''vSalesC' + CAST(@i AS VARCHAR(2)) + ''';';
    EXEC(@sql);

    SET @i += 1;
END
GO
