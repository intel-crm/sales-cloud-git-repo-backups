@isTest  
public class SPM_ShareAccountdetailsTest {  
    
    
    @testSetup
    static void setupTestData() { 
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        List<User> usercreation = new List<User>();
        User us = new User();
        us.FirstName = 'test';
        us.LastName = 'GM';
        us.Email = 'testuser@intel.com';
        us.Username = 'testinguser@inteltest.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.userqwert';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = pro.Id;
        us.LanguageLocaleKey = 'en_US';
        us.Core_WWID__c = '00000';
        usercreation.add(us);
        
        User us1 = new User();
        us1.FirstName = 'test1';
        us1.LastName = 'VP';
        us1.Email = 'testuser1@intel.com';
        us1.Username = 'testinguser1@inteltest.com';
        us1.Alias = 'testu1';
        us1.CommunityNickname = 'test.userqwert1';
        us1.TimeZoneSidKey = 'America/Los_Angeles';
        us1.LocaleSidKey = 'en_US';
        us1.EmailEncodingKey = 'UTF-8';
        us1.ProfileId = pro.Id;
        us1.LanguageLocaleKey = 'en_US';
        us1.Core_WWID__c = '11111';
        usercreation.add(us1);
        
        User us2 = new User();
        us2.FirstName = 'test2';
        us2.LastName = 'DR';
        us2.Email = 'testuser2@intel.com';
        us2.Username = 'testinguser2@inteltest.com';
        us2.Alias = 'testu2';
        us2.CommunityNickname = 'test.userqwert2';
        us2.TimeZoneSidKey = 'America/Los_Angeles';
        us2.LocaleSidKey = 'en_US';
        us2.EmailEncodingKey = 'UTF-8';
        us2.ProfileId = pro.Id;
        us2.LanguageLocaleKey = 'en_US';
        us2.Core_WWID__c = '22222';
        usercreation.add(us2);
        
        User us3 = new User();
        us3.FirstName = 'test3';
        us3.LastName = 'Account Owner';
        us3.Email = 'testuser3@intel.com';
        us3.Username = 'testinguser3@inteltest.com';
        us3.Alias = 'testu3';
        us3.CommunityNickname = 'test.userqwert3';
        us3.TimeZoneSidKey = 'America/Los_Angeles';
        us3.LocaleSidKey = 'en_US';
        us3.EmailEncodingKey = 'UTF-8';
        us3.ProfileId = pro.Id;
        us3.LanguageLocaleKey = 'en_US';
        us3.Core_WWID__c = '33333';
        usercreation.add(us3);
        
        User us4 = new User();
        us4.FirstName = 'test3';
        us4.LastName = 'Account Owner';
        us4.Email = 'testuser4@intel.com';
        us4.Username = 'testinguser4@inteltest.com';
        us4.Alias = 'testu4';
        us4.CommunityNickname = 'test.userqwert4';
        us4.TimeZoneSidKey = 'America/Los_Angeles';
        us4.LocaleSidKey = 'en_US';
        us4.EmailEncodingKey = 'UTF-8';
        us4.ProfileId = pro.Id;
        us4.LanguageLocaleKey = 'en_US';
        us4.Core_WWID__c = '4444';
        usercreation.add(us4);
        
        User us5 = new User();
        us5.FirstName = 'test3';
        us5.LastName = 'Account Owner';
        us5.Email = 'testuser5@intel.com';
        us5.Username = 'testinguser5@inteltest.com';
        us5.Alias = 'testu5';
        us5.CommunityNickname = 'test.userqwert5';
        us5.TimeZoneSidKey = 'America/Los_Angeles';
        us5.LocaleSidKey = 'en_US';
        us5.EmailEncodingKey = 'UTF-8';
        us5.ProfileId = pro.Id;
        us5.LanguageLocaleKey = 'en_US';
        us5.Core_WWID__c = '55555';
        usercreation.add(us5);
        
        
        insert usercreation;
        
        List<Core_CRM_Labels__c> customSetting= new List<Core_CRM_Labels__c>();
        
        Core_CRM_Labels__c cust1 = new Core_CRM_Labels__c();
        cust1.name = 'Intel_Led';
        cust1.value__c = 'Intel Led';
        customSetting.add(cust1);
        
        Core_CRM_Labels__c cust2 = new Core_CRM_Labels__c();
        cust2.name = 'Partner_led';
        cust2.value__c = 'Partner Led';
        customSetting.add(cust2);
        
        Core_CRM_Labels__c cust3 = new Core_CRM_Labels__c();
        cust3.name = 'Uncovered';
        cust3.value__c = 'Uncovered';
        customSetting.add(cust3);
        
        insert customSetting;
        
        // Create an account
        Account a = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St',Core_Geo__c='APJ',RecordTypeId= '012o0000000GlzTAAS',
                                BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        
        insert a;
        
        Permissionset tempper = [Select id from Permissionset where name = 'Sales_CRM_CST_Director' limit 1];
        
        PermissionSetAssignment assignDRPer = new PermissionSetAssignment();
        assignDRPer.AssigneeId = usercreation[2].id;
        assignDRPer.PermissionSetId = tempper.id;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert assignDRPer;
        }
        
        SPM_Planning_Period__c pp =new SPM_Planning_Period__c(Active__c=true);
        insert pp;
        
        List<SPM_Security_Mapping__c> createSecurity = New List<SPM_Security_Mapping__c>();
        createSecurity.add(new SPM_Security_Mapping__c(Account_Owner__c = usercreation[3].id, Role__c = 'DR',Region__c= 'EMEA', Manager__c = usercreation[2].id));
        createSecurity.add(new SPM_Security_Mapping__c(Account_Owner__c = usercreation[3].id, Role__c = 'VP',Region__c= 'EMEA', Manager__c = usercreation[1].id, TA__c =usercreation[0].id));
        createSecurity.add(new SPM_Security_Mapping__c(Account_Owner__c = usercreation[3].id, Role__c = 'GM',Region__c= 'EMEA', Manager__c = usercreation[0].id, TA__c =usercreation[1].id));
        createSecurity.add(new SPM_Security_Mapping__c(Account_Owner__c = usercreation[3].id, Role__c = 'Regional Lead', Region__c= 'EMEA', Manager__c = usercreation[4].id));
        createSecurity.add(new SPM_Security_Mapping__c(Account_Owner__c = usercreation[3].id, Role__c = 'R3',Region__c= 'EMEA', Manager__c = usercreation[5].id));
        
        insert createSecurity;
        
        SPM_Regional_Customer__c createRegionalCust = new SPM_Regional_Customer__c(Core_Region__c = 'EMEA',Stage__c='DR');
        insert createRegionalCust;
        
        SPM_Customer_Detail__c createCustomer = new SPM_Customer_Detail__c(SPM_Customer_Name__c = 'Test Customer',Core_Region__c='EMEA',Core_Regional_Customer_Id__c =createRegionalCust.id );
        
        insert createCustomer;
        List<SPM_Customer_Category__c> categoryCreate = new List<SPM_Customer_Category__c>();
        SPM_Customer_Category__c createCategory = new SPM_Customer_Category__c(Customer_Detail__c =createCustomer.id,Coverage__c = 'Partner Led',Category__c = 'Distributors',  Core_Recommendation__c='Consider for Intel led');
        categoryCreate.add(createCategory);
        SPM_Customer_Category__c createCategory1 = new SPM_Customer_Category__c(Customer_Detail__c =createCustomer.id,Coverage__c = 'Intel Led',Category__c = 'B2B End-user');
        categoryCreate.add(createCategory1);
        
        insert categoryCreate;
        
        String userWWID = [select Core_WWID__c from user where Id =: UserInfo.getUserId()].Core_WWID__c;
        List<SPM_Account_Detail__c> accountDetailsList = new List<SPM_Account_Detail__c>();
        SPM_Account_Detail__c account = new SPM_Account_Detail__c(Account_Owner_WWID__c = userWWID, SF_Account__c= a.id, Region__c = 'PCR', Category__c = 'Distributors' , SPM_Customer_ID__c =createCustomer.id ); 
        accountDetailsList.add(account);
        SPM_Account_Detail__c account1 = new SPM_Account_Detail__c(Account_Owner_WWID__c = userWWID, SF_Account__c= a.id, Region__c = 'PCR', Category__c = 'Distributors' , SPM_Customer_ID__c =createCustomer.id ); 
        accountDetailsList.add(account1);
        insert accountDetailsList; 
        
        SPM_Account_Detail__c account2 = new SPM_Account_Detail__c(Account_Owner_WWID__c = '33333', SF_Account__c= a.id, Region__c = 'PCR', Category__c = 'B2B End-user' , SPM_Customer_ID__c =createCustomer.id ); 
        insert account2;
        
        Core_Trigger_Executions__c triggerExecRecord =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='SPM_AccountDetailsTriggerHandler',Core_Description__c='testing',Core_Object__c='SPM_New_Accounts__c',Core_Trigger_Events__c='After update',Name='shareNewAccountDetails');
        insert triggerExecRecord;
       
    }
    
    @isTest  
    static void testflowSharing() { 
        SPM_ShareAccountdetails.FlowInputs input = new SPM_ShareAccountdetails.FlowInputs();
        list<SPM_ShareAccountdetails.FlowInputs> inputList = new list<SPM_ShareAccountdetails.FlowInputs>();
        list<Id> acctownerWWIDlst = new list<Id>();
        list<Id> acctDetIdlst = new list<Id>();
        
        test.starttest();
        List<SPM_Account_Detail__c> accountDetailsList = [select id, Account_Owner_WWID__c from SPM_Account_Detail__c where Category__c = 'Distributors' limit 2];
        for(SPM_Account_Detail__c acd : accountDetailsList) {
            acctownerWWIDlst.add(acd.Id);
            acctDetIdlst.add(acd.Id);
        }
        input.AccountOwnerWWIDList = acctownerWWIDlst;
        input.AccountDetailIdList = acctDetIdlst;
        inputList.add(input);
        SPM_ShareAccountdetails.executeCRMAccountBatch(inputList);
        SPM_ShareAccountdetails.getSecurtiyMape();
        test.stopTest();
    }
    
    @isTest  
    static void testCoveredAccountSharing() {  
        test.starttest();
        // Create instance of batch class with covered account flag and query for test account  
        SPM_ShareAccountdetails batch = new SPM_ShareAccountdetails(false, 'Where Account_Owner_WWID__c != null', 1);  
        
        // Execute batch  
        Database.executeBatch(batch);
        
        test.stopTest();
    }  
    
    @isTest  
    static void testNewAccountSharing() {  
        user tempUser  = [Select id from user where email = 'testuser2@intel.com' limit 1]; 
        test.starttest();
        SPM_New_Accounts__c NewAccount = new SPM_New_Accounts__c();
        NewAccount.Account_Name__c = 'test New Account';
        NewAccount.Customer_category__c ='Distributors';
        NewAccount.New_Account_Owner__c = tempUser.id;
        NewAccount.Reasoning__c	= 'testing';
        
        System.runAs(tempUser) {
            insert NewAccount;
        }
        
        test.stopTest();      
    }      
}