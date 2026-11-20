@isTest
private class SWS_SLAEmail_Trigger_FlowSchedular_Test {    
    @testSetup
    static void setupTestData() {
        Core_Opp_Bypass_Validation_Rule__c bypassSetting = new Core_Opp_Bypass_Validation_Rule__c(
            Name = 'Bypass',
            Bypass__c = TRUE
        );
        insert bypassSetting;        
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 10; i++) {
            leads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead' + i,
                Company = 'Test Company',
                Core_Lead_Status__c = 'New',
                Country = 'United States'
            ));
        }
        insert leads; 
    }    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        SWS_SLAEmail_Trigger_FlowSchedular batch = new SWS_SLAEmail_Trigger_FlowSchedular();
        Database.executeBatch(batch, 10); 
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status = 'Completed']);
    }
}