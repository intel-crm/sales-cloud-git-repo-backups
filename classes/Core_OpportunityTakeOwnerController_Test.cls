@isTest
public class Core_OpportunityTakeOwnerController_Test {


     static testMethod void testMethod1(){
     Account acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', /*Core_CIM_ID__c = '8675309',*/Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(), Industry = 'Agriculture' , Core_Sub_Industry__c ='Animal Production');
        insert acct;
        
        // Create a new opportunity using the account created above
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppo = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, 
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today());
        insert oppo;
        
         Test.startTest();
         Core_OpportunityTakeOwnerController.ChangeOppoOwner(oppo.id);
         Test.stopTest();
         system.assertEquals(null,oppo.ownerId);
        
     }
}