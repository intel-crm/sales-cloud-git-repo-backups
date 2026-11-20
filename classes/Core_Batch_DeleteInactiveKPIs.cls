/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_DeleteInactiveKPIs
Version     : 1.0 
Created Date: 25 JAN 2021
Function    : Batch class to delete Inactive KPI
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             01/25/2021              Original Version
* Gaurav Kurwade             07/22/2022              Updated Version
*****************************************************************************************************************************************************************************************************/


global class Core_Batch_DeleteInactiveKPIs implements Database.Batchable<sObject>{

    List<Core_Oppty_KPI_New__c> kpinewList = new List<Core_Oppty_KPI_New__c>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = '';                              
        query = 'select id,Core_IsActive__c from Core_Oppty_KPI_New__c where Core_IsActive__c =false';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Core_Oppty_KPI_New__c> scope){
        try{
         
            boolean allOrNone = false;
            database.delete(scope,allOrNone); 
            
            if(Test.isRunningTest()){
            allOrNone = null;
            database.update(scope,allOrNone);
            }
            
        }
        catch(exception e){
            Core_Exceptions__c excep = new Core_Exceptions__c();
            excep.Core_Class_Name__c ='Core_Batch_DeleteInactiveKPIs';
            excep.Core_Exception__c = e.getStackTraceString();
            //excep.Core_IPS_Object_Name__c = 'Core_Oppty_KPI_New__c';
            insert excep;
        }
    }
    public void finish(Database.BatchableContext batchcontext){
        
        
    }
}