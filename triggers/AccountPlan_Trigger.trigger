trigger AccountPlan_Trigger on Account_Plan__c (after insert) {

    AccountPlan_TriggerHandler handlerObject = new AccountPlan_TriggerHandler();
    handlerObject.run();
}