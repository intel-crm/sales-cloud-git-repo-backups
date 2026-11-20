/**************************************************************************************
Apex Class Name:  Core_WebServiceUtility_Test
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : test class for the Core_WebServiceUtility
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kunal Mehta           10/03/2014              Original Version
*************************************************************************************/
@isTest(seeAllData=true)
private class Core_WebServiceUtility_Test
{
     /*
    * Method name  : testWebserviceUtility
    * Description  : Method to setup test data ( WebServiceUtility)
    * Return Type  : None
    * Parameter    : None
    */
    public Static testmethod void testWebserviceUtility()
    {
        
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
        
        lstAssertSeedWebserviceWrapper.add(seedWeb);
        
        Core_DealSupportHomeController.seedWebserviceWrapper seedWeb1 = new Core_DealSupportHomeController.seedWebserviceWrapper();
        seedWeb1.AccountID = String.valueof('6013683886');
        seedWeb1.OpportunityID = String.valueof('0000069747');       
        
        lstAssertSeedWebserviceWrapper.add(seedWeb1);
         
        System.assertNotEquals(lstSeedWebserviceWrapper, lstAssertSeedWebserviceWrapper);
        
    }
}