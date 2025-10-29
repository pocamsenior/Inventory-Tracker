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
    rq_Objects = #shared[rq_Objects],
    
// External Queries
    brzCombined_PurchaseOrders = rq_Objects[brzCombined_PurchaseOrders],

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

            // function for reversing null handling to check them
                nlstReverseNullHandlesFX = List.Transform(lstColumnNames, 
                    each{_, (value) => if List.Contains(lstDistinctNullHandles,value) then null else value})

        ]

in
    clean_PurchaseOrders