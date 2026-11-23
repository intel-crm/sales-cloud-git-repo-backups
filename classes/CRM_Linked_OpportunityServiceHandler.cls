public without sharing class CRM_Linked_OpportunityServiceHandler {

    public static void CheckValidation(List<CRM_Linked_Opportunities__c> linkedOpportunity) {
       // Collect all Opportunity IDs to query in bulk
        Map<Id, Opportunity> opportunities = getOpportunities(linkedOpportunity);
	
        // Perform validation
        for (CRM_Linked_Opportunities__c junctionOpp : linkedOpportunity) {
            if(junctionOpp.CRM_Primary_Opportunity__c == null){
                junctionOpp.addError(Core_CRM_Utility.getCRMLabel('Linked_Opty_Save_New_error'));
            }
            else{
                validateDesignOriginalToDesignSecondary(junctionOpp, opportunities);
            	validateVBSOriginalToVBSConsumption(junctionOpp, opportunities);
            	validateVBSSiliconPullThrough(junctionOpp, opportunities);
            	validateITEOpportunitiesToDeployment(junctionOpp, opportunities);
            	validateVBSOriginalToVBSRenewal(junctionOpp, opportunities);
            	validateDesignHWToDesignSW(junctionOpp, opportunities);
                validateDuplicate(junctionOpp, opportunities);
            }
            
            
        }
    }
    
    private static Map<Id, Opportunity> getOpportunities(List<CRM_Linked_Opportunities__c> linkedOpportunity) {
        Set<Id> opportunityIds = new Set<Id>();
        for (CRM_Linked_Opportunities__c junctionOpp : linkedOpportunity) {
            opportunityIds.add(junctionOpp.CRM_Primary_Opportunity__c);
            opportunityIds.add(junctionOpp.CRM_Linked_Opportunity__c);
        }
        return new Map<Id, Opportunity>([
            SELECT Id, StageName, Core_VBS_Potential__c, Core_Opportunity_Type__c, RecordType.Name, 
                   Core_Coverage_Type_Nm__c, Core_Opportunity_Coverage_Nm__c
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ]);
    }
    
    

    private static void validateDuplicate(CRM_Linked_Opportunities__c junctionOpp, Map<Id, Opportunity> opportunities) {
        Opportunity primaryOppty = opportunities.get(junctionOpp.CRM_Primary_Opportunity__c);
        Opportunity linkedOppty = opportunities.get(junctionOpp.CRM_Linked_Opportunity__c);
        if (junctionOpp.CRM_Link_Reason__c !=null && primaryOppty.Id == linkedOppty.Id) { junctionOpp.addError(Core_CRM_Utility.getCRMLabel('Duplicate'));
        }
    }

    private static void validateDesignOriginalToDesignSecondary(CRM_Linked_Opportunities__c junctionOpp, Map<Id, Opportunity> opportunities) {
        Opportunity linkedOppty = opportunities.get(junctionOpp.CRM_Linked_Opportunity__c);
        if (junctionOpp.CRM_Link_Reason__c == 'Design Original (ODM Board) to Design Secondary (OEM System)' && linkedOppty.RecordType.Name != 'Design Opportunity') {junctionOpp.addError(Core_CRM_Utility.getCRMLabel('Duplicate'));  
        }
    }

    private static void validateVBSOriginalToVBSConsumption(CRM_Linked_Opportunities__c junctionOpp, Map<Id, Opportunity> opportunities) {
        Opportunity primaryOppty = opportunities.get(junctionOpp.CRM_Primary_Opportunity__c);
        if (junctionOpp.CRM_Link_Reason__c == 'VBS original to VBS Consumption only' && (!primaryOppty.Core_VBS_Potential__c || primaryOppty.StageName != 'Design Win' || primaryOppty.Core_Opportunity_Coverage_Nm__c != 'Intel-Led Opportunity')) {junctionOpp.addError(Core_CRM_Utility.getCRMLabel('VBS_Original_to_VBS_Consumptional'));
        }
    }
    
     private static void validateVBSSiliconPullThrough(CRM_Linked_Opportunities__c junctionOpp, Map<Id, Opportunity> opportunities) {
        Opportunity primaryOppty = opportunities.get(junctionOpp.CRM_Primary_Opportunity__c);
        if (junctionOpp.CRM_Link_Reason__c == 'VBS Silicon pull-through' && (!primaryOppty.Core_VBS_Potential__c || primaryOppty.Core_Opportunity_Coverage_Nm__c != 'Intel-Led Opportunity')) {junctionOpp.addError(Core_CRM_Utility.getCRMLabel('VBS_Silicon_pull_through'));
        }
    }
    private static void validateITEOpportunitiesToDeployment(CRM_Linked_Opportunities__c junctionOpp, Map<Id, Opportunity> opportunities) {
        Opportunity primaryOppty = opportunities.get(junctionOpp.CRM_Primary_Opportunity__c);
        if (junctionOpp.CRM_Link_Reason__c == 'ITE opportunities to Actual deployment' && (primaryOppty.RecordType.Name != 'Deal Opportunity' || primaryOppty.Core_Opportunity_Coverage_Nm__c != 'Intel-Led Opportunity')) {junctionOpp.addError(Core_CRM_Utility.getCRMLabel('ITE_opportunities_to_Actual_deployment'));
        }
    }
    private static void validateVBSOriginalToVBSRenewal(CRM_Linked_Opportunities__c junctionOpp, Map<Id, Opportunity> opportunities) {
        Opportunity primaryOppty = opportunities.get(junctionOpp.CRM_Primary_Opportunity__c);
        Opportunity linkedOppty = opportunities.get(junctionOpp.CRM_Linked_Opportunity__c);
        if (junctionOpp.CRM_Link_Reason__c == 'VBS Original to VBS Renewal' && (!primaryOppty.Core_VBS_Potential__c || primaryOppty.StageName != 'Design Win' || linkedOppty.Core_Opportunity_Coverage_Nm__c != 'Intel-Led Opportunity')) {junctionOpp.addError(Core_CRM_Utility.getCRMLabel('VBS_Original_to_VBS_Renewal'));
        }
    }
    private static void validateDesignHWToDesignSW(CRM_Linked_Opportunities__c junctionOpp, Map<Id, Opportunity> opportunities) {
        Opportunity primaryOppty = opportunities.get(junctionOpp.CRM_Primary_Opportunity__c);
        Opportunity linkedOppty = opportunities.get(junctionOpp.CRM_Linked_Opportunity__c);
        
        if (junctionOpp.CRM_Link_Reason__c == 'Design HW component to Design SW component' && !(primaryOppty.RecordType.Name == 'Design Opportunity' && primaryOppty.Core_Opportunity_Coverage_Nm__c == 'Intel-Led Opportunity')) {junctionOpp.addError(Core_CRM_Utility.getCRMLabel('Design_HW_comp_to_Design_SW_comp'));
        }
        //TWC4767-2707 - Defect fix to restrict Duplicate record creation
        junctionOpp.CRM_UniqueLinkedOppty__c = primaryOppty.id > linkedOppty.id ? String.valueof(primaryOppty.id) + String.valueof(linkedOppty.id) : String.valueof(linkedOppty.id) +String.valueof(primaryOppty.id);   
    }

}