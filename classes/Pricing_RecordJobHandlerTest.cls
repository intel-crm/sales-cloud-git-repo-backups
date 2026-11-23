/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 06-13-2024
 * @last modified by  : Sandeep Chamate
**/
@isTest
public class Pricing_RecordJobHandlerTest {
    
    @testSetup
    public static void setUpData() {
    	List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
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

            }

            Test.stopTest();
        }
    static testMethod void testAbortQueuebaledummy() {
        	Map<Id, SBQQ__RecordJob__c> quoteIdToRecordJobMap = new Map<Id, SBQQ__RecordJob__c>();
            Set<Id> quoteIds = new Set<Id>();
            User usr = [Select Id, Email from User Where Email = 'firstName@intel.com' Limit 1];
            Test.startTest();
            System.runAs(usr) {
                SBQQ__QuoteLine__c qli = [SELECT Id,Pricing_Save_After_Calculation_cb__c FROM SBQQ__QuoteLine__c LIMIT 1];

                SBQQ__RecordJob__c recordJob = [SELECT Id,SBQQ__RecordId__c FROM SBQQ__RecordJob__c LIMIT 1];
                List<String> recordIdList = recordJob.SBQQ__RecordId__c.split('::');
                quoteIds.add(recordIdList[0]);
                quoteIdToRecordJobMap.put(recordIdList[0],recordJob);
                Pricing_RecordJobHandler.checkCalculatorFailure(quoteIds,quoteIdToRecordJobMap);
 
            }
 
            Test.stopTest();
        }
}