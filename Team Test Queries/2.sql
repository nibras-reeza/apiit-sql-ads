/* 
	Assuming that semesters start at the 1st day of 1st and 5th and 9th month of the year.

	
	
 */

/*
CREATE FUNCTION GETSTARTMONTH() RETURNS DATE
	AS
		BEGIN
			DECLARE @month INT
			DECLARE @year INT

			SELECT @month=DATEPART(MONTH,GETDATE())
			SELECT @year=DATEPART(YEAR,GETDATE())

			IF(@month BETWEEN 1 AND 4)
				RETURN CONVERT(DATE,'01-05-'+CONVERT(varchar,@year),104);
			ELSE IF(@month BETWEEN 5 AND 8)
				RETURN CONVERT(DATE,'01-09-'+CONVERT(varchar,@year),104);
			
			RETURN CONVERT(DATE,'01-01-'+CONVERT(varchar,@year+1),104);
		END
*/
SELECT Room.RoomNo, Room.RoomType, Room.NoOfBeds AS Beds FROM Room 
	WHERE 
		(Room.RoomNo IN 
			(SELECT Student.RoomNo FROM 
				Lease,Student 
					WHERE 
					DATEADD(month,CONVERT(int,Lease.RentalPeriod),Lease.StartDate)
							<dbo.GETSTARTMONTH() 
						AND 
					Lease.StudentID=Student.StudentID))
		OR
		(Room.RoomNo 
			IN
				(SELECT Room.RoomNo FROM Room 
					EXCEPT SELECT Student.RoomNo FROM Student))