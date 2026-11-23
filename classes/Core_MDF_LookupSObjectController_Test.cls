/**************************************************************************************
Apex Class Name:  Core_MDF_LookupSObjectController_Test 
Version     : 1.0 
Created Date: 06 11 2018
Function    : Test class for the Core_MDF_LookupSObjectController Class 
Author      : Anjali Haryani
*************************************************************************************/

@isTest(SeeAllData=false) 
private class Core_MDF_LookupSObjectController_Test {
    private static final String SEARCH_STRING = 'Client Co-Marketing Fund';
    private static final String SOBJECT_API_NAME = 'ChannelProgram';
    private static final String FIELDS_TO_RETURN = 'id,Name,Core_MDF_Technical_Program_Name__c';
    private static final String WHERE_CLAUSE = '';
    
    @testSetup
    private static void createTestData(){
        // Insert Channel program
		ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
    }
    
    public static testmethod void testLookup(){
        List<ChannelProgram> cpList = [Select id,Name from ChannelProgram where Name = 'Client Co-Marketing Fund'];
        Test.startTest();
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = cpList[0].Id;        
        Test.setFixedSearchResults(fixedSearchResults);

        List<Core_MDF_LookupSObjectController.Result> results = Core_MDF_LookupSObjectController.lookup(SEARCH_STRING,SOBJECT_API_NAME,FIELDS_TO_RETURN,WHERE_CLAUSE);
        Test.stopTest();
        
        //Assertions
        if(!results.isEmpty()){
            System.assert(results != null);
            System.assertEquals(results[0].objectId, cpList[0].Id);
        }
    }
}