SELECT Student.*,Invoice.*
FROM Student,Invoice
WHERE Student.StudentID=Invoice.StudentID AND Invoice.MethodOfPayment = 'Not Paid'
ORDER BY Invoice.Penalties DESC;