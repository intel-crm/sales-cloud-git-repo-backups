/****************************************************************************************************
Apex Class Name : SWS_SendEmailController
Version         : 1.0 
Created Date    : 15/4/2024
Function        : This Class is used to send email for all credit request email.
Test Class      : SWS_SendEmailControllerTest
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Naveen Muthuramalingam     15/4/2024                Created
*****************************************************************************************************/
public without sharing class SWS_SendEmailController {

    public static final String LOG_ENTRY_ORIGIN   = 'SWS_SendEmailController';
    public static final String LOG_ENTRY_SCOPE    = 'Error while sending email';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    
    public static List<SWS_Cloud_Credit_Request__c> requestBatchList = new List<SWS_Cloud_Credit_Request__c>();
    public static List<Messaging.EmailFileAttachment> attachment = new List<Messaging.EmailFileAttachment>();
    public static OrgWideEmailAddress orgWideEmailAdd;
    public static Boolean bypassUpdate = false;
    public static Boolean retryUpdateFailed = false;

    static{
        orgWideEmailAdd = [SELECT Id, Address,DisplayName FROM OrgWideEmailAddress WHERE Address='wsm-postmaster@intel.com'];
    }

    /************************************************************************************************************
    *Method Name : sendEmailFromFLow
    *Created Date: 15/4/2024
    *Author: Naveen Muthuramalingam
    *Description : Pass Record Id from flow to this method and send email from this method.
    *User Story: TWC5945-78
    *@index1 : String recordId
    *@index2 : String emailTemplate
    ************************************************************************************************************/
    @InvocableMethod(label ='Send Email')
    public static void sendEmailFromFLow(List<List<String>> details) {
        if(details.isEmpty() && details.size() < 2){
            return;
        }
        List<String> detailsFromFlow =details[0];
        String recordId = detailsFromFlow.size() > 1 ? detailsFromFlow[0] : '';
        String emailTemplate = detailsFromFlow.size() <= 2 ? detailsFromFlow[1] : '';
        if(!String.isBlank(recordId) && !String.isBlank(emailTemplate)){
            sendEmail(recordId,emailTemplate);
        }
    }
    
    /************************************************************************************************************
    *Method Name : sendEmail
    *Created Date: 15/4/2024
    *Author: Naveen Muthuramalingam
    *User Story: TWC5945-78
    *Description : Method to send email from Apex Class.
    ************************************************************************************************************/
    public static void sendEmail(String recordId, String emailTemplate){
        try{
            EmailTemplate template = getEmailTemplate(emailTemplate);
            SWS_Cloud_Credit_Request__c request = String.isBlank(recordId) ? null : SWS_Utility.getRecordDetails(recordId);            
            List<SWS_Cloud_Credit_Request__c> reqList = request != null ? new List<SWS_Cloud_Credit_Request__c>{request} : requestBatchList;
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(SWS_Cloud_Credit_Request__c req : reqList){
                if(req != null && template !=null){
                    mails.add(getRenderEmailContent(template.Id,req));   
                }
            }
            if(mails != null){
                Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
                processEmailResult(result);
            }
        }catch(Exception e){
            SWS_Utility.createCoreLogEntry(LOG_ENTRY_ORIGIN,'sendEmail',LOG_ENTRY_SCOPE,'',e,'SWS_Cloud_Credit_Request__c',LOG_ENTRY_SEVERITY,recordId);
        }
    }

    /************************************************************************************************************
    *Method Name : processEmailResult
    *Created Date: 15/4/2024
    *Author: Bishal Singh
    *Description : Process email results if error occurs.
    ************************************************************************************************************/
    public static void processEmailResult(Messaging.SendEmailResult[] results){
        String msg = '';
        for (Integer i = 0; i < results.size(); i++) {
            Messaging.SendEmailResult sr = results[i];
            if (!sr.isSuccess()) {
                msg += getErrorAsString(sr.getErrors());
            }
        }

        if(String.isNotBlank(msg)){
            SWS_Utility.createCoreLogEntry(LOG_ENTRY_ORIGIN,'sendEmail','Error while sending email',msg,null,'SWS_Cloud_Credit_Request__c',LOG_ENTRY_SEVERITY,'');
        }
    }

    /************************************************************************************************************
    *Method Name : getErrorAsString
    *Created Date: 15/4/2024
    *Author: Bishal Singh
    *Description : Get the list of all error and join it in single string.
    ************************************************************************************************************/
    public static String getErrorAsString(Messaging.SendEmailError[] errors) {
        List<String> errorList = new List<String>();
        for (Messaging.SendEmailError error : errors) {
            if (error.getMessage() != null) {
                errorList.add(error.getMessage());
            }
        }
        return String.join(errorList, ';');
    }

    /************************************************************************************************************
    *Method Name : getRenderEmailContent
    *Created Date: 15/4/2024
    *Author: Bishal Singh
    *Description : Render the email content for requested email template.
    ************************************************************************************************************/
    public static Messaging.SingleEmailMessage getRenderEmailContent(String templateId, SWS_Cloud_Credit_Request__c req){
        Messaging.SingleEmailMessage sendEmail = Messaging.renderStoredEmailTemplate(templateId, null, req?.Id);
        sendEmail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
        if(!bypassUpdate && !retryUpdateFailed){
            setEmailRecipient(sendEmail,req);
        }else{
            sendEmail.setToAddresses(retryUpdateFailed ? new String[]{SWS_Core_CRM_Labels__c.getValues('ITTeamEmail') != null ? SWS_Core_CRM_Labels__c.getValues('ITTeamEmail').SWS_Value__c : ''} : new String[]{UserInfo.getUserId()});
            sendEmail.setSubject(sendEmail.getSubject());
            if(!attachment.isEmpty()){
                sendEmail.setFileAttachments(attachment);
            }
        }        
        return sendEmail;
    }
    
    /************************************************************************************************************
    *Method Name : getEmailTemplate
    *Created Date: 19/07/2024
    *Author: Bishal Singh
    *Description : Get email template.
    ************************************************************************************************************/
    public static EmailTemplate getEmailTemplate(String emailTemplate){
        return [SELECT Id,Subject,HtmlValue,Markup,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName =:emailTemplate WITH SECURITY_ENFORCED];
    }

    /************************************************************************************************************
    *Method Name : setEmailRecipient
    *Created Date: 07/10/2024
    *Author: Bishal Singh
    *Description : Set Email Recipient
    ************************************************************************************************************/
    public static void setEmailRecipient(Messaging.SingleEmailMessage sendEmail, SWS_Cloud_Credit_Request__c req){
        sendEmail.setSaveAsActivity(true);
        String toEmail = (req.CreatedById == Label.PRM_IPARegistration_Integration_UserId && req.SWS_Request_Status__c == 'Awaiting_Submission') || req.SWS_Request_Status__c == 'Rejected' ? req.SWS_Submitter_Email__c : req.SWS_Email__c;
        sendEmail.setToAddresses(new String[]{toEmail});
        if (String.isNotBlank(req.SWS_Submitter_Email__c) && !req.SWS_Submitter_Requster_Email__c && toEmail != req.SWS_Submitter_Email__c && req.SWS_Request_Status__c != 'Rejected') {
            sendEmail.setCcAddresses(new String[]{req.SWS_Submitter_Email__c});
        }
    }
}