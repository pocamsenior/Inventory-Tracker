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
    rq_FilePath = #shared[rq_FilePaths],

// External Queries
    slvCleaned_PurchaseOrders = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[slvCleaned_PurchaseOrders])),#shared),
    rqCreate_dimTableIds = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[rqCreate_dimTableIds])),#shared),
    rqCreate_dimTables = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[rqCreate_dimTables])),#shared),
    lstDimTableNames = rqCreate_dimTables[lstTableNames],
    nlstNullHandles = rqCreate_dimTableIds[nlstNullHandles],

// Variables
    posTableName = List.PositionOf(lstDimTableNames,"dim_Categories"),
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

