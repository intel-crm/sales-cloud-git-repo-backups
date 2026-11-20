trigger PMP_Company_Resource_Trigger on PMP_Company_Resource__c (after insert, after update) {
    
   new PMP_SearchCompanyResourceTriggerHandler().run();
    
    
    
}