public with sharing class PRM_ServiceNowCase_TriggerHandler extends TriggerHandler{
    public override void afterInsert(){
       PRM_ServiceNowUtility.createServiceNowCase(trigger.new);
    }
}