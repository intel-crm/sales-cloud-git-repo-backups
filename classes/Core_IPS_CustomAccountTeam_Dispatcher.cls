/**************************************************************************************
Apex Class Name:  Core_IPS_CustomAccountTeam_Dispatcher
Version     : ?
Created Date: ?
Function    : Dispatcher class for the trigger on the custom Account Team object
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* ?                           ?                      Original version for IPS
* Dave Hood                   03/17/2016             Added call to non-IPS handler methods, to share Account Meeting Briefs
* Brian Matthews              04/28/2016             Added call to synchronize Standard Account Team on delete. 
*************************************************************************************/
public class Core_IPS_CustomAccountTeam_Dispatcher{
    public static void beforeMethod(List<Core_Account_Team__c> oldList, List<Core_Account_Team__c> newList, 
                            Map<Id,Core_Account_Team__c> oldMap,Map<Id,Core_Account_Team__c> newMap){
         if(trigger.isInsert) {
                 
         }
         if(trigger.isUpdate) {
                 
         }
         if(trigger.isDelete) {
             
         }
    }      


    public static void afterMethod(List<Core_Account_Team__c> oldList, List<Core_Account_Team__c> newList, 
                            Map<Id,Core_Account_Team__c> oldMap,Map<Id,Core_Account_Team__c> newMap){
            
        //[Below 2 lines are making sure to process only IPS records.]
        List<Core_Account_Team__c> ipsNewRecordList = Core_IPS_CustomAccountTeam_Handler.ipsRecordsOnly(newList);
        List<Core_Account_Team__c> ipsOldRecordList = Core_IPS_CustomAccountTeam_Handler.ipsRecordsOnly(oldList);
        
        if(trigger.isInsert){
             if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                 Core_IPS_CustomAccountTeam_Handler.manageSharing(ipsNewRecordList);
             }
             
            
            Core_CustomAccountTeamHandler.manageSharing(newList);
         }
         if(trigger.isUpdate){             
             if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                 Core_IPS_CustomAccountTeam_Handler.manageSharing(ipsNewRecordList);
             }
             
            Core_CustomAccountTeamHandler.manageSharing(newList);
         }
         if(trigger.isDelete){
             if(ipsOldRecordList <> null && ipsOldRecordList.size() > 0){
                 Core_IPS_CustomAccountTeam_Handler.revokeAccessForDelete(ipsOldRecordList);
             }
             
           Core_CustomAccountTeamHandler.revokeAccessForDelete(oldList);

            // Synchronize deletes to Standard Account Team object.
            Core_IPS_CustomAccountTeam_Handler.deleteStandardAccountTeam(oldList);
         }             
    }  
}