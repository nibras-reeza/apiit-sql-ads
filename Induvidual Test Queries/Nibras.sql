update inspections set Comments = 'Poor' where InspectionID = 4;

select fname, lname, phonenumber,studentaddress from Student where RoomNo in 
	(select RoomNo from Room where FlatNo in
		(select FlatNo from Inspections where Comments like '%Poor%'));

