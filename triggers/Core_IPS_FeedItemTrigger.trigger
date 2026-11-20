/**
 * @description       : only handle for Before Insert here.
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-26-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-26-2020   Prem Ranjan   Initial Version
**/
trigger Core_IPS_FeedItemTrigger on FeedItem (before insert) {
    
    if(trigger.isBefore){  
        Core_IPS_FeedItem_Dispatcher.beforeMethod( trigger.new, trigger.oldMap, trigger.newMap);
    }   
}