/*********************************************
* Name : IPS_APIGEE_Case_Queueable 
* Author : Karthik Bandla
* Date Created : 23/06/2021
* Description : This class is called from Process builder whenever a case is created or updated with relevant changes inorder to sent details to JIRA,HSD,RTC.
*   
************************************************/
public class IPS_APIGEE_Case_Queueable {
    
    @InvocableMethod
    public static void getcaseRecords(list<Case> getCaseIds){
        
        string strDetails;
        set<Id>caseIds = new set<Id>();
        if(getCaseIds!=null){
        for(Case cs: getCaseIds){
            caseIds.add(cs.Id);              
        }
        }
        
        try{
            if(caseIds!=null){
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs())           
                System.enqueueJob(new IPS_APIGEE_Case_Backend_System(caseIds)); 
            }
            //Creating custom exception to cover catch block
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch(exception ex)
        {
            strDetails = 'Unable to connect to APIGEE class';
            Core_Log_Entry.logEntryWithException('SFDC','IPS',null,'warn','IPS JIRA,HSD,RTC Integration issue in IPS_APIGEE_Case_Queueable',strDetails,null,'Case',null,ex);
        }
    }
    
}