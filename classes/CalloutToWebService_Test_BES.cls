public class CalloutToWebService_Test_BES {
    public static void makeWebServiceCallout() {
        String baseUrl = 'https://intel--crmdevcase.sandbox.my.salesforce.com/services/apexrest/IPS_BES_InboundMessageJSON/';
        // Replace 'your-instance' with your Salesforce instance name

        // Create the request payload
        String requestBody = '{' +
            '"system_details": {' +
            '  "message_id": "9f84a3d3-6763-4807-8e8a-c94f0965c4d1",' +
            '  "message_type": "Case",' +
            '  "source_system": "hsdes:client_platf:bug",' +
            '  "target_system": "IPS",' +
            '  "source_id": "13010045725",' +
            '  "target_id": "00222901",' +
            '  "backend_rev": "10"' +
            '},' +
            '"issue_information": {' +
            '  "description": "<p>Test Case on 18-9-23 desc123</p>",' +
            '  "hsd_mirror_status": "open",' +
            '  "hsd_mirror_reason": "awaiting_customer"' +
            '}' +
            '}';

        HttpRequest request = new HttpRequest();
        request.setEndpoint(baseUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);

        // Create an HTTP object to send the request
        Http http = new Http();
        HttpResponse response = http.send(request);

        // Process the response
        if (response.getStatusCode() == 200) {
            // Successful response handling here
            System.debug('Success: ' + response.getBody());
        } else {
            // Error handling for non-200 responses
            System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());
        }
    }
}