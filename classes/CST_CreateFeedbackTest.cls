@isTest(SeeAllData=false)
public class CST_CreateFeedbackTest {
    @TestSetup static void testSetup() {
        List<Core_CRM_Labels__c> customSetting= new List<Core_CRM_Labels__c>();
        
        Core_CRM_Labels__c cust1 = new Core_CRM_Labels__c();
        cust1.name = 'CST_Error_Email';
        cust1.value__c = 'vijaykumar.s@intel.com';
        customSetting.add(cust1);
        
        Core_CRM_Labels__c cust2 = new Core_CRM_Labels__c();
        cust2.name = 'CST_Add_multiple_feedback_Error';
        cust2.value__c = 'You cannot add multiple feedbacks for same person.Kindly edit the old feedback record.';
        customSetting.add(cust2);
        
        Core_CRM_Labels__c cust3 = new Core_CRM_Labels__c();
        cust3.name = 'ST_Check_Recommendation_for_uncovered';
        cust3.value__c = 'Intel led';
        customSetting.add(cust3);
        
        Core_CRM_Labels__c cust4 = new Core_CRM_Labels__c();
        cust4.name = 'CST_Cust_level_feedback_first_Error';
        cust4.value__c = 'First enter a customer level Feedback. Please click on the Customer ID link to return to the customer details.';
        customSetting.add(cust4);
        
        Core_CRM_Labels__c cust5 = new Core_CRM_Labels__c();
        cust5.name = 'CST_Nonpropogated_Feedback_Error';
        cust5.value__c = 'Note: you need to enter feedback for the specific account/s that is changing.';
        customSetting.add(cust5);
        
        Core_CRM_Labels__c cust6 = new Core_CRM_Labels__c();
        cust6.name = 'CST_Save_Error';
        cust6.value__c = 'Data not saved successfully. Please contact your administrator.';
        customSetting.add(cust6);
        
        Core_CRM_Labels__c cust7 = new Core_CRM_Labels__c();
        cust7.name = 'ST_Valid_DR_Acct';
        cust7.value__c = 'You are not the eligible DR for this Account.';
        customSetting.add(cust7);
        
        Core_CRM_Labels__c cust8 = new Core_CRM_Labels__c();
        cust8.name = 'CST_Valid_DR_Cust';
        cust8.value__c = 'You have not selected a correct DR for Feedback By.';
        customSetting.add(cust8);
        
        Core_CRM_Labels__c cust9 = new Core_CRM_Labels__c();
        cust9.name = 'CST_Valid_Email_Error_AcctOwner';
        cust9.value__c = 'Please provide a valid user email for new account owner.';
        customSetting.add(cust9);
        
        Core_CRM_Labels__c cust10 = new Core_CRM_Labels__c();
        cust10.name = 'CST_Valid_Email_Error_FeedbackBy';
        cust10.value__c = 'Please provide a valid email id for feedbackBy.';
        customSetting.add(cust10);
        
        Core_CRM_Labels__c cust11 = new Core_CRM_Labels__c();
        cust11.name = 'CST_Valid_VP_Acct';
        cust11.value__c = 'You are not the eligible VP for this Account.';
        customSetting.add(cust11);
        
        Core_CRM_Labels__c cust12 = new Core_CRM_Labels__c();
        cust12.name = 'CST_Valid_VP_Cust';
        cust12.value__c = 'You have not selected a correct VP for Feedback By.';
        customSetting.add(cust12);
        
        insert customSetting;
        
        
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='System Administrator'];
        
		User us1 = new User();
        us1.FirstName = 'test1';
        us1.LastName = 'user';
        us1.Email = 'testuser1@intel.com';
        us1.Username = 'testinguser1@inteltest.com';
        us1.Alias = 'testu1';
        us1.CommunityNickname = 'test.userqwert1';
        us1.TimeZoneSidKey = 'America/Los_Angeles';
        us1.LocaleSidKey = 'en_US';
        us1.EmailEncodingKey = 'UTF-8';
        us1.ProfileId = pro.Id;
        us1.LanguageLocaleKey = 'en_US';
		insert us1;
		Id userId = [SELECT Id from User where Email='testuser1@intel.com' limit 1][0].Id;
        
        system.runAs(us1){
        PermissionSet superadmin = [SELECT Id, Name FROM PermissionSet where Name = 'Sales_CRM_CST_Super_Admin'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = superadmin.Id, AssigneeId = userId);
            insert psa;
        }
        
		
         SPM_Regional_Customer__c rc = new SPM_Regional_Customer__c();
         rc.Core_Region__c = 'EMEA';
         rc.Stage__c = 'DR';
        insert rc;
        
        Id rcId = [select id from SPM_Regional_Customer__c limit 1][0].Id;
        
        SPM_Customer_Detail__c cd = new SPM_Customer_Detail__c();
        cd.Coverage__c='Intel Led';
        cd.Core_Regional_Customer_Id__c = rcId;
        cd.SPM_Customer_Name__c='TestCST';
        insert cd;
        
        Id cstId = [select id from SPM_Customer_Detail__c limit 1][0].Id;
        
        SPM_Customer_Category__c cc = new SPM_Customer_Category__c();
        cc.Customer_Detail__c = cstId;
        cc.Coverage__c = 'Intel Led';
        insert cc;
        
        
        Account a = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St',
                                BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a;
        }
        Id sfAcctId = [select id from Account where Name='TestAccount' limit 1][0].Id;
        SPM_Account_Detail__c ad = new SPM_Account_Detail__c();
        ad.Coverage_Type__c='Intel Led';
        ad.DR__c = userId;
        ad.VP__c = userId;
        ad.GM__c = userId;
        ad.SPM_Customer_ID__c =cstId;
        ad.SF_Account__c=sfAcctId;
        insert ad;
        
    }
    @isTest static void testGetEmbeddingObjectDetails(){
        Id cstId = [select id from SPM_Customer_Detail__c limit 1][0].Id;
        CST_CreateFeedback.FeedBackFields cstF = CST_CreateFeedback.getEmbeddingObjectDetails(cstId);
        Id acctId = [select id from SPM_Account_Detail__c limit 1][0].Id;
        CST_CreateFeedback.FeedBackFields acctF = CST_CreateFeedback.getEmbeddingObjectDetails(acctId);
        
    }
    @isTest static void testCheckPerm(){ 
        Id cstId = [select id from SPM_Customer_Detail__c limit 1][0].Id;
        Id userId = [SELECT Id from User where Email='testuser1@intel.com' limit 1][0].Id;
        CST_CreateFeedback.CST_CheckPerm cp = new CST_CreateFeedback.CST_CheckPerm();
        Boolean isValid = cp.checkPerm(cstId,'DR',userId);
        
    }
    
         @isTest static void createDRAccountFeedbackTest(){ 
		 User userRec = [SELECT Id,Email from User where Email='testuser1@intel.com' limit 1][0];
         Id cstId = [select id from SPM_Customer_Detail__c limit 1][0].Id;
        CST_CreateFeedback.CustomerFeedBackFields cstFeedback = new CST_CreateFeedback.CustomerFeedBackFields();
            
             System.runAs(userRec){
                 cstFeedback.CustomerId = cstId;
        cstFeedback.feedbackBy = userRec.Email;
        cstFeedback.FeedbackType ='DR';
        cstFeedback.Feedback='Add to Intel Led';
        cstFeedback.ReasonForChange ='test';
        cstFeedback.NewAcctOwner = userRec.Email;
        cstFeedback.TeamMembers = userRec.Id;
        cstFeedback.SalesGroup='test';
        cstFeedback.Coverage='Intel Led';
        //Id cstRecordTypeId = Schema.SObjectType.SPM_Customer_Feedback__c.getRecordTypeInfosByName().get('DR Feedback').getRecordTypeId();
        //cstFeedback.RecordTypeId = cstRecordTypeId;
        
        Map<Boolean,String> cf = CST_CreateFeedback.createCustomerFeedback(cstFeedback);
             
        Id acctId = [select id from SPM_Account_Detail__c where SPM_Customer_ID__c =:cstId limit 1][0].Id;
        CST_CreateFeedback.AccountFeedBackFields acctFeedback = new CST_CreateFeedback.AccountFeedBackFields();
        acctFeedback.AccountId = acctId;
        acctFeedback.FeedbackType ='DR';
        acctFeedback.Feedback='Add to Intel Led';
        acctFeedback.ReasonForChange ='test';
        acctFeedback.NewAcctOwner = userRec.Email;
        acctFeedback.TeamMembers = userRec.Id;
        acctFeedback.SalesGroup='test';
        acctFeedback.Coverage='Intel Led';
        Id recordTypeId = Schema.SObjectType.SPM_Account_Feedback__c.getRecordTypeInfosByName().get('DR Feedback').getRecordTypeId();
        acctFeedback.RecordTypeId = recordTypeId;
        
        Map<Boolean,String> af = CST_CreateFeedback.createAccountFeedback(acctFeedback);
             }
             
         }
        

         @isTest static void createVPAccountFeedbackTest(){ 
		 User userRec = [SELECT Id,Email from User where Email='testuser1@intel.com' limit 1][0];
             system.runAs(userRec){
                 SPM_Regional_Customer__c rc = [SELECT ID from SPM_Regional_Customer__c where Core_Region__c='EMEA' and Stage__c='DR' LIMIT 1];
                 rc.Stage__c = 'VP';
                 update rc;
                 Id cstId = [select id from SPM_Customer_Detail__c limit 1][0].Id;
                 
                 CST_CreateFeedback.CustomerFeedBackFields cstFeedback = new CST_CreateFeedback.CustomerFeedBackFields();
                 cstFeedback.CustomerId = cstId;
                 cstFeedback.feedbackBy = userRec.Email;
                 cstFeedback.FeedbackType ='VP';
                 cstFeedback.Feedback='Change to Partner';
                 cstFeedback.ReasonForChange ='test';
                 cstFeedback.NewAcctOwner = userRec.Email;
                 cstFeedback.TeamMembers = userRec.Id;
                 cstFeedback.SalesGroup='test';
                 cstFeedback.Coverage='Intel Led';
                 //Id cstRecordTypeId = Schema.SObjectType.SPM_Customer_Feedback__c.getRecordTypeInfosByName().get('VP Feedback').getRecordTypeId();
                 //cstFeedback.RecordTypeId = cstRecordTypeId;
                 
                 Map<Boolean,String> cf = CST_CreateFeedback.createCustomerFeedback(cstFeedback);
                 
                 Id acctId = [select id from SPM_Account_Detail__c limit 1][0].Id;
                 CST_CreateFeedback.AccountFeedBackFields acctFeedback = new CST_CreateFeedback.AccountFeedBackFields();
                 acctFeedback.AccountId = acctId;
                 acctFeedback.FeedbackType ='VP';
                 acctFeedback.Feedback='Change to Partner';
                 acctFeedback.ReasonForChange ='test';
                 acctFeedback.NewAcctOwner = userRec.Email;
                 acctFeedback.TeamMembers = userRec.Id;
                 acctFeedback.SalesGroup='test';
                 acctFeedback.Coverage='Intel Led';
                 Id recordTypeId = Schema.SObjectType.SPM_Account_Feedback__c.getRecordTypeInfosByName().get('VP Feedback').getRecordTypeId();
                 acctFeedback.RecordTypeId = recordTypeId;
                 
                 Map<Boolean,String> af = CST_CreateFeedback.createAccountFeedback(acctFeedback);
                 CST_CreateFeedback.FeedBackFields cstF = CST_CreateFeedback.getEmbeddingObjectDetails(cstId);
                 CST_CreateFeedback.FeedBackFields acctF = CST_CreateFeedback.getEmbeddingObjectDetails(acctId);
                 
                 List<SPM_Regional_Customer__c> regionalView = [select id,stage__c from SPM_Regional_Customer__c where id =: rc.Id limit 1];
                 String queryCustomerFeedback = 'select id,Feedback_Type__c, Customer_ID__r.Core_Regional_Customer_Id__c from SPM_Customer_Feedback__c where Customer_ID__r.Core_Regional_Customer_Id__c	IN: regionalId';
                 Map<Id,SPM_Regional_Customer__c>   regionalData =  new Map<Id,SPM_Regional_Customer__c>(regionalView);
                 SPM_FeedbackStageUpdate batchCustomerUpdate = new SPM_FeedbackStageUpdate('SPM_Customer_Feedback__c',queryCustomerFeedback,regionalData);
                 Database.executeBatch(batchCustomerUpdate,100);
                 //List<Map<String, String>> gtmValues = CST_CreateFeedback.getgtmPicklistValues();
         //List<Map<String, String>> gtmValuesCust =    CST_CreateFeedback.getgtmPicklistValuesCustFeedback();
         List<Map<String, String>> gtmValuesAcct =    CST_CreateFeedback.getAccountCategoryValues();
             }
         }  
}