@IsTest
public class MessageQueueServiceTest {
	private static UCD_ACM_ServiceContracts.IMessageQueueService messageQueueServiceInstance = MessageQueueService.getInstance();
    @TestSetup
    private static void setCommonData(){
        insert new MessageQueueClasses__c(Class_Name__c='InterfaceTestCls',Implementation_Type__c='AfterInsert');
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert acc;
        
        ACM_Integration_Message_Queue__c integrationMessage = UCD_ACM_Cntrlr_TestDataInitialization.createIntegrationMessageQueue(acc.Id);
        insert integrationMessage;
    }
    
    @isTest
    private static void whenMapIntegrationMessageQueueResponse(){
        
    }
    
}