/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_RecallApproval_Schedulable 
* Version     : 1.0 
* Created Date: 6/29/2021
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture - NZ 		6/29/2021				 Batch class to recall 
**************************************************************************************************************************************************************************************/

global class Core_MDF_RecallApproval_Schedulable implements Schedulable{
	global void execute(SchedulableContext sc) {  
        Core_MDF_RecallApproval_Batch recallApprovalBatch = new Core_MDF_RecallApproval_Batch();      
       	Database.executeBatch(recallApprovalBatch, 100);
    }
}