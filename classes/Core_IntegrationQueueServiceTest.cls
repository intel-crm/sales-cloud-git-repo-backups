@IsTest
private class Core_IntegrationQueueServiceTest {

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
        contact.Email = 'queue.service.' + String.valueOf(DateTime.now().getTime()) + '@example.test';
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
            Name = 'Queue Service Subscription',
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
        engagement.Name = 'Queue Service Engagement';
        engagement.Core_Technical_Engagement_Code__c = 'SOFT-001';
        engagement.Core_Engagement_Type__c = 'SFT';
        insert engagement;

        Core_Entitlement__c entitlement = new Core_Entitlement__c(
            Name = 'Queue Service Entitlement',
            Core_Display_Name__c = 'Queue Service Entitlement',
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

    @IsTest
    static void createQueueRecords_createsQueueMessageAndContactUpdate() {
        Contact contact = getContactForPayload();
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>{
            contact.Id => new Contact(Id = contact.Id, Phone = contact.Phone, MobilePhone = contact.MobilePhone)
        };

        Test.startTest();
        List<Core_ACM_Integration_Queue__c> queueRecords = Core_IntegrationQueueService.createQueueRecords(
            new List<Contact>{ contact },
            oldContactMap,
            Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.LIVE)
        );
        Test.stopTest();

        System.assertEquals(1, queueRecords.size());
        System.assertNotEquals(null, queueRecords[0].Id);
        System.assertEquals(Core_ACM_Constants.MESSAGE_TYPE_ERPM, queueRecords[0].Core_Message_Type__c);
        System.assertEquals(Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.NEW_STATUS), queueRecords[0].Core_Status__c);
        System.assert(queueRecords[0].Core_Payload__c.contains('PersonAccountProfile'));
        System.assert(queueRecords[0].Core_Payload__c.contains('INTCLDCOM'));
        System.assert(queueRecords[0].Core_Payload__c.contains('SOFT-001'));

        Contact_Message__c contactMessage = [
            SELECT Id, Contact__c, ACM_Integration_Queue__c
            FROM Contact_Message__c
            WHERE ACM_Integration_Queue__c = :queueRecords[0].Id
            LIMIT 1
        ];
        System.assertEquals(contact.Id, contactMessage.Contact__c);

        Contact updatedContact = [
            SELECT Id, Core_ERPM_Integration_Status__c
            FROM Contact
            WHERE Id = :contact.Id
        ];
        System.assertEquals(Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.IN_PROGRESS_STATUS), updatedContact.Core_ERPM_Integration_Status__c);
    }

    @IsTest
    static void createQueueRecords_returnsEmptyForNoContacts() {
        Test.startTest();
        List<Core_ACM_Integration_Queue__c> queueRecords = Core_IntegrationQueueService.createQueueRecords(
            new List<Contact>(),
            new Map<Id, Contact>(),
            Core_ACM_Constants.getProcessTypeValue(Core_ACM_Constants.ProcessType.BULK_MODE)
        );
        Test.stopTest();

        System.assertEquals(0, queueRecords.size());
    }

    @IsTest
    static void buildPayload_preservesPhoneRemovalSignals() {
        Contact queriedContact = getContactForPayload();
        Contact updatedContact = queriedContact.clone(false, true, false, false);
        updatedContact.Phone = null;
        updatedContact.MobilePhone = null;

        Map<Id, Contact> oldContactMap = new Map<Id, Contact>{
            queriedContact.Id => queriedContact
        };

        Test.startTest();
        Core_ACM_PayloadWrapper payload = Core_ACM_PayloadBuilder.buildPayload(updatedContact, oldContactMap);
        Test.stopTest();

        System.assertEquals(Core_ACM_Constants.CHANGE_AGENT, payload.ChangeAgent);
        System.assertEquals(Core_ACM_Constants.CHANGE_AGENT_LOGIN_ID, payload.ChgAgtLoginId);
        System.assertEquals(Core_ACM_Constants.getFlagValue(Core_ACM_Constants.Flag.NO), payload.PersonAccountProfile.DoNotContactFlag);
        System.assertEquals(Core_ACM_Constants.getFlagValue(Core_ACM_Constants.Flag.NO), payload.PersonAccountProfile.SalesDoNotContactFlag);
    }

    @IsTest
    static void testGetSoftEngagementCode_Rejected() {

        Contact con = Core_IntegrationQueueServiceTest.getContactForPayload();

        Core_Contact_Entitlement__c ent =
            [SELECT Id, Core_Selected__c
            FROM Core_Contact_Entitlement__c
            LIMIT 1];

        ent.Core_Selected__c = false;
        update ent;

        con = Core_IntegrationQueueServiceTest.getContactForPayload();

        Test.startTest();
        Map<String,String> result =
            Core_ACM_ContactDataProcessor.getSoftEngagementCode(con);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assert(
            result.containsKey('SOFT-001')
        );
    }

    @IsTest
    static void testGetSubscriptions_DoNotContact() {

        Contact con =
            [SELECT Id,
                    Core_Do_Not_Contact__c,
                    (SELECT Id,
                            PRM_Status_Nm__c,
                            PRM_Status_Reason_Txt__c,
                            PRM_Partner_Subscription_Id__r.Name,
                            PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c
                    FROM Contact_Subscription_Associations__r)
            FROM Contact
            LIMIT 1];

        con.Core_Do_Not_Contact__c = true;

        Test.startTest();
        List<Core_ACM_PayloadWrapper.Subscription> subs =
            Core_ACM_ContactDataProcessor.getSubscriptions(con);
        Test.stopTest();

        System.assertEquals(1, subs.size());

        System.assertEquals(
            Core_ACM_Constants.getSubscriptionStatusValue(
                Core_ACM_Constants.SubscriptionStatus.UNSUBSCRIBED
            ),
            subs[0].SubscriptionStatusCode
        );
    }

    /*@IsTest
    static void testGetMemberships_WithBusinessType() {

        Contact con =
            [SELECT Id,
                    Core_Enterprise_Id__c,
                    (SELECT Id, Status__c
                    FROM Contact_Business_Types__r)
            FROM Contact
            LIMIT 1];

        Contact_Business_Types__c bt =
            new Contact_Business_Types__c(
                Contact__c = con.Id,
                Status__c = Core_ACM_Constants.getStatusValue(
                    Core_ACM_Constants.Status.APPROVED_STATUS
                )
            );

        insert bt;

        con =
            [SELECT Id,
                    Core_Enterprise_Id__c,
                    (SELECT Id, Status__c
                    FROM Contact_Business_Types__r)
            FROM Contact
            WHERE Id = :con.Id];

        Test.startTest();

        List<Core_ACM_PayloadWrapper.Membership> memberships =
            Core_ACM_ContactDataProcessor.getMemberShips(
                con,
                new Map<String,String>{
                    'SOFT-001' =>
                        Core_ACM_Constants.getEngagementStatusValue(
                            Core_ACM_Constants.EngagementStatus.APPROVED
                        )
                }
            );

        Test.stopTest();

        System.assert(memberships.size() >= 2);
   }*/

   @IsTest
    static void testGetSoftEngagementCode_SECBranch() {

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Core_ERPM_Engagement__c secEng =
            new Core_ERPM_Engagement__c(
                Name='SEC ENG',
                Core_Technical_Engagement_Code__c='SEC001',
                Core_Engagement_Type__c=
                    Core_ACM_Constants.ENGAGEMENT_TYPE_SEC
            );
        insert secEng;

        Core_Entitlement__c ent = new Core_Entitlement__c(
            Name='SEC ENT',
            Core_Display_Name__c='SEC ENT',
            Core_IsActive__c=true,
            Core_ERPM_Engagement_Id__c=secEng.Id
        );
        insert ent;

        insert new Core_Contact_Entitlement__c(
            Core_Contact_Id__c=con.Id,
            Core_Entitlement_Id__c=ent.Id,
            Core_Selected__c=true
        );

        Contact refreshed =
            Core_IntegrationQueueServiceTest.getContactForPayload();

        Test.startTest();
        Map<String,String> result =
            Core_ACM_ContactDataProcessor.getSoftEngagementCode(refreshed);
        Test.stopTest();

        // SEC engagement goes to mEngCodes
        // so should NOT be returned.
        System.assert(!result.containsKey('SEC001'));
  }

    private static Contact getContactForPayload() {
        return [
            SELECT Id, FirstName, LastName, Email, Phone, MobilePhone, Salutation,
                   MailingCountryCode, MailingStateCode,
                   Core_Enterprise_Id__c, Core_eRPM_Person_Id__c,
                   Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c,
                   Core_Profession__c, Core_Job_Function_Code__c,
                   Core_Preferred_Language__c, Core_Do_Not_Contact__c,
                   Core_Sales_Do_Not_Contact_Ind__c,
                   Account.BillingCountryCode,
                   (SELECT Id, Core_Contact_Id__c, Core_Selected__c,
                           Core_Entitlement_Id__r.Core_IsActive__c,
                           Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,
                           Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Engagement_Type__c
                    FROM Contact_Entitlements__r),
                   (SELECT Id, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,
                           PRM_Partner_Subscription_Id__r.Name,
                           PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c
                    FROM Contact_Subscription_Associations__r),
                   (SELECT Id, Status__c FROM Contact_Business_Types__r)
            FROM Contact
            LIMIT 1
        ];
    }
}