/**************************************************************************************
Apex Class Name:  Core_SearchUsersOpportunityRecords_Test
Version     : 1.0 
Created Date: 10 DEC 2014
Function    : Test Class for Core_SearchUsersOpportunityRecord class.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             10/12/2014              Original Version
* Kunal Mehta              10/12/2014              Original Version
*************************************************************************************/
@isTest
public class Core_SearchUsersOpportunityRecords_Test {

    /*
     * Method name  : SearchUsersOpportunityRecordsTest
     * Description  : Method to fetch records for which user is having access
     * Return Type  : None
     * Parameter    : None
     */
    static testMethod void SearchUsersOpportunityRecordsTest() {

        // Fetching a Sales Rep User
        List<User> salesUser = new List<User>();
        salesUser = [SELECT Id, Name FROM User where isActive = TRUE AND Profile.Name = : System.Label.Core_Sales_User_Profile LIMIT 1];

        // Populating and inserting opportunity
       // List<Opportunity> lstOpportunity = Core_Test_Utility.createOpportunity(2);
       // insert lstOpportunity;
        
         Id recAccountTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
        Account testAccount =   new Account(Name='Test SMG SSR Account', RecordTypeId=recAccountTypeId,
                                            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA',Core_Sales_Groups__c='CCG Sales Group');
        insert testAccount;      
        List<Account> testAccounts = [select id from Account where Id =: testAccount.Id];
        system.assertEquals(1, testAccounts.size());
        
        
        // create Opty Records
        List<Opportunity> lstOpportunity=new List<Opportunity>();
        Id recOpportunityTypeId = [select Id from RecordType where DeveloperName = 'Core_Opportunity' limit 1][0].Id;
        Opportunity testOpportunity = new Opportunity(Name='Test SSG Support Request with Account',
                                                      AccountId=testAccount.Id, StageName='Qualifying', RecordTypeId=recOpportunityTypeId,
                                                      CloseDate=System.Date.today().addYears(1));
        lstOpportunity.add(testOpportunity);
        Opportunity testOpportunity1 = new Opportunity(Name='Test SSG Support Request with Accoun1t',
                                                      AccountId=testAccount.Id, StageName='Qualifying', RecordTypeId=recOpportunityTypeId,
                                                      CloseDate=System.Date.today().addYears(1));
        lstOpportunity.add(testOpportunity1);
        insert lstOpportunity;
        
        Set<Id> oppIds = new Set<Id>();
        
        for (Opportunity opp : lstOpportunity)
            oppIds.add(opp.Id);
        

        Test.startTest();

            // Building query for opportunity
            String query = 'SELECT Id,Name From Opportunity';
    
            // Fetching the records for which user is having access
            List <Opportunity> lstFetchOpportunity = Core_SearchUsersOpportunityRecords.doQuery(query, oppIds);
    
            // Asserting current user is having access to records created
            System.assertEquals(lstFetchOpportunity.size(), 2);
    
            if (!salesUser.isEmpty()) {
                System.runAs(salesUser.get(0)) {
                    // Building query for opportunity
                    String querySalesUser = 'SELECT Id,Name From Opportunity';
    
                    // Fetching the records for which user is having access
                    List <Opportunity> lstFetchOpportunityForSalesUser = Core_SearchUsersOpportunityRecords.doQuery(query, new SET<ID>());
    
                    // Asserting salesUser doesn't have access to records created by System Admin
                    System.assertEquals(lstFetchOpportunityForSalesUser.size(), 0);
                }
            }
        Test.stopTest();
    }
}