CREATE PROCEDURE InvoiceInsertUpdate
(
	@StudentID numeric(18, 0),
	@DatePaid  nvarchar(50),
	@MethodOfPayment nvarchar(50),
	@Date1OfRemainder nvarchar(50),
	@Date2OfRemainder nvarchar(50),
	@Penalties nvarchar(50),
	@StatementType Varchar(20),
	@InvoiceNo numeric(18, 0)OUTPUT
)

 AS
 BEGIN



 IF @StatementType = 'Insert'
 BEGIN

 SELECT @InvoiceNo = ISNULL(MAX(InvoiceNo), 0) + 1
 FROM Invoice

 SELECT @StudentID
 WHERE NOT EXISTS (SELECT InvoiceNo,StudentID FROM Invoice 
                 WHERE StudentID=@StudentID)

Insert into Invoice (StudentID, DatePaid, MethodOfPayment, Date1OfRemainder, Date2OfRemainder, Penalties)
Values(@StudentID, @DatePaid, @MethodOfPayment, @Date1OfRemainder, @Date2OfRemainder, @Penalties)

SELECT @InvoiceNo = SCOPE_IDENTITY()    

End

ELSE IF @StatementType = 'Select'
Begin
select * from Invoice
END 

ELSE IF @StatementType = 'Update'
BEGIN
UPDATE Invoice SET
        StudentID =  @StudentID, DatePaid = @DatePaid, MethodOfPayment = @MethodOfPayment, Date1OfRemainder = @Date1OfRemainder, Date2OfRemainder = @Date2OfRemainder, Penalties = @Penalties
  WHERE InvoiceNo = @InvoiceNo
END

END