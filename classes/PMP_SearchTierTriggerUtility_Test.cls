@isTest
public class PMP_SearchTierTriggerUtility_Test {
	
    @isTest
    static void testRunOnce(){
        Test.startTest();
        system.assertEquals(true, PMP_SearchTierTriggerUtility.runOnce());	
        system.assertEquals(false, PMP_SearchTierTriggerUtility.runOnce());	
        Test.stopTest();
    }
    
	 @isTest
    static void testRunWorkCopyOnce(){
        Test.startTest();
        system.assertEquals(true, PMP_SearchTierTriggerUtility.runWorkCopyOnce());
        system.assertEquals(false, PMP_SearchTierTriggerUtility.runWorkCopyOnce());	
        Test.stopTest();
    }    
    
}