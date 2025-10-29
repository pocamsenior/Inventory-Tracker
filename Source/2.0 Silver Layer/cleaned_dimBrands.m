/* 
===================================================
Silver Layer - Create and Clean dimBrands
===================================================
# Script Definition
This script creates the dimBrands table along with each record's Id
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
    posTableName = List.PositionOf(lstDimTableNames,"dimBrands"),
    nlstColumnNames = rqCreate_dimTables[nlstColumnNames]{posTableName},
    nlstRenameColumns = rqCreate_dimTables[nlstRenameColumns]{posTableName},
    idColumnName = rqCreate_dimTables[lstIdColumnNames]{posTableName}{0},
    idPatterns = rqCreate_dimTableIds[lstCreateIdPatternsFX]{posTableName},
    cleanWords = idPatterns{0},
    handleMissingData = idPatterns{1},
    OneWordPattern = idPatterns{2},
    TwoWordPattern = idPatterns{3},
    ThreeWordPattern = idPatterns{4},
    MoreThanThreeWordPattern = idPatterns{5},
    chkDuplicates = (tbl,ColumnGroup) => Table.ExpandTableColumn(Table.TransformColumns(Table.Group(tbl,ColumnGroup,{"Model Number", each _}),{"Model Number", each Table.AddIndexColumn(_,"Model Number",1,1)}),"Model Number",{"Model","Model Number"}),
    


// Query
    Source = slvCleaned_PurchaseOrders,
// Prep Table
    #"Select Columns" = Table.SelectColumns(Source, nlstColumnNames),
    #"Unique Rows" = Table.Distinct(#"Select Columns"),
    #"Rename Column" = Table.RenameColumns(#"Unique Rows", nlstRenameColumns),
    #"Add Model Number" = chkDuplicates(#"Rename Column","Brand"),
    #"Add Id Column" = Table.AddColumn(#"Add Model Number",idColumnName, each _[Brand]),
//Transform Ids
    #"Clean Words" = Table.TransformColumns(#"Add Id Column",{idColumnName, cleanWords}),
    #"Handle Missing Data" = Table.TransformColumns(#"Clean Words",{idColumnName, handleMissingData}),
    #"One Word Id" = Table.TransformColumns(#"Handle Missing Data",{idColumnName, OneWordPattern}),
    #"Two Word Id" = Table.TransformColumns(#"One Word Id",{idColumnName, TwoWordPattern}),
    #"Three Word Id" = Table.TransformColumns(#"Two Word Id",{idColumnName, ThreeWordPattern}),
    #"More Than Three Word Id Patterns" = Table.TransformColumns(#"Three Word Id",{idColumnName, MoreThanThreeWordPattern}),
    #"Combine Brand ID and Model Number" = Table.CombineColumns(#"More Than Three Word Id Patterns",{idColumnName, "Model Number"}, each Text.Combine({_{0},Text.PadStart(Text.From(_{1}),3,"0")}), "Brand Id")

in
 #"Combine Brand ID and Model Number"