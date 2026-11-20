@isTest
public class PMP_OfferingSearchControllerTest {
    static testMethod void retrieveListViewDataTest(){
        Test.startTest();
        String keyword = 'Test';
        String objectName = 'PMP_Company__c';
        List<SObject> results1 = PMP_OfferingSearchController.retrieveListViewData(keyword, objectName);
        List<SObject> results2 =PMP_OfferingSearchController.retrieveListViewData(keyword, 'PMP_Company__c');
        //List<SObject> results3 =PMP_OfferingSearchController.retrieveListViewData(keyword, 'partner-solution-list');
        Test.stopTest();
        
        
        // Add assertions to verify the expected outcomes
        System.assertNotEquals(null, results1, 'Expected results for PMP_Partner_Offering__c should not be null');
        System.assertNotEquals(null, results2, 'Expected results for PMP_Company__c should not be null');
        //System.assertNotEquals(null, results3, 'Expected results for partner-solution-list should not be null');//IPA2.0: US-TWC729-7976
       
    }
}