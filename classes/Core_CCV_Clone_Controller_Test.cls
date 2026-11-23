/****************************************************************************************************
Apex Class Name : Core_CCV_Clone_Controller_Test
Version         : 1.0 
Created Date    : 01/18/15
Function        : Test class for CCV cloning
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              01/18/2015             Original Version
*****************************************************************************************************/
@
isTest
private class Core_CCV_Clone_Controller_Test {

    static Account account;
    static ApexPages.StandardController accountController;
    static ApexPages.StandardController ccvStandardController;
    
    static Core_CCV__c ccvTest;
    static Core_CCV_Clone_Controller newController;

    static void setupTest()
    {
        List<Account> accountList = Core_Test_Utility.createAccount(1);
        account                   = accountList[0]; 
        insert account;
        
        ccvTest                   = new Core_CCV__c();
        ccvTest.Core_Account__c   = account.Id;
        
        ccvStandardController     = new ApexPages.StandardController(ccvTest);
        newController             = new Core_CCV_Clone_Controller(ccvStandardController); 
    }


    static testMethod void ccvCloneControllerTest() 
    {    
        setupTest();
        
        // Start testing the functionality
        Test.startTest();
        
        // Throw an exception
        newController.cloneWithItems(); 

        // Clone it.        
        insert ccvTest;
        
        Core_Value_Chain__c valueChain = new Core_Value_Chain__c();
        valueChain.Core_CCV__c         = ccvTest.Id;
        insert valueChain;        
                                
        Core_Capability_Matrix__c capabilityMatrix = new Core_Capability_Matrix__c();
        capabilityMatrix.Core_CCV__c               = ccvTest.Id;
        insert capabilityMatrix;        

        Core_Value_Map__c valueMap         = new Core_Value_Map__c();
        valueMap.Core_CCV__c               = ccvTest.Id;
        valueMap.Core_Customer_Value__c    = Label.Core_CCV_Customer_Value_High;
        insert valueMap;

        Core_Customer_Financials__c financials = new Core_Customer_Financials__c();
        financials.Core_CCV__c                 = ccvTest.Id;
        insert financials;

        Core_Intel_Business_Summary__c business = new Core_Intel_Business_Summary__c();
        business.Core_CCV__c                    = ccvTest.Id;
        insert business;

        newController.cloneWithItems(); 
                   
        
        Test.stopTest();
    }
}