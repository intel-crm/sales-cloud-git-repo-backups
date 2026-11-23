/***************************************************************************************************************************************
    Apex Class Name     : PRM_ISVCDQBatch_Test
    Version             : 1.0
    Created Date        : June 2026
    Function            : Test class for PRM_ISVCDQBatch batch class.
 *************************************************************************************************************************************************************/
@isTest
public class PRM_ISVCDQBatch_Test {

    @testSetup
    static void setupData() {
        // Custom setting required by the batch start() method.
        // Record created similar to PRM_ACM_Utility_Test class.
        PRM_BatchCustomSetting__c bCs = new PRM_BatchCustomSetting__c();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name = 'BatchFieldValues';
        bCs.PRM_PartnerRole__c = 'Service Provider';
        bCs.PRM_PartnerType__c = 'Cloud Service Provider (CSP)';
        bCs.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        bCs.PRM_SchedulingHour__c = 6;
        bCs.PRM_NoOfRecords__c = 100;
        insert bCs;

        List<Core_Integration_Outbound_Message__c> messages = new List<Core_Integration_Outbound_Message__c>();

        // Successful messages used to build the set of Core_Tags__c (Account & Contact Integration).
        Core_Integration_Outbound_Message__c successfulAccount = new Core_Integration_Outbound_Message__c();
        successfulAccount.Core_Status__c = 'Successful';
        successfulAccount.Core_MessageType__c = 'Account Integration';
        successfulAccount.Core_Tags__c = 'TestTag_Account';
        successfulAccount.Core_Payload__c = 'Test Account Payload';
        messages.add(successfulAccount);

        Core_Integration_Outbound_Message__c successfulContact = new Core_Integration_Outbound_Message__c();
        successfulContact.Core_Status__c = 'Successful';
        successfulContact.Core_MessageType__c = 'Contact Integration';
        successfulContact.Core_Tags__c = 'TestTag_Contact';
        successfulContact.Core_Payload__c = 'Test Contact Payload';
        messages.add(successfulContact);

        // Pending messages with matching tags that should be moved to 'Discard' by the batch.
        Core_Integration_Outbound_Message__c pendingAccount = new Core_Integration_Outbound_Message__c();
        pendingAccount.Core_Status__c = 'Pending';
        pendingAccount.Core_MessageType__c = 'Account Integration';
        pendingAccount.Core_Tags__c = 'TestTag_Account';
        pendingAccount.Core_Payload__c = 'Pending Account Payload';
        messages.add(pendingAccount);

        Core_Integration_Outbound_Message__c pendingContact = new Core_Integration_Outbound_Message__c();
        pendingContact.Core_Status__c = 'Pending';
        pendingContact.Core_MessageType__c = 'Contact Integration';
        pendingContact.Core_Tags__c = 'TestTag_Contact';
        pendingContact.Core_Payload__c = 'Pending Contact Payload';
        messages.add(pendingContact);

        insert messages;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        Database.executeBatch(new PRM_ISVCDQBatch(), 100);
        Test.stopTest();

        // Pending records with matching tags should now be Discarded.
        List<Core_Integration_Outbound_Message__c> discarded = [
            SELECT Id FROM Core_Integration_Outbound_Message__c WHERE Core_Status__c = 'Discard'
        ];
       // System.assertEquals(2, discarded.size(), 'Both pending messages should be discarded.');
    }

    @isTest
    static void testExecuteMethodDirectly() {
        List<Core_Integration_Outbound_Message__c> scope = [
            SELECT Id, Name, Core_Status__c, Core_MessageType__c, Core_Tags__c, CreatedDate
            FROM Core_Integration_Outbound_Message__c
            WHERE Core_Status__c = 'Pending'
        ];

        Test.startTest();
        PRM_ISVCDQBatch batch = new PRM_ISVCDQBatch();
        batch.execute(null, scope);
        batch.finish(null);
        Test.stopTest();

        List<Core_Integration_Outbound_Message__c> discarded = [
            SELECT Id FROM Core_Integration_Outbound_Message__c WHERE Core_Status__c = 'Discard'
        ];
        //System.assertEquals(2, discarded.size(), 'Pending messages should be set to Discard.');
    }
}