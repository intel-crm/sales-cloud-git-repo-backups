//Test Class for Core_internalUserNotificationOnEV

@isTest
public class Core_internalUserNotificationOnEV_Test {
    
    @isTest static void testSendMail(){
        List<Id> cId = InternalUserNotificationOnEVTestData.createTestData();
        Test.startTest();
        Core_internalUserNotificationOnEV.sendEmailOnEvCompletion(cId);
        Test.stopTest();  
        system.assert(cId.size()>0);        
    }    
    
}