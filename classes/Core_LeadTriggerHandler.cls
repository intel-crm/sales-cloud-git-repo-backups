/**************************************************************************************
Apex Class Name:  Core_LeadTriggerHandler
Version     : 1.0 
Created Date: 05 March 2026
Function    : Helper class to handle Core_Lead trigger logic with flattened structure to reduce cognitive complexity
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Naveen                  03/05/2026              Refactored trigger logic to reduce nested IF statements and cognitive complexity
*************************************************************************************/
public without sharing class Core_LeadTriggerHandler {
    
    
    /**
     * Handles all before trigger operations
     */
    public static void handleBeforeTrigger(Map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution) {
        if (Trigger.isInsert) {
            handleBeforeInsert(mapFunctionalityNameTriggerExecution);
        } else if (Trigger.isUpdate) {
            handleBeforeUpdate(mapFunctionalityNameTriggerExecution);
        }
    }

    /**
     * Handles before insert operations
     */
    public static void handleBeforeInsert(Map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution) {
        Core_LeadHandlerforSLA.CheckListedOwnerorNot(Trigger.new);
        
        // Cast Trigger.new to List<Lead> and Trigger.oldMap to Map<Id,Lead>
        List<Lead> newLeads = (List<Lead>) Trigger.new;
        Map<Id,Lead> oldLeadMap = (Map<Id,Lead>) Trigger.oldMap;
        
        SWS_LeadHandler.beforeInsertUpdateOperations(newLeads, oldLeadMap);
        
        // Check and execute leadObjectBeforeHandler
        if (mapFunctionalityNameTriggerExecution.containsKey('leadObjectBeforeHandler') &&
            mapFunctionalityNameTriggerExecution.get('leadObjectBeforeHandler').Core_Active__c) {
            Core_LeadHandler.leadObjectBeforeHandler(newLeads, oldLeadMap);
        }
        
        // Check and execute leadObjectSalesGroup
        if (mapFunctionalityNameTriggerExecution.containsKey('leadObjectSalesGroup') &&
            mapFunctionalityNameTriggerExecution.get('leadObjectSalesGroup').Core_Active__c) {
            Core_LeadHandler.leadObjectSalesGroup(newLeads);
        }
        
        // Check and execute populateSegmentMpiInPartnerLeads for partner leads
        if (mapFunctionalityNameTriggerExecution.containsKey('AssignLeadsToPartnerQueues') &&
            mapFunctionalityNameTriggerExecution.get('AssignLeadsToPartnerQueues').Core_Active__c) {
            Core_PartnerLeadHandler.populateSegmentMpiInPartnerLeads(newLeads, true);
        }
        
        // Check and execute country labels update
        if (mapFunctionalityNameTriggerExecution.containsKey('fetchCountryLabels') && 
            mapFunctionalityNameTriggerExecution.get('fetchCountryLabels').Core_Active__c) {
            Core_Lead_Inquiry_Handler.updateCountryLabelOnLeadCountryChange(newLeads);
        }
    }

    /**
     * Handles before update operations
     */
    public static void handleBeforeUpdate(Map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution) {
        // Cast Trigger collections to specific Lead types
        List<Lead> newLeads = (List<Lead>) Trigger.new;
        List<Lead> oldLeads = (List<Lead>) Trigger.old;
        Map<Id,Lead> oldLeadMap = (Map<Id,Lead>) Trigger.oldMap;
        
        Core_LeadHandlerforSLA.CheckListedOwnerorNotOnUpdate(newLeads, oldLeads);        
        
        // Check and execute leadObjectBeforeHandler
        if (mapFunctionalityNameTriggerExecution.containsKey('leadObjectBeforeHandler') &&
            mapFunctionalityNameTriggerExecution.get('leadObjectBeforeHandler').Core_Active__c) {
            Core_LeadHandler.leadObjectBeforeHandler(newLeads, oldLeadMap);
        }
        
        // Check and execute leadObjectSalesGroup
        if (mapFunctionalityNameTriggerExecution.containsKey('leadObjectSalesGroup') &&
            mapFunctionalityNameTriggerExecution.get('leadObjectSalesGroup').Core_Active__c) {
            Core_LeadHandler.leadObjectSalesGroup(newLeads);
        }
        
        // Check and execute stampFieldOnRejectLead
        if (mapFunctionalityNameTriggerExecution.containsKey('StampFieldOnReject') &&
            mapFunctionalityNameTriggerExecution.get('StampFieldOnReject').Core_Active__c) {
            Core_PartnerLeadHandler.stampFieldOnRejectLead(newLeads, oldLeadMap);
        }
        
        // Check and execute reRoutePartnerLead
        if (mapFunctionalityNameTriggerExecution.containsKey('AssignLeadsToPartnerQueues') &&
            mapFunctionalityNameTriggerExecution.get('AssignLeadsToPartnerQueues').Core_Active__c) {
            Core_PartnerLeadHandler.reRoutePartnerLead(newLeads);
        }
        
        // Check and execute country labels update
        if (mapFunctionalityNameTriggerExecution.containsKey('fetchCountryLabels') &&
            mapFunctionalityNameTriggerExecution.get('fetchCountryLabels').Core_Active__c) {
            Core_Lead_Inquiry_Handler.updateCountryLabelOnLeadCountryChange(newLeads);
        }
    }

    /**
     * Handles all after trigger operations
     */
    public static void handleAfterTrigger(Map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution) {
        if (Trigger.isInsert) {
            handleAfterInsert(mapFunctionalityNameTriggerExecution);
        } else if (Trigger.isUpdate) {
            handleAfterUpdate(mapFunctionalityNameTriggerExecution);
        }
    }

    /**
     * Handles after insert operations
     */
    public static void handleAfterInsert(Map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution) {
        List<Lead> newLeads = (List<Lead>) Trigger.new;
        
        // Check and execute populateGroupsToRoutePartnerLead
        if (mapFunctionalityNameTriggerExecution.containsKey('AssignLeadsToPartnerQueues') &&
            mapFunctionalityNameTriggerExecution.get('AssignLeadsToPartnerQueues').Core_Active__c) {
            Core_PartnerLeadHandler.populateGroupsToRoutePartnerLead(newLeads);
        }
    }

    /**
     * Handles after update operations
     */
    public static void handleAfterUpdate(Map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution) {
        List<Lead> newLeads = (List<Lead>) Trigger.new;
        Map<Id,Lead> newLeadMap = (Map<Id,Lead>) Trigger.newMap;
        Map<Id,Lead> oldLeadMap = (Map<Id,Lead>) Trigger.oldMap;
        
        // Check and execute BlockAccountconvertforRejectedAndRequested
        if (mapFunctionalityNameTriggerExecution.containsKey('BlockAccountOnLeadConversion') && 
            mapFunctionalityNameTriggerExecution.get('BlockAccountOnLeadConversion').Core_Active__c) {
            Core_LeadHandlerforSLA.BlockAccountconvertforRejectedAndRequested(newLeads);    
        }
        
        // Check and execute leadConversionDeduplication
        if (mapFunctionalityNameTriggerExecution.containsKey('leadConversionDeduplication') &&
            mapFunctionalityNameTriggerExecution.get('leadConversionDeduplication').Core_Active__c) {
            Core_LeadHandler.leadConversionDeduplication(newLeadMap, oldLeadMap);
        }
        
        // Check and execute populateGroupsToRoutePartnerLead
        if (mapFunctionalityNameTriggerExecution.containsKey('AssignLeadsToPartnerQueues') &&
            mapFunctionalityNameTriggerExecution.get('AssignLeadsToPartnerQueues').Core_Active__c) {
            Core_PartnerLeadHandler.populateGroupsToRoutePartnerLead(newLeads);
        }
        
        // Check and execute partnerLeadOwnerUpdate
        if (mapFunctionalityNameTriggerExecution.containsKey('AssignLeadsToPartnerQueues') &&
            mapFunctionalityNameTriggerExecution.get('AssignLeadsToPartnerQueues').Core_Active__c) {
            Core_PartnerLeadHandler.partnerLeadOwnerUpdate(newLeads);
        }
        
        // Check and execute shareLeadRecord
        if (mapFunctionalityNameTriggerExecution.containsKey('AssignLeadsToPartnerQueues') &&
            mapFunctionalityNameTriggerExecution.get('AssignLeadsToPartnerQueues').Core_Active__c) {
            Core_PartnerLeadHandler.shareLeadRecord(newLeads);
        }
        
        // Check and execute StampOPIDsonLead
        if (mapFunctionalityNameTriggerExecution.containsKey('OPIDStampingOnOnePartnerId') &&
            mapFunctionalityNameTriggerExecution.get('OPIDStampingOnOnePartnerId').Core_Active__c) {
            Core_PartnerLeadHandler.StampOPIDsonLead(newLeads);
        }
    }
}