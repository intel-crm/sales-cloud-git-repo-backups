public class EmailHelper {
    public boolean sendErrorNotification(string jobId)
    {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { 'pranavx.singh@intel.com' };
        message.subject = 'Error in Job :' +jobId ;
        message.htmlbody  = 'Hello, </br>There is error in job.</br> Please check</br></br>. Apex Job';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            return true;
        } else {
           return false;
        }
    }
}