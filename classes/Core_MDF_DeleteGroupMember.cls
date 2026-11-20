/****************************************************************************************************************************************
* Class Name        : Core_MDF_DeleteGroupMember
* Created Date      : 08-12-2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VK       08-12-2020         Queueable class to delete group member records when IUPGM is inactivated from Batch
*****************************************************************************************************************************************/
public class Core_MDF_DeleteGroupMember implements Queueable {
	
    List<GroupMember> gmListToBeDeleted = new List<GroupMember>();
    //List<User> userListForUpdate = new List<User>();
    //US1073355 - Marketing User update with Platform Event changes
    List<Core_MDF_Bulk_Transaction__e> userListForUpdate = new List<Core_MDF_Bulk_Transaction__e>();
    
    public Core_MDF_DeleteGroupMember(List<GroupMember> gmList, List<Core_MDF_Bulk_Transaction__e> userList){
        
        if(gmList != NULL && gmList.Size() > 0){
            gmListToBeDeleted = gmList;
        }
        
        if(userList != NULL && userList.Size() > 0){userListForUpdate = userList;}
    }
    
    /***************************************************************************************************** 
    Method Name :   execute
    @return     :   Null
    @parameters :   QueueableContext
    Description :   Deletes group member records
    Added By    :   Accenture - VK - 08-12-2020
    Modified By :                               Date:                   Changes:
    ******************************************************************************************************/ 
    public void execute(QueueableContext context){ 
        try{
            if(gmListToBeDeleted != NULL && gmListToBeDeleted.Size() > 0){
                Database.delete(gmListToBeDeleted);
            }
            
            //if(userListForUpdate != NULL && userListForUpdate.Size() > 0){ID jobID = System.enqueueJob(new Core_MDF_MarketingUser(userListForUpdate));}
            if(userListForUpdate != null && !userListForUpdate.isEmpty()){List<Database.SaveResult> results = EventBus.publish(userListForUpdate);}
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
}