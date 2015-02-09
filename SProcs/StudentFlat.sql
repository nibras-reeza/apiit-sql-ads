CREATE PROCEDURE StudentFlatInsertUpdate
(
 	@FlatAdd nvarchar(MAX),
	@NoOfRooms numeric(18, 0),
	@StatementType Varchar(20),
	@FlatNo numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @FlatNo = ISNULL(MAX(FlatNo), 0) + 1
 FROM StudentFlat

 SELECT @FlatAdd
 WHERE NOT EXISTS (SELECT FlatNo,FlatAdd FROM StudentFlat 
                 WHERE FlatAdd=@FlatAdd)

   Insert into StudentFlat (FlatAdd, NoOfRooms)
   Values(@FlatAdd, @NoOfRooms)

SELECT @FlatNo = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from StudentFlat
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE StudentFlat SET
        FlatAdd = @FlatAdd, NoOfRooms = @NoOfRooms 
  WHERE FlatNo = @FlatNo
END

END