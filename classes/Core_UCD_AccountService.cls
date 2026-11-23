public with sharing class Core_UCD_AccountService {
    public static IAccountService getServiceInstance(AccountType accountType){
        switch on accountType {
            when INTELACCOUNT {
                return Core_UCD_IntelAccount.getInstance();
            }
            when else {
                return null;    
            }
        }
    }    

    public enum AccountType {
        INTELACCOUNT
    }
}