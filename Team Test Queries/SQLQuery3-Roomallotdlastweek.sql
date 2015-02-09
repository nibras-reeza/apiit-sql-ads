SELECT StudentID,FName,LName,RoomNo,PhoneNumber
FROM Student
WHERE RoomAllotedDate >= DATEADD(day,-7, GETDATE())