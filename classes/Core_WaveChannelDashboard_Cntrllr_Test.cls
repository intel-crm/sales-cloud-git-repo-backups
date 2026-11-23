@isTest
public class Core_WaveChannelDashboard_Cntrllr_Test {
    
    private static final String ACCOUNT_NAME = 'Test Account 1';
    
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name=ACCOUNT_NAME, BillingStreet='123 Fake St', BillingCity='Portland',
                                          BillingState='OR', BillingCountry='USA', Core_CIM_ID__c='8675309');
        insert testAccount;
    }

    static testMethod void testDashboard() {
        
        // Get our test records
        Account acct = [select Id, Core_CIM_ID__c from Account where Name = :ACCOUNT_NAME limit 1];
        
        // Set the current page with CIM ID parameter, and instantiate our controller
        PageReference dashboardPage = Page.Core_WaveChannelSingleAccount;
        Test.setCurrentPage(dashboardPage);
        ApexPages.currentPage().getParameters().put('cim_id', acct.Core_CIM_ID__c);
        Core_WaveChannelDashboard_Controller dashboardController =
            new Core_WaveChannelDashboard_Controller(new ApexPages.StandardController(acct));
        dashboardController.init();
        
        // Set the current page with an Id parameter, and instantiate our controller
        //Test.setCurrentPage(dashboardPage);
        ApexPages.currentPage().getParameters().put('id', acct.Id);
        dashboardController = new Core_WaveChannelDashboard_Controller(new ApexPages.StandardController(acct));
        dashboardController.init();
    }
}