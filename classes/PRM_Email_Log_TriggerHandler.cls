/******************************************************************************************************************************
Apex Class Name:  PRM_Email_Log_TriggerHandler
Version     : 1.0 
Created Date: 01 JUN 2021
Function    : Trigger handler for the object PRM_EmailLog__c 

Modification Log :
* Developer                     Date                    Description
* ----------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/06/2021               Call publishEmailLogDetails method of PRM_Email_Log_Utility Class

*******************************************************************************************************************************/
public class PRM_Email_Log_TriggerHandler extends TriggerHandler {
    boolean firstRun=false;
    public override void afterInsert(){
        //Fetching data from Custom Metadata 
        if(isActive('PRM_Email_Log_AfterInsert_Switch')){
            PRM_Email_Log_Utility.publishEmailLogDetails(Trigger.new,(Map<Id,PRM_EmailLog__c>)Trigger.oldMap);
        }
    }
    public override void afterUpdate(){
        //Fetching data from Custom Metadata 
        if(!firstRun && isActive('PRM_Email_Log_AfterUpdate_Switch')){
            firstRun=true;
            PRM_Email_Log_Utility.publishEmailLogDetails(Trigger.new,(Map<Id,PRM_EmailLog__c>)Trigger.oldMap);
        }
    }
}