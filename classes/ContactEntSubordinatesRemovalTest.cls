@isTest public class ContactEntSubordinatesRemovalTest {
    static testMethod void testGetMetadata() {
        List<Contact_Entitlement_Subordinates_Removal__mdt> customMetadataRecords;
        Test.startTest();
            customMetadataRecords = new ContactEntitlementSubordinatesRemoval().getCustomMetadataRecords( 'SELECT Id,Label,Core_Condition__c,Core_Entitlement_Id__c,Core_Entitlement_Name__c,Core_Entitlement_Subordinate_Id__c,Core_Entitlement_Subordinate_Name__c FROM Contact_Entitlement_Subordinates_Removal__mdt' );
        customMetadataRecords = [SELECT Id,Label,Core_Condition__c,Core_Entitlement_Id__c,Core_Entitlement_Name__c,Core_Entitlement_Subordinate_Id__c,Core_Entitlement_Subordinate_Name__c FROM Contact_Entitlement_Subordinates_Removal__mdt];
        Test.stopTest();
        System.assertEquals( [SELECT Id,Label,Core_Condition__c,Core_Entitlement_Id__c,Core_Entitlement_Name__c,Core_Entitlement_Subordinate_Id__c,Core_Entitlement_Subordinate_Name__c FROM Contact_Entitlement_Subordinates_Removal__mdt].size(), customMetadataRecords.size(), 'Size should match' );
    }
     
    public static void setMetadata( String query, List<Contact_Entitlement_Subordinates_Removal__mdt> records ) {
        ContactEntitlementSubordinatesRemoval.customMetadataRecordsMap.put( query, records );
    }
}