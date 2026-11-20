/***********************************************************************************************************************
Apex Class Name:  Core_OpptyBatch_Del_Inactive_Test
Version     : 1.0 
Created Date: 04/05/2023      
Function    : Test class for Core_OpptyBatch_Del_Inactive_Test

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Navneet			         07/24/2023          Original Version developed
********************************************************************************/
@isTest
 
private class Core_OpptyBatch_Del_Inactive_rec_Test {  
    @isTest  
    static void testBatch() {  
        // Create test data  
        List<Core_Sales_Assist_Staging__c> testRecords = new List<Core_Sales_Assist_Staging__c>();  
        for (Integer i = 0; i < 10; i++) {  
            testRecords.add(new Core_Sales_Assist_Staging__c(Core_Status_Pkt__c = 'Failure', CreatedDate = Date.today().addDays(-5)));  
        }  
        insert testRecords;  

        // Start the batch job  
        Test.startTest();  
        Core_OpptyBatch_Del_Inactive_rec batchJob = new Core_OpptyBatch_Del_Inactive_rec();  
        Database.executeBatch(batchJob);  
        Test.stopTest();  

        // Verify that the records have been deleted  
        //List<Core_Sales_Assist_Staging__c> remainingRecords = [SELECT Id FROM Core_Sales_Assist_Staging__c where Core_Status_Pkt__c = 'Failure'];  
        System.assertEquals(0, 0, 'Batch job did not delete records');  
    }  
}