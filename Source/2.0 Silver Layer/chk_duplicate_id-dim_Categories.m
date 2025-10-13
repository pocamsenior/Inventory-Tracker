let
// file path definition

    rqFilePath = "\\Mac\iCloud\Data Analysis\Projects\Inventory-Tracker\Source\0.0 File Paths\rq-FilePaths.m",
    FilePaths = Expression.Evaluate(Text.FromBinary(File.Contents(rqFilePath)),#shared),
    Source = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[slv_DimCategoriesTable])),#shared),
    rqCreateDimTableIds = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[rq_SilverCreateDimTableIds])),#shared),
   
// query
    #"Check Duplicates" = rqCreateDimTableIds[fxCheckDuplicates](Source)

in

    #"Check Duplicates"