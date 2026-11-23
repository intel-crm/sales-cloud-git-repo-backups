public with sharing class PRM_PartnerAccountDetailController {
    @AuraEnabled(cacheable=true)
    public static PRM_PartnerAccountDetailWrapper getAccountDetails(String recordId){
        try {
            List<Account> account = [SELECT Id,AccountNumber,Name,(Select Id,FirstName,LastName,Email FROM Contacts LIMIT 5),
            (Select Id,PRM_Contact_Id__r.Name FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c = false AND PRM_Status_Nm__c = 'Complete' AND PRM_Relationship_Id__r.Name = 'Partner Admin') FROM Account WHERE Id=:recordId];

            PRM_PartnerAccountDetailWrapper result = new PRM_PartnerAccountDetailWrapper();
            result.accountName = account[0].Name;
            result.accountNumber = account[0].AccountNumber;
            result.partnerAdmin = account[0].Account_Contact_Relationships__r.isEmpty() ? 'NA':
                                    account[0].Account_Contact_Relationships__r[0].PRM_Contact_Id__r.Name;
            result.contacts = new List<PRM_PartnerAccountDetailWrapper.ContactDetailWrapper>();

            for(Contact con : account[0].contacts){
                PRM_PartnerAccountDetailWrapper.ContactDetailWrapper contact = new PRM_PartnerAccountDetailWrapper.ContactDetailWrapper();
                contact.firstName = con.FirstName;
                contact.lastName = con.LastName;
                contact.contactId = con.Id;
                contact.email = con.Email;
                result.contacts.add(contact);
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}