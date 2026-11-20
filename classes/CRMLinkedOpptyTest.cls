@isTest
public class CRMLinkedOpptyTest {
 @testSetup
    static void setupTestData() {
     
 	Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
                
                User adminUser = new User(Alias = 'admin', 
                              Email='adminTest010@intel.com', 
                              EmailEncodingKey='UTF-8',
                              LastName='Testing01',
                              LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', 
                              ProfileId = prf.Id, 
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='adminTest010@intel.com');
                insert adminUser;
         System.RunAs(adminUser){
       
        Core_Opp_Bypass_Validation_Rule__c BypassRule = new Core_Opp_Bypass_Validation_Rule__c();
        BypassRule.Bypass__c = true;
        insert BypassRule;
        Id accDealID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        // Create a new account        
        Account acct = new Account(Name = 'New Test Account1', BillingStreet = '123 Fake St',Industry ='Gaming', Core_Sub_Industry__c   ='eSports',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(), RecordTypeId = accDealID);//Core_CIM_ID__c = '8675309'
        insert acct;
              List<Opportunity> oppList = new List<Opportunity>();
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Id newOppRecTypeId2 = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity100', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_VBS_Potential__c=true);
        
        oppList.add(opp1);
        
        
         Opportunity opp2 = new Opportunity(Name = 'Test Opportunity200', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Created_from_CPQ__c=false);
		oppList.add(opp2);
        Opportunity opp3 = new Opportunity(Name = 'Test Opportunity201', RecordTypeId = newOppRecTypeId,
                                                  AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Created_from_CPQ__c=false);
		oppList.add(opp3);
        insert oppList;
         

        // Create CRM_Linked_Opportunities__c records
       CRM_Linked_Opportunities__c linkedOpp = new CRM_Linked_Opportunities__c(
            CRM_Primary_Opportunity__c = oppList[0].Id, 
            CRM_Linked_Opportunity__c = oppList[1].Id, 
            CRM_Link_Reason__c = 'Design Original (ODM Board) to Design Secondary (OEM System)'
        );
        insert linkedOpp;
      CRM_Linked_Opportunities__c linkedOpp1 = new CRM_Linked_Opportunities__c(
            CRM_Primary_Opportunity__c = oppList[1].Id, 
            CRM_Linked_Opportunity__c = oppList[2].Id, 
            CRM_Link_Reason__c = 'ITE opportunities to Actual deployment'
        );
        //insert linkedOpp1;
           linkedOpp.CRM_Linked_Opportunity__c =  oppList[2].Id;
          update linkedOpp;   
         }
    }

   

    @isTest
    static void testCheckValidation() {
        // Retrieve test data
        List<CRM_Linked_Opportunities__c> linkedOpportunities = [
            SELECT Id, CRM_Primary_Opportunity__c, CRM_Linked_Opportunity__c, CRM_Link_Reason__c 
            FROM CRM_Linked_Opportunities__c
        ];

        // Execute the method to be tested
        Test.startTest();
            CRM_Linked_OpportunityServiceHandler.CheckValidation(linkedOpportunities);
        Test.stopTest();

        // Verify the validation errors
        System.assertEquals(1, linkedOpportunities.size());

    }
}