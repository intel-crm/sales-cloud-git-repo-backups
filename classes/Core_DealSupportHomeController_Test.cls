/**************************************************************************************
Apex Class Name:  Core_DealSupportHomeController_Test
Version     : 1.0 
Created Date: 24 OCT 2014
Function    : Test Class for the Core_DealSupportHomeController
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/24/2014              Original Version
* Srikant Joshi             18/02/2014              Modified the code to fetch only 1 user - Line 122
*************************************************************************************/
@isTest(SeeAllData=true)
public class Core_DealSupportHomeController_Test{
    
    /*
    * Method name  : DealSupportHttpResponseTest
    * Description  : test method to cover Core_DealSupportHomeControllerclass
    * Return Type  : VOID
    * Parameter    : NONE
    */ 
    static testMethod void DealSupportHttpResponseTest(){
                
        //Construct two list to form the resultset
        List < Core_DealSupportHomeController.seedWebserviceWrapper > lstSeedWebserviceWrapper = new List < Core_DealSupportHomeController.seedWebserviceWrapper >{};
        List < Core_DealSupportHomeController.seedWebserviceWrapper > lstAssertSeedWebserviceWrapper = new List < Core_DealSupportHomeController.seedWebserviceWrapper >{};
        
        //Set the dealsupport home page
        PageReference pageRef = Page.Core_DealSupportHome;
        Test.setCurrentPage(pageRef);
        
        //Since webservice methods cannot be called directly from a test method
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpResponseGenerator());
                
        Core_DealSupportHomeController controllerCoreOppDesc = new Core_DealSupportHomeController();
        controllerCoreOppDesc.init();
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, '9999');
        
        Core_DealSupportHomeController controllerOppCoreOppDesc = new Core_DealSupportHomeController();
        controllerOppCoreOppDesc.init();
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, NULL);
        ApexPages.currentPage().getParameters().put(system.label.Core_AccountName, '9999');
        ApexPages.currentPage().getParameters().put(system.label.Core_CIMID, '9999');
        
        Core_DealSupportHomeController controllerAccntCoreOppDesc = new Core_DealSupportHomeController();
        lstSeedWebserviceWrapper  = controllerAccntCoreOppDesc.coreGetSeeds();
        
        // set up the list to be matched with the resultset
        Core_DealSupportHomeController.seedWebserviceWrapper seedWeb = new Core_DealSupportHomeController.seedWebserviceWrapper();
        seedWeb.AccountID = String.valueof('6013683884');
        seedWeb.OpportunityID = String.valueof('0000069741');
        
        Core_DealSupportHomeController.seedWebserviceWrapper seedWeb1 = new Core_DealSupportHomeController.seedWebserviceWrapper();
        seedWeb1.AccountID = String.valueof('6013683886');
        seedWeb1.OpportunityID = String.valueof('0000069747');       
        
        lstAssertSeedWebserviceWrapper.add(seedWeb1);
         
        System.assertNotEquals(lstSeedWebserviceWrapper, lstAssertSeedWebserviceWrapper);
        
        controllerAccntCoreOppDesc.searchSeed();
    }
    
    /*
    * Method name  : DealSupportHttpNoResponseTest
    * Description  : test method to cover Core_DealSupportHomeControllerclass
    * Return Type  : VOID
    * Parameter    : NONE
    */ 
    static testMethod void DealSupportHttpNoResponseTest(){

        //Since webservice methods cannot be called directly from a test method
        List < Core_DealSupportHomeController.seedWebserviceWrapper > lstSeedWebserviceWrapper = new List < Core_DealSupportHomeController.seedWebserviceWrapper >{};
        List < Core_DealSupportHomeController.seedWebserviceWrapper > lstAssertSeedWebserviceWrapper = new List < Core_DealSupportHomeController.seedWebserviceWrapper >{};
        
        //Since webservice methods cannot be called directly from a test method        
        PageReference pageRef = Page.Core_DealSupportHome;
        Test.setCurrentPage(pageRef);
        
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpNoResponseGenerator());
                
        Core_DealSupportHomeController controllerCoreOppDesc = new Core_DealSupportHomeController();
        controllerCoreOppDesc.searchSeed();
        controllerCoreOppDesc.init();
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, '9999');
        
        Core_DealSupportHomeController controllerOppCoreOppDesc = new Core_DealSupportHomeController();
        controllerOppCoreOppDesc.searchSeed();
        controllerOppCoreOppDesc.init();
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, NULL);
        ApexPages.currentPage().getParameters().put(system.label.Core_AccountName, '9999');
        ApexPages.currentPage().getParameters().put(system.label.Core_CIMID, '9999');
        
        Core_DealSupportHomeController controllerAccntCoreOppDesc = new Core_DealSupportHomeController();
        lstSeedWebserviceWrapper  = controllerAccntCoreOppDesc.coreGetSeeds();
         
        System.assertEquals(lstSeedWebserviceWrapper, lstAssertSeedWebserviceWrapper);
        
        controllerAccntCoreOppDesc.searchSeed();        
    }
   
    
    /*
    * Method name  : DealSupportUserHttpResponseTest
    * Description  : test method to cover Core_DealSupportHomeController class
    * Return Type  : VOID
    * Parameter    : NONE
    */ 
    static testMethod void DealSupportUserHttpResponseTest(){
       
        Profile profileofusers = [SELECT Id FROM Profile WHERE Name=:System.label.Core_IntegrationUser]; 
        
        List<User> lstUser = new List<User>();
        
        lstUser = Core_Test_Utility.Core_User(1);
        
        if(profileofusers != NULL)
            lstUser[0].Profileid = profileofusers.id;
        
        insert lstUser;
        
        User StandardUser = lstUser[0];
        
        System.runAs(StandardUser){ 
            
            PageReference pageRef = Page.Core_DealSupportHome;
            Test.setCurrentPage(pageRef);
            
            //Since webservice methods cannot be called directly from a test method
            Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpNoResponseGenerator());
                    
            Core_DealSupportHomeController controllerCoreOppDesc = new Core_DealSupportHomeController();
            controllerCoreOppDesc.searchSeed();
            controllerCoreOppDesc.init();
            
            //Add parameters to page URL
            ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, '9999');
            
            Core_DealSupportHomeController controllerOppCoreOppDesc = new Core_DealSupportHomeController();
            controllerOppCoreOppDesc.searchSeed();
            controllerOppCoreOppDesc.init();
            
            //Add parameters to page URL
            ApexPages.currentPage().getParameters().put(system.label.Core_OpportunityID, NULL);
            ApexPages.currentPage().getParameters().put(system.label.Core_AccountName, '9999');
            ApexPages.currentPage().getParameters().put(system.label.Core_CIMID, '9999');
            
            Core_DealSupportHomeController controllerAccntCoreOppDesc = new Core_DealSupportHomeController();
            controllerAccntCoreOppDesc.coreGetSeeds();
            controllerAccntCoreOppDesc.searchSeed();
        }    
    }
    
    /*
    * Method name  : DealSupportOpportunityResponseTest
    * Description  : test method to cover Core_DealSupportHomeControllerOpportunity records
    * Return Type  : VOID
    * Parameter    : NONE
    */ 
    static testMethod void DealSupportOpportunityResponseTest(){
        
        PageReference pageRef = Page.Core_DealSupportHome;
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
        
        Core_DealSupportHomeController controllerOppCoreOppDesc = new Core_DealSupportHomeController();
        controllerOppCoreOppDesc.searchSeed();
        controllerOppCoreOppDesc.init();
        
    }
    
    /*
    * Method name  : DealSupportOpportunityNULLResponseTest
    * Description  : test method to cover Core_DealSupportHomeController Opportunity records
    * Return Type  : VOID
    * Parameter    : NONE
    */ 
    static testMethod void DealSupportOpportunityNULLResponseTest(){
        
        PageReference pageRef = Page.Core_DealSupportHome;
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
        
        Core_DealSupportHomeController controllerOppCoreOppDesc = new Core_DealSupportHomeController();
        controllerOppCoreOppDesc.searchSeed();
        controllerOppCoreOppDesc.init();        
        
    }
}