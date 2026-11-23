/***************************************************************************************************
* Purpose: This Class is test class for the IPS_MyIntel_3_0_delete_Outbound_Batch
* @Name IPS_MyIntel_3_0_dlt_Outbound_Batch_Test.
* @Author Karthik Bandla
* @version 1.0
* @Created Date 23/06/2021
* @Last Modfied Date 10/09/2017
***************************************************************************************************/
@isTest
global class IPS_MyIntel_3_0_dlt_Outbound_Batch_Test {
    @testSetup
    static void setup(){
        
        
        Account caseAccount = TestUtilities.getAccountRecord();
        caseAccount.Name = 'Test Case Account';
        insert caseAccount;
		System.assert(caseAccount.Id != null, 'Record not created');
        
        Contact caseContact = new Contact();
        caseContact.FirstName = 'Test';
        caseContact.LastName = 'Contact1';
        caseContact.Email = 'testemail@email.com';
        caseContact.Core_Enterprise_Id__c = '88899';
        caseContact.AccountId = caseAccount.Id;
        caseContact.MailingCountry = 'India';
        insert caseContact;
        System.assert(caseContact.Id != null, 'Record not created');

        Product2 product = TestUtilities.getProduct();
        insert product;
        System.assert(product.Id != null, 'Record not created');
        Case caseRecord = new Case();
        caseRecord.Subject = 'Test Subject';
        caseRecord.ProductId = product.Id;
        caseRecord.Status = 'Open';
        caseRecord.CreatedDate = DateTime.parse(System.Now().format());
        caseRecord.LastModifiedDate = DateTime.parse(System.Now().format());
        caseRecord.AccountId = caseAccount.Id;
        caseRecord.ContactId = caseContact.Id;
        caseRecord.Core_CaseType__c = 'Debug Request';
        caseRecord.Core_IPS_Customer_Visible__c = true;
        insert caseRecord;
        System.assert(caseRecord.Id != null, 'Record not created');
    }
    public class TestData
    {
        public List<Account>testAccountData;
        public List<Contact>testContactData;
        public List<Case>testCaseData;
        
        public TestData()
        {
            testAccountData = [Select Id,Name FROM account where Name ='Test Case Account'];
            
            testContactData = [Select Id,AccountId FROM Contact where AccountId =: testAccountData[0].Id];
            
            testCaseData =  [Select Id,AccountId FROM Case where AccountId =: testAccountData[0].Id];  
            
        }
    }
    @isTest 
    private static void IPS_Delete_Outbound_Batchtest(){
        TestData testContext = new TestData();
         
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@example.com';
        
        User u = new User(Alias = 'standt', Email='standarduser@example.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName); 
        Insert u;
        System.assert(u.Id != null, 'Record not created');
        
        system.runAs(u)
        {
        list<Case> lstcase = new list<Case>();
        for(Case cs:testContext.testCaseData)
        {
            cs.Subject ='Test Subject Change';   
            lstcase.add(cs);
        }       
        Update lstcase;
        
        //Outbound message record 
        list<Core_IPS_MyIntel_Outbound_Message__c>lstOutbound = new list<Core_IPS_MyIntel_Outbound_Message__c>();
        Core_IPS_MyIntel_Outbound_Message__c outbound = new Core_IPS_MyIntel_Outbound_Message__c();
        outbound.Core_IPS_Case_ID__c = lstcase[0].id;
        outbound.Core_IPS_Operation_Type__c = 'Update';
        outbound.Core_IPS_Status__c = 'Failed';
        outbound.OwnerId = UserInfo.getUserId();
        lstOutbound.add(outbound);
        Insert lstOutbound;
        System.assert(lstOutbound[0].Id != null, 'Record not created');
        // Log entry record
        list<Core_Log_Entry__c>lstLog = new list<Core_Log_Entry__c>();
        Core_Log_Entry__c log = new Core_Log_Entry__c();
        log.Core_Message__c='Error in Test Class';
        log.Core_sObjectType__c = 'Core_IPS_MyIntel_Outbound_Message__c';
        log.Core_Severity__c = 'Error';
        log.Core_sObjectId__c = 'Case';
        log.Core_Origin__c = 'IPS_MyIntel_3_0_dlt_Outbound_Batch_Test';
        log.Core_Project__c = 'IPS';
        log.Core_Scope__c = 'MyIntel';
        log.Core_When__c = System.Now();
        lstLog.add(log);
        Insert lstLog;
        System.assert(lstLog[0].Id != null, 'Record not created');
        Datetime logEntryDate = Datetime.now().addDays(-90);
        Test.setCreatedDate(lstLog[0].Id, logEntryDate);
        
        Test.startTest();            
        IPS_MyIntel_3_0_delete_Outbound_Batch batch = new IPS_MyIntel_3_0_delete_Outbound_Batch();
        Database.QueryLocator ql = batch.start(null);
        batch.execute(null,lstOutbound);
        batch.Finish(null);         
        Test.stopTest();
        }
    }
    
    @isTest
    public static void testschedule()
    {
          // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@example.com';
        
        User u = new User(Alias = 'standt', Email='standarduser@example.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName); 
        Insert u;
        System.assert(u.Id != null, 'Record not created');
        system.runAs(u){
        Test.startTest();
        IPS_MyIntel_3_0_delete_Schedule_Batch schedulableBatch = new IPS_MyIntel_3_0_delete_Schedule_Batch();
        string cronExp ='0 0 0 ? * * *';   
        system.schedule('Test Outbound Delete Check', cronExp, schedulableBatch);
        Test.stopTest();
        }
    }
    
   
}