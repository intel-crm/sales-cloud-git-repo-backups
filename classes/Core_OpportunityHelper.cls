public class Core_OpportunityHelper extends TriggerHandler {
    
    map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public override void afterInsert() {
        Opportunity opp = (Opportunity)Trigger.new[0];
        
        if (mapFunctionalityNameTriggerExecution.containsKey('crmOpportunityHandler') &&
            mapFunctionalityNameTriggerExecution.get('crmOpportunityHandler').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                CRM_OpportunityHandler.AfterOptyFieldUpdate(trigger.new,(Map<Id,Opportunity>)Trigger.newMap,Trigger.old,(Map<Id,Opportunity>)Trigger.OldMap,true,false);
            }
        
        if (mapFunctionalityNameTriggerExecution.containsKey('opportunityTechnicalOwnerUpdate') &&
                mapFunctionalityNameTriggerExecution.get('opportunityTechnicalOwnerUpdate').Core_Active__c && !opp.Core_Created_from_CPQ__c)
            Core_OpportunityHandler.opportunityTechnicalOwnerUpdate(new Map<Id,Opportunity>{}, (Map<Id,Opportunity>)Trigger.Newmap , False);
        
        
        //Added by Sanket(Infosys Team) for the US661969 on 14/9/2020
        //Navneet To Bypass the KPI Call
       if (mapFunctionalityNameTriggerExecution.containsKey('OpportunityKPIJSON') && mapFunctionalityNameTriggerExecution.get('OpportunityKPIJSON').Core_Active__c && !opp.Core_Created_from_CPQ__c && !system.label.get('','Core_Bypass_Users_CRM_KPI').contains(UserInfo.getUserEmail())) {
                Core_OpportunityHandler.createOppJSONInsert(Trigger.New);
            }
        //Call FEDCRMshare
       if (mapFunctionalityNameTriggerExecution.containsKey('FedCRMShareUnshare') && mapFunctionalityNameTriggerExecution.get('FedCRMShareUnshare').Core_Active__c && !opp.Core_Created_from_CPQ__c){
           Core_OpportunityHandler.FedCRMOpportunityShare(Trigger.New, (Map < Id, Opportunity > ) Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
       }
    }
    
    public override void afterUpdate() {    
        Opportunity opp = (Opportunity)Trigger.new[0]; 
        
        if (mapFunctionalityNameTriggerExecution.containsKey('crmOpportunityHandler') &&
            mapFunctionalityNameTriggerExecution.get('crmOpportunityHandler').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                CRM_OpportunityHandler.AfterOptyFieldUpdate(trigger.new,(Map<Id,Opportunity>)Trigger.newMap,Trigger.old,(Map<Id,Opportunity>)Trigger.OldMap,false,true);
            }
        
        //Opportunity Lock Fields
        if (mapFunctionalityNameTriggerExecution.containsKey('OpportunityLockFields') &&
            mapFunctionalityNameTriggerExecution.get('OpportunityLockFields').Core_Active__c)
            Core_OpportunityHandler.ValidateLockFields(Trigger.New, (Map<Id,Opportunity>)Trigger.oldMap);
        
        if (mapFunctionalityNameTriggerExecution.containsKey('POPCheckOnUpdate') &&
            mapFunctionalityNameTriggerExecution.get('POPCheckOnUpdate').Core_Active__c && !opp.Core_Created_from_CPQ__c && !opp.CRM_IsLowTouchAdmin_Chk__c){
                Core_POP_Handler.popCheckOnApproval(Trigger.New, (Map<Id,Opportunity>)Trigger.oldMap);
                Core_POP_Handler.popCheckOnPWApproval(Trigger.New, (Map < Id, Opportunity > ) Trigger.oldMap);
            }//TWC3123-3676- Added check POP for PW(Production Win) approval.
        
        //Technical owner and Cim Id Check 
        if (mapFunctionalityNameTriggerExecution.containsKey('Tech_CIMID_Validation') &&
            mapFunctionalityNameTriggerExecution.get('Tech_CIMID_Validation').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                Core_POP_Handler.TechOwnerCIMIdValidation(Trigger.New, (Map<Id,Opportunity>)Trigger.oldMap);
            }
        
        if (mapFunctionalityNameTriggerExecution.containsKey('updateProductLineItems') &&
            mapFunctionalityNameTriggerExecution.get('updateProductLineItems').Core_Active__c && !opp.Core_Created_from_CPQ__c)
        { 
            
            Core_OppApproval.updateProductLineItems((Map<Id,Opportunity>)Trigger.oldMap, Trigger.new);}
        
        //Call the method to update the technical owner on a opportunity
        if (mapFunctionalityNameTriggerExecution.containsKey('opportunityTechnicalOwnerUpdate') &&
            mapFunctionalityNameTriggerExecution.get('opportunityTechnicalOwnerUpdate').Core_Active__c && !opp.Core_Created_from_CPQ__c)
            Core_OpportunityHandler.opportunityTechnicalOwnerUpdate((Map<Id,Opportunity>)Trigger.Oldmap, (Map<Id,Opportunity>)Trigger.Newmap , True);
        
        //Call the method to update Pending line items to Lost/Cancelled if opportunity is Lost/Cancelled
        if (Core_OpportunityHandler_2.isNonCloneFunction && mapFunctionalityNameTriggerExecution.containsKey('opportunityStageUpdate') &&
            mapFunctionalityNameTriggerExecution.get('opportunityStageUpdate').Core_Active__c && !opp.Core_Created_from_CPQ__c)
            Core_OpportunityHandler.opportunityStageUpdate((Map<Id,Opportunity>)Trigger.Oldmap,(Map<Id,Opportunity>) Trigger.Newmap);
        
        // Call the method to update the Amount, Volume of all the related marketing activites
        if (mapFunctionalityNameTriggerExecution.containsKey('updateActivityLineItems') &&
            mapFunctionalityNameTriggerExecution.get('updateActivityLineItems').Core_Active__c && !opp.Core_Created_from_CPQ__c)
            Core_OpportunityHandler.UpdateActivityLineItems(Trigger.New);
        
        //US83104 - Calling Forecast updation method to update the Forecast records and recalculate the quantity and quarter when Opportunity is being changed
        if (mapFunctionalityNameTriggerExecution.containsKey('forecastUpdateFromOppty') && mapFunctionalityNameTriggerExecution.get('forecastUpdateFromOppty').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
            Core_OpportunityHandler.updateForecastRecs(Trigger.New, (Map<Id,Opportunity>)Trigger.oldMap);
        }
        //Added by Sanket(Infosys Team) for the US661969 on 14/9/2020
        //Added by Navneet to bypass the KPI Call
        if (mapFunctionalityNameTriggerExecution.containsKey('OpportunityKPIJSON') && mapFunctionalityNameTriggerExecution.get('OpportunityKPIJSON').Core_Active__c && !opp.Core_Created_from_CPQ__c && !system.label.get('','Core_Bypass_Users_CRM_KPI').contains(UserInfo.getUserEmail())) {
            Core_OpportunityHandler.createOppJSONUpdate(Trigger.New,(Map<Id,Opportunity>)Trigger.OldMap);
        }
        //Added by Megha(Infosys Team) for the TWC3123-2303 on 24/8/2022
        if (mapFunctionalityNameTriggerExecution.containsKey('delegateApproverRoleChange') &&
            mapFunctionalityNameTriggerExecution.get('delegateApproverRoleChange').Core_Active__c) {
                Core_DelegateApproverOppShare.postOpportunityShare((Map<Id,Opportunity>)Trigger.oldMap,(Map<Id,Opportunity>)Trigger.newMap);
            }
        //To retrigger 6QPS auto calculation added by Ketki(Accenture team) for TWC3123-3794 
        if (mapFunctionalityNameTriggerExecution.containsKey('OpportunityAutoCalculate6QPS') &&
            mapFunctionalityNameTriggerExecution.get('OpportunityAutoCalculate6QPS').Core_Active__c) {
                //Core_OpportunityHandler.retrigger6QPSCalcOnUpdate(Trigger.New, (Map < Id, Opportunity > ) Trigger.oldMap);
            }
        //Trigger to update role sharing after change of technical owner to partner owner for Partner-Led Opportunity.
        if (mapFunctionalityNameTriggerExecution.containsKey('OpportunityShare') &&
            mapFunctionalityNameTriggerExecution.get('OpportunityShare').Core_Active__c) {
                Core_OpportunityHandler.OpportunityShare(Trigger.New, (Map < Id, Opportunity > ) Trigger.oldMap);
            }
        //TWC4767-931 : Technical Owner team member creation
        if (mapFunctionalityNameTriggerExecution.containsKey('TechnicalOwnerAdditiontoTM') &&
            mapFunctionalityNameTriggerExecution.get('TechnicalOwnerAdditiontoTM').Core_Active__c) {
                Core_OpportunityHandler_2.checkOppStatus(Trigger.New);
            }
        //CallFedCRMShare
        if (mapFunctionalityNameTriggerExecution.containsKey('FedCRMShareUnshare') && mapFunctionalityNameTriggerExecution.get('FedCRMShareUnshare').Core_Active__c){
            Core_OpportunityHandler.FedCRMOpportunityShare(Trigger.New, (Map < Id, Opportunity > ) Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
        }
        
        //Added as part of TWC3123-5419 by Hira for point-> Any update to DW opportunity in stage DW including the submission - > update the pw qty, sales price from DW field for blank values)
        if(mapFunctionalityNameTriggerExecution.containsKey('updatePWFieldsonProduct') && mapFunctionalityNameTriggerExecution.get('updatePWFieldsonProduct').Core_Active__c && !Core_OpportunityLineItemHandler.updateForecastRecordsRecCheck){
           Core_OpportunityHandler.updatePWFieldsonProduct(Trigger.New);
        }
        
        /*if (mapFunctionalityNameTriggerExecution.containsKey('OpportunityKPIfieldRefresh') &&
            mapFunctionalityNameTriggerExecution.get('OpportunityKPIfieldRefresh').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                Core_OpportunityHandler.OpportunityKPIBatchUpdate(Trigger.New, (Map<Id,Opportunity>)Trigger.oldMap);
            }*/
        
        if(mapFunctionalityNameTriggerExecution.containsKey('PCCDealRegOwnerOptyQuoteSync') && mapFunctionalityNameTriggerExecution.get('PCCDealRegOwnerOptyQuoteSync').Core_Active__c && !opp.Core_Created_from_CPQ__c){
            Core_OpportunityHandler.syncOwner_Opportunity_Quote(Trigger.New, (Map<Id,Opportunity>)Trigger.oldMap);
        }
        
        if(mapFunctionalityNameTriggerExecution.containsKey('ILO_syncStatus_Opportunity_IQRQuote') && mapFunctionalityNameTriggerExecution.get('ILO_syncStatus_Opportunity_IQRQuote').Core_Active__c && !opp.Core_Created_from_CPQ__c){
            Core_OpportunityHandler.syncStatus_Opportunity_IQRQuote(Trigger.New, (Map<Id,Opportunity>)Trigger.oldMap);
        }
        /*Utkarsh - Start - IPA Changes - Partner Deal Registration*/
        if(mapFunctionalityNameTriggerExecution.containsKey('PRM_PartnerDealSharing') && mapFunctionalityNameTriggerExecution.get('PRM_PartnerDealSharing').Core_Active__c){
            Core_OpportunityHandler_2.sharePRMDealOpptyToOpptyOwner(Trigger.New, (Map<Id,Opportunity>)Trigger.oldMap);
        }
        /*Utkarsh - End - IPA Changes - Partner Deal Registration*/
    }
    
    public override void beforeInsert() {
        Opportunity opp = (Opportunity)Trigger.new[0];
       
      //  Core_OpportunityHandler.checkOptyLockStatusBasedOnQuote((Map<Id,Opportunity>)Trigger.OldMap,  Trigger.New);
       if (mapFunctionalityNameTriggerExecution.containsKey('crmOpportunityHandler') &&
            mapFunctionalityNameTriggerExecution.get('crmOpportunityHandler').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                CRM_OpportunityHandler.BeforeOptyFieldUpdate(trigger.new,(Map<Id,Opportunity>)Trigger.newMap,Trigger.old,(Map<Id,Opportunity>)Trigger.OldMap,true,false);
            }
       
        if (mapFunctionalityNameTriggerExecution.containsKey('UpdateTerritoryInfoOnOppty') &&
            mapFunctionalityNameTriggerExecution.get('UpdateTerritoryInfoOnOppty').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                Core_OpportunityHandler.UpdateTerritoryInfoOnOppty(trigger.new,null,False);
            }
        
        if (mapFunctionalityNameTriggerExecution.containsKey('RestrictSolutionDetailLOV') &&
            mapFunctionalityNameTriggerExecution.get('RestrictSolutionDetailLOV').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                Core_OpportunityHandler.validateAllActiveLOV(Trigger.New,(Map<Id,Opportunity>)Trigger.OldMap,true);
            }
        
        if (mapFunctionalityNameTriggerExecution.containsKey('CombineSolutionDetailFields') &&
            mapFunctionalityNameTriggerExecution.get('CombineSolutionDetailFields').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                Core_OpportunityHandler.SolutionDetailCombine(Trigger.New,(Map<Id,Opportunity>)Trigger.OldMap);
            }
        
        ///Opportunity Uniqua Name validation - by Gaurav
        if (mapFunctionalityNameTriggerExecution.containsKey('UpdateForeCast') && mapFunctionalityNameTriggerExecution.get('UpdateForeCast').Core_Active__c) {
                Core_OpportunityHandler.validateUniqueOppInsert(Trigger.New);
            }
        
        //Opportunity Stage Update Blank fields Check - Added by Hira(Accenture Team) as a part of TWC3123-3502
        if (Core_OpportunityHandler_2.isNonCloneFunction && mapFunctionalityNameTriggerExecution.containsKey('OpportunityStageExitValidation') &&
            mapFunctionalityNameTriggerExecution.get('OpportunityStageExitValidation').Core_Active__c && !opp.Core_Created_from_CPQ__c && !opp.CRM_IsLowTouchAdmin_Chk__c && !opp.CRM_SW_Flag_Ind__c ) {
                Core_OpportunityHandler.restrictBlankFieldUpdates(Trigger.New,null,null,False);
            }
       //TWC3123-5650 call updateForecastCategoryOmmited
       /*if (mapFunctionalityNameTriggerExecution.containsKey('OmmitForecast') && mapFunctionalityNameTriggerExecution.get('OmmitForecast').Core_Active__c){
           Core_OpportunityHandler.updateForecastCategoryOmmited(Trigger.New,(Map<Id,Opportunity>)Trigger.OldMap);
       }*/
    }
    
    public override void beforeUpdate() {
        Opportunity opp = (Opportunity)Trigger.new[0];
        if (mapFunctionalityNameTriggerExecution.containsKey('crmOpportunityHandler') &&
            mapFunctionalityNameTriggerExecution.get('crmOpportunityHandler').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                CRM_OpportunityHandler.BeforeOptyFieldUpdate(trigger.new,(Map<Id,Opportunity>)Trigger.newMap,Trigger.old,(Map<Id,Opportunity>)Trigger.OldMap,false,true);
            }
        //For PCC Oppty, Lock the Opportunity when related Quote's any QuoteLine is in PFIR status - TWC3123-5659-Devashish
       if (!Core_CRM_Utility.oppLockValidationPerformed && mapFunctionalityNameTriggerExecution.containsKey('lockPCCOpportunity') && mapFunctionalityNameTriggerExecution.get('lockPCCOpportunity').Core_Active__c && !opp.Core_Created_from_CPQ__c){
            Core_OpportunityHandler.checkPCCOpptyLock(Trigger.new,(Map<Id,Opportunity>)Trigger.OldMap);
       }
                
        //Opportunity Lock Fields
        if (mapFunctionalityNameTriggerExecution.containsKey('OpportunityLockFields') &&
            mapFunctionalityNameTriggerExecution.get('OpportunityLockFields').Core_Active__c)
            Core_OpportunityHandler.ValidateLockFields(Trigger.New, (Map<Id,Opportunity>)Trigger.oldMap);
        
        if (mapFunctionalityNameTriggerExecution.containsKey('RestrictSolutionDetailLOV') &&
            mapFunctionalityNameTriggerExecution.get('RestrictSolutionDetailLOV').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                Core_OpportunityHandler.validateAllActiveLOV(Trigger.New,(Map<Id,Opportunity>)Trigger.OldMap,false);
            }
        
        if (mapFunctionalityNameTriggerExecution.containsKey('smgApprovalReversalSwitch') &&
            mapFunctionalityNameTriggerExecution.get('smgApprovalReversalSwitch').Core_Active__c){
                Core_OppApproval.smgGmcCheckApprovalRejection(Trigger.New, (Map<Id,Opportunity>)Trigger.oldMap);
            }// Added this switch logic as part of TWC3123-5580
        
        //DE63809 : Not getting an error message when user tries to update an historical data with old Solution area field LOV's
        if (mapFunctionalityNameTriggerExecution.containsKey('RestrictSolutionAreaInactiveLOV') &&
            mapFunctionalityNameTriggerExecution.get('RestrictSolutionAreaInactiveLOV').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                Core_OpportunityHandler.validateSolutionAreaInActiveLOV(Trigger.New);
            }
        
        if (mapFunctionalityNameTriggerExecution.containsKey('CombineSolutionDetailFields') &&
            mapFunctionalityNameTriggerExecution.get('CombineSolutionDetailFields').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                Core_OpportunityHandler.SolutionDetailCombine(Trigger.New,(Map<Id,Opportunity>)Trigger.OldMap); 
            }
        
        //Block user to select an existing opportunity while lead conversion
        /*if (mapFunctionalityNameTriggerExecution.containsKey('BlockExistingOppOnLeadConversion') &&
            mapFunctionalityNameTriggerExecution.get('BlockExistingOppOnLeadConversion').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                if (Core_OpportunityHandler.isExistingOpp) {
                    Core_OpportunityHandler.isExistingOpp = false;
                    Core_OpportunityHandler.BlockExistingOppOnLeadConversion(Trigger.New,(Map<Id,Opportunity>)Trigger.OldMap);
                }
            }*/
        if (mapFunctionalityNameTriggerExecution.containsKey('determineApprovers') &&
            mapFunctionalityNameTriggerExecution.get('determineApprovers').Core_Active__c && !opp.Core_Created_from_CPQ__c)
            
            Core_OppApproval.determineApprovers((Map<Id,Opportunity>)Trigger.oldMap, Trigger.new);
        
        // call method to populate territory information on opportunity               
        if (mapFunctionalityNameTriggerExecution.containsKey('UpdateTerritoryInfoOnOppty') &&
            mapFunctionalityNameTriggerExecution.get('UpdateTerritoryInfoOnOppty').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                Core_OpportunityHandler.UpdateTerritoryInfoOnOppty(trigger.new,(Map<Id,Opportunity>)Trigger.oldmap,True);
            }
        ///Opportunity Uniqua Name validation - by Gaurav
        if (mapFunctionalityNameTriggerExecution.containsKey('UpdateForeCast') && mapFunctionalityNameTriggerExecution.get('UpdateForeCast').Core_Active__c) {
                Core_OpportunityHandler.validateUniqueOppUpdate(Trigger.New, (Map<Id,Opportunity>)Trigger.OldMap);
            }
        
        //Opportunity Stage Update Blank fields Check - Added by Hira(Accenture Team) as a part of TWC3123-3502
        if (Core_OpportunityHandler_2.isNonCloneFunction && mapFunctionalityNameTriggerExecution.containsKey('OpportunityStageExitValidation') && mapFunctionalityNameTriggerExecution.get('OpportunityStageExitValidation').Core_Active__c && !opp.Core_Created_from_CPQ__c && !opp.CRM_IsLowTouchAdmin_Chk__c && !opp.CRM_SW_Flag_Ind__c) {
                Core_OpportunityHandler.restrictBlankFieldUpdates(Trigger.New,(Map<Id,Opportunity>)Trigger.OldMap,Trigger.Old,True);
            }
        
         //Refreshing PW KPI field on Opportunity - Added by Hira(Accenture Team)
        /* if (mapFunctionalityNameTriggerExecution.containsKey('OpportunityKPIfieldRefresh') &&
            mapFunctionalityNameTriggerExecution.get('OpportunityKPIfieldRefresh').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                Core_OpportunityHandler.OpportunityKPIfieldRefresh(Trigger.New, (Map<Id,Opportunity>)Trigger.oldMap);
            }*/

        //Storing the Description Of Contribution of Technical owner and Partner account owner into field whenever Opportunity Owner changed -TWC3123-4957
        if (mapFunctionalityNameTriggerExecution.containsKey('storeOppTeamMemDescription') &&
            mapFunctionalityNameTriggerExecution.get('storeOppTeamMemDescription').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
                Core_OpportunityHandler.storeOppTeamMemDescription((Map < Id,Opportunity>) Trigger.oldMap, (Map < Id,Opportunity>) Trigger.newMap);            
            }        
    }
    
    public override void beforeDelete() {
        Opportunity opp = (Opportunity)Trigger.old[0];
        
        if (mapFunctionalityNameTriggerExecution.containsKey('opportunityOppFactDelete') &&
            mapFunctionalityNameTriggerExecution.get('opportunityOppFactDelete').Core_Active__c && !opp.Core_Created_from_CPQ__c)
            Core_OpportunityHandler.opportunityOppFactDelete(Trigger.old);
        
        if (mapFunctionalityNameTriggerExecution.containsKey('deleteKPIonOpportunityDelete') && mapFunctionalityNameTriggerExecution.get('deleteKPIonOpportunityDelete').Core_Active__c && !opp.Core_Created_from_CPQ__c) {
            Core_OpportunityHandler.deleteNewKPI(Trigger.old);
        }
    }
}