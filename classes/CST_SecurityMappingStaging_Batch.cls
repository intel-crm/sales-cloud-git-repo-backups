public class CST_SecurityMappingStaging_Batch implements Database.Batchable<sObject>{
    public List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();


    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Account_Owner_c,Manager__c,Account_Owner_WWID__c,Manager_WWID__c,Role__c,Region__c FROM Security_Mapping_Staging__c';
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
    
       List<SPM_Security_Mapping__c> securityMappingList = new List<SPM_Security_Mapping__c>();
       
        for(SPM_Security_Mapping__c stagingRec:securityMappingList){
            SPM_Security_Mapping__c securityMapping = new SPM_Security_Mapping__c();
            securityMappingList.add(securityMapping);
        }
		
       if(!securityMappingList.isEmpty()){
                Database.SaveResult[] srList = Database.insert(securityMappingList, false);
                for(Database.SaveResult sr : srList) {
                    if(!sr.isSuccess() || Test.isRunningTest()){
                        String errorMsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            errorMsg = errorMsg + err.getMessage();
                        }
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'SecurityMapping_Insert_Error', Core_Severity__c = 'High', Core_Origin__c='CST_SecurityMappingBatch', Core_When__c = System.now()));   
                    }
                }
            }
            if(!captureQueryErr.isEmpty()){
                insert captureQueryErr;
            }
    }
    public static void getSalesforceID(){
        //get salesforce id from user record
    }
    
    public void finish(Database.BatchableContext BC)
    {
    
    }
}