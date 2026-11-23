public class testclass{
 
    public static void prepareApiRequestBody(List<Core_Design_Registration__c> newList) {
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        if(newList != null && !newList.IsEmpty()){
            system.debug('newList'+newList);
            for(Core_Design_Registration__c iDR : newList){
                // Create a JSON representation of the record data
                if(iDR.Core_Submission_Type__c =='M2M'){
                    system.debug('Inside Request body map>>');
                    requestBodyMap.put('Country__c',iDR.Core_End_Customer_Country_Nm__c );
                    requestBodyMap.put('DR_First_Customer_Ship_Date__c',iDR.Core_First_Customer_Ship_Dt__c );
                    requestBodyMap.put('DR_Partner_FAE__c',iDR.Core_Partner_FAE_Nm__c );
                    requestBodyMap.put('DR_Partner_FAE_Email__c',iDR.DDR_Partner_FAE_Email__c );
                    requestBodyMap.put('DR_Production_End_Date__c',iDR.Core_Production_End_Dt__c );
                    requestBodyMap.put('DR_Rec_Id__c', iDR.id);
                    // Convert the map to a JSON string
                    String requestBody = JSON.serialize(requestBodyMap);
                    system.debug(requestBody);
                    
                    calloutCreateDR(requestBody);
                }
            }
        }
        
    }
    @future (callout=true)
    public static void calloutCreateDR(String requestBody){
        try{
            
           String url ='callout:Test_Named_Cred_new/services/data/v60.0/sobjects/Test_Event__e/';
            String apiRequestBody =requestBody;
            System.debug('apiRequestBody>>'+apiRequestBody);
            HttpRequest request1 = new HttpRequest();
            request1.setEndpoint(url);
            request1.setMethod('POST');
           request1.setHeader('Content-Type', 'application/json');
            request1.setBody(apiRequestBody);
           
            Http http = new Http();
            HttpResponse response = http.send(request1);
            
            if (response.getStatusCode() == 201) {
                system.debug('Resp body'+response.getBody());
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