public with sharing class PRM_SendEmailToUsers {
public static void sendData(string emailTemplateName,string recordStringSuccess,string recordStringFail,string emailBody,string emailSubject) {
 List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
 string header = 'ContactEmail,LastName, FirstName, ContactCountry, status \n';
 string header1 = 'countrylist \n';
    string finalstr = header ; 
    string finalstr1 = header1 ;   
    
    if(string.isNotBlank(recordStringSuccess)){
        finalstr = finalstr +recordStringSuccess;
    }
    if(string.isNotBlank(recordStringFail)){
        finalstr = finalstr +recordStringFail;
    }
    List<Schema.PicklistEntry> entries = Account.BillingCountryCode.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : entries) {
            finalstr1=finalstr1+'"'+entry.getLabel()+'"'+'\n';
        }
    String emailBodyTemplate = [select HtmlValue from EmailTemplate where DeveloperName =:emailTemplateName limit 1].HtmlValue;
    emailBodyTemplate =  Test.isRunningTest()?emailSubject:emailBodyTemplate.replace('{!job_subject}',emailSubject);//'Batch Execution started'
    emailBodyTemplate= Test.isRunningTest()?emailBody:emailBodyTemplate.replace('{!JOB_MESSAGE}',emailBody);
    emailBodyTemplate = Test.isRunningTest()?Label.PRM_CurrentYear:emailBodyTemplate.replace('{!$Label.PRM_CurrentYear}', Label.PRM_CurrentYear);//IPA2.0 TWC727-3232

    String userName = UserInfo.getUserName();
    User activeUser = [Select Email,ContactId,Contact.Email,tolabel(Contact.Core_Preferred_Language__c),LanguageLocaleKey From User where Username = : userName limit 1];
    String userEmail = activeUser.Email;
    string userLang=activeUser.Contact.Core_Preferred_Language__c;
   // String userEmail ='latax.dudam@intel.com';
    Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
    Messaging.EmailFileAttachment csvAttc1 = new Messaging.EmailFileAttachment();
   // blob csvBlob = Blob.valueOf(finalstr);
   blob csvBlob = Blob.valueOf('\uFEFF'+finalstr);
   blob csvBlob1 = Blob.valueOf('\uFEFF'+finalstr1);
   string csvname1= 'CountryList.csv';
    string csvname= 'BulkInviteResults.csv';
    boolean isSuccess=false;
    csvAttc.setFileName(csvname);
    csvAttc.setBody(csvBlob);
    csvAttc1.setFileName(csvname1);
    csvAttc1.setBody(csvBlob1);
    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    efa.setFileName(csvname);
    efa.setBody(csvBlob);
    Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
    efa1.setFileName(csvname1);
    efa1.setBody(csvBlob1);
  
    Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
    String[] toAddresses = new list<string> {userEmail};
    // String subject ='Bulk Data Load Results';
     email.setSubject(emailSubject);
     email.setHtmlBody(emailBodyTemplate); 
    email.setToAddresses( toAddresses );
    email.setPlainTextBody(emailBodyTemplate);
    email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa, efa1 });
    if (owea != null) {
        email.setOrgWideEmailAddressId(owea.get(0).Id);
}   
    // email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
    // email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc1});
    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    List<Messaging.SingleEmailMessage> mail =new List<Messaging.SingleEmailMessage>();
    mail.add(email);
    if(r[0].IsSuccess()){
    List<PRM_EmailLog__c> listEmailLogs = PRM_Retrigger_Emaillog_Utility.createRetriggerEmailLogs(mail, new List<PRM_EmailLog__c>(),  emailTemplateName,userLang);
    if(!listEmailLogs.isempty()){
        listEmailLogs[0].PRM_Contact__c = activeUser.ContactId;
        insert listEmailLogs;
         // file attachment log:
    // First, create a new ContentVersion record using the Blob data of your CSV file.
    Id networkId = [SELECT Id FROM Network LIMIT 1].Id;
    ContentVersion cv = new ContentVersion();
    cv.Title = 'BulkInviteResults.csv';
    String base64 = EncodingUtil.base64Encode(Blob.valueOf(finalstr));
    cv.VersionData = EncodingUtil.base64Decode(base64);
    cv.NetworkId = networkId;
    cv.PathOnClient='BulkInviteResults';
    Database.SaveResult InsertedRecord = Database.insert(cv);
    if(InsertedRecord != null && InsertedRecord.isSuccess() ){
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.id].Id; 
        cdl.LinkedEntityId = listEmailLogs[0].id; 
        cdl.ShareType = 'V'; 
        cdl.Visibility = 'AllUsers'; 
        insert cdl;
    }
  

    }
}  
} 
}