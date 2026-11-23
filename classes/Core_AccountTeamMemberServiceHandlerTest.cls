@isTest
public class Core_AccountTeamMemberServiceHandlerTest {
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
        
        String permissionSetName = System.Label.Pricing_Tender_PermissionSets_TenderUser;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
    }
    
    static TestMethod void Core_AccountTeamMemberHandler_Test(){
        list<User> us=[select id,UserName from user where Email='abcdtest1234@apttus.com'];
        
        Account lstAccount = new Account();
        lstAccount.Name='newtestaccount';
        lstAccount.BillingCountryCode = 'USA';
        lstAccount.BIllingStateCode = 'AL';
        lstAccount.BillingCity = 'Alabama';
        lstAccount.BillingStreet = 'test';
        insert lstAccount;
        
        Core_Trigger_Executions__c cte=new Core_Trigger_Executions__c();
        cte.Core_Active__c=true;
        cte.Core_Class_Name__c='Core_AccountTeamMember';
        cte.Name='SendingListOfTenderUsersTobatch';
        cte.Core_Description__c ='Used for Core_AccountTeam_PermissionSetAssignment Trigger';
        cte.Core_Object__c ='AccountTeamMember';
        cte.Core_Trigger_Events__c='after insert,after update';
        insert cte;
        
        list<AccountTeamMember> accTeamList=new list<AccountTeamMember>(); 
        AccountTeamMember atm=new AccountTeamMember();
        atm.UserId=us[0].id;
        atm.AccountId=lstAccount.id;
        atm.TeamMemberRole='Team Member (100%)';
        insert atm;
        
         AccountTeamMember atm2=new AccountTeamMember();
        atm2.UserId=us[1].id;
        atm2.AccountId=lstAccount.id;
        atm2.TeamMemberRole='Team Member (100%)';
        insert atm2;
        
        AccountTeamMember atm1=new AccountTeamMember();
        atm1.Id=atm.Id;
        atm1.TeamMemberRole='Viewer (0%)';
        Update atm1;
        accTeamList.add(atm1);
        Delete atm2;
        system.assertEquals(1, accTeamList.size());
        
        Test.startTest();
        system.runAs(us[0]){
            Core_AccountTeamMemberServiceHandler.sharingAccountTeamList(accTeamList,false);
        }
        Test.stopTest();
    }
}