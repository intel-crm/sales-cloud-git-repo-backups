/**************************************************************************************
Apex Class Name : PMP_Marketplace_Topic_Handler
Version     : 1.0 
Created Date: 3rd August, 2022
Description : Marketplace logic for handler for Marketplace Topic Record
* Modification Log :
* Developer                 Date                     Description 
* ----------------------------------------------------------------------------
* Sathish                  03/Aug/2022               Original Version
*************************************************************************************/
public class PMP_Marketplace_Topic_Handler  extends TriggerHandler {
 public static Boolean isWorking() {
        boolean flag=true;
        return flag;
    }
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
     public override void beforeInsert(){

        if((mapFunctionalityNameTriggerExecution.containsKey('PMP_Marketplace_AutoTopic_Insert') && 
        mapFunctionalityNameTriggerExecution.get('PMP_Marketplace_AutoTopic_Insert').Core_Active__c)){
            PMP_Marketplace_Topic_Helper.insertTopicRecord((List<PMP_Marketplace_Topic__c>)Trigger.new);
        }

        if((mapFunctionalityNameTriggerExecution.containsKey('PMP_Marketplace_AutoEvent_Upsert') && 
        mapFunctionalityNameTriggerExecution.get('PMP_Marketplace_AutoEvent_Upsert').Core_Active__c)){
           PMP_Marketplace_Topic_Helper.upsertEventRecords((List<PMP_Marketplace_Topic__c>)Trigger.new);
        }

     }

     public override void beforeUpdate(){


        if((mapFunctionalityNameTriggerExecution.containsKey('PMP_Marketplace_AutoEvent_Upsert') && 
        mapFunctionalityNameTriggerExecution.get('PMP_Marketplace_AutoEvent_Upsert').Core_Active__c)){
            PMP_Marketplace_Topic_Helper.upsertEventRecords((List<PMP_Marketplace_Topic__c>)Trigger.new);
        }
    }*/

 
}