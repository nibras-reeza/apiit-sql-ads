set showplan_text on
go

select fname, lname, phonenumber,studentaddress from Student where RoomNo in 
	(select RoomNo from Room where FlatNo in
		(select FlatNo from Inspections where Comments like '%Poor%'));
go

set showplan_text off
go