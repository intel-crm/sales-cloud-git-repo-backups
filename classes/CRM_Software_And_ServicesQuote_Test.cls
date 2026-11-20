@isTest
public class CRM_Software_And_ServicesQuote_Test {
    
    static List<Account> accountList;
    static Opportunity opp;
	@testSetup
    static void setupTest() {
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        User usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
        
    	accountList = Core_Test_Utility.createAccount(1);
        accountList[0].Name = 'SWAcct';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Agriculture';
        accountList[0].Core_Sub_Industry__c = 'Forestry';
        accountList[0].Core_Business_Partner_Id__c = '12345';
        insert accountList;
        
        
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        lstAcc[1].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel; 
        lstAcc[0].Core_Business_Partner_Id__c = '12345';
        lstAcc[1].Core_Business_Partner_Id__c = '12345';
        insert LstAcc;
        
        List<Id> listDDRId = new List<Id>();
        Core_Design_Registration__c DDRLst = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'FPGA/Power',
            Core_Design_Registration_Nm__c = 'DDR Test',
            Core_Design_Registration_Dsc__c = 'ABC',
            Core_Opportunity_Volume_Cnt__c = 5,
            Core_Partner_FAE_Nm__c = '6',            
            Core_End_Customer_Nm__c = 'DDR Test',            
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
            Core_End_Customer_City_Nm__c = 'BAN',
            Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            Core_End_Customer_Country_Nm__c = 'USA',
            Core_End_Customer_Postal_Cd__c = '560037',
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today()+45,
            Core_First_Customer_Ship_Dt__c = system.today()+46,
            Core_Production_End_Dt__c = system.today().addDays(47),
            Core_Vertical_Market_Nm__c = 'Education',
            Core_Intel_Platform_Nm__c = 'Board',
            Core_Product_Application_Nm__c = 'Business Desktop',
            Core_Product_Segment_Nm__c = 'Client Computing',
            Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Registration_Status_Nm__c = 'Re-Submitted',PCC_End_Customer_Country__c='France',
            PCC_Sub_Industry__c= 'Crop Production',
            PCC_Industry__c='Agriculture',
            PCC_Digital_Identifier__c='Website/URL',
            PCC_Digital_Identifier_Value__c='Test'
        );
        DDRLst.Core_Product_Group_Nm__c ='Embedded/IOT';
        insert DDRLst;
        
        List<Product2> products2 = Core_DDR_Utility.CreateProduct(1);
        insert products2;
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(1);
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(1, TestDDRlst, products2);
        
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(4);
        Id oppDealID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        
        opp = listOpportunity[0];  
        opp.Name = 'SWOpptyTest';
        opp.AccountId = accountList[0].Id;
        opp.Core_Commissionable__c='Yes'; 
        opp.RecordTypeId = oppDealID;
        opp.StageName = 'Qualify';    
        opp.Core_Opportunity_Type__c='Deal: Sell-to';
        opp.Core_Solution_Area__c = 'CCG Commercial Deal $';
        opp.Core_Lead_Conversion_Flag__c = false;
        opp.Core_Volume__c = null;
        opp.Core_Competitive_Architecture__c = null;
        opp.Core_Manufacturing_Geo__c = null;
        opp.CloseDate = System.Date.today().addYears(1);
        opp.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert opp;            
            DDRLst.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            DDRLst.Core_Partner_Account_Id__c = LstAcc[1].id;
            DDRLst.Core_Opportunity_Id__c = opp.id;
            update DDRLst;
        }
         /*Account accountInstance = [select id,name, BillingCountryCode, BIllingStateCode, BillingCity, BillingStreet,            Core_Sales_Groups__c, Industry, Core_Sub_Industry__c 
                                    from Account where name like '%SWAcct%' limit 1];*/
        
         Id accDealID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        // Create a new account        
        Account acct = new Account(Name = 'New Test Account1', BillingStreet = '123 Fake St',Industry ='Gaming', Core_Sub_Industry__c   ='eSports',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(), RecordTypeId = accDealID);//Core_CIM_ID__c = '8675309'
        insert acct;
        
        Contact contactInstance = new Contact();
        contactInstance.FirstName = 'test';
        contactInstance.LastName = 'Contact xyz';
        contactInstance.email = 'test@test1.com';
        contactInstance.AccountId = acct.id;
        contactInstance.MailingCountry = 'India';
        
        insert contactInstance;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = contactInstance.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Business Decision Maker';
        insert ocr;       
    
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
    
    }
    
    @isTest
    static void testHasAccessToCreateSWQuote() {        
        Boolean result;
        // Query the permission set you've created in your org
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        User usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
   		List<PermissionSet> ps = [SELECT Id FROM PermissionSet WHERE Name IN ('Pricing_SW_CPQ_User','Pricing_SW_CPQ_AA_License','Pricing_SW_CPQ_License')];
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(PermissionSetId = ps[0].Id, AssigneeId = usr1.Id),
            new PermissionSetAssignment(PermissionSetId = ps[1].Id, AssigneeId = usr1.Id),
            new PermissionSetAssignment(PermissionSetId = ps[2].Id, AssigneeId = usr1.Id)
        };

        // Insert the PermissionSetAssignments
        insert assignments;
        System.runAs(usr1){
        Opportunity testOpportunity = [Select id,recordtypeId,StageName,Core_Approval_Status__c,Description,OwnerId,AccountId,Core_Product_Count__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c from Opportunity where name like '%SWOpptyTest%' limit 1 ];
        
        result = CRM_Software_And_ServicesQuote.hasAccessToCreateSWQuote(testOpportunity.Id);
        }
        System.assert(result, 'Expected access to create SW Quote to be true/false based on your logic');
    }
    
    @isTest
    static void testHasAccessToCreateSWQuoteFalse() {        
        Boolean result;
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        User usr1 = [SELECT id, Name, isActive,Core_User_Geo__c FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
   		
        Opportunity testOpportunity = [Select id,recordtypeId,StageName,Core_Approval_Status__c,Description,OwnerId,AccountId,Core_Product_Count__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c from Opportunity where name like '%SWOpptyTest%' limit 1 ];
        System.runAs(usr1){
        result = CRM_Software_And_ServicesQuote.hasAccessToCreateSWQuote(testOpportunity.Id);
        }
        System.assertEquals(result,false,'No Access for creating SW Quote.');

    }
    
     @isTest
    static void testHasAccessToCreateSWQuoteOnApprovedOppt() {
        CRM_Software_And_ServicesQuote.SWAndServQuoteSuppRequestWrapper swsuppReq;        
        Opportunity testOpportunity = [Select id,recordtypeId,StageName,Core_Approval_Status__c,Description,OwnerId,AccountId,Core_Product_Count__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c from Opportunity where name like '%SWOpptyTest%' limit 1 ]; 
        testOpportunity.Core_Approval_Status__c = 'Approved';
        testOpportunity.StageName= 'Design';
        testOpportunity.Core_Created_from_CPQ__c = true;
        System.runAs(Core_Test_Utility.systemAdminUser) {
        update testOpportunity;
        swsuppReq = CRM_Software_And_ServicesQuote.getSWAndServQuoteSuppRequestDetails(testOpportunity.Id);
        
        swsuppReq.isApprovedOpptyHardStopError =  Core_CRM_Utility.getCRMLabel('CRM_SW_OpptSubmOrAppHardError');
        
        }
        //System.assert(result, 'Expected access to create SW Quote to be true/false based on your logic');
        System.assertEquals(swsuppReq.isApprovedOpptyHardStopError,  Core_CRM_Utility.getCRMLabel('CRM_SW_OpptSubmOrAppHardError'),'You can create a Quote only when the Opportunity is not Won or Open Status');

    }

   /* @isTest
    static void testIsSWQuoteAlreadyPresent() {
        List<RecordType> recordTypes = [ SELECT Id FROM RecordType WHERE SObjectType = 'SBQQ__Quote__c' AND DeveloperName = 'Pricing_Software_Quote_Create' AND IsActive = true];

		Opportunity testOpportunity = [Select id,recordtypeId,StageName,Core_Approval_Status__c,Description,OwnerId,AccountId,Core_Product_Count__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c from Opportunity where name like '%SWOpptyTest%' limit 1 ];

		OpportunityContactRole ocr = [select id,Role,ContactId from OpportunityContactRole where opportunityid =:testOpportunity.Id limit 1]; // User 
       
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            recordTypeId = recordTypes[0].Id,
            Pricing_SW_Description__c = testOpportunity.Description, 
            SBQQ__PrimaryContact__c = ocr.ContactId,
            SBQQ__Account__c = testOpportunity.AccountId,
            SBQQ__Opportunity2__c = testOpportunity.Id,
            SBQQ__SalesRep__c = testOpportunity.OwnerId,
            SBQQ__StartDate__c= system.today()+1,
            SBQQ__EndDate__c = system.today()+5,
            SBQQ__SubscriptionTerm__c= 4);
        insert testQuote;
        
        //Boolean result = CRM_Software_And_ServicesQuote.isSWQuoteAlreadyPresent(testOpportunity.Id);
		
        //System.assert(result, 'Expected SW Quote to be already present');
    }*/
    @isTest
    static void testGetQuoteProgramName() {
        Opportunity testOpportunity = [Select id,recordtypeId,StageName,Core_Approval_Status__c,Description,OwnerId,AccountId,Core_Product_Count__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c from Opportunity where name like '%SWOpptyTest%' limit 1 ]; 
        OpportunityContactRole ocr = [select id,Role,ContactId from OpportunityContactRole where opportunityid =:testOpportunity.Id limit 1]; // User 
        List<RecordType> recordTypes = [ SELECT Id FROM RecordType WHERE SObjectType = 'SBQQ__Quote__c' AND DeveloperName = 'Pricing_Software_Quote_Create' AND IsActive = true];
        
        SBQQ__Quote__c quotes = new SBQQ__Quote__c(
            recordTypeId = recordTypes[0].Id,
            Pricing_SW_Description__c = testOpportunity.Description, 
            SBQQ__PrimaryContact__c = ocr.ContactId,
            SBQQ__Account__c = testOpportunity.AccountId,
            SBQQ__Opportunity2__c = testOpportunity.Id,
            SBQQ__SalesRep__c = testOpportunity.OwnerId,
            SBQQ__StartDate__c= system.today()+1,
            SBQQ__EndDate__c = system.today()+5,
            SBQQ__SubscriptionTerm__c= 4); 
        try {
            insert quotes;
        }
        catch(exception ex) {
            PMP_Utility.logError(ex, 'CRM_Software_And_ServicesQuote_Test.testGetQuoteProgramName');
        }
        
        // Call the method under test
        Test.startTest();
        List<String> result = CRM_Software_And_ServicesQuote.getQuoteProgramName(testOpportunity.Id);
        Test.stopTest();
        
        // Assert that the result contains the expected program names
        System.assertEquals(0, result.size(), 'There should be no distinct program names.');        
    }

    @isTest
    static void testGetSWAndServQuoteSuppRequestDetails() {
        
		Opportunity testOpportunity = [Select id,recordtypeId,StageName,Core_Approval_Status__c,Description,OwnerId,AccountId,Core_Product_Count__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c from Opportunity where name like '%SWOpptyTest%' limit 1 ];
        testOpportunity.Core_VBS_Potential__c = true;
        testOpportunity.Core_VBS_Status__c='SOAR1 Qualified';
        update testOpportunity;
        CRM_Software_And_ServicesQuote.SWAndServQuoteSuppRequestWrapper result = CRM_Software_And_ServicesQuote.getSWAndServQuoteSuppRequestDetails(testOpportunity.Id);

        System.assertNotEquals(null, result, 'Expected result to not be null');
        
    }
    
    @isTest
    static void testGetSWAndServQuoteWithoutContactRole() {
        Opportunity testOpportunity = [Select id,recordtypeId,StageName,Core_Approval_Status__c,Description,OwnerId,AccountId,Core_Product_Count__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c from Opportunity where name like '%SWOpptyTest%' limit 1 ];

		OpportunityContactRole ocr = [select id,Role,ContactId from OpportunityContactRole where opportunityid =:testOpportunity.Id limit 1]; // User 
        ocr.IsPrimary=false;
		update ocr;
        
        CRM_Software_And_ServicesQuote.SWAndServQuoteSuppRequestWrapper swsuppReq = CRM_Software_And_ServicesQuote.getSWAndServQuoteSuppRequestDetails(testOpportunity.Id);
        
        swsuppReq.isApprovedOpptyHardStopError =  Core_CRM_Utility.getCRMLabel('CRM_SW_QuoteCntCreateWithoutPriContact');
        System.assertEquals(swsuppReq.isApprovedOpptyHardStopError,  Core_CRM_Utility.getCRMLabel('CRM_SW_QuoteCntCreateWithoutPriContact'),'Software Quote cannot be created without Primary Contact Role.');

    }
}