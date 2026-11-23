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
    
    public Core_MDF_DeleteGroupMember(List<GroupMember> gmList){
        if(gmList != NULL && gmList.Size() > 0){
            gmListToBeDeleted = gmList;
        }
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
               Database.delete(gmListToBeDeleted); }}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
}