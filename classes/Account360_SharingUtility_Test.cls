@isTest
public class Account360_SharingUtility_Test {
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
    
    static TestMethod void account360_Sharing_Test(){
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
        List<Core_Trigger_Executions__c> cteList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c cte=new Core_Trigger_Executions__c();
        cte.Core_Active__c=true;
        cte.Core_Class_Name__c='AccountPlan_Trigger';
        cte.Name='EnableAccount360SharingForAccountPlan';
        cte.Core_Description__c ='Switch to Enable Account360 Sharing For AccountPlan';
        cte.Core_Object__c ='Account_Plan__c';
        cte.Core_Trigger_Events__c='after insert';
        cteList.add(cte);
        Core_Trigger_Executions__c cte2=new Core_Trigger_Executions__c();
        cte2.Core_Active__c=true;
        cte2.Core_Class_Name__c='AccountStatus_Trigger';
        cte2.Name='EnableAcc360SharingForAccountStatus';
        cte2.Core_Description__c ='Switch to Enable Account360 Sharing For AccountStatus';
        cte2.Core_Object__c ='Account_Status__c';
        cte2.Core_Trigger_Events__c='after insert';
        cteList.add(cte2);
        Core_Trigger_Executions__c cte3=new Core_Trigger_Executions__c();
        cte3.Core_Active__c=true;
        cte3.Core_Class_Name__c='ExecutiveMeetingBrief_Trigger';
        cte3.Name='EnableAccount360SharingForEMB';
        cte3.Core_Description__c ='Switch to Enable Account360 Sharing For Executive Meeting Brief';
        cte3.Core_Object__c ='Executive_Meeting_Brief__c';
        cte3.Core_Trigger_Events__c='after insert';
        cteList.add(cte3);
        Core_Trigger_Executions__c cte4=new Core_Trigger_Executions__c();
        cte4.Core_Active__c=true;
        cte4.Core_Class_Name__c='AccountRevenue_Trigger';
        cte4.Name='EnableAccount360SharingForAccountRev';
        cte4.Core_Description__c ='Switch to Enable Account360 Sharing For AccountRevenue';
        cte4.Core_Object__c ='Account_Revenue__c';
        cte4.Core_Trigger_Events__c='after insert';
        cteList.add(cte4);
        
        
        Database.insert(cteList);
        
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
        
        List<Account_Plan__Share> accPlanShare = new List<Account_Plan__Share>();
        List<Executive_Meeting_Brief__Share> embShare = new List<Executive_Meeting_Brief__Share>();
        List<Account_Status__Share> accStatusShare = new List<Account_Status__Share>();
        List<Account_Revenue__Share> accRevShare = new List<Account_Revenue__Share>();
        accPlanShare = [Select ID,ParentId, UserOrGroupId from Account_Plan__Share where UserOrGroupId = :us[0].Id];
        embShare = [Select ID,ParentId, UserOrGroupId from Executive_Meeting_Brief__Share where UserOrGroupId = :us[0].Id];
        accStatusShare = [Select ID,ParentId, UserOrGroupId from Account_Status__Share where UserOrGroupId = :us[0].Id];
        accRevShare = [Select ID,ParentId, UserOrGroupId from Account_Revenue__Share where UserOrGroupId = :us[0].Id];
        System.assert(accPlanShare.size() > 0);
        System.assert(embShare.size() > 0);
        System.assert(accStatusShare.size() > 0);
        System.assert(accRevShare.size() > 0);
        
        Delete atm2;
        accPlanShare = [Select ID,ParentId, UserOrGroupId from Account_Plan__Share where UserOrGroupId = :us[1].Id];
        Test.stopTest();
        Account360_DeleteSharing.InputData  inp = new Account360_DeleteSharing.InputData();
        inp.userId = null;
        inp.accountId = null ;
        ExecutiveMeetingBrief_ServiceHandler.account360Sharing(null);
        AccountPlan_ServiceHandler.account360Sharing(null);
        AccountStatus_ServiceHandler.account360Sharing(null);
        AccountRevenue_ServiceHandler.account360Sharing(null);
        Account360_DeleteSharing.invokeDeleteAccount360Sharing(new List<Account360_DeleteSharing.InputData>{inp});
        Account360_SharingUtility.createShareRecordList(null);
        Account360_SharingUtility.account360_Apex_Sharing(null);
        Account360_SharingUtility.invokeAccount360Sharing(null);
        Account360_SharingUtility.performAccount360Sharing(null);
       }
}