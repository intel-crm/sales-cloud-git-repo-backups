/***************************************************************************************************
* Apex Class Name: Core_EmailUtil 
* Version     : 1.0 
* Created Date: 15th Nov Sept 2015
* Function    : Generic Email Utility
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     11/15/2015              Orig.Version http://developer.force.com/cookbook/recipe/email-utility-class
* Malhotra, Abhimanyu S     11/18/2015              Add Org-Wide email processing and AllorNone processing
****************************************************************************************************/
public class Core_EmailUtil {
/*===================================
Default settings for email content
======================================= */
    // defaults for email content  
    private String subject = '';
    private String htmlBody = ''; 
    private String plainTextBody = '';
    private Boolean useSignature = false;
    private Boolean SaveAsActivity = false;
    private List<Messaging.EmailFileAttachment> fileAttachments = null;
    // Default replyTo is current user's email address
    // using a static to save this result across multiple email constructions.
    private static User currentUser {
        get {
            if (currentUser == null)
                currentUser = [Select email from User where username = :UserInfo.getUserName() limit 1];
            return currentUser;
        } set;
    }
    private String replyTo = currentUser.email; //replyTo defaults to current user's email 
    private String senderDisplayName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
    //Org Wide Email Address
    private Id orgWideEmailAddressId;
    
    // Template options
    private Id templateId;
    private Id whatId;
    
    // defaults for recipient types
    private final Id targetObjectId; // Contact, Lead, or User.
    private final List<String> toAddresses; 
    
    // Used to temporarily hold the email during the build command
    private Messaging.SingleEmailMessage singleEmailMessage; 
      
/*===================================
Chain Starters
======================================= */
    public static Core_EmailUtil to(List<String> addresses) {
        return new Core_EmailUtil(addresses);
    }
    
    public static Core_EmailUtil to(Id target) { 
        // warning: can't override this with a string handler, apex can't tell an Id from a String.
        return new Core_EmailUtil(target);
    }
    
/*===================================
Attribute Setters
======================================= */
/*
.saveAsActivity(Boolean val)
.senderDisplayName(String val)
.subject(String val)
.htmlBody(String val)
.useSignature(Boolean bool)
.replyTo(String val)
.plainTextBody(String val)
.fileAttachments(List<Messaging.Emailfileattachment> val)
.orgWideEmailAddressId(Id an_Id)

for use in template:
.templateId(Id an_id)
.whatId(Id an_id)
*/
    
    public Core_EmailUtil saveAsActivity(Boolean val) {
        saveAsActivity = val;
        return this;
    }
    
    public Core_EmailUtil senderDisplayName(String val) {
        senderDisplayName = val;
        return this;
    }
    
    public Core_EmailUtil subject(String val) {
        subject = val;
        return this;
    }
    
    public Core_EmailUtil htmlBody(String val) {
        htmlBody = val;
        return this;
    }
    
    public Core_EmailUtil templateId(Id an_id) {
        templateId = an_id;
        return this;
    }
    
    public Core_EmailUtil whatId (Id an_id) {
        whatId = an_id;
        return this;
    }
    
    public Core_EmailUtil useSignature(Boolean bool) {
        useSignature = bool;
        return this;
    }
    
    public Core_EmailUtil replyTo(String val) {
        replyTo = val;
        return this;
    }
    
    public Core_EmailUtil plainTextBody(String val) {
        plainTextBody = val;
        return this;
    }
    
    public Core_EmailUtil fileAttachments(List<Messaging.Emailfileattachment> val) {
        fileAttachments = val;
        return this;
    }
    
    public Core_EmailUtil orgWideEmailAddressId(Id an_id) {
        orgWideEmailAddressId = an_id;
        return this;
    }    
    
/*===================================
Chain Terminators: call to send now or stash for bulk send.
======================================= */
    public void sendEmail( Boolean AllorNone) {
        // build and send email.
        build();
        last_sendEmail_result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmailMessage }, AllorNone);
    } 
    public void stashForBulk() {
        //build and stash email.
        build();
        bulk_stash.add(singleEmailMessage);
    }
    
/*===================================
Other Bulk Actions
======================================= */
    public static void sendBulkEmail(Boolean AllorNone) {
        // send emails in bulk_stash, empty it.
        system.debug('######Total entries in bulk_stash:' + bulk_stash.size());
        system.debug('######You have made ' + Limits.getEmailInvocations() + ' email calls out of ' + 
                     Limits.getLimitEmailInvocations() + ' allowed');   
        try {
            Messaging.reserveSingleEmailCapacity(bulk_stash.size());
        } catch (Exception e) {
            System.debug('######You have used up your daily allowance of mails');
        }        
        last_sendEmail_result = Messaging.sendEmail(bulk_stash, AllorNone);
        bulk_stash.clear();
    }
    
    public static Boolean hasEmailsToSend() {
        return bulk_stash.size() != 0 ? true : false;       
    }
    
    // static method for holding email results, so I can test when triggers send emails
    public static Messaging.SendEmailResult[] last_sendEmail_result {get; private set;}
       
/*===================================
Helpers & private constructors
======================================= */
    
    // private constructors, force you to use the static chain methods.
    private Core_EmailUtil(List<String> addresses) {
        this.toAddresses = addresses;
    }
    
    private Core_EmailUtil(Id target) {
        this.targetObjectId = target; 
    }
    
    // build method, constructs a single email message.
    // this method is private and is called from sendEmail() or stashForBulk()
    private Core_EmailUtil build() {
        singleEmailMessage = new Messaging.SingleEmailMessage();
        singleEmailMessage.setTargetObjectId(this.targetObjectId);
        singleEmailMessage.setWhatId(this.whatId);
        singleEmailMessage.setOrgWideEmailAddressId(this.orgWideEmailAddressId);
        singleEmailMessage.setToAddresses(this.toAddresses);
        if(this.orgWideEmailAddressId == null){
        singleEmailMessage.setSenderDisplayName(this.senderDisplayName);
        }
        singleEmailMessage.setUseSignature(this.useSignature);
        singleEmailMessage.setReplyTo(this.replyTo);
        singleEmailMessage.setFileAttachments(this.fileAttachments);
        singleEmailMessage.setSaveAsActivity(this.saveasactivity);
        // use template if one exists, else use html and plain text body
        if (this.templateId == null) {
            singleEmailMessage.setHtmlBody(this.htmlBody);
            singleEmailMessage.setPlainTextBody(this.plainTextBody);
            singleEmailMessage.setSubject(this.subject);
        } else {
            singleEmailMessage.setTemplateId(this.templateId);
        }
        return this;
    }
        
    private static Messaging.SingleEmailMessage[] bulk_stash {
        get {
            if (bulk_stash == null) 
                bulk_stash = new Messaging.SingleEmailMessage[]{};
                    return bulk_stash;
        } private set;
    }
    
       @future 
    public static void SendEmail_ScheduledJob_Exception(boolean IsSuccess)
    {
    try
	{
        system.debug('SendEmail');
        List<OrgWideEmailAddress> orgWideEmailList=new List<OrgWideEmailAddress>();
       
        if(OrgWideEmailAddress.SObjectType.getDescribe().isAccessible()){
        orgWideEmailList = [select id, address from OrgWideEmailAddress where Address =: System.Label.Core_Job_OrgWide_Email limit 1];
        }
        String orgWideEmailId = (orgWideEmailList!=null && orgWideEmailList.size()>0) ? orgWideEmailList[0].id : '';
    	String Email_Template ='';
    	if (IsSuccess)
        {
            Email_Template =System.Label.Core_Job_Email_Template;
        }
        else
        {
        	 Email_Template =System.Label.Core_Job_Failure_Email_Template;
        }
        
        List<EmailTemplate> emailTemp = [SELECT Id , DeveloperName  FROM EmailTemplate WHERE DeveloperName =: Email_Template  LIMIT 1];
        string templateId = emailTemp.size() > 0 ? emailTemp[0].id : null;
    
     	system.debug('templateId--->'+templateId);
        List<Core_Exceptions__c> emailException = new List<Core_Exceptions__c>();
        
        String[] sendingTo = System.Label.Core_Job_Custom_Email.split(',');       
      
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        if(emailTemp != null && sendingTo != null  && orgWideEmailId != null){            
            email.setToAddresses(sendingTo);           
            email.setTemplateId(orgWideEmailId);
            email.setTargetObjectId(UserInfo.getUserId());
            email.setTemplateId(templateId);            
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(orgWideEmailId);
        }
            emailList.add(email);
       
        system.debug('emailList--->'+emailList);
        List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailList);
  
        // Process the send results if needed
        for (Messaging.SendEmailResult result : sendResults) {
            if (result.isSuccess()) {
                System.debug('Email sent successfully.-----'+ result);
            } else {
               System.debug('Email failure.');
               System.debug('Email failure.------' + result);
            }
        }
	}
	catch(Exception ex)
	{
     System.debug('Exception-->' + ex);
    
	}
    }
    
       
}