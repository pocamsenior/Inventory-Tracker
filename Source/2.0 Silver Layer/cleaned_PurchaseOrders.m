/* 
===================================================
Silver Layer - Clean PurchaseOrders
===================================================
# Script Definition
This script loads the combined data from the bronze layer and does a preliminary clean
    1. Data types are updated
    2. All blanks/nulls are handled based on their columns purpose
===================================================
*/

let
// File Path Definition
    rq_FilePath = #shared[rq_FilePaths],
    rqClean_PurchaseOrders = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[rqClean_PurchaseOrders])),#shared),
    brzCombined_PurchaseOrders = Expression.Evaluate(Text.FromBinary(File.Contents(rq_FilePath[brzCombined_PurchaseOrders])),#shared),

// Variables
    nlstDataTypes = rqClean_PurchaseOrders[nlstDataTypes],
    lstColumnNames = rqClean_PurchaseOrders[lstColumnNames],
    nlstNullHandlesFX = rqClean_PurchaseOrders[nlstNullHandlesFX],

// Query

    Source = brzCombined_PurchaseOrders,
    #"Update Data Types" = Table.TransformColumnTypes(Source, nlstDataTypes),
    #"Transform Blanks to Nulls" = Table.ReplaceValue(#"Update Data Types","",null,Replacer.ReplaceValue,lstColumnNames),
    #"Handle Missing Data" = Table.TransformColumns(#"Transform Blanks to Nulls", nlstNullHandlesFX)

in
    #"Handle Missing Data"