public class Core_MDF_ClaimSelectionForAudit_Queable implements Queueable{
    List<PartnerFundClaim> claimListForAudit = new List<PartnerFundClaim>();
    
    public Core_MDF_ClaimSelectionForAudit_Queable(List<PartnerFundClaim> claimListForAudit) {
        this.claimListForAudit = claimListForAudit;
    }
    
    public void execute(System.QueueableContext qc) {
        List<PartnerFundClaim> claimListTobeUpdated = new List<PartnerFundClaim>();
        for(PartnerFundClaim pfcObj : claimListForAudit) {
            PartnerFundClaim pfc = new PartnerFundClaim();
            pfc.Id = pfcObj.Id;
            pfc.Core_MDF_Audit_Type__c = 'Random';            
            pfc.Core_MDF_FlaggedForAudit__c = TRUE;
            pfc.Core_MDF_Status__c = 'Hold';
            pfc.Core_MDF_Audit_Hold__c = TRUE;
            claimListTobeUpdated.add(pfc);
        }
        if(!claimListTobeUpdated.isEmpty()) {
            update claimListTobeUpdated;
        }   
    }
}