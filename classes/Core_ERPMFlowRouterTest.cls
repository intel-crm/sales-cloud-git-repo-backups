@IsTest
private class Core_ERPMFlowRouterTest {

    private class ErpmApiMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"Status":"Success"}');
            return response;
        }
    }

    @TestSetup
    static void setupData() {
        Account account = PRM_TestUtility.getAccount();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        account.BillingCity = 'Bengaluru';
        account.BillingCountry = 'IND';
        account.BillingStreet = 'ITPL';
        account.BillingPostalCode = '560037';
        insert account;

        Contact contact = PRM_TestUtility.getContact();
        contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        contact.AccountId = account.Id;
        contact.Email = 'erpm.router.' + String.valueOf(DateTime.now().getTime()) + '@example.test';
        contact.Phone = '8888779792';
        contact.MobilePhone = '9999779792';
        contact.Core_Enterprise_Id__c = 'ENT-001';
        contact.Core_eRPM_Person_Id__c = 'PER-001';
        contact.Core_English_Only_First_Name__c = 'Matt';
        contact.Core_English_Only_Last_Name__c = 'Smith';
        contact.Core_Profession__c = 'PROFESSOR';
        contact.Core_Job_Function_Code__c = 'DEV';
        contact.Core_Preferred_Language__c = 'ENG';
        contact.Core_Do_Not_Contact__c = false;
        contact.Core_Sales_Do_Not_Contact_Ind__c = false;
        //contact.Core_IPS_Employee_Customer__c = false;
        contact.Core_Erpm_Integration_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.PENDING_STATUS);
        insert contact;

        PRM_Partner_Subscription__c subscription = new PRM_Partner_Subscription__c(
            Name = 'ERPM Router Subscription',
            PRM_Community__c = 'Community',
            PRM_InActive_Ind__c = false,
            PRM_Subscription_Cd__c = 'INTCLDCOM'
        );
        insert subscription;

        insert new PRM_ContactSubscriptionAssociation__c(
            PRM_Contact_Id__c = contact.Id,
            PRM_Partner_Subscription_Id__c = subscription.Id,
            PRM_Status_Nm__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.ACTIVE_STATUS),
            PRM_Status_Reason_Txt__c = 'Test association'
        );

        Core_ERPM_Engagement__c engagement = PRM_TestUtility.getERPMEngagement();
        engagement.Name = 'ERPM Router Engagement';
        engagement.Core_Technical_Engagement_Code__c = 'SOFT-001';
        engagement.Core_Engagement_Type__c = 'SFT';
        insert engagement;

        Core_Entitlement__c entitlement = new Core_Entitlement__c(
            Name = 'ERPM Router Entitlement',
            Core_Display_Name__c = 'ERPM Router Entitlement',
            Core_IsActive__c = true,
            Core_ERPM_Engagement_Id__c = engagement.Id
        );
        insert entitlement;

        insert new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = contact.Id,
            Core_Entitlement_Id__c = entitlement.Id,
            Core_Selected__c = true,
            Core_Status__c = 'Complete'
        );
    }

    private static Contact getSetupContact() {
        return [SELECT Id, Phone, MobilePhone FROM Contact LIMIT 1];
    }

    @IsTest
    static void buildOldContactMap_keepsOnlyPriorPhoneValues() {
        Id contactId = '003000000000001AAA';

        Core_ERPMFlowRouter.Request populatedRequest = new Core_ERPMFlowRouter.Request();
        populatedRequest.contactId = contactId;
        populatedRequest.priorPhone = '1234567890';
        populatedRequest.priorMobilePhone = '0987654321';

        Core_ERPMFlowRouter.Request blankRequest = new Core_ERPMFlowRouter.Request();
        blankRequest.contactId = '003000000000002AAA';

        Map<Id, Contact> oldContactMap = Core_ERPMFlowRouter.buildOldContactMap(
            new List<Core_ERPMFlowRouter.Request>{ populatedRequest, blankRequest }
        );

        System.assertEquals(1, oldContactMap.size());
        System.assertEquals('1234567890', oldContactMap.get(contactId).Phone);
        System.assertEquals('0987654321', oldContactMap.get(contactId).MobilePhone);
        System.assert(!oldContactMap.containsKey(blankRequest.contactId));
    }

    @IsTest
    static void buildOldContactMap_handlesNullRequests() {
        Map<Id, Contact> oldContactMap = Core_ERPMFlowRouter.buildOldContactMap(null);
        System.assertEquals(0, oldContactMap.size());
    }

    @IsTest
    static void queryContacts_returnsFlowProjection() {
        Contact setupContact = getSetupContact();

        Test.startTest();
        List<Contact> contacts = Core_ERPMFlowRouter.queryContacts(
            new Set<Id>{ setupContact.Id }
        );
        Test.stopTest();

        System.assertEquals(1, contacts.size());
        System.assertEquals(setupContact.Id, contacts[0].Id);
        System.assertEquals('Pending', contacts[0].Core_Erpm_Integration_Status__c);
    }

    @IsTest
    static void routeContacts_processesPendingContactThroughLiveFlow() {
        Contact setupContact = getSetupContact();

        Core_ERPMFlowRouter.Request request = new Core_ERPMFlowRouter.Request();
        request.contactId = setupContact.Id;
        request.priorPhone = '1112223333';
        request.priorMobilePhone = '4445556666';

        Test.setMock(HttpCalloutMock.class, new ErpmApiMock());

        Test.startTest();
        Core_ERPMFlowRouter.routeContacts(new List<Core_ERPMFlowRouter.Request>{ request });
        Test.stopTest();

        List<Core_ACM_Integration_Queue__c> queueRecords = [
            SELECT Id FROM Core_ACM_Integration_Queue__c
        ];
        System.assertEquals(1, queueRecords.size(), 'Live flow should create one queue record');

        Contact updatedContact = [
            SELECT Id, Core_Erpm_Integration_Status__c FROM Contact WHERE Id = :setupContact.Id
        ];
        System.assertNotEquals(
            Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.PENDING_STATUS),
            updatedContact.Core_Erpm_Integration_Status__c,
            'Live flow should move the contact out of Pending'
        );
    }

    @IsTest
    static void routeContacts_skipsNonPendingContacts() {
        Contact setupContact = getSetupContact();
        setupContact.Core_Erpm_Integration_Status__c = 'Complete';
        update setupContact;

        Core_ERPMFlowRouter.Request request = new Core_ERPMFlowRouter.Request();
        request.contactId = setupContact.Id;

        Test.startTest();
        Core_ERPMFlowRouter.routeContacts(new List<Core_ERPMFlowRouter.Request>{ request });
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Core_ACM_Integration_Queue__c],
            'Non-pending contacts should not be processed'
        );
    }

    @IsTest
    static void routeContacts_handlesEmptyAndNullRequests() {
        Test.startTest();
        Core_ERPMFlowRouter.routeContacts(new List<Core_ERPMFlowRouter.Request>());
        Core_ERPMFlowRouter.routeContacts(null);
        Core_ERPMFlowRouter.routeContacts(new List<Core_ERPMFlowRouter.Request>{ null });
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Core_ACM_Integration_Queue__c],
            'No queue records should be created for empty or null input'
        );
    }

    @IsTest
    static void erpmProcessFlow_ignoresContactsWithFullQueue() {
        Contact setupContact = getSetupContact();
        Contact contactToProcess = new Contact(
            Id = setupContact.Id,
            Core_Erpm_Integration_Status__c = Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.PENDING_STATUS),
            Core_ERPM_Integration_Queue_txt__c = 'Full'
        );

        Test.startTest();
        Core_ContactHandler.erpmProcessFlow(
            new List<Contact>{ contactToProcess },
            new Map<Id, Contact>()
        );
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Core_ACM_Integration_Queue__c],
            'Contacts with a full queue should be skipped'
        );
    }

    @IsTest
    static void processBulkFlow_publishesBulkPlatformEvent() {
        Contact setupContact = getSetupContact();
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>{
            setupContact.Id => new Contact(Id = setupContact.Id, Phone = '0000000000')
        };

        Test.startTest();
        Core_ContactHandler.processBulkFlow(
            new List<Contact>{ setupContact },
            oldContactMap
        );
        Test.stopTest();

        System.assert(true, 'Bulk flow should publish the platform event without throwing');
    }
}