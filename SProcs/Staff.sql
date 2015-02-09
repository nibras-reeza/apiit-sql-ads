CREATE PROCEDURE StaffInsertUpdate
(
 	@StaffName nvarchar(50),
	@StaffAddress nvarchar(50),
	@StaffEmail nvarchar(50),
	@StaffPhone numeric(18, 0),
	@StatementType Varchar(20),
	@StaffID numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @StaffID = ISNULL(MAX(StaffID), 0) + 1
 FROM Staff

 SELECT @StaffName
 WHERE NOT EXISTS (SELECT StaffID,StaffName FROM Staff 
                 WHERE StaffName=@StaffName)

Insert into Staff (StaffName, StaffAddress, StaffEmail, StaffPhone)
   Values(@StaffName, @StaffAddress,@StaffEmail ,@StaffPhone)

SELECT @StaffID = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from Staff
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE Staff SET
        StaffName = @StaffName, StaffAddress = @StaffAddress, StaffEmail = @StaffEmail , StaffPhone = @StaffPhone
  WHERE StaffID = @StaffID
END

END