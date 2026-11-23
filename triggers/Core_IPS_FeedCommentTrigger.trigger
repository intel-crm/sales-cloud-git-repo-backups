/**
 * @description       : only handle for Before Insert here.
 * @author            : Prem Ranjan
 * @group             : 
 * @last modified on  : 09-02-2020
 * @last modified by  : Prem Ranjan
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   07-26-2020   Prem Ranjan   Initial Version
**/

trigger Core_IPS_FeedCommentTrigger on FeedComment (before insert) {
    
    if(trigger.isBefore){  
        Core_IPS_FeedComment_Dispatcher.beforeMethod( trigger.new, trigger.oldMap, trigger.newMap);
    }   
}