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
chkNulls = rqClean_PurchaseOrders[chkNulls],

// Query
    Source = slvCleaned_PurchaseOrders,
    #"Null Check" = Table.SelectRows(Source, chkNulls)

in

    Source