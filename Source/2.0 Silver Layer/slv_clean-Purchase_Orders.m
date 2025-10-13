/* 
===================================================
Silver Layer - Clean Data
===================================================

This script loads the `brz_combine-Purchase_Orders.m` and cleans the raw data

+++++++++++++++++++++++++++++++++++++++++++++++++++

`FilePath`: Update file path to absolute path of the folder that contains the purchase orders

 */


let
// file path definition

    rqFilePath = "\\Mac\iCloud\Data Analysis\Projects\Inventory-Tracker\Source\0.0 File Paths\rq-FilePaths.m",
    FilePaths = Expression.Evaluate(Text.FromBinary(File.Contents(rqFilePath)),#shared),
    Source = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[slv_BronzeTableLoad])),#shared),
    rqClean = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[rq_SilverClean])),#shared),

// variables

    DataTypes = rqClean[lstDataTypes],
    OriginalColumnNames = rqClean[lstOriginalColumnNames],
    fxNullHandles = rqClean[lstfxNullHandles],

// query

    #"Update Data Types" = Table.TransformColumnTypes(Source, DataTypes),
    #"Transform Blanks to Nulls" = Table.ReplaceValue(#"Update Data Types","",null,Replacer.ReplaceValue, OriginalColumnNames),
    #"Handle Missing Data" = Table.TransformColumns(#"Transform Blanks to Nulls", fxNullHandles)

in
    #"Handle Missing Data"