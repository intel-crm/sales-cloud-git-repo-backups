public with sharing class UCD_ACM_AfterUpdateTriggerDealParent implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    static boolean runonce = true;
    public UCD_ACM_AfterUpdateTriggerDealParent() {

    }

    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts){
        
        system.debug('@@UCD_ACM_AfterUpdateTriggerDealParent');
        
    }
}