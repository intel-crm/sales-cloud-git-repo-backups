public class Core_MDF_SendClaimNotification implements Database.Batchable<sObject>{
    
    List<PartnerFundClaim> ClaimListUpdated= new List<PartnerFundClaim>();
    public Integer numberOfClaimsProcessed = 0;
    
    public Core_MDF_SendClaimNotification(List<PartnerFundClaim> claimList){
        system.debug('claimList::'+claimList);
        this.claimListUpdated=claimList;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query='Select Id,OwnerId,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c,Core_MDF_ESD_Hold__c from PartnerFundClaim WHERE Id IN : claimListUpdated';
         return Database.getQueryLocator(query);
    }
   
    public void execute(Database.BatchableContext bc,List<PartnerFundClaim> claimListUpdated){
        
      List<Core_MDF_GenericClassToSendMail.MailParams> emailInputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();     

         for(PartnerFundClaim pfc : claimListUpdated){
            List<Id> extUserIdList = new List<Id>();
            extUserIdList.add(pfc.OwnerId);
            system.debug('extUserIdList'+extUserIdList);
            if (pfc.Core_MDF_Status__c=='Hold' && pfc.Core_MDF_ESD_Hold__c==true){
                Core_MDF_GenericClassToSendMail.MailParams sendEmailToExt = new Core_MDF_GenericClassToSendMail.MailParams();
                sendEmailToExt.recordId = pfc.Id;
                sendEmailToExt.templateName = Label.Core_MDF_NotifyExternalUsersOnBankHold;
                sendEmailToExt.userIdList = extUserIdList;
                sendEmailToExt.sendDiff = false;
                numberOfClaimsProcessed++;
                emailInputList.add(sendEmailToExt);
                 system.debug('emailInputList'+emailInputList);
            }else if(pfc.Core_MDF_Status__c=='Pending Available Fund' && pfc.Core_MDF_Claim_Previous_Status__c=='Submitted'){
                Core_MDF_GenericClassToSendMail.MailParams sendEmailToExt = new Core_MDF_GenericClassToSendMail.MailParams();
                sendEmailToExt.recordId = pfc.Id;
                sendEmailToExt.templateName = Label.Core_MDF_NotifyExternalUsersOnBankRelease;
                sendEmailToExt.userIdList = extUserIdList;
                sendEmailToExt.sendDiff = false;
                numberOfClaimsProcessed++;
                emailInputList.add(sendEmailToExt);
            }            
        }
        //system.debug('emailInputList'+emailInputList);
        if(emailInputList!=null && emailInputList.size()>0){
            Core_MDF_GenericClassToSendMail.sendEmailMethod(emailInputList);
        }
    }
    public void finish(Database.BatchableContext bc){
        
    }
    
}