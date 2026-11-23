public class CRM_Linked_Opportunity_RelatedList {
 
    @AuraEnabled( cacheable=true ) 
    public static list<CRM_Linked_Opportunities__c> fetchRecords( String recordId )  { 
        system.debug( 'values are ' + recordId ); 
        RelatedListWrapper objWrap = new RelatedListWrapper();
        list<CRM_Linked_Opportunities__c> linkedOptyRecord =[SELECT Id,CRM_Primary_Opportunity__c,CRM_Linked_Opportunity__c,CRM_Link_Reason__c,CRM_Link_Description__c 
                                                                         FROM CRM_Linked_Opportunities__c where (CRM_Primary_Opportunity__c =: recordId OR CRM_Linked_Opportunity__c =: recordId)];
        
        return linkedOptyRecord; 
         
    } 

    public class RelatedListWrapper {

        @AuraEnabled
        public List <CRM_Linked_Opportunities__c> listRecords;
        @AuraEnabled
        public Integer recordCount;

    }
         
}