@isTest
        public class PCC_Rebate_Claim_BatchFlowSchedulerTest {
            @isTest
            public static void testReminder(){
                Test.startTest();
                List<PCC_Rebate_Claim__c> listBatchConfigItems = [SELECT Id FROM PCC_Rebate_Claim__c LIMIT 1];
                String flowApiName = 'PCC_Rebate_Analyst_Actions'; // Replace with your actual Flow API name
                PCC_Rebate_Claim_BatchFlowScheduler batchJob = new PCC_Rebate_Claim_BatchFlowScheduler();
                Database.executeBatch(batchJob); 
                batchJob.execute(null,listBatchConfigItems);
              
            Test.stopTest();

           
                
            }
        
        }