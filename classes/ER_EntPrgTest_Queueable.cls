public class ER_EntPrgTest_Queueable implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext context) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();

        // 🔗 Replace with your actual sandbox domain if needed
        String endpoint = 'https://intel--crmdevint3.sandbox.my.salesforce.com/services/apexrest/Account/V2/SearchAccount-old';

        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

        //  Construct request body
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('AccountName', 'Infosys Limited');
        payload.put('AccountURL', 'infosys.com');
        payload.put('EmailAddress', 'contact@infosys.com'); // optional
        payload.put('BizOrgType', '');
        payload.put('SearchLimit', '5');
        payload.put('MinimumSearchScore', '60');
        payload.put('EntitlementName', 'RDC'); // must match a CEAccountTypeMap label

        //  Nested address object
        Map<String, String> address = new Map<String, String>();
        address.put('CountryCode2', 'IN');
        address.put('StateCode2', 'KA');
        address.put('AddressLine1', 'Electronic City Phase 1');
        address.put('AddressLine2', '');
        address.put('City', 'Bangalore');
        address.put('PostalCode', '560100');

        payload.put('AccountAddress', address);

        String jsonBody = JSON.serialize(payload);
        req.setBody(jsonBody);

        //  Log full request
        System.debug(' [ENT PRG Queueable] Endpoint: ' + endpoint);
        System.debug(' [ENT PRG Queueable] Request Body: ' + jsonBody);

        try {
            HttpResponse res = http.send(req);

            //  Log successful response
            System.debug('[ENT PRG Queueable] HTTP Status: ' + res.getStatus());
            System.debug(' [ENT PRG Queueable] Response Body: ' + res.getBody());

        } catch (Exception e) {
            //  Log errors
            System.debug(' [ENT PRG Queueable] Callout Error: ' + e.getMessage());
        }
    }
}