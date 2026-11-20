public class Core_MDF_Batch_PNUMRefresh implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bContext) {
         //Jahnavi K -- Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
        String query = 'SELECT Id FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Error_Details_txt__c != null AND (Core_MDF_User__r.IsActive = true or Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE) LIMIT 200';
        return Database.getQueryLocator(String.escapeSingleQuotes(query)); 
    }
    
    public void execute(Database.BatchableContext bContext, List<Core_MDF_Partner_Node_User_Mapping__c> pnumList) {       
        try{
            
            if(!pnumList.isEmpty()){
                Database.SaveResult[] updateResults = Database.update(pnumList, false);
                List<Id> recordIds = new List<Id>();                
                for (Core_MDF_Partner_Node_User_Mapping__c pnum : pnumList) {
                    recordIds.add(pnum.Id);
                }
                List<String> failedRecordDetails = Core_MDF_CCP_UtilityClass.collectDmlFailureDetails(recordIds, updateResults);

                if(!failedRecordDetails.isEmpty()){
                    Core_MDF_CCP_UtilityClass.logErrorinLogObject('Core_MDF_Batch_PNUMRefresh partial update failures: ' + String.join(failedRecordDetails, ' | '), 'Class.Core_MDF_Batch_PNUMRefresh.execute');
                }
            }
        }catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    public void finish(Database.BatchableContext bContext) {
       
    }
}