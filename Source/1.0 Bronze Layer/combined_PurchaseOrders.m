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
    rq_FilePath = #shared[rq_FilePaths],

// External Queries
    brzBinary_PurchaseOrders = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[brzBinary_PurchaseOrders])),#shared),

// Query
    Source = brzBinary_PurchaseOrders,
    #"Expand & Append Tables" = Table.Combine(Source[Content])

in
    #"Expand & Append Tables"
