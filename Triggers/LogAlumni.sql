CREATE TRIGGER LogAlumni ON Student INSTEAD OF DELETE
	AS
		BEGIN
			INSERT INTO ALUMNI 
				(d.StudentID,d.FName,d.LName,d.Sex,d.StudentAddress,d.Rentinfo,d.AdvisorID,d.NextOfKinID,d.RoomNo,d.RoomAllotedDate,d.PhoneNumber) 
				SELECT * FROM deleted d;

			DELETE FROM Student WHERE StudentID=(SELECT StudentID FROM deleted);
		END
