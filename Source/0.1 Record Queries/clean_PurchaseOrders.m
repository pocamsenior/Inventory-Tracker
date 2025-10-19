/* 
===================================================
Record Query - Clean Purchase Orders
===================================================
# Script Definition
This script contains lists and functions that aid in cleaning Purchase Orders
===================================================
*/

let
// File Path Definition
    rq_FilePath = #shared[rq_FilePaths],
    
// External Queries
    brzCombined_PurchaseOrders = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[brzCombined_PurchaseOrders])),#shared),

// Record Query
    clean_PurchaseOrders = 

        [
            // column names
            lstColumnNames = Table.ColumnNames(brzCombined_PurchaseOrders),

            // data types
            nlstDataTypes = List.Transform(lstColumnNames,
            each {_,
                if List.Contains({Text.Contains(_,"Id"),Text.Contains(_,"Quantity")},true) then Int64.Type 
                else if List.Contains({Text.Contains(_,"Date")},true) then Date.Type 
                else if List.Contains({Text.Contains(_,"Price")},true) then Decimal.Type 
                else Text.Type}),

            // null handles
            lstNullHandles = List.Transform(lstColumnNames,
            each 
                if List.Contains({Text.Contains(_,"Supplier"),Text.Contains(_,"Hyperlink")},true) then "Not Provided" 
                else if List.Contains({Text.Contains(_,"Brand")},true) then "Not Available" 
                else if List.Contains({Text.Contains(_,"Variant"),Text.Contains(_,"Model"),Text.Contains(_,"Size")},true) then "Not Applicable" 
                else if List.Contains({Text.Contains(_,"Price")},true) then -1 
                else "** Nulls Not Allowed **"),

            // null handle functions
            nlstNullHandlesFX = List.Transform(lstColumnNames, 
            each {_,
                (value) => value ?? lstNullHandles{List.PositionOf(lstColumnNames,_)}}),

            // unique null handles
            lstDistinctNullHandles = List.Distinct(List.Transform(lstNullHandles, each _)),

            // function for checking for nulls ***** Update, if possible *****
            chkNulls = each List.Contains(lstDistinctNullHandles, [Order Id]) or List.Contains(lstDistinctNullHandles, [Order Date]) or List.Contains(lstDistinctNullHandles, [Order Supplier]) or List.Contains(lstDistinctNullHandles, [Order Quantity]) or List.Contains(lstDistinctNullHandles, [Product Category]) or List.Contains(lstDistinctNullHandles, [Product Name]) or List.Contains(lstDistinctNullHandles, [Product Brand]) or List.Contains(lstDistinctNullHandles, [Product Model]) or List.Contains(lstDistinctNullHandles, [Product Price])or List.Contains(lstDistinctNullHandles, [Product Quantity]) or List.Contains(lstDistinctNullHandles, [Product Hyperlink])

        ]

in
    clean_PurchaseOrders