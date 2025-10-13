/* 
===================================================
Bronze Layer - Create Bronze Layer Tables
===================================================

This script expands all of the file contents from the purchase orders and makes one table

+++++++++++++++++++++++++++++++++++++++++++++++++++

`FilePath`: Update file path to absolute path of the folder

 */

let
// file path definition

    rqFilePath = "\\Mac\iCloud\Data Analysis\Projects\Inventory-Tracker\Source\0.0 File Paths\rq-FilePaths.m",
    FilePaths = Expression.Evaluate(Text.FromBinary(File.Contents(rqFilePath)),#shared),
    Source = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[brz_BinaryFiles])),#shared),

// query

    #"Expand & Append Tables" = Table.Combine(Source[Content])
in
    #"Expand & Append Tables"