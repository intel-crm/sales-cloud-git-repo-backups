/**
* Class Name      - DP_EAT_ResultsToNewRelic
* Test Class Name - DP_EAT_ResultsToNewRelicTest
* Version         - 1.0
* Function        - Created to call New relic api to send IPA project results from Project Info to New relic
*        
*
* Developer           Date               Description
* --------------------------------------------------------------------------------------------------------------------
* Swati Paraste       5/20/2022        -Created as for the requirement in Story Bhoomi/TWC4471-173 : [KIIT] - Build sample new relic dashboard with EAT, API's, automated test execution results                                        https://jira.devtools.intel.com/browse/TWC4471-173
*                                      https://jira.devtools.intel.com/browse/TWC4471-173
**/

public class DP_EAT_ResultsToNewRelic {
    public static void sendResultToNewRelic(){
        
        DP_EAT_Project_Info__c IPAproject = [select Name, DP_EAT_Number_of_last_ran_Test_Methods__c, DP_EAT_Number_of_last_ran_Tests_Passed__c, DP_EAT_Number_of_last_ran_Tests_Failed__c, DP_EAT_Number_of_Compilation_Failures__c  from DP_EAT_Project_Info__c where Name = 'IPA' limit 1];
        system.debug('IPAProject...'+IPAproject);
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();      
    	gen.writeStringField('eventType', 'EAT');
    	gen.writeStringField('projectName',IPAproject.Name);
    	gen.writeNumberField('testMethods',IPAproject.DP_EAT_Number_of_last_ran_Test_Methods__c);
    	gen.writeNumberField('testsPassed',IPAproject.DP_EAT_Number_of_last_ran_Tests_Passed__c);
    	gen.writeNumberField('testsFailed',IPAproject.DP_EAT_Number_of_last_ran_Tests_Failed__c);
    	gen.writeNumberField('testsCompileFailed',IPAproject.DP_EAT_Number_of_Compilation_Failures__c);
    	gen.writeEndObject();
  
        String jsonS = gen.getAsString();
        System.debug('jsonMaterials'+jsonS);
        
        //Use POST method,add the Json Body and set the endpoint
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://insights-collector.newrelic.com/v1/accounts/2927413/events');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');  
        req.setHeader('X-License-Key', '9b189775a28813d91ddfede4b9c1d58ecf00NRAL'); 
        req.setBody(jsonS);
        
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
}