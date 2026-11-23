public class Test_Class_New {
     public  String getAccessToken() {
        String endpoint = 'https://intel--crmdevint3.sandbox.my.salesforce.com/services/oauth2/token';
        String clientId = '3MVG9ysJNY7CaIHmfWttUndboDtwNXX10523GosRcaibn9RybXDZUjkvp2.Mi_eU.NPAPvS3TmL.a0b_iIPH9';
        String clientSecret = '5F94D593C50A8CBC87A2305B38D67A0025293AFBBF1D008D77A009BB73247610';
        /*String endpoint =Intel_M2M_API_Data__mdt.getInstance('Access_Token_End_Point').Value__c ;
        String clientId =Intel_M2M_API_Data__mdt.getInstance('Access_Token_Client_Id').Value__c ;
        String clientSecret = Intel_M2M_API_Data__mdt.getInstance('Access_Token_Client_Secret').Value__c;*/
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        // Set the request body in JSON format
        String requestBody = 'grant_type=client_credentials&client_id=' + clientId +
            '&client_secret=' + clientSecret;        
        request.setBody(requestBody);        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String accessToken = (String) responseData.get('access_token');
            return accessToken;
        } else {
            
            System.debug('Error response: ' + response.getBody());
            return null;
        }
    }
    public  void calloutCreateDR(){
        try{
            String url ='https://intel--crmdevint3.sandbox.my.salesforce.com/services/apexrest/v1.0/design-registration/';
           /* String url =Intel_M2M_API_Data__mdt.getInstance('Create_Update_DR_Callout_URL').Value__c;*/
            String apiRequestBody ='[{ "productSegment": "Client Computing", "partnerFAEEmail": "pcctestlen2@ruamkt.com", "designDecisionDate": "2025-05-11", "firstCustomerShipDate": "2025-06-11", "productionEndDate": "2025-07-11", "militaryAerospaceGvrnmtUseInd": "Yes", "productApplication": "Business Desktop", "verticalMarket": "Agriculture", "productGroup": "", "opportunityVolume": "77", "partnerFAE": "Test FAE", "partnerFSR": "", "endCustomerName": "Test Electronics Account", "endCustomerAddress1": "12 Street 99", "endCustomerAddress2": "", "endCustomerCountry": "India", "endCustomerCity": "Bangalore", "endCustomerState": "Karnataka", "endCustomerPostalCode": "758854", "endCustomerContactTitle": "", "endCustomerContactName": "Test Electronics Partner User 01", "endCustomerContactEmail": "Testelec.partneruser01@testwbb.com", "endCustomerContactPhone": "7826499722", "description":"Created through Postman on 21-02-2024_test123", "manufacturingRegion": "", "intelPlatform":"", "designRegistrationName":"Created through Postman on 21-02-2024_new_shub", "endCustomerUrl": "", "externalId": "1278390232442" ,"createdThroughMappingTab":"true" }]';
            system.debug(apiRequestBody);
            Test_Class_New test=new Test_Class_New();
            String accessToken = test.getAccessToken();
            system.debug(accessToken) ; 
            HttpRequest request1 = new HttpRequest();
            request1.setEndpoint(url);
            request1.setMethod('POST');
            request1.setHeader('Authorization', 'Bearer ' +accessToken);
            request1.setHeader('Content-Type', 'application/json');
            request1.setBody(apiRequestBody);
            Http http = new Http();
            HttpResponse response = http.send(request1);
            
            if (response.getStatusCode() == 201) {
                List<Object> jsonResponseList = (List<Object>) JSON.deserializeUntyped(response.getBody());
                
                if (jsonResponseList != null && !jsonResponseList.isEmpty()) {
                    // Assuming the 'recordId' is at index 0, adjust accordingly based on your actual response structure
                    Map<String, Object> jsonResponse = (Map<String, Object>) jsonResponseList[0];
                    
                    system.debug(jsonResponse);
                    
                } 
            }
            else {
                System.debug('API callout failed with status code: ' + response.getStatusCode());
                System.debug('Response body: ' + response.getBody());
            }
        }
        catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
            
        }
    }

}