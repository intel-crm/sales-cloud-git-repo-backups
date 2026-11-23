/**************************************************************************************
Apex Class Name : Core_Batch_Internal_Entitlement_Update
Version     : 1.0 
Created Date: 11th Jan 2024
Description : Batch class for failed salesforce entitlement with 'User record not Available' Error
Test Class  : Core_Batch_Int_Entitlement_Update_Test
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shreyas[Team Draco]     11th Jan 2024               Original Version
*************************************************************************************/
global without sharing class Core_Batch_Internal_Entitlement_Update implements Database.Batchable<sObject>, Database.Stateful{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){   
        String queryFailedCE = 'SELECT Id, Core_Contact_Id__c, Core_Selected__c, Core_Status__c, Core_Status_of_Assignment_Failure__c, Core_Update_Reason__c  FROM core_Contact_Entitlement__c WHERE Core_Status_of_Assignment_Failure__c IN (\'Failed Assignment\',\'Failed Removal\') AND Core_Contact_Id__c IN (SELECT ContactId FROM User WHERE Profile.Name = \'Partner\' AND IsActive = TRUE) AND Core_Entitlement_Id__r.Core_Entitlement_Type__c = \'Salesforce\'';   
        return Database.getQueryLocator(queryFailedCE); 
    }
    
    global void execute(Database.BatchableContext BC, List<Core_Contact_Entitlement__c> lstAllFailedCERecords){
        Set<Id> contactIds = new Set<Id>();
        List<Contact> contactToUpdate = new List<Contact>();
        List<Core_Contact_Entitlement__c> EntitlementToUpdate = new List<Core_Contact_Entitlement__c>();
        for(Core_Contact_Entitlement__c contEnt : lstAllFailedCERecords){
            if(contEnt.Core_Status_of_Assignment_Failure__c == 'Failed Assignment'){
                contEnt.Core_Selected__c = true;
                contEnt.Core_Status__c = 'Complete';
                contEnt.Core_Status_of_Assignment_Failure__c = 'Successful Assignment';
                contEnt.Core_Update_Reason__c = '';
                EntitlementToUpdate.add(contEnt);
                contactIds.add(contEnt.Core_Contact_Id__c);
            }
            if(contEnt.Core_Status_of_Assignment_Failure__c == 'Failed Removal'){
                contEnt.Core_Selected__c = false;
                contEnt.Core_Status__c = 'Complete';
                contEnt.Core_Status_of_Assignment_Failure__c = 'Successful Removal';
                contEnt.Core_Update_Reason__c = '';
                EntitlementToUpdate.add(contEnt);  
            }
        }
        
        // Update the Partner Portal Entitlement to TRUE-Complete if the Active User Record is already present for these Internal Entitlements and yet the PP is Pending
        for(Core_Contact_Entitlement__c  partnerPortalCE : [SELECT Id FROM Core_Contact_Entitlement__c WHERE Core_Entitlement_Id__r.Core_Display_Name__c = 'Partner Portal' AND Core_Contact_Id__c IN :contactIds AND Core_Status__c = 'Pending']){
            partnerPortalCE.Core_Selected__c = true;
            partnerPortalCE.Core_Status__c = 'Complete';
            partnerPortalCE.Core_Status_of_Assignment_Failure__c = 'Successful Assignment';
            partnerPortalCE.Core_Update_Reason__c = '';
            EntitlementToUpdate.add(partnerPortalCE);
        }

        for(Id conId : contactIds){
            contactToUpdate.add(new Contact(Id = conId, Core_AGS_Integration_Status__c = 'Successful', Core_AGS_Integration_Message__c = 'Timestamp: ' + System.now() + ' GMT')); 
        }

        Database.update(EntitlementToUpdate, false);
        
        Database.update(contactToUpdate, false);
    }
    
    global void finish(Database.BatchableContext BC){}
}