/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_PriceBook_Add
Version         : 1.0 
Created Date    : 01/10/2018
Function        : This batch apex is used update the partner price entries with the recent price of products
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran              01/10/2018            Created
*****************************************************************************************************/
global Class Core_Batch_DDR_PriceBook_Add implements Database.Batchable<sObject> {
    //To get the log switch details 
    public static final Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
    public static final String PARTNER_PRICE_BOOK_NAME = 'Partner Price Book';
    public static final String STANDARD_PRICE_BOOK_NAME = 'Standard Price Book';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, Name, Core_Product_Series__c, Core_Design_Registration_Eligible_Ind__c, Core_Partner_Visible_Ind__c FROM Product2 '+
                        'WHERE IsActive = true AND Core_Sales_Visible_Flag__c = true '+ 
                        'AND (Core_Design_Registration_Eligible_Ind__c = TRUE OR Core_Partner_Visible_Ind__c = TRUE) '+
                        'AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE IsActive = true AND Pricebook2.Name = \''+STANDARD_PRICE_BOOK_NAME+'\')'+
                        //'AND Id NOT IN (SELECT Product2Id FROM PricebookEntry WHERE IsActive = true AND Pricebook2.Name = \''+PARTNER_PRICE_BOOK_NAME+'\')';
                        'AND Id NOT IN (SELECT Core_Design_Product_Id__c FROM Core_Design_Registration_Product_List__c where Core_Active_Ind__c = TRUE)';
        
        return Database.getQueryLocator(query);
    }
     /*execute class*/
    global void execute(Database.BatchableContext BC, List<Product2> lstProduct2) {
        try {
            Set<Id> setPricebookId = new Set<Id>();
            Set<Id> setProductId = new Set<Id>();
            List<Pricebook2> lstPriceBook2 = new List<Pricebook2>();
            List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
            List<Core_Design_Registration_Product_List__c> lstDesignProdList = new List<Core_Design_Registration_Product_List__c>();
            List<PricebookEntry> lstUpsertPricebookEntry = new List<PricebookEntry>();            
            List<Core_Design_Registration_Product_List__c> lstUpsertDesignProdList = new List<Core_Design_Registration_Product_List__c>();
            Map<Id, PricebookEntry> mapProductIdStandardPriceBook = new Map<Id, PricebookEntry>();
            Map<Id, PricebookEntry> mapProductIdPartnerPriceBook = new Map<Id, PricebookEntry>();
            Map<Id, Core_Design_Registration_Product_List__c> mapProductIdDesignProdList = new Map<Id, Core_Design_Registration_Product_List__c>();
            
            Id StandardPricebookId;
            Id PartnerPricebookId;

            lstPriceBook2 = [SELECT Id, Name FROM Pricebook2 WHERE Name =: STANDARD_PRICE_BOOK_NAME OR Name=:PARTNER_PRICE_BOOK_NAME];
            for(Product2 iProduct2 : lstProduct2) {
                setProductId.add(iProduct2.Id);
            }
            for(Pricebook2 iPriceBook2 : lstPriceBook2) {
                setPricebookId.add(iPriceBook2.Id);
                if(iPriceBook2.Name == STANDARD_PRICE_BOOK_NAME) {
                    StandardPricebookId = iPriceBook2.Id;
                }
                else if(iPriceBook2.Name == PARTNER_PRICE_BOOK_NAME) {
                    PartnerPricebookId = iPriceBook2.Id;
                }
            }
            //Query all standard & partner price book entries
            lstPricebookEntry = [SELECT Id, Product2Id, Pricebook2Id, UnitPrice, isActive FROM PricebookEntry WHERE Product2.Id IN: setProductId];
            lstDesignProdList = [SELECT Id, Name,Core_Design_Product_Id__c FROM Core_Design_Registration_Product_List__c WHERE Core_Design_Product_Id__c IN: setProductId];
            //Create maps to product id to their respective pricebook
            for(PricebookEntry iPriceBookEntry : lstPricebookEntry) {
                Map<Id, Id> MapPriceBookEntryIdToPriceBookId = new Map<Id, Id>();
                MapPriceBookEntryIdToPriceBookId.put(iPriceBookEntry.Id, iPriceBookEntry.Pricebook2Id);
                
                if(iPriceBookEntry.Pricebook2Id == PartnerPricebookId) {
                    mapProductIdPartnerPriceBook.put(iPriceBookEntry.Product2Id, iPriceBookEntry);
                }
                else if(iPriceBookEntry.Pricebook2Id == StandardPricebookId) {
                    mapProductIdStandardPriceBook.put(iPriceBookEntry.Product2Id, iPriceBookEntry);
                }
            }
            for(Core_Design_Registration_Product_List__c iDesignProdList : lstDesignProdList) {
                mapProductIdDesignProdList.put(iDesignProdList.Core_Design_Product_Id__c, iDesignProdList);    
            }
            for(Product2 iProduct2 : lstProduct2) {
                lstUpsertPricebookEntry=pricebookEntryInsert(iProduct2,mapProductIdStandardPriceBook,mapProductIdPartnerPriceBook,PartnerPricebookId);
                lstUpsertDesignProdList=designProdInsert(iProduct2,mapProductIdDesignProdList); //Adding the products to design product list
            }
            updateList(lstUpsertPricebookEntry,lstUpsertDesignProdList);
        }
        catch(Exception err) {
            //System.debug('NotifyPatnerPriceBookBatchApex::'+err.getMessage());
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c) {   
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = 'Error:'+err.getMessage(),Core_Details__c = 'Line number: ' + err.getLineNumber()+', Stack trace: ' + err.getStackTraceString(), Core_Origin__c='Core_Batch_DDR_PriceBook_Add', Core_Severity__c='High', Core_When__c = System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = '');
                insert ExcepLog;
            }                     
        }
    }
        /*Upsert the pricebook  and design product list*/

    global void updateList(List<PricebookEntry> lstUpsertPricebookEntry,List<Core_Design_Registration_Product_List__c> lstUpsertDesignProdList) {

    if(lstUpsertPricebookEntry.size() > 0) {
        upsert lstUpsertPricebookEntry;   
    }
    if(lstUpsertDesignProdList.size() > 0) {   //Upsert Design Product List 
        upsert lstUpsertDesignProdList;   
    }
}

    /*return the pricebook entry list*/
global List<PricebookEntry> pricebookEntryInsert(Product2 iProduct2,Map<Id, PricebookEntry> mapProductIdStandardPriceBook,Map<Id, PricebookEntry> mapProductIdPartnerPriceBook, Id PartnerPricebookId) {
    
    List<PricebookEntry> lstUpsertPricebookEntry = new List<PricebookEntry>();            

    if(mapProductIdPartnerPriceBook.containskey(iProduct2.Id)) {   //update the partner pricebook entry for updated price
        PricebookEntry tempPriceBookEntry = new PricebookEntry();
        
        if(mapProductIdStandardPriceBook.containskey(iProduct2.Id)) {
            tempPriceBookEntry.Id = mapProductIdPartnerPriceBook.get(iProduct2.Id).Id;
            tempPriceBookEntry=pricebookAddList(tempPriceBookEntry,iProduct2,mapProductIdStandardPriceBook);
            lstUpsertPricebookEntry.add(tempPriceBookEntry);  
        }
    }
    else {   //create the partner pricebook entry for new price
        PricebookEntry tempPriceBookEntry = new PricebookEntry();
        
        if(mapProductIdStandardPriceBook.containskey(iProduct2.Id)) {
            tempPriceBookEntry.Product2Id = iProduct2.Id;
            tempPriceBookEntry.Pricebook2Id = PartnerPricebookId;
            tempPriceBookEntry=pricebookAddList(tempPriceBookEntry,iProduct2,mapProductIdStandardPriceBook);
            lstUpsertPricebookEntry.add(tempPriceBookEntry);
        }
    }
    return lstUpsertPricebookEntry;
}
/*Adding the products to design product list*/
 global List<Core_Design_Registration_Product_List__c> designProdInsert(Product2 iProduct2, Map<Id, Core_Design_Registration_Product_List__c> mapProductIdDesignProdList) {
    
    List<Core_Design_Registration_Product_List__c> lstUpsertDesignProdList = new List<Core_Design_Registration_Product_List__c>();
    if(mapProductIdDesignProdList.containsKey(iProduct2.Id)) {
    Core_Design_Registration_Product_List__c tempDesignProdList = new Core_Design_Registration_Product_List__c();
    tempDesignProdList.Id = mapProductIdDesignProdList.get(iProduct2.Id).Id;
    tempDesignProdList=productAddList(tempDesignProdList,iProduct2);
    lstUpsertDesignProdList.add(tempDesignProdList);                
    }
    else {
    Core_Design_Registration_Product_List__c tempDesignProdList = new Core_Design_Registration_Product_List__c();
    tempDesignProdList=productAddList(tempDesignProdList,iProduct2);
    lstUpsertDesignProdList.add(tempDesignProdList);                
    }
    return lstUpsertDesignProdList;
 }

    /* returning the product list*/
    global Core_Design_Registration_Product_List__c productAddList( Core_Design_Registration_Product_List__c tempDesignProdList,Product2 iProduct2  ) {
        
        tempDesignProdList.Core_Design_Product_Id__c = iProduct2.Id;
        tempDesignProdList.Core_Design_Product_Nm__c = iProduct2.Name;
        tempDesignProdList.Core_Active_Ind__c = TRUE;
        return tempDesignProdList;
    }
        /* returning the pricebook list*/
    global PricebookEntry pricebookAddList( PricebookEntry tempPriceBookEntry,Product2 iProduct2,Map<Id, PricebookEntry> mapProductIdStandardPriceBook  ) {
       
        tempPriceBookEntry.UseStandardPrice =TRUE;
        tempPriceBookEntry.isActive = TRUE;
        tempPriceBookEntry.UnitPrice = mapProductIdStandardPriceBook.get(iProduct2.Id).UnitPrice;
        return tempPriceBookEntry;
    }


     
    global void finish(Database.BatchableContext BC) {
        // Empty finish method
    }
}