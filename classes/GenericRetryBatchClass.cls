/******************************************************************************************************
 * Class Name  : GenericRetryBatchClass
 * Version     : 1.0
 * Created Date: 01-30-2020
 * Modification Log :
 * Developer            Date               Description
 * -----------------------------------------------------------------------------------------------------
 * Accenture - JV      01/30/2020          Batchable class to Handle the Retry Logic Of All the Batch Classes
 *******************************************************************************************************/
public without sharing class GenericRetryBatchClass implements Database.Batchable<sObject>,Database.Stateful,Database.RaisesPlatformEvents  {
    
    private List<Core_MDF_Batch_Apex_Error_Log__c> errorLogList;
    
    /*public GenericRetryBatchClass() {
        
    }*/
    
    // Constructor called from Core_MDF_SubmitLogForRetry
    public GenericRetryBatchClass(List<Core_MDF_Batch_Apex_Error_Log__c> jobScopes) {
        this.errorLogList = jobScopes;
    }
	
    /*****************************************************************************************************
	   Method Name :   start
	   @return     :   List of Core_MDF_Batch_Apex_Error_Log__c records
	   @parameters :   Database.BatchableContext
	   Description :   It returns a List of Core_MDF_Batch_Apex_Error_Log__c records
	   Added By    :   Accenture - VK - 01/30/2020 
	   Modified By :                               Date:                   Changes:
	 ******************************************************************************************************/
    public List<Core_MDF_Batch_Apex_Error_Log__c> start(Database.BatchableContext bc) {
        return errorLogList;
    }

    /********************************************************************************************************
	   Method Name :   execute
	   @return     :   void
	   @parameters :   Database.BatchableContext, List<Core_MDF_Batch_Apex_Error_Log__c>
	   Description :   Calls the respective batch class for retry of failed scope from the Log record
	   Added By    :   Accenture - VK - 01/30/2020 
	   Modified By :                               Date:         Changes:
	 **********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Core_MDF_Batch_Apex_Error_Log__c> scope) {
		        
        for (Core_MDF_Batch_Apex_Error_Log__c errorLog : scope) {
            
            //List of Ids failed in a batch
            List<Id> scopeErrorIds = errorLog.Core_MDF_Scope_txt__c.split(',');
            
            SObjectType sObjectType = scopeErrorIds[0].getSobjectType();
            
            List<SObject> retryScope = new List<SObject>();
            
            for(Id errorId : scopeErrorIds) {
                retryScope.add(sObjectType.newSObject(errorId));
            }
			System.debug('retryScope---'+retryScope[0]);
            Type apexJobClassType = Type.forName(errorLog.Core_MDF_Apex_Class_txt__c);
            
            Database.Batchable<SObject> batchJob = (Database.Batchable<SObject>) apexJobClassType.newInstance();
            
            if(errorLog.Core_MDF_Apex_Class_txt__c == 'Core_MDF_CreateBatchShareRecordsInternal'){
                Core_MDF_CreateBatchShareRecordsInternal.isRetry = TRUE;
                batchJob.execute(bc,retryScope);
            }
            else{
                batchJob.execute(bc,retryScope);
            }
            
        }

    }
	
    /*****************************************************************************************************
	   Method Name :   finish
	   @return     :   void
	   @parameters :   Database.BatchableContext
	   Description :
	   Added By    :   Accenture - VK - 01/30/2020
	   Modified By :                               Date:                     Changes:None
	 ******************************************************************************************************/
    public void finish(Database.BatchableContext bc) {
        
    }
}