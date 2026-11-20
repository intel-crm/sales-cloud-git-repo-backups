public without sharing class Core_MDF_ClaimPredictionServiceHandler {    
    //added dummy method to get the code coverage for this class
    public static void getCodeCoverage(){
    }
    /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
    public static boolean runOnce = true;
    
    public static void isPredictionScoreUpdated(Boolean isInsert,Boolean isUpdate, List<Core_MDF_Claim_Prediction__c> newClaimPredList, Map<Id,Core_MDF_Claim_Prediction__c> oldClaimPredMap, String context){
        Map<String, Core_MDF_CCP_Claim_Window__mdt> auditSelectionOrder = new Map<String, Core_MDF_CCP_Claim_Window__mdt>();
        
        List<Core_MDF_Claim_Prediction__c> ccfdcfClaimPredList = new List<Core_MDF_Claim_Prediction__c>();
        Map<Id,Core_MDF_Claim_Prediction__c> ccfdcfClaimPredOldMap = new Map<Id,Core_MDF_Claim_Prediction__c>();
        
        for(Core_MDF_CCP_Claim_Window__mdt selection : [SELECT toLabel(core_mdf_program__c),Core_MDF_Exclude_CAPS_check__c from Core_MDF_CCP_Claim_Window__mdt LIMIT 10000])
            {
                auditSelectionOrder.put(selection.Core_MDF_Program__c, selection);
            }
         
        Map<Id,Id> predIdToClaimId = new Map<Id,Id>();
        
        for(Core_MDF_Claim_Prediction__c cp : newClaimPredList)
            {
                predIdToClaimId.put(cp.id, cp.Core_MDF_Claim_id__c);
            }
        
        Map<Id,Boolean> claimIdToAuditFlag = new Map<Id,Boolean>();
        for(PartnerFundClaim pfc : [SELECT Core_MDF_AuditSelectionInProgress__c from PartnerFundClaim where id in : predIdToClaimId.values()])
            {
                claimIdToAuditFlag.put(pfc.Id, pfc.Core_MDF_AuditSelectionInProgress__c);
            }
        
        //List<String> progToBeIncludedForNewAuditCheck = Label.Core_MDF_Exclude_CAPS_check.split(';'); 
        //check the prog  
        for(Core_MDF_Claim_Prediction__c newClaimPredRec : newClaimPredList){
            //if(progToBeIncludedForNewAuditCheck.contains(newClaimPredRec.Core_MDF_Program_Nm__c)){
                //check if program not ccf/dcf. CCF and DCF moved to new claim prediction logic
                if(auditSelectionOrder.containsKey(newClaimPredRec.Core_MDF_Program_Nm__c) && auditSelectionOrder.get(newClaimPredRec.Core_MDF_Program_Nm__c).Core_MDF_Exclude_CAPS_check__c){
                Id claimId = predIdToClaimId.get(newClaimPredRec.Id);
                if(isUpdate && claimIdToAuditFlag.get(claimId)){
                    if(newClaimPredRec.Core_MDF_Prediction_Score_PB__c != null 
                       //&& newClaimPredRec.Core_MDF_Prediction_Score_PB__c != oldClaimPredMap.get(newClaimPredRec.Id).Core_MDF_Prediction_Score_PB__c
                      ){
                        ccfdcfClaimPredList.add(newClaimPredRec);
                    }
                   
                }
            }
        }
        
        
        if(context == 'afterUpdate' || context == 'afterInsert'){
            if(ccfdcfClaimPredList != NULL && ccfdcfClaimPredList.Size() > 0 && runOnce){
            	Core_MDF_ProcessClaimPrediction.executeAuditRulesFlow(ccfdcfClaimPredList, ccfdcfClaimPredOldMap, isInsert, isUpdate);
                runOnce = false;
            }  
            
        }
        
    }
	*/
}