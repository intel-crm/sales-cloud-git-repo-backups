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
        
        Account_Create_Request__c req = new Account_Create_Request__c();
        req.Account_Name__c = 'Sample Account';
        req.Process_Type__c = 'Partner';
        req.Requestor_Name__c = UserInfo.getName();
        req.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        req.Status__c = 'Pending Approval';
        req.Core_Account_Reference_Source_Name__c = 'Partner'; 
        req.Address__City__s = 'Test';
        req.Address__CountryCode__s = 'IND';
        req.Address__Street__s = 'Test';
        insert req;
        
        ACM_Integration_Message_Queue__c im = new ACM_Integration_Message_Queue__c();
        im.Custom_Filter__c = String.valueOf(req.Id);
        im.Content__c = String.valueOf(req.Id);
        im.Content_Type__c = 'ARQId';
        im.Module_Name__c = 'SBR';
        im.Source_System__c = 'SBR';
        im.Queue_Type__c = 'Outbound';
        im.Retry_Count__c = 0;
        im.Message_Status__c = 'New';
        insert im;
    }
    
    @isTest
    private static void whenbatchClassRunning(){
        
            test.StartTest();
            UCD_ACM_AccountPlatformEvent_Batch batchRec = new UCD_ACM_AccountPlatformEvent_Batch();
            DataBase.executeBatch(batchRec);
            test.StopTest();
            
            ACM_Integration_Message_Queue__c integrationMessage = [SELECT Id,Content__c, Content_Type__c, Message_Status__c, Module_Name__c, Queue_Type__c, Source_System__c, Custom_Filter__c FROM ACM_Integration_Message_Queue__c WHERE Content_Type__c = 'ARQId' AND Module_Name__c = 'SBR' AND Queue_Type__c = 'Outbound' AND Source_System__c = 'SBR' LIMIT 1];
        	Assert.areEqual('Success',integrationMessage.Message_Status__c, 'Request process failed');
        }

}