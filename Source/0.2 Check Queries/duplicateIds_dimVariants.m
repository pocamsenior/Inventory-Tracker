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
    rq_Objects = #shared[rq_Objects],

// External Queries
    slvCleaned_dimVariants = rq_Objects[slvCleaned_dimVariants],
    rqCreate_dimTables = rq_Objects[rqCreate_dimTables],
    rqCreate_dimTableIds = rq_Objects[rqCreate_dimTableIds],

// Variables
    lstDimTableNames = rqCreate_dimTables[lstTableNames],
    posTableName = List.PositionOf(lstDimTableNames,"dimVariants"),
    idColumnName = rqCreate_dimTables[lstIdColumnNames]{posTableName}{0},
    ColumnName = Text.BeforeDelimiter(idColumnName, " "),

// Query
    Source = slvCleaned_dimVariants,
    #"Check Duplicates" = rqCreate_dimTableIds[chkDuplicates](Source,{ColumnName, idColumnName},posTableName)

in

    #"Check Duplicates"