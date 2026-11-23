/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 01-16-2025
 * @last modified by  : Vrushabh Uprikar
**/
@isTest
public class Pricing_ConsumptionAttr_ControllerTest {

    @testSetup
    public static void setUpData() {
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('qlBusinessLogicAdmin');
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser2(); // firstNameRPM@intel.com
        List<User> fseUser2 = Pricing_Test_Utility.createFSEUserWithParam('newFSEUser@intel.com','NewFseUser','UserName');
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            List<User> accExeUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            Test.startTest();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;            
            
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accExeUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 3);
            
            Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
            triggerEntry2.name = 'pricingSendOutboundMessagesIQR';
            triggerEntry2.Core_Object__c = 'Descriptive Feature';
            triggerEntry2.Core_Trigger_Events__c = 'After insert';
            triggerEntry2.Core_Active__c = TRUE;
            triggerEntry2.Core_Description__c = 'This is test description';
            triggerEntry2.Core_Class_Name__c = 'Test Class';
            insert triggerEntry2;
            
            Document document;            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;

            Pricing_ConsumptionAccountMapping__c accountMapping  = new Pricing_ConsumptionAccountMapping__c();
            accountMapping.Name= 'Test Account Mapping';
            accountMapping.Pricing_Consumption_Type_Nm__c = 'Consumption Platform';
            accountMapping.Pricing_Active_ind__c = true;
            accountMapping.Pricing_Account_Nm__c = quoteList[0].SBQQ__Account__c;

            insert accountMapping;

            Test.stopTest();
        }
    }


    @isTest
    public static void testSaveConsumptionTxtData() {
        // Test data setup
        SBQQ__QuoteLine__c quoteLine = [Select Id, SBQQ__Quote__c From SBQQ__QuoteLine__c Limit 1];
        String quoteLineId = quoteLine.Id;
        String platformValue = 'UpdatedPlatform';
        String regionValue = 'UpdatedRegion';
        String countryValue = 'UpdatedCountry';
        String salesGeoValue = '';
        String segmentValue = 'segment';

        // Test the saveConsumptionTxtData method
        Test.startTest();
        String result = Pricing_ConsumptionAttr_Controller.saveConsumptionTxtData(quoteLineId, platformValue, regionValue, countryValue, salesGeoValue, segmentValue);
        Test.stopTest();

        // Verify the result
        System.assertEquals('true', result);

        // Query the quote line to verify the updates
        SBQQ__QuoteLine__c updatedQuoteLine = [SELECT Id,Pricing_Consumption_Platform__c, Pricing_Consumption_Region__c, Pricing_Consumption_Country__c, Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Segment__c
                                                FROM SBQQ__QuoteLine__c
                                                WHERE Id = :quoteLineId
                                                LIMIT 1];

        SBQQ__QuoteLine__c quote = Pricing_ConsumptionAttr_Controller.getParentQuoteLine(quoteLineId);
        System.assertEquals(platformValue, updatedQuoteLine.Pricing_Consumption_Platform__c);
        System.assertEquals(regionValue, updatedQuoteLine.Pricing_Consumption_Region__c);
        System.assertEquals(countryValue, updatedQuoteLine.Pricing_Consumption_Country__c);
    }

    @isTest
    public static void testGetConsumptionTxtData() {
        User adminUser = [Select id from User where Email='qlBusinessLogicAdmin@intel.com'];
        SBQQ__QuoteLine__c quoteLine = [Select Id, SBQQ__Quote__c From SBQQ__QuoteLine__c Limit 1];
        // Test data setup
        System.runAs(adminUser){            
            quoteLine.Pricing_Consumption_Platform__c = 'TestPlatform1';
            quoteLine.Pricing_Consumption_Region__c = 'APAC';
            quoteLine.Pricing_Consumption_Country__c = 'Aland Islands';
            quoteLine.Pricing_Consumption_Sale_Geo__c = '';
            update quoteLine;
        }

        String quoteLineId = quoteLine.Id;

        // Test the getConsumptionTxtData method
        Test.startTest();
        SBQQ__QuoteLine__c result = Pricing_ConsumptionAttr_Controller.getConsumptionTxtData(quoteLineId);
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(quoteLine.Pricing_Consumption_Platform__c, result.Pricing_Consumption_Platform__c);
        System.assertEquals(quoteLine.Pricing_Consumption_Region__c, result.Pricing_Consumption_Region__c);
        System.assertEquals(quoteLine.Pricing_Consumption_Country__c, result.Pricing_Consumption_Country__c);
        System.assertEquals(quoteLine.Pricing_Consumption_Sale_Geo__c, result.Pricing_Consumption_Sale_Geo__c);
    }

    @isTest
    public static void testGetPlatformAndSalesGeoPickList() {
        
        SBQQ__Quote__c quote = [Select Id, Name from SBQQ__Quote__c  Limit 1];
        String quoteId = quote.Id;

        // Test the getPlatformAndSalesGeoPickList method
        Test.startTest();
        List<Pricing_ConsumptionAccountMapping__c> result = Pricing_ConsumptionAttr_Controller.getPlatformAndSalesGeoPickList(quoteId);
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(0, result.size());
        System.assertEquals(1, result.size());
    }
}