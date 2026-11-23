/****************************************************************************************************************************************
* Class Name  : Core_MDF_Remove_GroupMembers_Queueable
* Version     : 1.0
* Created Date: 02/25/2022
* Modification Log :
* Developer            	Date               	Description
------------------------------------------------------------------------------------------------------------------------------------------
*Accenture - JB			02/25/2022			To remove Group members from Account Node Group.
******************************************************************************************************************************************/
public without Sharing class Core_MDF_Remove_GroupMembers_Queueable implements Queueable{
    private Map<Id,GroupMember> grpMemListToInsert = new Map<Id,GroupMember>();
    private Map<Id,Id> pnumIdToGrmMemberIdDeleteMap = new Map<Id,Id>();
    List<Core_MDF_Partner_Node_User_Mapping__c> erroredPnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
    public Core_MDF_Remove_GroupMembers_Queueable(Map<Id,GroupMember> grpMemListToInsert, Map<Id,Id> pnumIdToGrmMemberIdDeleteMap){
        this.grpMemListToInsert = grpMemListToInsert;
        this.pnumIdToGrmMemberIdDeleteMap = pnumIdToGrmMemberIdDeleteMap;
    }
    
	public void execute(QueueableContext context) {
        list<Id> grmMemIdList = new List<Id>();
        Boolean errorFlag = false;

        //To remove Group Members from respective acccount node groups.        
        //if(pnumIdToGrmMemberIdDeleteMap != null && !pnumIdToGrmMemberIdDeleteMap.isEmpty()){
        if(pnumIdToGrmMemberIdDeleteMap == null || pnumIdToGrmMemberIdDeleteMap.isEmpty()){ //ATHR Fix WW19
            Core_MDF_PNUM_Update_Finalizer fc = new Core_MDF_PNUM_Update_Finalizer(erroredPnumList,grpMemListToInsert);
            System.attachFinalizer(fc);
            return;
        }
            
            Database.DeleteResult[] drList = Database.delete(new List<Id>(pnumIdToGrmMemberIdDeleteMap.values()), false);
            
            // Iterate through each returned result
            for (Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                   
                    grmMemIdList.add(dr.getId());
                }
                else {     
                   errorFlag = true;
                }
            }
                
            if(errorFlag){
                for(Id pnumId : pnumIdToGrmMemberIdDeleteMap.keySet()){
                    if(pnumIdToGrmMemberIdDeleteMap.containskey(pnumId) && !grmMemIdList.contains(pnumIdToGrmMemberIdDeleteMap.get(pnumId))){
                        erroredPnumList.add(new Core_MDF_Partner_Node_User_Mapping__c(Id = pnumId, Core_MDF_Error_Details_txt__c = 'Group member delete failed'));
                    }
                }
            }
        //}

        // Create an instance of LoggingFinalizer and attach it
        Core_MDF_PNUM_Update_Finalizer fc = new Core_MDF_PNUM_Update_Finalizer(erroredPnumList,grpMemListToInsert);
        System.attachFinalizer(fc);
    }
    
    public class Core_MDF_PNUM_Update_Finalizer implements Finalizer{
        List<Core_MDF_Partner_Node_User_Mapping__c> erroredPnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        Map<Id,GroupMember> pnumIdTogrpMemListToInsert = new Map<Id,GroupMember>();
        public Core_MDF_PNUM_Update_Finalizer(List<Core_MDF_Partner_Node_User_Mapping__c> erroredPnumList , Map<Id,GroupMember> pnumIdTogrpMemListToInsert){
            this.erroredPnumList = erroredPnumList;
            this.pnumIdTogrpMemListToInsert = pnumIdTogrpMemListToInsert;
        }
        
        // Finalizer implementation
        public void execute(FinalizerContext ctx) {
          
            
            Core_MDF_RecursiveTrigger.isRecursive = true;

            //To Add Group Members
            if (pnumIdTogrpMemListToInsert != null && !pnumIdTogrpMemListToInsert.isEmpty()) {
                System.enqueueJob(new Core_MDF_Add_GroupMembers_Queueable(pnumIdTogrpMemListToInsert));
            } 

            //PNUM records to update
            if(!erroredPnumList.isEmpty()){
                Database.update(erroredPnumList);
            }
        }
    }
}