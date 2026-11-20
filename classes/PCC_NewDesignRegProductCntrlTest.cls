/****************************************************************************************************************************************
* Class Name  : PCC_NewDesignRegProductCntrlTest 
* Version     : 1.0 
* Created Date:  01-08-2024
* Modification Log :
* Developer            		  Date               DescriptionP
* ---------------------------------------------------------------------------------------------------------------------------------------
Aravind                       01-08-2024          This is the test class for PCC_NewDesignRegProductCntrl apex class
*****************************************************************************************************************************************/
@IsTest
private class PCC_NewDesignRegProductCntrlTest {
    /**
     * This is a setup method used to insert required data for this particular test class.
     */
    @TestSetup
    static void setupData() {
        Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account accRec = new Account(
            Name = 'TestAccount',
            BillingStreet = '123 Fake St',
            Core_Geo__c = 'EMEA',
            BillingCity = 'Springfield',
            BillingState = 'IL',
            BillingCountry = 'USA',
            Industry = 'Agriculture',
            Core_Sub_Industry__c = 'Crop Production',
            BillingPostalCode = '12345',
            Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI(),
            RecordTypeId = intelRecordTypeId
        );
        insert accRec;

        Contact conRec = PRM_TestUtility.getContact();
        conRec.AccountId = accRec.Id;
        conRec.Core_Preferred_Language__c = 'ENG';
        conRec.Core_eRPM_Language_Code__c = 'ENG';
        conRec.Core_IPA_Partner_Role__c = 'Service Provider';
        conRec.Email = 'testUsercoreMPM1245@intel.com';
        conRec.MailingCountry='India';
        insert conRec;

        Profile profileRec = [SELECT Id FROM Profile WHERE name = 'Partner'];

        User partnerUser = new User(
            Alias = String.valueOf(datetime.now()).substring(0, 8),
            Email = 'testUsercoreMPM1245@intel.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser' + String.valueOf(date.today()),
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testUserLL' + String.valueOf(Math.random()) + '@CoreMPM.com',
            FirstName = 'TestUtilityKK',
            ContactId = conRec.id,
            ProfileId = profileRec.Id
        );
        insert partnerUser;

        System.runAs(partnerUser) {
            insert createDrInstance();
        }

        Product2 productRecord = new Product2();
        productRecord.Core_iPaaS_Load_ID__c = '654890';
        productRecord.Core_Product_Org__c = 'Sales';
        productRecord.Name = 'Private Wireless Network';
        productRecord.Core_Hierarchy_ID__c = '43';
        productRecord.Core_Hierarchy_Name__c = 'Valid Product Hierarchy';
        productRecord.Core_Product_Type_EPM_ID__c = '86547';
        productRecord.Core_Product_Type__c = 'Programs';
        productRecord.Core_Product_Status__c = 'AC';
        productRecord.Core_Product_Name_EPM_ID__c = '65498';
        productRecord.Core_Unique_ID__c = '65498;65477;67282;86547';
        productRecord.IsActive = true;
        insert productRecord;
    }

    /**
     * This method is used to return instance of design registration record.
     */
    private static Core_Design_Registration__c createDrInstance() {
        Core_Design_Registration__c ddrRec = new Core_Design_Registration__c();
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec.Core_Vertical_Market_Nm__c = 'Education';
        ddrRec.Core_Product_Segment_Nm__c = 'Client Computing';
        ddrRec.Core_Product_Application_Nm__c = 'Business Desktop';
        ddrRec.Core_Opportunity_Volume_Cnt__c = 100;
        ddrRec.Core_Partner_FAE_Nm__c = 'Test FAE';
        ddrRec.Core_Partner_FSR_Nm__c = 'Test FSR';
        ddrRec.Core_End_Customer_Nm__c = 'Arrow Electronics Account';
        ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c = '12 Street 99';
        ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c = '';
        ddrRec.PCC_End_Customer_Country__c = 'India';
        ddrRec.Core_End_Customer_City_Nm__c = 'Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c = 'Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c = '758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c = 'Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c = 'Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c = 'arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c = '7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c = 'ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today() + 20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today() + 21;
        ddrRec.Core_Production_End_Dt__c = system.today() + 22;
        ddrRec.Core_Design_Registration_Nm__c = 'Test DR Name Arrow9';
        ddrRec.Core_Design_Registration_Dsc__c = 'Test Des';
        ddrRec.Core_External_Id__c = 'abczd001';
        ddrRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        ddrRec.PCC_Consumption_Countries__c = 'Test';
        ddrRec.PCC_Current_EndCustomer_Product_Provider__c = 'Test';
        ddrRec.RecordTypeId = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName()
            .get('Design_Registration_Partner_Draft')
            .getRecordTypeId();
        ddrRec.Core_Design_Registration_Status_Nm__c = 'Submitted';

        return ddrRec;
    }

    /**
     * This method is a test method to cover getPriceForProduct method.
     */
    @isTest
    public static void testgetPriceForProduct() {
        List<Product2> prd = [SELECT Id FROM Product2 WHERE Core_Unique_ID__c = '65498;65477;67282;86547'];

        Product_MM_Attribute_Mapping__c mmAttributes = new Product_MM_Attribute_Mapping__c();
        mmAttributes.Level_1_EPM_ID__c = '98836';
        mmAttributes.Level_2_EPM_ID__c = '130101';
        mmAttributes.Level_3_EPM_ID__c = '130103';
        mmAttributes.Level_4_EPM_ID__c = '147261';
        mmAttributes.Level_5_EPM_ID__c = '130211';
        mmAttributes.MMID__c = '768221';
        mmAttributes.Unique_ID__c = '768221;130211;147261;130103;130101;98836';
        mmAttributes.iPaaS_Load_ID__c = '654890';
        mmAttributes.Name = '89292';
        mmAttributes.IsActive__c = true;
        mmAttributes.L4_Product__c = prd[0].Id;
        mmAttributes.Eligible_for_DDI_Payment__c = 'Yes';
        mmAttributes.DDI_focused__c = 'Tier 1';
        mmAttributes.PCC_DDI_Program_Pay_Rate_APJ_PRC__c = 'Tier 3';
        mmAttributes.Payment_Expiration_Date__c = System.today();
        insert mmAttributes;

        PCC_ParnterLed_Price__c priceRec = new PCC_ParnterLed_Price__c();
        priceRec.PCC_Material_Master__c = '89292';
        priceRec.PCC_Product_MM_Attribute_Mapping__c = mmAttributes.Id;
        priceRec.PCC_Standard_Disti_Price__c = 23;
        insert priceRec;

        List<Core_Design_Registration__c> dr = [SELECT Id FROM Core_Design_Registration__c LIMIT 1];

        Test.startTest();
        PCC_NewDesignRegProductCntrl.getPriceForProduct(prd[0].Id, null, dr[0].Id);
        PCC_NewDesignRegProductCntrl.PriceDataResponse res = PCC_NewDesignRegProductCntrl.getPriceForProduct(null, mmAttributes.Id, dr[0].Id);
        Test.stopTest();
        Assert.areEqual(23, res.sdp, 'Correct standard disti price returned');
    }
}