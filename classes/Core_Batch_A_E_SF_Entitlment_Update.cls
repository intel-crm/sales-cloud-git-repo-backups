/**************************************************************************************
Apex Class Name : Core_Batch_A_E_SF_Entitlment_Update
Version     : 1.0 
Created Date: 11th Jan 2024
Description : Batch class for failed salesforce entitlement with 'User record not Available' Error
Test Class  : Core_Batch_A_E_SF_Entitlment_Update_Test
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shreyas[Team Draco]     11th Jan 2024               Original Version
*************************************************************************************/
global without sharing class Core_Batch_A_E_SF_Entitlment_Update implements Database.Batchable<sObject>, Database.Stateful{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){   
        String queryFailedCE = 'SELECT Id, Core_Contact_Id__c, Core_Selected__c, Core_Status__c, Core_Status_of_Assignment_Failure__c, Core_Update_Reason__c  from core_Contact_Entitlement__c WHERE Core_Status_of_Assignment_Failure__c IN (\'Failed Assignment\',\'Failed Removal\') AND Core_Contact_Id__c IN (SELECT ContactId FROM User WHERE Profile.Name = \'Partner\' AND IsActive = TRUE) AND Core_Entitlement_Id__r.Core_Entitlement_Type__c = \'Salesforce\'';   
        return Database.getQueryLocator(queryFailedCE);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Core_Contact_Entitlement__c> lstAllFailedCERecords){
        
        List<Core_Contact_Entitlement__c> EntitlementToUpdate = new List<Core_Contact_Entitlement__c>();
        for(Core_Contact_Entitlement__c contEnt : lstAllFailedCERecords){
            if(contEnt.Core_Status_of_Assignment_Failure__c == 'Failed Assignment'){
                contEnt.Core_Selected__c = True;
                contEnt.Core_Status__c = 'Complete';
                contEnt.Core_Status_of_Assignment_Failure__c = 'Successful Assignment';
                contEnt.Core_Update_Reason__c = '';
                EntitlementToUpdate.add(contEnt);
            }
            if(contEnt.Core_Status_of_Assignment_Failure__c == 'Failed Removal'){
                contEnt.Core_Selected__c = False;
                contEnt.Core_Status__c = 'Complete';
                contEnt.Core_Status_of_Assignment_Failure__c = 'Successful Removal';
                contEnt.Core_Update_Reason__c = '';
                EntitlementToUpdate.add(contEnt);  
            }
        }
        database.update(EntitlementToUpdate, false);	
    }
    
    global void finish(Database.BatchableContext BC){}
}