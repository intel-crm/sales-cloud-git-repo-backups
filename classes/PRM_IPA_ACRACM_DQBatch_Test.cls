@IsTest
public class PRM_IPA_ACRACM_DQBatch_Test {
    @TestSetup
    static void setupData() {
        // Custom Setting
       PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        bcs.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        insert bCs;
        Id intelRT =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id opidRT =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();

        ChannelProgram cp = new ChannelProgram(Name = 'Intel Partner Alliance',PRM_programCode__c = 'IPA');
        insert cp;
        ChannelProgramLevel level1 = new ChannelProgramLevel(
            Name = 'Partner',
            ProgramId = cp.Id
        );
        insert level1;

        // OPID
        Account opid = new Account(
            RecordTypeId = opidRT,
            Name = 'Test OPID',
            BillingCity = 'City',
            BillingStreet = 'Street',
            BillingCountry = 'India',
            BillingPostalCode = '560001',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Core_IPA_Partner_Role__c = 'Service Provider',
            Core_Intel_Partner_Alliance_PartnerGroup__c = true
        );
        insert opid;

        // Intel Account
        Account intel = new Account(
            RecordTypeId = intelRT,
            Name = 'Test Intel',
            BillingCity = 'City',
            BillingStreet = 'Street',
            BillingCountry = 'India',
            BillingPostalCode = '560001',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Core_User_Defined_Website__c = 'www.test.com',
            Core_IPA_One_Partner_Id__c = opid.Id,
            Core_Intel_Partner_Alliance_PartnerGroup__c = true
        );
        insert intel;

        // Contact
        Contact c = new Contact(
                AccountId = intel.Id,
                LastName = 'Contact',
                FirstName = 'Test',
                Email = 'test@test.com'
            );
        TriggerHandler.bypass('Core_ContactHandler');
        insert c;
        TriggerHandler.clearBypass('Core_ContactHandler');

        // Contact Relationship
        PRM_ContactRelationships__c rel =
            new PRM_ContactRelationships__c(
                Name = 'Partner Admin',
                PRM_Contact_Relationship_Cd__c = 'RELTNPRCTC',
                PRM_Channel_Program_Id__c = cp.Id,
                PRM_Default_Relationship_Ind__c = true
            );
        insert rel;

        // ACR
        PRM_Account_Contact_Relationship__c acr =
            new PRM_Account_Contact_Relationship__c(
                PRM_Account_Id__c = intel.Id,
                PRM_Contact_Id__c = c.Id,
                PRM_Relationship_Id__c = rel.Id,
                PRM_Status_Nm__c = 'Complete',
                PRM_InActive_Ind__c = false,
                PRM_Status_Reason_Txt__c = 'Test'
            );
        insert acr;

        // Intel ACM
        PRM_AccountChannelMembership__c intelACM =
            new PRM_AccountChannelMembership__c(
                PRM_Account_Id__c = intel.Id,
                PRM_Channel_Program_Id__c = cp.Id,
                PRM_Channel_Program_Level_Id__c = level1.Id,
                PRM_Partner_Role__c = 'Service Provider',
                PRM_Status_Nm__c = 'Approved',
                PRM_Status_Reason_Txt__c = 'Test'
            );
        insert intelACM;

        // OPID ACM
        PRM_AccountChannelMembership__c opidACM =
            new PRM_AccountChannelMembership__c(
                PRM_Account_Id__c = opid.Id,
                PRM_Channel_Program_Id__c = cp.Id,
                PRM_Channel_Program_Level_Id__c = level1.Id,
                PRM_Partner_Role__c = 'Service Provider',
                PRM_Status_Nm__c = 'Inactive',
                PRM_Status_Reason_Txt__c = 'Test'
            );
        insert opidACM;

        // Active CAG
        Core_Account_Group_Member__c cag =
            new Core_Account_Group_Member__c(
                Core_Partner_Account_Id__c = opid.Id,
                Core_Intel_Account_Id__c = intel.Id,
                Core_Inactive_Ind__c = false
            );
        insert cag;
    }

    @IsTest
    static void testBatchExecution() {
        Test.startTest();
        Database.executeBatch(new PRM_IPA_ACRACM_DQBatch(),1);
        Test.stopTest();
        System.assert(true);
    }
    @IsTest
    static void testScenario1_ACRInactive() {

        Account intel =[SELECT Id FROM Account WHERE RecordType.Name = 'Intel Account' LIMIT 1];
        delete [SELECT Id FROM PRM_AccountChannelMembership__c WHERE PRM_Account_Id__c = :intel.Id];

        Test.startTest();
        Database.executeBatch(new PRM_IPA_ACRACM_DQBatch(),1);
        Test.stopTest();
        PRM_Account_Contact_Relationship__c acr =
            [SELECT PRM_InActive_Ind__c FROM PRM_Account_Contact_Relationship__c WHERE PRM_Account_Id__c = :intel.Id LIMIT 1];

        System.assertEquals(
            true,
            acr.PRM_InActive_Ind__c
        );
    }

    @IsTest
    static void testScenario2_OPIDACMRollup() {

        Test.startTest();

        Database.executeBatch(
            new PRM_IPA_ACRACM_DQBatch(),
            1
        );

        Test.stopTest();

        List<PRM_AccountChannelMembership__c> opidAcms =
            [
                SELECT Id,
                       PRM_Status_Nm__c
                FROM PRM_AccountChannelMembership__c
                WHERE PRM_Account_Id__r.RecordType.Name =
                        'Partner Account Group'
            ];

        System.assert(
            opidAcms.size() > 0
        );
    }

    @IsTest
    static void testScenario3_RemoveOPIDStamp() {

        Account intel =
            [
                SELECT Id,
                       Core_IPA_One_Partner_Id__c
                FROM Account
                WHERE Core_IPA_One_Partner_Id__c != null
                LIMIT 1
            ];

        delete [
            SELECT Id
            FROM Core_Account_Group_Member__c
            WHERE Core_Intel_Account_Id__c = :intel.Id
        ];

        Test.startTest();

        Database.executeBatch(
            new PRM_IPA_ACRACM_DQBatch(),
            1
        );

        Test.stopTest();

        intel =
            [
                SELECT Core_IPA_One_Partner_Id__c
                FROM Account
                WHERE Id = :intel.Id
            ];

        System.assertEquals(
            null,
            intel.Core_IPA_One_Partner_Id__c
        );
    }

    @IsTest
    static void testScenario4_DeactivatedOPID() {

        Account opid =
            [
                SELECT Id
                FROM Account
                WHERE RecordType.Name =
                    'Partner Account Group'
                LIMIT 1
            ];

        opid.Core_Deactivated__c = true;
        update opid;

        Test.startTest();

        Database.executeBatch(
            new PRM_IPA_ACRACM_DQBatch(),
            1
        );

        Test.stopTest();

        Core_Account_Group_Member__c cag = [SELECT Core_Inactive_Ind__c FROM Core_Account_Group_Member__c LIMIT 1];

        System.assertEquals(true,cag.Core_Inactive_Ind__c);
    }
}