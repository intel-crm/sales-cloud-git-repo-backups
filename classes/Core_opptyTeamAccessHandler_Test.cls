/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_opptyTeamAccessHandler_Test
Version     : 1.0 
Created Date: 26th-June-2017
Function    : Test Class for Utility Core_opptyTeamAccessHandler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash             19th-June-2017             Original Version
*****************************************************************************************************************************************************************************************************/
@isTest
public class Core_opptyTeamAccessHandler_Test {
    public static List<Opportunity> opptyList = new List<Opportunity>();
    static void setupData() {
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI() /*,Core_CIM_ID__c = '8675309'*/);
        insert acct;
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                          AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), 
                                          Core_Technical_Owner__c = UserInfo.getUserId(), 
                                          Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', 
                                          Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', 
                                          Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   
                                          Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));
            insert opptyList;
            OpportunityTeamMember oppmem=new OpportunityTeamMember();
            oppmem.OpportunityId=opptylist[0].Id;
            oppmem.TeamMemberRole='Team Member (100%)';
            oppmem.UserId=UserInfo.getUserId();
            insert oppmem;
            
        }       
    }
    
    
    static testMethod void opptyTeamAccessHandler1() {
        //Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        //User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
        PermissionSetAssignment psa = [SELECT Id, PermissionSet.Name,PermissionSetId, AssigneeId from PermissionSetAssignment  where PermissionSet.Name='SalesRepBB' LIMIT 1];
		User usr = [SELECT id, Name, isActive FROM User WHERE Id = :psa.AssigneeId AND isActive = true LIMIT 1];
        List<Core_Trigger_Executions__c> triggExecList = new List<Core_Trigger_Executions__c>();
        triggExecList.add(new Core_Trigger_Executions__c(Name='opptyTeamAccess', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity_Partner', Core_Trigger_Events__c='After Update', Core_Active__c=true, Core_Description__c = 'blah blah'));      
        insert triggExecList;
        Core_Opp_Bypass_Validation_Rule__c bp = new Core_Opp_Bypass_Validation_Rule__c();
        bp.Bypass__c = true;
        bp.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
        insert bp;
        test.startTest();
        setupData();
        Core_Oppty_Team_Access__c oppacc=new Core_Oppty_Team_Access__c();
        oppacc.Approval_Status__c='Submitted';
        oppacc.Opportunity_Name__c=opptyList[0].Id;
        oppacc.Core_ChangeReason__c='Test Record';
        oppacc.Opportunity_Access__c='Read';
        oppacc.Opportunity_Team_Role__c='Team Member (100%)';
        
        insert oppacc;
        oppacc.Approval_Status__c='Approved';
        update oppacc;
        test.stopTest();
        
        Assert.areEqual(true, oppacc.Approval_Status__c=='Approved');
    }
}