public with sharing class Core_IPS_OppParNote {
    public Core_IPS_Opportunity_PAR__c oppParRec;
    public Boolean show{get;set;}
    public Core_IPS_OppParNote(ApexPages.StandardController controller) {
        //FLS Check Added - Nishitha
        if(Core_IPS_Opportunity_PAR__c.SObjectType.getDescribe().isAccessible()){
             oppParRec = [SELECT Id, Core_IPS_Premier_Support_Project__c, Core_IPS_Premier_Support_Project__r.Core_Status__c FROM Core_IPS_Opportunity_PAR__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        }
            if(oppParRec.Core_IPS_Premier_Support_Project__c == null || (oppParRec.Core_IPS_Premier_Support_Project__c != null && oppParRec.Core_IPS_Premier_Support_Project__r.Core_Status__c == 'Draft')) {
            show = true;
        } else {
            show = false;
        }
    }
}