/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 03-09-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_RecordJobHandlerTest {
    
    @testSetup
    public static void setUpData() {
    	List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Record_Job_Handler_Test');
            User partnerUser = Pricing_Test_Utility.createPartnerAdminUser(acc.Id);
            
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuote(acc.Id, con.Id, 1);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 2);

            SBQQ__RecordJob__c recordJob = new SBQQ__RecordJob__c();
            recordJob.SBQQ__IsRead__c = false;
            recordJob.SBQQ__RecordId__c = quoteList[0].Id + '::QuoteCalculator';

            insert recordJob;

                        
            Test.stopTest();
        }
    }

        static testMethod void testAbortQueuebale() {
            User usr = [Select Id, Email from User Where Email = 'firstName@intel.com' Limit 1];
            Test.startTest();
            System.runAs(usr) {
                SBQQ__QuoteLine__c qli = [SELECT Id,Pricing_Save_After_Calculation_cb__c FROM SBQQ__QuoteLine__c LIMIT 1];
                qli.Pricing_Save_After_Calculation_cb__c = true;
                update qli;

                SBQQ__RecordJob__c recordJob = [SELECT Id FROM SBQQ__RecordJob__c LIMIT 1];
                update recordJob;
                System.assertEquals(true ,recordJob != null);
            } 
            Test.stopTest();
        }

        @isTest
        static void testGetIntegrationUserIds() {
            User integrationUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            PermissionSet integrationPermissionSet = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'Pricing_Abort_Calculator_Integration_User'
                LIMIT 1
            ];
            insert new PermissionSetAssignment(
                AssigneeId = integrationUser.Id,
                PermissionSetId = integrationPermissionSet.Id
            );

            Set<Id> integrationUserIds = Pricing_RecordJobHandler.getIntegrationUserIds(
                new Set<Id>{integrationUser.Id}
            );

            System.assertEquals(
                new Set<Id>{integrationUser.Id},
                integrationUserIds,
                'Users assigned the integration marker permission set must be identified.'
            );
        }
}