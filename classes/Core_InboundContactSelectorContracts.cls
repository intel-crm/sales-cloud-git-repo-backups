public without sharing class Core_InboundContactSelectorContracts {
    public interface IContactQuerySelector {
        Contact getContact(String erpmPersonId,String erpmEmail,String queryFields);
        Map<Id, Core_Contact_Entitlement__c> getContactEntitlements(Id matchingContactId, String queryConEntitlementFields);
        Account getAccount(String salesforceId, String queryAccount);
        Map<Id, Contact> getContactsById(Set<Id> contactIdsInserted, String querycontactsToInsert);
        Map<Id, Core_Entitlement__c> getEntitlements( String queryEntitlement,String andClauseEntitlement);
        Core_Integration_Inbound_Message__c getInboundMsg(String contactMessageId, String queryInboundMsg);
        Contact getContactById(String contactIdInserted, String querycontactsToInsert);
    }
}