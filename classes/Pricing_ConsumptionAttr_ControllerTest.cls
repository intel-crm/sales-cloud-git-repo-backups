/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 01-03-2024
 * @last modified by  : Sandeep Chamate
**/
@isTest
public class Pricing_ConsumptionAttr_ControllerTest {

    @testSetup
    public static void setUpData() {
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('qlBusinessLogicAdmin');
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Consumption_Attr_Controller_test');
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

    @isTest
    public static void testGetConsumptionTxtData_BlankId_ReturnsEmptyFields() {
        // When quoteLineId is blank, method returns a new QL with empty strings in fields
        Test.startTest();
        SBQQ__QuoteLine__c result = Pricing_ConsumptionAttr_Controller.getConsumptionTxtData('');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return an sObject even when id is blank');
        System.assertEquals('', result.Pricing_Consumption_Platform__c, 'Platform blank default');
        System.assertEquals('', result.Pricing_Consumption_Region__c, 'Region blank default');
        System.assertEquals('', result.Pricing_Consumption_Country__c, 'Country blank default');
        System.assertEquals('', result.Pricing_Consumption_Sale_Geo__c, 'Sales Geo blank default');
        System.assertEquals('', result.Pricing_Consumption_Segment__c, 'Segment blank default');
    }

    @isTest
    public static void testSaveConsumptionTxtData_ExceptionReturnsMessage() {
        String qliId = '00Q000000000000AAA';

        Test.startTest();
        String res = Pricing_ConsumptionAttr_Controller.saveConsumptionTxtData(qliId, 'p', 'r', 'c', 'g', 's');
        Test.stopTest();

        System.assertNotEquals('true', res, 'On exception, should not be true');
        System.assertNotEquals(null, res, 'Should return an error message');
    }

    @isTest
    public static void testGetPlatformAndSalesGeoPickList_NullQuoteId_ReturnsEmpty() {
        Test.startTest();
        List<Pricing_ConsumptionAccountMapping__c> mappings = Pricing_ConsumptionAttr_Controller.getPlatformAndSalesGeoPickList(null);
        Test.stopTest();
        System.assertEquals(0, mappings.size(), 'Null quote id should return empty list');
    }
    @isTest
    public static void testGetParentQuoteLine_BlankId_ReturnsNull() {
        Test.startTest();
        SBQQ__QuoteLine__c res = Pricing_ConsumptionAttr_Controller.getParentQuoteLine('');
        Test.stopTest();
        System.assertEquals(null, res, 'Blank Id should return null');
    }

    @isTest
    public static void testGetParentQuoteLine_NoMatch_ReturnsNull() {
        // Create a child QL without CR flag/without reference to trigger no selection and catch block or empty return
        SBQQ__QuoteLine__c someQL = [SELECT Id, SBQQ__Quote__c FROM SBQQ__QuoteLine__c LIMIT 1];

        Test.startTest();
        SBQQ__QuoteLine__c res = Pricing_ConsumptionAttr_Controller.getParentQuoteLine(someQL.Id);
        Test.stopTest();

        System.assertEquals(null, res, 'Without CR flag and reference, should return null');
    }
}