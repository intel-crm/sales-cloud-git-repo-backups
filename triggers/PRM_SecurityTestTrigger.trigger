trigger PRM_SecurityTestTrigger on PRM_Security_Test__c (before insert, before update) { 
    if(Trigger.isInsert && Trigger.isBefore){
        PRM_SecutityTesting.updateSource(Trigger.new);
    }
}