/* 
===================================================
Check Query - Nulls in Purchase Orders
===================================================
# Script Definition
This script isolates all records in Purchase Orders that contain a null handle

*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Queries
    rqClean_PurchaseOrders = rq_Objects[rqClean_PurchaseOrders],
    slvCleaned_PurchaseOrders = rq_Objects[slvCleaned_PurchaseOrders],

// Variables
nlstReverseNullHandlesFX = rqClean_PurchaseOrders[nlstReverseNullHandlesFX],
NullColumnName = "Nulls",

// Query
    Source = slvCleaned_PurchaseOrders,
    #"Reverse Handle Missing Data" = Table.TransformColumns(Source, nlstReverseNullHandlesFX),
    #"Add Null Column" = Table.AddColumn(#"Reverse Handle Missing Data",NullColumnName, each List.Contains(Record.ToList(_),null)),
    #"Null Check" = Table.SelectRows(#"Add Null Column", each [Nulls] = true),
    #"Remove Null Column" = Table.RemoveColumns(#"Null Check", NullColumnName)

in
     #"Remove Null Column"
    
