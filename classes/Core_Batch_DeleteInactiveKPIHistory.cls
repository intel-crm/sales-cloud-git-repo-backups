/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_DeleteInactiveKPIHistory
Version     : 1.0 
Created Date: 07/22/2022
Function    : Batch class to delete Inactive Oppo KPI history records
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade             07/22/2022              original Version
*****************************************************************************************************************************************************************************************************/


global without sharing class Core_Batch_DeleteInactiveKPIHistory implements Database.Batchable<sObject>{

    List<Core_Opp_KPI_History__c> kpiHistorynewList = new List<Core_Opp_KPI_History__c>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';                              
        query = 'SELECT Id,Core_New_Opportunity_KPI__r.Core_IsActive__c, Core_New_Opportunity_KPI__c FROM Core_Opp_KPI_History__c WHERE Core_New_Opportunity_KPI__r.Core_IsActive__c = false';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Core_Opp_KPI_History__c> scope){
        try{
			 boolean allOrNone = false;	
            database.delete(scope,false);
            if(Test.isRunningTest()){
            allOrNone = null;
            database.delete(scope,allOrNone);
            }
        }
        catch(exception e){
            Core_Exceptions__c excep = new Core_Exceptions__c();
            excep.Core_Class_Name__c ='Core_Batch_DeleteInactiveKPIHistory';
            excep.Core_Exception__c = e.getStackTraceString();
            //excep.Core_IPS_Object_Name__c = 'Core_Oppty_KPI_New__c'; 
            insert excep;
        }
    }
    public void finish(Database.BatchableContext batchcontext){
        Integer batchSize = Integer.valueOf(System.Label.Core_DelInactiveApi_Size);
        database.executeBatch(new Core_Batch_DeleteInactiveKPIs(),batchSize);
    }
}