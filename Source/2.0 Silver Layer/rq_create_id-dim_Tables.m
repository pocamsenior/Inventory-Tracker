let

// file path definition
rqFilePath = "\\Mac\iCloud\Data Analysis\Projects\Inventory-Tracker\Source\0.0 File Paths\rq-FilePaths.m",
FilePaths = Expression.Evaluate(Text.FromBinary(File.Contents(rqFilePath)),#shared),
rqSilverClean = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[rq_SilverClean])),#shared),
rqSilverCreateDimTables = Expression.Evaluate(Text.FromBinary(File.Contents(FilePaths[rq_SilverCreateDimTables])),#shared),

// variables
lstDoubleLetters = {"aa","bb","cc","dd","ee","ff","gg","hh","ii","jj","kk","ll","mm","nn","oo","pp","qq","rr","ss","tt","uu","vv","ww","xx","yy","zz"},
lstDropLetters = {"ck","nt","rd","lf"},
lstLetterCombinations = List.Combine({lstDoubleLetters,lstDropLetters}),

lstVowels = {"a","e","i","o","u"},
lstSymbols ={"-","&"," "},
lstVowelsSymbols = List.Combine({lstVowels,lstSymbols}),

// Functions

//check word length
chkOneWord = (word) => List.Count(Text.PositionOf(word," ",Occurrence.All)) = 0,
chkTwoWords = (word) => List.Count(Text.PositionOf(word," ",Occurrence.All)) = 1,
chkTwoWordsAmp = (word) => List.Count(Text.PositionOf(word," ",Occurrence.All)) = 2,
chkThreeWords = chkTwoWordsAmp,

// split at character
PositionSpace = (word, position) => Text.SplitAny(word, " "){position},
PositionDash = (word, position) => Text.SplitAny(word, "-"){position},
PositionAmp = (word, position) => Text.SplitAny(word, " & "){position},

LettersBeforeFirstVowel = (word) => Text.SplitAny(word,"aeiou"){0},

// remove characters
rmVowels = (word) => Text.Remove(word,lstVowels),
rmVowelsSymbols = (word) => Text.Remove(word,lstVowelsSymbols),

// text contains vowels
hasVowelsAtBegin = (word) => List.Contains(lstVowels,Text.ToList(word){0},Comparer.OrdinalIgnoreCase),

// single letter combinations
LetterCombinationPosition = (word) => List.PositionOf(List.Transform(lstLetterCombinations, (LetterCombination) => Text.Contains(word, LetterCombination)),true),

// letter combination replacement
chgLetterCombination = (word) => Text.End(lstLetterCombinations{LetterCombinationPosition(word)},1),


// record query
rq = [

fxCreateId = List.Transform(rqSilverCreateDimTables[lstDimTableNames], each 

// Category Id -- 3 letters
if Text.Contains(_,"Categories") 
then {_,

//First Letter Capitalized
each Text.Proper(_),

// One Word

// when vowels are removed, the word length is less than 3
each if chkOneWord(_) and Text.Length(rmVowels(_)) < 3 
then Text.Upper(Text.Combine({Text.Start(_,2),Text.End(rmVowels(_),1)})) 

// when vowels are removed, the word length is greater than or equal to 3
else if chkOneWord(_) and Text.Length(rmVowels(_)) >= 3
then Text.Upper(Text.Start(rmVowels(_),3))

// new rule needs to be created if word doesn't fit any criteria
else if chkOneWord(_)
then "** Create New Rule **"

else _,

// Two Words

// when there is an `&` inbetween the words
each if Text.Contains(_,"&") = true and chkTwoWordsAmp(_)
then Text.Upper(Text.Combine({Text.Start(_,1), Text.Start(rmVowelsSymbols(PositionAmp(_,3)),2)})) 

// when there are two words
else if chkTwoWords(_)
then Text.Upper(Text.Combine({Text.Start(_,1),Text.Start(rmVowels(PositionSpace(_,1)),2)})) 

// new rule needs to be created if word doesn't fit any criteria
else if chkTwoWords(_)
then "** Create New Rule **"

else _,

// Three Words

// when there are three words
each if chkThreeWords(_)
then Text.Upper(Text.Combine({Text.Start(_,1),Text.Start(PositionSpace(_,1),1),Text.Start(PositionSpace(_,2),1)})) 

// new rule needs to be created if word doesn't fit any criteria
else if chkThreeWords(_)
then "** Create New Rule **"

else _} 

// Variant Id -- 2 to 4 letters and numbers
else if Text.Contains(_,"Variant") 
then {_,

//First Letter Capitalized
each Text.Proper(_),

// Not Applicable
each if _ = "Not Applicable" then Text.Upper("NOAP") else _,

// One Word

// word length is less than 4
each if chkOneWord(_) and Text.Length(_) <= 4 
then Text.Upper(_) 

// word length with vowels and symbols is greater than 4 but less than 4 without
else if chkOneWord(_) and Text.Length(_) > 4 and Text.Length(rmVowelsSymbols(_)) < 4 
then Text.Upper(Text.Combine({LettersBeforeFirstVowel(_),Text.End(_, 4 - Text.Length(LettersBeforeFirstVowel(_)))}))

// word length with vowels and symbols is greater than 4 but equal to 4 without
else if chkOneWord(_) and Text.Length(_) > 4 and Text.Length(rmVowelsSymbols(_)) = 4 
then Text.Upper(Text.Combine({Text.Start(_,1),Text.Range(rmVowels(_),1,3)}))

// word length with vowels and symbols is greater than 4, contains a dash, and the words before and after the dash without vowels and symbols are greater than or equal to 2
else if chkOneWord(_) and Text.Length(_) > 4 and Text.Contains(_,"-") and Text.Length(rmVowelsSymbols(PositionDash(_,0))) >= 2 and Text.Length(rmVowelsSymbols(PositionDash(_,1))) >= 2 
then Text.Upper(Text.Combine({Text.Start(rmVowelsSymbols(PositionDash(_,0)),2),Text.Start(rmVowelsSymbols(PositionDash(_,1)),2)}))

// word contains letter combinations
else if chkOneWord(_) and Text.Length(Text.Range(_,1,Text.Length(_)-1)) > 3 and List.AnyTrue(List.Transform(lstLetterCombinations, (LetterCombination) => Text.Contains(_, LetterCombination)))
then Text.Upper(Text.Start(Text.Remove(Text.ReplaceRange(_,Text.PositionOf(_,lstLetterCombinations{LetterCombinationPosition(_)},Occurrence.First,Comparer.OrdinalIgnoreCase),2,chgLetterCombination(_)),lstVowelsSymbols),4))

// word length is greater than 4 without vowels
else if chkOneWord(_) and Text.Length(Text.Range(_,1,Text.Length(_)-1)) > 3
then Text.Upper(Text.Start(rmVowels(_),4))

// new rule needs to be created if word doesn't fit any criteria
else if chkOneWord(_)
then "** Create New Rule **"

else _,

// Two Words

//
each if chkTwoWords(_) 
then _

// new rule needs to be created if word doesn't fit any criteria
else if chkTwoWords(_)
then "** Create New Rule **"

/* 

else _,

// Three Words

//
each if chkThreeWords(_) 
then _

// new rule needs to be created if word doesn't fit any criteria
else if chkThreeWords(_)
then "** Create New Rule **" 

*/

else _

 } 

else null),


// Check for duplicate in Id Columns
fxCheckDuplicates = (Tbl) => Table.SelectRows(Table.ExpandTableColumn(Table.TransformColumns(Table.Group(Tbl,{"Category Id"},{"Duplicates", each _}),{"Duplicates", each Table.AddIndexColumn(_,"Duplicate_Flag",0,1)}),"Duplicates",{"Category","Duplicate_Flag"}),each _[Duplicate_Flag] > 0),

nlstContents = List.Zip({rqSilverCreateDimTables[lstDimTableNames], fxCreateId})



]

in

rq