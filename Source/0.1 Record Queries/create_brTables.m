/* 
===================================================
Record Query - Create Bridge Tables
===================================================
# Script Definition
This script aids in creating all bridge tables
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Queries
    rqClean_PurchaseOrders = rq_Objects[rqClean_PurchaseOrders],
    rqCreate_dimTables = rq_Objects[rqCreate_dimTables],
    lstColumnNames = rqClean_PurchaseOrders[lstColumnNames],
    lstTableNames = rqCreate_dimTables[lstTableNames],
    slvCleaned_dimCategories = rq_Objects[slvCleaned_dimCategories],
    slvCleaned_dimVariants = rq_Objects[slvCleaned_dimVariants],
    slvCleaned_dimBrands = rq_Objects[slvCleaned_dimBrands],
    slvCleaned_dimSizes = rq_Objects[slvCleaned_dimSizes],

// Variables
    lstTableNamesSansFirst = List.RemoveFirstN(lstTableNames,1),
    lstProductColumnNames = List.Select(List.Select(lstColumnNames, each Text.Contains(_,"Product") = true), each List.Contains({Text.Contains(_,"Category"), Text.Contains(_,"Variant"), Text.Contains(_,"Brand"),Text.Contains(_,"Model"), Text.Contains(_,"Size")}, true)),
    lstdimTablesOBJ = {slvCleaned_dimCategories,slvCleaned_dimVariants,slvCleaned_dimBrands,slvCleaned_dimSizes},
    lstDimTablesJoinInfo = List.RemoveNulls(List.Generate(() => 0, each _ < 5, each _ + 1, 
            each if Text.Contains(lstProductColumnNames{_},"Brand") 
            then {lstProductColumnNames{_}, lstProductColumnNames{_+1}, Text.AfterDelimiter(lstProductColumnNames{_}," "), Text.AfterDelimiter(lstProductColumnNames{_+1}," "),Text.Combine({Text.AfterDelimiter(lstProductColumnNames{_}," ")," Id"}),Text.Combine({Text.AfterDelimiter(lstProductColumnNames{_+1}," ")," Id"})} 
            else if Text.Contains(lstProductColumnNames{_},"Model")
            then null
            else {lstProductColumnNames{_}, Text.AfterDelimiter(lstProductColumnNames{_}," "), Text.Combine({Text.AfterDelimiter(lstProductColumnNames{_}," ")," Id"})})),

// Record Query
    create_brTables = 

        [
        // dimension table names
            lstTableNames = lstTableNames,

        // join table list
            lstTableJoins = List.Transform(lstDimTablesJoinInfo, each if List.Count(_) > 3 then List.Split(_,2) else _),

        // join dimTables to a source table
            joinTables = (Initial, InputTable) =>
                let 
                    step = Initial,
                    JoinTable = lstdimTablesOBJ,
                    OutputTableFX = (tblA, tblB, position) => 
                        if Value.Type(lstTableJoins{step}{0}) = Text.Type
                        then Table.ExpandTableColumn(Table.NestedJoin(tblA, lstTableJoins{position}{0}, tblB, lstTableJoins{position}{1}, lstTableJoins{position}{2}, JoinKind.LeftOuter), lstTableJoins{position}{2}, {lstTableJoins{position}{2}})
                        else Table.ExpandTableColumn(Table.NestedJoin(tblA, {lstTableJoins{position}{0}{0},lstTableJoins{position}{0}{1}}, tblB, {lstTableJoins{position}{1}{0}, lstTableJoins{position}{1}{1}}, lstTableJoins{position}{2}{0}, JoinKind.LeftOuter), lstTableJoins{position}{2}{0}, {lstTableJoins{position}{2}{0}}),
                    OutputTable = OutputTableFX(InputTable, JoinTable{step}, step)

                in
                    if step < List.Count(JoinTable)-1 then @joinTables(step+1, OutputTable) else OutputTable,

            // create product key column
                createProductKey = (tbl) =>
                    let
                        lstIds = List.Transform(List.Select(lstProductColumnNames, each not(Text.Contains(_, "Model"))), each Text.Combine({Text.AfterDelimiter(_," "), " Id"}))
                    in
                        Table.CombineColumns(tbl, lstIds, Combiner.CombineTextByDelimiter("-",QuoteStyle.None), "Product Key"),

            // testing
                test = null
        ]

in
    create_brTables