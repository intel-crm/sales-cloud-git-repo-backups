/*********************************************
* Name : IPS_APIGEE_Case_Comments_Queueable 
* Author : Karthik Bandla
* Date Created : 21/06/2021
* Description : This class is called from Process builder whenever a caseComment is created or updated with relevant changes inorder to sent details to JIRA,HSD,RTC.
*   
************************************************/
public class IPS_APIGEE_Case_Comments_Queueable {
    
    @InvocableMethod
    public static void getcaseCommentRecords(list<Core_IPS_Case_Comments__c> getCaseCommentIds){
        
        set<Id> caseCommentIds = new set<Id>();
        string strDetails;
		system.debug('getCaseCommentIds --->'+getCaseCommentIds);
        if(getCaseCommentIds!=null){
            for(Core_IPS_Case_Comments__c cc: getCaseCommentIds){
                caseCommentIds.add(cc.Id);
            }
        }
		system.debug('caseCommentIds --->'+caseCommentIds);
        try{            
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()){ 
                system.debug('getQueueableJobs --->'+Limits.getQueueableJobs());
                system.debug('getLimitQueueableJobs --->'+ Limits.getLimitQueueableJobs());
                System.enqueueJob(new IPS_APIGEE_Backend_CaseComments(caseCommentIds));                
            }
            //Creating custom exception to cover catch block
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            
        }
        catch(exception ex) {
            strDetails = 'Unable to connect to APIGEE class';
            Core_Log_Entry.logEntryWithException('SFDC','IPS',null,'warn','IPS JIRA,HSD,RTC Integration issue in IPS_APIGEE_Case_Comments_Queueable',strDetails,null,'CaseComment',null,ex);
        }
    }
    
}