/* 
===================================================
Record Query - Create Dimension Tables
===================================================
# Script Definition
This script aids in creating all dimension tables
===================================================
*/

let
// File Path Definition
    rq_FilePath = #shared[rq_FilePaths],

// External Queries
    rqClean_PurchaseOrders = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[rqClean_PurchaseOrders])),#shared),
    lstColumnNames = rqClean_PurchaseOrders[lstColumnNames],

// Functions
    nlstOriginalItems = (listItem) => List.Transform(listItem, (nListItem) => nListItem),
    rmNestedListFirstWord = (listItem) => List.Transform(listItem, (nListItem) => Text.AfterDelimiter(nListItem," ")),
    createNestedListColumnIdName = (listItem) => List.Transform(listItem, (nListItem) => Text.Combine({Text.AfterDelimiter(nListItem," ")," Id"})),

// Record Query
    create_dimTables = 

        [
        // dimension table names
            lstTableNames = {"dim_Products","dim_Categories","dim_Variants","dim_Brands","dim_Sizes"},

        // original dimension table column names
            nlstColumnNames = List.Transform(lstTableNames, 
            each 
                if List.Contains({Text.Contains(_,"Product")},true) then List.Select(lstColumnNames, each Text.Contains(_, "Product")) 
                else if List.Contains({Text.Contains(_,"Categories")},true) then List.Select(lstColumnNames, each Text.Contains(_, "Category")) 
                else if List.Contains({Text.Contains(_,"Variant")},true) then List.Select(lstColumnNames, each Text.Contains(_, "Variant")) 
                else if List.Contains({Text.Contains(_,"Brand"),Text.Contains(_,"Model")},true) then List.Select(lstColumnNames, each Text.Contains(_, "Brand") or Text.Contains(_, "Model")) 
                else if List.Contains({Text.Contains(_,"Size")},true) then List.Select(lstColumnNames, each Text.Contains(_, "Size") ) 
                else null),

        // renamed dimension table column names
            nlstRenameColumns = List.Transform(nlstColumnNames, 
            each 
                if List.Count(List.Combine({nlstOriginalItems(_),rmNestedListFirstWord(_)}))>2 
                then List.Zip(List.Split(List.Combine({nlstOriginalItems(_),rmNestedListFirstWord(_)}),List.Count(List.Combine({nlstOriginalItems(_),rmNestedListFirstWord(_)}))/2)) 
                else List.Combine({nlstOriginalItems(_),rmNestedListFirstWord(_)})),

        // id column names
            lstIdColumnNames = List.Transform(nlstColumnNames, each createNestedListColumnIdName(_)),

            // // sorting order
            // nlstSortAscending =  List.Transform((List.Transform(lstTableNames, each List.Transform(nlstRenameColumns{List.PositionOf(lstTableNames,_)},(nListItem) => if Value.Type(nListItem) = type list then List.Combine({List.Select(nListItem, each not Text.Contains(_, "Product")),{Order.Ascending}}) else nListItem))), each if List.PositionOf(nlstRenameColumns,_) >= 1 then List.Combine({List.Select(_, each not Text.Contains(_, "Product")),{Order.Ascending}}) else _),


        // null handles
            lstNullHandles = List.Select(rqClean_PurchaseOrders[lstDistinctNullHandles], each _ <> -1 and List.Count(Text.PositionOf(_," ",Occurrence.All)) = 1)

        ]

in
    create_dimTables