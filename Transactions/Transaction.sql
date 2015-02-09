CREATE PROCEDURE AllocateRoom 
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