CREATE PROCEDURE StudentInsertUpdate
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