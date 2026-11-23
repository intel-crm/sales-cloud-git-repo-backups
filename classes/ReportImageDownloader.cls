public class ReportImageDownloader {
    public static void downloadReportImage() {
        String reportId ='00ODf000000YlmFMAS';
        // Replace with your actual access token
        String accessToken = '00D2D000000E9ZK!AQQAQOxQP9KfkZkcgzKH2wwCsMo2rGrHzrWa4DlQRXWOw8MvwqvokhIzjAePv8Fh0iI7bsjrdEePzCZwuipIjdhkWnjNswtr';
        // Replace with your Salesforce instance URL
        String instanceUrl = 'https://intel--crmdevsls3.sandbox.lightning.force.com';

        // Construct the API endpoint
        String url = instanceUrl + '/services/data/v55.0/analytics/download/report/' + reportId + '.png';

        // Create an HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', 'image/png');

        // Send the request
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Check if the request was successful
        if (res.getStatusCode() == 200) {
            // Get the image data
            Blob imageBlob = res.getBodyAsBlob();

            // Create an attachment to store the image
            Attachment reportAttachment = new Attachment();
           // reportAttachment.ParentId = '001XXXXXXXXXXXXXXX'; // Replace with the ID of the parent record
            reportAttachment.Name = 'Salesforce_Report_Image.png';
            reportAttachment.Body = imageBlob;
            reportAttachment.ContentType = 'image/png';

            // Insert the attachment
            insert reportAttachment;
        } else {
            System.debug('Failed to download report image. Status code: ' + res.getStatusCode());
        }
    }
}