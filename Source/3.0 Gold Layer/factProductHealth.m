/* 
===================================================
Gold Layer - factProductHealth
===================================================
# Script Definition
This script creates the factProductHealth Table
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Tables
    slvCombined_brProductOrders = rq_Objects[slvCombined_brProductOrders],

// Query
    Source = slvCombined_brProductOrders

in 

    Source