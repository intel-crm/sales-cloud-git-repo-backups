@IsTest
private class Core_BulkContactFlowProcessorTest {

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
        contact.Email = 'bulk.processor.' + String.valueOf(DateTime.now().getTime()) + '@example.test';
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
        insert contact;

        PRM_Partner_Subscription__c subscription = new PRM_Partner_Subscription__c(
            Name = 'Bulk Processor Subscription',
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
        engagement.Name = 'Bulk Processor Engagement';
        engagement.Core_Technical_Engagement_Code__c = 'SOFT-001';
        engagement.Core_Engagement_Type__c = 'SFT';
        insert engagement;

        Core_Entitlement__c entitlement = new Core_Entitlement__c(
            Name = 'Bulk Processor Entitlement',
            Core_Display_Name__c = 'Bulk Processor Entitlement',
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
    static void processBulkContactFlow_createsQueueRecordsFromJson() {
        Contact setupContact = getSetupContact();

        Core_BulkContactFlowProcessor.Request req = new Core_BulkContactFlowProcessor.Request();
        req.contactIdsJson = JSON.serialize(new List<Id>{ setupContact.Id });
        req.operationType = Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE);
        req.oldContactMapJson = JSON.serialize(new Map<Id, Contact>{
            setupContact.Id => new Contact(Id = setupContact.Id, Phone = setupContact.Phone, MobilePhone = setupContact.MobilePhone)
        });

        Test.startTest();
        Core_BulkContactFlowProcessor.processBulkContactFlow(new List<Core_BulkContactFlowProcessor.Request>{ req });
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM Core_ACM_Integration_Queue__c WHERE Core_Contact__c = :setupContact.Id],
            'A queue record should be created for the bulk contact'
        );
    }

    @IsTest
    static void processIntegrationQueue_createsQueueRecordsDirectly() {
        Contact setupContact = getSetupContact();
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>{
            setupContact.Id => new Contact(Id = setupContact.Id, Phone = '0000000000')
        };

        Test.startTest();
        Core_BulkContactFlowProcessor.processIntegrationQueue(
            new Set<Id>{ setupContact.Id },
            Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE),
            oldContactMap
        );
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM Core_ACM_Integration_Queue__c WHERE Core_Contact__c = :setupContact.Id],
            'Queue record should be created when processing integration queue directly'
        );
    }

    @IsTest
    static void processIntegrationQueue_handlesEmptyContactIds() {
        Test.startTest();
        Core_BulkContactFlowProcessor.processIntegrationQueue(
            new Set<Id>(),
            Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE),
            new Map<Id, Contact>()
        );
        Core_BulkContactFlowProcessor.processIntegrationQueue(
            null,
            Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE),
            null
        );
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Core_ACM_Integration_Queue__c],
            'No queue records should be created for empty or null contact ids'
        );
    }

    @IsTest
    static void processBulkContactFlow_handlesNullAndEmptyRequests() {
        Test.startTest();
        Core_BulkContactFlowProcessor.processBulkContactFlow(null);
        Core_BulkContactFlowProcessor.processBulkContactFlow(new List<Core_BulkContactFlowProcessor.Request>());
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Core_ACM_Integration_Queue__c],
            'No queue records should be created for null or empty request lists'
        );
    }

    @IsTest
    static void processBulkContactFlow_handlesInvalidJsonGracefully() {
        Core_BulkContactFlowProcessor.Request req = new Core_BulkContactFlowProcessor.Request();
        req.contactIdsJson = 'not-a-json';
        req.operationType = Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE);
        req.oldContactMapJson = 'not-a-json';

        Test.startTest();
        Core_BulkContactFlowProcessor.processBulkContactFlow(new List<Core_BulkContactFlowProcessor.Request>{ req });
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Core_ACM_Integration_Queue__c],
            'Invalid JSON should be caught and no queue records created'
        );
    }
}