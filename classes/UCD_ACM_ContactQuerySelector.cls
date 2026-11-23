public with sharing class UCD_ACM_ContactQuerySelector  implements UCD_ACM_SelectorContracts.IContactQuerySelector {

    private static UCD_ACM_SelectorContracts.IContactQuerySelector instance = null;
    private UCD_ACM_ContactQuerySelector() {}

    public static UCD_ACM_SelectorContracts.IContactQuerySelector getInstance(){
        if (instance  == null) {
            instance  = new UCD_ACM_ContactQuerySelector();
        }
        return instance;
    }

    public static List<Contact> getCurrContactDetails(String contactId, String queryFields){
        String query = 'SELECT '+queryFields+' FROM Contact WHERE Id =: contactId';
            List<Contact> contacts = Database.query(query);
            return contacts;
    }

    public static List<Case> getCaseDetails(String contactId, String queryFields){
        String query = 'SELECT '+queryFields+' FROM Case WHERE Id =: contactId  AND RecordType.Name != \'CEP Case\' ';
            List<case> cases = Database.query(query);
            return cases;
    }

    public static List<Asset> assetDetails(String queryFields, String whereClause){
        List<Asset> lstAsset = Database.query(queryFields + whereClause);
        return lstAsset;
    }

    public static List<Core_Contact_Entitlement__c>  getEntitlementsDetails(String contactId, String queryFields){
        String query = 'Select '+ queryFields + 'WHERE Core_Contact_Id__c =: contactId AND Core_Entitlement_Id__r.Core_IsActive__c = true' ;
        List<Core_Contact_Entitlement__c> entitlementsDetails = Database.query(query);
        return entitlementsDetails;
    }

    public static Account getTargetAccountObj(String AccountId, String queryFields){
        String query = 'Select '+ queryFields + ' From Account  where ID =: AccountId Limit 1' ;
        Account account = Database.query(query);
        return account;
    }

    public static List<Contact_Move_Governance__c> getContactMoveGovDetails(String ContactMoveGovId , String queryFields){
        String query = 'Select '+ queryFields + ' From Contact_Move_Governance__c  where Contact__c = ContactMoveGovId ' ;
        List<Contact_Move_Governance__c> contactMoveGovDetails = Database.query(query);
        return contactMoveGovDetails;
    }
}