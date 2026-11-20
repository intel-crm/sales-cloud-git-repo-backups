trigger AccountStatus_Trigger on Account_Status__c (after insert) {

    AccountStatus_TriggerHandler handlerObject = new AccountStatus_TriggerHandler();
    handlerObject.run();
}