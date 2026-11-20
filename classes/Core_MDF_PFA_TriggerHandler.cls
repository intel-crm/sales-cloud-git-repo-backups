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

    public override void beforeInsert(){
        if (isActive('Core_MDF_PFA_BeforeInsert')) {
            //Populate unique field on Allocation
            if(!Core_MDF_Utility.byPassFeature('Bypass_UniqueFieldPopulationAllocation')){
                Core_MDF_PFA_ServiceHandler.populateUniqueField((List<PartnerFundAllocation>) Trigger.new, null);
            }
        }
    }

    public override void beforeUpdate(){
        if (isActive('Core_MDF_PFA_BeforeUpdate')) {
            //Populate unique field on Allocation
            if(!Core_MDF_Utility.byPassFeature('Bypass_UniqueFieldPopulationAllocation')){
                Core_MDF_PFA_ServiceHandler.populateUniqueField((List<PartnerFundAllocation>) Trigger.new, (Map<Id,PartnerFundAllocation>) Trigger.oldMap);
            }
        }
    }


    public override void afterInsert(){
        if (isActive('Core_MDF_PFA_AfterInsert')) {

            if(!Core_MDF_Utility.byPassFeature('Bypass_SharePfaWithAccountExtGrp')){
                Core_MDF_PFA_ServiceHandler.sharePfaWithAccountExternalGroup((Map<Id,PartnerFundAllocation>) Trigger.newMap);
            }
            if(!Core_MDF_Utility.byPassFeature('Bypass_GeoBased_Allocation_Sharing')){
                Core_MDF_PFA_ServiceHandler.invokeAllocationShareRecordToGeoGroup(Trigger.new);
            }
        }
    }
    public override void afterUpdate(){
        if (isActive('Core_MDF_PFA_AfterUpdate')) {

            
            Core_MDF_PFA_ServiceHandler.sharePfaWithGroupsOnUpdate((Map<Id,PartnerFundAllocation>) Trigger.newMap, Trigger.old);
            
            //Bypass allocation reservation after update trigger 
            if(!Core_MDF_Utility.byPassFeature('Bypass_Allocation_Reservation'))
                Core_MDF_PFA_ServiceHandler.checkUpdatedAllocations((List<PartnerFundAllocation>) trigger.new, (Map<Id, PartnerFundAllocation>) trigger.oldMap);
        }
       
    }
    
}