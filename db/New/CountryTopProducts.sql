SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE CountryTopProducts
	@Country VARCHAR(50),
	@FromDate VARCHAR(50),
	@ToDate VARCHAR(50)

AS
BEGIN 
	SET NOCOUNT ON; 
	SELECT Products.ProductName, Sales.Date, SUM(Sales.EmployeeSales) AS Quantity FROM
		(
			SELECT  [Order Details].ProductID, 
					SUM(Quantity)  AS EmployeeSales,  
					DATEFROMPARTS(DATEPART(YEAR, Orders.OrderDate), DATEPART(MONTH, Orders.OrderDate), 1) AS Date
			FROM [Order Details]
				INNER JOIN Orders ON Orders.OrderID = [Order Details].OrderID
			GROUP BY [Order Details].ProductID, DATEFROMPARTS(DATEPART(YEAR, Orders.OrderDate), DATEPART(MONTH, Orders.OrderDate), 1) 
		) AS Sales 
		INNER JOIN Products ON Products.ProductID = Sales.ProductID
	WHERE Sales.ProductID IN (
		SELECT TOP 5 Products.ProductID AS Quantity FROM
			(
				SELECT [Order Details].ProductID, 
						Orders.ShipCountry,
						SUM(Quantity)  AS EmployeeSales,  
						DATEFROMPARTS(DATEPART(YEAR, Orders.OrderDate), DATEPART(MONTH, Orders.OrderDate), 1) AS Date
				FROM [Order Details]
					INNER JOIN Orders ON Orders.OrderID = [Order Details].OrderID
				WHERE 
					Orders.ShipCountry = @Country AND
					DATEFROMPARTS(DATEPART(YEAR, Orders.OrderDate), DATEPART(MONTH, Orders.OrderDate), 1) >= CONVERT(DATE, @FromDate,112) AND
					DATEFROMPARTS(DATEPART(YEAR, Orders.OrderDate), DATEPART(MONTH, Orders.OrderDate), 1) <= CONVERT(DATE, @ToDate,112)
				GROUP BY [Order Details].ProductID, DATEFROMPARTS(DATEPART(YEAR, Orders.OrderDate), DATEPART(MONTH, Orders.OrderDate), 1), Orders.ShipCountry
			) AS Sales 
			INNER JOIN Products ON Products.ProductID = Sales.ProductID
		GROUP BY Products.ProductID
		ORDER BY SUM(Sales.EmployeeSales) DESC
	)
	GROUP BY Sales.Date, Products.ProductName
END
