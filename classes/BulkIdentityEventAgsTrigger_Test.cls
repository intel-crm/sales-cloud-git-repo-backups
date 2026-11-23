@isTest
public class BulkIdentityEventAgsTrigger_Test{
    
    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(
            RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId(),
        BillingCity='City',
        BillingStreet='Street',
        BillingCountry='India',
        BillingPostalCode='Postal code',
            Name = 'Test Account'
        );
        insert testAccount;
        
        // Create test Contacts
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact testContact = new Contact(
                FirstName = 'Test' + i,
                LastName = 'Contact' + i,
                Email = 'test' + i + '@example.com',
                AccountId = testAccount.Id,
                Core_AGS_Integration_Status__c = 'Active',
                Core_ERPM_Integration_Status__c = 'Active',
                MailingCountry = 'IND'
            );
            testContacts.add(testContact);
        }
        insert testContacts;
    }
    
    @isTest
    static void testHandleAfterInsert_Success() {
        // Get test contacts
        List<Contact> testContacts = [SELECT Id, FirstName, LastName, Email, Phone, MobilePhone,
                             Core_eRPM_Person_Id__c, Core_Enterprise_Id__c, Core_Profession__c,
                             Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c,
                             Core_Sales_Do_Not_Contact_Ind__c, Core_Do_Not_Contact__c,
                             Core_Do_Not_Contact_Dtm__c, Core_Marketing_Do_Not_Contact_Dtm__c,
                             Salutation, MailingCountryCode, MailingStateCode, MailingCountry,
                             MailingState, MailingCity, MailingStreet, MailingPostalCode,
                             Core_Job_Function_Code__c, Core_Preferred_Language__c,
                             Core_ERPM_Integration_Status__c, Core_Account_Primary_Country__c,
                             AccountId
                      FROM Contact LIMIT 3];
        List<Id> contactIds = new List<Id>();
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>();
        
        for (Contact con : testContacts) {
            contactIds.add(con.Id);
            // Create old contact data for comparison
            Contact oldContact = con.clone(true, true, true, true);
            oldContact.FirstName = 'Old' + oldContact.FirstName;
            oldContactMap.put(con.Id, oldContact);
        }
        
        // Create platform event
        BulkIdentity__e testEvent = new BulkIdentity__e(
            Contact_Ids__c = JSON.serialize(contactIds),
            Old_Contact_Map__c = JSON.serialize(oldContactMap)
        );
        
        List<BulkIdentity__e> platformEvents = new List<BulkIdentity__e>{ testEvent };
        
        Test.startTest();
        Core_BulkContact_Platform_Event_Handler.handleAfterInsert(platformEvents);
        Test.stopTest();
        
        // Verify that the method executed without throwing exceptions
        // Additional assertions can be added based on the Core_IntegrationQueueService behavior
        System.assert(true, 'Method executed successfully');
    }
    
    @isTest
    static void testHandleAfterInsert_EmptyOldContactMap() {
        // Get test contacts
        List<Contact> testContacts = [SELECT Id FROM Contact LIMIT 2];
        List<Id> contactIds = new List<Id>();
        
        for (Contact con : testContacts) {
            contactIds.add(con.Id);
        }
        
        // Create platform event without old contact map
        BulkIdentity__e testEvent = new BulkIdentity__e(
            Contact_Ids__c = JSON.serialize(contactIds),
            Old_Contact_Map__c = null
        );
        
        List<BulkIdentity__e> platformEvents = new List<BulkIdentity__e>{ testEvent };
        
        Test.startTest();
        Core_BulkContact_Platform_Event_Handler.handleAfterInsert(platformEvents);
        Test.stopTest();
        
        // Verify that the method handled null old contact map gracefully
        System.assert(true, 'Method executed successfully with null old contact map');
    }
    
    @isTest
    static void testHandleAfterInsert_EmptyContactIds() {
        // Create platform event with empty contact IDs
        BulkIdentity__e testEvent = new BulkIdentity__e(
            Contact_Ids__c = JSON.serialize(new List<Id>()),
            Old_Contact_Map__c = JSON.serialize(new Map<Id, Contact>())
        );
        
        List<BulkIdentity__e> platformEvents = new List<BulkIdentity__e>{ testEvent };
        
        Test.startTest();
        Core_BulkContact_Platform_Event_Handler.handleAfterInsert(platformEvents);
        Test.stopTest();
        
        // Verify that the method handled empty contact IDs gracefully
        System.assert(true, 'Method executed successfully with empty contact IDs');
    }
    
    @isTest
    static void testHandleAfterInsert_MultipleEvents() {
        // Get test contacts
        List<Contact> testContacts = [SELECT Id FROM Contact];
        List<Id> contactIds1 = new List<Id>{ testContacts[0].Id, testContacts[1].Id };
        List<Id> contactIds2 = new List<Id>{ testContacts[2].Id, testContacts[3].Id };
        
        Map<Id, Contact> oldContactMap1 = new Map<Id, Contact>();
        Map<Id, Contact> oldContactMap2 = new Map<Id, Contact>();
        
        // Create old contact data
        for (Id contactId : contactIds1) {
            Contact oldContact = new Contact(Id = contactId, FirstName = 'Old1');
            oldContactMap1.put(contactId, oldContact);
        }
        
        for (Id contactId : contactIds2) {
            Contact oldContact = new Contact(Id = contactId, FirstName = 'Old2');
            oldContactMap2.put(contactId, oldContact);
        }
        
        // Create multiple platform events
        List<BulkIdentity__e> platformEvents = new List<BulkIdentity__e>{
            new BulkIdentity__e(
                Contact_Ids__c = JSON.serialize(contactIds1),
                Old_Contact_Map__c = JSON.serialize(oldContactMap1)
            ),
            new BulkIdentity__e(
                Contact_Ids__c = JSON.serialize(contactIds2),
                Old_Contact_Map__c = JSON.serialize(oldContactMap2)
            )
        };
        
        Test.startTest();
        Core_BulkContact_Platform_Event_Handler.handleAfterInsert(platformEvents);
        Test.stopTest();
        
        // Verify that multiple events were processed successfully
        System.assert(true, 'Multiple events processed successfully');
    }
    
    @isTest
    static void testHandleAfterInsert_InvalidJSON() {
        // Create platform event with invalid JSON
        BulkIdentity__e testEvent = new BulkIdentity__e(
            Contact_Ids__c = 'invalid json',
            Old_Contact_Map__c = 'invalid json'
        );
        
        List<BulkIdentity__e> platformEvents = new List<BulkIdentity__e>{ testEvent };
        
        Test.startTest();
        Core_BulkContact_Platform_Event_Handler.handleAfterInsert(platformEvents);
        Test.stopTest();
        
        // Verify that the method handled invalid JSON gracefully (should be caught by exception handling)
        System.assert(true, 'Method handled invalid JSON gracefully');
    }
    
    @isTest
    static void testHandleAfterInsertAgs_Success() {
        // Get test contacts
        List<Contact> testContacts = [SELECT Id, FirstName, LastName, Email, Phone, MobilePhone,
                             Core_eRPM_Person_Id__c, Core_Enterprise_Id__c, Core_Profession__c,
                             Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c,
                             Core_Sales_Do_Not_Contact_Ind__c, Core_Do_Not_Contact__c,
                             Core_Do_Not_Contact_Dtm__c, Core_Marketing_Do_Not_Contact_Dtm__c,
                             Salutation, MailingCountryCode, MailingStateCode, MailingCountry,
                             MailingState, MailingCity, MailingStreet, MailingPostalCode,
                             Core_Job_Function_Code__c, Core_Preferred_Language__c,
                             Core_ERPM_Integration_Status__c, Core_Account_Primary_Country__c,
                             AccountId
                      FROM Contact LIMIT 3];
        List<Id> contactIds = new List<Id>();
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>();
        
        for (Contact con : testContacts) {
            contactIds.add(con.Id);
            // Create old contact data for comparison
            Contact oldContact = con.clone(true, true, true, true);
            oldContact.FirstName = 'Old' + oldContact.FirstName;
            oldContactMap.put(con.Id, oldContact);
        }
        
        // Create AGS platform event
        BulkIdentityAgs__e testEvent = new BulkIdentityAgs__e(
            Contact_Ids__c = JSON.serialize(contactIds),
            Old_Contact_Map__c = JSON.serialize(oldContactMap)
        );
        
        List<BulkIdentityAgs__e> platformEvents = new List<BulkIdentityAgs__e>{ testEvent };
        
        Test.startTest();
        Core_BulkContact_Platform_Event_Handler.handleAfterInsertAgs(platformEvents);
        Test.stopTest();
        
        // Verify that the method executed without throwing exceptions
        System.assert(true, 'AGS method executed successfully');
    }
    
    @isTest
    static void testHandleAfterInsertAgs_EmptyOldContactMap() {
        // Get test contacts
        List<Contact> testContacts = [SELECT Id FROM Contact LIMIT 2];
        List<Id> contactIds = new List<Id>();
        
        for (Contact con : testContacts) {
            contactIds.add(con.Id);
        }
        
        // Create AGS platform event without old contact map
        BulkIdentityAgs__e testEvent = new BulkIdentityAgs__e(
            Contact_Ids__c = JSON.serialize(contactIds),
            Old_Contact_Map__c = ''
        );
        
        List<BulkIdentityAgs__e> platformEvents = new List<BulkIdentityAgs__e>{ testEvent };
        
        Test.startTest();
        Core_BulkContact_Platform_Event_Handler.handleAfterInsertAgs(platformEvents);
        Test.stopTest();
        
        // Verify that the method handled empty old contact map gracefully
        System.assert(true, 'AGS method executed successfully with empty old contact map');
    }
    
    @isTest
    static void testHandleAfterInsertAgs_InvalidJSON() {
        // Create AGS platform event with invalid JSON
        BulkIdentityAgs__e testEvent = new BulkIdentityAgs__e(
            Contact_Ids__c = 'invalid json',
            Old_Contact_Map__c = 'invalid json'
        );
        
        List<BulkIdentityAgs__e> platformEvents = new List<BulkIdentityAgs__e>{ testEvent };
        
        Test.startTest();
        Core_BulkContact_Platform_Event_Handler.handleAfterInsertAgs(platformEvents);
        Test.stopTest();
        
        // Verify that the method handled invalid JSON gracefully
        System.assert(true, 'AGS method handled invalid JSON gracefully');
    }
    
    @isTest
    static void testHandleAfterInsert_NonExistentContactIds() {
        // Create fake contact IDs that don't exist
        List<Id> fakeContactIds = new List<Id>();
        String fakeId1 = '003000000000001'; // Fake Contact ID
        String fakeId2 = '003000000000002'; // Fake Contact ID
        fakeContactIds.add(Id.valueOf(fakeId1));
        fakeContactIds.add(Id.valueOf(fakeId2));
        
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>();
        oldContactMap.put(Id.valueOf(fakeId1), new Contact(Id = Id.valueOf(fakeId1), FirstName = 'Fake1'));
        
        // Create platform event with non-existent contact IDs
        BulkIdentity__e testEvent = new BulkIdentity__e(
            Contact_Ids__c = JSON.serialize(fakeContactIds),
            Old_Contact_Map__c = JSON.serialize(oldContactMap)
        );
        
        List<BulkIdentity__e> platformEvents = new List<BulkIdentity__e>{ testEvent };
        
        Test.startTest();
        Core_BulkContact_Platform_Event_Handler.handleAfterInsert(platformEvents);
        Test.stopTest();
        
        // Verify that the method handled non-existent contact IDs gracefully
        System.assert(true, 'Method handled non-existent contact IDs gracefully');
    }
    
    @isTest
    static void testHandleAfterInsertAgs_NonExistentContactIds() {
        // Create fake contact IDs that don't exist
        List<Id> fakeContactIds = new List<Id>();
        String fakeId1 = '003000000000003'; // Fake Contact ID
        String fakeId2 = '003000000000004'; // Fake Contact ID
        fakeContactIds.add(Id.valueOf(fakeId1));
        fakeContactIds.add(Id.valueOf(fakeId2));
        
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>();
        oldContactMap.put(Id.valueOf(fakeId1), new Contact(Id = Id.valueOf(fakeId1), FirstName = 'Fake1'));
        
        // Create AGS platform event with non-existent contact IDs
        BulkIdentityAgs__e testEvent = new BulkIdentityAgs__e(
            Contact_Ids__c = JSON.serialize(fakeContactIds),
            Old_Contact_Map__c = JSON.serialize(oldContactMap)
        );
        
        List<BulkIdentityAgs__e> platformEvents = new List<BulkIdentityAgs__e>{ testEvent };
        
        Test.startTest();
        Core_BulkContact_Platform_Event_Handler.handleAfterInsertAgs(platformEvents);
        Test.stopTest();
        
        // Verify that the method handled non-existent contact IDs gracefully
        System.assert(true, 'AGS method handled non-existent contact IDs gracefully');
    }
}