SELECT Staff.StaffID, count(Student.AdvisorID) AS Advisees 
FROM Staff, Student, Advisor 
WHERE Student.AdvisorID=Advisor.AdvisorID 
AND Advisor.StaffID=Staff.StaffID 
GROUP BY Staff.StaffID having count(Student.AdvisorID)>1