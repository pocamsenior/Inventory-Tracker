/* 
===================================================
Bronze Layer - Import Purchase Order Excel Files
===================================================

This script creates a combined table of all purchase order files in one folder.

+++++++++++++++++++++++++++++++++++++++++++++++++++

`FilePath`: Update file path to absolute path of the folder that contains the purchase orders

 */

let
// file path definition

    rqFilePath = "\\Mac\iCloud\Data Analysis\Projects\Inventory-Tracker\Source\0.0 File Paths\rq-FilePaths.m",
    FilePaths = Expression.Evaluate(Text.FromBinary(File.Contents(rqFilePath)),#shared),
    Source = Folder.Contents(FilePaths[brz_CSVFiles]),

// query

    #"Filter Files" = Table.SelectRows(Source, each not Text.StartsWith([Name],".")),
    #"Transform Content Binary to Table" = Table.TransformColumns(#"Filter Files",{"Content", each Csv.Document(_)}),
    #"Add Timestamp Column" = Table.AddColumn(#"Transform Content Binary to Table","Date Last Query",each DateTime.LocalNow()),
    #"Sort Table by Name" = Table.Sort(#"Add Timestamp Column",{"Name",Order.Ascending}),
    #"Promote CSV Headers" = Table.TransformColumns(#"Sort Table by Name", {"Content", each Table.PromoteHeaders(_)})
in
    #"Promote CSV Headers"