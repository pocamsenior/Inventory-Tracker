/* 
===================================================
Check Query - Duplicate Ids in dimBrands
===================================================
# Script Definition
This script finds duplicate auto-generated ids in dimBrands table
===================================================
*/

let
// File Path Definition
    rq_FilePath = #shared[rq_FilePaths],

// External Queries
    slvCleaned_dimBrands = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[slvCleaned_dimBrands])),#shared),
    rqCreate_dimTables = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[rqCreate_dimTables])),#shared),
    rqCreate_dimTableIds = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[rqCreate_dimTableIds])),#shared),

// Variables
    lstDimTableNames = rqCreate_dimTables[lstTableNames],
    posTableName = List.PositionOf(lstDimTableNames,"dim_Brands"),
    idColumnName = rqCreate_dimTables[lstIdColumnNames]{posTableName}{0},
    ColumnName = Text.BeforeDelimiter(idColumnName, " "),

// Query
    Source = slvCleaned_dimBrands,
    #"Remove Columns" = Table.RemoveColumns(Source,{"Model", "Model Number"}),
    #"Check Duplicates" = rqCreate_dimTableIds[chkDuplicates](#"Remove Columns",{ColumnName,idColumnName},posTableName)

in

    #"Check Duplicates"