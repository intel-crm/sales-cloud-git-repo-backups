/*
* Test Class Name - DP_EAT_ResultsToNewRelicTest
* Version         - 1.0
* Function        - Created to call New relic api to send result of IPA project from Project Info in a New relic
*        
*
* Developer           Date               Description
* --------------------------------------------------------------------------------------------------------------------
* Swati Paraste       5/20/2022        -Test class created for DP_EAT_ResultsToNewRelic class
*                                      -Created as for the requirement in Story Bhoomi/TWC4471-173 : [KIIT] - Build sample new relic dashboard with EAT, API's, automated test execution results                                        https://jira.devtools.intel.com/browse/TWC4471-173
*                                      https://jira.devtools.intel.com/browse/TWC4471-173
**/
@isTest
public class DP_EAT_ResultsToNewRelic_Test {
    public static testMethod void sendResultTest() {
        DP_EAT_Project_Info__c projectInfo = new DP_EAT_Project_Info__c();
        projectInfo.Name='IPA';
        projectInfo.DP_EAT_Number_of_Compilation_Failures__c=2;
        projectInfo.DP_EAT_Number_of_last_ran_Test_Methods__c=10;
        projectInfo.DP_EAT_Number_of_last_ran_Tests_Failed__c=1;
        projectInfo.DP_EAT_Number_of_last_ran_Tests_Passed__c=9;
        projectInfo.DP_EAT_Send_Email__c = TRUE;
        projectInfo.DP_EAT_Email_Addresses__c='abc@intel.com';
        projectInfo.DP_EAT_Prefixes__c='Abc';        
        insert projectInfo;
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new DP_EAT_ResultsToNewRelicMock());        
       
        DP_EAT_ResultsToNewRelic.sendResultToNewRelic();
        
        Test.stopTest();
    }
    // Implement a mock http response generator 
    public class DP_EAT_ResultsToNewRelicMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"application": "CORP","operations": [{"op": "UserEntitlement","requestedBy": "12054651","justification": "test justification","value": [{"value": "12054651"}]}]}');
            response.setStatusCode(200);
            return response; 
        }
    }
}