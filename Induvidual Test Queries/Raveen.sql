SELECT NextOfKin.NOK_Name AS Name, 
		NextOfKin.NOK_Phone as Contact

		from Student, Invoice, NextOfKin
		
		where 
			NextOfKin.NextOfKinID=Student.NextOfKinID AND
			Invoice.StudentID=Student.StudentID AND
			CONVERT(money,Invoice.Penalties)>500 AND
			CONVERT(DATE, Invoice.Date2OfRemainder,105)<GETDATE()
			