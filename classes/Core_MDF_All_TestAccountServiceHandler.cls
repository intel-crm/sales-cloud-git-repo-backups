public without sharing class Core_MDF_All_TestAccountServiceHandler implements UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger, UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    public void execute( Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        try {
        
        System.debug('@@IBeforeUpdateAccountTrigger - '+Trigger.operationType);
        
        } catch (Exception ex) {
            system.debug('@@IBeforeUpdateAccountTrigger - Error');
        }
    }
    
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        try {
                      System.debug('@@IAfterUpdateAccountTrigger - '+Trigger.operationType);  
        
        } catch (Exception ex) {
            system.debug('@@IAfterUpdateAccountTrigger - Error');
        }
    }
}