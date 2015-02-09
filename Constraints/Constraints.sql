ALTER TABLE Advisor ADD CONSTRAINT ADV_STF_FK FOREIGN KEY(StaffID) references Staff(StaffID);

ALTER TABLE Student ADD CONSTRAINT STU_ADV_FK FOREIGN KEY(AdvisorID) references Advisor(AdvisorID);
ALTER TABLE Student ADD CONSTRAINT STU_RM_FK FOREIGN KEY(RoomNo) references Room(RoomNo);
ALTER TABLE Student ADD CONSTRAINT STU_NK_FK FOREIGN KEY(NextOfKinId) references NextOfKin(NextOfKinId);

ALTER TABLE Alumni ADD CONSTRAINT ALU_ADV_FK FOREIGN KEY(AdvisorID) references Advisor(AdvisorID);
ALTER TABLE Alumni ADD CONSTRAINT ALU_RM_FK FOREIGN KEY(RoomNo) references Room(RoomNo);
ALTER TABLE Alumni ADD CONSTRAINT ALU_NK_FK FOREIGN KEY(NextOfKinId) references NextOfKin(NextOfKinId);


ALTER TABLE Inspections ADD CONSTRAINT INS_STF_FK FOREIGN KEY(StaffID) references Staff(StaffID);
ALTER TABLE Inspections ADD CONSTRAINT INS_FNO_FK FOREIGN KEY(FlatNo) references StudentFlat(FlatNo);

ALTER TABLE Invoice ADD CONSTRAINT INV_STU_FK FOREIGN KEY(StudentID) references Student(StudentID);

ALTER TABLE Room ADD CONSTRAINT RM_FLT_FK FOREIGN KEY(FlatNo) references StudentFlat(FlatNo);
ALTER TABLE Room ADD CONSTRAINT RM_RES_FK FOREIGN KEY(ResidenceID) references HallOfRes(RecidenceID);

/*
Reference for following statement: (Dave, 2007)
*/
SELECT OBJECT_NAME(OBJECT_ID) AS NameofConstraint,
OBJECT_NAME(parent_object_id) AS TableName
FROM sys.objects
WHERE type_desc LIKE 'FOREIGN_KEY_CONSTRAINT'