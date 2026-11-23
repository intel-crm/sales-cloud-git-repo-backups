public class claimVfController {
    
    public string[] SelectedClaimIDs{get;set;}
    
    public claimVfController(ApexPages.StandardSetController listcontroller){
        SelectedClaimIDs = new string[]{};
            for(PartnerFundClaim claim : (PartnerFundClaim[])listcontroller.getSelected()){
                SelectedClaimIDs.add(claim.Id);
            }
        system.debug('SelectedClaimIDs - '+SelectedClaimIDs);
    }
    
}