@isTest(SeeAllData=false)
public class CST_UtilityClass_Test {
    
    
    @isTest static void testADandAFMap(){ 
        
        // setup data
        
        Core_CRM_Labels__c customSetting= new Core_CRM_Labels__c();
        
        customSetting.name = 'CST_Error_Email';
        customSetting.value__c = 'vijaykumar.s@intel.com';
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
        
        List<SPM_Security_Mapping__c> createSecurity = New List<SPM_Security_Mapping__c>();
        createSecurity.add(new SPM_Security_Mapping__c(Account_Owner__c = userId, Role__c = 'Regional Lead', Region__c= 'EMEA', Manager__c = userId));
        insert createSecurity;
        
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
        
        
        // setup data
               
        User userRec = [SELECT Id,Email from User where Email='testuser1@intel.com' limit 1][0];
        //Id cstId = [select id from SPM_Customer_Detail__c where SPM_Customer_Name__c = 'TestCST' limit 1][0].Id;
      //  System.debug('cstId'+cstId);
        CST_CreateFeedback.CustomerFeedBackFields cstFeedback = new CST_CreateFeedback.CustomerFeedBackFields();
        
        System.runAs(userRec){
            cstFeedback.CustomerId = cstId;
            cstFeedback.feedbackBy = userRec.Email;
            cstFeedback.FeedbackType ='DR';
            cstFeedback.Feedback='Change to Partner';
            cstFeedback.ReasonForChange ='test';
            cstFeedback.NewAcctOwner = userRec.Email;
            cstFeedback.TeamMembers = userRec.Id;
            cstFeedback.SalesGroup='test';
            cstFeedback.Coverage='Intel Led';
            
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
            
            SPM_Customer_Feedback__c custFeedback = [Select id,Feedback_By__c from SPM_Customer_Feedback__c WHERE Customer_ID__c =: cstId limit 1];
            
            List<String> custIdList = new List<String>();
            custIdList.add(custFeedback.Id);
            List<String> custFBList = new List<String>();
            custFBList.add(custFeedback.Feedback_By__c);
            System.debug('custFeedback '+custFeedback+'acctFeedback '+acctFeedback+'cstId -'+cstId);
            CST_UtilityClass.mapADandAF(custIdList);
            CST_FlowApexActionController.getSecurity(custFBList);
        }
    }
    
}