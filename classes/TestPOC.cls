public with sharing class TestPOC {
        
    @AuraEnabled public static Contact currContact {get;set;}
    @AuraEnabled public static Account targetAccount {get;set;}

    @AuraEnabled(cacheable=true)
    public static contact getCore_IPS_MoveContact_AnkitTest_LWCPOC (String recordId){
        currContact = [Select Id, Account.Name, Name, AccountId,Core_IPS_Active__c, FirstName, Account.Core_Export_Compliance_Block__c, 
                           Account.Core_Export_Compliance_Block_Reason__c, Account.Core_IsODM__c, Account.Core_IPS_Active__c,Account.Core_PSG_Account__c,
                           Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, 
                           Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName, Account.Core_B2B_Entitlement__c, Core_Contact_B2B_Indicator__c 
                           From Contact Where id =: recordId]; 
        return currContact;
    }
    
    
}