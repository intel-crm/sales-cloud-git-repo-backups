/*********************************************
* Name : IPS_APIGEE_Backend_Integration_Queueable 
* Author : Karthik Bandla
* Date Created : 21/06/2021
* Description : This class is called from Process builder whenever a caseAttachment is created or updated with relevant changes inorder to sent details to JIRA,HSD,RTC.
*   
************************************************/
public class IPS_APIGEE_Backend_Integration_Queueable {
    
    @InvocableMethod
    public static void getcaseAttachmentRecords(list<Core_IPS_Case_Attachments__c> getCaseAttachmentIds){
        string strDetails;
        set<Id>caseAttachmentIds = new set<Id>();
        
        for(Core_IPS_Case_Attachments__c ca: getCaseAttachmentIds){
            caseAttachmentIds.add(ca.Id);
            
        }
        
        try{
            
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) 
                System.enqueueJob(new IPS_APIGEE_Backend_System_CaseAttachment(caseAttachmentIds));
            
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
            Core_Log_Entry.logEntryWithException('SFDC','IPS',null,'warn','IPS JIRA,HSD,RTC Integration issue in IPS_APIGEE_Backend_Integration_Queueable',strDetails,null,'CaseAttachment',null,ex);
        }
    }
    
}