@isTest
public class UCD_ACM_AccountReqQueueHandlerTest {
    
        @TestSetup
    private static void setCommonData(){
        // Create a reltio user
        User us = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration'].Id,
            FirstName = 'Reltio',
            LastName = 'SFDC Connector',
            Email = 'Test@example.com',
            Username = 'ucd_reltio_connector_user@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'Test Title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert us;
        
        // Create Requested Account
        Account reuestedAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccount1','Requested Account','UNFD_GLBL_CUST');
        insert reuestedAccount;
    }
    
    @isTest
    private static void publishAccountRequestPlatformEventTest(){
        
        Account account = [Select Id,Name,ParentId,RecordtypeId,LastModifiedById from Account Where Name = 'TestChildAccount1' LIMIT 1];

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
        
        User userRec = [Select Id FROM User Where Username Like '%ucd_reltio_connector_user@test.com%' LIMIT 1];
        
        test.startTest();
        	System.runAs(userRec) {
                Account_Create_Request__c req1 = [Select Id, Status__c, Requested_Account__c FROM Account_Create_Request__c LIMIT 1];
                	req1.Status__c = 'Approved';
                	req1.Requested_Account__c = account.Id;
                update req1;
                UCD_ACM_AccountPlatformEvent_Batch batchJob = new UCD_ACM_AccountPlatformEvent_Batch();
                Id batchJobId = Database.executeBatch(batchJob, 200);
            }
        test.stopTest();
        
        ACM_Integration_Message_Queue__c integrationMessage = [SELECT Id,Content__c, Content_Type__c, Message_Status__c, Module_Name__c, Queue_Type__c, Source_System__c, Custom_Filter__c FROM ACM_Integration_Message_Queue__c WHERE Content_Type__c = 'ARQId' AND Module_Name__c = 'SBR' AND Queue_Type__c = 'Outbound' AND Source_System__c = 'SBR' LIMIT 1];
        Assert.isTrue(integrationMessage.Message_Status__c == 'Success', 'Request process failed');
    }
    
    @isTest
    private static void publishAccountRequestPlatformEventExistingTest(){
        
        Account account = [Select Id,Name,ParentId,RecordtypeId,LastModifiedById from Account Where Name = 'TestChildAccount1' LIMIT 1];

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
        im.Message_Status__c = 'Success';
        insert im;
            
        User userRec = [Select Id FROM User Where Username Like '%ucd_reltio_connector_user@test.com%' LIMIT 1];
        
        test.startTest();
        	System.runAs(userRec) {
                Account_Create_Request__c req1 = [Select Id, Status__c, Requested_Account__c FROM Account_Create_Request__c LIMIT 1];
                	req1.Status__c = 'Approved';
                	req1.Requested_Account__c = account.Id;
                update req1;
            }
        test.stopTest();
        
        ACM_Integration_Message_Queue__c integrationMessage = [SELECT Id,Content__c, Content_Type__c, Message_Status__c, Module_Name__c, Queue_Type__c, Source_System__c, Custom_Filter__c FROM ACM_Integration_Message_Queue__c WHERE Content_Type__c = 'ARQId' AND Module_Name__c = 'SBR' AND Queue_Type__c = 'Outbound' AND Source_System__c = 'SBR' LIMIT 1];
        Assert.areEqual('New',integrationMessage.Message_Status__c, 'Request process failed');
    }
}