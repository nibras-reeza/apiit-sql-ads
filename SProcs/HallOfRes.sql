CREATE PROCEDURE HallOfResInsertUpdate
(
 	@RecidenceName nvarchar(50),
	@RecidenceAdd nvarchar(MAX),
	@RecidenceTel numeric(18, 0),
	@HallManagerID numeric(18, 0),
	@StatementType Varchar(20),
	@RecidenceID numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @RecidenceID = ISNULL(MAX(RecidenceID), 0) + 1
 FROM HallOfRes

 SELECT @RecidenceName
 WHERE NOT EXISTS (SELECT RecidenceID,RecidenceName FROM HallOfRes 
                 WHERE RecidenceName=@RecidenceName)

   Insert into HallOfRes (RecidenceName, RecidenceAdd, RecidenceTel, HallManagerID)
   Values(@RecidenceName, @RecidenceAdd,@RecidenceTel, @HallManagerID)

SELECT @RecidenceID = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from HallOfRes
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE HallOfRes SET
        RecidenceName =  @RecidenceName, RecidenceAdd = @RecidenceAdd, RecidenceTel = @RecidenceTel, HallManagerID = @HallManagerID 
  WHERE RecidenceID = @RecidenceID
END

END