/****************************************************************************************************************************************
* Class Name  : Core_MDF_PartnerFundAllocationTriggerHandler 
* Version     : 1.0 
* Created Date: 8-6-2018
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - athoma10       8/6/2018           Created for extending Trigger framework to process 
                                            Partner Fund Allocation business logic methods.
*****************************************************************************************************************************************/
public class Core_MDF_PFA_TriggerHandler extends TriggerHandler {

    public Core_MDF_PFA_TriggerHandler(){

    }

    public override void afterInsert(){
        System.debug('Reached PFA Insert');
    
        //new Core_MDF_PFA_NodeSharing().ShareRecordsWithNode((Map<Id,PartnerFundAllocation>) Trigger.newMap);
    }
    public override void afterUpdate(){
       Core_MDF_PFA_ServiceHandler.checkUpdatedAllocations((List<PartnerFundAllocation>) trigger.new, (Map<Id, PartnerFundAllocation>) trigger.oldMap);
       
    }
    
}