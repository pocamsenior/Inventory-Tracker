/* 
===================================================
Silver Layer - Create and Clean dimSizes
===================================================
# Script Definition
This script creates the dimSizes table along with each record's Id
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

//External Queries
    slvCleaned_PurchaseOrders = rq_Objects[slvCleaned_PurchaseOrders],
    rqCreate_dimTableIds = rq_Objects[rqCreate_dimTableIds],
    rqCreate_dimTables = rq_Objects[rqCreate_dimTables],
    lstDimTableNames = rqCreate_dimTables[lstTableNames],
    nlstNullHandles = rqCreate_dimTableIds[nlstNullHandles],

// Variables
    posTableName = List.PositionOf(lstDimTableNames,"dim_Sizes"),
    nlstColumnNames = rqCreate_dimTables[nlstColumnNames]{posTableName},
    nlstRenameColumns = rqCreate_dimTables[nlstRenameColumns]{posTableName},
    idColumnName = rqCreate_dimTables[lstIdColumnNames]{posTableName}{0},
    idPatterns = rqCreate_dimTableIds[lstCreateIdPatternsFX]{posTableName},
    cleanWords = idPatterns{0},
    handleMissingData = idPatterns{1},
    changeUnits = idPatterns{2},
    changeSize = idPatterns{3},
    combineWords = idPatterns{4},
   

// Query
    Source = slvCleaned_PurchaseOrders,
// Prep Table
    #"Select Columns" = Table.SelectColumns(Source, nlstColumnNames),
    #"Unique Rows" = Table.Distinct(#"Select Columns"),
    #"Rename Column" = Table.RenameColumns(#"Unique Rows", nlstRenameColumns),
    #"Add Id Column" = Table.AddColumn(#"Rename Column",idColumnName, each _[Size]),
//Transform Ids
    #"Clean Words" = Table.TransformColumns(#"Add Id Column",{idColumnName, cleanWords}),
    #"Handle Missing Data" = Table.TransformColumns(#"Clean Words",{idColumnName, handleMissingData}),
    #"Change Units" = Table.TransformColumns(#"Handle Missing Data",{idColumnName, changeUnits}),
    #"Change Size" = Table.TransformColumns(#"Change Units",{idColumnName, changeSize}),#"Combine Words" = Table.TransformColumns(#"Change Size",{idColumnName, combineWords})
    
in

#"Combine Words"