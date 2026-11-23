public class ACM_EmailManager {

    // Public method
    public void sendMail(List<String> toAddresses, String subject, String body) {
        // Create an email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        // Pass this email message to the built-in sendEmail method 
        // of the Messaging class
        Messaging.SendEmailResult[] results = Messaging.sendEmail(
                                 new Messaging.SingleEmailMessage[] { mail });
        // Call a helper method to inspect the returned results
        inspectResults(results);
    }
    
    public void sendEmailHTML(List<ACM_CNDAStatusBatch.NDAAccountWrapper> ndaAccountTable) {
        // Generate the HTML email body
        String emailBody = '<h3>&lt;System generated email&gt;</h3><br/><p>Please note below is the list of accounts with CNDAs in Inactive state, data cleanse is complete and inactive NDAs are removed from SalesCRM Account.</p>';
        emailBody += '<table border="1" cellpadding="5" cellspacing="0">';
        emailBody += '<tr><th>CNDA List</th><th>Account ID</th></tr>';
        
        // Loop through the NDAAccountTable and add rows to the HTML table
        for (ACM_CNDAStatusBatch.NDAAccountWrapper row : ndaAccountTable) {
            emailBody += '<tr>';
            emailBody += '<td>' + row.ndaList + '</td>';
            emailBody += '<td>' + row.accountId + '</td>';
            emailBody += '</tr>';
        }

        emailBody += '</table>';

        // Create the email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Set email parameters
        mail.setToAddresses(new String[] {'ajay.balakrishnan@intel.com','team.vega@intel.com'}); // Replace with recipient email
        mail.setSubject('SalesCRM Inactive CNDA Bulk Action');
        mail.setHtmlBody(emailBody);  // Set the HTML content
        
        System.debug('Reached here');

        Messaging.SendEmailResult[] results = Messaging.sendEmail(
                                 new Messaging.SingleEmailMessage[] { mail });
        // Call a helper method to inspect the returned results
        inspectResults(results);
    }

    
    // Helper method
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        // sendEmail returns an array of result objects.
        // Iterate through the list to inspect results. 
        // In this class, the methods send only one email, 
        // so we should have only one result.
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            }
            else {
                sendResult = false;
                System.debug('The following errors occurred: ' + res.getErrors());                 
            }
        }
        return sendResult;
    }
}