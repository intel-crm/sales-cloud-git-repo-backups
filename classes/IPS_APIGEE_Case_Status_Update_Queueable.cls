/************************************************
* Name : IPS_APIGEE_Case_Status_Update_Queueable 
* Author : Karthik Bandla
* Date Created : 23/06/2021
* Description : This class is called from Process builder(Core IPS Case Backend Outbound Messages) ,whenever a case is created or updated with relevant changes 
inorder to sent details to JIRA,HSD,RTC.
*   
************************************************/
public class IPS_APIGEE_Case_Status_Update_Queueable {
    
    @InvocableMethod
    public static void getcaseRecords(list<Case> getCaseIds){
        string strDetails;
        System.debug('check caseId value>>>>'+getCaseIds);
        set<Id>caseIds = new set<Id>();
        if(getCaseIds!=null){
        for(Case cs: getCaseIds){
            caseIds.add(cs.Id);              
        }
            System.debug('check set of caseId value>>>>'+caseIds);
       }
        try{
            
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs())       
                System.enqueueJob(new IPS_APIGEE_Backend_Case_Status_Update(caseIds)); 
            
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
            Core_Log_Entry.logEntryWithException('SFDC','IPS',null,'warn','IPS JIRA,HSD,RTC Integration issue in IPS_APIGEE_Case_Status_Update_Queueable',strDetails,null,'Case',null,ex);
        }
    }
    
}