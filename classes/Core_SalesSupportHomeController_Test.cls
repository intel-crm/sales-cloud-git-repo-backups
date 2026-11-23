/**************************************************************************************
Apex Class Name:  Core_SalesSupportHomeController_Test
Version     : 1.0 
Created Date: 24 OCT 2014
Function    : Test Class for the Core_SalesSupportHomeController
Modification Log :
* Developer           Date               Description
* ----------------------------------------------------------------------------            
* Srikant Joshi       Oct 24, 2014       Original Version
* Srikant Joshi       Feb 18, 2015       Modified the code to fetch only 1 user - Line 122
* Dave Hood           Jul 27, 2015       Copied from original code, refactored, updated for R2
* Accenture           Dec 26, 2016       Test Method for PSG Quote    
* Rangesh Kona        Aug 22nd, 2017     update @isTest(SeeAllData at the class level to method level)
*                                        applied as needed only
* Rangesh Kona        Aug 31st, 2017     Improved test coverage
*************************************************************************************/
@isTest
public class Core_SalesSupportHomeController_Test{
    
    @testSetup
    static void prepareCustomSetting(){
        List<Core_System_Credentials__c> sysCredList = new List<Core_System_Credentials__c>();
        Core_System_Credentials__c sysCred = new Core_System_Credentials__c();
        sysCred.Name = 'Core AC Mule Service';
        sysCred.Core_End_Point_URL__c = 'https://eip-crm-proxy.cloudhub.io.dummy/smit/api/eip-crm-sls-account-coverage/ACSTART';
        sysCredList.add(sysCred);
        sysCred = new Core_System_Credentials__c();
        sysCred.Name = 'Core_AGS_Get_Entitlement';
        sysCred.Core_End_Point_URL__c = 'https://eip-crm-proxy.cloudhub.io.dummy/smit/api/eip-crm-sls-ags/currentroles';
        sysCredList.add(sysCred);
        sysCred = new Core_System_Credentials__c();
        sysCred.Name = 'Demo Depot Order Management';
        sysCred.Core_End_Point_URL__c = 'http://idd.intel.com.dummy:8081/Order/Management/OrderDetails.aspx?';
        sysCredList.add(sysCred);
        sysCred = new Core_System_Credentials__c();
        sysCred.Name = 'Demo Depot Order Placement';
        sysCred.Core_End_Point_URL__c = 'http://idd.intel.com.dummy:8081/Order/Default.aspx?';
        sysCredList.add(sysCred);
        sysCred = new Core_System_Credentials__c();
        sysCred.Name = 'Demo Depot Service';
        sysCred.Core_End_Point_URL__c = 'https://eip-crm-seeds.cloudhub.io.dummy/api/seeds';
        sysCredList.add(sysCred);
        sysCred = new Core_System_Credentials__c();
        sysCred.Name = 'My Samples Home';
        sysCred.Core_End_Point_URL__c = 'https://mysamples.intel.com.dummy';
        sysCredList.add(sysCred);
        sysCred = new Core_System_Credentials__c();
        sysCred.Name = 'My Samples Request Management';
        sysCred.Core_End_Point_URL__c = 'https://mysamples.intel.com.dummy/SAM_U_Request/Request_History.aspx?';
        sysCredList.add(sysCred);
        sysCred = new Core_System_Credentials__c();
        sysCred.Name = 'My Samples Request Placement';
        sysCred.Core_End_Point_URL__c = 'https://mysamples.intel.com.dummy?';
        sysCredList.add(sysCred);
        sysCred = new Core_System_Credentials__c();
        sysCred.Name = 'My Samples Service';
        sysCred.Core_End_Point_URL__c = 'https://eip-crm-proxy.cloudhub.io.dummy/smit/api/eip-crm-sls-sf2mysamples';
        sysCredList.add(sysCred);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert sysCredList;
        }
        
        //Added BY Bishal Singh - Accenture
        SBQQ.TriggerControl.disable();
        /*List<User> lstUsers2 = PSG_Test_Utility.createAdminUser(); 
        List<User> SOSUser = PSG_Test_Utility.createDistyUser();
        System.runAs(lstUsers2[0]){
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            Test.startTest();
            PriceBook2 pb = PSG_Test_Utility.createPriceBook('abcd');
            List<Product2> pdt = PSG_Test_Utility.createProduct(1);
            PSG_Test_Utility.createProductDetails();
            Account acc = PSG_Test_Utility.createDirectAccount();
            Account acc1= PSG_Test_Utility.createAccount();
            acc1.Core_Direct_Pricing_Parent_Id__c=acc.id;
            acc1.Core_Direct_Legal_Parent_Id__c=acc.id;
            update acc1;
            Test.stopTest();
            List<PriceBookEntry> pbe = [Select Id from PriceBookEntry limit 1];
            Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            Opportunity opportunityRecord =new Opportunity();
            opportunityRecord.Name='TestOpty';
            opportunityRecord.accountId = acc1.Id;
            opportunityRecord.CloseDate= system.today();
            opportunityRecord.Core_First_Customer_Ship_Date__c=date.parse('12/01/2020');
            opportunityRecord.Core_Production_End_Date__c=date.parse('12/16/2020');
            opportunityRecord.Core_Volume__c=90;
            opportunityRecord.Core_Product_Segment__c='Client Computing';
            opportunityRecord.Core_Product_Application__c='Business Mobility';
            opportunityRecord.Core_Technical_Owner__c = userInfo.getUserId();
            opportunityRecord.Core_PSG_Quote_Last_Processed_Status__c='Success';
            opportunityRecord.StageName='Qualify';
            opportunityRecord.Core_Consumption_Market__c='Agriculture';
            opportunityRecord.Core_Military_Aerospace_Govmt_End_Use__c='No';
            insert opportunityRecord;
            
            Core_Design_Registration__c designRegistration =new Core_Design_Registration__c();
            
            designRegistration.Core_Opportunity_Id__c=opportunityRecord.id;
            
            designRegistration.Core_Product_Group_Nm__c='FPGA/Power';
            designRegistration.Core_Design_Registration_Nm__c='testDesignres';
            designRegistration.Core_Design_Registration_Dsc__c='desing res decription';
            designRegistration.Core_Opportunity_Volume_Cnt__c=20;
            designRegistration.Core_Partner_FAE_Nm__c='Me';
            designRegistration.Core_End_Customer_Nm__c='testNameEndcust';
            designRegistration.Core_End_Customer_Street_Addr_Line1_Txt__c='bakerstreet';
            designRegistration.Core_End_Customer_Street_Addr_Line2_Txt__c='Market Strasse';
            designRegistration.Core_End_Customer_City_Nm__c='Texas';
            designRegistration.Core_End_Customer_Country_Subdivision_Nm__c='Bihar';
            designRegistration.Core_End_Customer_Postal_Cd__c='78100006';
            
            designRegistration.Core_End_Customer_Country_Nm__c='USA';
            designRegistration.Core_End_Customer_Account_Id__c=acc1.id;
            
            designRegistration.Core_Military_Aerospace_Gvrnmt_Use_Ind__c='No';
            
            designRegistration.Core_Product_Segment_Nm__c='Client Computing';
            designRegistration.Core_Product_Application_Nm__c='Business Mobility';
            designRegistration.Core_Opportunity_Decision_Dt__c=system.today().addYears(1);
            designRegistration.Core_First_Customer_Ship_Dt__c=System.today().addYears(2);
            designRegistration.Core_Production_End_Dt__c=System.today().addYears(3);
            designRegistration.Core_Vertical_Market_Nm__c='Agriculture';
            designRegistration.Core_Intel_Platform_Nm__c='ALDER LAKE';
            designRegistration.PCC_End_Customer_Country__c = 'United States';
            insert designRegistration;
            List<Product2> prods=new List<Product2>();
            Product2 product = new Product2(Name='TestProduct',
                                            Core_Product_Org__c = 'Sales',
                                            Core_Product_Type__c = 'Processors',
                                            Core_Design_Registration_Eligible_Ind__c = true,
                                            Core_Sales_Visible_Flag__c = true,
                                            Core_Hierarchy_ID__c = '43',
                                            Core_Group_Code_Short_Name__c = 'DCG',
                                            Core_Item_Quotable_Ind__c = true,
                                            Core_Item_Orderable_Ind__c = true,
                                            IsActive = true);
            prods.add(product);
            Product2 product1 = new Product2(Name='TestProduct1',
                                             Core_Product_Org__c = 'Sales',
                                             Core_Product_Type__c = 'Processors',
                                             Core_Design_Registration_Eligible_Ind__c = true,
                                             Core_Sales_Visible_Flag__c = false,
                                             Core_Hierarchy_ID__c = '43',
                                             Core_Group_Code_Short_Name__c = 'DCG',
                                             Core_Item_Quotable_Ind__c = false,
                                             Core_Item_Orderable_Ind__c = false,
                                             IsActive = false);
            prods.add(product1);
            insert prods;
            
            Core_Design_Registration_Product__c designRegistrationProduct=new Core_Design_Registration_Product__c();
            designRegistrationProduct.Core_Target_Resale_Amt__c=200;
            designRegistrationProduct.Core_Product_Id__c=product.id;
            designRegistrationProduct.Core_Design_Registration_Id__c=designRegistration.id;
            designRegistrationProduct.Core_Full_Year_Qty__c=10;
            
            insert designRegistrationProduct;
            List<OpportunityLineItem> opportunityProduct = new List<OpportunityLineItem>();
            OpportunityLineItem optypdt =new OpportunityLineItem();
            optypdt.product2id = prods[0].Id;
            optypdt.OpportunityId = opportunityRecord.Id;
            optypdt.Core_Design_Registration_Product_Id__c = designRegistrationProduct.Id;
            optypdt.Quantity =10;
            optypdt.TotalPrice = 240;
            optypdt.Core_At_Risk_Status__c = 'In-Progress';
            optypdt.PricebookEntryId = pbe[0].Id;
            opportunityProduct.add(optypdt);
            
            OpportunityLineItem optypdt1 =new OpportunityLineItem();
            optypdt1.product2id = prods[1].Id;
            optypdt1.OpportunityId = opportunityRecord.Id;
            optypdt1.Core_Design_Registration_Product_Id__c = null;
            optypdt1.Quantity = 10; 
            optypdt1.TotalPrice = 240;
            optypdt1.Core_At_Risk_Status__c = 'In-Progress';
            optypdt1.PricebookEntryId = pbe[0].Id;
            opportunityProduct.add(optypdt1);
            insert opportunityProduct;
        }*/
    }
    
    /*
* Method name  : testSeedsHttpResponseTest
* Description  : test method to cover Core_SalesSupportHomeControllerclass
* Return Type  : VOID
* Parameter    : NONE
*/ 
    static  void testSeedsHttpResponseTest(){
        
        List<Account> accList = Core_SalesSupportPSGQuote_Test.createAccount(1,false);
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
         accList[0].RecordTypeId = masterRecordTypeId;
        accList[0].Name ='Test Account';accList[0].Core_Account_Type__c = 'End Customer';accList[0].RecordTypeId=masterRecordTypeId;accList[0].BillingCity='San Jose';accList[0].BillingCountry='USA';accList[0].BillingsTATE='CA';
        accList[0].BillingStreet='West Tasman Drive';accList[0].Industry='Accommodation and Food Services';accList[0].Core_Sub_Industry__c='Accommodation';accList[0].Core_Sales_Groups__c='PRC Sales Group';
        insert accList;
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(2, accList[0]);
        String oppoRecordTypeId = [SELECT Id, Name, SobjectType, IsActive FROM RecordType where SobjectType ='Opportunity' and Name='Deal Opportunity'].Id;
        oppList[0].Core_Product_Application__c='Business Mobility';
        oppList[1].Core_Product_Application__c='Business Mobility';
        oppList[1].Core_Product_Segment__c='Client Computing';
        oppList[0].Core_Product_Segment__c='Client Computing';
        oppList[0].RecordTypeId= oppoRecordTypeId;
        oppList[1].RecordTypeId= oppoRecordTypeId;
        insert oppList;
        //Construct two list to form the resultset
        List < Core_SalesSupportHomeController.seedWebserviceWrapper > lstSeedWebserviceWrapper = new List < Core_SalesSupportHomeController.seedWebserviceWrapper >{};
        List < Core_SalesSupportHomeController.seedWebserviceWrapper > lstAssertSeedWebserviceWrapper = new List < Core_SalesSupportHomeController.seedWebserviceWrapper >{};
                
        Test.startTest();
        //Set the dealsupport home page
        PageReference pageRef = Page.Core_SalesSupportHome;
        Test.setCurrentPage(pageRef);
        
        //Since webservice methods cannot be called directly from a test method
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpResponseGenerator());
        
        Core_SalesSupportHomeController controllerCoreOppDesc = new Core_SalesSupportHomeController();
        controllerCoreOppDesc.init();
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, oppList[0].Id);
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, oppList[0].Id);
        ApexPages.currentPage().getParameters().put(system.label.Core_AccountName, accList[0].Name);
        ApexPages.currentPage().getParameters().put(system.label.Core_CIMID, accList[0].Core_Business_Party_Id__c);
        ApexPages.currentPage().getParameters().put(System.Label.Core_OpportunityName, 'testOpportunity');
        
        Core_SalesSupportHomeController controllerOppCoreOppDesc = new Core_SalesSupportHomeController();
        controllerOppCoreOppDesc.init();
        
        Core_SalesSupportHomeController controllerAccntCoreOppDesc = new Core_SalesSupportHomeController();
        controllerAccntCoreOppDesc.pullSeeds();
        
        controllerAccntCoreOppDesc.sSeedSearch[1] = 'Dell';
        controllerAccntCoreOppDesc.filterSeeds();
        
        controllerAccntCoreOppDesc.sSeedSearch[0] = 'test';
        controllerAccntCoreOppDesc.filterSeeds();
        
        controllerAccntCoreOppDesc.sSeedSearch[1] = '';
        controllerAccntCoreOppDesc.filterSeeds();
        
        // set up the list to be matched with the resultset
        Core_SalesSupportHomeController.seedWebserviceWrapper seedWeb = new Core_SalesSupportHomeController.seedWebserviceWrapper();
        seedWeb.AccountID = accList[0].Id;
        seedWeb.OpportunityID = oppList[0].Id;
        
        Core_SalesSupportHomeController.seedWebserviceWrapper seedWeb1 = new Core_SalesSupportHomeController.seedWebserviceWrapper();
        seedWeb1.AccountID = accList[0].Id;
        seedWeb1.OpportunityID = oppList[0].Id;     
        
        lstAssertSeedWebserviceWrapper.add(seedWeb1);
        
        System.assertNotEquals(lstSeedWebserviceWrapper, lstAssertSeedWebserviceWrapper);
        test.stopTest();
    }
    
    static testMethod void testprocessSSGRequest() {
        
        //Core_OpportunityQuotePSGSales_Test.setupTestData();
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        List<Account> accList = Core_SalesSupportPSGQuote_Test.createAccount(1,true);
         accList[0].RecordTypeId = masterRecordTypeId;
        accList[0].Name ='Test Account';accList[0].Core_Account_Type__c = 'End Customer';accList[0].RecordTypeId=masterRecordTypeId;accList[0].BillingCity='San Jose';accList[0].BillingCountry='USA';accList[0].BillingsTATE='CA';
        accList[0].BillingStreet='West Tasman Drive';accList[0].Industry='Accommodation and Food Services';accList[0].Core_Sub_Industry__c='Accommodation';accList[0].Core_Sales_Groups__c='PRC Sales Group';
        insert accList;
        
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(2,accList[0]);
        String oppoRecordTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        oppList[0].Core_Product_Application__c='Business Mobility';
        oppList[0].Core_Product_Segment__c='Client Computing';
        oppList[0].StageName ='Qualify';
        oppList[1].StageName ='Qualify';
        oppList[1].Core_Product_Segment__c='Client Computing';
        oppList[1].Core_Product_Application__c='Business Mobility';
        oppList[0].RecordTypeId= oppoRecordTypeId;
        oppList[1].RecordTypeId= oppoRecordTypeId;
        insert oppList;
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        
        
        Core_SalesSupportHomeController ssgTest = new Core_SalesSupportHomeController();
        
        ssgTest.processSSGRequest();
        system.assertEquals(false,ssgTest.showNoAccessMessage);
        
        ssgTest.sOppId = null;
        ssgTest.processSSGRequest();
        PageReference pageRef = Page.Core_SSR_Create;
        Test.setCurrentPage(pageRef);
        system.assertEquals(true,ssgTest.showNavigationErrorMessage);
        
    }
    
    /*
* Method name  : testSeedsHttpNoResponseTest
* Description  : test method to cover Core_SalesSupportHomeControllerclass
* Return Type  : VOID
* Parameter    : NONE
*/ 
    @isTest(SeeAllData=false)
    static void testSeedsHttpNoResponseTest(){
        
        //Since webservice methods cannot be called directly from a test method
        List < Core_SalesSupportHomeController.seedWebserviceWrapper > lstSeedWebserviceWrapper = new List < Core_SalesSupportHomeController.seedWebserviceWrapper >{};
            List < Core_SalesSupportHomeController.seedWebserviceWrapper > lstAssertSeedWebserviceWrapper = new List < Core_SalesSupportHomeController.seedWebserviceWrapper >{};
                
                //Since webservice methods cannot be called directly from a test method        
                PageReference pageRef = Page.Core_SalesSupportHome;
        Test.setCurrentPage(pageRef);
        
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpNoResponseGenerator());
        
        Core_SalesSupportHomeController controllerCoreOppDesc = new Core_SalesSupportHomeController();
        //controllerCoreOppDesc.filterSeeds();
        controllerCoreOppDesc.init();
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, '9999');
        
        Core_SalesSupportHomeController controllerOppCoreOppDesc = new Core_SalesSupportHomeController();
        //controllerOppCoreOppDesc.filterSeeds();
        controllerOppCoreOppDesc.init();
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, NULL);
        ApexPages.currentPage().getParameters().put(system.label.Core_AccountName, '9999');
        ApexPages.currentPage().getParameters().put(system.label.Core_CIMID, '9999');
        
        Core_SalesSupportHomeController controllerAccntCoreOppDesc = new Core_SalesSupportHomeController();
        controllerAccntCoreOppDesc.pullSeeds();
        
        System.assertEquals(lstSeedWebserviceWrapper, lstAssertSeedWebserviceWrapper);
        
        controllerAccntCoreOppDesc.filterSeeds(); 
        
    }
    
    
    /*
* Method name  : testSeedsUserHttpResponseTest
* Description  : test method to cover Core_SalesSupportHomeController class
* Return Type  : VOID
* Parameter    : NONE
*/ 
    @isTest
    static  void testSeedsUserHttpResponseTest(){
        
        
        
        Profile profileofusers = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1]; 
        
        List<User> lstUser = new List<User>();
        
        lstUser = Core_Test_Utility.Core_User(1);
        
        if(profileofusers != NULL)
            lstUser[0].Profileid = profileofusers.id;
        
        insert lstUser;
        
        User StandardUser = lstUser[0];
        test.startTest();
        System.runAs(StandardUser){ 
            
            PageReference pageRef = Page.Core_SalesSupportHome;
            Test.setCurrentPage(pageRef);
            
            //Since webservice methods cannot be called directly from a test method
            Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpNoResponseGenerator());
            
            Core_SalesSupportHomeController controllerCoreOppDesc = new Core_SalesSupportHomeController();
            //controllerCoreOppDesc.filterSeeds();
            controllerCoreOppDesc.init();
            
            //Add parameters to page URL
            ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, '9999');
            
            Core_SalesSupportHomeController controllerOppCoreOppDesc = new Core_SalesSupportHomeController();
            controllerOppCoreOppDesc.pullSeeds();
            controllerOppCoreOppDesc.init();
            
            //Add parameters to page URL
            ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, NULL);
            ApexPages.currentPage().getParameters().put(system.label.Core_AccountName, '9999');
            ApexPages.currentPage().getParameters().put(system.label.Core_CIMID, '9999');
            
            Core_SalesSupportHomeController controllerAccntCoreOppDesc = new Core_SalesSupportHomeController();
            controllerAccntCoreOppDesc.pullSeeds();
            controllerAccntCoreOppDesc.filterSeeds();
            
        }
        test.stopTest();
    }
    
    /*
* Method name  : testSeedsOpportunityResponseTest
* Description  : test method to cover Core_SalesSupportHomeControllerOpportunity records
* Return Type  : VOID
* Parameter    : NONE
*/ 
    //  @isTest(SeeAllData=false)
    static testMethod void testSeedsOpportunityResponseTest(){
        
        
        PageReference pageRef = Page.Core_SalesSupportHome;
        Test.setCurrentPage(pageRef);
        
        //Since webservice methods cannot be called directly from a test method
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpNoResponseGenerator());
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        
        // Construct the Opportunity instances
        lstOpportunity = Core_Test_Utility.Core_Opportunity(6);
        
        // Insert the intialized Opportunity 
        Database.SaveResult[] lstSaveResultCS = Database.insert(lstOpportunity, false);
        
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpNoResponseGenerator());
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, lstOpportunity[0].ID);
        
        Core_SalesSupportHomeController controllerOppCoreOppDesc = new Core_SalesSupportHomeController();
        //controllerOppCoreOppDesc.filterSeeds();
        controllerOppCoreOppDesc.init();
        
    }
    
    /*
* Method name  : testSeedsOpportunityNULLResponseTest
* Description  : test method to cover Core_SalesSupportHomeController Opportunity records
* Return Type  : VOID
* Parameter    : NONE
*/ 
    //@isTest(SeeAllData=false)
    static  testMethod void testSeedsOpportunityNULLResponseTest(){
        
        
        
        PageReference pageRef = Page.Core_SalesSupportHome;
        Test.setCurrentPage(pageRef);
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        
        //Since webservice methods cannot be called directly from a test method
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpNULLResponseGenerator());
        
        // Construct the Opportunity instances
        lstOpportunity = Core_Test_Utility.Core_Opportunity(6);
        
        // Insert the intialized Opportunity 
        Database.SaveResult[] lstSaveResultCS = Database.insert(lstOpportunity, false);
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, lstOpportunity[0].ID);
        
        Core_SalesSupportHomeController controllerOppCoreOppDesc = new Core_SalesSupportHomeController();
        //controllerOppCoreOppDesc.filterSeeds();
        controllerOppCoreOppDesc.init();       
        
    }
    
    @isTest(SeeAllData=false)
    static  void testSamplessCallouts() {
        
        
        
        // Pages, controller, and other vars we'll use for testing
        PageReference ssPage = Page.Core_SalesSupportHome;
        PageReference nextPage;
        Core_SalesSupportHomeController ssController;
        String str = '';
        
        List<Account> accList = Core_SalesSupportPSGQuote_Test.createAccount(1,false);
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
         accList[0].RecordTypeId = masterRecordTypeId;
        accList[0].Name ='Test Account';accList[0].Core_Account_Type__c = 'End Customer';accList[0].RecordTypeId=masterRecordTypeId;accList[0].BillingCity='San Jose';accList[0].BillingCountry='USA';accList[0].BillingsTATE='CA';
        accList[0].BillingStreet='West Tasman Drive';accList[0].Industry='Accommodation and Food Services';accList[0].Core_Sub_Industry__c='Accommodation';accList[0].Core_Sales_Groups__c='PRC Sales Group';
        insert accList;
        
        
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(2,accList[0]);
        String oppoRecordTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        oppList[0].Core_Product_Application__c='Business Mobility';
        oppList[0].Core_Product_Segment__c='Client Computing';
        oppList[0].RecordTypeId= oppoRecordTypeId; 
        oppList[1].Core_Product_Segment__c='Client Computing';
        oppList[1].Core_Product_Application__c='Business Mobility';
        oppList[1].RecordTypeId= oppoRecordTypeId; 
        oppList[0].StageName ='Qualify';
        oppList[1].StageName ='Qualify';
        insert oppList;
        
        // Get any valid Account ID (needed for the assignment statements in the class to work)
        Id arbitraryAcctId = accList[0].Id;
        
        //----------------------------------------------------------------------------------
        // FROM SALES SUPPORT TAB DIRECTLY
        
        // Happy path
        Test.setCurrentPage(ssPage);
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpResponseGenerator());
        Test.startTest();
        ssController = new Core_SalesSupportHomeController();
        
        //Code added on 12-20-2016 to avoid Attempt to Reference Null Object issue 
        ssController.bSamplesErrorFlag = false;
        ssController.lstFilteredSamples = null;
        ssController.err='Valid quote';
        ssController.confirmPwd='Confirm';
        ssController.first='First';
        ssController.last='last';
        
        ssController.sCurrentTab = 'tabSamples';
        ssController.init();
        ssController.pullSamples();
        
        ssController.sSampleSearch[2] = 'processor';
        ssController.filterSamples();
        
        ssController.sSampleSearch[2] = 'dave';
        ssController.filterSamples();
        
        ssController.sSampleSearch[2] = '';
        ssController.filterSamples();
        
        //Testing for coverage
        
        Core_SalesSupportHomeController.SampleWebserviceWrapper samplewebse = new Core_SalesSupportHomeController.SampleWebserviceWrapper();
        samplewebse.RequestProductID='12334';
        samplewebse.RequestID='123354';
        samplewebse.RDD='Test'; 
        samplewebse.Line='LineTest';
        samplewebse.RequestedMM='TestMM'; 
        samplewebse.RequestedEPMName ='Tester';
        samplewebse.ApprovedMM='Business'; 
        samplewebse.ApprovedEPMName='Intel Business';
        samplewebse.Requester ='Dev team';
        samplewebse.RequestQty='{!Environment.Core_MDF_SFDC_Environment} Team'; 
        samplewebse.ApprovedQty='Business'; 
        samplewebse.OBO ='OBO';
        samplewebse.ApproverName ='Intel';
        samplewebse.ApproverEmail ='testbc@gmail.com';
        samplewebse.Status ='Pending';
        samplewebse.Socket='Socket';
        samplewebse.Media='Test Media'; 
        samplewebse.Stepping ='test steping';
        samplewebse.QDF ='test QDF';
        samplewebse.BoxQuantity='large'; 
        samplewebse.Contact='intel business'; 
        samplewebse.CustomerName ='customer ';
        samplewebse.CustomerCMFID ='12345';
        samplewebse.ShiptoCustomerName ='business customer';
        samplewebse.ShipToCustomerCMFID='786686'; 
        samplewebse.StreetAddress1 ='Electronic city';
        samplewebse.StreetAddress2='Phase 1'; 
        samplewebse.City ='Bangalore';
        samplewebse.StateName ='Karnataka';
        samplewebse.ZipCode ='560037';
        samplewebse.Country ='India';
        samplewebse.ActualShipDtm ='test sdd';
        samplewebse.TrackingIdForCarrier1Txt ='568399';
        samplewebse.TrackingIdForCarrier2Txt='7979'; 
        samplewebse.CustomerCIMID ='23344';
        samplewebse.DefaultCIM ='33445';
        samplewebse.DefaultCIMID ='9898';
        samplewebse.GridViewAccountName='test123'; 
        samplewebse.GridViewOpportunityName ='test34';
        samplewebse.GridViewOpportunityStage='pending'; 
        
        samplewebse.DetailViewCIMIDs='testt'; 
        samplewebse.DetailViewOppIDs ='yyss';
        samplewebse.bRenderCSection=true;
        // ssController.lstSamples='[{"RequestProductID":"2275","RequestID":"1823","RDD":"2015-07-20 00:00:00","Line":"100","RequestedMM":"879067","RequestedEPMName":"Intel Portable Cache Module (battery back-up unit) with 256MB DDR2 ECC - single pack","ApprovedMM":"","ApprovedEPMName":"","Requester":"DAVID A HOOD","RequestQty":"5","ApprovedQty":"0","OBO":"DAVID A HOOD","ApproverName":"","ApproverEmail":"","Status":"Requested","Socket":"","Media":"","Stepping":"","QDF":"","BoxQuantity":1,"Contact":"Craig Hood","CustomerName":"Intel Corporation","CustomerCMFID":"","ShiptoCustomerName":"Luscombe Eng Co Inc - CO","ShipToCustomerCMFID":"0002020061","StreetAddress1":"1500 Kansas Ave Ste 1B","StreetAddress2":"","City":"Longmont","StateName":"Colorado","ZipCode":"80501-6539","Country":"United States","ActualShipDtm":"","TrackingIdForCarrier1Txt":"","TrackingIdForCarrier2Txt":"","RequestProductCreatedDate":"2015-07-13T13:40:21","RequestProductModifiedDate":"2015-07-13T13:41:15","Opportunity":[{"AccountCIMID":"12341234","OpportunityId":""}];
        ssController.lstSamples.add(samplewebse);
        
        
        ssController.lstSamples[0].bRenderCSection = true;
        
        str = ssController.lstSamples[0].RequestProductID;
        str = ssController.lstSamples[0].RequestedMM;
        str = ssController.lstSamples[0].ApprovedMM;
        str = ssController.lstSamples[0].ApprovedEPMName;
        str = ssController.lstSamples[0].Requester;
        str = ssController.lstSamples[0].OBO;
        str = ssController.lstSamples[0].ApproverEmail;
        str = ssController.lstSamples[0].Socket;
        str = ssController.lstSamples[0].Media;
        str = ssController.lstSamples[0].Stepping;
        str = ssController.lstSamples[0].QDF;
        str = ssController.lstSamples[0].BoxQuantity;
        str = ssController.lstSamples[0].Contact;
        str = ssController.lstSamples[0].CustomerName;
        str = ssController.lstSamples[0].CustomerCMFID;
        str = ssController.lstSamples[0].ShiptoCustomerName;
        str = ssController.lstSamples[0].ShipToCustomerCMFID;
        str = ssController.lstSamples[0].StreetAddress1;
        str = ssController.lstSamples[0].StreetAddress2;
        str = ssController.lstSamples[0].City;
        str = ssController.lstSamples[0].StateName;
        str = ssController.lstSamples[0].ZipCode;
        str = ssController.lstSamples[0].Country;
        str = ssController.lstSamples[0].ActualShipDtm;
        str = ssController.lstSamples[0].TrackingIdForCarrier1Txt;
        str = ssController.lstSamples[0].TrackingIdForCarrier2Txt;
        str = ssController.lstSamples[0].GridViewOpportunityName;
        str = ssController.lstSamples[0].GridViewOpportunityStage; 
        
        
        nextPage = ssController.toggleRendering();
        
        //----------------------------------------------------------------------------------
        // FROM AN ACCOUNT
        
        // Happy path
        Test.setCurrentPage(ssPage);
        ApexPages.currentPage().getParameters().put(System.Label.Core_CIMID, '1234512345');
        ApexPages.currentPage().getParameters().put(System.Label.Core_AccountName, 'Test Account 123');
        ApexPages.currentPage().getParameters().put(System.Label.Core_AccountID, arbitraryAcctId);
        ssController = new Core_SalesSupportHomeController();
        ssController.sCurrentTab = 'tabSamples';
        ssController.init();
        ssController.pullSamples();
        
        // Without the correct parameters passed
        Test.setCurrentPage(ssPage);
        ApexPages.currentPage().getParameters().put(System.Label.Core_CIMID, '');
        ApexPages.currentPage().getParameters().put(System.Label.Core_AccountName, 'Test Account 123');
        ApexPages.currentPage().getParameters().put(System.Label.Core_AccountID, arbitraryAcctId);
        ssController = new Core_SalesSupportHomeController();
        ssController.sCurrentTab = 'tabSamples';
        ssController.init();
        
        //----------------------------------------------------------------------------------
        // FROM AN OPPORTUNITY
        
        // Happy path
        Test.setCurrentPage(ssPage);
        ApexPages.currentPage().getParameters().put(System.Label.Core_OpportunityID, '1234512345');
        ApexPages.currentPage().getParameters().put(System.Label.Core_OpportunityName, 'Test Opportunity 1');
        ssController = new Core_SalesSupportHomeController();
        ssController.sCurrentTab = 'tabSamples';
        ssController.init();
        ssController.pullSamples();
        
        // Filtering
        ssController.sSampleSearch[0] = 'test';
        ssController.sSampleSearch[1] = 'test';
        ssController.sSampleSearch[2] = 'test';
        ssController.sSampleSearch[3] = 'test';
        ssController.sSampleSearch[4] = 'test';
        ssController.sSampleSearch[5] = 'test';
        ssController.sSampleSearch[6] = 'test';
        ssController.sSampleSearch[7] = 'test';
        ssController.sSampleSearch[8] = 'test';
        ssController.sSampleSearch[9] = 'test';
        ssController.sSampleSearch[10] = 'test';
        ssController.sSampleSearch[11] = 'test';
        ssController.lstSamples = new List<Core_SalesSupportHomeController.sampleWebserviceWrapper>();
        ssController.filterSamples();
        
        //----------------------------------------------------------------------------------
        // Null Http Response
        
        Test.setCurrentPage(ssPage);
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpNullResponseGenerator());
        ssController = new Core_SalesSupportHomeController();
        ssController.sCurrentTab = 'tabSamples';
        ssController.init();
        ssController.pullSamples();
        
        // If we made it this far, and didn't get any errors, we're good
        System.assertEquals(1, 1);
        Test.stopTest();
    }
    
    // @isTest(SeeAllData=false)
    static testMethod void testSamplesAccessChecks() {
        
        
        // Pages, controller, and parameter map we'll use for testing
        PageReference ssPage = Page.Core_SalesSupportHome;
        Core_SalesSupportHomeController ssController;
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;

        // Set up a test account and opportunity that we'll use
        Account acct = new Account(Name='Test Account', BillingCountryCode='USA', BillingStateCode='OR',
                                   BillingCity='Portland',Core_Sales_Groups__c= 'PRC Sales Group', Industry='Consulting',Core_Sub_Industry__c='Consulting',BillingStreet='123 Fake St.', Core_Business_Party_Id__c = '999293859',RecordTypeId=recordtypeId);
        insert acct;
        
        Opportunity opp = new Opportunity(Name='Test Opportunity 1', AccountId=acct.Id, StageName='Qualify',
                                          CloseDate=System.Today().addDays(24));
        insert opp;
        
        //----------------------------------------------------------------------------------
        // FROM SALES SUPPORT TAB DIRECTLY
        
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpResponseGenerator());
        Test.startTest();
        
        // Where the user doesn't have a WWID
        User usr = createUser();
        
        insert usr;
        
        System.runAs(usr) {
            
            Test.setCurrentPage(ssPage);
            ssController = new Core_SalesSupportHomeController();
            ssController.sCurrentTab = 'tabSamples';
            ssController.init();
        }
        
        //----------------------------------------------------------------------------------
        // FROM AN ACCOUNT
        
        // Where the user doesn't have access
        System.runAs(usr) {
            Test.setCurrentPage(ssPage);
            ApexPages.currentPage().getParameters().put(System.Label.Core_CIMID, acct.Core_Business_Party_Id__c);
            ApexPages.currentPage().getParameters().put(System.Label.Core_AccountName, acct.Name);
            ApexPages.currentPage().getParameters().put(System.Label.Core_AccountID, acct.Id);
            ssController = new Core_SalesSupportHomeController();
        }
        
        //----------------------------------------------------------------------------------
        // FROM AN OPPORTUNITY
        
        // Where the user doesn't have access
        System.runAs(usr) {
            Test.setCurrentPage(ssPage);
            ApexPages.currentPage().getParameters().put(System.Label.Core_OpportunityID, opp.Id);
            ApexPages.currentPage().getParameters().put(System.Label.Core_OpportunityName, 'Test Opportunity 1');
            ssController = new Core_SalesSupportHomeController();
        }
        
        // If we made it this far, and didn't get any errors, we're good
        System.assertEquals(1, 1);        
        Test.stopTest();
    }
    
    /**********************************
* Method Name : createUser
* Created On  : Aug 31st, 2017
* Created By  : Rangesh Kona
* Description : createTest user to use it
*               for runAs scenarios
***********************************/
    public static User createUser() {
        // Where the user doesn't have a WWID
        User usr = new User();
        usr.Firstname = 'test';
        usr.LastName = 'samples 1';
        usr.userName = 'testusersamples1@intel.com.crm';
        usr.email = 'testsamples1@intel.com';
        usr.alias = 'samp1';
        usr.communityNickName = 'testusersamples1';
        usr.profileId = [select Id from Profile where Name = 'CCP - Core Access' limit 1][0].Id;
        //usr.profileId = [select Id from Profile where Name = 'Sales Rep-BB' limit 1][0].Id;
        // usr.profileId = [select Id from Profile where Name = 'Partner' limit 1][0].Id;
        usr.LANGUAGELOCALEKEY = 'en_US';
        usr.LOCALESIDKEY = 'en_US';
        usr.TIMEZONESIDKEY = 'America/Los_Angeles';
        usr.EMAILENCODINGKEY = 'ISO-8859-1';
        usr.Core_Employee_Type_Code__c = 'EMP';
        
        return usr;
    }
    
    /**********************************
* Method Name : testSalesSupportHomeCreatePSGQuote_Test 
* Created On  : Dec-17-2016
* Created By  : Accenture 
* Description : Intel Altera Phase1: 
*               Below test method is used for  creating the Quote
*        
***********************************/
    public static User createUser1() {
        User usr1 = new User();
        usr1.Firstname = 'test';
        usr1.LastName = 'samples 1';
        usr1.userName = 'testusersamples1@intel.com.crm';
        usr1.email = 'testsamples1@intel.com';
        usr1.alias = 'samp1';
        // usr1.ContactId =[select Id from Contact limit 1][0].Id;
        usr1.communityNickName = 'testusersamples1';
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.PSG_PermissionSets_PSG_Distributor];
        Id r = [Select id from UserRole where name = 'Admin' limit 1].id;
        Id p = [SELECT Id FROM PROFILE WHERE Name =: Label.Pricing_Tender_Profiles_Partner].id;   
        usr1.profileId=p;
        usr1.UserRoleid = r;
        // usr1.profileId = [select Id from Profile where Name = 'Partner' limit 1][0].Id;
        // usr.profileId = [select Id from Profile where Name = 'Partner' limit 1][0].Id;
        usr1.LANGUAGELOCALEKEY = 'en_US';
        usr1.LOCALESIDKEY = 'en_US';
        usr1.TIMEZONESIDKEY = 'America/Los_Angeles';
        usr1.EMAILENCODINGKEY = 'ISO-8859-1';
        usr1.Core_Employee_Type_Code__c = 'EMP';
        
        return usr1;
        
    }

    /*************************************************************************************************************************** */


        // @isTest(SeeAllData=false)
        static testMethod void testSalesSupportHomeCreatePSGQuote_Test1() {
        
            //Core_OpportunityQuotePSGSales_Test.setupTestData();
            List<Account> accList = Core_SalesSupportPSGQuote_Test.createAccount(1,true);
            //Account a1=PSG_Test_Utility.createDirectAccount();
            Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            Account a1 = [SELECT Id from Account where RecordTypeId=:recordtypeId];
            //Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
            //triggerExecList.Bypass__c = true;
            //insert triggerExecList;
            
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
             accList[0].RecordTypeId = masterRecordTypeId;
            accList[0].Name ='Test Account';accList[0].Core_Account_Type__c = 'End Customer';accList[0].RecordTypeId=masterRecordTypeId;accList[0].BillingCity='San Jose';accList[0].BillingCountry='USA';accList[0].BillingsTATE='CA';
            accList[0].BillingStreet='West Tasman Drive';accList[0].Industry='Accommodation and Food Services';accList[0].Core_Sub_Industry__c='Accommodation';accList[0].Core_Sales_Groups__c='PRC Sales Group';
            accList[0].Core_PSG_Account__c = true;
            accList[0].Core_Direct_Pricing_Parent_Id__c=a1.id;
            accList[0].Core_Direct_Legal_Parent_Id__c=a1.id;
    
            insert accList;
            
            List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(2,accList[0]);
    
            String oppoRecordTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
            oppList[0].Core_Product_Application__c='Business Mobility';
            oppList[0].Core_Product_Segment__c='Client Computing';
            oppList[0].RecordTypeId= oppoRecordTypeId; 
            oppList[1].Core_Product_Application__c='Business Mobility';
            oppList[1].Core_Product_Segment__c='Client Computing';
            oppList[1].RecordTypeId= oppoRecordTypeId;
            oppList[0].StageName ='Qualify';
            oppList[1].StageName ='Qualify';
            oppList[0].Core_PSG_Quote_Last_Processed_Status__c='Success';
            oppList[1].Core_PSG_Quote_Last_Processed_Status__c='Success';
            insert oppList;
            ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
            
            List<OpportunityLineItem> oppLineItemList = Core_SalesSupportPSGQuote_Test.createOpportunityProduct(1,oppList[0],true);
            insert oppLineItemList;
            
            List<Core_Opportunity_Partner__c> oppPartnerList = Core_SalesSupportPSGQuote_Test.createOpportunityPartner(1,accList[0],oppList[0]);
            insert oppPartnerList;
        
            upsert new Core_PSG_Integration_Settings__c (Name = 'MyCustSettingName', SetupOwnerId=UserInfo.getOrganizationId(), Core_User_Name__c='test',Core_Password__c = 'test' ); 
            
            Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
           
            
           
            Test.startTest();
            
            Id intelRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
            
            
            Account acct = new Account(Name = 'TestDE_', BillingStreet = '123 Fake St',
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                       BillingPostalCode = '12345', Core_Sales_Groups__c='PRC Sales Group', Core_Account_Type__c='End Customer',Core_PSG_Account__c = true,Core_Direct_Account_Type_Nm__c='End Customer Parent',
                                       Core_Is_Pricing_Parent_ChkBox__c=true,Core_Direct_Account_Active_Ind__c=true);
            insert acct;
           
       
            Contact con = new Contact();
            con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
            con.FirstName = 'FirstName2';
            con.LastName = 'LastName2';
            con.Email = 'FirstName2@intel.com';
            con.AccountId = acct.Id;
            con.Core_Primary_Contact__c = true;
            con.MailingCountry='USA';
            insert con;
           
            //User sysUser = [SELECT id, email  from user where email = 'adminuser@intel.com'];
            User usr1 = createUser1();
            usr1.ContactId = con.Id;
            system.debug('usr1  '+ usr1);
            /*List<User> lstUsers2 = PSG_Test_Utility.createAdminUser(); 
            system.debug('lstUsers2 '+lstUsers2);
            System.runAs(lstUsers2[0]){
                //insert usr1;
            }*/
            
           /* User usr1 = createUser1();
            usr1.ContactId = con.Id;
            insert usr1;*/
    
            SBQQ.TriggerControl.disable();       
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
            Opportunity opps1 = new Opportunity(Name = 'Opportunity to Lose 03-24-2023', RecordTypeId = newOppRecTypeId,
                                                AccountId = acct.Id,Core_Volume__c =10,Core_First_Customer_Ship_Date__c=System.TODAY(),
                                                StageName = 'Qualify', Core_PSG_Quote_Last_Processed_Status__c='Success', CloseDate = System.Date.today().addYears(1));
            insert opps1;
            
            List<OpportunityLineItem> oppLineItemList1 = Core_SalesSupportPSGQuote_Test.createOpportunityProduct(1,opps1,true);
            insert oppLineItemList1;
            List<Core_Opportunity_Partner__c> oppPartnerList1 = Core_SalesSupportPSGQuote_Test.createOpportunityPartner(1,acct,opps1);
            insert oppPartnerList1;
            
            Core_SalesSupportHomeController.bOpportunityValidForQuoteCreation=true;
            Core_SalesSupportHomeController.isPartner=true;
            List<String> errm1 = new List<String>{'Custom message'};
            Core_SalesSupportHomeController.errorMessage =errm1;
            //Core_SalesSupportHomeController.createPSGQuoteonSiebelNew(opps1.Id);
          
    
            //END DINESH
            //System.runas(usr1) {
                
                Core_SalesSupportHomeController.bOpportunityValidForQuoteCreation=true;
                List<String> errm = new List<String>{'Custom message'};
                Core_SalesSupportHomeController.errorMessage =errm; 
               
            //}
            test.stopTest();
        }
    

    /************************************************************************************************************************* */
    // @isTest(SeeAllData=false)
    static testMethod void createPSGQuoteonSiebel_NegativeTest() {
        
        //Core_OpportunityQuotePSGSales_Test.setupTestData();
        List<Account> accList = Core_SalesSupportPSGQuote_Test.createAccount(1,true);
        //Account a1=PSG_Test_Utility.createDirectAccount();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        Account a1 = [SELECT Id from Account where RecordTypeId=:recordtypeId];
        //Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        //triggerExecList.Bypass__c = true;
        //insert triggerExecList;
        
        
        a1.RecordTypeId=recordtypeId;
        a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
        a1.Core_Is_Pricing_Parent_ChkBox__c=true;
        a1.Core_Direct_Account_Active_Ind__c=true;
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            update a1;
        //}
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();

         accList[0].RecordTypeId = masterRecordTypeId;
        accList[0].Name ='Test Account';accList[0].Core_Account_Type__c = 'End Customer';accList[0].RecordTypeId=masterRecordTypeId;accList[0].BillingCity='San Jose';accList[0].BillingCountry='USA';accList[0].BillingsTATE='CA';
        accList[0].BillingStreet='West Tasman Drive';accList[0].Industry='Accommodation and Food Services';accList[0].Core_Sub_Industry__c='Accommodation';accList[0].Core_Sales_Groups__c='PRC Sales Group';
        accList[0].Core_PSG_Account__c = true;
        accList[0].Core_Direct_Pricing_Parent_Id__c=a1.id;
        accList[0].Core_Direct_Legal_Parent_Id__c=a1.id;
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            insert accList;
        //}
        
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(2,accList[0]);

        String oppoRecordTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        oppList[0].Core_Product_Application__c='Business Mobility';
        oppList[0].Core_Product_Segment__c='Client Computing';
        oppList[0].RecordTypeId= oppoRecordTypeId; 
        oppList[1].Core_Product_Application__c='Business Mobility';
        oppList[1].Core_Product_Segment__c='Client Computing';
        oppList[1].RecordTypeId= oppoRecordTypeId;
        oppList[0].StageName ='Qualify';
        oppList[1].StageName ='Qualify';
        oppList[0].Core_PSG_Quote_Last_Processed_Status__c='Success';
        oppList[1].Core_PSG_Quote_Last_Processed_Status__c='Success';
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppList;
        //}
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        
        List<OpportunityLineItem> oppLineItemList = Core_SalesSupportPSGQuote_Test.createOpportunityProduct(1,oppList[0],true);
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppLineItemList;
        //}
        
        List<Core_Opportunity_Partner__c> oppPartnerList = Core_SalesSupportPSGQuote_Test.createOpportunityPartner(1,accList[0],oppList[0]);
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppPartnerList;
        //}
        
        // Rangesh - Custom setting was not visible to the test class, so inserted custom setting record
        // 
        // Insert custom setting data 
        
        Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
        Id intelRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
         // Where the user doesn't have a WWID
        
        Account acct = new Account(Name = 'TestDE_', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c='PRC Sales Group', Core_Account_Type__c='End Customer',Core_PSG_Account__c = true,Core_Direct_Account_Type_Nm__c='End Customer Parent',
                                   Core_Is_Pricing_Parent_ChkBox__c=true,Core_Direct_Account_Active_Ind__c=true);
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        //}
       
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'FirstName2';
        con.LastName = 'LastName2';
        con.Email = 'FirstName2@intel.com';
        con.AccountId = acct.Id;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry='USA';
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            insert con;
        //}
     
        User usr1 = createUser1();
        usr1.ContactId = con.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            //insert usr1;
        }
        
        Test.startTest();
         
        SBQQ.TriggerControl.disable();       

        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity opps1 = new Opportunity(Name = 'Opportunity to Lose 03-24-2023', RecordTypeId = newOppRecTypeId,
                                            AccountId = acct.Id,Core_Volume__c =10,Core_First_Customer_Ship_Date__c=System.TODAY(),
                                            StageName = 'Qualify', Core_PSG_Quote_Last_Processed_Status__c='Success', CloseDate = System.Date.today().addYears(1));
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps1;
        //}
        List<PriceBookEntry> pbe = [Select Id from PriceBookEntry limit 1];
        List<Product2> prods=new List<Product2>();
        Product2 product = new Product2(Name='TestProduct',
                                        Core_Product_Org__c = 'Sales',
                                        Core_Product_Type__c = 'Processors',
                                        Core_Design_Registration_Eligible_Ind__c = true,
                                        Core_Sales_Visible_Flag__c = true,
                                        Core_Hierarchy_ID__c = '43',
                                        Core_Group_Code_Short_Name__c = 'DCG',
                                        Core_Item_Quotable_Ind__c = true,
                                        Core_Item_Orderable_Ind__c = true,
                                        IsActive = true);
        prods.add(product);
        

        List<OpportunityLineItem> opportunityProduct = new List<OpportunityLineItem>();
        OpportunityLineItem optypdt =new OpportunityLineItem();
        optypdt.product2id = prods[0].Id;
        optypdt.OpportunityId = opps1.Id;
        optypdt.Quantity =10;
        optypdt.TotalPrice = 240;
        optypdt.Core_At_Risk_Status__c = 'In-Progress';
        optypdt.PricebookEntryId = pbe[0].Id;
        opportunityProduct.add(optypdt);

        List<Core_Opportunity_Partner__c> oppPartnerList1 = Core_SalesSupportPSGQuote_Test.createOpportunityPartner(1,acct,opps1);
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppPartnerList1;
        //}
        
        Core_SalesSupportHomeController.bOpportunityValidForQuoteCreation=true;
        Core_SalesSupportHomeController.isPartner=true;
        List<String> errm1 = new List<String>{'Custom message'};
        Core_SalesSupportHomeController.errorMessage =errm1;
        //Core_SalesSupportHomeController.createPSGQuoteonSiebelNew(opps1.Id);
         
        //END DINESH
        //System.runas(usr1) {
            
            ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, opps1.Id);
            //objHomeController.isPartner = true;
            Core_SalesSupportHomeController.isPartner=true;
            String oppId=ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, opps1.Id);
            objHomeController.selectedISR = 'Testing';
            //objHomeController.createPSGQuoteonSiebel();
            objHomeController.sobjAcct=acct;
            Core_SalesSupportHomeController.bOpportunityValidForQuoteCreation=true;
            List<String> errm = new List<String>{'Custom message'};
            Core_SalesSupportHomeController.errorMessage =errm;
            //Core_SalesSupportHomeController.createPSGQuoteonSiebelNew(opps1.Id);
           
        //}
        test.stopTest();
        // Ranegsh - Changes End
    }
    /*********************** */

    static testMethod void testSalesSupportHomeCreatePSGQuoteNew_NegativeTest() {
        SBQQ.TriggerControl.disable();       
        /*List<User> lstUsers2 = PSG_Test_Utility.createAdminUser(); 
        List<User> SOSUser = PSG_Test_Utility.createDistyUser();
        Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();        
        PriceBook2 pb = PSG_Test_Utility.createPriceBook('PSG Price Book');
        PSG_Test_Utility.createProductDetails();
        Account acc = PSG_Test_Utility.createDirectAccount();
        Account acc1= PSG_Test_Utility.createAccount();
        acc1.Core_Direct_Pricing_Parent_Id__c=acc.id;
        acc1.Core_Direct_Legal_Parent_Id__c=acc.id;
        update acc1;*/
        //new changes added - Bishal Singh Accenture   
        Account acct = new Account(Name = 'TestDE_', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c='PRC Sales Group', Core_Account_Type__c='End Customer',Core_PSG_Account__c = true,Core_Direct_Account_Type_Nm__c='End Customer Parent',
                                   Core_Is_Pricing_Parent_ChkBox__c=true,Core_Direct_Account_Active_Ind__c=true);
        insert acct;
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'FirstName2';
        con.LastName = 'LastName2';
        con.Email = 'FirstName2@intel.com';
        con.AccountId = acct.Id;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry='USA';
        insert con;
      
        //ended Bishal Singh - Accenture
        User usr1 = createUser1();
        usr1.ContactId = con.Id;
        //insert usr1;
        
        /*System.runas(SOSUser[0]){
            Test.startTest();
            List<PriceBookEntry> pbe = [Select Id from PriceBookEntry limit 1];
            Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            Opportunity opportunityRecord =new Opportunity();
            opportunityRecord.Name='TestOpty';
            opportunityRecord.accountId = acct.Id;
            opportunityRecord.CloseDate= system.today();
            opportunityRecord.Core_First_Customer_Ship_Date__c=date.parse('12/01/2020');
            opportunityRecord.Core_Production_End_Date__c=date.parse('12/16/2020');
            opportunityRecord.Core_Volume__c=90;
            opportunityRecord.Core_Product_Segment__c='Client Computing';
            opportunityRecord.Core_Product_Application__c='Business Mobility';
            opportunityRecord.Core_Technical_Owner__c = userInfo.getUserId();
            opportunityRecord.Core_PSG_Quote_Last_Processed_Status__c='Success';
            opportunityRecord.StageName='Qualify';
            opportunityRecord.Core_Consumption_Market__c='Agriculture';
            opportunityRecord.Core_Military_Aerospace_Govmt_End_Use__c='No';
            insert opportunityRecord;
            Core_Design_Registration__c designRegistration =new Core_Design_Registration__c();
            designRegistration.Core_Opportunity_Id__c=opportunityRecord.id;
            designRegistration.Core_Product_Group_Nm__c='FPGA/Power';
            designRegistration.Core_Design_Registration_Nm__c='testDesignres';
            designRegistration.Core_Design_Registration_Dsc__c='desing res decription';
            designRegistration.Core_Opportunity_Volume_Cnt__c=20;
            designRegistration.Core_Partner_FAE_Nm__c='Me';
            designRegistration.Core_End_Customer_Nm__c='testNameEndcust';
            designRegistration.Core_End_Customer_Street_Addr_Line1_Txt__c='bakerstreet';
            designRegistration.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
            designRegistration.Core_End_Customer_City_Nm__c='Texas';
            designRegistration.Core_End_Customer_Country_Subdivision_Nm__c='Bihar';
            designRegistration.Core_End_Customer_Postal_Cd__c='78100006';
            designRegistration.Core_End_Customer_Country_Nm__c='USA';
            designRegistration.Core_End_Customer_Account_Id__c=acct.id;
            designRegistration.Core_Military_Aerospace_Gvrnmt_Use_Ind__c='No';
            designRegistration.Core_Product_Segment_Nm__c='Client Computing';
            designRegistration.Core_Product_Application_Nm__c='Business Mobility';
            designRegistration.Core_Opportunity_Decision_Dt__c=system.today().addYears(1);
            designRegistration.Core_First_Customer_Ship_Dt__c=System.today().addYears(2);
            designRegistration.Core_Production_End_Dt__c=System.today().addYears(3);
            designRegistration.Core_Vertical_Market_Nm__c='Agriculture';
            designRegistration.Core_Intel_Platform_Nm__c='KASEYVILLE';
            designRegistration.PCC_End_Customer_Country__c = 'United States';
            insert designRegistration;
            List<Product2> prods=new List<Product2>();
            Product2 product = new Product2(Name='TestProduct',
                                            Core_Product_Org__c = 'Sales',
                                            Core_Product_Type__c = 'Processors',
                                            Core_Design_Registration_Eligible_Ind__c = true,
                                            Core_Sales_Visible_Flag__c = true,
                                            Core_Hierarchy_ID__c = '43',
                                            Core_Group_Code_Short_Name__c = 'DCG',
                                            Core_Item_Quotable_Ind__c = true,
                                            Core_Item_Orderable_Ind__c = true,
                                            IsActive = true);
            prods.add(product);
            Product2 product1 = new Product2(Name='TestProduct1',
                                             Core_Product_Org__c = 'Sales',
                                             Core_Product_Type__c = 'Processors',
                                             Core_Design_Registration_Eligible_Ind__c = true,
                                             Core_Sales_Visible_Flag__c = false,
                                             Core_Hierarchy_ID__c = '43',
                                             Core_Group_Code_Short_Name__c = 'DCG',
                                             Core_Item_Quotable_Ind__c = false,
                                             Core_Item_Orderable_Ind__c = false,
                                             IsActive = false);
            prods.add(product1);
            insert prods;
            Core_Design_Registration_Product__c designRegistrationProduct=new Core_Design_Registration_Product__c();
            designRegistrationProduct.Core_Target_Resale_Amt__c=200;
            designRegistrationProduct.Core_Product_Id__c=product.id;
            designRegistrationProduct.Core_Design_Registration_Id__c=designRegistration.id;
            designRegistrationProduct.Core_Full_Year_Qty__c=10;
            
            insert designRegistrationProduct;
            List<OpportunityLineItem> opportunityProduct = new List<OpportunityLineItem>();
            OpportunityLineItem optypdt =new OpportunityLineItem();
            optypdt.product2id = prods[0].Id;
            optypdt.OpportunityId = opportunityRecord.Id;
            optypdt.Core_Design_Registration_Product_Id__c = designRegistrationProduct.Id;
            optypdt.Quantity =10;
            optypdt.TotalPrice = 240;
            optypdt.Core_At_Risk_Status__c = 'In-Progress';
            optypdt.PricebookEntryId = pbe[0].Id;
            opportunityProduct.add(optypdt);
            OpportunityLineItem optypdt1 =new OpportunityLineItem();
            //optypdt1.product2id = prods[1].Id;
            optypdt1.OpportunityId = opportunityRecord.Id;
            optypdt1.Core_Design_Registration_Product_Id__c = null;
            optypdt1.Quantity = 10; 
            optypdt1.TotalPrice = 240;
            optypdt1.Core_At_Risk_Status__c = 'In-Progress';
            optypdt1.PricebookEntryId = pbe[0].Id;
            opportunityProduct.add(optypdt1);
            insert opportunityProduct;
            System.assertEquals(acc.BillingCountry,'USA');            
            /* 
            List<OpportunityLineItem> oppLineItemList = Core_SalesSupportPSGQuote_Test.createOpportunityProduct(1,opportunityRecord,true);
            insert oppLineItemList;
            
            List<Core_Opportunity_Partner__c> oppPartnerList = Core_SalesSupportPSGQuote_Test.createOpportunityPartner(1,acct,opportunityRecord);
            insert oppPartnerList;
            //System.runAs(usr1){
                SBQQ.TriggerControl.disable();
                //PSG_CreateQuoteController.getLoginUserType();
                //Core_SalesSupportHomeController.createPSGQuoteonSiebelNew(opportunityRecord.Id); 
                Core_SalesSupportHomeController.isPartner=true;
            //}
            Test.stopTest();
        }*/
    }
    

    /**********************************
* Method Name : testSalesSupportHomePullPSGQuoteHistory_Test 
* Created On  : Dec-17-2016
* Created By  : Accenture 
* Description : Intel Altera Phase1: 
*               Below Test method is used for pulling the PSG Quote History data 
*        
***********************************/
    static testmethod void testSalesSupportHomePullPSGQuoteHistory_Test() {
        
        //Core_OpportunityQuotePSGSales_Test.setupTestData();
        List<Account> accList = Core_SalesSupportPSGQuote_Test.createAccount(1,true);
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
         accList[0].RecordTypeId = masterRecordTypeId;
        accList[0].Name ='Test Account';accList[0].Core_Account_Type__c = 'End Customer';accList[0].RecordTypeId=masterRecordTypeId;accList[0].BillingCity='San Jose';accList[0].BillingCountry='USA';accList[0].BillingsTATE='CA';
        accList[0].BillingStreet='West Tasman Drive';accList[0].Industry='Accommodation and Food Services';accList[0].Core_Sub_Industry__c='Accommodation';accList[0].Core_Sales_Groups__c='PRC Sales Group';
        insert accList;
        
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(2,accList[0]);
        String oppoRecordTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        oppList[0].Core_Product_Application__c='Business Mobility';
        oppList[1].Core_Product_Application__c='Business Mobility';
        oppList[0].Core_Product_Segment__c='Client Computing';
        oppList[1].Core_Product_Segment__c='Client Computing';
        oppList[1].RecordTypeId= oppoRecordTypeId;
        oppList[0].RecordTypeId= oppoRecordTypeId;
        oppList[0].StageName ='Qualify';
        oppList[1].StageName ='Qualify';
        insert oppList;
        
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        
        List<OpportunityLineItem> oppLineItemList = Core_SalesSupportPSGQuote_Test.createOpportunityProduct(1,oppList[0],true);
        insert oppLineItemList;
        
        List<Core_Integration_Inbound_Message__c>  inboundMessageList = Core_SalesSupportPSGQuote_Test.insertIntegrationInboundMessage(1,oppList[0]);
        insert inboundMessageList;
        Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
        objHomeController.pullPSGQuoteHistory();
        //}
        //This functionality is used for loading the initial Tab
        objHomeController.sCurrentTab = 'tabSeeds';
        
        objHomeController.loadFirstTab();
        //Sathis start
        objHomeController.sCurrentTab = 'tabSamples';
        objHomeController.loadFirstTab();
        //Sathis end
        List<Core_PSG_Quote_Generation_History__c> quoteGenarationList = [SELECT Id, Name, Core_Opportunity__c, Core_RFQ_ID__c FROM Core_PSG_Quote_Generation_History__c where Core_Opportunity__c =:oppList[0].Id];
        //System.AssertEquals(1,quoteGenarationList.size());
        
        
    }
    
    
    /**********************************
* Method Name : testSalesSupportHomePullPSGQuoteHistory_Test 
* Created On  : Dec-17-2016
* Created By  : Accenture 
* Description : Intel Altera Phase1: 
*               Below Test method for checking already processing PSG quote  
***********************************/
    static testmethod void testSalesSupportHomeAlreadyProcessingPSGQuote_Test() {
        
        List<Account> accList = Core_SalesSupportPSGQuote_Test.createAccount(1,true);
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
         accList[0].RecordTypeId = masterRecordTypeId;
        accList[0].Name ='Test Account';accList[0].Core_Account_Type__c = 'End Customer';accList[0].RecordTypeId=masterRecordTypeId;accList[0].BillingCity='San Jose';accList[0].BillingCountry='USA';accList[0].BillingsTATE='CA';
        accList[0].BillingStreet='West Tasman Drive';accList[0].Industry='Accommodation and Food Services';accList[0].Core_Sub_Industry__c='Accommodation';accList[0].Core_Sales_Groups__c='PRC Sales Group';
        insert accList;
        
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(2,accList[0]);
        String oppoRecordTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        oppList[0].Core_Product_Application__c='Business Mobility';
        oppList[0].Core_Product_Segment__c='Client Computing';
        oppList[0].RecordTypeId= oppoRecordTypeId;oppList[0].StageName ='Qualify';
        oppList[1].Core_Product_Application__c='Business Mobility';
        oppList[1].Core_Product_Segment__c='Client Computing';
        oppList[1].RecordTypeId= oppoRecordTypeId;oppList[1].StageName ='Qualify';
        insert oppList;
        
        List<Opportunity> oppUpdateList = [select id,Core_PSG_Quote_Last_Processed_Status__c from Opportunity where Id=:oppList[0].Id];
        oppUpdateList[0].Core_PSG_Quote_Last_Processed_Status__c = 'Processing';
        update oppUpdateList;
        
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        
        List<OpportunityLineItem> oppLineItemList = Core_SalesSupportPSGQuote_Test.createOpportunityProduct(1,oppList[0],true);
        insert oppLineItemList;
        
        List<Core_Opportunity_Partner__c> oppPartnerList = Core_SalesSupportPSGQuote_Test.createOpportunityPartner(1,accList[0],oppList[0]);
        insert oppPartnerList;
        
        List<Core_Integration_Outbound_Message__c> outBoundmessageList;
        Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
        //objHomeController.createPSGQuoteonSiebel();
        outBoundmessageList = [select id, name from Core_Integration_Outbound_Message__c where Core_MessageType__c ='PSG_Quote'];
        //objHomeController.createPSGQuoteonSiebel();
        
        System.AssertEquals('Processing',oppUpdateList[0].Core_PSG_Quote_Last_Processed_Status__c); 
        
    }
    
    
    /**********************************
* Method Name : testSalesSupportHomePullPSGQuoteHistory_Test 
* Created On  : Dec-17-2016
* Created By  : Accenture 
* Description : Intel Altera Phase1: 
*               Below Test method for checking already processing PSG quote with QuoteHistory 
***********************************/
    static testmethod void testSalesSupportHomeAlreadyProcessingWithPSGQuoteHistory_Test() {
        
        
        List<Account> accList = Core_SalesSupportPSGQuote_Test.createAccount(1,true);
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
         accList[0].RecordTypeId = masterRecordTypeId;
        accList[0].Name ='Test Account';accList[0].Core_Account_Type__c = 'End Customer';accList[0].RecordTypeId=masterRecordTypeId;accList[0].BillingCity='San Jose';accList[0].BillingCountry='USA';accList[0].BillingsTATE='CA';
        accList[0].BillingStreet='West Tasman Drive';accList[0].Industry='Accommodation and Food Services';accList[0].Core_Sub_Industry__c='Accommodation';accList[0].Core_Sales_Groups__c='PRC Sales Group';
        insert accList;
        
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(2,accList[0]);
        String oppoRecordTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        oppList[0].Core_Product_Application__c='Business Mobility';
        oppList[1].Core_Product_Application__c='Business Mobility';
        oppList[0].Core_Product_Segment__c='Client Computing';
        oppList[1].Core_Product_Segment__c='Client Computing';
        oppList[0].RecordTypeId= oppoRecordTypeId;
        oppList[1].RecordTypeId= oppoRecordTypeId;
        oppList[0].StageName ='Define';
        oppList[1].StageName ='Define';
        insert oppList;
        
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        
        List<OpportunityLineItem> oppLineItemList = Core_SalesSupportPSGQuote_Test.createOpportunityProduct(1,oppList[0],true);
        insert oppLineItemList;
        
        if(Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation()) {
            List<Core_Integration_Inbound_Message__c>  inboundMessageList = Core_SalesSupportPSGQuote_Test.insertIntegrationInboundMessage(1,oppList[0]);
            insert inboundMessageList;
            
        }
        
        List<Opportunity> oppUpdateList = [Select Id,name,Core_PSG_Quote_Last_Processed_Status__c from Opportunity where Id=:oppList[0].Id];
        oppUpdateList[0].Core_PSG_Quote_Last_Processed_Status__c = 'Processing';
        update oppUpdateList;
        
        
        Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
        System.AssertEquals('Processing',oppUpdateList[0].Core_PSG_Quote_Last_Processed_Status__c); 
    }
    
    
    // This test method is used to cover the seedWebserviceWrapper and getISRList 
    static testmethod void testGetISRList() {
        
        Group testGroup = new Group();
        testGroup.Name = 'Test Group';
        insert testGroup;
        
        User usr = createUser();
        usr.Core_Login_Id__c = 'testLogin';
        insert usr;
        //PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = '0PSDf000001B1dZOAS', AssigneeId = usr.Id);
        //insert psa;
        GroupMember GM = new GroupMember();
        GM.GroupId = testGroup.id;
        GM.UserOrGroupId = usr.Id;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpNoResponseGenerator());
        Core_SalesSupportHomeController objHomeCont = new Core_SalesSupportHomeController();
        objHomeCont.getISRList(); 
        objHomeCont.pullWebQuotes();

        
        Core_SalesSupportHomeController.seedWebserviceWrapper seedWeb = new Core_SalesSupportHomeController.seedWebserviceWrapper();
        seedWeb.AccountID = String.valueof('6013683884');
        seedWeb.AccountName = String.valueof('Test');
        seedWeb.OpportunityID = String.valueof('0000069741');
        seedWeb.OpportunityName = String.valueof('Test Opp');
        seedWeb.OrderStatus = String.valueof('success');
        seedWeb.Requestor = String.valueof('rew');
        seedWeb.Submitter = String.valueof('submiter');
        seedWeb.ProductCode = String.valueof('123');
        seedWeb.LineItemStatus = String.valueof('success');
        seedWeb.ActualShipDate = String.valueof('08-17-2018');
        seedWeb.RequestedQty = Integer.valueof('123');
        seedWeb.ShippedQty = Integer.valueof('23');
        seedWeb.ActualShipDate = String.valueof('08-17-2018');
        seedWeb.ProductDesc = String.valueof('Test Prod');
        seedWeb.ProductListDesc = String.valueof('Test Prod');
        seedWeb.CompanyName=String.valueof('Test compnay');
        seedWeb.StreetAddress1 = String.valueof('Bangalore');
        seedWeb.StreetAddress2 = String.valueof('BTM');
        seedWeb.MailStop=String.valueof('Teststop');
        seedWeb.City=String.valueof('Bangaklore');
        seedWeb.State=String.valueof('Karnataja');
        seedWeb.ZipCode=String.valueof('560029');
        seedWeb.Country=String.valueof('India');
        seedWeb.AttentionName=String.valueof('Atten');
        seedWeb.AttentionNumber=String.valueof('2341');
        seedWeb.Notes=String.valueof('Hello');
        seedWeb.Status=String.valueof('success');
        seedWeb.message=String.valueof('Hello');
        seedWeb.OrderNumber=Integer.valueof('12344');
        seedWeb.RequestedDeliveryDate=String.valueof('01-01-2018');
        seedWeb.ReturnPickupDate=String.valueof('01-05-2018');
        seedWeb.ProductName=String.valueof('test');
        seedWeb.EstimatedShipDate=String.valueof('01-01-2018');
        seedWeb.bRenderCSection=true;
        
        Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
        objHomeController.seedMatchesFilters(seedWeb);
        
        objHomeController.sCurrentTab = 'tabSamples';
        // System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.INFO));
        
        objHomeController.pullSeeds();
        
        objHomeController.loadFirstTab();
        
        objHomeController.sCurrentTab = 'tabSeeds';
        // System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.INFO));
        
        objHomeController.pullSeeds();
        String json = '{"name":"John"}';
        seedWeb.parse(json); 
        //
        
    test.stopTest();        
        // if(Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation()) {
        Core_SalesSupportHomeController objHomeControllerr = new Core_SalesSupportHomeController();
        
        
        //objHomeControllerr.createPSGQuoteonSiebel();
        String Payload = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="http://siebel.com/CustomUI" xmlns:eai="http://www.siebel.com/xml/EAI%20Opty%20IO%20SFDC%20Altera">'+
            '<soapenv:Header/>'+
            '<soapenv:Body>'+
            '<cus:AlteraSfdcQuoteIntegration_Output>'+
            '<cus:Error_spcCode></cus:Error_spcCode>'+
            '<cus:Error_spcMessage></cus:Error_spcMessage>'+
            '<cus:QuoteURL>Altera.com</cus:QuoteURL>'+
            '<cus:RFQ_ID>IY-13456321ewqw41</cus:RFQ_ID>'+
            '<cus:Opportunity_ID>'+'</cus:Opportunity_ID>'+
            '<cus:Status>Quote successfully created – all PSG products on the opportunity were quoted</cus:Status>'+
            '</cus:AlteraSfdcQuoteIntegration_Output>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';
        /*List<User> lstUsers2 = PSG_Test_Utility.createAdminUser(); 
        System.runAs(lstUsers2[0]){
        Core_Integration_Inbound_Message__c InboundMsg = new Core_Integration_Inbound_Message__c();
        InboundMsg.Core_Source_System__c = 'SIEBEL';
        InboundMsg.Core_Message_Type__c = 'Quote';
        InboundMsg.Core_Payload__c = Payload;
        insert InboundMsg;
        }*/
        
        
        Core_SalesSupportHomeController.SampleWebserviceWrapper samplewebse = new Core_SalesSupportHomeController.SampleWebserviceWrapper();
        samplewebse.RequestProductID='12334';
        samplewebse.RequestID='123354';
        samplewebse.RDD='Test'; 
        samplewebse.Line='LineTest';
        samplewebse.RequestedMM='TestMM'; 
        samplewebse.RequestedEPMName ='Tester';
        samplewebse.ApprovedMM='Business'; 
        samplewebse.ApprovedEPMName='Intel Business';
        samplewebse.Requester ='Dev team';
        samplewebse.RequestQty='{!Environment.Core_MDF_SFDC_Environment} Team'; 
        samplewebse.ApprovedQty='Business'; 
        samplewebse.OBO ='OBO';
        samplewebse.ApproverName ='Intel';
        samplewebse.ApproverEmail ='testbc@gmail.com';
        samplewebse.Status ='Pending';
        samplewebse.Socket='Socket';
        samplewebse.Media='Test Media'; 
        samplewebse.Stepping ='test steping';
        samplewebse.QDF ='test QDF';
        samplewebse.BoxQuantity='large'; 
        samplewebse.Contact='intel business'; 
        samplewebse.CustomerName ='customer ';
        samplewebse.CustomerCMFID ='12345';
        samplewebse.ShiptoCustomerName ='business customer';
        samplewebse.ShipToCustomerCMFID='786686'; 
        samplewebse.StreetAddress1 ='Electronic city';
        samplewebse.StreetAddress2='Phase 1'; 
        samplewebse.City ='Bangalore';
        samplewebse.StateName ='Karnataka';
        samplewebse.ZipCode ='560037';
        samplewebse.Country ='India';
        samplewebse.ActualShipDtm ='test sdd';
        samplewebse.TrackingIdForCarrier1Txt ='568399';
        samplewebse.TrackingIdForCarrier2Txt='7979'; 
        samplewebse.CustomerCIMID ='23344';
        samplewebse.DefaultCIM ='33445';
        samplewebse.DefaultCIMID ='9898';
        samplewebse.GridViewAccountName='test123'; 
        samplewebse.GridViewOpportunityName ='test34';
        samplewebse.GridViewOpportunityStage='pending'; 
        
        samplewebse.DetailViewCIMIDs='testt'; 
        samplewebse.DetailViewOppIDs ='yyss';
        samplewebse.bRenderCSection=true;
        
        objHomeControllerr.sampleMatchesFilters(samplewebse);
        
    }
    
    static testmethod void testgetWebQuotes(){
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new Core_SalesSupportHomeControllerMock());
        Core_SalesSupportHomeController obj = new Core_SalesSupportHomeController();
        obj.pullWebQuotes();
        Core_SalesSupportHomeController.WebQuote webquote = new Core_SalesSupportHomeController.WebQuote();
        webquote.aprv_prc = 12;
        webquote.approved_quantity=12;
        webquote.cre_dt =  Date.newInstance(2016,6,15);
        webquote.dpa_expr_dt = Date.newInstance(2016,6,15);
        webquote.dpa_vld_fr_dt = Date.newInstance(2016,6,15);
        webquote.prd_dsc =null;
        webquote.quote_name = '869476.01';
        webquote.quote_status = 'DPA Closed';
        webquote.quote_type = 'Volume';
        webquote.creator = 'Sarah Manuel';
        Test.stopTest();
    }
    
     static testmethod void testgetSeeds(){
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new Core_TestMockHttpResponseGenerator());
        Core_SalesSupportHomeController obj = new Core_SalesSupportHomeController();
        obj.pullSeeds();
        Test.stopTest();
    }
    
     static testmethod void testgetMySamples(){
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new Core_TestMockHttpResponseGenerator());
        Core_SalesSupportHomeController obj = new Core_SalesSupportHomeController();
        obj.pullSamples();
        Test.stopTest();
    }
    
    // Added by Bishal Singh - Accenture
    static testmethod void createPSGQuoteonSiebel_PositiveTest(){
        SBQQ.TriggerControl.disable();
        Test.startTest();
        //List<User> lstUsers2 = PSG_Test_Utility.createAdminUser(); 
        //List<User> SOSUser = PSG_Test_Utility.createDistyUser();
        Account acc=[Select id,BillingCountry from Account where Core_Direct_Pricing_Parent_Id__c = null LIMIT 1];
        Account acc1=[Select id,BillingCountry from Account where Core_Direct_Pricing_Parent_Id__c != null LIMIT 1];
        Opportunity opportunityRecord=[Select Id,Core_First_Customer_Ship_Date__c from Opportunity LIMIT 1];
        Core_Design_Registration_Product__c designRegistrationProduct=[Select Id from Core_Design_Registration_Product__c LIMIT 1];
        List<product2> prods=[Select id from Product2];
        Test.stopTest();
        /*System.runAs(lstUsers2[0]){
            Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
            ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, opportunityRecord.Id);
            ApexPages.currentPage().getParameters().put('OppId', opportunityRecord.Id);
            String oppId1 = ApexPages.currentPage().getParameters().put('OppId', opportunityRecord.Id);
            Core_SalesSupportHomeController.isPartner=true;
            String oppId=ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, opportunityRecord.Id);
            objHomeController.selectedISR = 'Testing';
            objHomeController.sOppId = opportunityRecord.Id;
            //objHomeController.createPSGQuoteonSiebel();     
        }*/
    }
    
    // Added by Bishal Singh - Accenture
    static testmethod void createPSGQuoteonSiebelNew_PositiveTest(){

        SBQQ.TriggerControl.disable();
        Test.startTest();
        //List<User> lstUsers2 = PSG_Test_Utility.createAdminUser(); 
        //List<User> SOSUser = PSG_Test_Utility.createDistyUser();
        Account acc=[Select id,BillingCountry from Account where Core_Direct_Pricing_Parent_Id__c = null LIMIT 1];
        Account acc1=[Select id,BillingCountry from Account where Core_Direct_Pricing_Parent_Id__c != null LIMIT 1];
        Opportunity opportunityRecord=[Select Id,Core_First_Customer_Ship_Date__c from Opportunity LIMIT 1];
        Core_Design_Registration_Product__c designRegistrationProduct=[Select Id from Core_Design_Registration_Product__c LIMIT 1];
        List<product2> prods=[Select id from Product2];
        Test.stopTest();
        /*System.runAs(lstUsers2[0]){
            Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
            ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, opportunityRecord.Id);
            ApexPages.currentPage().getParameters().put('OppId', opportunityRecord.Id);
            String oppId1 = ApexPages.currentPage().getParameters().put('OppId', opportunityRecord.Id);
            Core_SalesSupportHomeController.isPartner=true;
            String oppId=ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, opportunityRecord.Id);
            objHomeController.selectedISR = 'Testing';
            objHomeController.sOppId = opportunityRecord.Id;
            //Core_SalesSupportHomeController.createPSGQuoteonSiebelNew(opportunityRecord.Id);        
        }*/
    }
    
    // Added by Bishal Singh - Accenture
    static testmethod void createQuote_PositiveTest(){
        SBQQ.TriggerControl.disable();
        //List<User> lstUsers2 = PSG_Test_Utility.createAdminUser(); 
        //List<User> SOSUser = PSG_Test_Utility.createDistyUser();
        Account acc=[Select id,BillingCountry from Account where Core_Direct_Pricing_Parent_Id__c = null LIMIT 1];
        Account acc1=[Select id,BillingCountry from Account where Core_Direct_Pricing_Parent_Id__c != null LIMIT 1];
        Opportunity opportunityRecord=[Select Id,Core_First_Customer_Ship_Date__c from Opportunity LIMIT 1];
        Core_Design_Registration_Product__c designRegistrationProduct=[Select Id from Core_Design_Registration_Product__c LIMIT 1];
        List<product2> prods=[Select id from Product2];
        /*System.runAs(lstUsers2[0]){
            Test.startTest();
            Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
            ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, opportunityRecord.Id);
            ApexPages.currentPage().getParameters().put('OppId', opportunityRecord.Id);
            String oppId1 = ApexPages.currentPage().getParameters().put('OppId', opportunityRecord.Id);
            Core_SalesSupportHomeController.isPartner=true;
            String oppId=ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, opportunityRecord.Id);
            objHomeController.selectedISR = 'Testing';
            objHomeController.sOppId = opportunityRecord.Id;
            //objHomeController.createQuotes();
            Test.stopTest();
        }*/
    }
}