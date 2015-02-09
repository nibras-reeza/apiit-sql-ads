SELECT (Student.FName + ' ' + Student.LName) AS Name, 
		Student.PhoneNumber as Contact

		from Student, Lease, Invoice 
		
		where 
			Lease.StudentID=Student.StudentID AND
			Invoice.StudentID=Student.StudentID AND
			CONVERT(money,Invoice.Penalties)>500 AND
			DATEDIFF(month,GETDATE(),DATEADD(month,CONVERT(int,Lease.RentalPeriod),Lease.StartDate))<=1