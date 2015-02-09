SELECT StudentFlat.*,Inspections.*
FROM StudentFlat,Inspections
WHERE StudentFlat.FlatNo = Inspections.FlatNo AND Inspections.Comments = 'Poor' AND (SELECT DATEPART(month,GETDATE()))- (SELECT DATEPART(month,Inspections.Date)) > '4'