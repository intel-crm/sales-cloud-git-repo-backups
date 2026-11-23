public class sendemailsample {
public static void sendData(string recordString) {
 string header = 'ContactEmail,LastName, FirstName, status \n';
    string finalstr = header ;   
    finalstr = finalstr +recordString;
   
    String userName = UserInfo.getUserName();
    User activeUser = [Select Email,Contact.Email From User where Username = : userName limit 1];
   // String userEmail = activeUser.Contact.Email;
    String userEmail ='latax.dudam@intel.com';
    Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
    blob csvBlob = Blob.valueOf(finalstr);
    string csvname= 'BulkInviteResults.csv';
    boolean isSuccess=false;
    csvAttc.setFileName(csvname);
    csvAttc.setBody(csvBlob);
    Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
    String[] toAddresses = new list<string> {userEmail};
    String subject ='Bulk Data Upload completed Successfully';
    email.setSubject(subject);
    email.setToAddresses( toAddresses );
    email.setPlainTextBody('Bulk Data Upload results ');
    email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
   // PlatformEventCtrl.publishEvent();
    // custom field: stauts==mail sending:pass fail
    // picklist source =xyz
            PRM_Bulk_Invite__e event = new PRM_Bulk_Invite__e();
        event.PRM_Status__c='abc';
            EventBus.publish(event);
    
   
    
} 
}