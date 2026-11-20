global without sharing class Core_Batch_Update_FC_Product_Schedule implements Database.Batchable<sObject> {
    public list<Id> oppProductIds = new list<id>();
    global Core_Batch_Update_FC_Product_Schedule(list<id> oppProductIdList ){
        this.oppProductIds =oppProductIdList;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'select id ,name,Core_Opp_Line_Item_RecordID__c,Core_FC_Opportunity_Product__c,Core_Is_Post_Win__c from Core_Opp_FC_Prod_Schedule__c where Core_FC_Opportunity_Product__c = null and (Core_Opp_Line_Item_RecordID__c != null and Core_Opp_Line_Item_RecordID__c IN:oppProductIds) and Core_Is_Post_Win__c = false';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Core_Opp_FC_Prod_Schedule__c> scope)
    {
        Database.DeleteResult[] drList = null;
        List<Core_Log_Entry__c> failedData = new List<Core_Log_Entry__c>();
        if (!scope.isempty()){
            
            drList = Database.delete(scope,false);
            
            if(!drList.isEmpty()){
                for (Database.DeleteResult dr : drList) {
                    if (!dr.isSuccess()) {
                        for (Database.Error e  : dr.getErrors()) {	                    
                            failedData.add(new Core_Log_Entry__c(Core_Details__c = e.getMessage() , Core_Message__c = 'Error from  Core_Batch_Update_FC_Product_Schedule class', Core_Severity__c = 'Info', Core_Origin__c = 'Core_Batch_Update_FC_Product_Schedule', Core_When__c = System.now()));
                        }
                    }
                }
                
                if(!failedData.isEmpty()){
                    Insert failedData ;
                }
                
            }
            
        }
    }
    global void finish(Database.BatchableContext bc) {
        
    }
}