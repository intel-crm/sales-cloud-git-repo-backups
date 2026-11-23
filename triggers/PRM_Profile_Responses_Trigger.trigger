trigger PRM_Profile_Responses_Trigger on PRM_Profile_Responses__c (before update, before insert, after update, after insert) {
    new PRM_ProfileResponses_TriggerHandler().run();
}