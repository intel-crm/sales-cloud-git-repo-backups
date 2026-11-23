/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_UserGroupMapping_Deletion 
* Version     : 1.0 
* Created Date: 27-02-2019
* Modification Log :
* Developer                     Date                          Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      27-02-2019                    Batch class to delete records from GroupMember table if the audience list no longer contains CCP audience
* Intel - NP(11630236)			10-06-2020					  Commented the User share code
* Intel - NP(11630236)			11-06-2020					  Added code to delete PNUMs on group member deletion
**************************************************************************************************************************************************************************************/
global class Core_MDF_UserGroupMapping_Deletion implements Database.Batchable<id>, Database.Stateful
{
   public List<id> tobeDeleted = new List<id>();
   public list<id> toBeDeletedPnum = new list<id>();
   public List<UserShare> userShareTobeDeletedList = new List<UserShare>();
   public Set<String> userOrGroupIdSet = new Set<String>();
   public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll(); 
   public boolean pnumSwitch =false;
   public boolean externalUserSharingSwitch =false;


   global Core_MDF_UserGroupMapping_Deletion(List<id> inputFromUserGroupMappingClass)
   {
    tobeDeleted = inputFromUserGroupMappingClass;          
   }

   global List<id> start(Database.BatchableContext batchContext)
   {
      return tobeDeleted;
   }

   global void execute(Database.BatchableContext batchContext, List<id> toBeDeleted)
   {

      try{
         List<Id> groupIdList = new List<Id>(); 
         for (GroupMember gm : [SELECT Id,UserOrGroupId,GroupId FROM GroupMember WHERE Id IN:toBeDeleted]) {
            userOrGroupIdSet.add(gm.UserOrGroupId);
            groupIdList.add(gm.GroupId);
         }
         
         for(UserShare usr : [SELECT Id,RowCause From UserShare WHERE UserId IN: userOrGroupIdSet AND UserOrGroupId IN: groupIdList AND RowCause = :Schema.UserShare.RowCause.Manual]){
            userShareTobeDeletedList.add(usr);
         } 
         
         //Check if PNUM deletion indicator is True
         if(mapFunctionalityNameTriggerExecution.containsKey('pnumDeletionIndicator') &&
            mapFunctionalityNameTriggerExecution.get('pnumDeletionIndicator').Core_Active__c){pnumSwitch = true;}
         
         
         //Get the PNUM values to be deleted before the user is removed from Group
         if(pnumSwitch){toBeDeletedPnum = Core_MDF_PNUM_Deletion.pnumdeletion(toBeDeleted);}
         
         //Remove User from Groupmember
         Database.DeleteResult[] deleteList = Database.delete(toBeDeleted,false); 
         system.debug('deleteList' + deleteList);
  
       }
       
       catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}     
   }

   global void finish(Database.BatchableContext batchContext)
   {    
       system.debug('pnumSwitch' + pnumSwitch);
       if(pnumSwitch){
           //Log the PNUM deletion in the User Group Mapping Log table
           Core_MDF_PNUM_Deletion.logUGM(toBeDeletedPnum);
           
           //Delete the PNUM records
           Database.DeleteResult[] pnumDeleteList = Database.delete(toBeDeletedPnum,false); 
           system.debug('pnumdelete' + pnumDeleteList); 
           
           //Check if PNUM deletion indicator is True
           if(mapFunctionalityNameTriggerExecution.containsKey('callExternalUserSharingFromUGMDeletion') &&
              mapFunctionalityNameTriggerExecution.get('callExternalUserSharingFromUGMDeletion').Core_Active__c){externalUserSharingSwitch = true;}
           
           // Delete the corresponding User Share Records by calling the External User sharing batch 
           if(externalUserSharingSwitch && userShareTobeDeletedList != NULL && userShareTobeDeletedList.size() > 0){
               // Calling the external batch class to delete the User Share record which was created manually as part of User - group addition
               Database.executeBatch(new Core_MDF_ExternalUserSharing(true,userShareTobeDeletedList));
           }
           
       }
 
   }

}