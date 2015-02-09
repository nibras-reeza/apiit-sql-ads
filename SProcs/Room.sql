CREATE PROCEDURE RoomInsertUpdate
(
 	@PlaceNo nvarchar(MAX),
	@Rent  numeric(18, 0),
	@Availability nvarchar(50),
	@RoomType nvarchar(50),
	@NoOfBeds numeric(18, 0),
	@FlatNo numeric(18, 0),
	@ResidenceID numeric(18, 0),
	@StatementType Varchar(20),
	@RoomNo numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @RoomNo = ISNULL(MAX(RoomNo), 0) + 1
 FROM Room

 SELECT @PlaceNo
 WHERE NOT EXISTS (SELECT RoomNo,PlaceNo FROM Room 
                 WHERE PlaceNo=@PlaceNo)

  Insert into Room (PlaceNo, Rent, Availability, RoomType, NoOfBeds, FlatNo, ResidenceID)
   Values(@PlaceNo, @Rent,@Availability, @RoomType, @NoOfBeds, @FlatNo, @ResidenceID)


SELECT @RoomNo = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from Room
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE Room SET
        PlaceNo = @PlaceNo, Rent = @Rent, Availability = @Availability, RoomType = @RoomType, NoOfBeds = @NoOfBeds, FlatNo = @FlatNo, ResidenceID = @ResidenceID 
  WHERE RoomNo = @RoomNo
END

END