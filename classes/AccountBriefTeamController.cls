public with sharing class AccountBriefTeamController {
    @AuraEnabled
    public static void saveRecord(String data) {
        List<Account_Brief_Summary_POC__c> records = (List<Account_Brief_Summary_POC__c>) JSON.deserialize(data, List<Account_Brief_Summary_POC__c>.class);
        insert records;
    }

    @AuraEnabled
    public static String generatePdfContent(String data) {
        // Generate HTML content from the input data
        List<Account_Brief_Summary_POC__c> records = (List<Account_Brief_Summary_POC__c>) JSON.deserialize(data, List<Account_Brief_Summary_POC__c>.class);

        String html = '<html><head><title>Account Brief Team</title></head><body>';
        for (Account_Brief_Summary_POC__c record : records) {
            html += '<h3>Meeting Details</h3>';
            html += '<p><strong>Account Brief Summary:</strong> ' + record.Account_Brief_Summary__c + '</p>';
            html += '<p><strong>Meeting Invite:</strong> ' + record.Meeting_Invite__c + '</p>';
            html += '<p><strong>Attendees:</strong> ' + record.Attendees__c + '</p>';
        }
        html += '</body></html>';

        // Generate the PDF file
        String pdfUrl = PdfGenerator.generate(html); // Assume a utility class
        return pdfUrl;
    }
}