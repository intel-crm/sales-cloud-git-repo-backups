trigger PMP_Company_Info_Trigger on PMP_Company__c (after insert, after update,before insert,before update) {
     
     new PMP_Company_Info_TriggerHandler().run();

}