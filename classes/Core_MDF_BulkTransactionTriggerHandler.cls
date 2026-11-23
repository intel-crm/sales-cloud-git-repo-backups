/****************************************************************************************************************************************
* Class Name  : Core_MDF_BulkTransactionTriggerHandler
* Version     : 1.0 
* Created Date: 06-25-2021
* Modification Log :
* Developer                     Date                        Description
* ---------------------------------------------------------------------------------------------------------------------------------------
  Accenture - NZ				06/23/2021					Bulk Data Insert/Update
*****************************************************************************************************************************************/
public class Core_MDF_BulkTransactionTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {
    	Core_MDF_Bulk_TransactionServiceHandler.upsertRecords(Trigger.New);    
    } 
}