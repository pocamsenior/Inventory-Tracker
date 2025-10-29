/* 
===================================================
Record Query - Create Dimension Tables
===================================================
# Script Definition
This script aids in creating all dimension tables in the silver layer
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Queries
    rqClean_PurchaseOrders = rq_Objects[rqClean_PurchaseOrders],
    lstColumnNames = rqClean_PurchaseOrders[lstColumnNames],
    slvCleaned_dimCategories = rq_Objects[slvCleaned_dimCategories],
    slvCleaned_dimVariants = rq_Objects[slvCleaned_dimVariants],
    slvCleaned_dimBrands = rq_Objects[slvCleaned_dimBrands],
    slvCleaned_dimSizes = rq_Objects[slvCleaned_dimSizes],

// Variables
    lstTableNames = {"dimProducts","dimCategories","dimVariants","dimBrands","dimSizes"},

// Functions
    nlstOriginalItems = (listItem) => List.Transform(listItem, (nListItem) => nListItem),
    rmNestedListFirstWord = (listItem) => List.Transform(listItem, (nListItem) => Text.AfterDelimiter(nListItem," ")),
    createNestedListColumnIdName = (listItem) => List.Transform(listItem, (nListItem) => Text.Combine({Text.AfterDelimiter(nListItem," ")," Id"})),

// Record Query
    create_dimTables = 

        [
        // dimension table names
            lstTableNames = lstTableNames,

        // original dimension table column names -- future refactor?
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

        // null handles
            lstNullHandles = List.Select(rqClean_PurchaseOrders[lstDistinctNullHandles], each _ <> -1 and List.Count(Text.PositionOf(_," ",Occurrence.All)) = 1)

        ]

in
    create_dimTables