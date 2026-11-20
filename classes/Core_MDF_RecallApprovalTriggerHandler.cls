/****************************************************************************************************************************************
* Class Name  : Core_MDF_RecallApprovalTriggerHandler
* Version     : 1.0 
* Created Date: 04-26-2021
* Modification Log :
* Developer                     Date                        Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Prashant Dhanagar    			4/26/2021                    Created for extending Trigger framework to process the Recall Apporval process logic.
* *****************************************************************************************************************************************/
public class Core_MDF_RecallApprovalTriggerHandler extends TriggerHandler{    
    public override void afterInsert(){
        Core_MDF_RecallApprovalServiceHandler.recallApprovalProcess ((List<Core_MDF_Recall_Approval__e>)Trigger.New);
    }   
}