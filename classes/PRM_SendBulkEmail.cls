public class PRM_SendBulkEmail implements Finalizer{
    public List<PRM_Account_Contact_Relationship__c> conACR;
    public Integer success, failures;
    
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_SendBulkEmail';
    public static final String LOG_ENTRY_PROJECT  = 'Bulk Data Upload';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_SendBulkEmail';
    public static final String LOG_ENTRY_SEVERITY = 'error';
    
    public PRM_SendBulkEmail(List<PRM_Account_Contact_Relationship__c> ContactACRs, Integer successRecords, Integer failureRecords ){
        conACR = ContactACRs;
        success = successRecords;
		failures = failureRecords;
    }
    public void execute(FinalizerContext ctx){
        try{
            if(ctx.getResult() == ParentJobResult.SUCCESS){
                Integer failedContactCount = checkBulkAGSFailures(conACR).size();
                if(success != 0){
                    System.debug('PRM_SendBulkEmailsuccess'+success);
                    System.debug('PRM_SendBulkEmailfailures'+failures);
                    System.debug('PRM_SendBulkEmailconACR'+conACR);
                    String emailBody = emailBodyMessage(success, failures, failedContactCount);
                    if(emailBody != null){
                        sendMail('BATCH_JOB_NOTIFICATION', emailBody ,'Bulk Data Upload completed Successfully');
                    }
                }
                System.debug('Successful');
            }
        }
        catch(Exception e){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);
        }
    }
    
    //Check AGS Failed ACRs
    public static Set<Id> checkBulkAGSFailures(List<PRM_Account_Contact_Relationship__c> ContactACRs){
        Set<Id> AGSFailedConCount = new Set<Id>(); 
        for(PRM_Account_Contact_Relationship__c acr : ContactACRs){
            if(acr.PRM_AGS_Identity_Creation_Fail__c == true){
                AGSFailedConCount.add(acr.PRM_Contact_Id__c);//adding contact IDs for failed ACRs
            }
        }
        
        return AGSFailedConCount;
    }
    //Email Body Message
    public static String emailBodyMessage(Integer successRecords, Integer failureRecords, Integer failedContacts){
        List<Report> AGSFailedreport = [Select id, DeveloperName from Report where DeveloperName =: System.Label.PRM_Bulk_AGS_Identity_Failed_Report_Name LIMIT 1];
        String AGSFailedbulkreportid = '';
        if(AGSFailedreport.size() > 0){
            AGSFailedbulkreportid = String.valueOf(AGSFailedreport[0].id);
        }
        String baseURLAGSFailed = System.URL.getSalesforceBaseUrl().toExternalForm();
        String urlAGSFailed = '/lightning/r/Report/' + AGSFailedbulkreportid + '/view'; 
        String AGSFailedreportLink = baseURLAGSFailed+urlAGSFailed;
        String bodyFailedACRs = 'AGS identity creation failed for '+failedContacts+ ' Contacts.<br>' + 'Click '+ '<a href = "'+ AGSFailedreportLink +'"> here </a>' +'to view all AGS Failed Bulk Upload Contact(s).<br>';//AGS Failed ACRs addition to Body String
        
        List<Report> bulkReport = [Select id, DeveloperName from Report where DeveloperName =: System.Label.PRM_Bulk_Report LIMIT 1];
        String bulkreportid = '';
        if(bulkReport.size() > 0){
            bulkreportid = String.valueOf(bulkReport[0].id);
        }
        String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        String url = '/lightning/r/Report/' + bulkreportid + '/view'; 
        String reportLink = baseURL+url;
        String body1 = '<br>The Bulk Invite request is complete with '+ successRecords +' success and '+ failureRecords +' failures. \n\n<br><br>';
        if(failedContacts != 0){
            body1 += bodyFailedACRs +'<br>';//If there are any AGS Failed ACRs adding them to Email Body else not appending ACRs and AGS Failure message
        }
        STring body3 = 'Click '+ '<a href = "'+ reportLink +'"> here </a>' +'to view the bulk upload report.';
        String body =  body1+body3;
        return body;
    }
    
    //Get Email Addresses    
    public List<String> getMailAddresses(){
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>(); 
        
        Group gp = [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group where developername ='PRM_Batch_Jobs_Email_Notification'];
        for (GroupMember gm : gp.GroupMembers) {
            idList.add(gm.UserOrGroupId);
        }
        List<User> userList = [SELECT Email FROM User WHERE Id IN :idList];
        for(User u : userList) {
            mailToAddresses.add(u.email);
        } 
        return mailToAddresses;
    }
    
    
    //Send Email    
    public void sendMail(String templateName, String jobStatusMessage, String jobSubject) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];        
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        mail.setToAddresses(getMailAddresses());     
        String emailBody = [select HtmlValue from EmailTemplate where DeveloperName =:templateName limit 1].HtmlValue;
        emailBody = emailBody.replace('{!job_subject}',jobSubject);//'Batch Execution started'
        emailBody= emailBody.replace('{!JOB_MESSAGE}',jobStatusMessage);// 'Batch Execution is progress for Bulk Data Upload Batch'
        System.debug('Email Body -->'+emailBody);
        mail.setSubject('Bulk Data Upload completed Successfully');
        mail.setHtmlBody(emailBody);               
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}