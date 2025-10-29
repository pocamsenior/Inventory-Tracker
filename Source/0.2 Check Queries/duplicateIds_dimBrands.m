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
    rq_Objects = #shared[rq_Objects],

// External Queries
    slvCleaned_dimBrands = rq_Objects[slvCleaned_dimBrands],
    rqCreate_dimTables = rq_Objects[rqCreate_dimTables],
    rqCreate_dimTableIds = rq_Objects[rqCreate_dimTableIds],

// // Variables
//     lstDimTableNames = rqCreate_dimTables[lstTableNames],
//     posTableName = List.PositionOf(lstDimTableNames,"dim_Brands"),
//     idColumnName = rqCreate_dimTables[lstIdColumnNames]{posTableName}{0},
//     ColumnName = Text.BeforeDelimiter(idColumnName, " "),

// // Query
//     Source = slvCleaned_dimBrands,
//     #"Remove Columns" = Table.RemoveColumns(Source,{"Model", "Model Number"}),
//     #"Check Duplicates" = rqCreate_dimTableIds[chkDuplicates](#"Remove Columns",{ColumnName,idColumnName},posTableName)

// Variables
    lstDimTableNames = rqCreate_dimTables[lstTableNames],
    posTableName = List.PositionOf(lstDimTableNames,"dimBrands"),
    idColumnName = rqCreate_dimTables[lstIdColumnNames]{posTableName}{0},
    ColumnName = Text.BeforeDelimiter(idColumnName, " "),

   
// Query
    Source = slvCleaned_dimBrands,
    #"Check Duplicates" = rqCreate_dimTableIds[chkDuplicates](Source, {ColumnName, idColumnName}, posTableName)

in

    #"Check Duplicates"