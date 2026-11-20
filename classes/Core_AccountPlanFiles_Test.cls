@isTest
public class Core_AccountPlanFiles_Test {
@testSetup static void setup() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User u = new User(Alias = 'standt', Email='abcdtest1234@apttus.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName=uniqueName + '@test' + orgId + '.org');
        insert u;
        
        User u1 = new User(Alias = 'standt', Email='abcdtest1234@apttus.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName=uniqueName + '@test1' + orgId + '.org');
        insert u1;
        
        User u2 = new User(Alias = 'standt2', Email='abcdtest@apttus.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName=uniqueName + '@test2' + orgId + '.org');
        insert u2;
        
        List<Core_LogEntry_Switch__c> logEntSwitchList = new List<Core_LogEntry_Switch__c>();
        Core_LogEntry_Switch__c logEntSwitch = new Core_LogEntry_Switch__c();
        logEntSwitch.Name = 'Core_LogEntry_Check';
        logEntSwitch.Is_Selected__c = true;
        logEntSwitchList.add(logEntSwitch);
        insert logEntSwitchList;

    }
    
     static TestMethod void AccountPlanContentDocumentLink_Test(){
        list<User> us=[select id,UserName from user where Email='abcdtest1234@apttus.com'];
        User us2=[select id,UserName from user where Email='abcdtest@apttus.com' Limit 1];
        Test.startTest();
        List<Account> acctlist = new List<Account>();
        Account lstAccount = new Account();
        lstAccount.Name='newtestaccount';
        lstAccount.BillingCountryCode = 'USA';
        lstAccount.BIllingStateCode = 'AL';
        lstAccount.BillingCity = 'Alabama';
        lstAccount.BillingStreet = 'test';
        acctlist.add(lstAccount);
        Account lstAccount2 = new Account();
        lstAccount2.Name='newtestaccount2';
        lstAccount2.BillingCountryCode = 'USA';
        lstAccount2.BIllingStateCode = 'AL';
        lstAccount2.BillingCity = 'Alabama';
        lstAccount2.BillingStreet = 'test';
        acctlist.add(lstAccount2);
        Account lstAccount3 = new Account();
        lstAccount3.Name='newtestaccount3';
        lstAccount3.BillingCountryCode = 'USA';
        lstAccount3.BIllingStateCode = 'AL';
        lstAccount3.BillingCity = 'Alabama';
        lstAccount3.BillingStreet = 'test';
        acctlist.add(lstAccount3);
        insert acctlist;
        
        list<AccountTeamMember> accTeamList=new list<AccountTeamMember>(); 
        AccountTeamMember atm=new AccountTeamMember();
        atm.UserId=us[0].id;
        atm.AccountId=lstAccount.id;
        atm.TeamMemberRole='Team Member (100%)';
        accTeamList.add(atm);
        
         AccountTeamMember atm2=new AccountTeamMember();
        atm2.UserId=us[1].id;
        atm2.AccountId=lstAccount.id;
        atm2.TeamMemberRole='Team Member (100%)';
        accTeamList.add(atm2);
        insert accTeamList;
        
        Account_Plan__c accPlan1 = new Account_Plan__c();
        accPlan1.Account__c = lstAccount.id;
        accPlan1.Plan_Name__c = 'Plan 1';
        accPlan1.Plan_Status__c = 'Draft';
        insert accPlan1;
        
        Account_Plan__c accPlan2 = new Account_Plan__c();
        accPlan2.Account__c = lstAccount3.id;
        accPlan2.Plan_Name__c = 'Plan 1';
        accPlan2.Plan_Status__c = 'Draft';
        insert accPlan2;
        
        List<Account_Plan__c> accPlanList=new List<Account_Plan__c>();
         accPlanList.add(accPlan1);
                  accPlanList.add(accPlan2);

        Executive_Meeting_Brief__c emb1 = new Executive_Meeting_Brief__c();
        emb1.Account__c = lstAccount.id;
        emb1.Brief_Status__c = 'Draft';
        insert emb1;
        
        Account_Status__c accStatus1 = new Account_Status__c();
        accStatus1.Account__c = lstAccount.id;
        accStatus1.Status_Update__c = 'Account Status 1';
        insert accStatus1;
        
        Account_Revenue__c accRev1 = new Account_Revenue__c();
        accRev1.Account__c = lstAccount.id;
        insert accRev1;
        
        AccountTeamMember atm3=new AccountTeamMember();
        atm3.UserId=us2.id;
        atm3.AccountId=lstAccount.id;
        atm3.TeamMemberRole='Team Member (100%)';
        insert atm3;
        
        ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion;

            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

			//create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = accPlan1.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
         List<ContentDocumentLink> conDocLinkList=new List<ContentDocumentLink>();
         conDocLinkList.add(cdl);

			//if we are to do multiple tests, i would do all the test data above into a @TestSetup

            //List<ContentDocumentLink> cdl2 = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =:opp.Id];
            //
            Core_AccountPlanFiles.AccountPlanContentDocumentLink(conDocLinkList,null,true);
         	delete cdl;
         	conDocLinkList.add(cdl);
                     Core_AccountPlanFiles.AccountPlanContentDocumentLink(null,conDocLinkList,false);
         Core_AccountPlanFiles.AccountPlanContentDocument(documents);
       }
}