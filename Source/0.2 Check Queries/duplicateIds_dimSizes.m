/* 
===================================================
Check Query - Duplicate Ids in dimSizes
===================================================
# Script Definition
This script finds duplicate auto-generated ids in dimSizes table
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Queries
    slvCleaned_dimSizes = rq_Objects[slvCleaned_dimSizes],
    rqCreate_dimTables = rq_Objects[rqCreate_dimTables],
    rqCreate_dimTableIds = rq_Objects[rqCreate_dimTableIds],

// Variables
    lstDimTableNames = rqCreate_dimTables[lstTableNames],
    posTableName = List.PositionOf(lstDimTableNames,"dimSizes"),
    idColumnName = rqCreate_dimTables[lstIdColumnNames]{posTableName}{0},
    ColumnName = Text.BeforeDelimiter(idColumnName, " "),

// Query
    Source = slvCleaned_dimSizes,
    #"Check Duplicates" = rqCreate_dimTableIds[chkDuplicates](Source,{ColumnName, idColumnName},posTableName)

in

    #"Check Duplicates"