/****************************************************************************************************************************************
* Class Name  : Core_MDF_Account_PGM_Sync_TriggerHandler
* Version     : 1.0 
* Created Date: 02/16/2023
* Modification Log :
* Developer                     Date                        Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* JB - Accenture    		02/16/2023                    Created for extending Trigger framework to process the Account PGM Sync Platform event logic.
* *****************************************************************************************************************************************/
public class Core_MDF_Account_PGM_Sync_TriggerHandler extends TriggerHandler{
	public override void afterInsert(){
        if(isActive('Core_MDF_AfterInsert_AccountPgmSync_PE') && !Core_MDF_Utility.byPassFeature('Bypass_AccountPgmSync')){
            Core_MDF_Account_PGM_Sync_ServiceHandler.processRecords(Trigger.new);
        }
    }
}