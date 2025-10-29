/* 
===================================================
Gold Layer - faceOrders
===================================================
# Script Definition
This script creates the faceOrders Table
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Tables
    slvCombined_brProductOrders = rq_Objects[slvCombined_brProductOrders],
    rqCreate_gldTables = rq_Objects[rqCreate_gldTables],

// Variables
    factOrders = rqCreate_gldTables[factOrders],

// Query
    Source = factOrders

in 

    Source