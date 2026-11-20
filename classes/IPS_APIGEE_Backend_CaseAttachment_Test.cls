/*********************************************
* Name : IPS_APIGEE_Backend_CaseAttachment_Test 
* Author : Karthik Bandla
* Date Created : 25/06/2021
* Description : Test class for IPS_APIGEE_Backend_System_CaseAttachment.
*   
************************************************/
@isTest
global class IPS_APIGEE_Backend_CaseAttachment_Test {
    @testSetup
    static void setup(){
        
        Account caseContactAccount = TestUtilities.getAccountRecord();
        caseContactAccount.Name = 'Test Sony Products';
        insert caseContactAccount;
        
        Contact caseContact = new Contact();
        caseContact.FirstName = 'Test';
        caseContact.LastName = 'Contact1';
        caseContact.Email = 'testemail@email.com';
        caseContact.Core_Enterprise_Id__c = '88899';
        caseContact.AccountId = caseContactAccount.Id;
        caseContact.MailingCountry='India';
        insert caseContact;
        
        
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
        insert caseRecord; 
        
        Core_IPS_APIGEE_Custom_Settings__c customSetting = new Core_IPS_APIGEE_Custom_Settings__c();
        customSetting.Name = 'Core_IPS_MyIntel_Integration';
        customSetting.MyIntel_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a822530833';
        customSetting.MyIntel_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        customSetting.MyIntel_Endpoint_URL__c = 'https://apis.intel.com/m2r/intel-customers/v1/profiles';
        customSetting.MyIntel_GrantType__c = 'client_credentials';
        customSetting.MyIntel_Integration_Class_Name__c = 'IPS_APIGEE_Backend_System_CaseAttachment';
        customSetting.MyIntel_Token_Endpoint_URL__c = 'https://apis-sandbox.intel.com/v1/auth/token';
        insert customSetting;
        
        Core_Trigger_Executions__c label1= new Core_Trigger_Executions__c();
        label1.name= 'InsertCaseCommentForAttach';
        label1.Core_Active__c= true;
        label1.Core_Class_Name__c = 'Core_IPS_CasePromotion_Handler';
        label1.Core_Description__c = 'InsertCaseCommentForAttachements';
        label1.Core_Object__c = 'Case Comment';
        label1.Core_Trigger_Events__c = 'After Insert, After update';
        insert label1;
        
        Core_Trigger_Executions__c label0 = new Core_Trigger_Executions__c();
        label0.name= 'UpdateCaseComntDscptnForAttach';
        label0.Core_Active__c= true;
        label0.Core_Class_Name__c = 'Core_IPS_CasePromotion_Handler';
        label0.Core_Description__c = 'InsertCaseCommentForAttachements';
        label0.Core_Object__c = 'Case Comment';
        label0.Core_Trigger_Events__c = 'After Insert, After update';
        insert label0;
        
        Core_Trigger_Executions__c label10 = new Core_Trigger_Executions__c();
        label10.name= 'IsDMUser_En_forCommTrigExec';
        label10.Core_Active__c= true;
        label10.Core_Class_Name__c = 'Core_IPS_CasePromotion_Handler';
        label10.Core_Description__c = 'InsertCaseCommentForAttachements';
        label10.Core_Object__c = 'Case Comment';
        label10.Core_Trigger_Events__c = 'After Insert, After update';
        insert label10;
         // Avoid Hardcoding Id Fix  - Shipra
        Profile dataMigPrf = [select id, name from Profile where name = 'CCP - Core Access' Limit 1];
        Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
        labels2.name= 'Data Migration Profile Id';
        labels2.value__c=dataMigPrf.Id;
      //   labels2.value__c='00eo0000000f7Gd';
        insert labels2; 
        
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
        labels.name= 'COMPLETE';
        labels.value__c='COMPLETE';
        insert labels;
        
        Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c ();
        labels1.name= 'PUBLIC_TO_CUSTOMERS';
        labels1.value__c='Public to Customers';
        insert labels1;
        
        Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c ();
        labels3.name= 'PRIVATE_TO_INTEL';
        labels3.value__c='Private to Intel';
        insert labels3;
        
        Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c ();
        labels4.name= 'PRIVATE_TO_AGENTS';
        labels4.value__c='Private to Agents';
        insert labels4;
        
        Core_IPS_Labels__c labels5 = new Core_IPS_Labels__c ();
        labels5.name= 'FAE';
        labels5.value__c='FAE';
        insert labels5;
        
        Core_IPS_Labels__c labels6 = new Core_IPS_Labels__c ();
        labels6.name= 'Agent';
        labels6.value__c='Agent';
        insert labels6;
        
        Core_IPS_Labels__c labels7 = new Core_IPS_Labels__c ();
        labels7.name= 'Customer';
        labels7.value__c='Customer';
        insert labels7;
        
        Core_IPS_Labels__c labels8 = new Core_IPS_Labels__c ();
        labels8.name= 'Backend Integration';
        labels8.value__c='Backend Integration';
        insert labels8;
        
        Core_IPS_Labels__c labels9 = new Core_IPS_Labels__c ();
        labels9.name= 'Data Migration';
        labels9.value__c='Data Migration';
        insert labels9;
        
        Core_IPS_Labels__c Label101 = new Core_IPS_Labels__c ();
        Label101.name= 'PRIVATE_TO_PARTNERS';
        label101.value__c= 'Private to Partner';
        insert label101;
        
        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.name='Partner - DFAE';
        label11.value__c='Partner - DFAE';
        insert label11;
        
        Core_IPS_Labels__c label12 = new Core_IPS_Labels__c();
        label12.name='Partner - Agent';
        label12.value__c='Partner - Agent';
        insert label12; 
        
        Core_IPS_Labels__c label13 = new Core_IPS_Labels__c();
        label13.name='Partner';
        label13.value__c='Partner';
        insert label13; 
        
        Core_IPS_Labels__c label14 = new Core_IPS_Labels__c();
        label14.name='Comment Source - Customer';
        label14.value__c='Customer Portal';
        insert label14;
        
        Core_IPS_System_Credentails_Apigee__c label17 = new Core_IPS_System_Credentails_Apigee__c();
        label17.Name = 'Core_IPS_CaseComment_Update';
        label17.Core_IPS_EndPointURL__c = 'Test.org.com';
        insert label17;
        
        
        
        
    }
    @isTest 
    static void test1() {
        //create a test method and make a mock call out 
        Case core_IPS_Case = [SELECT Id FROM CASE LIMIT 1];
        Core_IPS_Case_Attachments__c attachments = new Core_IPS_Case_Attachments__c();
        attachments.Core_Case__c = core_IPS_Case.id;
        attachments.Core_File_Description__c='Test-Description';
        attachments.Core_File_Name__c='Test-File';
        attachments.Core_IPS_Attachment_Visibility__c= Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
        attachments.Core_Is_Migrated__c = false;
        attachments.Core_Promote_Status__c = '';
        attachments.Core_File_URL__c='www.test.com';
        attachments.Core_FileSizeInBytes__c='2KB';
        attachments.Core_Upload_Status__c=Core_IPS_Labels__c.getValues('COMPLETE').value__c;
        attachments.Core_FileUploadedBy__c= Userinfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new IPS_APIGEE_BackendHttpCalloutMock());
        Test.startTest();
        insert attachments;
        Test.stopTest();
    }
    
}