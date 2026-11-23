public class updateClaimQueueable implements Queueable {
    public set<id> bnkIds;
    
    public updateClaimQueueable (List<string> bankIds) {
        bnkIds = new set<Id>();
        for(string bankId:bankIds) {
            bnkIds.add(bankId);
        }
    }
	public void execute(QueueableContext context) {
        
        List<PartnerFundClaim> partnerclaim = [SELECT Id,Core_MDF_Type_Txt__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Status__c,Core_MDF_ESD_Hold__c,Core_MDF_Bank__r.Core_MDF_Bank_Status__c,Core_MDF_Bank__r.Core_MDF_Hold_Payments_from_AP_file_ind__c,Core_MDF_Bank__r.Core_MDF_ESD_Hold_Indicator__c FROM PartnerFundClaim where Core_MDF_Bank__c IN:bnkIds];
        list<PartnerFundClaim> updateList = new list<PartnerFundClaim>();
        system.debug('partnerclaim----'+partnerclaim);
        system.debug('partnerclaim----'+partnerclaim.size());
        for(PartnerFundClaim claim:partnerclaim) {
            if(claim.Core_MDF_Type_Txt__c == 'Claim' && (claim.Core_MDF_Status__c == 'Submitted' ||
              claim.Core_MDF_Status__c == 'Payment Due' || claim.Core_MDF_Status__c == 'Pending Available Funds' || claim.Core_MDF_Status__c == 'Hold')) {
                  system.debug('enter---24---');
                  if(claim.Core_MDF_Bank__r.Core_MDF_ESD_Hold_Indicator__c == true){
                      system.debug('enter---26---');
                      claim.Core_MDF_ESD_Hold__c = true;
                      claim.Core_MDF_Status__c = 'Hold';
                  }
                  else if(claim.Core_MDF_Bank__r.Core_MDF_Hold_Payments_from_AP_file_ind__c == 'Yes'){
                      system.debug('enter---31---');
                      claim.Core_MDF_Payment_Hold_ind__c = true;
                      claim.Core_MDF_Status__c = 'Hold';
                  }
                  system.debug('claim----'+claim);
                updateList.add(claim);
                  
            }             
        }
        system.debug('updateList----'+updateList);
        if(updateList.size() > 0) {
            update updateList;
        }
    }
}