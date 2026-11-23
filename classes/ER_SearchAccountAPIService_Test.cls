@IsTest
public class ER_SearchAccountAPIService_Test {

    private static final String TEST_GROUP_NAME = 'ER Search Test Group';
    private static final String EXISTING_CMF_UNIQUE = '12345EU0102Industrial AG Sold-to Party';

    @TestSetup
    static void setupData() {
        ER_Customer_Master_File_Group__c cmfGroup = new ER_Customer_Master_File_Group__c(
            Name = TEST_GROUP_NAME
        );
        insert cmfGroup;

        ER_Customer_Master_File__c cmf = new ER_Customer_Master_File__c(
            Name = 'Existing CMF',
            ER_CMF_Name__c = 'Existing CMF Name',
            ER_CMFUnique__c = EXISTING_CMF_UNIQUE
        );
        insert cmf;

        insert new ER_CMFGroupAssociation__c(
            ER_Customer_Master_File__c = cmf.Id,
            ER_Customer_Master_File_Group__c = cmfGroup.Id,
            ER_StartDate__c = System.now()
        );
    }

    @IsTest
    static void testSearchBusinessPartners_Success() {
        Test.setMock(HttpCalloutMock.class, new SearchSuccessCalloutMock());
        ER_Customer_Master_File_Group__c cmfGroup = getTestGroup();

        Test.startTest();
        Map<String, String> result = (Map<String, String>) ER_SearchAccountAPIService.searchBusinessPartners(
            cmfGroup.Id,
            buildRequest(0)
        );
        Test.stopTest();

        System.assertEquals('27', result.get('RecordCount'), 'The count response should be returned when the first page is requested.');
        System.assert(String.isNotBlank(result.get('Elements')), 'The response should include serialized elements.');

        List<ER_SearchAccountModels.DirectCustomerProfileData> elements =
            (List<ER_SearchAccountModels.DirectCustomerProfileData>) JSON.deserialize(
                result.get('Elements'),
                List<ER_SearchAccountModels.DirectCustomerProfileData>.class
            );

        System.assertEquals(1, elements.size(), 'The unique profile map should return one row for the mock response.');
        System.assertEquals('12345', elements[0].DirectCustomerProfileId, 'The mapped element should preserve the direct profile id.');
        System.assertEquals(false, elements[0].disableButton, 'Existing CMF associations should re-enable the row action.');
    }

    @IsTest
    static void testSearchBusinessPartners_NullInputReturnsEmptyMap() {
        Test.startTest();
        Map<String, String> result = (Map<String, String>) ER_SearchAccountAPIService.searchBusinessPartners(null, null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Null input should be handled and return an empty result map.');
    }

    @IsTest
    static void testSearchBusinessPartners_EmptyInputReturnsEmptyMap() {
        Test.startTest();
        Map<String, String> result = (Map<String, String>) ER_SearchAccountAPIService.searchBusinessPartners(
            getTestGroup().Id,
            new List<ER_SearchAccountModels.RequestBPModel>()
        );
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Empty input should be handled and return an empty result map.');
    }

    @IsTest
    static void testSearchBusinessPartners_ErrorResponseReturnsEmptyMap() {
        Test.setMock(HttpCalloutMock.class, new ErrorCalloutMock());

        Test.startTest();
        Map<String, String> result = (Map<String, String>) ER_SearchAccountAPIService.searchBusinessPartners(
            getTestGroup().Id,
            buildRequest(0)
        );
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Invalid response payloads should be caught and return an empty result map.');
    }

    @IsTest
    static void testBuildFilter_DefaultRoleUsesAG() {
        String filter = ER_AccountFilterBuilder.buildFilter(getTestGroup().Id, buildRequest(0));

        System.assert(filter.contains('"DirectCustomerRelationshipFunctionalRoleCd"=\'AG\''), 'Groups without ODM associations should use the AG role filter.');
        System.assert(filter.contains('"DirectCustomerProfileId"=\'12345\''), 'The direct customer id should be included in the filter.');
        System.assert(filter.contains('"SalesOrganizationCd"=\'EU01\''), 'The sales organization should be included in the filter.');
    }

    @IsTest
    static void testBuildFilter_OdmRoleUsesWE() {
        ER_Customer_Master_File_Group__c cmfGroup = getTestGroup();
        Schema.RecordTypeInfo intelAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account');

        System.assertNotEquals(null, intelAccountRecordType, 'The Intel Account record type must exist for contact setup.');
        Account odmAccount = new Account(
            Name = 'ODM Account',
            RecordTypeId = intelAccountRecordType.getRecordTypeId(),
            Core_IsODM__c = true,
            BillingCountry = 'USA',
            BillingCity = 'New York',
            BillingStreet = 'Test C'
        );
        insert odmAccount;

        Contact contactRecord = new Contact(
            FirstName = 'ODM',
            LastName = 'Contact',
            Email = 'odm.contact@example.com',
            MailingCountry = 'USA',
            Core_Login_Status__c = 'Active',
            AccountId = odmAccount.Id
        );
        insert contactRecord;

        insert new ER_ContactGroupAssociation__c(
            ER_Contact__c = contactRecord.Id,
            ER_Customer_Master_File_Group__c = cmfGroup.Id,
            ER_Active__c = true
        );

        String filter = ER_AccountFilterBuilder.buildFilter(cmfGroup.Id, buildRequest(0));

        System.assert(filter.contains('"DirectCustomerRelationshipFunctionalRoleCd"=\'WE\''), 'Groups with an active ODM association should use the WE role filter.');
    }

    @IsTest
    static void testSaveBusinessPartnerAccounts_CreatesAccountAndAssociation() {
        ER_Customer_Master_File_Group__c cmfGroup = getTestGroup();
        Schema.RecordTypeInfo businessPartnerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Partner');

        System.assertNotEquals(null, businessPartnerRecordType, 'The Business Partner record type must exist for this flow.');
        Id businessPartnerRecordTypeId = businessPartnerRecordType.getRecordTypeId();

        Account existingAccount = new Account(
            Name = 'Existing Business Partner',
            RecordTypeId = businessPartnerRecordTypeId,
            Core_Direct_Account_Id__c = '99999',
            BillingCity = 'Test City',
            BillingCountry = 'USA',
            BillingStreet = 'Test Street'
        );
        insert existingAccount;

        Test.startTest();
        ER_SearchAccountAPIService.saveBusinessPartnerAccounts(cmfGroup.Id, new List<ER_SearchAccountModels.BusinessPartnerDetailModel>{
            buildBusinessPartnerDetail('99999', 'Created Business Partner')
        });
        Test.stopTest();

        Account insertedAccount = [
            SELECT Id, Name, RecordTypeId, Core_Direct_Account_Id__c,
                   Core_Direct_Account_Type_Nm__c, Core_ER_Sales_Area_Order_Block_Code__c,
                   Core_ER_Sales_Area_Order_Block_Name__c
            FROM Account
            WHERE Core_Direct_Account_Id__c = '99999'
            LIMIT 1
        ];

        System.assertEquals('Created Business Partner', insertedAccount.Name, 'The account name should be mapped from the business partner payload.');
        System.assertEquals(businessPartnerRecordTypeId, insertedAccount.RecordTypeId, 'The account should use the Business Partner record type.');
        System.assertEquals('Sold-to Party', insertedAccount.Core_Direct_Account_Type_Nm__c, 'Supported partner roles should map to account type.');
        System.assertEquals('00', insertedAccount.Core_ER_Sales_Area_Order_Block_Code__c, 'Order block codes should be stringified during mapping.');
        System.assertEquals('Open', insertedAccount.Core_ER_Sales_Area_Order_Block_Name__c, 'Order block names should be stringified during mapping.');

        ER_Account_Business_Partner__c association = [
            SELECT ER_Account__c, ER_Customer_Master_File_Grouping__c, ER_Active__c
            FROM ER_Account_Business_Partner__c
            WHERE ER_Account__c = :insertedAccount.Id
            LIMIT 1
        ];

        System.assertEquals(cmfGroup.Id, association.ER_Customer_Master_File_Grouping__c, 'The new association should point to the requested CMF group.');
        System.assertEquals(true, association.ER_Active__c, 'The service should create active partner associations.');
    }

    @IsTest
    static void testSaveBusinessPartnerAccounts_EmptyInputDoesNothing() {
        Test.startTest();
        ER_SearchAccountAPIService.saveBusinessPartnerAccounts(getTestGroup().Id, new List<ER_SearchAccountModels.BusinessPartnerDetailModel>());
        Test.stopTest();

        Integer matchingAccounts = [SELECT COUNT() FROM Account WHERE Core_Direct_Account_Id__c = 'empty-input-check'];
        System.assertEquals(0, matchingAccounts, 'Empty input should not create any accounts.');
    }

    private static ER_Customer_Master_File_Group__c getTestGroup() {
        return [
            SELECT Id, Name
            FROM ER_Customer_Master_File_Group__c
            WHERE Name = :TEST_GROUP_NAME
            LIMIT 1
        ];
    }

    private static List<ER_SearchAccountModels.RequestBPModel> buildRequest(Integer pageFirstRec) {
        ER_SearchAccountModels.RequestBPModel requestModel = new ER_SearchAccountModels.RequestBPModel();
        requestModel.cmfId = '12345';
        requestModel.cmfName = 'Test Account';
        requestModel.salesOrgCode = 'EU01';
        requestModel.salesDistiChannelCode = '02';
        requestModel.pageFirstRec = pageFirstRec;
        return new List<ER_SearchAccountModels.RequestBPModel>{ requestModel };
    }

    private static ER_SearchAccountModels.BusinessPartnerDetailModel buildBusinessPartnerDetail(String directCustomerProfileId, String directCustomerProfileName) {
        ER_SearchAccountModels.BusinessPartnerDetailModel detail = new ER_SearchAccountModels.BusinessPartnerDetailModel();
        detail.DirectCustomerProfileId = directCustomerProfileId;
        detail.DirectCustomerProfileNm = directCustomerProfileName;
        detail.SalesOrganizationCd = 'EU01';
        detail.DistributionChannelCd = '02';
        detail.DistributionChannelNm = 'Industrial';
        detail.DirectCustomerRelationshipFunctionalRoleCd = 'AG';
        detail.DirectCustomerRelationshipFunctionalRoleNm = 'Sold-to Party';
        detail.CityNm = 'Santa Clara';
        detail.PostalCd = '95054';
        detail.DirectCustomerRoleCd = '0001';
        detail.GeographyCd = 'EU';
        detail.SalesAreaOrderBlockCd = '00';
        detail.SalesAreaOrderBlockNm = 'Open';
        detail.CountryNm = null;
        detail.CountrySubdivisionNm = null;
        return detail;
    }

    private class SearchSuccessCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String endpoint = req.getEndpoint();
            System.assert(endpoint.contains('DirectCustomerProfileId'), 'The request should include the direct customer id filter.');
            System.assert(endpoint.contains('SalesOrganizationCd'), 'The request should include the sales organization filter.');
            System.assert(endpoint.contains('DirectCustomerRelationshipFunctionalRoleCd'), 'The request should include the role filter.');
            System.assert(endpoint.contains('\'AG\''), 'The default search role should be AG.');

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            if (endpoint.contains('/$count?')) {
                res.setBody('27');
            } else {
                res.setBody(
                    '{"name":"response","elements":[' +
                    '{"DirectCustomerProfileId":"12345",' +
                    '"DirectCustomerProfileNm":"Test Account",' +
                    '"SalesOrganizationCd":"EU01",' +
                    '"DistributionChannelCd":"02",' +
                    '"DistributionChannelNm":"Industrial",' +
                    '"DirectCustomerRelationshipFunctionalRoleCd":"AG",' +
                    '"DirectCustomerRelationshipFunctionalRoleNm":"Sold-to Party",' +
                    '"PhysicalStreetAddressTxt":"123 Test St",' +
                    '"CityNm":"Test City",' +
                    '"CountryNm":"USA",' +
                    '"PostalCd":"12345",' +
                    '"GeographyCd":"EU",' +
                    '"DirectCustomerRoleCd":"0001",' +
                    '"SalesAreaOrderBlockCd":"00",' +
                    '"SalesAreaOrderBlockNm":"Open"}' +
                    ']}'
                );
            }
            return res;
        }
    }

    private class ErrorCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }
}