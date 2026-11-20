/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_OpportunityKPIFinalProcess
Version     : 1.0 
Created Date: 6 DEC 2021
Function    : Batch to create new KPIs from Azure
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             12/06/2021              Original Version

*****************************************************************************************************************************************************************************************************/
global class Core_Batch_OpportunityKPIFinalProcess implements Database.Batchable<sObject>,Database.stateful{
    global Database.QueryLocator start(Database.BatchableContext bc) {
                                
        String query = 'select id,Core_Is_KPI_Refresh__c,Core_Is_KPI_Failed__c from opportunity where Core_Is_KPI_Refresh__c=true or Core_Is_KPI_Failed__c = true';

        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<opportunity> newRec){
        List<opportunity> fList = new List<opportunity>();
        for(opportunity o : newRec){
            opportunity obj = new opportunity();
            obj.id = o.id;
            obj.Core_Is_KPI_Refresh__c = false;
            obj.Core_Is_KPI_Failed__c = false;
            obj.Core_Last_KPI_Update__c = system.now();
            fList.add(obj);
        }
        Database.update(fList,false);
    }
    
    global void finish(Database.BatchableContext batchcontext){
        List<Core_KPI_FullRefresh_Check__c> csList = new List<Core_KPI_FullRefresh_Check__c>();
        Core_KPI_FullRefresh_Check__c csUser = Core_KPI_FullRefresh_Check__c.getInstance();
        Core_KPI_FullRefresh_Check__c csOrg = Core_KPI_FullRefresh_Check__c.getOrgDefaults();
        //system.debug('cs='+cs.IsFullRefresh__c);
        csOrg.IsFullRefresh__c = false;
        csUser.IsFullRefresh__c = false;
        csList.add(csOrg);
        csList.add(csUser);
        if(!Test.isRunningTest()){
            update csList; 
        }
        
    }
}