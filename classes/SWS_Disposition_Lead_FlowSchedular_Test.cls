/****************************************************************************************************
Class Name      : SWS_Disposition_Lead_FlowSchedularTest
Version         : 1.0 
Created Date    : 2025-02-18
Function        : To make the code coverage of the class more than 80%
Created By      : Pankaj Deshmukh
User Story      : TWC5945-1770.TWC5945-1691
*****************************************************************************************************/
@isTest
private class SWS_Disposition_Lead_FlowSchedular_Test {    
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
        SWS_Disposition_Lead_FlowSchedular batch = new SWS_Disposition_Lead_FlowSchedular();
        Database.executeBatch(batch, 10); 
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status = 'Completed']);
    }
}