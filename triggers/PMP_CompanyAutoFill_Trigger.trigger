trigger PMP_CompanyAutoFill_Trigger on PMP_CompanyAutoFill__c (after insert, after update,before insert,before update) {       
            new PMP_CompanyAutoFill_TriggerHandler().run();
        
}