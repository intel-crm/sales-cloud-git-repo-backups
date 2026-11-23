@isTest
private class PMP_OfferingEmailAlertsControllerTest{
  
    @testSetup
    static void setupSeedData() {
      
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        
        PMP_TestDataUtility.createDocument();
    }
    
    static testMethod void emailContentTest() {
        
        Test.startTest();
        
        PMP_OfferingEmailAlertsController ctrl = new PMP_OfferingEmailAlertsController();
        
        ctrl.headerMessage = 'Offering Submitted Successfully';
        ctrl.getCommunityURL();
        
        ctrl.getCreateOfferingURL();
        
        ctrl.getHeaderURL();
                
        ctrl.getBodyURL();
        
        PMP_Partner_Offering__c  existingoffering = [Select Id from PMP_Partner_Offering__c ];
        ctrl.offeringId = existingoffering.Id; 
        PMP_Partner_Offering__c offering = ctrl.getOfferingData();
        System.AssertNotEquals(offering.Id,null);
        
        Test.StopTest();
    }
    
    static testMethod void testGetOfferingData(){
        
        PMP_OfferingEmailAlertsController obj = new PMP_OfferingEmailAlertsController();
        obj.getOfferingData();
    }   
    
}