SELECT Staff.* FROM Staff, Advisor, Student WHERE Student.Sex='Female' AND Student.AdvisorID=Advisor.AdvisorID AND Advisor.StaffID=Staff.StaffID;