/*********************************************
* Name : IPS_APIGEE_Case_Backend_System_Test 
* Author : Karthik Bandla
* Date Created : 25/06/2021
* Description : Test class for IPS_APIGEE_Case_Backend_System.
*   
************************************************/
@isTest
global class IPS_APIGEE_Case_Backend_System_Test {
    //create a test method and make a mock call out 
    @isTest
    public static void DePromoteTest() {
        Account caseContactAccount = TestUtilities.getAccountRecord();
        caseContactAccount.Name = 'Test Sony Products';
        insert caseContactAccount;
        
        Contact caseContact = new Contact();
        caseContact.FirstName = 'Test';
        caseContact.LastName = 'Contact1';
        caseContact.Email = 'testemail@email.com';
        caseContact.Core_Enterprise_Id__c = '88899';
        caseContact.AccountId = caseContactAccount.Id;
        caseContact.MailingCountry = 'USA';
        insert caseContact;
        
        
        //Product2 product = TestUtilities.getProduct();
        //insert product;
        Product2 prod = new Product2();
        prod.Name = 'Purley';
        prod.Core_Sales_Visible_Flag__c = false;
        prod.Core_IPS_Visible_Flag_External__c = true;
        prod.Core_IPS_Visible_Flag_Internal__c = 'Yes';
        prod.IsActive = true;
        prod.Core_Product_Org__c = 'IPS';//@@New Validation Rule!!!
        insert prod;
        Core_IPS_Backend_System__c backendSystem = new Core_IPS_Backend_System__c();
        backendSystem.Name = 'Test Backend System';
        backendSystem.Core_IPS_Backend_Connection_String__c = 'Test Backend Connection';
        backendSystem.Core_IPS_Cloud_Internal_URL__c ='Test.org.com';
        backendSystem.Core_IPS_Deactivated__c = false;
        insert backendSystem;
        
        Case caseRecord = new Case();
        caseRecord.Subject = 'Test Subject';
        caseRecord.ProductId = prod.Id;
        caseRecord.Status = 'Open';
        caseRecord.CreatedDate = DateTime.parse(System.Now().format());
        caseRecord.LastModifiedDate = DateTime.parse(System.Now().format());
        caseRecord.AccountId = caseContactAccount.Id;
        caseRecord.ContactId = caseContact.Id;
        caseRecord.Core_CaseType__c = 'Debug Request';
        caseRecord.Core_IPS_Customer_Visible__c = true;
        caseRecord.Core_IPS_Backend_ID__c = '-1';
        caseRecord.Core_IPS_Backend_System__c = backendSystem.Id;
        caseRecord.Core_IPS_Backend_Previous_Status__c='disassociate|220178896|a1ko0000002WR7uAAG';
        
        
        
        Core_IPS_APIGEE_Custom_Settings__c customSetting = new Core_IPS_APIGEE_Custom_Settings__c();
        customSetting.Name = 'Core_IPS_MyIntel_Integration';
        customSetting.MyIntel_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a822530833';
        customSetting.MyIntel_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        customSetting.MyIntel_Endpoint_URL__c = 'https://apis.intel.com/m2r/intel-customers/v1/profiles';
        customSetting.MyIntel_GrantType__c = 'client_credentials';
        customSetting.MyIntel_Integration_Class_Name__c = 'IPS_APIGEE_Case_Backend_System_Test';
        customSetting.MyIntel_Token_Endpoint_URL__c = 'https://apis-sandbox.intel.com/v1/auth/token';
        insert customSetting;
        
        Core_IPS_System_Credentails_Apigee__c label17 = new Core_IPS_System_Credentails_Apigee__c();
        label17.Name = 'Core_IPS_Case_Promote';
        label17.Core_IPS_EndPointURL__c = 'Test.org.com';
        insert label17;
        Core_IPS_System_Credentails_Apigee__c label18 = new Core_IPS_System_Credentails_Apigee__c();
        label18.Name = 'Core_IPS_Case_DePromote';
        label18.Core_IPS_EndPointURL__c = 'Test1.org.com';
        insert label18;
        Core_IPS_System_Credentails_Apigee__c label19 = new Core_IPS_System_Credentails_Apigee__c();
        label19.Name = 'Core_IPS_Case_FieldUpdate';
        label19.Core_IPS_EndPointURL__c = 'Test2.org.com';
        insert label19;
        
        Test.setMock(HttpCalloutMock.class, new IPS_APIGEE_BackendHttpCalloutMock());
        Test.startTest();
        insert caseRecord;
        Test.stopTest();
    }
    @isTest
    public static void PromoteTest() {
        Account caseContactAccount = TestUtilities.getAccountRecord();
        caseContactAccount.Name = 'Test Sony Products';
        insert caseContactAccount;
        
        Contact caseContact = new Contact();
        caseContact.FirstName = 'Test';
        caseContact.LastName = 'Contact1';
        caseContact.Email = 'testemail@email.com';
        caseContact.Core_Enterprise_Id__c = '88899';
        caseContact.AccountId = caseContactAccount.Id;
        caseContact.MailingCountry = 'USA';
        insert caseContact;
        
        
        //Product2 product = TestUtilities.getProduct();
        //insert product;
        Product2 prod = new Product2();
        prod.Name = 'Purley';
        prod.Core_Sales_Visible_Flag__c = false;
        prod.Core_IPS_Visible_Flag_External__c = true;
        prod.Core_IPS_Visible_Flag_Internal__c = 'Yes';
        prod.IsActive = true;
        prod.Core_Product_Org__c = 'IPS';//@@New Validation Rule!!!
        insert prod;
        Core_IPS_Backend_System__c backendSystem = new Core_IPS_Backend_System__c();
        backendSystem.Name = 'Test Backend System';
        backendSystem.Core_IPS_Backend_Connection_String__c = 'Test Backend Connection';
        backendSystem.Core_IPS_Cloud_Internal_URL__c ='Test.org.com';
        backendSystem.Core_IPS_Deactivated__c = false;
        insert backendSystem;
        
        Case caseRecord = new Case();
        caseRecord.Subject = 'Test Subject';
        caseRecord.ProductId = prod.Id;
        caseRecord.Status = 'Open';
        caseRecord.CreatedDate = DateTime.parse(System.Now().format());
        caseRecord.LastModifiedDate = DateTime.parse(System.Now().format());
        caseRecord.AccountId = caseContactAccount.Id;
        caseRecord.ContactId = caseContact.Id;
        caseRecord.Core_CaseType__c = 'Debug Request';
        caseRecord.Core_IPS_Customer_Visible__c = true;
        caseRecord.Core_IPS_Backend_ID__c =null;
        caseRecord.Core_IPS_Backend_System__c = backendSystem.Id;
        caseRecord.Core_Promote_Status__c='In Progress';
        caseRecord.Core_IPS_GEC_Status__c = null;
        caseRecord.Core_IPS_Backend_Previous_Status__c='disassociate|220178896|a1ko0000002WR7uAAG';
        
        
        
        Core_IPS_APIGEE_Custom_Settings__c customSetting = new Core_IPS_APIGEE_Custom_Settings__c();
        customSetting.Name = 'Core_IPS_MyIntel_Integration';
        customSetting.MyIntel_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a822530833';
        customSetting.MyIntel_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        customSetting.MyIntel_Endpoint_URL__c = 'https://apis.intel.com/m2r/intel-customers/v1/profiles';
        customSetting.MyIntel_GrantType__c = 'client_credentials';
        customSetting.MyIntel_Integration_Class_Name__c = 'IPS_APIGEE_Case_Backend_System_Test';
        customSetting.MyIntel_Token_Endpoint_URL__c = 'https://apis-sandbox.intel.com/v1/auth/token';
        insert customSetting;
        
        Core_IPS_System_Credentails_Apigee__c label17 = new Core_IPS_System_Credentails_Apigee__c();
        label17.Name = 'Core_IPS_Case_Promote';
        label17.Core_IPS_EndPointURL__c = 'Test.org.com';
        insert label17;
        Core_IPS_System_Credentails_Apigee__c label18 = new Core_IPS_System_Credentails_Apigee__c();
        label18.Name = 'Core_IPS_Case_DePromote';
        label18.Core_IPS_EndPointURL__c = 'Test1.org.com';
        insert label18;
        Core_IPS_System_Credentails_Apigee__c label19 = new Core_IPS_System_Credentails_Apigee__c();
        label19.Name = 'Core_IPS_Case_FieldUpdate';
        label19.Core_IPS_EndPointURL__c = 'Test2.org.com';
        insert label19;
        Test.setMock(HttpCalloutMock.class, new IPS_APIGEE_BackendHttpCalloutMock());
        Test.startTest();
        insert caseRecord;
        Test.stopTest();
    }
    @isTest
    public static void FieldUpdateTest() {
          Test.startTest();
        Account caseContactAccount = TestUtilities.getAccountRecord();
        caseContactAccount.Name = 'Test Sony Products';
        insert caseContactAccount;
        
        Contact caseContact = new Contact();
        caseContact.FirstName = 'Test';
        caseContact.LastName = 'Contact1';
        caseContact.Email = 'testemail@email.com';
        caseContact.Core_Enterprise_Id__c = '88899';
        caseContact.AccountId = caseContactAccount.Id;
        caseContact.MailingCountry = 'USA';
        insert caseContact;
        
        
        //Product2 product = TestUtilities.getProduct();
        //insert product;
        Product2 prod = new Product2();
        prod.Name = 'Purley';
        prod.Core_Sales_Visible_Flag__c = false;
        prod.Core_IPS_Visible_Flag_External__c = true;
        prod.Core_IPS_Visible_Flag_Internal__c = 'Yes';
        prod.IsActive = true;
        prod.Core_Product_Org__c = 'IPS';//@@New Validation Rule!!!
        insert prod;
        
        Core_IPS_Backend_System__c backendSystem = new Core_IPS_Backend_System__c();
        backendSystem.Name = 'Test Backend System';
        backendSystem.Core_IPS_Backend_Connection_String__c = 'Test Backend Connection';
        backendSystem.Core_IPS_Cloud_Internal_URL__c ='Test.org.com';
        backendSystem.Core_IPS_Deactivated__c = false;
        insert backendSystem;
        
        Case caseRecord = new Case();
        caseRecord.Subject = 'Test Subject';
        caseRecord.ProductId = prod.Id;
        caseRecord.Status = 'Open';
        caseRecord.CreatedDate = DateTime.parse(System.Now().format());
        caseRecord.LastModifiedDate = DateTime.parse(System.Now().format());
        caseRecord.AccountId = caseContactAccount.Id;
        caseRecord.ContactId = caseContact.Id;
        caseRecord.Core_CaseType__c = 'Debug Request';
        caseRecord.Core_IPS_Customer_Visible__c = true;
        caseRecord.Core_IPS_Backend_ID__c ='test';
        caseRecord.Core_IPS_Backend_System__c = backendSystem.id;
        caseRecord.Core_IPS_BK_Flds_UpdatedAt__c= DateTime.parse(System.Now().format());
        DateTime dt = DateTime.newInstance(2021, 09, 21, 10, 14, 00);
        caseRecord.Core_IPS_BK_Flds_UpdatedAt_PreVal__c=dt;
        caseRecord.Core_IPS_Backend_Previous_Status__c='test|220178896|a1ko0000002WR7uAAG';
        
        /* case cs = [select id,Core_IPS_BK_Flds_UpdatedAt_PreVal__c,Core_IPS_BK_Flds_UpdatedAt__c,Core_IPS_Backend_System__c,Core_IPS_Backend_ID__c,Core_IPS_Backend_System__r.Core_IPS_Deactivated__c,Core_IPS_Backend_System__r.Core_IPS_Backend_Connection_String__c from case];


if((cs.Core_IPS_Backend_System__c !=null && (cs.Core_IPS_BK_Flds_UpdatedAt__c != cs.Core_IPS_BK_Flds_UpdatedAt_PreVal__c) && cs.Core_IPS_Backend_ID__c != null && cs.Core_IPS_Backend_System__r.Core_IPS_Backend_Connection_String__c != null && !(cs.Core_IPS_Backend_System__r.Core_IPS_Deactivated__c))){
system.debug('test8');
}*/
        
        
        
        
        Core_IPS_System_Credentails_Apigee__c label17 = new Core_IPS_System_Credentails_Apigee__c();
        label17.Name = 'Core_IPS_Case_Promote';
        label17.Core_IPS_EndPointURL__c = 'Test.org.com';
        insert label17;
        Core_IPS_System_Credentails_Apigee__c label18 = new Core_IPS_System_Credentails_Apigee__c();
        label18.Name = 'Core_IPS_Case_DePromote';
        label18.Core_IPS_EndPointURL__c = 'Test1.org.com';
        insert label18;
       
        Core_IPS_System_Credentails_Apigee__c label19 = new Core_IPS_System_Credentails_Apigee__c();
        label19.Name = 'Core_IPS_Case_FieldUpdate';
        label19.Core_IPS_EndPointURL__c = 'Test2.org.com';
        insert label19;
       
        Core_Trigger_Executions__c label20 =new Core_Trigger_Executions__c();
        label20.Name='myIntelIntegration';
        label20.Core_Active__c=true;
        label20.Core_Class_Name__c='Core_IPS_CaseTriggerHandler';
        label20.Core_Object__c='Case';
        label20.Core_Description__c='MyIntel 3.0';
        label20.Core_Trigger_Events__c='before update, after create';
        //insert label20;
        Test.setMock(HttpCalloutMock.class, new IPS_APIGEE_BackendHttpCalloutMock());
        
        
        insert caseRecord;
        case caseRecord1=[select id,Subject from case];
        caseRecord1.Subject='test purpose';
        update caseRecord1;
        Test.stopTest();
    }
    
}