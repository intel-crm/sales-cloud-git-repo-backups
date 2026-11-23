public without sharing class PRM_Whitelisted_DomainUtility {
    
    public static void domaincheck(List<Core_Account_Whitelisted_Domains__c> domainlist){
        System.debug('Domain list:'+domainlist);
        Set<Id> acctIds = new Set<Id>();
        List<String> procCountries = label.PRM_PROC_Countries.split(',');
        List<String> procBlkList = label.PRM_Intel_BlackListed_Email_Domain_For_PROC_Region.split(',');
        List<String> nonProcBlkList = label.PRM_Intel_BlackListed_Email_Domain.split(';');
        for(Core_Account_Whitelisted_Domains__c wd : domainlist){
            acctIds.add(wd.Account__c);
            System.debug('Account Ids'+acctIds);
        }
        if(acctIds.size() > 0){
            Map<id,Account> acctsMap = new Map<id,Account>([Select Id ,BillingCountryCode from Account where Id IN :acctIds]);
            for(Core_Account_Whitelisted_Domains__c wd : domainlist){
                String countryCode =  acctsMap.containsKey(wd.Account__c) ? acctsMap.get(wd.Account__c).BillingCountryCode: null;
                List<String> blkListedDomains =  (!String.isEmpty(countryCode) && procCountries.contains(countryCode)) ? procBlkList: nonProcBlkList;
                System.debug('blkListedDomains'+blkListedDomains);
                if(blkListedDomains.contains(wd.Name)){
                   wd.Name.addError(system.label.PRM_Whitelist_Domain_Error);
                }
        	}
        }
    }
}