@IsTest
public class UCD_ACM_AccountMutationSelectorTest {
    private static UCD_ACM_SelectorContracts.IAccountMutationSelector accountMutantSelectorInstance = UCD_ACM_AccountMutationSelector.getInstance();

    @TestSetup
    private static void setCommonData(){
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        
        insert parentAccount;

        // Create End Customer Deal Account Intermediate1 child
        Account intChildAcc1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntChildAccount1','End Customer Deal Account','UNFD_INTRMD_CUST');
        intChildAcc1.parentId = parentAccount.Id;
        insert intChildAcc1;

        Account intChildAcc2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntChildAccount2','End Customer Deal Account','UNFD_INTRMD_CUST');
        intChildAcc2.parentId = intChildAcc1.Id;
        insert intChildAcc2;

        // Create ACM_Integration_Message_Queue__c
        List<ACM_Integration_Message_Queue__c> integrationMsgToInsert = new List<ACM_Integration_Message_Queue__c>();
        ACM_Integration_Message_Queue__c integrationMessageNewStatus = UCD_ACM_Cntrlr_TestDataInitialization.createIntegrationMessageQueue(intChildAcc1.Id);
        integrationMessageNewStatus.Message_Status__c='Success';
        //ACM_Integration_Message_Queue__c integrationMessageErrorStatus = UCD_ACM_Cntrlr_TestDataInitialization.createIntegrationMessageQueue(intChildAcc2.Id);
        integrationMsgToInsert.add(integrationMessageNewStatus);
        //integrationMsgToInsert.add(integrationMessageErrorStatus);
        insert integrationMsgToInsert;

        //Account_Create_Request__c accountCreateRequest = UCD_ACM_Cntrlr_TestDataInitialization.createApproveAccountRequest('TestcreateReq1','India');
        //insert accountCreateRequest;

        //Account_Create_Request__c accountCreateRequest1 = UCD_ACM_Cntrlr_TestDataInitialization.createRejectAccountRequest('TestRejectAccReq','India');
        //insert accountCreateRequest1;

        Business_Types__c businessType=UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT');
        insert businessType;

    }
	@isTest
    private static void whenCreateAccount(){
        List<UCD_ACM_Models.AccountModel> accountRequest = new List<UCD_ACM_Models.AccountModel>();
        UCD_ACM_Models.AccountModel modelData = UCD_ACM_AccountTestData.getAccountModel('TestAccount1','UNFD_CTRY_CUST','DIR_PRC_EXCPT','Test','Test@test.com','India','IN');
        modelData.AccountRequestReferences = UCD_ACM_AccountTestData.getAccountRequestReference('MyDeals','Test2');
        accountRequest.add(modelData);
        test.startTest();
        Map<Id,Account> accountById = accountMutantSelectorInstance.createAccount(accountRequest);
        test.stopTest();
    }

    @isTest
    private static void whenSetIntegrationMessage(){
        List<Account> accounts = Database.query('Select Id,Name from account where name like \'%TestIntChildAccount%\'');
        Set<Id> accountIds = (new Map<Id,Account>(accounts)).keySet();
        test.startTest();
        accountMutantSelectorInstance.setIntegrationMessage(accountIds);
        test.stopTest();

    }

    @isTest
    private static void whenUpdateIntegrationMsgQueueStatusError(){
        List<Account> accounts = Database.query('Select Id,Name from account where name like \'%TestIntChildAccount%\'');
        Set<Id> accountIds = (new Map<Id,Account>(accounts)).keySet();
        test.startTest();
        accountMutantSelectorInstance.updateIntegrationMsgQueueStatus(accountIds,'Error');
        test.stopTest();

    }

    /**@isTest
    private static void whenApproveAccountRequest(){
        List<Account_Create_Request__c> accountCreateRequest=Database.query('Select Id, Account_Name__c, City__c, Country__c, Customer_Process_Engagement__c, Street__c, State__c From Account_Create_Request__c Where Name=\'TestcreateReq1\'');
        test.startTest();
        accountMutantSelectorInstance.approveAccountRequest(accountCreateRequest);
        test.stopTest();
    }
    @isTest
    private static void whenRejectAccountRequest(){
        List<Account_Create_Request__c> accountCreateRequest=Database.query('Select Id, Account_Name__c, City__c, Country__c, Customer_Process_Engagement__c, Street__c, State__c From Account_Create_Request__c Where Name=\'TestRejectAccReq\'');
        test.startTest();
        accountMutantSelectorInstance.rejectAccountRequest(accountCreateRequest);
        test.stopTest();
    }*/

}