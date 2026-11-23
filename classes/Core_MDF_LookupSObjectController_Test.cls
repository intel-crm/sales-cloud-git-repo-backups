/**************************************************************************************
Apex Class Name:  Core_MDF_LookupSObjectController_Test 
Version     : 1.0 
Created Date: 06 11 2018
Function    : Test class for the Core_MDF_LookupSObjectController Class 
Author      : Anjali Haryani
*************************************************************************************/

@isTest(SeeAllData=false) 
private class Core_MDF_LookupSObjectController_Test {
    private static final String SEARCH_STRING = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
    private static final String SOBJECT_API_NAME = 'ChannelProgram';
    private static final String FIELDS_TO_RETURN = 'id,Name,Core_MDF_Technical_Program_Name__c';
    private static final String WHERE_CLAUSE = 'Name LIKE @quote;%Client%@quote;';
    
    @testSetup
    private static void createTestData(){
        // Insert Channel program
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        Database.insert(usr);
    }
    
    public static testmethod void testLookup(){
        List<ChannelProgram> cpList = [Select id,Name from ChannelProgram where Name =:Core_MDF_CCP_ConstantClass.CCF_PROGRAM LIMIT 1];
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Test.startTest();
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = cpList[0].Id; 
        Test.setFixedSearchResults(fixedSearchResults);
        system.runas(usr){
            List<Core_MDF_LookupSObjectController.Result> results = Core_MDF_LookupSObjectController.lookup(SEARCH_STRING,SOBJECT_API_NAME,FIELDS_TO_RETURN,WHERE_CLAUSE);  
            //Assertions
            if(!results.isEmpty()){
                System.assert(results != null);
                System.assertEquals(results[0].objectId, cpList[0].Id);
            }
        }
        Test.stopTest();
    }
}