/* 
===================================================
Check Query - Duplicate Ids in dimVariants
===================================================
# Script Definition
This script finds duplicate auto-generated ids in dimVariants table
===================================================
*/

let
// File Path Definition
    rq_FilePath = #shared[rq_FilePaths],

// External Queries
    slvCleaned_dimVariants = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[slvCleaned_dimVariants])),#shared),
    rqCreate_dimTables = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[rqCreate_dimTables])),#shared),
    rqCreate_dimTableIds = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[rqCreate_dimTableIds])),#shared),

// Variables
    lstDimTableNames = rqCreate_dimTables[lstTableNames],
    posTableName = List.PositionOf(lstDimTableNames,"dim_Variants"),
    idColumnName = rqCreate_dimTables[lstIdColumnNames]{posTableName}{0},
    ColumnName = Text.BeforeDelimiter(idColumnName, " "),

// Query
    Source = slvCleaned_dimVariants,
    #"Check Duplicates" = rqCreate_dimTableIds[chkDuplicates](Source,{ColumnName, idColumnName},posTableName)

in

    #"Check Duplicates"