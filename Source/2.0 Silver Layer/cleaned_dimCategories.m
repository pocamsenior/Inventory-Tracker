/* 
===================================================
Silver Layer - Create and Clean dimCategories
===================================================
# Script Definition
This script creates the dimCategories table along with each record's Id
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Queries
    slvCleaned_PurchaseOrders = rq_Objects[slvCleaned_PurchaseOrders],
    rqCreate_dimTableIds = rq_Objects[rqCreate_dimTableIds],
    rqCreate_dimTables = rq_Objects[rqCreate_dimTables],
    lstDimTableNames = rqCreate_dimTables[lstTableNames],
    nlstNullHandles = rqCreate_dimTableIds[nlstNullHandles],

// Variables
    posTableName = List.PositionOf(lstDimTableNames,"dimCategories"),
    nlstColumnNames = rqCreate_dimTables[nlstColumnNames]{posTableName},
    nlstRenameColumns = rqCreate_dimTables[nlstRenameColumns]{posTableName},
    idColumnName = rqCreate_dimTables[lstIdColumnNames]{posTableName}{0},
    idPatterns = rqCreate_dimTableIds[lstCreateIdPatternsFX]{posTableName},
    cleanWords = idPatterns{0},
    OneWordPattern = idPatterns{1},
    TwoWordPattern = idPatterns{2},
    ThreeMoreWordPattern = idPatterns{3},


// Query
    Source = slvCleaned_PurchaseOrders,
// Prep Table
    #"Select Columns" = Table.SelectColumns(Source, nlstColumnNames),
    #"Unique Rows" = Table.Distinct(#"Select Columns"),
    #"Rename Columns" = Table.RenameColumns(#"Unique Rows", nlstRenameColumns),
    #"Add Id Column" = Table.AddColumn(#"Rename Columns", idColumnName, each _[Category]),
// Transform Ids
    #"Clean Words" = Table.TransformColumns(#"Add Id Column",{idColumnName, cleanWords}),
    #"One Word Id Patterns" = Table.TransformColumns(#"Clean Words",{idColumnName, OneWordPattern}),
    #"Two Word Id Patterns" = Table.TransformColumns(#"One Word Id Patterns",{idColumnName, TwoWordPattern}),
    #"Three Word Id Patterns" = Table.TransformColumns(#"Two Word Id Patterns",{idColumnName, ThreeMoreWordPattern})
in
    #"Three Word Id Patterns"

