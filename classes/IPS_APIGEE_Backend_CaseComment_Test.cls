/*********************************************
* Name : IPS_APIGEE_Backend_CaseComment_Test 
* Author : Karthik Bandla
* Date Created : 25/06/2021
* Description : Test class for IPS_APIGEE_Backend_CaseComments.
*   
************************************************/
@isTest
global class IPS_APIGEE_Backend_CaseComment_Test {
    
    @testSetup
    static void setup(){
        
        Account caseContactAccount = TestUtilities.getAccountRecord();
        caseContactAccount.Name = 'Test Sony Products';
        insert caseContactAccount;
		System.assert(caseContactAccount.Id != null, 'Record not created');
        
        Contact caseContact = new Contact();
        caseContact.FirstName = 'Test';
        caseContact.LastName = 'Contact1';
        caseContact.Email = 'testemail@email.com';
        caseContact.Core_Enterprise_Id__c = '88899';
        caseContact.AccountId = caseContactAccount.Id;
        caseContact.MailingCountry = 'USA';
        insert caseContact;
        System.assert(caseContact.Id != null, 'Record not created');

        
        // Product2 product = TestUtilities.getProduct();
        // insert product;
        Product2 prod = new Product2();
        prod.Name = 'Purley';
        prod.Core_Sales_Visible_Flag__c = false;
        prod.Core_IPS_Visible_Flag_External__c = true;
        prod.Core_IPS_Visible_Flag_Internal__c = 'Yes';
        prod.IsActive = true;
        prod.Core_Product_Org__c = 'IPS';//@@New Validation Rule!!!
        insert prod;
        System.assert(prod.Id != null, 'Record not created');
        
        Core_IPS_Backend_System__c backendSystem = new Core_IPS_Backend_System__c();
        backendSystem.Name = 'Test Backend System';
        backendSystem.Core_IPS_Backend_Connection_String__c = 'Test Backend Connection';
        backendSystem.Core_IPS_Cloud_Internal_URL__c ='Test.org.com';
        backendSystem.Core_IPS_Deactivated__c = false;
        insert backendSystem;
        System.assert(backendSystem.Id != null, 'Record not created');
        
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
        System.assert(caseRecord.Id != null, 'Record not created');
        
        Core_IPS_APIGEE_Custom_Settings__c customSetting = new Core_IPS_APIGEE_Custom_Settings__c();
        customSetting.Name = 'Core_IPS_MyIntel_Integration';
        customSetting.MyIntel_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a822530833';
        customSetting.MyIntel_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        customSetting.MyIntel_Endpoint_URL__c = 'https://apis.intel.com/m2r/intel-customers/v1/profiles';
        customSetting.MyIntel_GrantType__c = 'client_credentials';
        customSetting.MyIntel_Integration_Class_Name__c = 'IPS_APIGEE_Backend_CaseComment_Test';
        customSetting.MyIntel_Token_Endpoint_URL__c = 'https://apis-sandbox.intel.com/v1/auth/token';
        insert customSetting;
        System.assert(customSetting.Id != null, 'Record not created');
        List<Core_IPS_Labels__c> IPSLabelList = new List<Core_IPS_Labels__c>();
        
        Core_IPS_Labels__c label0 = new Core_IPS_Labels__c ();
        label0.name= 'PUBLIC_TO_CUSTOMERS';
        label0.value__c='Public to Customers';
        IPSLabelList.add(label0);
        
        Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
        label1.name= 'PRIVATE_TO_AGENTS';
        label1.value__c= 'Private to Agents';
        IPSLabelList.add(label1);
        
        Core_IPS_Labels__c Label2 = new Core_IPS_Labels__c ();
        Label2.name= 'PRIVATE_TO_INTEL';
        label2.value__c= 'Private to Intel';
        IPSLabelList.add(label2);
        
        Core_IPS_Labels__c label3= new Core_IPS_Labels__c();
        label3.name='Customer';
        label3.value__c='Customer';
        IPSLabelList.add(label3);
        
        Core_IPS_Labels__c label4 = new Core_IPS_Labels__c ();
        label4.name='FAE';
        label4.value__c='FAE';
        IPSLabelList.add(label4);
        
        
        Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
        label5.name='Agent';
        label5.value__c='Agent';
        IPSLabelList.add(label5);
        
        Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
        label6.name='Backend Integration';
        label6.value__c='Backend Integration';
        IPSLabelList.add(label6);
        
        Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
        label7.name='Data Migration';
        label7.value__c='Data Migration';
        IPSLabelList.add(label7);
        
        Core_IPS_Labels__c label8 = new Core_IPS_Labels__c();
        label8.name='Partner';
        label8.value__c='Partner';
        IPSLabelList.add(label8);
        
        Core_IPS_Labels__c Label9 = new Core_IPS_Labels__c ();
        Label9.name= 'PRIVATE_TO_PARTNERS';
        label9.value__c= 'Private to Partner';
        IPSLabelList.add(label9);
        
        Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
        label10.name='Partner - DFAE';
        label10.value__c='Partner - DFAE';
        IPSLabelList.add(label10);
        
        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.name='Partner - Agent';
        label11.value__c='Partner - Agent';
        IPSLabelList.add(label11);
        
        Core_IPS_Labels__c label12= new Core_IPS_Labels__c();
        label12.name='Comment Source - Customer';
        label12.value__c='Customer Portal';
        IPSLabelList.add(label12);
        
        Core_IPS_Labels__c label13= new Core_IPS_Labels__c();
        label13.name='Comment Source - Internal';
        label13.value__c='Internal Portal';
        IPSLabelList.add(label13);
        
        Core_IPS_Labels__c label14= new Core_IPS_Labels__c();
        label14.name='Comment Source - Email';
        label14.value__c='Email';
        IPSLabelList.add(label14);
        
        Core_IPS_Labels__c label15= new Core_IPS_Labels__c();
        label15.name='Comment Source - N/A';
        label15.value__c='N/A';
        IPSLabelList.add(label15);
        
        Core_IPS_Labels__c label16= new Core_IPS_Labels__c();
        label16.name='Comment Source - Data Migration';
        label16.value__c='Data Migration';
        IPSLabelList.add(label16);
        
        insert IPSLabelList;
        System.assert(IPSLabelList[0].Id != null, 'Record not created');
        
        Core_IPS_System_Credentails_Apigee__c label17 = new Core_IPS_System_Credentails_Apigee__c();
        label17.Name = 'Core_IPS_CaseComment_Update';
        label17.Core_IPS_EndPointURL__c = 'Test.org.com';
        insert label17;
        
                           
    }
    //create a test method and make a mock call out
    @isTest
    public static void test1() {
        Case core_IPS_Case = [SELECT Id FROM CASE LIMIT 1];
        Core_IPS_Case_Comments__c casecomment = new Core_IPS_Case_Comments__c();
        casecomment.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;
        casecomment.Core_IPS_Case__c = core_IPS_Case.Id;
        casecomment.Core_IPS_Comment__c = 'TestString';
        Test.setMock(HttpCalloutMock.class, new IPS_APIGEE_BackendHttpCalloutMock());
        Test.startTest();
        insert casecomment;
        Test.stopTest();
    }
}