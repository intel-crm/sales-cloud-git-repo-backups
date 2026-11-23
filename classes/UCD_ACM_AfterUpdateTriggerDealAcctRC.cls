public with sharing class UCD_ACM_AfterUpdateTriggerDealAcctRC implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    static boolean runonce = true;
    public UCD_ACM_AfterUpdateTriggerDealAcctRC() {

    }

    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts){
        if(runonce){
            system.debug('@@UCD_ACM_AfterUpdateTriggerDealAcctRC');
        }
        runonce=false;
        
    }
}