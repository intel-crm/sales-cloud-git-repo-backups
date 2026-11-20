/****************************************************************************************************
Apex Class Name : SWS_LeadHandler
Version         : 1.0 
Test Class		: SWS_LeadHandlerTest
Created Date    : 2024-08-23 
Function        : Handles the SWS Lead Trigger Operations.
Modifications   :
*****************************************************************************************************
* Developer                   			Date                   Description
* ----------------------------------------------------------------------------                 
* Naveen Muthuramalingam              2024-08-23                Created
* Bishal Singh                        2024-08-26                Modified
*****************************************************************************************************/
public without sharing class SWS_LeadHandler {
    
    /************************************************************************************************************
    *Method Name : beforeInsertUpdateOperations
    *Created Date: 08/23/2024
    *Author      : Naveen Muthuramalingam    
    *Description : Performs operations on before context of trigger.
    ************************************************************************************************************/
    public static void beforeInsertUpdateOperations(List<Lead> leadList,Map<Id,Lead> oldMap) {
        Set<String> newLeadEmails = new Set<String>();
        for (Lead nl : leadList) {
            if(nl.SWS_Lead_Source_System__c != null && nl.SWS_Lead_Source_System__c.contains('HubSpot') && nl.Core_Product_Interest__c != null){
                newLeadEmails.add(nl.Email);    
            }
        }
        List<Lead> existingLeads = [SELECT Email,Core_Product_Interest__c FROM Lead WHERE Email IN :newLeadEmails AND Core_Product_Interest__c != null AND SWS_Software_Lead__c = true];
        if(!existingLeads.isEmpty()){
            Map<String, List<Lead>> existingLeadMap = createExistingLeadMap(existingLeads) ;
            for (Lead nl : leadList) {
                if(existingLeadMap.containsKey(nl.Email) && !existingLeadMap.get(nl.Email).isEmpty()){
                    validateProductInterests(nl, existingLeadMap.get(nl.Email));
                }
            }
        }
    }
    
    private static Map<String, List<Lead>> createExistingLeadMap(List<Lead> existingLeads) {
        Map<String, List<Lead>> existingLeadMap = new Map<String, List<Lead>>();
        for (Lead ex : existingLeads) {
            if (!existingLeadMap.containsKey(ex.Email)) {
                existingLeadMap.put(ex.Email, new List<Lead>());
            } 
            existingLeadMap.get(ex.Email).add(ex);
        }
        return existingLeadMap;
    }
    
    private static void validateProductInterests(Lead newLead, List<Lead> existingLeads) {
        for (Lead ex : existingLeads) {
            if (ex.Core_Product_Interest__c.contains(newLead.Core_Product_Interest__c)) {
                String errorMessage = SWS_Core_CRM_Labels__c.getValues('DuplicateLeadError')?.SWS_Value__c + ' ' + ex.Id;
                newLead.addError(errorMessage);
            }
        }
    }
}