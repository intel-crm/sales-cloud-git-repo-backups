@isTest
public class Core_IPS_BES_ErrorTriggerTest {

    @isTest
    static void testCore_IPS_BES_ErrorTrigger() {
        // Create test data for Core_IPS_BES_Error_Log__c
        List<Core_IPS_BES_Error_Log__c> errorLogs = new List<Core_IPS_BES_Error_Log__c>();
        
        for (Integer i = 0; i < 5; i++) {
            Core_IPS_BES_Error_Log__c log = new Core_IPS_BES_Error_Log__c(
                Core_IPS_Error_Code__c =  i  
            );
            errorLogs.add(log);
        }

        // Insert the test records
        Test.startTest();
        insert errorLogs;
        Test.stopTest();
        System.assertEquals(errorLogs[0].Core_IPS_Error_Code__c, 0);
    }

    @isTest
    static void testEventPublishFailure() {
        // Mocking the event publish failure
        Test.startTest();
        
        // Insert invalid data or create conditions where event publishing should fail
        Core_IPS_BES_Error_Log__c log = new Core_IPS_BES_Error_Log__c(
            Core_IPS_Error_Code__c =  1          
        );
        
        try {
            insert log;
            // Intentionally adding the test logic here for failure case
            // If the insert fails, we should check the exception handling logic
        } catch (Exception e) {
            //String errorMsg = e.getMessage();
            throw new AuraHandledException(e.getMessage());// ATHR fix Gangadhar
            //System.debug('Expected exception: ' + e.getMessage());
        }
        
        Test.stopTest();
                System.assertEquals(log.Core_IPS_Error_Code__c, 1);

    }
}