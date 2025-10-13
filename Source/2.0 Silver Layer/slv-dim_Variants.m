let
// file path definition

    rqFilePath = "\\Mac\iCloud\Data Analysis\Projects\Inventory-Tracker\Source\0.0 File Paths\rq-FilePaths.m",
    FilePaths = Expression.Evaluate(Text.FromBinary(File.Contents(rqFilePath)),#shared),
    Source = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[slv_CleanTable])),#shared),
    rqCreateDimTables = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[rq_SilverCreateDimTables])),#shared),
    rqCreateDimTableIds = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[rq_SilverCreateDimTableIds])),#shared),

// variables
    Position = List.PositionOf(rqCreateDimTables[lstDimTableNames],"dim_Variants"),
    ColumnNames = rqCreateDimTables[nlstContents]{Position}{1},
    RenameColumns = rqCreateDimTables[nlstContents]{Position}{2},
    IdPatterns = rqCreateDimTableIds[nlstContents]{Position}{1},

// query
    
    #"Select Columns" = Table.SelectColumns(Source, ColumnNames),
    #"Unique Rows" = Table.Distinct(#"Select Columns"),
    #"Rename Column" = Table.RenameColumns(#"Unique Rows", RenameColumns),
    #"Add Id Column" = Table.AddColumn(#"Rename Column","Variant Id", each _[Variant]),
    #"First Letter Capitalized" = Table.TransformColumns(#"Add Id Column",{"Variant Id", IdPatterns{1}}),
    #"One Word Id" = Table.TransformColumns(#"Add Id Column",{"Variant Id", IdPatterns{2}}),
    #"Two Word Id" = Table.TransformColumns(#"One Word Id",{"Variant Id", IdPatterns{3}}),
    #"Three Word Id" = Table.TransformColumns(#"Two Word Id",{"Variant Id", IdPatterns{4}})
in
    #"Two Word Id"