/****************************************************************************************************************************************
* Class Name  : Core_MDF_Add_GroupMembers_Queueable
* Version     : 1.0
* Created Date: 02/25/2022
* Modification Log :
* Developer            	Date               	Description
------------------------------------------------------------------------------------------------------------------------------------------
*Accenture - JB			02/25/2022			To add Group members from Account Node Group.
******************************************************************************************************************************************/
public without sharing class Core_MDF_Add_GroupMembers_Queueable implements Queueable{

    private Map<Id,GroupMember> grpMemListToInsert = new Map<Id,GroupMember>();
    List<Core_MDF_Partner_Node_User_Mapping__c> pnumInitialList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
    Database.SaveResult[] srList;

    public Core_MDF_Add_GroupMembers_Queueable(Map<Id,GroupMember> grpMemListToInsert){
        this.grpMemListToInsert = grpMemListToInsert;
    }
    
	public void execute(QueueableContext context) {
        try{
            //To add Group Members with respective acccount node groups.
            if(grpMemListToInsert != null && !grpMemListToInsert.isEmpty()){

                if(!Test.isRunningTest())
                    srList = Database.insert(grpMemListToInsert.values(), false);

               
                
                for(Id pnumId : grpMemListToInsert.keySet()){
                    
                    if(grpMemListToInsert.containskey(pnumId) && grpMemListToInsert.get(pnumId).Id == null){
                        pnumInitialList.add(new Core_MDF_Partner_Node_User_Mapping__c(Id = pnumId, Core_MDF_Error_Details_txt__c = 'Group member Insert failed'));
                    }
                }
               

                if(!pnumInitialList.isEmpty()){
                    // Create an instance of LoggingFinalizer and attach it
                    Core_MDF_PNUM_Update_Finalizer fc = new Core_MDF_PNUM_Update_Finalizer(pnumInitialList);
                    System.attachFinalizer(fc);
                }
            }
            
        }catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    public class Core_MDF_PNUM_Update_Finalizer implements Finalizer{

        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        public Core_MDF_PNUM_Update_Finalizer(List<Core_MDF_Partner_Node_User_Mapping__c> pnumList){
            this.pnumList = pnumList;
        }
        
        // Finalizer implementation
        public void execute(FinalizerContext ctx) {

            Core_MDF_RecursiveTrigger.isRecursive = true;

            //PNUM records to update
            if(!pnumList.isEmpty()){
                Database.update(pnumList);
            }     
            
        }
    }
}