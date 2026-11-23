/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_UserGroupMapping_Deletion 
* Version     : 1.0 
* Created Date: 27-02-2019
* Modification Log :
* Developer                     Date                          Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      27-02-2019                    Batch class to delete records from GroupMember table if the audience list no longer contains CCP audience
**************************************************************************************************************************************************************************************/
global class Core_MDF_UserGroupMapping_Deletion implements Database.Batchable<id>, Database.Stateful
{
   public List<id> tobeDeleted = new List<id>();
   public static String logEntryMsg = '';
   public static exception ex;
   public List<UserShare> userShareTobeDeletedList = new List<UserShare>();
   public Set<String> userOrGroupIdSet = new Set<String>();

   global Core_MDF_UserGroupMapping_Deletion(List<id> inputFromUserGroupMappingClass)
   {
    tobeDeleted = inputFromUserGroupMappingClass;          
   }

   global List<id> start(Database.BatchableContext BC)
   {
      return tobeDeleted;
   }

   global void execute(Database.BatchableContext BC, List<id> toBeDeleted)
   {

      try{
         List<Id> groupIdList = new List<Id>();
         //Prepare userorgroupIdSet from Group Member 
         for (GroupMember gm : [SELECT Id,UserOrGroupId,GroupId FROM GroupMember WHERE Id IN:toBeDeleted]) {
            userOrGroupIdSet.add(gm.UserOrGroupId);
            groupIdList.add(gm.GroupId);
         }
         System.debug('userOrGroupIdSet:'+userOrGroupIdSet);
         
         for(UserShare usr : [SELECT Id,RowCause From UserShare WHERE UserId IN: userOrGroupIdSet AND UserOrGroupId IN: groupIdList AND RowCause = :Schema.UserShare.RowCause.Manual]){
            userShareTobeDeletedList.add(usr);
         }
         System.debug('userShareTobeDeletedList:'+userShareTobeDeletedList);
          system.debug('toBeDeletedIds' + toBeDeleted);
          Database.DeleteResult[] deleteList = Database.delete(toBeDeleted,false); 
          system.debug('deleteList' + deleteList);
          System.debug('userShareTobeDeletedList:'+userShareTobeDeletedList);
          
       }
       
       catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex); Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Core_MDF_UserGroupMappingAutomation - getGroupListForUser()');/*system.debug('logEntryMsg' + logEntryMsg +isError );*/}     
   }

   global void finish(Database.BatchableContext BC)
   {
      // Delete the corresponding User Share Records by calling the External User sharing batch 
      if(userShareTobeDeletedList != NULL && userShareTobeDeletedList.size() > 0){
         // Calling the external batch class to delete the User Share record which was created manually as part of User - group addition
         Database.executeBatch(new Core_MDF_ExternalUserSharing(true,userShareTobeDeletedList));
      }
   }

}