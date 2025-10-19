/* 
===================================================
Check Query - Nulls in Purchase Orders
===================================================
# Script Definition
This script isolates all records in Purchase Orders that contain a null handle

*/

let
// File Path Definition
    rq_FilePath = #shared[rq_FilePaths],

// External Queries
    rqClean_PurchaseOrders = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[rqClean_PurchaseOrders])),#shared),
    slvCleaned_PurchaseOrders = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[slvCleaned_PurchaseOrders])),#shared),

// Variables
chkNulls = rqClean_PurchaseOrders[chkNulls],

// Query
    Source = slvCleaned_PurchaseOrders,
    #"Null Check" = Table.SelectRows(Source, chkNulls)

in

    Source