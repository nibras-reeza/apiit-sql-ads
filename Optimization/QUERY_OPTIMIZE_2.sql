set showplan_text on
go

select student.fname, student.lname, student.phonenumber,student.studentaddress 
	from Student, Room, Inspections 
		where 
		Student.RoomNo=Room.RoomNo AND
		Room.FlatNo = Inspections.FlatNo AND 
		Inspections.Comments like '%Poor%';
go

set showplan_text off
go