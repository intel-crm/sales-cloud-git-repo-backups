public without sharing class Core_InboundContactQuerySelector implements Core_InboundContactSelectorContracts.IContactQuerySelector {
    private static Core_InboundContactSelectorContracts.IContactQuerySelector instance = null;
    private Core_InboundContactQuerySelector() {}
    
    public static Core_InboundContactSelectorContracts.IContactQuerySelector getInstance()
    {
        if (instance  == null) {
            instance  = new Core_InboundContactQuerySelector();
        }
        return instance;
    }

    /*
    * description : get Contact record using ERPMPersonId, ERPMPersonEmail and Query.
    * params : String erpmPersonId,String erpmEmail,String queryFields
    * return : Contact
    * author : abhishekx.kushwaha@intel.com
    */
    public Contact getContact(String erpmPersonId,String erpmEmail,String queryFields){
        List<Contact> contacts = new List<Contact>();
        String query = 'SELECT '+queryFields+' FROM contact WHERE Core_eRPM_Person_Id__c =:erpmPersonId LIMIT 1';
        contacts = Database.query(query);
        if(contacts.size() == 0) {
            String query1 = 'SELECT '+queryFields+' FROM contact WHERE Email =:erpmEmail LIMIT 1';
            contacts = Database.query(query1);
        }
        return (!contacts.isEmpty() && contacts != null) ? contacts[0] : null;
    }

    /*
    * description : get Contact Entitlement record using MatchingContactId and Query.
    * params : Id matchingContactId, String queryConEntitlementFields
    * return : Map<Id, Core_Contact_Entitlement__c>
    * author : abhishekx.kushwaha@intel.com
    */
    public Map<Id, Core_Contact_Entitlement__c> getContactEntitlements(Id matchingContactId, String queryConEntitlementFields){
        String query = 'SELECT '+queryConEntitlementFields+' FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c =:matchingContactId';
        List<Core_Contact_Entitlement__c> contactEntitlements = Database.query(query);        
        Map<Id, Core_Contact_Entitlement__c> contactEntitlementMap = new Map<Id, Core_Contact_Entitlement__c>(contactEntitlements);
        return contactEntitlementMap.size() > 0 ? contactEntitlementMap : null;
    }

    /*
    * description : get Account record using salesforceId and Query.
    * params : String salesforceId, String queryAccount
    * return : Account
    * author : abhishekx.kushwaha@intel.com
    */
    public Account getAccount(String salesforceId, String queryAccount){
        String query = 'SELECT '+ queryAccount +' FROM Account WHERE Id =:salesforceId LIMIT 1';
        List<Account> accounts = Database.query(query);
        return (accounts != null && !accounts.isEmpty()) ? accounts[0] : null;        
    }

    /*
    * description : get Contacts record using contactInsertedId and Query.
    * params : Set<Id> contactIdsInserted, String querycontactsToInsert
    * return : Map<Id, Contact>
    * author : abhishekx.kushwaha@intel.com
    */
    public Map<Id, Contact> getContactsById(Set<Id> contactIdsInserted, String querycontactsToInsert){
        String query = 'SELECT '+ querycontactsToInsert +' FROM contact WHERE Id IN :contactIdsInserted';
        List<Contact> contacts = Database.query(query);        
        Map<Id, Contact> contactsByIdMap  = new Map<Id, Contact>(contacts);
        return contactsByIdMap.size() > 0 ? contactsByIdMap : null;
    }

    /*
    * description : get Single Contact record using contactInsertedId and Query.
    * params : String contactIdsInserted, String querycontactsToInsert
    * return : Contact
    * author : abhishekx.kushwaha@intel.com
    */
    public Contact getContactById(String contactIdInserted, String querycontactsToInsert){
        String query = 'SELECT '+ querycontactsToInsert +' FROM contact WHERE Id =:contactIdInserted LIMIT 1';
        List<Contact> contacts = Database.query(query);        
        return (contacts!=null && !contacts.isEmpty()) ? contacts[0] : null;
    }

    /*
    * description : get Entitlements record using Query and Clause.
    * params : String queryEntitlement,String andClauseEntitlement
    * return : Map<Id, Core_Entitlement__c>
    * author : abhishekx.kushwaha@intel.com
    */
    public Map<Id, Core_Entitlement__c> getEntitlements(String queryEntitlement,String andClauseEntitlement){
        String query = 'SELECT '+ queryEntitlement +' FROM Core_Entitlement__c WHERE Core_AGS_Role_Id__c = \'\' and '+ andClauseEntitlement;
        List<Core_Entitlement__c> entitlements = Database.query(query);        
        Map<Id, Core_Entitlement__c> entitlementsMap = new Map<Id, Core_Entitlement__c>(entitlements);
        return entitlementsMap.size() > 0 ? entitlementsMap : null;
    }

    /*
    * description : get Integration Inbound Message record using MessageId and Query.
    * params : String contactMessageId, String queryInboundMsg
    * return : Core_Integration_Inbound_Message__c
    * author : abhishekx.kushwaha@intel.com
    */
    public Core_Integration_Inbound_Message__c getInboundMsg(String contactMessageId, String queryInboundMsg){
        String query = 'SELECT '+ queryInboundMsg +' FROM Core_Integration_Inbound_Message__c WHERE Id =:contactMessageId LIMIT 1';
        List<Core_Integration_Inbound_Message__c> inboundMsgs = Database.query(query);
        return (inboundMsgs != null && !inboundMsgs.isEmpty()) ? inboundMsgs[0] : null;        
    }  
}