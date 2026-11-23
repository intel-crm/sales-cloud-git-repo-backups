@isTest
private class PMP_GlobalFooterController_Test {

    @testSetup
    static void setupSeedData() {
      
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        
        PMP_TestDataUtility.createDocument();
    }
    
    static testMethod void emailContentTest() {
        
        Test.startTest();
        
        PMP_GlobalFooterController ctrl = new PMP_GlobalFooterController();      
        ctrl.getCommunityHelpURL();
        
        Test.StopTest();
    }
}