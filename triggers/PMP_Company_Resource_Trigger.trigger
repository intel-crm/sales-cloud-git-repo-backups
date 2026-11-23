trigger PMP_Company_Resource_Trigger on PMP_Company_Resource__c (before insert,after insert, after update) {
    
   new PMP_SearchCompanyResourceTriggerHandler().run();
    
    
    
}