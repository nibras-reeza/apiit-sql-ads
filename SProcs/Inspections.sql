CREATE PROCEDURE InspectionsInsertUpdate
(
	@StaffID Varchar(200),
	@FlatNo  Varchar(200),
	@Date     Varchar(50),
	@Comments     Varchar(50),
	@StatementType Varchar(20),
	@InspectionID numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @InspectionID = ISNULL(MAX(InspectionID), 0) + 1
 FROM Inspections

 SELECT @StaffID
 WHERE NOT EXISTS (SELECT InspectionID,StaffID FROM Inspections 
                 WHERE StaffID=@StaffID)

Insert into Inspections (StaffID, FlatNo, Date, Comments)
Values(@StaffID, @FlatNo,@Date, @Comments)

SELECT @InspectionID = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from Inspections
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE Inspections SET
        StaffID =  @StaffID, FlatNo = @FlatNo, Date = @Date, Comments = @Comments
  WHERE InspectionID = @InspectionID
END

END