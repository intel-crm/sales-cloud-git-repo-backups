/****************************************************************************************************************************************
* Class Name  : Core_MDF_PartnerRequestTriggerHandler
* Version     : 1.0 
* Created Date: 08-21-2018
* Modification Log :
* Developer                     Date                        Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi     8/21/2018                    Created for extending Trigger framework to process campaign business logic methods.
* Accenture - Shridhar K       12/23/2018                   Added recallApprovalProcess.
* Intel - NP(11630236)         26-06-2020        US700310: Sync up Activity updates on Case (if any)
* Ganapati                     08/18/2020                   US758619 - To share activity to account manager's group
*****************************************************************************************************************************************/
public class Core_MDF_PartnerRequestTriggerHandler extends TriggerHandler
{
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll(); 
    public static String userid = UserInfo.getUserId();
    boolean triggerFlag,platformEventFlag,atfUpdateCheck;
 //Commented by Sushma as there was no implmentation of this method call
    // Enabled by Sridhar as need to call the close activity close date update  
 public override void beforeInsert()
    {
        // Call for close logic
        if (isActive('Core_MDF_PFR_Before_Insert'))
        {
                if(!Core_MDF_Utility.byPassFeature('Bypass_UpdateActivityFields')){
                   
                    Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert((List<PartnerFundRequest>) Trigger.new);
                }
                if(!Core_MDF_Utility.byPassFeature('Bypass_ValidateActivityWithCampaign')){
                    Core_MDF_ProcessCCP_PartnerFundRequest.validateActivityWithCampaign((Map<Id,PartnerFundRequest>) Trigger.oldMap,(List<PartnerFundRequest>) Trigger.new);
                }
                if(isActive('Core_MDF_Product_Category_Split')){
                    
                } 
                //Auto Budget Transfer for EEF Program
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_Frwd_AutoBdgtTransfer')&& !Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_Before_FrwdBT')) {
                Core_MDF_Process_PartnerFundRequest.activityAutoBudgetTransferForward((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap ,Trigger.isBefore , Trigger.isAfter);
                }
                Core_MDF_Process_PartnerFundRequest.callRuleEngine((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap,Trigger.isInsert,Trigger.isBefore); 
                          
                //validate accounts on Activity with PNUM records.
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPassValidatePNUM')){
                    Core_MDF_Process_PartnerFundRequest.validatePNUMForExternalUsers((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap);
                }
                //Akash - Validate budget type of campaign and activity
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ValidateBudType')){
                    Core_MDF_Process_PartnerFundRequest.validateBudgetType((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap);
                }
            //Rishabh - Only one Activity can be created for an Outcome-Based Proposal Campaign. 
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPass_OneActivityperCampaign')){
                    Core_MDF_Process_PartnerFundRequest.oneActivityperCampaign((List<PartnerFundRequest>) Trigger.new);
                }  
                
        }
                   
    }
    
    public override void beforeUpdate() 
    {
        //Avoid Deeply Nested IF Statements
        triggerFlag = isActive('Core_MDF_PFR_Before_Update');
        atfUpdateCheck = isATFFlagUpdated((Map<Id,PartnerFundRequest>)Trigger.oldMap,(List<PartnerFundRequest>)Trigger.new);
        
       if(triggerFlag && !(System.isBatch() && atfUpdateCheck) && !Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ATFBatchUpdate'))
        {
       // if (isActive('Core_MDF_PFR_Before_Update')){
                
                //to bypass query exceution in test classes
                if(!Core_MDF_Utility.byPassFeature('Bypass_UpdateActivityFields')){
                    
                    
                    Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsUpdate((Map<Id,PartnerFundRequest>) Trigger.newMap, (Map<Id,PartnerFundRequest>) Trigger.oldMap);
                }
                if(!Core_MDF_Utility.byPassFeature('Bypass_ValidateActivityWithCampaign')){
                    Core_MDF_ProcessCCP_PartnerFundRequest.validateActivityWithCampaign((Map<Id,PartnerFundRequest>) Trigger.oldMap,(List<PartnerFundRequest>) Trigger.new);
                }
          
                if(!Core_MDF_Utility.byPassFeature('byPass_Cancel_Activity')){
                    Core_MDF_CheckStatusAndDate.checkValidClaims((Map<Id,PartnerFundRequest>) Trigger.oldMap,(Map<Id,PartnerFundRequest>) Trigger.newMap);  
                }
                //Auto Budget Transfer for EEF Program
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_Frwd_AutoBdgtTransfer') && !Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_Before_FrwdBT')) {
                Core_MDF_Process_PartnerFundRequest.activityAutoBudgetTransferForward((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap ,Trigger.isBefore , Trigger.isAfter);
                }
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassCancelPFR')){
                    Core_MDF_ProcessCCP_PartnerFundRequest.cancelActivityForCancelledCliamsAndEsclations((Map<Id,PartnerFundRequest>) Trigger.newMap,(Map<Id,PartnerFundRequest>) Trigger.oldMap);
                }
                //RULE ENGINE CALL
                Core_MDF_Process_PartnerFundRequest.callRuleEngine((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap,Trigger.isInsert,Trigger.isBefore);
                            
                //validate accounts on Activity with PNUM records.
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPassValidatePNUM')){
                Core_MDF_Process_PartnerFundRequest.validatePNUMForExternalUsers((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap);
                }
                //Akash - Validate budget type of campaign and activity
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ValidateBudType')){
                    Core_MDF_Process_PartnerFundRequest.validateBudgetType((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap);
                }
                //Ramapriya - validate IPA In-progress activity field update against claims associated 
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ValidateInProgActEdit')){
                    Core_MDF_Process_PartnerFundRequest.validateInprogressPFRUpdates((Map<Id, PartnerFundRequest>) Trigger.oldMap,(Map<Id, PartnerFundRequest>) Trigger.newMap);
                }

        //}
        }
    }
    
    public override void afterInsert()
    {
        triggerFlag = isActive('Core_MDF_PFR_Insert');
        //Akash - Calling publishActivityPlatformEvent from After Insert
        platformEventFlag = isActive('Core_MDF_Activity_Platform_Event');
        
        if(triggerFlag)
        {
                if(platformEventFlag)
                {
                  Core_MDF_ProcessCCP_PartnerFundRequest.publishActivityPlatformEvent((List<PartnerFundRequest>) Trigger.new, null);
                }
                Core_MDF_ProcessCCP_PartnerFundRequest.updateTotalCampaignCostIpa((Map<Id,PartnerFundRequest>) Trigger.oldMap,(List<PartnerFundRequest>) Trigger.new, true);
                //Avoid Deeply Nested IF Statements
                //if(isActive('Core_MDF_PFR_Sharing')){
                    if(isActive('Core_MDF_PFR_Sharing') && !Core_MDF_Utility.byPassFeature('Bypass_ShareActivityWithUsers')){
                        Core_MDF_ProcessCCP_PartnerFundRequest.shareActivityWithUsers((Map<Id,PartnerFundRequest>) Trigger.newMap);
                    }

                    if(isActive('Core_MDF_PFR_Sharing') && isActive('Core_MDF_PFR_Node_Sharing')){
                         if(!Core_MDF_Utility.byPassFeature('Bypass_ShareActivityWithAccNodeGroup')){
                            Core_MDF_ProcessCCP_PartnerFundRequest.shareActivityWithAccNodeGroupMethod((Map<Id,PartnerFundRequest>) Trigger.newMap, (Map<Id,PartnerFundRequest>) Trigger.oldMap);
                         }
                    }
                //}
                Core_MDF_Process_PartnerFundRequest.callRuleEngine((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap,Trigger.isInsert,Trigger.isBefore);
                //Auto Budget Transfer for EEF Program

                if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_Frwd_AutoBdgtTransfer') && !Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_After_FrwdBT')) {
                Core_MDF_Process_PartnerFundRequest.activityAutoBudgetTransferForward((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap ,Trigger.isBefore , Trigger.isAfter);
                }

            if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_IntelOwnerNotification')){
                Core_MDF_SendPFREmailNotification.sendNotificationEmailToIntelOwner((List<PartnerFundRequest>) Trigger.new,(Map<Id, PartnerFundRequest>) Trigger.oldMap, Trigger.isInsert);
            }
        }
    }
    
    public override void afterUpdate()
    {      
        triggerFlag = isActive('Core_MDF_PFR_Update');
        boolean recallFlag = isActive('Core_MDF_Activity_Recall');
        platformEventFlag = isActive('Core_MDF_Activity_Platform_Event');
       
        atfUpdateCheck = isATFFlagUpdated((Map<Id,PartnerFundRequest>)Trigger.oldMap,(List<PartnerFundRequest>)Trigger.new);
        
        
        if(triggerFlag && !(System.isBatch() && atfUpdateCheck) && !Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ATFBatchUpdate'))
        {
                Core_MDF_ProcessCCP_PartnerFundRequest.updateTotalCampaignCostIpa((Map<Id,PartnerFundRequest>) Trigger.oldMap,(List<PartnerFundRequest>) Trigger.new, true);    
                //Akash
                Core_MDF_Outcome_Acc_Based_Activity.handleParentActivityUpdates((Map<Id, PartnerFundRequest>)Trigger.newMap,(Map<Id, PartnerFundRequest>)Trigger.oldMap);
                    //Evaluate the rule engine for approval
                Core_MDF_Process_PartnerFundRequest.callRuleEngine((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap,Trigger.isInsert,Trigger.isBefore);                
                //Auto Budget Transfer for EEF Program
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_Frwd_AutoBdgtTransfer') && !Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_After_FrwdBT')) {              
                 Core_MDF_Process_PartnerFundRequest.activityAutoBudgetTransferForward((List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap ,Trigger.isBefore ,Trigger.isAfter);
                    }
                //Added by Shridhar K to call recallApprovalProcess
                //Avoid Deeply Nested IF Statements
                if(recallFlag && !Core_MDF_Utility.byPassFeature('Bypass_geoLeadApprovalProcess'))
                {
                    //if(!Core_MDF_Utility.byPassFeature('Bypass_geoLeadApprovalProcess')){
                        //analyse the below method:recallApprovalActivities
                        boolean result = Core_MDF_Process_PartnerFundRequest.recallApprovalActivities( (List<PartnerFundRequest>) Trigger.new,(Map<Id,PartnerFundRequest>) Trigger.oldMap);
                    //}
                   // Core_MDF_ProcessCCP_PartnerFundRequest.recallApprovalProcess( (List<PartnerFundRequest>) Trigger.new, (Map<id,PartnerFundRequest>) Trigger.oldMap);
                }
                //Avoid Deeply Nested IF Statements
                //if(isActive('Core_MDF_PFR_Sharing')){
                    
                    if(isActive('Core_MDF_PFR_Sharing') && mapFunctionalityNameTriggerExecution != null && 
                       (!mapFunctionalityNameTriggerExecution.containsKey('ShareActivityWithInternalUsers_Bypass') ||
                       (mapFunctionalityNameTriggerExecution.containsKey('ShareActivityWithInternalUsers_Bypass') && 
                      !mapFunctionalityNameTriggerExecution.get('ShareActivityWithInternalUsers_Bypass').Core_Active__c))){
                         Core_MDF_ProcessCCP_PartnerFundRequest.shareActivityWithInternalUsers((Map<Id,PartnerFundRequest>) Trigger.oldMap, (Map<Id,PartnerFundRequest>) Trigger.newMap);
                  
                       }
                     
                    if(isActive('Core_MDF_PFR_Sharing') && isActive('Core_MDF_PFR_Node_Sharing')){
                         if(!Core_MDF_Utility.byPassFeature('Bypass_ShareActivityWithAccNodeGroup')){
                            Core_MDF_ProcessCCP_PartnerFundRequest.shareActivityWithAccNodeGroupMethod((Map<Id,PartnerFundRequest>) Trigger.newMap, (Map<Id,PartnerFundRequest>) Trigger.oldMap);
                         }
                    }
                  //} 
                if(platformEventFlag)
                {
                  Core_MDF_ProcessCCP_PartnerFundRequest.publishActivityPlatformEvent((List<PartnerFundRequest>) Trigger.new, (Map<Id,PartnerFundRequest>) Trigger.oldMap);
                }
               
                //Sync up Activity updates on Case (if any)
                if(isActive('Core_MDF_Activity_Case_Sync')){
                    Core_MDF_ClaimReviewCaseProcess.checkForActivityUpdates((Map<Id,PartnerFundRequest>) Trigger.newMap, (Map<Id,PartnerFundRequest>) Trigger.oldMap); 
                }
                
                
            
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_IntelOwnerNotification')){
                Core_MDF_SendPFREmailNotification.sendNotificationEmailToIntelOwner((List<PartnerFundRequest>) Trigger.new,(Map<Id, PartnerFundRequest>) Trigger.oldMap, Trigger.isInsert);
            }
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_PFREmailNotification')){
                Core_MDF_SendPFREmailNotification.pfrStatusChangeEmail((List<PartnerFundRequest>) Trigger.new,(Map<Id, PartnerFundRequest>) Trigger.oldMap);
            }
             if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_Rev_AutoBdgtTransfer')) {
                Core_MDF_Process_PartnerFundRequest.activityAutoBudgetTransferReversal((Map<Id,PartnerFundRequest>) Trigger.newMap,(Map<Id,PartnerFundRequest>) Trigger.oldMap );
                }
        }

    }
    public static Boolean isATFFlagUpdated(Map<Id,PartnerFundRequest> pfrOldMap, list<PartnerFundRequest> pfrNewList)
    {
        Boolean atfUpdateFlag = false;
        for(partnerFundRequest pfrnew : pfrNewList)
        {
            if(pfrOldMap.get(pfrnew.id).Core_MDF_ATF_Flag_nm__c!= pfrnew.Core_MDF_ATF_Flag_nm__c)
            {
                atfUpdateFlag = true;
            }
            break;
        }
        return atfUpdateFlag;
    }
}