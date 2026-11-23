public class core_MDF_Batch_updateClmOnClmRecoveryIns implements Database.Batchable<sObject>,Database.stateful {
    public Map<Id,Core_MDF_Recovery__c> idToClaimMap = new Map<Id,Core_MDF_Recovery__c>();
    public set<Id> claimIds=new set<Id>();
    public core_MDF_Batch_updateClmOnClmRecoveryIns (Map<Id,Core_MDF_Recovery__c> idToClaimMap) {
        this.idToClaimMap = idToClaimMap;
        system.debug('idToClaimMap'+idToClaimMap);      
    }
    public Database.QueryLocator start(Database.BatchableContext bContext) {
        List<String> statusesNotAllowForRecovery= Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Status_not_allowed_for_Recovery');
        String claimType=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Type');
        set<Id> claimIds=new set<Id>();
        claimIds=idToClaimMap.keySet();
        system.debug('cliamIds'+claimIds);
        String strQuery = '';
        
        strQuery ='SELECT Id,Amount,Core_MDF_Status__c, Title, Core_MDF_Total_Claim_Recovery_Amount__c from PartnerFundClaim where Id IN:claimIds AND Core_MDF_Status__c NOT IN: statusesNotAllowForRecovery AND Core_MDF_Type_Txt__c=:claimType';
        system.debug('query'+strQuery);
        return Database.getQueryLocator(strQuery);   
    }
    public void execute(Database.BatchableContext bContext, List<PartnerFundClaim> claimList) {
        List<PartnerFundClaim> updatedClaimsList=new List<PartnerFundClaim>();
        system.debug('claimList'+claimList);
        if(!claimList.isEmpty()){
            
            for(PartnerFundClaim claim:claimList){
                //checking if claim amount is greater that recovery amount,reducing recovery amount from claim amount
                if(claim.Amount!=Null && claim.Amount>0 && idToClaimMap.containsKey(claim.id)&&
                   idToClaimMap.get(claim.id).Core_MDF_Amount_Amt__c!=Null){
                       system.debug('idToClaimMap data'+idToClaimMap.get(claim.id).Core_MDF_Amount_Amt__c);
                       if(claim.Amount>=idToClaimMap.get(claim.id).Core_MDF_Amount_Amt__c ){
                           system.debug('85');
                           claim.Amount=(claim.Amount - idToClaimMap.get(claim.id).Core_MDF_Amount_Amt__c);
                           system.debug('claimamount'+claim.Amount);
                           //update claim status to Paid if amount on claim is 0
                           if(claim.Amount==0){
                               system.debug('89');
                               claim.Core_MDF_Status__c=Label.Core_MDF_Status_Paid;
                               system.debug('status'+claim.Core_MDF_Status__c);
                           }
                       }
                       updatedClaimsList.add(claim);
                       system.debug('idToClaimMap'+idToClaimMap);
                   }
                
            }
            if(!updatedClaimsList.isempty()){
                update updatedClaimsList;
            }
            
        }
        
    }
    public void finish(Database.BatchableContext bContext) {
        
    }
    
}