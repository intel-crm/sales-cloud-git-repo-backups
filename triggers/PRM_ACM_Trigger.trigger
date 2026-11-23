trigger PRM_ACM_Trigger on PRM_AccountChannelMembership__c (before update, before insert, after update, after insert) {
    system.debug('ACM trigger entry');
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        if(Boolean.valueOf(System.Label.PRM_OptimizedTriggerHandler)){
            System.debug('Inside ACM trigger'+Boolean.valueOf(System.Label.PRM_OptimizedTriggerHandler));
            new PRM_ACMTriggerHandlerNew().run();
        }
       /* else{
            new PRM_ACM_TriggerHandler().run();
        }*/
    }
}