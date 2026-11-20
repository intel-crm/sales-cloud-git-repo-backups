/******************************************************************************************************************************************
Trigger Name: Core_ContactEngagement
Version     : 1.0 
Created Date: 27 APR 2016
Function    : Trigger for the object Core_Contact_Engagement__c
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Troy Hofeling             04/27/2016              Original version
*****************************************************************************************************************************************/
trigger Core_ContactEngagement on Core_Contact_Engagement__c (after insert, after update, after delete, before insert, before update, before delete) {
    if(trigger.isBefore){
        Core_ContactEngagement_Dispatcher.beforeMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
    if(trigger.isAfter){
        Core_ContactEngagement_Dispatcher.afterMethod(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
}