USE [master]
GO
/****** Object:  Database [UAO]    Script Date: 9/11/2014 5:40:11 PM ******/
CREATE DATABASE [UAO]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'UAO', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\FinalDB\UAO.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'UAO_log', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\FinalDB\UAO_log.ldf' , SIZE = 3136KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [UAO] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [UAO].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [UAO] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [UAO] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [UAO] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [UAO] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [UAO] SET ARITHABORT OFF 
GO
ALTER DATABASE [UAO] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [UAO] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [UAO] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [UAO] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [UAO] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [UAO] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [UAO] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [UAO] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [UAO] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [UAO] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [UAO] SET  DISABLE_BROKER 
GO
ALTER DATABASE [UAO] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [UAO] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [UAO] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [UAO] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [UAO] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [UAO] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [UAO] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [UAO] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [UAO] SET  MULTI_USER 
GO
ALTER DATABASE [UAO] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [UAO] SET DB_CHAINING OFF 
GO
ALTER DATABASE [UAO] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [UAO] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'UAO', N'ON'
GO
USE [UAO]
GO
/****** Object:  StoredProcedure [dbo].[AllocateRoom]    Script Date: 9/11/2014 5:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AllocateRoom] 
	@studentID numeric(18,0),
	@RentalPeriod nchar(10),
	@MethodOfPayment nvarchar(50)
	,@amount money,
	@RoomNo numeric(18,0) out /*Let's store as sproc*/
AS
	BEGIN TRANSACTION /*Let's begin!*/
		IF NOT EXISTS (SELECT RoomNo FROM  Room EXCEPT SELECT RoomNo from Student) /*Check if rooms are there*/
			BEGIN
				PRINT 'No rooms available!' /*No rooms available. Let's rollback.*/
				ROLLBACK;
			END
		 ELSE
			BEGIN
				DECLARE @RoomsAvailable TABLE(roomno numeric(18,0));
				INSERT INTO @RoomsAvailable(roomno) (SELECT RoomNo FROM  Room EXCEPT SELECT RoomNo from Student) 
				
				SELECT @RoomNo = (SELECT TOP 1 roomno FROM @RoomsAvailable);

				UPDATE Student SET RoomNo=@RoomNo,RoomAllotedDate=CONVERT(nvarchar(50),GETDATE()) WHERE StudentID = @StudentID;

				INSERT INTO Lease(RentalPeriod,StudentID,StartDate) VALUES(@RentalPeriod,@studentID,CONVERT(DATE,GETDATE()));
				INSERT INTO Invoice(StudentID,DatePaid, MethodOfPayment,Amount) VALUES(@studentID,CONVERT(nvarchar(50),GETDATE()), @MethodOfPayment,@amount);

				DECLARE @FName nvarchar(50);
				SELECT @FName=FName FROM Student WHERE StudentID=@studentID
				PRINT 'Room ' + CONVERT(varchar,@RoomNo) +' was alloted to '+ @FName;
			END
	COMMIT TRANSACTION /*Everything went well. Let's commit!*/
GO
/****** Object:  StoredProcedure [dbo].[HallOfResInsertUpdate]    Script Date: 9/11/2014 5:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[HallOfResInsertUpdate]
(
 	@RecidenceName nvarchar(50),
	@RecidenceAdd nvarchar(MAX),
	@RecidenceTel numeric(18, 0),
	@HallManagerID numeric(18, 0),
	@StatementType Varchar(20),
	@RecidenceID numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @RecidenceID = ISNULL(MAX(RecidenceID), 0) + 1
 FROM HallOfRes

 SELECT @RecidenceName
 WHERE NOT EXISTS (SELECT RecidenceID,RecidenceName FROM HallOfRes 
                 WHERE RecidenceName=@RecidenceName)

   Insert into HallOfRes (RecidenceName, RecidenceAdd, RecidenceTel, HallManagerID)
   Values(@RecidenceName, @RecidenceAdd,@RecidenceTel, @HallManagerID)

SELECT @RecidenceID = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from HallOfRes
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE HallOfRes SET
        RecidenceName =  @RecidenceName, RecidenceAdd = @RecidenceAdd, RecidenceTel = @RecidenceTel, HallManagerID = @HallManagerID 
  WHERE RecidenceID = @RecidenceID
END

END
GO
/****** Object:  StoredProcedure [dbo].[InspectionsInsertUpdate]    Script Date: 9/11/2014 5:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InspectionsInsertUpdate]
(
	@StaffID Varchar(200),
	@FlatNo  Varchar(200),
	@Date     Varchar(50),
	@Comments     Varchar(50),
	@StatementType Varchar(20),
	@InspectionID numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @InspectionID = ISNULL(MAX(InspectionID), 0) + 1
 FROM Inspections

 SELECT @StaffID
 WHERE NOT EXISTS (SELECT InspectionID,StaffID FROM Inspections 
                 WHERE StaffID=@StaffID)

Insert into Inspections (StaffID, FlatNo, Date, Comments)
Values(@StaffID, @FlatNo,@Date, @Comments)

SELECT @InspectionID = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from Inspections
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE Inspections SET
        StaffID =  @StaffID, FlatNo = @FlatNo, Date = @Date, Comments = @Comments
  WHERE InspectionID = @InspectionID
END

END
GO
/****** Object:  StoredProcedure [dbo].[InvoiceInsertUpdate]    Script Date: 9/11/2014 5:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InvoiceInsertUpdate]
(
	@StudentID numeric(18, 0),
	@DatePaid  nvarchar(50),
	@MethodOfPayment nvarchar(50),
	@Date1OfRemainder nvarchar(50),
	@Date2OfRemainder nvarchar(50),
	@Penalties nvarchar(50),
	@StatementType Varchar(20),
	@InvoiceNo numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @InvoiceNo = ISNULL(MAX(InvoiceNo), 0) + 1
 FROM Invoice

 SELECT @StudentID
 WHERE NOT EXISTS (SELECT InvoiceNo,StudentID FROM Invoice 
                 WHERE StudentID=@StudentID)

Insert into Invoice (StudentID, DatePaid, MethodOfPayment, Date1OfRemainder, Date2OfRemainder, Penalties)
Values(@StudentID, @DatePaid, @MethodOfPayment, @Date1OfRemainder, @Date2OfRemainder, @Penalties)

SELECT @InvoiceNo = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from Invoice
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE Invoice SET
        StudentID =  @StudentID, DatePaid = @DatePaid, MethodOfPayment = @MethodOfPayment, Date1OfRemainder = @Date1OfRemainder, Date2OfRemainder = @Date2OfRemainder, Penalties = @Penalties
  WHERE InvoiceNo = @InvoiceNo
END

END
GO
/****** Object:  StoredProcedure [dbo].[LeaseInsertUpdate]    Script Date: 9/11/2014 5:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LeaseInsertUpdate]
(
	@RentalPeriod nchar(10),
	@StudentID numeric(18, 0),
	@StatementType Varchar(20),
	@LeaseID numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @LeaseID = ISNULL(MAX(LeaseID), 0) + 1
 FROM Lease

 SELECT @LeaseID
 WHERE NOT EXISTS (SELECT LeaseID,StudentID FROM Lease 
                 WHERE StudentID=@StudentID)

Insert into Lease (RentalPeriod, StudentID)
   Values(@RentalPeriod, @StudentID)

SELECT @LeaseID = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from Lease
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE Lease SET
        RentalPeriod =  @RentalPeriod, StudentID = @StudentID
  WHERE LeaseID = @LeaseID
END

END
GO
/****** Object:  StoredProcedure [dbo].[NextOfKinInsertUpdate]    Script Date: 9/11/2014 5:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NextOfKinInsertUpdate]
(
 	@NOK_Name nvarchar(50),
	@Relationship nvarchar(50),
	@NOK_Address nvarchar(MAX),
	@NOK_Phone nvarchar(MAX),
	@StatementType Varchar(20),
	@NextOfKinID numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @NextOfKinID = ISNULL(MAX(NextOfKinID), 0) + 1
 FROM NextOfKin

 SELECT @NOK_Name
 WHERE NOT EXISTS (SELECT NextOfKinID,NOK_Name FROM NextOfKin 
                 WHERE NOK_Name=@NOK_Name)

	Insert into NextOfKin (NOK_Name, Relationship, NOK_Address, NOK_Phone)
	Values(@NOK_Name, @Relationship,@NOK_Address, @NOK_Phone)

SELECT @NextOfKinID = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from NextOfKin
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE NextOfKin SET
        NOK_Name =  @NOK_Name, Relationship = @Relationship, NOK_Address = @NOK_Address, NOK_Phone = @NOK_Phone 
  WHERE NextOfKinID = @NextOfKinID
END

END
GO
/****** Object:  StoredProcedure [dbo].[RoomInsertUpdate]    Script Date: 9/11/2014 5:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RoomInsertUpdate]
(
 	@PlaceNo nvarchar(MAX),
	@Rent  numeric(18, 0),
	@Availability nvarchar(50),
	@RoomType nvarchar(50),
	@NoOfBeds numeric(18, 0),
	@FlatNo numeric(18, 0),
	@ResidenceID numeric(18, 0),
	@StatementType Varchar(20),
	@RoomNo numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @RoomNo = ISNULL(MAX(RoomNo), 0) + 1
 FROM Room

 SELECT @PlaceNo
 WHERE NOT EXISTS (SELECT RoomNo,PlaceNo FROM Room 
                 WHERE PlaceNo=@PlaceNo)

  Insert into Room (PlaceNo, Rent, Availability, RoomType, NoOfBeds, FlatNo, ResidenceID)
   Values(@PlaceNo, @Rent,@Availability, @RoomType, @NoOfBeds, @FlatNo, @ResidenceID)


SELECT @RoomNo = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from Room
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE Room SET
        PlaceNo = @PlaceNo, Rent = @Rent, Availability = @Availability, RoomType = @RoomType, NoOfBeds = @NoOfBeds, FlatNo = @FlatNo, ResidenceID = @ResidenceID 
  WHERE RoomNo = @RoomNo
END

END
GO
/****** Object:  StoredProcedure [dbo].[StaffInsertUpdate]    Script Date: 9/11/2014 5:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[StaffInsertUpdate]
(
 	@StaffName nvarchar(50),
	@StaffAddress nvarchar(50),
	@StaffEmail nvarchar(50),
	@StaffPhone numeric(18, 0),
	@StatementType Varchar(20),
	@StaffID numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @StaffID = ISNULL(MAX(StaffID), 0) + 1
 FROM Staff

 SELECT @StaffName
 WHERE NOT EXISTS (SELECT StaffID,StaffName FROM Staff 
                 WHERE StaffName=@StaffName)

Insert into Staff (StaffName, StaffAddress, StaffEmail, StaffPhone)
   Values(@StaffName, @StaffAddress,@StaffEmail ,@StaffPhone)

SELECT @StaffID = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from Staff
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE Staff SET
        StaffName = @StaffName, StaffAddress = @StaffAddress, StaffEmail = @StaffEmail , StaffPhone = @StaffPhone
  WHERE StaffID = @StaffID
END

END
GO
/****** Object:  StoredProcedure [dbo].[StudentFlatInsertUpdate]    Script Date: 9/11/2014 5:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[StudentFlatInsertUpdate]
(
 	@FlatAdd nvarchar(MAX),
	@NoOfRooms numeric(18, 0),
	@StatementType Varchar(20),
	@FlatNo numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @FlatNo = ISNULL(MAX(FlatNo), 0) + 1
 FROM StudentFlat

 SELECT @FlatAdd
 WHERE NOT EXISTS (SELECT FlatNo,FlatAdd FROM StudentFlat 
                 WHERE FlatAdd=@FlatAdd)

   Insert into StudentFlat (FlatAdd, NoOfRooms)
   Values(@FlatAdd, @NoOfRooms)

SELECT @FlatNo = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from StudentFlat
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE StudentFlat SET
        FlatAdd = @FlatAdd, NoOfRooms = @NoOfRooms 
  WHERE FlatNo = @FlatNo
END

END
GO
/****** Object:  StoredProcedure [dbo].[StudentInsertUpdate]    Script Date: 9/11/2014 5:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[StudentInsertUpdate]
(
 	@FName nvarchar(50),
	@LName  nvarchar(50),
	@Sex nchar(10),
	@StudentAddress nvarchar(MAX),
	@Rentinfo nchar(10),
	@AdvisorID numeric(18, 0),
	@NextOfKinID numeric(18, 0),
	@RoomNo numeric(18, 0),
	@RoomAllotedDate nvarchar(MAX),
	@PhoneNumber numeric(18, 0),
	@StatementType Varchar(20),
	@StudentID numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @StudentID = ISNULL(MAX(StudentID), 0) + 1
 FROM Student

 SELECT @FName
 WHERE NOT EXISTS (SELECT StudentID,FName FROM Student 
                 WHERE FName=@FName)

  Insert into Student (FName, LName, Sex, StudentAddress, Rentinfo, AdvisorID, NextOfKinID, RoomNo, RoomAllotedDate, PhoneNumber)
   Values(@FName, @LName,@Sex ,@StudentAddress, @Rentinfo, @AdvisorID, @NextOfKinID, @RoomNo, @RoomAllotedDate, @PhoneNumber)

SELECT @StudentID = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from Student
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE Student SET
        FName = @FName, LName = @LName, Sex = @Sex , StudentAddress = @StudentAddress, Rentinfo = @Rentinfo, AdvisorID = @AdvisorID, NextOfKinID = @NextOfKinID, RoomNo = @RoomNo, RoomAllotedDate = @RoomAllotedDate, PhoneNumber = @PhoneNumber 
  WHERE StudentID = @StudentID
END

END
GO
/****** Object:  Table [dbo].[Advisor]    Script Date: 9/11/2014 5:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Advisor](
	[AdvisorID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[Department] [nchar](10) NULL,
	[OfficeLocation] [nchar](10) NULL,
	[StaffID] [numeric](18, 0) NULL,
 CONSTRAINT [PK_Advisor] PRIMARY KEY CLUSTERED 
(
	[AdvisorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Alumni]    Script Date: 9/11/2014 5:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Alumni](
	[StudentID] [numeric](18, 0) NOT NULL,
	[FName] [nvarchar](50) NULL,
	[LName] [nvarchar](50) NULL,
	[Sex] [nchar](10) NULL,
	[StudentAddress] [nvarchar](max) NULL,
	[Rentinfo] [nchar](10) NULL,
	[AdvisorID] [numeric](18, 0) NULL,
	[NextOfKinID] [numeric](18, 0) NULL,
	[RoomNo] [numeric](18, 0) NULL,
	[RoomAllotedDate] [nvarchar](max) NULL,
	[PhoneNumber] [numeric](18, 0) NULL,
 CONSTRAINT [PK_Alumni] PRIMARY KEY CLUSTERED 
(
	[StudentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HallOfRes]    Script Date: 9/11/2014 5:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HallOfRes](
	[RecidenceID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[RecidenceName] [nvarchar](50) NULL,
	[RecidenceAdd] [nvarchar](max) NULL,
	[RecidenceTel] [numeric](18, 0) NULL,
	[HallManagerID] [numeric](18, 0) NULL,
 CONSTRAINT [PK_HallOfRec] PRIMARY KEY CLUSTERED 
(
	[RecidenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Inspections]    Script Date: 9/11/2014 5:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Inspections](
	[InspectionID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[Date] [nvarchar](50) NULL,
	[Comments] [nchar](10) NULL,
	[staffID] [numeric](18, 0) NULL,
	[FlatNo] [numeric](18, 0) NULL,
 CONSTRAINT [PK_Inspections] PRIMARY KEY CLUSTERED 
(
	[InspectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Invoice]    Script Date: 9/11/2014 5:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Invoice](
	[InvoiceNo] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[StudentID] [numeric](18, 0) NULL,
	[DatePaid] [nvarchar](50) NULL,
	[MethodOfPayment] [nvarchar](50) NULL,
	[Date1OfRemainder] [nvarchar](50) NULL,
	[Date2OfRemainder] [nvarchar](50) NULL,
	[Penalties] [nvarchar](50) NULL,
	[Amount] [money] NULL,
 CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED 
(
	[InvoiceNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lease]    Script Date: 9/11/2014 5:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lease](
	[LeaseID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[RentalPeriod] [nchar](10) NULL,
	[StudentID] [numeric](18, 0) NULL,
	[StartDate] [date] NULL,
 CONSTRAINT [PK_Lease] PRIMARY KEY CLUSTERED 
(
	[LeaseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NextOfKin]    Script Date: 9/11/2014 5:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NextOfKin](
	[NextOfKinID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[NOK_Name] [nvarchar](50) NULL,
	[Relationship] [nvarchar](50) NULL,
	[NOK_Address] [nvarchar](max) NULL,
	[NOK_Phone] [nvarchar](max) NULL,
 CONSTRAINT [PK_NextOfKin] PRIMARY KEY CLUSTERED 
(
	[NextOfKinID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Room]    Script Date: 9/11/2014 5:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Room](
	[RoomNo] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[PlaceNo] [nvarchar](max) NULL,
	[Rent] [numeric](18, 0) NULL,
	[Availability] [nvarchar](50) NULL,
	[RoomType] [nvarchar](50) NULL,
	[NoOfBeds] [numeric](18, 0) NULL,
	[FlatNo] [numeric](18, 0) NULL,
	[ResidenceID] [numeric](18, 0) NULL,
 CONSTRAINT [PK_Room] PRIMARY KEY CLUSTERED 
(
	[RoomNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RoomHistory]    Script Date: 9/11/2014 5:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RoomHistory](
	[RoomNo] [numeric](18, 0) NULL,
	[StudentID] [numeric](18, 0) NULL,
	[Change] [date] NULL,
	[TypeOfChange] [varchar](20) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Staff]    Script Date: 9/11/2014 5:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staff](
	[StaffID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[StaffName] [nvarchar](50) NULL,
	[StaffAddress] [nvarchar](50) NULL,
	[StaffEmail] [nvarchar](50) NULL,
	[StaffPhone] [numeric](18, 0) NULL,
 CONSTRAINT [PK_Staff] PRIMARY KEY CLUSTERED 
(
	[StaffID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Student]    Script Date: 9/11/2014 5:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Student](
	[StudentID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[FName] [nvarchar](50) NULL,
	[LName] [nvarchar](50) NULL,
	[Sex] [nchar](10) NULL,
	[StudentAddress] [nvarchar](max) NULL,
	[Rentinfo] [nchar](10) NULL,
	[AdvisorID] [numeric](18, 0) NULL,
	[NextOfKinID] [numeric](18, 0) NULL,
	[RoomNo] [numeric](18, 0) NULL,
	[RoomAllotedDate] [nvarchar](max) NULL,
	[PhoneNumber] [numeric](18, 0) NULL,
 CONSTRAINT [PK_Student] PRIMARY KEY CLUSTERED 
(
	[StudentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[StudentFlat]    Script Date: 9/11/2014 5:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudentFlat](
	[FlatNo] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[FlatAdd] [nvarchar](max) NULL,
	[NoOfRooms] [numeric](18, 0) NULL,
 CONSTRAINT [PK_StudentFlat] PRIMARY KEY CLUSTERED 
(
	[FlatNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [flat_condition]    Script Date: 9/11/2014 5:40:12 PM ******/
CREATE NONCLUSTERED INDEX [flat_condition] ON [dbo].[Inspections]
(
	[Comments] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [start_date_lease]    Script Date: 9/11/2014 5:40:12 PM ******/
CREATE NONCLUSTERED INDEX [start_date_lease] ON [dbo].[Lease]
(
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [staff_name]    Script Date: 9/11/2014 5:40:12 PM ******/
CREATE NONCLUSTERED INDEX [staff_name] ON [dbo].[Staff]
(
	[StaffName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [student_name]    Script Date: 9/11/2014 5:40:12 PM ******/
CREATE NONCLUSTERED INDEX [student_name] ON [dbo].[Student]
(
	[FName] ASC,
	[LName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Advisor]  WITH CHECK ADD  CONSTRAINT [ADV_STF_FK] FOREIGN KEY([StaffID])
REFERENCES [dbo].[Staff] ([StaffID])
GO
ALTER TABLE [dbo].[Advisor] CHECK CONSTRAINT [ADV_STF_FK]
GO
ALTER TABLE [dbo].[Alumni]  WITH CHECK ADD  CONSTRAINT [ALU_ADV_FK] FOREIGN KEY([AdvisorID])
REFERENCES [dbo].[Advisor] ([AdvisorID])
GO
ALTER TABLE [dbo].[Alumni] CHECK CONSTRAINT [ALU_ADV_FK]
GO
ALTER TABLE [dbo].[Alumni]  WITH CHECK ADD  CONSTRAINT [ALU_NK_FK] FOREIGN KEY([NextOfKinID])
REFERENCES [dbo].[NextOfKin] ([NextOfKinID])
GO
ALTER TABLE [dbo].[Alumni] CHECK CONSTRAINT [ALU_NK_FK]
GO
ALTER TABLE [dbo].[Alumni]  WITH CHECK ADD  CONSTRAINT [ALU_RM_FK] FOREIGN KEY([RoomNo])
REFERENCES [dbo].[Room] ([RoomNo])
GO
ALTER TABLE [dbo].[Alumni] CHECK CONSTRAINT [ALU_RM_FK]
GO
ALTER TABLE [dbo].[Inspections]  WITH CHECK ADD  CONSTRAINT [INS_FNO_FK] FOREIGN KEY([FlatNo])
REFERENCES [dbo].[StudentFlat] ([FlatNo])
GO
ALTER TABLE [dbo].[Inspections] CHECK CONSTRAINT [INS_FNO_FK]
GO
ALTER TABLE [dbo].[Inspections]  WITH CHECK ADD  CONSTRAINT [INS_STF_FK] FOREIGN KEY([staffID])
REFERENCES [dbo].[Staff] ([StaffID])
GO
ALTER TABLE [dbo].[Inspections] CHECK CONSTRAINT [INS_STF_FK]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [INV_STU_FK] FOREIGN KEY([StudentID])
REFERENCES [dbo].[Student] ([StudentID])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [INV_STU_FK]
GO
ALTER TABLE [dbo].[Room]  WITH CHECK ADD  CONSTRAINT [RM_FLT_FK] FOREIGN KEY([FlatNo])
REFERENCES [dbo].[StudentFlat] ([FlatNo])
GO
ALTER TABLE [dbo].[Room] CHECK CONSTRAINT [RM_FLT_FK]
GO
ALTER TABLE [dbo].[Room]  WITH CHECK ADD  CONSTRAINT [RM_RES_FK] FOREIGN KEY([ResidenceID])
REFERENCES [dbo].[HallOfRes] ([RecidenceID])
GO
ALTER TABLE [dbo].[Room] CHECK CONSTRAINT [RM_RES_FK]
GO
ALTER TABLE [dbo].[RoomHistory]  WITH CHECK ADD FOREIGN KEY([RoomNo])
REFERENCES [dbo].[Room] ([RoomNo])
GO
ALTER TABLE [dbo].[RoomHistory]  WITH CHECK ADD FOREIGN KEY([StudentID])
REFERENCES [dbo].[Student] ([StudentID])
GO
ALTER TABLE [dbo].[Student]  WITH CHECK ADD  CONSTRAINT [STU_ADV_FK] FOREIGN KEY([AdvisorID])
REFERENCES [dbo].[Advisor] ([AdvisorID])
GO
ALTER TABLE [dbo].[Student] CHECK CONSTRAINT [STU_ADV_FK]
GO
ALTER TABLE [dbo].[Student]  WITH CHECK ADD  CONSTRAINT [STU_NK_FK] FOREIGN KEY([NextOfKinID])
REFERENCES [dbo].[NextOfKin] ([NextOfKinID])
GO
ALTER TABLE [dbo].[Student] CHECK CONSTRAINT [STU_NK_FK]
GO
ALTER TABLE [dbo].[Student]  WITH CHECK ADD  CONSTRAINT [STU_RM_FK] FOREIGN KEY([RoomNo])
REFERENCES [dbo].[Room] ([RoomNo])
GO
ALTER TABLE [dbo].[Student] CHECK CONSTRAINT [STU_RM_FK]
GO
ALTER TABLE [dbo].[Student]  WITH CHECK ADD  CONSTRAINT [StuGender] CHECK  (([Sex]='Female' OR [Sex]='Male'))
GO
ALTER TABLE [dbo].[Student] CHECK CONSTRAINT [StuGender]
GO
USE [master]
GO
ALTER DATABASE [UAO] SET  READ_WRITE 
GO
