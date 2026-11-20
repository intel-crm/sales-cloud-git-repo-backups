trigger CRM_Linked_Opportunity on CRM_Linked_Opportunities__c (before insert, before update) {
     if(true){
            new CRM_Linked_OpportunityHandler().run();
        }  
}