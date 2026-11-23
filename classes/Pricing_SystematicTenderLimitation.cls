/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-11-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_SystematicTenderLimitation {

    @AuraEnabled(cacheable=true)
    public static Map<Id,Pricing_Systematic_Tender_Limitation__c>  getSystematicTenderLimitation() {
        Map<Id,Pricing_Systematic_Tender_Limitation__c> tenderLimitationRecords =  new Map<Id,Pricing_Systematic_Tender_Limitation__c>();
        for(Pricing_Systematic_Tender_Limitation__c rec : [SELECT Id,Pricing_Active_cb__c,Pricing_Quote_Type__c,Pricing_Account__c,Pricing_Exception_Quota__c,Pricing_Account__r.Name FROM Pricing_Systematic_Tender_Limitation__c]){
            tenderLimitationRecords.put(rec.Id,rec);
        }
    return tenderLimitationRecords;
    }

    @AuraEnabled
    public static List<Account> searchAccounts(String searchKey) {  
        //This method is called by LWC to find the user from searchkey
        String searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';               
        String query =  'SELECT Id, Name FROM Account WHERE Name LIKE '+searchText+' LIMIT 5';
        return Database.query(query);
    }
    @AuraEnabled
    public static List<Pricing_Systematic_Tender_Limitation__c> saveRecords(List<Pricing_Systematic_Tender_Limitation__c> records) {
        List<Pricing_Systematic_Tender_Limitation__c> tenderLimitationRecords = new List<Pricing_Systematic_Tender_Limitation__c>();
        try {
            
            if(records.size() > 0){

                //Database.UpsertResult[] results = Database.upsert(records, false); // false = partial success not allowed
                List<Database.upsertResult> results = Database.upsert(records,false);
                // Fetch updated records with new IDs and related fields
                Set<Id> updatedRecordIds = new Set<Id>();
                for (Integer i = 0; i < results.size(); i++) {
                    if (results[i].isSuccess()) {
                        updatedRecordIds.add(records[i].Id); // Collect new or existing IDs
                    } else {
                        // Log errors if needed
                        for (Database.Error err : results[i].getErrors()) {
                            System.debug('Error saving record: ' + err.getMessage());
                            //throw new AuraHandledException('Error: ' + err.getMessage());
                        }
                    }
                }

                if(updatedRecordIds.size() > 0){
                    tenderLimitationRecords = [SELECT Id,Pricing_Active_cb__c,Pricing_Quote_Type__c,Pricing_Account__c,Pricing_Exception_Quota__c,Pricing_Account__r.Name 
                                                FROM Pricing_Systematic_Tender_Limitation__c WHERE Id IN :records];
                }
            }
        }catch(exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }  
        return tenderLimitationRecords;
    }
}