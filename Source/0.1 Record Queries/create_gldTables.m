/* 
===================================================
Record Query - Create Gold Tables
===================================================
# Script Definition
This script aids in creating all tables in the gold layer
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Queries
    slvCombined_brProductOrders = rq_Objects[slvCombined_brProductOrders],rqClean_PurchaseOrders = rq_Objects[rqClean_PurchaseOrders],
    gld_dimProducts = rq_Objects[gld_dimProducts],

// Variables
    lstBrProductOrdersColumnNames = Table.ColumnNames(slvCombined_brProductOrders),
    lstBrProductColumnNames = List.Select(lstBrProductOrdersColumnNames, each Text.Contains(_,"Product")),
    lstKeyProductColumns = List.Select(List.RemoveLastN(lstBrProductOrdersColumnNames,5), each Text.Contains(_,"Product")),
    lstGldOrdersColumns = List.InsertRange(List.RemoveLastN(List.RemoveItems(lstBrProductOrdersColumnNames,lstKeyProductColumns),3),1,{"Product Id"}),


// Record Query
    create_gldTables = 

        [       
            // list of columns that pertain to Orders    
            lstOrderColumns = List.Select(lstBrProductOrdersColumnNames, each not(Text.Contains(_,"Product"))),

            // function that reorders dimProducts Columns
            reorderDimProductsColumns = () => 
                    let
                        nlstReorderDimProductsColumns = {{8, "Product Total Order Quantity"}},
                        lstRemoveDimProductsColumns = {"Product Key", "Product Quantity"},
                        lstRemoveColumnNames = List.Select(List.Combine(nlstReorderDimProductsColumns), each Number.Mod((List.PositionOf(List.Combine(nlstReorderDimProductsColumns),_)),2) = 1),
                        lstIndexNumbers = List.Select(List.Combine(nlstReorderDimProductsColumns), each Number.Mod((List.PositionOf(List.Combine(nlstReorderDimProductsColumns),_)),2) = 0),
                        lstRemovedColumnNames = List.RemoveItems(lstBrProductColumnNames, List.Combine({lstRemoveColumnNames,lstRemoveDimProductsColumns}))
                    in
                        List.Accumulate(lstIndexNumbers, lstRemovedColumnNames, (lst, index) => List.InsertRange(lst, index, {lstRemoveColumnNames{List.PositionOf(lstIndexNumbers, index)}})),

            // function that aggregated dimProducts table
            lstAggregatedDimProductsColumns = (tbl) => 
                    let
                        nlstAggregatedColumnsFX = {
                            {"Latest Product Hyperlink", each [Product Hyperlink]{Table.RowCount(_)-1}},
                            {"Average Product Price", each if List.Average(Table.ReplaceValue(_, -1, null, Replacer.ReplaceValue,{"Product Price"})[Product Price]) = null then -1 else List.Average(Table.ReplaceValue(_, -1, null, Replacer.ReplaceValue,{"Product Price"})[Product Price])}, 
                            {"Product Total Order Quantity", each List.Sum([Product Total Order Quantity])}},
                        lstAggregatedColumns = List.Select(List.Combine(nlstAggregatedColumnsFX), each Number.Mod((List.PositionOf(List.Combine(nlstAggregatedColumnsFX),_)),2) = 0),
                        lstKeyColumns = List.RemoveItems(reorderDimProductsColumns(), lstAggregatedColumns)
                    in
                        Table.Group(tbl, lstKeyColumns, nlstAggregatedColumnsFX),

            factOrders = Table.Sort(Table.SelectColumns(Table.ExpandTableColumn(Table.NestedJoin(slvCombined_brProductOrders, lstKeyProductColumns, gld_dimProducts, lstKeyProductColumns, "dimProducts", JoinKind.Inner), "dimProducts", {"Product Id"}), lstGldOrdersColumns), {{"Order Id", Order.Ascending},{"Product Id", Order.Ascending}}),

            // testing
                test = 1
        ]

in
    create_gldTables