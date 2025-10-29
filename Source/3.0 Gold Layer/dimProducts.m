/* 
===================================================
Gold Layer - dimProducts
===================================================
# Script Definition
This script creates the dimProducts Table
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Tables
    slvCombined_brProductOrders = rq_Objects[slvCombined_brProductOrders],
    rqCreate_gldTables = rq_Objects[rqCreate_gldTables],
    

// Variables
lstOrderColumns = rqCreate_gldTables[lstOrderColumns],
reorderDimProductsColumns = rqCreate_gldTables[reorderDimProductsColumns](),
aggregateTable = rqCreate_gldTables[lstAggregatedDimProductsColumns],

// Query
    Source = slvCombined_brProductOrders,
    #"Select Columns" = Table.SelectColumns(Source,reorderDimProductsColumns),
    #"Aggregate Products" = aggregateTable(#"Select Columns"),
    #"Add Index Column" = Table.AddIndexColumn(#"Aggregate Products","Product Id", 1, 1, Int64.Type),
    #"Move Index Column to Beginning" = Table.SelectColumns(#"Add Index Column", List.InsertRange(List.RemoveLastN(Table.ColumnNames(#"Add Index Column"),1),0,{"Product Id"}))



in 

// Source
    #"Move Index Column to Beginning"

// Test
// rqCreate_gldTables[test]()