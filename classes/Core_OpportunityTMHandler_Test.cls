@isTest
public class Core_OpportunityTMHandler_Test {
    @TestSetup
    static void setupData() {
        List<Core_Trigger_Executions__c> teList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c opportunityTeamMemberHandler = new Core_Trigger_Executions__c();
        opportunityTeamMemberHandler.name = 'opportunityTeamMemberHandler';
        opportunityTeamMemberHandler.Core_Object__c = 'OpportunityTeamMember';
        opportunityTeamMemberHandler.Core_Active__c = TRUE;
        opportunityTeamMemberHandler.Core_Trigger_Events__c = 'After insert, after update, after delete';
        opportunityTeamMemberHandler.Core_Description__c = 'This is test description';
        opportunityTeamMemberHandler.Core_Class_Name__c = 'Test Class';
        teList.add(opportunityTeamMemberHandler);
        
        Core_Trigger_Executions__c IsAccessibleOppoObj = new Core_Trigger_Executions__c();
        IsAccessibleOppoObj.name = 'IsAccessibleOppoObj';
        IsAccessibleOppoObj.Core_Object__c = 'OpportunityTeamMember';
        IsAccessibleOppoObj.Core_Active__c = TRUE;
        IsAccessibleOppoObj.Core_Trigger_Events__c = 'After insert, after update, after delete';
        IsAccessibleOppoObj.Core_Description__c = 'This is test description';
        IsAccessibleOppoObj.Core_Class_Name__c = 'Test Class';
        teList.add(IsAccessibleOppoObj);
        
        insert teList;
        
        Profile p = [select Id from Profile where Name = 'IT Admin'];
        
        User OSOOwner = new User(Alias = 'OSOOwner', Email='OSOOwner@apttus.com',
                               EmailEncodingKey='UTF-8', LastName='TTest', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = p.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='OSOOwner@mail.com', Department='OSC', Core_User_Geo__c = 'PRC');
        insert OSOOwner;
        
        User NonOSOOwner = new User(Alias = 'NonOSOO', Email='NonOSOOwner@apttus.com',
                                   EmailEncodingKey='UTF-8', LastName='NonOSO', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = p.Id,
                                   TimeZoneSidKey='America/Los_Angeles', UserName='NonOSOOwner@mail.com', Department='');
        insert NonOSOOwner;
        
        User OSOTOwner = new User(Alias = 'OSOTO', Email='OSOTOwner@apttus.com',
                            EmailEncodingKey='UTF-8', LastName='OTest', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='OSOTOwner@mail.com', Department='OSC');
        insert OSOTOwner;
        User NONOSOTOwner = new User(Alias = 'NOSOTO', Email='NONOSOTOwner@apttus.com',
                          EmailEncodingKey='UTF-8', LastName='ATTest', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='NONOSOTOwner@mail.com');
        insert NONOSOTOwner;
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        
        Account acct = new Account();
        acct.name = 'TestAccountKPI';
        acct.RecordTypeId = recTypeId;
        acct.BillingCountryCode = 'USA';
        acct.BIllingStateCode = 'AL';
        acct.BillingCity = 'Alabama123';
        acct.BillingStreet = 'test123';  
        acct.Core_Sales_Groups__c='Americas Partner Holding';
        acct.Industry='Health and Life Sciences'; 
        acct.Core_Sub_Industry__c='Biotechnology';     
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        system.runAs(OSOOwner){
            Opportunity oppoTM1 = new Opportunity(Name = 'OppoTMHandler1', RecordTypeId = newOppRecTypeId,core_approval_status__c = 'Approved',
                                                      AccountId = acct.Id,Core_Commissionable__c = 'Yes',Core_Date_Submitted_for_Approval__c = System.Date.today()+1,
                                                      StageName = 'Qualify', CloseDate = System.Date.today()+1, Core_Technical_Owner__c=OSOOwner.id);
            
            insert oppoTM1;
            
        }
        
        system.runAs(NonOSOOwner){
            Opportunity oppoTM2 = new Opportunity(Name = 'OppoTMHandler2', RecordTypeId = newOppRecTypeId,core_approval_status__c = 'Approved',
                                                       AccountId = acct.Id,Core_Commissionable__c = 'Yes',Core_Date_Submitted_for_Approval__c = System.Date.today()+1,
                                                       StageName = 'Qualify', CloseDate = System.Date.today()+1, Core_Technical_Owner__c=NonOSOOwner.id);
            
            insert oppoTM2;   
        }
    }
    
    static testmethod void testOppoTM() { 
        List<OpportunityTeamMember> oppTMList = new List<OpportunityTeamMember>();
        Opportunity oppoTM1 = [select id from Opportunity where Name = 'OppoTMHandler1'  limit 1];
        Opportunity oppoTM2 = [select id from Opportunity where Name = 'OppoTMHandler2'  limit 1];
 
        User osoTO = [select id from User where UserName='OSOOwner@mail.com'  limit 1];
        User nonosoTO = [select id from User where UserName='NONOSOTOwner@mail.com'  limit 1];

        OpportunityTeamMember teamMember1 = new OpportunityTeamMember(OpportunityId = oppoTM1.Id, UserId = osoTO.Id,TeamMemberRole = 'Opportunity Owner', Core_OSC_Snapshot__c=1);
        OpportunityTeamMember teamMember2 = new OpportunityTeamMember(OpportunityId = oppoTM1.Id, UserId = nonosoTO.Id,TeamMemberRole = 'Technical Owner', Core_OSC_Snapshot__c=0);
        OpportunityTeamMember teamMember3 = new OpportunityTeamMember(OpportunityId = oppoTM1.Id, UserId = osoTO.Id,TeamMemberRole = 'Technical Owner', Core_OSC_Snapshot__c=1);
        OpportunityTeamMember teamMember4 = new OpportunityTeamMember(OpportunityId = oppoTM2.Id, UserId = nonosoTO.Id,TeamMemberRole = 'Technical Owner',Core_OSC_Snapshot__c=0);
        OpportunityTeamMember teamMember5 = new OpportunityTeamMember(OpportunityId = oppoTM2.Id, UserId = osoTO.Id,TeamMemberRole = 'Technical Owner',Core_OSC_Snapshot__c=1);
        
        oppTMList.add(teamMember1);oppTMList.add(teamMember2);oppTMList.add(teamMember3);oppTMList.add(teamMember4);oppTMList.add(teamMember5);

        // Call the method being tested
        Test.startTest();
        insert oppTMList;
        Test.stopTest();
        
        // Verify the results
        Opportunity updatedOpp = [SELECT Core_Opportunity_Team_Geo_PRC__c FROM Opportunity WHERE Id = :oppoTM1.Id];
        System.assertEquals(true, updatedOpp.Core_Opportunity_Team_Geo_PRC__c);   
    }
    
}