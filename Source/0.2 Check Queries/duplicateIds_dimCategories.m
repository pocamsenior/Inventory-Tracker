/* 
===================================================
Check Query - Duplicate Ids in dimCategories
===================================================
# Script Definition
This script finds duplicate auto-generated ids in dimCategories table
===================================================
*/

let
// File Path Definition
    rq_FilePath = #shared[rq_FilePaths],

// External Queries
    slvCleaned_dimCategories = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[slvCleaned_dimCategories])),#shared),
    rqCreate_dimTables = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[rqCreate_dimTables])),#shared),
    rqCreate_dimTableIds = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[rqCreate_dimTableIds])),#shared),

// Variables
    lstDimTableNames = rqCreate_dimTables[lstTableNames],
    posTableName = List.PositionOf(lstDimTableNames,"dim_Categories"),
    idColumnName = rqCreate_dimTables[lstIdColumnNames]{posTableName}{0},
    ColumnName = Text.BeforeDelimiter(idColumnName, " "),

   
// Query
    Source = slvCleaned_dimCategories,
    #"Check Duplicates" = rqCreate_dimTableIds[chkDuplicates](Source, {ColumnName, idColumnName}, posTableName)

in

    #"Check Duplicates"