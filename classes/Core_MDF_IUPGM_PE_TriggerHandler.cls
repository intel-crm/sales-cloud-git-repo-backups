/****************************************************************************************************************************************
* Class Name  : Core_MDF_IUPGM_PE_TriggerHandler
* Version     : 1.0 
* Created Date: 05/18/2022
* Modification Log :
* Developer                     Date                        Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* JB - Accenture    		05/18/2022                    Created for extending Trigger framework to process the IUPGM Platform event logic.
* *****************************************************************************************************************************************/
public class Core_MDF_IUPGM_PE_TriggerHandler extends TriggerHandler{
    /*public override void afterInsert(){
        if(isActive('Core_MDF_AfterInsertIUPGM_PE')){
            if(!Core_MDF_Utility.byPassFeature('Bypass_Budget_ApproverRecordCreaion')){
                //Only for PartnerMarketingBudget Approval Process
                Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmIdToRecordsMap = Core_MDF_IUPGM_PE_ServiceHandler.filterIupgmRecordsBasedOnObjectType(Trigger.new, 'Budget Approval Criteria');
                if(iupgmIdToRecordsMap != null && !iupgmIdToRecordsMap.isEmpty()){
                    Core_MDF_IUPGM_PE_ServiceHandler.processParnterMarketingBudget(Trigger.new, iupgmIdToRecordsMap, 'Budget Approval Criteria');
                }
            }
        }
    }*/
}