CREATE PROCEDURE LeaseInsertUpdate
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