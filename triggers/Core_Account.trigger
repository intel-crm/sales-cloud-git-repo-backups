/**************************************************************************************
Apex Class Name:  Core_Account
Version     : 1.0
Created Date: 03 OCT 2014
Function    : Trigger for the object Account
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Srikant Joshi             10/03/2014              Original Version
* Brian Matthews            12/03/2014              After-Delete.  Bulkified.
* Dave Hood                 03/28/2017              Added code to prevent A&E User account ownership
* Sarah Manuel              25/08/2020              Added code to onboard IPA accounts and Create group for Co-marketing Accounts
* Anjali Haryani            14/09/2020              Commented IPS code in after insert as that was not being invoked anytime
* Sougata Sarkar            09/09/2021              Added a logic to bypass whole account trigger while sales assist update is happening.
*************************************************************************************/
trigger Core_Account on Account (before insert, before update, before delete, after delete,after update,after insert) {
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    Boolean isSalesAssistUpdate = false;

    
    if(Trigger.isUpdate && mapFunctionalityNameTriggerExecution.containsKey('BypassAccTriggerOnSalesAssistUpdate') && mapFunctionalityNameTriggerExecution.get('BypassAccTriggerOnSalesAssistUpdate').Core_Active__c){
        if(trigger.new[0].Core_Sales_Assist_Staging__c <> trigger.OldMap.get(trigger.new[0].Id).Core_Sales_Assist_Staging__c){
            isSalesAssistUpdate = true;
            //UCD_ACM_Logger.error('Core_Account','Core_Account','isSalesAssistUpdate is true',null);
            //UCD_ACM_Logger.setLogDetails();
        }
    }

    try{
        if(mapFunctionalityNameTriggerExecution.containsKey('AccountTriggerExecution') &&
            mapFunctionalityNameTriggerExecution.get('AccountTriggerExecution').Core_Active__c){
                if(!isSalesAssistUpdate){
                    TriggerHandler genericTrigger = new Core_AccountTriggerHandler();
                    genericTrigger.run();
                }
        }
    }catch(Exception ex){
        UCD_ACM_Logger.error('Core_Account','Trigger','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
    }finally{
        UCD_ACM_Logger.setLogDetails();
    }
}