@isTest
private class PMP_GlobalFooterController_Test {

    @testSetup
    static void setupSeedData() {
      
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        //IPA2.0:US-4497-1631_OfferingEOL
        //PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        
        PMP_TestDataUtility.createDocument();
    }
    
    static testMethod void emailContentTest() {
        
        Test.startTest();
        
        PMP_GlobalFooterController ctrl = new PMP_GlobalFooterController();      
       string test1 =  ctrl.getCommunityHelpURL();
        // system.debug('test1'+test1);
        Test.stopTest();
        system.assertEquals('https://www.intel.com/content/www/us/en/partner-alliance/help/marketplace/overview.html', test1);
    }
}