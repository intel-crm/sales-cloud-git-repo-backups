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
@
isTest
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
        List<Opportunity> lstOpportunity = Core_Test_Utility.createOpportunity(2);
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