/**
* Class Name      - DP_EAT_InvocableUtilityTest
* Version         - 1.0
* Function        - Created as a test class for DP_EAT_InvocableUtility
* 
* Developer           Date               Description
* ---------------------------------------------------------------------------------------
* Charu Kaushik       3/30/2022         - Created test class for DP_EAT_InvocableUtility

**/
@isTest(SeeAllData=true)
public class DP_EAT_InvocableUtilityTest 
{
    public static testMethod void runTestsAndLogResult()
    {
        List<String> enqueueParameters = new List<String>();
        List<List<String>> enqueueParams = new List<List<String>>();
        List<String> logParameters = new List<String>();
        List<List<String>> logParams = new List<List<String>>();
        
        DP_EAT_Project_Info__c project = new DP_EAT_Project_Info__c();
        project.Name = 'Dummy Project for test class';
        project.DP_EAT_Prefixes__c = 'Intel_';
        project.DP_EAT_Send_Email__c = false;
        insert project;
        
        DP_EAT_Project_Info__c newProject = [SELECT Id, DP_EAT_Job_Id__c FROM DP_EAT_Project_Info__c WHERE Id=:project.Id LIMIT 1];        
        
        enqueueParameters.add('Enqueue tests');
        enqueueParameters.add(String.valueOf(newProject.Id));      
        enqueueParams.add(enqueueParameters);
            
        Test.startTest();        
        DP_EAT_InvocableUtility.testExecutionActions(enqueueParams); 
        
        List<ApexTestQueueItem> dummyAtqi =[select id, ApexClass.Name, ApexClassId,  Status, ExtendedStatus, ParentJobId, CreatedDate from ApexTestQueueItem where Status='Completed' and ApexClass.Name != 'DP_EAT_InvocableUtilityTest' limit 1];
        Id dummyJobId = dummyAtqi[0].ParentJobId;
        
        newProject.DP_EAT_Job_Id__c = dummyJobId;
        newProject.DP_EAT_Job_Status__c = 'Queued';
        update newProject;
        
        logParameters.add('Log test results');
        logParameters.add(String.valueOf(newProject.Id));      
        logParams.add(logParameters);
        
              
        DP_EAT_InvocableUtility.testExecutionActions(logParams);
     
        Test.stopTest();            
        
    }
}