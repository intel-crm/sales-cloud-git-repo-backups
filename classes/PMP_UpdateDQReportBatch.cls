/****************************************************************************************************************************************
* Class Name  : PMP_UpdateDQReportBatch 
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 22/08/2022            
*****************************************************************************************************************************************/
global class PMP_UpdateDQReportBatch implements Database.Batchable<sObject>{
 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        if(Test.isRunningTest())
        {
            query = 'Select Id,PMP_Status_Nm__c from PMP_Marketplace_DQ_Monitor__c';
        }
        else
        {
            query = 'Select Id,PMP_Status_Nm__c from PMP_Marketplace_DQ_Monitor__c where LastModifiedDate!=today and PMP_Status_Nm__c!=\'Closed\' and PMP_External_Key__c!=null';
        }      
        return Database.getQueryLocator(query);   
    }
    
    global void execute(Database.BatchableContext bc, List<PMP_Marketplace_DQ_Monitor__c> scope){
        if(scope !=null)
        {
            for(PMP_Marketplace_DQ_Monitor__c dqRec : scope)
            {       
                dqRec.PMP_Status_Nm__c ='Closed';
            }
            try
            {
                update scope;
            }
            catch(Exception e) 
            {
                PMP_Utility.logError(e,'PMP_UpdateDQReportBatch');
            }
        }
    }   
    
    global void finish(Database.BatchableContext bc){
       PMP_GenerateDQReportUtility.sendDQReportEmail();      
    }
    
}