--Creating tables
Create table Drivers
(
	Number int PRIMARY KEY, 
	Name varchar(30) NOT NULL,
	DOB datetime NOT NULL,
)
GO

Create table TradePoints
(
	Id int Primary key Identity(1,1),
	Name varchar(30) NOT NULL,
	Adress varchar(30) NOT NULL
)
GO

Create table RouteReports
(
	Id int Primary key Identity(1,1),
	DepartureDate datetime NOT NULL,
	ReturnDate datetime NOT NULL,
	DriverNumber int NOT NULL, 
	TradePointId int NOT NULL,
	Constraint fk_RR_DR Foreign key (DriverNumber) References Drivers(Number),
	Constraint fk_RR_TP Foreign key (TradePointId) References TradePoints(Id),
	)
GO
-- Making sure that no indentical reports will be stored
	Alter table RouteReports
	Add Constraint UQ_DD_RD_DN_TP Unique(DepartureDate, ReturnDate, DriverNumber, TradePointID)

--Inserting values

--Insertig drivers' rows

Insert into Drivers
Values (1598, 'Victor', '12.12.1974')

Insert into Drivers
Values (2355, 'Thiago', '12.11.1985')

Insert into Drivers
Values (1288, 'Mario', '04.02.1991')

Insert into Drivers
Values (9946, 'Anton', '06.20.1988')

Insert into Drivers
Values (1424, 'Stepan', '07.14.1980')

Insert into Drivers
Values (1591, 'Sergey', '10.12.1978')

Insert into Drivers
Values (7211, 'Marina', '07.10.1995')

Insert into Drivers
Values (1123, 'Maria', '07.10.1988')

Insert into Drivers
Values (1316, 'Ekaterina', '02.04.1986')

Insert into Drivers
Values (7773, 'Ludmila', '12.08.1994')

Insert into Drivers
Values (5123, 'Zina', '12.09.1966')

--Inserting Trade points' rows
Insert into TradePoints
Values ('Intel','Good st. 5')

Insert into TradePoints
Values ('AMD','Nice st. 123')

Insert into TradePoints
Values ('McDonalds','Johnes st. 44')

Insert into TradePoints
Values ('Burger King','Ivan st. 5')

Insert into TradePoints
Values ('Turkish Airlines','Straight st. 66')

Insert into TradePoints
Values ('Flying Emirates','Narrow st. 213')

Insert into TradePoints
Values ('Nokia','Great st. 50')

Insert into TradePoints
Values ('Samsung','East st. 42')

Insert into TradePoints
Values ('Alcatel','Southside st. 10')

--Inserting RouteReports' rows
Insert into RouteReports
Values ('07.15.2015', '07.17.2015', 5123, 1)

Insert into RouteReports
Values ('08.11.2015', '08.12.2015', 1288, 4)

Insert into RouteReports
Values ('04.15.2015', '10.15.2015', 1591, 3)

Insert into RouteReports
Values ('04.15.2015', '10.15.2015', 1598, 5)

Insert into RouteReports
Values ('04.15.2015', '10.15.2015', 7773, 2)

Insert into RouteReports
Values ('06.28.2015', '07.14.2015', 9946, 1)

Insert into RouteReports
Values ('05.06.2015', '05.15.2015', 7211, 9)

Insert into RouteReports
Values ('04.15.2015', '05.25.2015', 1123, 1)

Insert into RouteReports
Values ('04.10.2015', '05.10.2015', 1123, 7)

Insert into RouteReports
Values ('04.17.2015', '05.15.2015', 1123, 3)

Insert into RouteReports
Values ('07.05.2015', '07.25.2015', 9946, 6)

Insert into RouteReports
Values ('07.20.2015', '07.25.2015', 9946, 8)

Insert into RouteReports
Values ('07.20.2010', '07.25.2011', 9946, 8)

Select * from RouteReports

-- Deleting rows from Route reports that have intersecting dates
Delete from RouteReports from RouteReports join 
(
	Select *
	From RouteReports 
	join (Select RouteReports.Id as Id2, RouteReports.DepartureDate as DD2, RouteReports.ReturnDate as RD2, RouteReports.DriverNumber as DN2, RouteReports.TradePointID as TP2
	From RouteReports) as RR2
	on DriverNumber = RR2.DN2
	Where (DD2>DepartureDate and DD2<ReturnDate and TP2=TradePointId) or (DD2>=DepartureDate and DD2<ReturnDate and TP2!=TradePointId) 
) as RR on RouteReports.Id = RR.Id2


-- Making a trigger to not let insert/update intersecting route report dates
Create trigger Trigger_Instead_Insert_Intersecting
On RouteReports
After Insert, Update
As
	If Exists(
				Select 1
				From RouteReports 
				join (Select inserted.Id as Id2, inserted.DepartureDate as DD2, inserted.ReturnDate as RD2, inserted.DriverNumber as DN2, inserted.TradePointID as TP2
				From inserted) as RR2
				on RouteReports.DriverNumber = RR2.DN2
				Where (DD2>DepartureDate and DD2<ReturnDate and TP2=TradePointId) or (DD2>=DepartureDate and DD2<ReturnDate and TP2!=TradePointId)
				)
		Begin
			Raiserror('Attempt to add a route report with intersecting dates!', 10, 1)
			Rollback transaction
		End