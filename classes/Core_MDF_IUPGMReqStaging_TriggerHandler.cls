/****************************************************************************************************************************************
* Class Name       : Core_MDF_IUPGMReqStaging_TriggerHandler 
* Version          : 1.0 
* Created Date     : 03/04/2026
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Ramapriya       03/04/2026         Created for extending Trigger framework to process 
												 IUPGM Request Staging business logic methods.
*****************************************************************************************************************************************/
public class Core_MDF_IUPGMReqStaging_TriggerHandler extends TriggerHandler {

    public override void afterInsert(){

        System.debug('AFTER INSERT START');

        Boolean active = isActive('Core_MDF_afterInsertIUPGMRequest');
        System.debug('isActive(afterInsert): ' + active);

        if(active){
            System.debug('Calling Service Handler (Insert)');
            Core_MDF_IUPGMReqStaging_ServiceHandler.processRequests(
                (List<Core_MDF_IUPGM_Request_Staging__c>)Trigger.new
            );
        } else {
            System.debug('afterInsert is inactive');
        }
    }

    public override void afterUpdate(){

        System.debug('AFTER UPDATE START');

        Boolean active = isActive('Core_MDF_afterUpdateIUPGMRequest');
        System.debug('isActive(afterUpdate): ' + active);

        if(active){
            System.debug('Calling Service Handler (Update)');
            Core_MDF_IUPGMReqStaging_ServiceHandler.processRequests(
                (List<Core_MDF_IUPGM_Request_Staging__c>)Trigger.new
            );
        } else {
            System.debug('afterUpdate is inactive');
        }
    }
}