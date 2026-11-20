@isTest
public class SWS_TestUtilty {
    public static PermissionSet permissionRec;
    
    static{
        permissionRec = [SELECT Id 
                         FROM PermissionSet 
                         WHERE Name = 'SWS_IDC_Business_Ops' LIMIT 1];
    }
    
    public static Account createAccount(){
        Account acc = new Account();
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        acc.Name = 'Test Account'+ math.random();
        acc.Core_Account_Type__c = 'Distributor;End Customer';//added
        acc.Industry = 'Banking';
        acc.BillingCity = 'Texas';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'G-2101';
        acc.Core_Sales_Groups__c = 'Americas US Sales Group';
        acc.Core_Geo__c = 'APJ';
        acc.Core_Sub_Geo__c = 'IJKK';
        acc.Core_PSG_Account__c = true;
        acc.Core_Account_Tier__c ='PSG-Tier 4';
        acc.Core_Partner_Alliance_Program__c ='PSG Demand Creation - PSG';
        acc.Core_Account_BU_Focus__c='PSG-CM;PSG-DISTI';
        
        insert acc;
        system.assert(acc.Id!=null,'New Account created sucessfully');
        return acc;   
    }
    
    public static Contact createContact(Id accId){
        Contact con = new Contact();
        Account acc = new Account();
        acc.Id = accId;
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
        con.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId();
        con.FirstName = 'FirstName'+System.now();
        con.LastName = 'LastName';
        con.Email = 'FirstName@intel.com';
        con.AccountId = acc.Id;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry='USA';
        insert con;
        System.assert(con.Id!=null,'New Contact created sucessfully');
        return con;
    }
    
    public static User createUser(){
        Id profileId = [SELECT Id FROM Profile WHERE Name='System Administrator']?.Id; 
        User u = new User(Alias = 'standt', Email='requestoremail@example.com', 
                         EmailEncodingKey='UTF-8', LastName='requestorUser', LanguageLocaleKey='en_US', 
                         LocaleSidKey='en_US', ProfileId = profileId, 
                         TimeZoneSidKey='America/Los_Angeles', UserName='requestoremail@testorg.com');
        insert u;
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionRec.Id);
        System.assert(u.Id!=null,'New User created sucessfully');
        return u;
    }
    
    public static SWS_Core_CRM_Labels__c createLabel(String labelName,String value){
        SWS_Core_CRM_Labels__c label = new SWS_Core_CRM_Labels__c( 
            Name = labelName,
            SWS_Value__c = value
        );        
        insert label;
        System.assert(label.Id!=null,'New Label created sucessfully');
        return label;
    }
    
    public static SWS_Cloud_Credit_Request__c createSingleRequest(Boolean onlyRequiredField){
        Id recordTypeId = Schema.SObjectType.SWS_Cloud_Credit_Request__c.getRecordTypeInfosByDeveloperName().get('SWS_Cloud_Credit_Request').getRecordTypeId();
        SWS_Cloud_Credit_Request__c request = new SWS_Cloud_Credit_Request__c();
	request.RecordTypeId = recordTypeId;
        request.SWS_Submitter_Name__c = 'Test User';
        request.SWS_Submitter_Email__c='test@email.com';
        request.SWS_Request_Type__c = 'Intel_Internal_Use';
        request.SWS_Submitter_Requster_Email__c = False;
        request.SWS_First_Name__c='TestUser' + System.now();
        request.SWS_Email__c = 'TestUser'+math.random()+'@testorg.com';
        request.SWS_Last_Name__c = 'User';
        if(!onlyRequiredField){
            request.SWS_Country__c = 'Albania';
            request.SWS_Job_Title__c = 'Student';
            request.SWS_Cost_Center__c = '43256';
            request.SWS_HW_Compute_Platform_PL__c = 'Multiple platforms';
            request.SWS_HW_Compute_Quantity__c = 'Multiple platform contains intel cloud';
            request.SWS_Compute_Service_Requirements__c =  'Yes';
            request.SWS_Coupon_Type__c = 'Large – Covers 8 weeks of continuous bare-metal system access';
            request.SWS_Expiry_Date__c = System.now().date().addDays(30);
            request.SWS_Coupon_Value__c = 3000;
            request.SWS_No_Of_User__c = 1000;
        }
        insert request;
        System.assert(request.Id!=null,'New Request created sucessfully');
        return request;
    }
    
    public static List<SWS_Cloud_Credit_Request__c> createMultipleRequest(Integer noOfRecords){
        List<SWS_Cloud_Credit_Request__c> requestList = new List<SWS_Cloud_Credit_Request__c>();
        for(Integer i=0; i < noOfRecords ; i++){
            SWS_Cloud_Credit_Request__c request = new SWS_Cloud_Credit_Request__c(
                SWS_First_Name__c = 'Test',
                SWS_Last_Name__c = 'User',
                SWS_Request_Type__c = 'Intel_Internal_Use',
                SWS_Email__c = 'testorg@testorg.com',
                SWS_Country__c = 'Albania',
                SWS_Job_Title__c = 'Student',
                SWS_Cost_Center__c = '43256',
                SWS_HW_Compute_Platform_PL__c = 'Multiple platforms',
                SWS_HW_Compute_Quantity__c = 'Multiple platform contains intel cloud',
                SWS_Compute_Service_Requirements__c =  'Yes',
                SWS_Coupon_Type__c = 'Large – Covers 8 weeks of continuous bare-metal system access',
                SWS_Expiry_Date__c = System.now().date().addDays(30),
                SWS_Coupon_Value__c = 3000,
                SWS_No_Of_User__c = 1000
            );
            requestList.add(request);
        }
        Database.SaveResult[] result = Database.insert(requestList,false);
        System.assert(!requestList.isEmpty(),'New Request created sucessfully');
        return requestList;        
    }
    
    public static Lead createLeadRecord(){
        RecordType recordType = [Select Id from recordType where Name='Lead'];
        Lead lead1 = new Lead();
        lead1.RecordTypeId = recordType.Id;
        lead1.FirstName = 'Test';
        lead1.LastName = 'Test1';
        lead1.email = 'TestUser'+math.random()+'@testorg.com';
        lead1.Phone = '123456790';
        lead1.Company = 'Test1';
        lead1.CountryCode = 'USA';
        lead1.LeadSource = 'IDC Credit Request';
        lead1.Status='Marketing Qualified Lead';
        lead1.Core_Lead_Status__c='New';
        lead1.Core_Lead_State__c='Unclaimed';
        insert lead1;
        System.assert(lead1.Id!=null,'New Lead created sucessfully');
        return lead1;
    }
    
    public static SWS_Bypass_Validation_Rule__c createBypass(Boolean bypass, Datetime dateUpdate){
        SWS_Bypass_Validation_Rule__c mapBypassValidation = SWS_Bypass_Validation_Rule__c.getOrgDefaults();
        mapBypassValidation.Bypass__c = bypass;
        mapBypassValidation.Last_Batch_Update__c = dateUpdate;
        upsert mapBypassValidation;
        return mapBypassValidation;
    }
}