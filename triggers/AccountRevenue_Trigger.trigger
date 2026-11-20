trigger AccountRevenue_Trigger on Account_Revenue__c (after insert) {
    AccountRevenue_TriggerHandler handlerObject = new AccountRevenue_TriggerHandler();
    handlerObject.run();
}