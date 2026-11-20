@isTest
public class CST_CRMAccountBatch_Test {
      @TestSetup static void testSetup() {
        
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='System Administrator'];
          
        SPM_Planning_Period__c pp = new SPM_Planning_Period__c();
        pp.Inactive__c = false;
        pp.Active__c = true;
        pp.Planning_Period__c ='1H 2024';
        insert pp;
          
        SPM_Regional_Customer__c regionalView = new SPM_Regional_Customer__c();
        regionalView.Core_Region__c ='United States';
        regionalView.Core_Planning_Period__c = pp.Id;
        regionalView.Stage__c = 'GM';
        insert regionalView;
        
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
          
        User us2 = new User();
        us2.FirstName = 'test2';
        us2.LastName = 'user';
        us2.Email = 'testuser2@intel.com';
        us2.Username = 'testinguser2@inteltest.com';
        us2.Alias = 'testu2';
        us2.TimeZoneSidKey = 'America/Los_Angeles';
        us2.LocaleSidKey = 'en_US';
        us2.EmailEncodingKey = 'UTF-8';
        us2.ProfileId = pro.Id;
        us2.LanguageLocaleKey = 'en_US';
        insert us2;
          
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
          
        SPM_Customer_Detail__c cd2 = new SPM_Customer_Detail__c();
        cd2.Coverage__c='Intel Led';
        cd2.Core_Regional_Customer_Id__c = rcId;
        cd2.SPM_Customer_Name__c='TestCST2';
        insert cd2;
        
        SPM_Customer_Detail__c cd3 = new SPM_Customer_Detail__c();
        cd3.Coverage__c='Intel Led';
        cd3.Core_Regional_Customer_Id__c = rcId;
        cd3.SPM_Customer_Name__c='TestCST3';
        insert cd3;
        
        Id cstId = [select id from SPM_Customer_Detail__c limit 1][0].Id;
        
        SPM_Customer_Category__c cc = new SPM_Customer_Category__c();
        cc.Customer_Detail__c = cstId;
        cc.Coverage__c = 'Intel Led';
        insert cc;
        
        
        Account a = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St',
                                BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                BillingPostalCode = '12345', Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a;
        }
        Account a1 = new Account(Name = 'TestAccount1', BillingStreet = '123 Fake St',
                                BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                BillingPostalCode = '12345', Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a1;
        }
          
        Account a3 = new Account(Name = 'TestAccount3', BillingStreet = '123 Fake St',
                                BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                BillingPostalCode = '12345', Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a3;
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
       Id sfAcctId1 = [select id from Account where Name='TestAccount1' limit 1][0].Id;    
       Id cst2Id = [select id,SPM_Customer_Name__c from SPM_Customer_Detail__c where SPM_Customer_Name__c='TestCST2' limit 1][0].Id;   
       
        
        SPM_Account_Detail__c ad1 = new SPM_Account_Detail__c();
        ad1.Coverage_Type__c='Intel Led';
        ad1.DR__c = userId;
        ad1.VP__c = userId;
        ad1.GM__c = userId;
        ad1.SPM_Customer_ID__c =cst2Id;
        ad1.SF_Account__c=sfAcctId1;
        insert ad1;
          
        Id sfAcctId3 = [select id from Account where Name='TestAccount3' limit 1][0].Id; 
        Id cst3Id = [select id,SPM_Customer_Name__c from SPM_Customer_Detail__c where SPM_Customer_Name__c='TestCST3' limit 1][0].Id; 
        
        SPM_Account_Detail__c ad3 = new SPM_Account_Detail__c();
        ad3.Coverage_Type__c='Intel Led';
        ad3.DR__c = userId;
        ad3.VP__c = userId;
        ad3.GM__c = userId;
        ad3.SPM_Customer_ID__c =cst3Id;
        ad3.SF_Account__c=sfAcctId3;
        insert ad3;
        
    }

    
     @isTest static void createDRAccountFeedbackTest(){ 
         User userRec = [SELECT Id,Email from User where Email='testuser1@intel.com' limit 1][0];
         Id cstId = [select id from SPM_Customer_Detail__c limit 1][0].Id;
          
       System.runAs(userRec){
           
        SPM_Customer_Feedback__c cstFeedback = new SPM_Customer_Feedback__c();
        cstFeedback.Customer_ID__c = cstId;
        cstFeedback.Feedback_By__c = userRec.Id;
        cstFeedback.Feedback_Type__c ='GM';
        cstFeedback.DR_Feedback__c='Add to Intel Led';
        cstFeedback.Reason_for_change__c ='test';
        cstFeedback.New_Account_Owner__c = userRec.Id;
        cstFeedback.Team_Members__c = userRec.Id;
        cstFeedback.New_Sales_Group__c='Americas Brazil Sales Group';
        cstFeedback.GM_Feedback__c = 'Approved';
        insert cstFeedback;           
        
         
        Id acctId = [select id,SPM_Customer_ID__c from SPM_Account_Detail__c where SPM_Customer_ID__c =:cstId limit 1][0].Id;
        SPM_Account_Feedback__c acctFeedback = new SPM_Account_Feedback__c();
        acctFeedback.Account_ID__c = acctId;
        acctFeedback.Feedback__c='Add to Intel Led';
        acctFeedback.Reason_for_change__c ='test';
        acctFeedback.New_Account_Owner__c = userRec.Id;
        acctFeedback.Team_Members__c = userRec.Id;
        acctFeedback.New_Sales_Group__c='Americas Brazil Sales Group';
        //acctFeedback.Coverage_Type__c='Intel Led';
        Id recordTypeId = Schema.SObjectType.SPM_Account_Feedback__c.getRecordTypeInfosByName().get('DR Feedback').getRecordTypeId();
        acctFeedback.RecordTypeId = recordTypeId;
        insert acctFeedback;
        system.debug('AF 1 ID IS:'+acctFeedback.Id);
           
        SPM_Account_Feedback__c acctFeedback2 = new SPM_Account_Feedback__c();
        acctFeedback2.Account_ID__c = acctId;
        acctFeedback2.Feedback__c='Add to Intel Led';
        acctFeedback2.Reason_for_change__c ='test';
        acctFeedback2.New_Account_Owner__c = userRec.Id;
        acctFeedback2.Team_Members__c = userRec.Id;
        acctFeedback2.New_Sales_Group__c='Americas Brazil Sales Group ';
        //acctFeedback2.Coverage_Type__c='Intel Led';
        acctFeedback2.RecordTypeId = recordTypeId;
        insert acctFeedback2;
        system.debug('AF 2 ID IS:'+acctFeedback2.Id);
           
        User userRec2 = [SELECT Id,Email from User where Email='testuser2@intel.com' limit 1][0];
        Id customer2Id = [select id,SPM_Customer_Name__c from SPM_Customer_Detail__c WHERE SPM_Customer_Name__c='TestCST2' limit 1][0].Id;             
        Id acct2Id = [select id from SPM_Account_Detail__c where SPM_Customer_ID__c =:customer2Id limit 1][0].Id;

        SPM_Customer_Feedback__c cstFeedback2 = new SPM_Customer_Feedback__c();
        cstFeedback2.Customer_ID__c = customer2Id;
        cstFeedback2.Feedback_By__c = userRec.Id;
        cstFeedback2.Feedback_Type__c ='GM';
        cstFeedback2.DR_Feedback__c='Add to Intel Led';
        cstFeedback2.Reason_for_change__c ='test';
        cstFeedback2.New_Account_Owner__c = userRec.Id;
        cstFeedback2.Team_Members__c = userRec.Id;
        cstFeedback2.New_Sales_Group__c='Americas Brazil Sales Group';
        cstFeedback2.GM_Feedback__c = 'Approved';
        insert cstFeedback2;           
        
        
        SPM_Account_Feedback__c acctFeedback3 = new SPM_Account_Feedback__c();
        acctFeedback3.Account_ID__c = acct2Id;
        acctFeedback3.Feedback__c='Add to Intel Led';
        acctFeedback3.Reason_for_change__c ='test';
        acctFeedback3.New_Account_Owner__c = userRec.Id;
        acctFeedback3.Team_Members__c = userRec.Id;
        acctFeedback3.New_Sales_Group__c='Americas Brazil Sales Group';
        //acctFeedback3.Coverage_Type__c='Intel Led';
        acctFeedback3.RecordTypeId = recordTypeId;
        insert acctFeedback3;
        system.debug('AF 3 ID IS:'+acctFeedback3.Id);
        
        Id customer3Id = [select id,SPM_Customer_Name__c from SPM_Customer_Detail__c where SPM_Customer_Name__c='TestCST3' limit 1][0].Id; 
        List<SPM_Account_Detail__c> acct3Id = [select id,SPM_Customer_ID__c from SPM_Account_Detail__c where SPM_Customer_ID__c =:customer3Id limit 1];  

        SPM_Account_Feedback__c acctFeedback4 = new SPM_Account_Feedback__c();
        acctFeedback4.Account_ID__c = acct2Id;        
        acctFeedback4.Feedback__c='Add to Intel Led';
        acctFeedback4.Reason_for_change__c ='test';
        acctFeedback4.New_Account_Owner__c = userRec.Id;
        acctFeedback4.Team_Members__c = userRec.Id;
        acctFeedback4.New_Sales_Group__c='Americas Canada Sales Group';
        //acctFeedback4.Coverage_Type__c='Intel Led';
        acctFeedback4.RecordTypeId = recordTypeId;
        insert acctFeedback4;
        system.debug('AF 4 ID IS:'+acctFeedback4.Id);
        
        List<SPM_Planning_Period__c> planningRec = [Select Id,Name,Active__c,Planning_Period__c  FROM SPM_Planning_Period__c WHERE Active__c=true ORDER BY CreatedDate DESC LIMIT 1];
        String planningPeriod =  planningRec[0].Planning_Period__c;
        system.debug('planning period is'+planningPeriod);
        List<SPM_Customer_Feedback__c> custFeedbackList =[SELECT Id,Name,GM_Feedback__c,Customer_Name__c,Customer_ID__r.Planning_Period__c FROM SPM_Customer_Feedback__c WHERE GM_Feedback__c ='Approved'  AND Customer_ID__r.Core_PlanningPeriod__c=:planningPeriod];
        system.debug('custFeedbackList is:'+custFeedbackList);
           
        Id jobId = Database.executeBatch(new CST_CRMAccountBatch());
             }
             
         }
        


}