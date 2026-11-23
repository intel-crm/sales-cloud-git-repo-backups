public without sharing class Core_IPA_AccountHelper {
    
    public static void isAccountEligibleForMDF(List<Account> newAccountList){
        Set<Account> setOfMdfBenefitAcc;
        Set<Account> setOfComarketingActiveAcc;
        Set<Account> setOfOpidAccounts;
        if(newAccountList!=null && newAccountList.size()>0){
        Set<Account> setOfIpaAccounts = isIpaAccount(newAccountList);
        if(setOfIpaAccounts!=null && setOfIpaAccounts.size()>0){
            setOfOpidAccounts = isOpiAccount(setOfIpaAccounts);
        }
        if(setOfOpidAccounts!=null && setOfOpidAccounts.size()>0){
            setOfComarketingActiveAcc = hasComarketingActive(setOfOpidAccounts);
        }
        if(setOfComarketingActiveAcc!=null && setOfComarketingActiveAcc.size()>0){
            setOfMdfBenefitAcc = hasMDFBenefit(setOfComarketingActiveAcc);
        }
        if(setOfMdfBenefitAcc!=null && setOfMdfBenefitAcc.size()>0){
            system.debug('all method passed - Account is not eligible fo MDF benefit - '+setOfMdfBenefitAcc);
            //Create Public Group
            //Create PGM
            //Create IPA Corp Node
			
			//onboardAccountToCCP  - program and account wrapper
        }else{
			//error
            for(Account acc : newAccountList){
                acc.addError('Account is not eligible fo MDF benefit');
            }
		}
        }
    }
    
    public static Set<Account> isIpaAccount(List<Account> newAccountList)
    {
        Set<Account> accountsToBeProcessed = new Set<Account>();
        if(newAccountList!=null && newAccountList.size()>0){
            for(Account account : newAccountList){
                if(account.Core_Intel_Partner_Alliance_PartnerGroup__c){
                    accountsToBeProcessed.add(account);
                }
            }
        }
        return accountsToBeProcessed;
    }
    
    public static Set<Account> isOpiAccount(Set<Account> newAccountSet)
    {
        Set<Account> accountsToBeProcessed = new Set<Account>();
        if(newAccountSet!=null && newAccountSet.size()>0){
            for(Account account : newAccountSet){
                if(account.Core_IPA_One_Partner_Id__c != null){
                    accountsToBeProcessed.add(account);
                }
            }
        }
        return accountsToBeProcessed;
    }
    
    public static Set<Account> hasComarketingActive(Set<Account> newAccountSet)
    {
        Set<Id> opidSet = new Set<Id>();
        Set<Account> accountsToBeProcessed = new Set<Account>();
        Map<Id,List<Account>> mapOfOpidToAcounts = new Map<Id,List<Account>>();
        for(Account account : newAccountSet){
            if(account.Core_IPA_One_Partner_Id__c !=null){
                opidSet.add(account.Core_IPA_One_Partner_Id__c);
            }
        }
        
        List<Account> listOfExistingAccounts = [Select Id,Core_IPA_One_Partner_Id__c from Account where Core_IPA_One_Partner_Id__c IN: (opidSet) and Core_MDF_CoMarketingActive__c = true];
        
        for(Account account : listOfExistingAccounts){
            if(mapOfOpidToAcounts.containsKey(account.Core_IPA_One_Partner_Id__c)){
                mapOfOpidToAcounts.get(account.Core_IPA_One_Partner_Id__c).add(account);
            }else{
                mapOfOpidToAcounts.put(account.Core_IPA_One_Partner_Id__c, new List<Account>{account});
            }
        }
        
        for(Account account : newAccountSet){
            if(mapOfOpidToAcounts.isEmpty() || (mapOfOpidToAcounts!=null && mapOfOpidToAcounts.size()>0 
               && mapOfOpidToAcounts.containsKey(account.Core_IPA_One_Partner_Id__c) 
               && (mapOfOpidToAcounts.get(account.Core_IPA_One_Partner_Id__c)).size()==0)){
                   accountsToBeProcessed.add(account);
               }
        }
        return accountsToBeProcessed;
    }
    
    public static Set<Account> hasMDFBenefit(Set<Account> newAccountSet)
    {
        Set<Account> accountsToBeProcessed = new Set<Account>();
        Map<Id,Account> mapOfAccounts = new Map<Id,Account>();
        for(Account account : newAccountSet){
            mapOfAccounts.put(account.Id,account);
        }
        //As of now we are using benefit.Name 
        List<PRM_AccountBenefitAssociation__c> listOfExistingAccBenefitAccoc = [select id, PRM_Account_Id__c,PRM_Account_Id__r.Name, PRM_Partner_Benefit_Id__r.Name from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c IN: (mapOfAccounts.keySet())]; 
        
        
        for(PRM_AccountBenefitAssociation__c accBenefitAssoc:listOfExistingAccBenefitAccoc){
            if(mapOfAccounts!=null && mapOfAccounts.size()>0 && mapOfAccounts.containsKey(accBenefitAssoc.PRM_Account_Id__c)){
                accountsToBeProcessed.add(mapOfAccounts.get(accBenefitAssoc.PRM_Account_Id__c));
            }
        }
        return accountsToBeProcessed;
    }
}