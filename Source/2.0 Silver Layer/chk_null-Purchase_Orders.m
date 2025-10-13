let
// file path definition
    rqFilePath = "\\Mac\iCloud\Data Analysis\Projects\Inventory-Tracker\Source\0.0 File Paths\rq-FilePaths.m",
    FilePaths = Expression.Evaluate(Text.FromBinary(File.Contents(rqFilePath)),#shared),
    Source = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[slv_CleanTable])),#shared),
    rqClean = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[rq_SilverClean])),#shared),

// variable
fxNullCheck = rqClean[fxNullCheck],

// query
    #"Null Check" = Table.SelectRows(Source, fxNullCheck)

in

    Source