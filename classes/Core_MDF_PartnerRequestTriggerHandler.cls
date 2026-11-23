/****************************************************************************************************************************************
* Class Name  : Core_MDF_PartnerRequestTriggerHandler 
* Version     : 1.0 
* Created Date: 08-21-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi     8/21/2018                    Created for extending Trigger framework to process campaign business logic methods.
* Accenture - Shridhar K           12/23/2018                   Added recallApprovalProcess.
*****************************************************************************************************************************************/
public class Core_MDF_PartnerRequestTriggerHandler extends TriggerHandler
{
    
    boolean triggerFlag,approvalFlag;
    
    public override void beforeUpdate() 
    {
        if (isActive('Core_MDF_PFR_Before_Update')){
            Core_MDF_CheckStatusAndDate.checkValidClaims((Map<Id,PartnerFundRequest>) Trigger.oldMap,(Map<Id,PartnerFundRequest>) Trigger.newMap);
            Core_MDF_CheckStatusAndDate.checkClaimDate((Map<Id,PartnerFundRequest>) Trigger.oldMap,(Map<Id,PartnerFundRequest>) Trigger.newMap);
            // Call for close logic
            // test code begins
            Core_MDF_ProcessCCP_PartnerFundRequest.recallApprovalProcess( (List<PartnerFundRequest>) Trigger.new, (Map<id,PartnerFundRequest>) Trigger.oldMap);
            // test code ends
            Core_MDF_UpdateActivityFields.populateBackEndFieldsUpdate((Map<Id,PartnerFundRequest>) Trigger.newMap, (Map<Id,PartnerFundRequest>) Trigger.oldMap);
            //Core_MDF_ProcessCCP_PartnerFundRequest.shareActivityWithInternalUsers((Map<Id,PartnerFundRequest>) Trigger.oldMap, (Map<Id,PartnerFundRequest>) Trigger.newMap);
        }
    }
    
    public override void afterInsert()
    {
        triggerFlag = isActive('Core_MDF_PFR_Insert');
        approvalFlag = isActive('Core_MDF_PFR_Approval');
        
        if(triggerFlag)
        {
            if(approvalFlag)
            {
                Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess( (Map<id,PartnerFundRequest>) Trigger.newMap, (List<PartnerFundRequest>) Trigger.new, (List<SObject>) Trigger.new,false);
            }
            Core_MDF_ProcessCCP_PartnerFundRequest.shareActivityWithUsers((Map<Id,PartnerFundRequest>) Trigger.newMap);
        }
    }
    
    public override void afterUpdate()
    {      
        triggerFlag = isActive('Core_MDF_PFR_Update');
        approvalFlag = isActive('Core_MDF_PFR_Approval');
        boolean recallFlag = isActive('Core_MDF_Activity_Recall');
        if(triggerFlag)
        {
            if (Core_MDF_ProcessCCP_PartnerFundRequest.runOnce())
            {
                if(approvalFlag)
                {
                    Core_MDF_ProcessCCP_PartnerFundRequest.callApprovalProcess( (Map<id,PartnerFundRequest>) Trigger.newMap,(List<PartnerFundRequest>) Trigger.new, (List<SObject>) Trigger.new,false);
                }
            }
            //Added by Shridhar K to call recallApprovalProcess
            if(recallFlag)
            {
                Core_MDF_ProcessCCP_PartnerFundRequest.recallApprovalProcess( (List<PartnerFundRequest>) Trigger.new, (Map<id,PartnerFundRequest>) Trigger.oldMap);
            }
            Core_MDF_ProcessCCP_PartnerFundRequest.shareActivityWithInternalUsers((Map<Id,PartnerFundRequest>) Trigger.oldMap, (Map<Id,PartnerFundRequest>) Trigger.newMap);
        
        }
    } 
    //Commented by Sushma as there was no implmentation of this method call
    // Enabled by Sridhar as need to call the close activity close date update
    public override void beforeInsert()
    {
        // Call for close logic
        if (isActive('Core_MDF_PFR_Before_Insert'))
        {
        	Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert((List<PartnerFundRequest>) Trigger.new);
        }
    }
}