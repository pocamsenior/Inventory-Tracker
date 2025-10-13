let

// file path definition
rqFilePath = "\\Mac\iCloud\Data Analysis\Projects\Inventory-Tracker\Source\0.0 File Paths\rq-FilePaths.m",
FilePaths = Expression.Evaluate(Text.FromBinary(File.Contents(rqFilePath)),#shared),
rqSilverClean = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[rq_SilverClean])),#shared),

// record query
rq = [

// list of dimension table names
lstDimTableNames = {"dim_Products","dim_Categories","dim_Variants","dim_Brands","dim_Sizes"},

// list of original column names
nlstOriginalColumnNames = List.Transform(lstDimTableNames, each if List.Contains({Text.Contains(_,"Product")},true) then List.Select(rqSilverClean[lstOriginalColumnNames], each Text.Contains(_, "Product")) else if List.Contains({Text.Contains(_,"Categories")},true) then List.Select(rqSilverClean[lstOriginalColumnNames], each Text.Contains(_, "Category")) else if List.Contains({Text.Contains(_,"Variant")},true) then List.Select(rqSilverClean[lstOriginalColumnNames], each Text.Contains(_, "Variant")) else if List.Contains({Text.Contains(_,"Brand"),Text.Contains(_,"Model")},true) then List.Select(rqSilverClean[lstOriginalColumnNames], each Text.Contains(_, "Brand") or Text.Contains(_, "Model")) else if List.Contains({Text.Contains(_,"Size")},true) then List.Select(rqSilverClean[lstOriginalColumnNames], each Text.Contains(_, "Size") ) else null),

// list of original column names and new names to rename
nlstRenameColumns = List.Transform(nlstOriginalColumnNames, each if List.Count(List.Combine({List.Transform(_, (nListItem) => nListItem),List.Transform(_, (nListItem) => Text.AfterDelimiter(nListItem," "))}))>2 then List.Zip(List.Split(List.Combine({List.Transform(_, (nListItem) => nListItem),List.Transform(_, (nListItem) => Text.AfterDelimiter(nListItem," "))}),List.Count(List.Combine({List.Transform(_, (nListItem) => nListItem),List.Transform(_, (nListItem) => Text.AfterDelimiter(nListItem," "))}))/2)) else List.Combine({List.Transform(_, (nListItem) => nListItem),List.Transform(_, (nListItem) => Text.AfterDelimiter(nListItem," "))})),

//
nlstSortAscending =  List.Transform((List.Transform(lstDimTableNames, each List.Transform(nlstRenameColumns{List.PositionOf(lstDimTableNames,_)},(nListItem) => if Value.Type(nListItem) = type list then List.Combine({List.Select(nListItem, each not Text.Contains(_, "Product")),{Order.Ascending}}) else nListItem))), each if List.PositionOf(nlstRenameColumns,_) >= 1 then List.Combine({List.Select(_, each not Text.Contains(_, "Product")),{Order.Ascending}}) else _), 

nlstContents = List.Zip({lstDimTableNames, nlstOriginalColumnNames, nlstRenameColumns, nlstSortAscending})
]

in

rq