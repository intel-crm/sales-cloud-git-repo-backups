trigger PRM_ACM_Trigger on PRM_AccountChannelMembership__c (before update, before insert, after update, after insert) {
    Boolean newTrigger = Boolean.valueOf(System.Label.PRM_OptimizedTriggerHandler);
    if(newTrigger){
        new PRM_ACMTriggerHandlerNew().run();
    }
    //else{new PRM_ACM_TriggerHandler().run();}
}