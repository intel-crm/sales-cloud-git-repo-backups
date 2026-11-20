public without sharing class Core_MDF_ProcessClaimPrediction {

    public static void executeAuditRulesFlow(List<Core_MDF_Claim_Prediction__c> ccfdcfClaimPredList, Map<Id,Core_MDF_Claim_Prediction__c> ccfdcfClaimPredOldMap,Boolean isInsert,Boolean isUpdate){
        
        List<Core_MDF_Claim_Prediction__c> claimListToBeSentToRulesEngine = new List<Core_MDF_Claim_Prediction__c>();
        
        if(ccfdcfClaimPredList != null && ccfdcfClaimPredList.size()>0){
            //call Narayani's new Audit rule engine
            Core_MDF_Audit_Rules_Processing.executePredictionFlow(ccfdcfClaimPredList);
            
        }
        
    }
}