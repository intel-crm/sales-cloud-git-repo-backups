/******************************************************************************************************************************
Apex Class Name:  Core_PreventDelTrackingRecordHandler
Version     : 1.0 
Created Date: 08 March 2019
Function    : Trigger on the Core_User_Field_Change_History__c object which prevents the Core_User_Field_Change_History__c from being deleted
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandip Ghosh                18/03/2019              Initial version of the trigger handler class
*******************************************************************************************************************************/
trigger Core_PreventDelTrackingRecord on Core_User_Field_Change_History__c (before delete, after delete, before insert, after insert,
                                                                           before update, after update,after undelete) {
    
     if ( trigger.isBefore ) {
         if ( trigger.isDelete ) {
             Core_PreventDelTrackingRecordHandler.onBeforeDelete(trigger.old, trigger.oldMap);
         }
     } else if ( trigger.isAfter ) {
         if ( trigger.isDelete ) {
             Core_PreventDelTrackingRecordHandler.onAfterDelete(trigger.old, trigger.oldMap);
         }
     }

}