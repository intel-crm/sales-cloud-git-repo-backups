/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_Account_PGM_Sync
* Version     : 1.0 
* Created Date: 02/16/2023
* Modification Log :
* Description:                                                 
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* JB - Accenture              02/16/2023                     
*/
trigger Core_MDF_Account_PGM_Sync on Core_MDF_Account_PGM_Sync__e(after insert) {
    new Core_MDF_Account_PGM_Sync_TriggerHandler().run();
}