/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_PriceBook
Version         : 1.0 
Created Date    : 10/31/2017
Function        : This batch apex is used update the partner price entries with the recent price of products
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran             10/31/2017             Created
*****************************************************************************************************/


global Class Core_Batch_DDR_PriceBook implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to executehttps://intel--crmdevsls3.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
         
        String query = 'SELECT Id, Name, Core_Design_Registration_Eligible_Ind__c, Core_Partner_Visible_Ind__c'+  
                        ' FROM Product2 WHERE isActive = true AND (Core_Design_Registration_Eligible_Ind__c = TRUE'+
                        ' OR Core_Partner_Visible_Ind__c = TRUE)';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Product2> lstProduct2) {
        try {
            Set<String> setPricebookName = new Set<String>();
            Set<Id> setPricebookId = new Set<Id>();
            Set<Id> setProductId = new Set<Id>();

            setPricebookName.add('Partner Price Book');
            setPricebookName.add('Standard Price Book');
            
            List<Pricebook2> lstPriceBook2 = new List<Pricebook2>();
            List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
            
            List<PricebookEntry> lstInsertPricebookEntry = new List<PricebookEntry>();
            List<PricebookEntry> lstUpdatePricebookEntry = new List<PricebookEntry>();
            
            Map<Id, PricebookEntry> mapProductIdStandardPriceBook = new Map<Id, PricebookEntry>();
            Map<Id, PricebookEntry> mapProductIdPartnerPriceBook = new Map<Id, PricebookEntry>();
            
            Id StandardPricebookId;
            Id PartnerPricebookId;
            
            lstPriceBook2 = [SELECT Id, Name FROM Pricebook2];
            
            for(Product2 iProduct2 : lstProduct2) {
                setProductId.add(iProduct2.Id);
            }
            
            for(Pricebook2 iPriceBook2 : lstPriceBook2) {
                setPricebookId.add(iPriceBook2.Id);
                
                if(iPriceBook2.Name == 'Standard Price Book') {
                    StandardPricebookId = iPriceBook2.Id;
                }
                else if(iPriceBook2.Name == 'Partner Price Book') {
                    PartnerPricebookId = iPriceBook2.Id;
                }
            }
            //Query all standard & partner price book entries
            lstPricebookEntry = [SELECT Id, Product2Id, Pricebook2Id, UnitPrice, isActive FROM PricebookEntry WHERE Product2.IsActive = true AND Pricebook2Id IN: setPricebookId];
            
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
            
            lstInsertPricebookEntry = executeLstInsertPricebookEntry(lstProduct2,mapProductIdPartnerPriceBook,mapProductIdStandardPriceBook,lstUpdatePricebookEntry,lstInsertPricebookEntry,PartnerPricebookId);
            // System.debug('lstInsertPricebookEntry-->'+lstInsertPricebookEntry);
        }
        catch(Exception err) {
            // System.debug('NotifyPatnerPriceBookBatchApex::'+err.getMessage());
        }     
    }   

    public List<PricebookEntry> executeLstInsertPricebookEntry(List<Product2> lstProduct2,Map<Id, PricebookEntry> mapProductIdPartnerPriceBook,Map<Id, PricebookEntry> mapProductIdStandardPriceBook,List<PricebookEntry> lstUpdatePricebookEntry,List<PricebookEntry> lstInsertPricebookEntry, Id PartnerPricebookId){
        for(Product2 iProduct2 : lstProduct2) {
            if(mapProductIdPartnerPriceBook.containskey(iProduct2.Id)) { //update the partner pricebook entry for updated price
                PricebookEntry tempPriceBookEntry = new PricebookEntry();
                if(mapProductIdStandardPriceBook.containskey(iProduct2.Id)) {
                    tempPriceBookEntry.Id = mapProductIdPartnerPriceBook.get(iProduct2.Id).Id;
                    tempPriceBookEntry.UseStandardPrice =TRUE;
                    tempPriceBookEntry.isActive = TRUE;
                    tempPriceBookEntry.UnitPrice = mapProductIdStandardPriceBook.get(iProduct2.Id).UnitPrice;
                    lstUpdatePricebookEntry.add(tempPriceBookEntry);
                }
            }
            else { //create the partner pricebook entry for new price
                PricebookEntry tempPriceBookEntry = new PricebookEntry();

                if(mapProductIdStandardPriceBook.containskey(iProduct2.Id)) {
                    tempPriceBookEntry.Product2Id = iProduct2.Id;
                    tempPriceBookEntry.Pricebook2Id = PartnerPricebookId;
                    tempPriceBookEntry.UseStandardPrice =TRUE;
                    tempPriceBookEntry.isActive = TRUE;
                    tempPriceBookEntry.UnitPrice = mapProductIdStandardPriceBook.get(iProduct2.Id).UnitPrice;
                    lstInsertPricebookEntry.add(tempPriceBookEntry);
                }
            }
        }   
    lstInsertPricebookEntry=PricebookInsert(mapProductIdPartnerPriceBook,lstInsertPricebookEntry,lstInsertPricebookEntry);
    return lstInsertPricebookEntry;
    }
     
global List<PricebookEntry> PricebookInsert(Map<Id, PricebookEntry> mapProductIdPartnerPriceBook, List<PricebookEntry> lstUpdatePricebookEntry, List<PricebookEntry> lstInsertPricebookEntry ) {

    List<Product2> lstPartnerPriceBookProducts = [SELECT id, Name, Core_Design_Registration_Eligible_Ind__c, Core_Partner_Visible_Ind__c FROM Product2 WHERE IsActive = true AND ID IN: mapProductIdPartnerPriceBook.KeySet()];
            Map<Id, Boolean> mapProductIdToDesignEligible = new Map<Id, Boolean>();
            Map<Id, Boolean> mapProductIdToPartnerVisible = new Map<Id, Boolean>();
            
            for(Product2 iProd : lstPartnerPriceBookProducts) {    
                mapProductIdToDesignEligible.put(iProd.Id, iProd.Core_Design_Registration_Eligible_Ind__c);
                mapProductIdToPartnerVisible.put(iProd.Id, iProd.Core_Partner_Visible_Ind__c);
            }
            
            for(Id PartnerPricebookProductId : mapProductIdPartnerPriceBook.KeySet()) {
                if(!(mapProductIdToDesignEligible.containskey(PartnerPricebookProductId) && mapProductIdToDesignEligible.get(PartnerPricebookProductId)) && !(mapProductIdToPartnerVisible.containskey(PartnerPricebookProductId) && mapProductIdToPartnerVisible.get(PartnerPricebookProductId))) {
                    //Inactive the existing partner price book entry when the product doesnt available for partner
                    PricebookEntry tempPriceBookEntry = new PricebookEntry();
                    tempPriceBookEntry.isActive = FALSE;
                    tempPriceBookEntry.Id = mapProductIdPartnerPriceBook.get(PartnerPricebookProductId).Id;
                    lstUpdatePricebookEntry.add(tempPriceBookEntry);
                }    
            }
            if(lstUpdatePricebookEntry.size() > 0) {
                update lstUpdatePricebookEntry;   
            }
            
            if(lstInsertPricebookEntry.size() > 0) {
                insert lstInsertPricebookEntry;
            }
            return lstInsertPricebookEntry;
}


    global void finish(Database.BatchableContext BC) {
                // Empty finish method
    }
}