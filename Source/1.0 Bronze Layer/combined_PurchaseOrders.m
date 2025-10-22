/* 
===================================================
Bronze Layer - Create Bronze Layer Tables
===================================================
# Script Definition
This script expands all of the file contents from the purchase orders and makes one table
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Queries
    brzBinary_PurchaseOrders = rq_Objects[brzBinary_PurchaseOrders],

// Query
    Source = brzBinary_PurchaseOrders,
    #"Expand & Append Tables" = Table.Combine(Source[Content])

in
    #"Expand & Append Tables"
