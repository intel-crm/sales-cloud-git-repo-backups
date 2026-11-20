/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_OpportunityTeamAccessReq_Cont_Test
Version     : 1.0 
Created Date: 26th-June-2017
Function    : Test Class for Core_OpportunityTeamAccessReq_Controller.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash             19th-June-2017             Original Version
*****************************************************************************************************************************************************************************************************/
@isTest
public class Core_OpportunityTeamAccessReq_Cont_Test {
   Static testmethod void Core_OpportunityTeamAccessReq_Cont() {
       test.startTest();
       //Account acc = new Account(Name = 'Test Account Joe ');
       Id newAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
       Account acc = new Account(Name = 'Test Account Joe', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                  BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                  BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
       insert acc;
       Opportunity opp = new Opportunity();
       opp.AccountId = acc.Id;
       opp.Name = 'Test_Joe_123';
       opp.StageName = 'Qualify';
       opp.CloseDate = date.today();
       opp.Type = 'New Business';
       insert opp;
       Core_Oppty_Team_Access__c oppacc=new Core_Oppty_Team_Access__c();
       oppacc.Approval_Status__c='Submitted';
       oppacc.Opportunity_Name__c=opp.Id;
       oppacc.Core_ChangeReason__c='Test Record';
       oppacc.Opportunity_Access__c='Read';
       oppacc.Opportunity_Team_Role__c='Team Member (100%)';
       ID userid =UserInfo.getUserId();
       ApexPages.currentPage().getParameters().put('id',opp.id);
       ApexPages.currentPage().getParameters().put('usr',userid);
       Core_OpportunityTeamAccessReq_Controller con = new Core_OpportunityTeamAccessReq_Controller();
       con.opptyTeamAccObj=oppacc;  
       con.save();
       test.stopTest();
       //TWC3123-5376: code scan fix
       Assert.areEqual(true, oppacc.id != null);
   }
}