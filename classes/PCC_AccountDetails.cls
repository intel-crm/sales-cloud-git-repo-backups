public without sharing class PCC_AccountDetails {
    

// public static PCC_AccountDetailsWrp getAccountDetails(){
//     Id accountId = [SELECT  Username, ContactId, Contact.Name, Contact.AccountId, Contact.Account.Name FROM User WHERE Id = :UserInfo.getUserId()].Contact.AccountId;
//     Account acc = [select id, name, Core_IPA_Partner_Role__c, Core_Account_Type__c from Account where id = :accountId];
//     PCC_AccountDetailsWrp acctDetWrp = new PCC_AccountDetailsWrp();
//     //acctDetWrp.partnerRole = acc.Core_IPA_Partner_Role__c;
//     //acctDetWrp.bizOrgType = acc.Core_Account_Type__c;
//     acctDetWrp.isBizOrgTypeODM = false;
//     acctDetWrp.isPartnerRoleDistributor = false;

//     if(acc.Core_IPA_Partner_Role__c.contains('Distributor')){
//         acctDetWrp.isPartnerRoleDistributor = true;
//     }
//     if(acc.Core_Account_Type__c.contains('Original Design Manufacturer (ODM)')){
//         acctDetWrp.isBizOrgTypeODM = true;
//     }
//     return acctDetWrp;
// }

// public class PCC_AccountDetailsWrp{
//     public Boolean isPartnerRoleDistributor{get;set;}
//     public Boolean isBizOrgTypeODM{get;set;}
// }
}