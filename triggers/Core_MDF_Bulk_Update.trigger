/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_Bulk_Update
* Version     : 1.0 
* Created Date: 6/23/2021
* Modification Log :
* Description:                                                 
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Nuzhath Zaiba       6/23/2021                    Trigger to handle Bulk Update 
*/
trigger Core_MDF_Bulk_Update on Core_MDF_Bulk_Update__e (after insert) {

    Core_MDF_Bulk_Update_ServiceHandler.updateRecords(Trigger.New);

}