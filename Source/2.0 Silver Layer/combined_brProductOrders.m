/* 
===================================================
Silver Layer - brProductsOrders
===================================================
# Script Definition
This script creates the brProductsOrders Table
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Tables
    rqCreate_brTables = rq_Objects[rqCreate_brTables],
    slvCleaned_PurchaseOrders = rq_Objects[slvCleaned_PurchaseOrders],
    slvCleaned_dimCategories = rq_Objects[slvCleaned_dimCategories],
    joinTables = rqCreate_brTables[joinTables],
    createProductKey = rqCreate_brTables[createProductKey],

// Query
    Source = slvCleaned_PurchaseOrders,
    #"Join Tables" = joinTables(0, Source),
    #"Create Product Key" = createProductKey(#"Join Tables"),
    #"Add Total Product Order Quantity Column" = Table.AddColumn(#"Create Product Key","Product Total Order Quantity", each [Order Quantity]*[Product Quantity], Int64.Type)

in 

    #"Add Total Product Order Quantity Column"