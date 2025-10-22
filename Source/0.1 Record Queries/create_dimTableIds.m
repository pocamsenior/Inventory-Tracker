/* 
===================================================
Record Query - Create Dimension Table Ids
===================================================
# Script Definition
This script aids in the creation of the auto-generated Ids in the dimension tables
===================================================
*/

let
// File Path Definition
    rq_Objects = #shared[rq_Objects],

// External Queries
    rqClean_PurchaseOrders = rq_Objects[rqClean_PurchaseOrders],
    rqCreate_dimTables = rq_Objects[rqCreate_dimTables],

// Variables

    // dimension table properties
    lstTableNames = rqCreate_dimTables[lstTableNames],
    nlstColumnNames = rqCreate_dimTables[nlstColumnNames],
    lstDistinctNullHandles = rqClean_PurchaseOrders[lstDistinctNullHandles],

    // letter combinations
    lstDoubleLetters = {"aa","bb","cc","dd","ee","ff","gg","hh","ii","jj","kk","ll","mm","nn","oo","pp","qq","rr","ss","tt","uu","vv","ww","xx","yy","zz"},
    lstDropLetters = {"ck","nt","rd","lf"},
    lstLetterCombinations = List.Combine({lstDoubleLetters,lstDropLetters}),

    // other lists
    lstVowels = {"a","e","i","o","u"},
    lstSymbols = {"&","'","!"},
    lstUnits = {"inch","foot","feet","decibel","ounce","count","piece","yard", "wide", "amp","volt"},
    lstUnitReplacements = {"IN","FT","FT","DB","OZ","CT","PC","YD","W","A","V"},
    lstSizes = {"small","medium","large","extra"},
    lstSizeReplacements = {"SM","MED","LG","XTR"},
    nlstWordReplacements = {{"/","F"},{"-"," "}, {" to "," "},{"  "," "}},
    nlstWordReplacementsSizes = {{"/","F"},{"-","D"},{"\"," T "}},

    // null handles
    nlstNullHandles = List.Transform(List.Select(lstDistinctNullHandles, each Value.Type(_) = type text and List.Count(Text.PositionOf(_," ",Occurrence.All)) = 1),each {_,Text.Upper(Text.Combine({Text.Start(_,2),Text.Start(Text.AfterDelimiter(_," "),2)}))}),

// Functions

    // remove 
    rmVowels = (word) => Text.Remove(word,lstVowels),

    // count
    ctLetters = (word) => List.Count(Text.ToList(word)),
    ctWords = (phrase) => List.Count(splitPhrase(phrase)),

    // split
    splitPhrase = (phrase) => Text.Split(phrase," "),
    splitBeforeFirstVowel = (word) => Text.SplitAny(word,"aeiou"){0},

    // clean words
    cleanWords = (word) => 
        let 
        cleanWord = List.Accumulate(nlstWordReplacements, word, (current, replacement) => Text.Remove(Text.Replace(current, replacement{0}, replacement{1}),lstSymbols))
        in
        Text.Proper(cleanWord),
    
    cleanSizes = (word) =>
        let 
        cleanWord = List.Accumulate(nlstWordReplacementsSizes, word, (current, replacement) => Text.Remove(Text.Replace(current, replacement{0}, replacement{1}),lstSymbols))
        in
        Text.Proper(cleanWord),    

    // handle missing data
    handleMissingData = (word) => 
        if List.PositionOf(List.Combine(nlstNullHandles), word) > -1 
        then nlstNullHandles{List.PositionOf(List.Combine(nlstNullHandles), word)/2}{1}
        else word,

    // check
    chkWordLength = (phrase) =>
        let
            lstWords = splitPhrase(phrase),
            nlstLetters = List.Transform(lstWords, each Text.ToList(_)),
            lstLetterCount = List.Transform(nlstLetters, each List.Count(_))
        in
            lstLetterCount,

    chkLetterCombination = (phrase) => 
        let
            lstWords = splitPhrase(phrase),
            WordLetterCombinations =  List.Zip(List.Transform(lstLetterCombinations, (LetterCombination) => List.Transform(lstWords, (words) => Text.Contains(words, LetterCombination))))
        in
            List.AnyTrue(List.Transform(WordLetterCombinations, each List.AnyTrue(_))), 
    
    chkUnits = (phrase) =>
        let
            lstWords = splitPhrase(phrase)
        in 
            List.ContainsAny(lstWords, lstUnits,Comparer.OrdinalIgnoreCase),

    // changelist
    chglstLetterCombinationReplacements = (phrase) => 
        let 
            lstWords = splitPhrase(phrase),
            WordLetterCombinations =  List.Zip(List.Transform(lstLetterCombinations, (LetterCombination) => List.Transform(lstWords, (words) => Text.Contains(words, LetterCombination)))),
            lstListPos = List.Transform(WordLetterCombinations,each List.PositionOf(_, true)),
            WordLetterSelect = List.Transform(lstListPos, each if _ = -1 then _ else lstLetterCombinations{_}),
            WordLetterReplacement = List.Transform(WordLetterSelect, each if _ = -1 then _ else Text.End(_,1)),
            lstReplacements = List.Zip({WordLetterSelect, WordLetterReplacement})
        in    
            List.Accumulate(lstReplacements, lstWords, (current, replacement) => List.Transform(current, each Text.Replace(_, if replacement{0} = -1 then current{List.PositionOf(current,_)} else replacement{0}, if replacement{1} = -1 then current{List.PositionOf(current,_)} else replacement{1}))),
    
    // change
    chgUnits = (phrase) =>
        let
            lstWords = splitPhrase(phrase),
            lstLowercaseWords = List.Transform(lstWords, each Text.Lower(_)),
            lstListPos = List.PositionOf(List.Transform(lstUnits, (units) => Text.Contains(phrase, units, Comparer.OrdinalIgnoreCase)),true),
            lstTextPos = List.PositionOf(lstLowercaseWords,lstUnits{lstListPos})
        in
            Text.Replace(phrase, Text.Proper(lstUnits{lstListPos}), Text.Start(lstWords{lstTextPos},1)),
    
    chgUnits_dimSizes = (phrase) =>
        let
            lstWords = splitPhrase(phrase),
            lstLowercaseWords = List.Transform(lstWords, each Text.Lower(_)),
            Units =  List.Zip(List.Transform(lstUnits, (unit) => List.Transform(lstLowercaseWords, (word) => Text.Contains(word, unit)))),
            lstListPos = List.Transform(Units, each List.PositionOf(_,true)),
            mxlstUnits_ListPosition = List.Transform(lstLowercaseWords, each List.Transform(lstListPos, (position) => if position = -1 then _ else position){List.PositionOf(lstLowercaseWords,_)})
        in
            List.Transform(mxlstUnits_ListPosition, each if Value.Type(_) = type number then lstUnitReplacements{_} else _),

    chgSizes = (phrase as list) =>
        let
            Sizes = List.Transform(phrase, each List.Transform(lstSizes, (size) => Text.Contains(_,size, Comparer.OrdinalIgnoreCase))),
            lstListPos = List.Transform(Sizes, each List.PositionOf(_, true)),
            mxlstSizes_ListPosition = List.Transform(phrase, each List.Transform(lstListPos, (position) => if position = -1 then _ else position){List.PositionOf(phrase,_)})
        in 
            List.Transform(mxlstSizes_ListPosition, each if Value.Type(_) = type number then lstSizeReplacements{_} else _),
           

// Record Query
    create_dimTableIds = [

        lstCreateIdPatternsFX = List.Transform(lstTableNames, each 

    // Category Id
        if Text.Contains(_,"Categories") 
        then {

        // Clean Words
            each cleanWords(_),

        // One Word
            each if ctWords(_) = 1 and _ <> "** Create New Rule **" then (

                // no vowels, less than 3 letters
                if Text.Length(rmVowels(_)) < 3 
                then Text.Upper(Text.Combine({Text.Start(_,2),Text.End(rmVowels(_),1)})) 

                // no vowels, greater than 2 letters
                else if Text.Length(rmVowels(_)) > 2 
                then Text.Upper(Text.Start(rmVowels(_),3)) 

                // create a new rule
                else "** Create New Rule **"
            ) else _,

        // Two Words
            each if ctWords(_) = 2 and _ <> "** Create New Rule **" then (

                // no vowels, greater than 2 letters
                if Text.Length(rmVowels(_)) > 2 
                then Text.Upper(Text.Combine(List.Transform(splitPhrase(_), (word) => if List.PositionOf(splitPhrase(_),word) = 0 then Text.Start(word,1) else Text.Start(rmVowels(word),2))))

                // create new rule
                else "** Create New Rule **"
            ) else _,

        // Three or More Words
            each if ctWords(_) >= 3 and _ <> "** Create New Rule **" then (
                // no vowels, greater than 2 letters
                if Text.Length(rmVowels(_)) > 2 
                then Text.Upper(Text.Combine(List.Transform(splitPhrase(_), each Text.Start(_,1))))

                // create new rule
                else "** Create New Rule **"
            ) else _
        } 

    // Variant Id or Brand Id
        else if Text.Contains(_,"Variant") or Text.Contains(_,"Brand")
        then {

        // Clean Words
            each cleanWords(_),

        // Handle Missing Data
            each handleMissingData(_),

        // One Word
            each if ctWords(_) = 1 then (

                // with vowels, less than 4 letters
                if Text.Length(_) < 5
                then Text.Upper(_)

                // with vowels, greater than 3 letters / no vowels, less than 4 letters
                else if Text.Length(_) > 3 and Text.Length(rmVowels(_)) < 4
                then Text.Upper(Text.Combine({splitBeforeFirstVowel(_),Text.End(_, 4 - Text.Length(splitBeforeFirstVowel(_)))}))

                // no vowels, greater than 5 / no vowels, contains letter combinations
                else if Text.Length(rmVowels(_)) > 4 and chkLetterCombination(rmVowels(_))
                then Text.Combine(List.Transform(chglstLetterCombinationReplacements(rmVowels(_)), each Text.Upper(Text.Start(_,4))))

                // no vowels, 4 letters
                else if Text.Length(rmVowels(_)) = 4
                then Text.Upper(rmVowels(_))

                // no vowels, greater than 4 letters
                else if Text.Length(rmVowels(_)) > 4
                then Text.Upper(Text.Start(rmVowels(_),4))

                // create new rule
                else "** Create New Rule **"

            ) else _,

        // Two Words
            each if ctWords(_) = 2 and _ <> "** Create New Rule **" then (

                // contains units
                if chkUnits(_)
                then Text.Start(Text.Combine(splitPhrase(chgUnits(rmVowels(_)))),4)

                // no vowels, first word < 2, second word > 3 / contain letter combination
                else if chkWordLength(rmVowels(_)){0} < 2 and chkWordLength(rmVowels(_)){1} > 3 and chkLetterCombination(rmVowels(_))
                then Text.Upper(Text.Combine(List.Transform(chglstLetterCombinationReplacements(rmVowels(_)), each if ctLetters(_) < 2 then _ else Text.Start(_,3))))

                // no vowels, first word > 1, second word < 2 / with vowels second word > 1
                else if chkWordLength(rmVowels(_)){0} > 1 and chkWordLength(rmVowels(_)){1} < 2 and chkWordLength(_){1} > 1
                then Text.Upper(Text.Combine(List.Transform(splitPhrase(_), each if ctLetters(rmVowels(_)) > 1 then Text.Start(rmVowels(_),2) else Text.Start(_,2))))

                // no vowels, both words > 1 / contain letter combination
                else if List.AllTrue(List.Transform(chkWordLength(rmVowels(_)), each _ > 1)) and chkLetterCombination(rmVowels(_))
                // then 1
                then Text.Upper(Text.Combine(List.Transform(chglstLetterCombinationReplacements(rmVowels(_)), each Text.Start(_,2))))

                // no vowels, both words > 1
                else if List.AllTrue(List.Transform(splitPhrase(rmVowels(_)), each List.Count(Text.ToList(rmVowels(_))) > 1))
                then Text.Upper(Text.Combine(List.Transform(splitPhrase(rmVowels(_)), (word) => if List.PositionOf(splitPhrase(rmVowels(_)),word) = 0 then Text.Start(word,2) else Text.Start(word,2))))

                // create new rule
                else "** Create New Rule **"
                
            ) else _,

        // Three Words
            each if ctWords(_) = 3 and _ <> "** Create New Rule **" then (

                // contains "SPF"
                if Text.Contains(_,"SPF",Comparer.OrdinalIgnoreCase)
                then Text.Upper(Text.Combine({Text.Start(splitPhrase(rmVowels(_)){0},1),Text.Start(splitPhrase(rmVowels(_)){1},2),Text.Start(splitPhrase(rmVowels(_)){2},1)}))

                // no vowels, 3 words all letters > 1
                else if List.AllTrue(List.Transform(splitPhrase(rmVowels(_)), each List.Count(Text.ToList(rmVowels(_))) > 1))
                then Text.Upper(Text.Combine({Text.Start(splitPhrase(rmVowels(_)){0},1),Text.Start(splitPhrase(rmVowels(_)){1},1),Text.Start(splitPhrase(rmVowels(_)){2},2)}))

                // create new rule
                else "** Create New Rule **"

            ) else _,

        // More than 3 Words
            each if ctWords(_) > 3 and _ <> "** Create New Rule **" then (

                // no vowels, all words > 1 letter
                if List.AllTrue(List.Transform(splitPhrase(rmVowels(_)), each List.Count(Text.ToList(rmVowels(_))) > 0))
                then Text.Start(Text.Upper(Text.Combine(List.Transform(splitPhrase(rmVowels(_)), each Text.Start(_,1)))),4)

                // create new rule
                else "** Create New Rule **"

            ) else _
        }

    // Size Id
        else if Text.Contains(_,"Size")
        then {
        // Clean Words
            each cleanSizes(_),

        // Handle Missing Data
            each handleMissingData(_),

        // Change Units
            each chgUnits_dimSizes(_),

        // Change Sizes
            each chgSizes(_),

        // Combine
            each Text.Upper(Text.Combine(_))
        }
        
        else null),

    // Check for duplicate in Id Columns
        chkDuplicates = (tbl,ColumnGroup as list, posTable) => 
            Table.SelectRows(
                Table.ExpandTableColumn(
                    Table.TransformColumns(
                            Table.Group(tbl,ColumnGroup,{"Duplicates", each _}),
                    {"Duplicates", each Table.AddIndexColumn(Table.Distinct(_),"Duplicate Flag",0,1)}),
                "Duplicates", {"Duplicate Flag"}),
            each _[Duplicate Flag] > 0)
    ]

in

    create_dimTableIds