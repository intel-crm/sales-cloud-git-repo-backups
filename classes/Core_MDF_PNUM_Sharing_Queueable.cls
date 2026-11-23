/****************************************************************************************************************************************
* Class Name  : Core_MDF_PNUM_Sharing_Queueable
* Version     : 1.0
* Created Date: 02/22/2022
* Modification Log :
* Developer            	Date               	Description
------------------------------------------------------------------------------------------------------------------------------------------
*Accenture - JB			02/22/2022			To add and remove Group members from Account Node Group.
******************************************************************************************************************************************/
public class Core_MDF_PNUM_Sharing_Queueable implements Queueable{
    private List<GroupMember> grpMemListToInsert = new List<GroupMember>();
    private Set<Id> grpMemIdSetToDelete = new Set<Id>();
    
    public Core_MDF_PNUM_Sharing_Queueable(List<GroupMember> grpMemListToInsert, Set<Id> grpMemIdSetToDelete){
        this.grpMemListToInsert = grpMemListToInsert;
        this.grpMemIdSetToDelete = grpMemIdSetToDelete;
    }
    
	public void execute(QueueableContext context) {
        try{
            
            //To remove Group Members from respective acccount node groups.
            if(grpMemIdSetToDelete!= null && !grpMemIdSetToDelete.isEmpty()){
                Database.delete(new List<Id>(grpMemIdSetToDelete));
            }
            
            //To add Group Members with respective acccount node groups.
            if(grpMemListToInsert!= null &&!grpMemListToInsert.isEmpty()){
                Database.insert(grpMemListToInsert);
           }
            
        }catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
    }
}