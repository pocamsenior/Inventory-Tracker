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
    rq_Objects = #shared[rq_Objects],

// External Queries
    slvCleaned_dimCategories = rq_Objects[slvCleaned_dimCategories],
    rqCreate_dimTables = rq_Objects[rqCreate_dimTables],
    rqCreate_dimTableIds = rq_Objects[rqCreate_dimTableIds],

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