/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_Bulk_Transaction
* Version     : 1.0 
* Created Date: 6/23/2021
* Modification Log :
* Description:                                                 
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
*   Accenture - NZ				06/23/2021					Bulk Data Insert/Update
*/
trigger Core_MDF_Bulk_Transaction on Core_MDF_Bulk_Transaction__e(after insert) {
	 
	 new Core_MDF_BulkTransactionTriggerHandler().run();       

}