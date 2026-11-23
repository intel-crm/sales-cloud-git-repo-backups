@isTest
private class PCC_RebateStagingBatchTest {
    static testMethod void testBatchExecution() {
       // List<PCC_Rebate_Claim_Stage__c> rebateClaimStages = new List<PCC_Rebate_Claim_Stage__c>();-Unused Var
        PCC_Rebate_Claim_Stage__c testParentRecord = new PCC_Rebate_Claim_Stage__c(PCC_Status__c = 'Pending');
        insert testParentRecord;
        
            PCC_Rebate_Claim_Stage__c stageRec = new PCC_Rebate_Claim_Stage__c(
               // Name = 'Stage Record ' + i,
                PCC_Parent_Record__c = testParentRecord.Id,
                PCC_Invoice_Date__c = String.valueof(Date.today()),
                PCC_Quantity__c = 'Test',
                PCC_Status__c='Pending'
            );
           insert stageRec;
        
        
        List<Id> headerIds = new List<Id> {testParentRecord.Id};
         Assert.isNotNull(headerIds);
        PCC_RebateStagingProcessBatch batchInstance = new PCC_RebateStagingProcessBatch(headerIds);
        Test.startTest();
        Database.executeBatch(batchInstance);
        Test.stopTest();

                }


    
}