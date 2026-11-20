/**************************************************************************************
Apex Class Name:  EPUM_LogDataUpdateBatch
Version     : 1.0 
Created Date: 11 Aug 2020
Function    : Class to populate EPUM Log data for successfull contact creation  
User Story : US751665 - IPA: EPUM Dashboard enhancements and UAT readiness
*/

global class EPUM_LogDataUpdateBatch implements Database.Batchable<sObject>,Schedulable { 
    
    /*Fetch the EPUM Log records to process whose EPUM_isContact_Registered__c = false AND EPUM_Origin_Txt__c = 'Invite Sent to Contact' */
    global Database.QueryLocator start(Database.BatchableContext BC){ 
       String strOrgin = 'Invite Sent to Contact'; 
       String query = 'SELECT EPUM_Search_Text__c,Id FROM EPUM_Log__c WHERE EPUM_isContact_Registered__c = false AND EPUM_Origin_Txt__c =: strOrgin'; 
       return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EPUM_Log__c> lstEPUMLog){
        String strRelationCode = 'WORKSFOR';
        String strComplete = 'Complete';
        String strOrgin = 'Contact Registered Successfully';
        String strProject = 'EPUM - Invite';
        String strSeverity = 'Information';
        String strDetails = 'Registration Completed';
        
        Map<String,EPUM_Log__c> mapEPUMLogScope = new Map<String,EPUM_Log__c>(); 
        List<EPUM_Log__c> lstEPUMLogToBeInserted = new List<EPUM_Log__c>();
        List<EPUM_Log__c> lstEPUMLogToBeUpdated = new List<EPUM_Log__c>();
        
        for(EPUM_Log__c log : lstEPUMLog) {
            mapEPUMLogScope.put(log.EPUM_Search_Text__c,log);
        }
        
        for(PRM_Account_Contact_Relationship__c acr : [Select Id, PRM_Contact_Id__r.Email, PRM_Contact_Id__r.OwnerId, LastModifiedDate
                                                       FROM PRM_Account_Contact_Relationship__c 
                                                       WHERE PRM_Contact_Id__r.Email =: mapEPUMLogScope.keySet()
                                                       AND PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c =: strRelationCode 
                                                       AND PRM_Status_Nm__c =: strComplete] ) {
            EPUM_Log__c EpumLog = new EPUM_Log__c();
            EpumLog.EPUM_Details_Dsc__c = strDetails;
            EpumLog.EPUM_Message_Txt__c = strDetails;
            EpumLog.EPUM_Origin_Txt__c = strOrgin;
            EpumLog.EPUM_Project_Txt__c = strProject;
            EpumLog.EPUM_Search_Text__c = acr.PRM_Contact_Id__r.Email;
            EpumLog.EPUM_Severity_Txt__c = strSeverity;
            EpumLog.EPUM_When_Dtm__c = acr.LastModifiedDate;
            EpumLog.OwnerId = acr.PRM_Contact_Id__r.OwnerId;                                     
            lstEPUMLogToBeInserted.add(EpumLog);
        }
        
        if(!lstEPUMLogToBeInserted.isEmpty()){
            Database.SaveResult[] lstSR = Database.insert(lstEPUMLogToBeInserted, false);

            for(Integer i = 0; i < lstSR.size(); i++) {
                if (lstSR[i].isSuccess()) {
                    if(lstEPUMLogToBeInserted[i].EPUM_Search_Text__c != '' && mapEPUMLogScope.containsKey(lstEPUMLogToBeInserted[i].EPUM_Search_Text__c)) {
                        EPUM_Log__c EpumLog = mapEPUMLogScope.get(lstEPUMLogToBeInserted[i].EPUM_Search_Text__c);
                        EpumLog.EPUM_isContact_Registered__c = true;
                        lstEPUMLogToBeUpdated.add(EpumLog);
                    }
                    
                }
            }
            if(!lstEPUMLogToBeUpdated.isEmpty()){
            	Database.update(lstEPUMLogToBeUpdated, false);
        	}
        }
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('Batch completed.');
    }
    
    global void execute(SchedulableContext ctx) 
    {
         EPUM_LogDataUpdateBatch schduleBatch = new EPUM_LogDataUpdateBatch();
         database.executebatch(schduleBatch);
    }
    
}