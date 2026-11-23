/**
* Class Name      - DP_EAT_InvocableUtility
* Version         - 1.0
* Function        - Created to Execute Selected Test Classes on Demand
* 
* Developer           Date               Description
* ---------------------------------------------------------------------------------------
* Charu Kaushik       3/30/2022         Added invocable method to Enqueue test runs and Log the Test Results in 
Custom Object 'Project Test Run Results'                                  

**/
public class DP_EAT_InvocableUtility 
{
    @invocablemethod(Label='Execute Project Test Classes')
    public static void testExecutionActions(List<List<String>> params)
    {
        String action = params[0][0]; //action can be 'Enqueue tests' OR 'Log test results'
        Id pId = Id.valueOf(params[0][1]);
        
        if(action == 'Enqueue tests')
        {
            String classNameFormats = '';
            DP_EAT_Project_Info__c project = [SELECT Id, Name,  DP_EAT_Job_Id__c, DP_EAT_Job_Status__c, DP_EAT_Prefixes__c FROM DP_EAT_Project_Info__c WHERE Id =:pId LIMIT 1];
		    String prefixes = project.DP_EAT_Prefixes__c;  
            List<String> qClause = new List<String>();
            ApexClass[] testClasses = new List<ApexClass>();
            //DP_EAT_Project_Test_Classes__c newPtc = new DP_EAT_Project_Test_Classes__c();
            DP_EAT_Project_Test_Classes__c[] ptcListToUpsert = new List<DP_EAT_Project_Test_Classes__c>();
            DP_EAT_Project_Test_Classes__c[] ptcList = new List<DP_EAT_Project_Test_Classes__c>();
           
                        
            if(project.DP_EAT_Job_Status__c != 'Queued')
            {
                List<String> prefixList = new List<String>(prefixes.split(','));
                system.debug('************ prefixList:- '+ prefixList);
                for(String p : prefixList)
                {
                    if(p != null && String.isNotBlank(p) && String.isNotEmpty(p))
                    {
                        //classNameFormats = classNameFormats + 'Name LIKE \'' + p + '%Test\' or';
                        qClause.add('Name LIKE \'' + p + '%Test\'');
                    }
                    
                }
                
                //classNameFormats = classNameFormats.left(classNameFormats.length()-3);
                if (!qClause.isEmpty()) 
                {
                    classNameFormats = string.join(qClause, 'or ');
                }
                
                String query = 'SELECT Id, Name FROM ApexClass WHERE '+ classNameFormats;
                testClasses = Database.query(query);
                
                if (testClasses.size() > 0)
                {
                    for (ApexClass cls : testClasses)
                    {
                        ptcListToUpsert.add(new DP_EAT_Project_Test_Classes__c(DP_EAT_Project_Name__c = pId ,Name = cls.Name, DP_EAT_Class_Id__c = String.valueOf(cls.Id), DP_EAT_Compound_Key_Text__c = cls.Name+'_'+pId));
                    }
                }
                
                upsert ptcListToUpsert DP_EAT_Compound_Key_Text__c ;
                
                ptcList = [select id, Name, DP_EAT_Class_Id__c from DP_EAT_Project_Test_Classes__c where DP_EAT_Project_Name__c =:pId AND DP_EAT_Exclude_test_class_for_test_runs__c = False];
				
                if (ptcList.size() > 0)
                {
                    ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
                    for (DP_EAT_Project_Test_Classes__c ptc : ptcList)
                    {
                        queueItems.add(new ApexTestQueueItem(ApexClassId=Id.valueOf(ptc.DP_EAT_Class_Id__c)));
                    }
                    if(!Test.isRunningTest())
                    {
                        insert queueItems;
                        system.debug('Test Runs Enqueued');
                        // Get the job ID of the first queue item returned.
                        ApexTestQueueItem item = [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id=:queueItems[0].Id LIMIT 1];
                        project.DP_EAT_Job_Id__c = item.parentjobid;
                        project.DP_EAT_Job_Status__c = 'Queued';
              			update project;
              			//apexJobIdList.add(item.parentjobid);
               
                    }
                    
                
                }
            }
        }
        
        else if(action == 'Log test results')
        {
            DP_EAT_Project_Info__c project = [SELECT Id, Name,  DP_EAT_Job_Id__c, DP_EAT_Job_Status__c, DP_EAT_Number_of_Compilation_Failures__c, DP_EAT_Number_of_last_ran_Test_Classes__c, DP_EAT_Number_of_last_ran_Test_Methods__c, DP_EAT_Number_of_last_ran_Tests_Failed__c, DP_EAT_Number_of_last_ran_Tests_Passed__c FROM DP_EAT_Project_Info__c WHERE Id = :pId LIMIT 1];
            Id jobId = Id.valueOf(project.DP_EAT_Job_Id__c);
            DP_EAT_Project_Test_Run_Results__c[] logs = new list<DP_EAT_Project_Test_Run_Results__c>();
            
            if(project.DP_EAT_Job_Status__c == 'Queued')
            {
            ApexTestResult[] results = 
                [SELECT Outcome, ApexClass.Name, MethodName, Message, StackTrace 
                 FROM ApexTestResult 
                 WHERE AsyncApexJobId=:jobId];
            for (ApexTestResult atr : results) {
                DP_EAT_Project_Test_Run_Results__c log = new DP_EAT_Project_Test_Run_Results__c();
                log.DP_EAT_Project_Name__c = pId;
                log.DP_EAT_Apex_test_class__c = atr.ApexClass.Name;
                log.DP_EAT_Apex_test_method__c = atr.MethodName;
                log.DP_EAT_Status__c = atr.Outcome;
                log.DP_EAT_Job_Id__c = jobId;
                if (atr.Outcome != 'Pass')
                {
                    log.DP_EAT_Error_Message__c = atr.Message + ' at ' + atr.StackTrace;
                }
                logs.add(log);
                
            }
            insert logs;
            
            AggregateResult[] passResults = [select COUNT(id) pCount from DP_EAT_Project_Test_Run_Results__c where DP_EAT_Job_Id__c = :jobId and DP_EAT_Status__c = 'Pass'];            
            project.DP_EAT_Number_of_last_ran_Tests_Passed__c = ((Decimal)passResults[0].get('pCount')).intValue();
            
            AggregateResult[] failResults = [select COUNT(id) fCount from DP_EAT_Project_Test_Run_Results__c where DP_EAT_Job_Id__c = :jobId and DP_EAT_Status__c = 'Fail'];            
            project.DP_EAT_Number_of_last_ran_Tests_Failed__c = ((Decimal)failResults[0].get('fCount')).intValue();

			AggregateResult[] compileFailResults = [select COUNT(id) cfCount from DP_EAT_Project_Test_Run_Results__c where DP_EAT_Job_Id__c = :jobId and DP_EAT_Status__c = 'CompileFail'];            
            project.DP_EAT_Number_of_Compilation_Failures__c = ((Decimal)compileFailResults[0].get('cfCount')).intValue();            
            
            project.DP_EAT_Number_of_last_ran_Test_Methods__c = logs.size();
            project.DP_EAT_Job_Status__c = 'Completed';
            update project;
            system.debug('Test Result Logs inserted');
        }
        }
        
        //return null;
    }
}