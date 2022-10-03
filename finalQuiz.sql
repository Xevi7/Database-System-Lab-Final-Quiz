USE LugiOh
GO

--1
SELECT
	CustomerName,
	CustomerGender,
	CustomerPhone,
	CustomerAddress,
	CustomerDOB
FROM Customer
WHERE CustomerName LIKE '%l%'

--2
SELECT
	C.CustomerName,
	C.CustomerGender,
	C.CustomerPhone,
	C.CustomerAddress,
	[Transaction Month] = DATENAME(MONTH, ht.TransactionDate)
FROM Customer C
JOIN HeaderTransaction ht ON ht.CustomerID = c.CustomerID
WHERE C.CustomerID = 'CU002'

--3
SELECT
	[CardName]=LOWER(c.CardName),
	c.CardElement,
	c.CardLevel,
	c.CardAttack,
	c.CardDefense,
	[Total Transaction] = CAST(COUNT(dt.TransactionID) AS VARCHAR(100)) + ' time(s)'
FROM Cards c
JOIN DetailTransaction dt ON c.CardsID = dt.CardsID
WHERE c.CardElement = 'Dark'
GROUP BY c.CardName, c.CardElement, c.CardLevel, c.CardAttack, c.CardDefense

--4
SELECT
	c.CardName,
	c.CardElement,
	[Total Price] = SUM(c.CardPrice),
	[Total Transaction] = CAST(COUNT(dt.TransactionID) AS VARCHAR(50)) + ' time(s)'
FROM Cards c
JOIN DetailTransaction dt ON dt.CardsID = c.CardsID
JOIN HeaderTransaction ht ON ht.TransactionID = dt.TransactionID
WHERE DATEDIFF(MONTH,ht.TransactionDate,'2017-12-31') > 8
GROUP BY c.CardName, c.CardElement
UNION
SELECT
	c.CardName,
	c.CardElement,
	[Total Price] = SUM(c.CardPrice),
	[Total Transaction] = CAST(COUNT(dt.TransactionID) AS VARCHAR(50)) + ' time(s)'
FROM Cards c
JOIN DetailTransaction dt ON dt.CardsID = c.CardsID
JOIN HeaderTransaction ht ON ht.TransactionID = dt.TransactionID
WHERE c.CardPrice > 500000
GROUP BY c.CardName, c.CardElement

--5
SELECT
	c.CustomerName,
	c.CustomerGender,
	[CustomerDOB] = CONVERT(VARCHAR,c.CustomerDOB,107)
FROM Customer c
JOIN HeaderTransaction ht ON ht.CustomerID = c.CustomerID
WHERE DATEPART(WEEKDAY,ht.TransactionDate) IN(6)

--6
SELECT
	c.CardName,
	[Type] = UPPER(ct.CardTypeName),
	c.CardElement,
	[Total Card] = CAST(dt.Quantity AS VARCHAR(50)) + ' Cards',
	[Total Price] = c.CardPrice*dt.Quantity
FROM Cards c
JOIN CardType ct ON ct.CardTypeID = c.CardTypeID
JOIN DetailTransaction dt ON dt.CardsID = c.CardsID,(
		SELECT
			Average = AVG(CardPrice)
		FROM Cards
	) AS A
WHERE CardPrice < A.Average
	AND c.CardElement = 'Dark'
ORDER BY dt.Quantity

--7
GO
CREATE VIEW DragonDeck AS
SELECT
	[Monster Card] = SUBSTRING(c.CardName,1,CHARINDEX(' ',c.CardName)-1),
	ct.CardTypeName,
	c.CardElement,
	c.CardLevel,
	c.CardAttack,
	c.CardDefense
FROM Cards c
JOIN CardType ct ON c.CardTypeID = ct.CardTypeID
WHERE ct.CardTypeName = 'Dragon'
GO
SELECT *
FROM DragonDeck

--8
GO
CREATE VIEW MayTransaction AS
SELECT
	c.CustomerName,
	[CustomerPhone] = REPLACE(c.CustomerPhone,'8','x'),
	s.StaffName,
	s.StaffPhone,
	ht.TransactionDate,
	[Sold Card] = SUM(dt.Quantity)
FROM Customer c
JOIN HeaderTransaction ht ON ht.CustomerID = c.CustomerID
JOIN Staff s ON s.StaffID = ht.StaffID
JOIN DetailTransaction dt ON dt.TransactionID = ht.TransactionID
WHERE MONTH(ht.TransactionDate) = 5
	AND c.CustomerGender = 'Female'
GROUP BY  c.CustomerName, c.CustomerPhone, s.StaffName, s.StaffPhone, ht.TransactionDate
GO
SELECT *
FROM MayTransaction

--9
ALTER TABLE Staff
ADD [StaffSalary] INT
ALTER TABLE Staff
ADD CONSTRAINT SALARY CHECK(StaffSalary > 100000)

SELECT *
FROM Staff

--10
BEGIN TRAN

UPDATE Cards
SET CardPrice = CardPrice + 200000
FROM Cards c
JOIN CardType ct ON ct.CardTypeID = c.CardTypeID
WHERE ct.CardTypeName = 'Divine-Beast'

ROLLBACK

SELECT *
FROM Cards