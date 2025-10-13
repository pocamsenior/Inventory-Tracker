let

// file path definition
rqFilePath = "\\Mac\iCloud\Data Analysis\Projects\Inventory-Tracker\Source\0.0 File Paths\rq-FilePaths.m",
FilePaths = Expression.Evaluate(Text.FromBinary(File.Contents(rqFilePath)),#shared),
brzTable = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[slv_BronzeTableLoad])),#shared),

// record query
rq = [


// bronze layer column names
lstOriginalColumnNames = Table.ColumnNames(brzTable),

// list of data types
lstDataTypes = List.Transform(lstOriginalColumnNames,each {_,if List.Contains({Text.Contains(_,"Id"),Text.Contains(_,"Quantity")},true) then Int64.Type else if List.Contains({Text.Contains(_,"Date")},true) then Date.Type else if List.Contains({Text.Contains(_,"Price")},true) then Decimal.Type else Text.Type }),

// list of null handles
lstNullHandles = List.Transform(lstOriginalColumnNames,each {_, if List.Contains({Text.Contains(_,"Supplier"),Text.Contains(_,"Hyperlink")},true) then "Not Provided" else if List.Contains({Text.Contains(_,"Brand")},true) then "Not Available" else if List.Contains({Text.Contains(_,"Variant"),Text.Contains(_,"Model"),Text.Contains(_,"Size")},true) then "Not Applicable" else if List.Contains({Text.Contains(_,"Price")},true) then -1 else "** Nulls Not Allowed **"}),

// list of null handle functions
lstfxNullHandles = List.Transform(lstOriginalColumnNames, each {_,(x) => x ?? lstNullHandles{List.PositionOf(lstOriginalColumnNames,_)}{1}}),

// list of unique null handles
lstDistinctNullHandles = List.Distinct(List.Transform(lstNullHandles,each _{1})),

// function for checking for nulls
fxNullCheck = each List.Contains(lstDistinctNullHandles, [Order Id]) or List.Contains(lstDistinctNullHandles, [Order Date]) or List.Contains(lstDistinctNullHandles, [Order Supplier]) or List.Contains(lstDistinctNullHandles, [Order Quantity]) or List.Contains(lstDistinctNullHandles, [Product Category]) or List.Contains(lstDistinctNullHandles, [Product Name]) or List.Contains(lstDistinctNullHandles, [Product Brand]) or List.Contains(lstDistinctNullHandles, [Product Model]) or List.Contains(lstDistinctNullHandles, [Product Price])or List.Contains(lstDistinctNullHandles, [Product Quantity]) or List.Contains(lstDistinctNullHandles, [Product Hyperlink])

]

in

rq