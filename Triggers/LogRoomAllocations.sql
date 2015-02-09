CREATE TRIGGER LogRoomAllocations ON Student AFTER UPDATE
	AS
		BEGIN
			DECLARE @newRoom numeric(18,0)
			DECLARE @oldRoom numeric(18,0)
			DECLARE @studentID numeric(18,0)

			SELECT @newRoom=RoomNo from inserted;
			SELECT @oldRoom=RoomNo,@studentID=StudentID from deleted;

			IF(@oldRoom IS NOT NULL)
				INSERT INTO RoomHistory values(@oldRoom,@studentID,CONVERT(DATE,GETDATE()),'VACATE')

			IF(@newRoom IS NOT NULL)
				INSERT INTO RoomHistory values(@newRoom,@studentID,CONVERT(DATE,GETDATE()),'ALLOT')

		END