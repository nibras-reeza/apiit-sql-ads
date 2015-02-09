CREATE PROCEDURE NextOfKinInsertUpdate
(
 	@NOK_Name nvarchar(50),
	@Relationship nvarchar(50),
	@NOK_Address nvarchar(MAX),
	@NOK_Phone nvarchar(MAX),
	@StatementType Varchar(20),
	@NextOfKinID numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @NextOfKinID = ISNULL(MAX(NextOfKinID), 0) + 1
 FROM NextOfKin

 SELECT @NOK_Name
 WHERE NOT EXISTS (SELECT NextOfKinID,NOK_Name FROM NextOfKin 
                 WHERE NOK_Name=@NOK_Name)

	Insert into NextOfKin (NOK_Name, Relationship, NOK_Address, NOK_Phone)
	Values(@NOK_Name, @Relationship,@NOK_Address, @NOK_Phone)

SELECT @NextOfKinID = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from NextOfKin
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE NextOfKin SET
        NOK_Name =  @NOK_Name, Relationship = @Relationship, NOK_Address = @NOK_Address, NOK_Phone = @NOK_Phone 
  WHERE NextOfKinID = @NextOfKinID
END

END