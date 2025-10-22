/* 
===================================================
Record Query - Objects
===================================================
# Script Definition
This script allows for a dynamic navigation through the project using external .m files.

# User Actions
## In Script
Define your folder and file paths in this script.

## In Power Query
Define your file paths to the `rq_Objects` file in the `0.0 Object Queries` folder with the variables `usb`, `mac`, `pc`. 
===================================================
*/

let 
// Storage Definition
    usb = "D:\Inventory-Tracker\",
    pc = "Y:\Data Analysis\Projects\Inventory-Tracker\",
    mac = "\\Mac\iCloud\Data Analysis\Projects\Inventory-Tracker\",

// File Definition
    BaseFolder = "Inventory-Tracker\",
    RawDataFolder = "Data\0.0 Raw\",
    RecordQueriesFolder = "Source\0.1 Record Queries\",
    CheckQueriesFolder = "Source\0.2 Check Queries\",
    BronzeLayerFolder ="Source\1.0 Bronze Layer\",
    SilverLayerFolder = "Source\2.0 Silver Layer\",

// Evaluation Formulas
    evalFile = (file) => 
        Expression.Evaluate(Text.FromBinary(File.Contents(file)),#shared),
    evalFolder = (folder) => Folder.Contents(folder),

// Record Query
    Objects = (path) =>
        [

        // raw files
            rawCSV_Files = evalFolder(Text.Combine({path, RawDataFolder,"Purchase Orders"})),

        // record queries
            rqClean_PurchaseOrders = evalFile(Text.Combine({path,RecordQueriesFolder,"clean_PurchaseOrders.m"})),
            rqCreate_dimTables = evalFile(Text.Combine({path,RecordQueriesFolder,"create_dimTables.m"})),
            rqCreate_dimTableIds = evalFile(Text.Combine({path,RecordQueriesFolder,"create_dimTableIds.m"})),

        // check queries
            chkNulls_PurchaseOrders = evalFile(Text.Combine({path, CheckQueriesFolder,"nulls_PurchaseOrders.m"})),
            chkDuplicateIds_dimCategories = evalFile(Text.Combine({path, CheckQueriesFolder,"duplicateIds_dimCategories.m"})),
            chkDuplicateIds_dimVariants = evalFile(Text.Combine({path, CheckQueriesFolder,"duplicateIds_dimVariants.m"})),
            chkDuplicateIds_dimBrands = evalFile(Text.Combine({path, CheckQueriesFolder,"duplicateIds_dimBrands.m"})),

        // bronze tables
            brzBinary_PurchaseOrders = evalFile(Text.Combine({path, BronzeLayerFolder,"binary_PurchaseOrders.m"})),
            brzCombined_PurchaseOrders = evalFile(Text.Combine({path, BronzeLayerFolder,"combined_PurchaseOrders.m"})),

        // silver tables
            slvCleaned_PurchaseOrders = evalFile(Text.Combine({path,SilverLayerFolder,"cleaned_PurchaseOrders.m"})),
            slvCleaned_dimCategories = evalFile(Text.Combine({path,SilverLayerFolder,"cleaned_dimCategories.m"})),
            slvCleaned_dimVariants = evalFile(Text.Combine({path,SilverLayerFolder,"cleaned_dimVariants.m"})),
            slvCleaned_dimBrands = evalFile(Text.Combine({path,SilverLayerFolder,"cleaned_dimBrands.m"})),
            slvCleaned_dimSizes = evalFile(Text.Combine({path,SilverLayerFolder,"cleaned_dimSizes.m"}))
        ]
    
in 

    Objects(usb)