trigger SPM_NewAccountShare on SPM_New_Accounts__c (after insert) {
    new SPM_AccountDetailsTriggerHandler().run();
}