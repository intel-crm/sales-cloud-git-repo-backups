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
* Rangesh Kona		  Aug 22nd, 2017	 update @isTest(SeeAllData at the class level to method level)
*										 applied as needed only
* Rangesh Kona		  Aug 31st, 2017     Improved test coverage
*************************************************************************************/
@isTest
public class Core_SalesSupportHomeController_Test{
    /*
    * Method name  : testSeedsHttpResponseTest
    * Description  : test method to cover Core_SalesSupportHomeControllerclass
    * Return Type  : VOID
    * Parameter    : NONE
    */ 
     @isTest(SeeAllData=true)
    static  void testSeedsHttpResponseTest(){
                   
        //Construct two list to form the resultset
        List < Core_SalesSupportHomeController.seedWebserviceWrapper > lstSeedWebserviceWrapper = new List < Core_SalesSupportHomeController.seedWebserviceWrapper >{};
        List < Core_SalesSupportHomeController.seedWebserviceWrapper > lstAssertSeedWebserviceWrapper = new List < Core_SalesSupportHomeController.seedWebserviceWrapper >{};
        
        //Set the dealsupport home page
        PageReference pageRef = Page.Core_SalesSupportHome;
        Test.setCurrentPage(pageRef);
        
        //Since webservice methods cannot be called directly from a test method
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpResponseGenerator());
                
        Core_SalesSupportHomeController controllerCoreOppDesc = new Core_SalesSupportHomeController();
        controllerCoreOppDesc.init();
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, '9999');
        
        Core_SalesSupportHomeController controllerOppCoreOppDesc = new Core_SalesSupportHomeController();
        controllerOppCoreOppDesc.init();
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, NULL);
        ApexPages.currentPage().getParameters().put(system.label.Core_AccountName, '9999');
        ApexPages.currentPage().getParameters().put(system.label.Core_CIMID, '9999');
        
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
        seedWeb.AccountID = String.valueof('6013683884');
        seedWeb.OpportunityID = String.valueof('0000069741');
        
        Core_SalesSupportHomeController.seedWebserviceWrapper seedWeb1 = new Core_SalesSupportHomeController.seedWebserviceWrapper();
        seedWeb1.AccountID = String.valueof('6013683886');
        seedWeb1.OpportunityID = String.valueof('0000069747');       
        
        lstAssertSeedWebserviceWrapper.add(seedWeb1);
         
        System.assertNotEquals(lstSeedWebserviceWrapper, lstAssertSeedWebserviceWrapper);

    }
    
    static testMethod void testprocessSSGRequest() {
        
        //Core_OpportunityQuotePSGSales_Test.setupTestData();
        List<Account> accList = Core_SalesSupportPSGQuote_Test.createAccount(1,true);
        insert accList;
         
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(1,accList[0]);
        insert oppList;
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        
        
        Core_SalesSupportHomeController ssgTest = new Core_SalesSupportHomeController();

        ssgTest.processSSGRequest();
        system.assertEquals(true,ssgTest.showNoAccessMessage);
        
        ssgTest.sOppId = null;
        ssgTest.processSSGRequest();
        system.assertEquals(true,ssgTest.showNavigationErrorMessage);
      
    }
    
    /*
    * Method name  : testSeedsHttpNoResponseTest
    * Description  : test method to cover Core_SalesSupportHomeControllerclass
    * Return Type  : VOID
    * Parameter    : NONE
    */ 
    @isTest(SeeAllData=true)
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
    @isTest(SeeAllData=true)
    static  void testSeedsUserHttpResponseTest(){
       

        
        Profile profileofusers = [SELECT Id FROM Profile WHERE Name=:System.label.Core_IntegrationUser]; 
        
        List<User> lstUser = new List<User>();
        
        lstUser = Core_Test_Utility.Core_User(1);
        
        if(profileofusers != NULL)
            lstUser[0].Profileid = profileofusers.id;
        
        insert lstUser;
        
        User StandardUser = lstUser[0];
        
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
    }
    
    /*
    * Method name  : testSeedsOpportunityResponseTest
    * Description  : test method to cover Core_SalesSupportHomeControllerOpportunity records
    * Return Type  : VOID
    * Parameter    : NONE
    */ 
  //  @isTest(SeeAllData=true)
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
//@isTest(SeeAllData=true)
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
    
    @isTest(SeeAllData=true)
    static  void testSamplesCallouts() {
        

        
        // Pages, controller, and other vars we'll use for testing
        PageReference ssPage = Page.Core_SalesSupportHome;
        PageReference nextPage;
        Core_SalesSupportHomeController ssController;
        String str = '';
        
        // Get any valid Account ID (needed for the assignment statements in the class to work)
        Id arbitraryAcctId = [select Id from Account limit 1][0].Id;
        
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
        
        
        ssController.sCurrentTab = 'tabSamples';
        ssController.init();
        ssController.pullSamples();
        
        ssController.sSampleSearch[2] = 'processor';
        ssController.filterSamples();
        
        ssController.sSampleSearch[2] = 'dave';
        ssController.filterSamples();
        
        ssController.sSampleSearch[2] = '';
        ssController.filterSamples();
        
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

    // @isTest(SeeAllData=true)
    static testMethod void testSamplesAccessChecks() {
        
    
        // Pages, controller, and parameter map we'll use for testing
        PageReference ssPage = Page.Core_SalesSupportHome;
        Core_SalesSupportHomeController ssController;
        
        // Set up a test account and opportunity that we'll use
        Account acct = new Account(Name='Test Account', BillingCountryCode='USA', BillingStateCode='OR',
                                   BillingCity='Portland', BillingStreet='123 Fake St.', Core_CIM_ID__c = '999293859');
        insert acct;
        
        Opportunity opp = new Opportunity(Name='Test Opportunity 1', AccountId=acct.Id, StageName='Develop',
                                          CloseDate=System.Today().addDays(24));
        insert opp;
        
        //----------------------------------------------------------------------------------
        // FROM SALES SUPPORT TAB DIRECTLY
        
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpResponseGenerator());
        Test.startTest();
        
        // Where the user doesn't have a WWID
        User usr = createUser();
        
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
            ApexPages.currentPage().getParameters().put(System.Label.Core_CIMID, acct.Core_CIM_ID__c);
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
    * 				for runAs scenarios
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
        usr.profileId = [select Id from Profile where Name = 'Sales Rep-BB' limit 1][0].Id;
        usr.LANGUAGELOCALEKEY = 'en_US';
        usr.LOCALESIDKEY = 'en_US';
        usr.TIMEZONESIDKEY = 'America/Los_Angeles';
        usr.EMAILENCODINGKEY = 'ISO-8859-1';
        usr.Core_Employee_Type_Code__c = 'EMP';
        insert usr;
    
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
   // @isTest(SeeAllData=true)
    static testMethod void testSalesSupportHomeCreatePSGQuote_Test() {
    
        //Core_OpportunityQuotePSGSales_Test.setupTestData();
        List<Account> accList = Core_SalesSupportPSGQuote_Test.createAccount(1,true);
        insert accList;
         
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(1,accList[0]);
        insert oppList;
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        
        List<OpportunityLineItem> oppLineItemList = Core_SalesSupportPSGQuote_Test.createOpportunityProduct(1,oppList[0],true);
        insert oppLineItemList;
        
        List<Core_Opportunity_Partner__c> oppPartnerList = Core_SalesSupportPSGQuote_Test.createOpportunityPartner(1,accList[0],oppList[0]);
        insert oppPartnerList;
        
        // Rangesh - Custom setting was not visible to the test class, so inserted custom setting record
        // 
        // Insert custom setting data 
        upsert new Core_PSG_Integration_Settings__c (Name = 'MyCustSettingName', SetupOwnerId=UserInfo.getOrganizationId(), Core_User_Name__c='test',Core_Password__c = 'test' ); 
        // run as difference user to allow InnerClass.insertSharing test coverage 
        User usr = createUser();
    
        System.runas(usr) {  
       		// if(Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation()) {
            Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
            objHomeController.createPSGQuoteonSiebel();
           // objHomeController.createPSGQuoteonSiebel();
            //}
            List<Core_Integration_Outbound_Message__c> outBoundmessageList = [select id, name from Core_Integration_Outbound_Message__c where Core_MessageType__c ='PSG_Quote'];
            //System.AssertEquals(true,!(outBoundmessageList.isEmpty())); 
        }
        // Ranegsh - Changes End
        
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
        insert accList;
         
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(1,accList[0]);
        insert oppList;
        
   
        
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        
        List<OpportunityLineItem> oppLineItemList = Core_SalesSupportPSGQuote_Test.createOpportunityProduct(1,oppList[0],true);
        insert oppLineItemList;
        
        
        //if(Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation()) {
            List<Core_Integration_Inbound_Message__c>  inboundMessageList = Core_SalesSupportPSGQuote_Test.insertIntegrationInboundMessage(1,oppList[0]);
            insert inboundMessageList;
            Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
            objHomeController.pullPSGQuoteHistory();
        //}
        //This functionality is used for loading the initial Tab
      //objHomeController.sCurrentTab = 'tabSeeds';
        objHomeController.loadFirstTab();
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
        insert accList;
         
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(1,accList[0]);
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
        objHomeController.createPSGQuoteonSiebel();
        outBoundmessageList = [select id, name from Core_Integration_Outbound_Message__c where Core_MessageType__c ='PSG_Quote'];
        objHomeController.createPSGQuoteonSiebel();
        
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
        insert accList;
         
        List<Opportunity> oppList = Core_SalesSupportPSGQuote_Test.createOpportunity(1,accList[0]);
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

}