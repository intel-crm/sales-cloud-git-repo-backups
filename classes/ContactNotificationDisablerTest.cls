@isTest public class ContactNotificationDisablerTest {
    static testMethod void testGetMetadata() {
        List<Core_Contact_Email_Notification_Disabler__mdt> customMetadataRecords;
        Test.startTest();
        customMetadataRecords = new ContactNotificationDisabler().getCustomMetadataRecords( 'SELECT Id,Label,Core_Allowed_Entitlement_Ids__c,Core_Engagement_Id__c,'+
                                                                                           'Core_Excluded_Entitlement_Ids__c,Core_Is_the_Rule_Active__c '+
                                                                                            'FROM Core_Contact_Email_Notification_Disabler__mdt' );
        customMetadataRecords = [SELECT Id,Label,Core_Allowed_Entitlement_Ids__c,Core_Engagement_Id__c,
                                 Core_Excluded_Entitlement_Ids__c,Core_Is_the_Rule_Active__c 
                                 FROM Core_Contact_Email_Notification_Disabler__mdt];
        Test.stopTest();
        System.assertEquals( [SELECT Id,Label,Core_Allowed_Entitlement_Ids__c,Core_Engagement_Id__c,
                                 Core_Excluded_Entitlement_Ids__c,Core_Is_the_Rule_Active__c 
                                 FROM Core_Contact_Email_Notification_Disabler__mdt].size(), customMetadataRecords.size(), 'Size should match' );
    }
     
    public static void setMetadata( String query, List<Core_Contact_Email_Notification_Disabler__mdt> records ) {
        ContactNotificationDisabler.customMetadataRecordsMap.put( query, records );
        System.debug('ContactNotificationDisablerTest : customMetadataRecordsMap ='+
                    ContactNotificationDisabler.customMetadataRecordsMap);
    }
}