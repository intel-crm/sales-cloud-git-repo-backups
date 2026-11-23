/*********************************************************************************************************************************
Apex Class Name:  Core_OpportunityPartner
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : Trigger for the object Core_Opportunity_Partner__c
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Nick Krisa                July 7,2015             Original Version
*********************************************************************************************************************************/
trigger Core_OpportunityPartner on Core_Opportunity_Partner__c (after delete, after insert, after update) {
    
    // Get the Trigger Execution variables
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if (!mapFunctionalityNameTriggerExecution.isEmpty()) {
        
        // Conditional entering of the loop based on the type of event
        if (Trigger.isAfter) {
            
            // If the operation is insert
            if (Trigger.isInsert) {
                if (mapFunctionalityNameTriggerExecution.containsKey('opportunityPartnerFactsUpdate') && 
                    mapFunctionalityNameTriggerExecution.get('opportunityPartnerFactsUpdate').Core_Active__c)
                    Core_OpportunityPartnerHandler.opportunityPartnerFactsUpdate(Trigger.New, null);
            }
            // If the operation is update
            else if (Trigger.isUpdate) {
                if (mapFunctionalityNameTriggerExecution.containsKey('opportunityPartnerFactsUpdate') && 
                    mapFunctionalityNameTriggerExecution.get('opportunityPartnerFactsUpdate').Core_Active__c)
                    Core_OpportunityPartnerHandler.opportunityPartnerFactsUpdate(Trigger.New, Trigger.Old);
            }
            // If the operation is delete
            else if (Trigger.isDelete) {
                if (mapFunctionalityNameTriggerExecution.containsKey('opportunityPartnerFactsUpdate') && 
                    mapFunctionalityNameTriggerExecution.get('opportunityPartnerFactsUpdate').Core_Active__c)
                    Core_OpportunityPartnerHandler.opportunityPartnerFactsUpdate(null, Trigger.Old);
            }
        }   
    }
}