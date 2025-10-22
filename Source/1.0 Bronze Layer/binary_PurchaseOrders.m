/* 
===================================================
Bronze Layer - Import Purchase Orders Excel Files
===================================================
# Script Definition
This script creates a combined table of all purchase orders excel files in one folder.
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],
    rawCSV_Files = rq_Objects[rawCSV_Files],

// Query
    Source = rawCSV_Files,
    #"Filter Files" = Table.SelectRows(Source, each not Text.StartsWith([Name],".")),
    #"Transform Content Binary to Table" = Table.TransformColumns(#"Filter Files",{"Content", each Csv.Document(_)}),
    #"Add Timestamp Column" = Table.AddColumn(#"Transform Content Binary to Table","Date Last Query",each DateTime.LocalNow()),
    #"Sort Table by Name" = Table.Sort(#"Add Timestamp Column",{"Name",Order.Ascending}),
    #"Promote CSV Headers" = Table.TransformColumns(#"Sort Table by Name", {"Content", each Table.PromoteHeaders(_)})
in
    #"Promote CSV Headers"