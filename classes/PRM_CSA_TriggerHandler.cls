/******************************************************************************************************************************
Apex Class Name     :  Core_PRM_CSA_TriggerHandler
Version             : 1.0 
Created Date        : 10 Dec 2018
Function            : Trigger handler for the object Core_PRM_ContactSubscriptionAssociation__c

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Anupam Agarwal      10-Dec-2018                   Overridden the beforeInsert() method 

*********************************************************************************************************************/

public without sharing class PRM_CSA_TriggerHandler extends TriggerHandler{
    //To prevent calling handler class twice
    //Please make use of different variable for before/delete scenarios
    public static boolean firstRun = true;
    public static boolean IPAfirstRun = true;

    public override void beforeInsert(){
        
        if(isActive('Contact_Subscription_Association_Switch')) //Retrieved from Custom labels
        {   
            PRM_CSA_Utility.duplicateRecordCheck(Trigger.new);
        }
    }
    public override void afterInsert() {
        if(isActive('CSA_Insert_ERPM_Integration_Trigger') && firstRun && !System.isBatch()) {            
            System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_ContactSubscriptionAssociation__c>)Trigger.new,  Trigger.new.getSObjectType()));
            firstRun = false;
        }else if(isActive('CSA_Insert_ERPM_Integration_Trigger') && firstRun){
            ContactERPMIntegrationStatusHandler.callableMethod((List<PRM_ContactSubscriptionAssociation__c>)Trigger.new);
            firstRun = false;
        }
    }
    
    public override void beforeUpdate(){
        
        if(isActive('CSA_Before_Update_Trigger')) 
        {   
            PRM_CSA_Utility.updateConSubscription((List<PRM_ContactSubscriptionAssociation__c>)Trigger.new, (Map<id, PRM_ContactSubscriptionAssociation__c>)Trigger.oldMap);
        }
    }
    
    public override void afterUpdate() {       
        if(isActive('CSA_Update_ERPM_Integration_Trigger') && firstRun) {  
            boolean isUpdatedERPM = false;
            for(PRM_ContactSubscriptionAssociation__c newCSA : (List<PRM_ContactSubscriptionAssociation__c>)Trigger.new) {
                PRM_ContactSubscriptionAssociation__c oldCSA = (PRM_ContactSubscriptionAssociation__c)Trigger.oldMap.get(newCSA.Id);
                if(newCSA.PRM_Status_Nm__c != oldCSA.PRM_Status_Nm__c) {
                    isUpdatedERPM = true;
                    break;
                }
            } 
            if(isUpdatedERPM && !System.isBatch())
            {
                System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_ContactSubscriptionAssociation__c>)Trigger.new,  Trigger.new.getSObjectType()));
                firstRun = false;
            }else if(isUpdatedERPM){
                ContactERPMIntegrationStatusHandler.callableMethod((List<PRM_ContactSubscriptionAssociation__c>)Trigger.new);
                firstRun = false;
            }
            
        }
        
         if(isActive('CSA_Update_IPA_Integration_Trigger') && IPAfirstRun) { 
           
            boolean isUpdated = false;
            for(PRM_ContactSubscriptionAssociation__c newCSA : (List<PRM_ContactSubscriptionAssociation__c>)Trigger.new) {
                PRM_ContactSubscriptionAssociation__c oldCSA = (PRM_ContactSubscriptionAssociation__c)Trigger.oldMap.get(newCSA.Id);
                if(newCSA.PRM_Status_Nm__c != oldCSA.PRM_Status_Nm__c) {
                    isUpdated = true;
                    break;
                }
            }            
        }
    }   
}