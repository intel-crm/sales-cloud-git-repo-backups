@IsTest
public class UCD_ACM_AccountPlatformEvent_BatchTest {
    
    @TestSetup
	private static void setCommonData(){
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert parentAccount;
        
        ACM_Integration_Message_Queue__c integrationMessage = new ACM_Integration_Message_Queue__c();
        integrationMessage.Message_Status__c = 'New';
        integrationMessage.Content_Type__c = 'AccountId';
		integrationMessage.Content__c = parentAccount.Id;
        integrationMessage.Custom_Filter__c = parentAccount.Id;
        integrationMessage.Module_Name__c = 'ACM';
        integrationMessage.Queue_Type__c = 'Outbound';
        integrationMessage.Retry_Count__c = 0;
        integrationMessage.Source_System__c = 'Reltio';        
        insert integrationMessage;
        
       
    }
    
    @isTest
    private static void whenbatchClassRunning(){
            UCD_ACM_AccountPlatformEvent_Batch batchRec = new UCD_ACM_AccountPlatformEvent_Batch();
            DataBase.executeBatch(batchRec); 
        }

}