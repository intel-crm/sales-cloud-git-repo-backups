@isTest
private class PMP_OfferingEmailAlertsControllerTest{
  
    // @testSetup
    // static void setupSeedData() {
      
    //     Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
    //     PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
    //     PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
    //     PMP_Partner_Offering_Message__c offMessage = new PMP_Partner_Offering_Message__c();
    //     offMessage.PMP_Partner_Offering_Id__c=offering1.Id;
    //     offMessage.PMP_Message_Txt__c='Test';    
    //     insert offMessage;
        
    //     PMP_TestDataUtility.createDocument();
    // }
    
    // static testMethod void emailContentTest() {
    //     Test.startTest();
        
    //     PMP_OfferingEmailAlertsController ctrl = new PMP_OfferingEmailAlertsController();
        
    //     ctrl.headerMessage = 'Offering Submitted Successfully';
    //     ctrl.getCommunityURL();
        
    //     ctrl.getCreateOfferingURL();
        
    //     ctrl.getHeaderURL();
                
    //     ctrl.getBodyURL();
        
    //     ctrl.getManageOfferingsURL();
        
    //     PMP_Partner_Offering__c  existingoffering = [Select Id from PMP_Partner_Offering__c LIMIT 10];
    //     ctrl.offeringId = existingoffering.Id; 
    //     PMP_Partner_Offering__c offering = ctrl.getOfferingData();
    //     //System.AssertNotEquals(offering.Id,null);
    //     Test.StopTest();
    // }
    
    // static testMethod void testGetOfferingData(){
    //     test.startTest();
        
    //     PMP_OfferingEmailAlertsController obj = new PMP_OfferingEmailAlertsController();
    //     PMP_Partner_Offering__c response = obj.getOfferingData();
        
    //     system.assertNotEquals(response,Null);
    //     test.stopTest();
    // }   
    
    // static testMethod void getretiredOfferingURLTest() {
	// 	PMP_OfferingEmailAlertsController obj = new PMP_OfferingEmailAlertsController();
	// 	obj.getretiredOfferingURL();
    // }
    
}