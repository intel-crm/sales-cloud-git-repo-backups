public class BatchDRUtility {
    public String query;
    public String object_name;
    public String dr_Are_Intel_items_used_for_MINDS;
    public String dr_City;
    public String dr_mapped_rec_id;
    public String dr_Country;
    public String dr_Decision_Date;
    public String dr_Description;
    public String dr_End_Customer_Name;
    public String dr_External_Id;
    public String dr_First_Customer_Ship_Date;
    public String dr_Opportunity_Volume;
    public String dr_Partner_FAE;
    public String dr_Partner_FAE_Email;
    public String dr_Product_Segment;
    public String dr_Product_Application;
    public String dr_Production_End_Date;
    public String dr_State_Province;
    public String dr_Street1;
    public String dr_Vertical_Market;
    public String dr_Zip_Postal_Code;
    public String dr_name_mapped_with;
    
    public String drp_DR_ID_mapped_with;
    public String drp_mapped_rec_id;
    public String drp_Mmid_mapped_with;
    public String drp_name_mapped_with;
    public String drp_Old_mmid_mapped_with;
    public String drp_Ordering_code_mapped_with;
    public String drp_quantity_mapped_with;
    public String drp_Target_resale_mapped_with;
    public String drp_object_mapped_with;
    List<DRP_field_mapping_stored__c> drpMapping;
    List<DR_field_mapping_stored__c> mapping;
    
    public void initialize() {
        mapping = [SELECT Id,DR_Name_mapped_with__c,DR_Are_Intel_items_used_mapped_with__c, DR_City_mapped_with__c, DR_Country_mapped_with__c, DR_Decision_Date_mapped_with__c, DR_Description_mapped_with__c, DR_End_Customer_Name_mapped_with__c, DR_External_Id_mapped_with__c, DR_First_Customer_Ship_Date_mapped_with__c, DR_Mapped_to_Rec_Id__c, DR_Opportunity_Volume_mapped_with__c, DR_Partner_FAE_Email_mapped_with__c, DR_Partner_FAE_mapped_with__c, DR_Product_Application_mapped_with__c, DR_Product_Segment_mapped_with__c, DR_Production_End_Date_mapped_with__c, DR_State_Province_mapped_with__c, DR_Street1_mapped_with__c, DR_Vertical_Market_mapped_with__c, DR_Zip_Postal_Code_mapped_with__c, Object_to_be_mapped__c from DR_field_mapping_stored__c Limit 1];
       
        for (DR_field_mapping_stored__c mapRecord : mapping) {
            object_name = mapRecord.Object_to_be_mapped__c;
            dr_name_mapped_with=mapRecord.DR_Name_mapped_with__c;
            dr_Are_Intel_items_used_for_MINDS=mapRecord.DR_Are_Intel_items_used_mapped_with__c;
            dr_City=mapRecord.DR_City_mapped_with__c;
            dr_mapped_rec_id=mapRecord.DR_Mapped_to_Rec_Id__c;
            dr_Country=mapRecord.DR_Country_mapped_with__c;
            dr_Decision_Date=mapRecord.DR_Decision_Date_mapped_with__c;
            dr_Description=mapRecord.DR_Description_mapped_with__c;
            dr_End_Customer_Name=mapRecord.DR_End_Customer_Name_mapped_with__c;
            dr_External_Id=mapRecord.DR_External_Id_mapped_with__c;
            dr_First_Customer_Ship_Date=mapRecord.DR_First_Customer_Ship_Date_mapped_with__c;
            dr_Opportunity_Volume=mapRecord.DR_Opportunity_Volume_mapped_with__c;
            dr_Partner_FAE=mapRecord.DR_Partner_FAE_mapped_with__c;
            dr_Partner_FAE_Email=mapRecord.DR_Partner_FAE_Email_mapped_with__c;
            dr_Product_Segment=mapRecord.DR_Product_Segment_mapped_with__c;
            dr_Product_Application=mapRecord.DR_Product_Application_mapped_with__c;
            dr_Production_End_Date=mapRecord.DR_Production_End_Date_mapped_with__c;
            dr_State_Province=mapRecord.DR_State_Province_mapped_with__c;
            dr_Street1=mapRecord.DR_Street1_mapped_with__c;
            dr_Vertical_Market=mapRecord.DR_Vertical_Market_mapped_with__c;
            dr_Zip_Postal_Code=mapRecord.DR_Zip_Postal_Code_mapped_with__c;
            
        }
    }
    
    public String getObjectName() {
        return object_name;
    }
    public void initializeDRP() {
        drpMapping = [select Id,DRP_Design_Registration_ID_mapped_with__c, DRP_Mapped_to_Rec_Id__c, DRP_MMID_mapped_with__c, DRP_Name_mapped_with__c, DRP_Old_MMID_mapped_with__c, DRP_Ordering_Code_mapped_with__c, DRP_Quantity_mapped_with__c, DRP_Target_Resale_Price_mapped_with__c, Name, Object_to_be_mapped__c from DRP_field_mapping_stored__c Limit 1];
       
        for (DRP_field_mapping_stored__c mapRecord : drpMapping) {
            drp_object_mapped_with = mapRecord.Object_to_be_mapped__c;
         drp_DR_ID_mapped_with= mapRecord.DRP_Design_Registration_ID_mapped_with__c;
  drp_mapped_rec_id= mapRecord.DRP_Mapped_to_Rec_Id__c;
   drp_Mmid_mapped_with= mapRecord.DRP_MMID_mapped_with__c;
   drp_name_mapped_with= mapRecord.DRP_Name_mapped_with__c;
   drp_Old_mmid_mapped_with= mapRecord.DRP_Old_MMID_mapped_with__c;
    drp_Ordering_code_mapped_with= mapRecord.DRP_Ordering_Code_mapped_with__c;
    drp_quantity_mapped_with= mapRecord.DRP_Quantity_mapped_with__c;
    drp_Target_resale_mapped_with= mapRecord.DRP_Target_Resale_Price_mapped_with__c;   
            
        }
    }
    
    public String getDRPObjectName() {
        return drp_object_mapped_with;
    }
    
    public static String getAccessToken() {
        String endpoint = 'https://intel--crmqa6.sandbox.my.salesforce.com/services/oauth2/token';
        String clientId = '3MVG9x2D7w6gNN5nyWEnsMmFudqRBQMtkYmsZcvzG7GpuwIF_PfwBuG9FkYeGshLgiIMt9BDCLBWY.EIN8ONr';
        String clientSecret = '2D0395E8FD089F5574AFD8B1ADE1ED81918905D7CCA15844A7AEDAAB0CF33FF1';
        
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
    private static String prepareApiRequestBody(Design_Registration_Stage__c recordData) {
        // Create a JSON representation of the record data
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('designRegistrationName', recordData.Name);
        requestBodyMap.put('militaryAerospaceGvrnmtUseInd', recordData.Are_Intel_items_used_for_MINDS__c);
        requestBodyMap.put('verticalMarket', recordData.Vertical_Market__c);
        requestBodyMap.put('productSegment', recordData.Product_Segment__c);
        requestBodyMap.put('productApplication', recordData.Product_Application__c);
        requestBodyMap.put('partnerFAE', recordData.Partner_FAE__c);
        requestBodyMap.put('partnerFAEEmail', recordData.Partner_FAE_Email__c);
        requestBodyMap.put('opportunityVolume', recordData.Opportunity_Volume__c);
        requestBodyMap.put('endCustomerName', recordData.End_Customer_Name__c);
        requestBodyMap.put('endCustomerCountry', recordData.Country__c);
        requestBodyMap.put('endCustomerCity', recordData.City__c);
        requestBodyMap.put('endCustomerState', recordData.State_Province__c);
        requestBodyMap.put('endCustomerPostalCode', recordData.Zip_Postal_Code__c);
        requestBodyMap.put('designDecisionDate', recordData.Decision_Date__c);
        requestBodyMap.put('firstCustomerShipDate', recordData.First_Customer_Ship_Date__c);
        requestBodyMap.put('productionEndDate', recordData.Production_End_Date__c);
        requestBodyMap.put('externalId', recordData.External_Id__c);
        requestBodyMap.put('description', recordData.Description__c);
        requestBodyMap.put('endCustomerAddress1', recordData.Street1__c);
        requestBodyMap.put('recordId', recordData.Record_Id_from_Response__c);
        
        // Convert the map to a JSON string
        String requestBody = JSON.serialize(requestBodyMap);
        String reqbody='['+requestBody+']';
        system.debug(reqbody);
        return reqbody;
    }
    private static String prepareApiRequestBodyUpdate(Design_Registration_Stage__c recordData) {
        // Create a JSON representation of the record data
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('designRegistrationName', recordData.Name);
        requestBodyMap.put('militaryAerospaceGvrnmtUseInd', recordData.Are_Intel_items_used_for_MINDS__c);
        requestBodyMap.put('verticalMarket', recordData.Vertical_Market__c);
        requestBodyMap.put('productSegment', recordData.Product_Segment__c);
        requestBodyMap.put('productApplication', recordData.Product_Application__c);
        requestBodyMap.put('partnerFAE', recordData.Partner_FAE__c);
        requestBodyMap.put('partnerFAEEmail', recordData.Partner_FAE_Email__c);
        requestBodyMap.put('opportunityVolume', recordData.Opportunity_Volume__c);
        requestBodyMap.put('endCustomerName', recordData.End_Customer_Name__c);
        requestBodyMap.put('endCustomerCountry', recordData.Country__c);
        requestBodyMap.put('endCustomerCity', recordData.City__c);
        requestBodyMap.put('endCustomerState', recordData.State_Province__c);
        requestBodyMap.put('endCustomerPostalCode', recordData.Zip_Postal_Code__c);        
        requestBodyMap.put('firstCustomerShipDate', recordData.First_Customer_Ship_Date__c);
        requestBodyMap.put('productionEndDate', recordData.Production_End_Date__c);
        requestBodyMap.put('externalId', recordData.External_Id__c);
        requestBodyMap.put('description', recordData.Description__c);
        requestBodyMap.put('endCustomerAddress1', recordData.Street1__c);
        requestBodyMap.put('recordId', recordData.Record_Id_from_Response__c);
        
        // Convert the map to a JSON string
        String requestBody = JSON.serialize(requestBodyMap);
        String reqbody='['+requestBody+']';
        system.debug(reqbody);
        return reqbody;
    }
    
    private static String prepareApiRequestBodyDRP(Design_Registration_Product_M2M_Stage__c recordData) {
        // Create a JSON representation of the record data
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('designRegId', recordData.Design_Registration_dummy__r.Record_Id_from_Response__c);
        requestBodyMap.put('quantity', recordData.Quantity__c);
        requestBodyMap.put('targetResalePrice', recordData.Target_Resale_Price__c);
        requestBodyMap.put('mmId', recordData.MMID__c);
        requestBodyMap.put('oldMMId', recordData.MMID__c);
        requestBodyMap.put('orderingCd', recordData.MMID__c);
        
        // Convert the map to a JSON string
        String requestBody = JSON.serialize(requestBodyMap);
        String reqbody='['+requestBody+']';
        system.debug(reqbody);
        return reqbody;
    }
    private static String prepareApiRequestBodyDRPUpdate(Design_Registration_Product_M2M_Stage__c recordData) {
        // Create a JSON representation of the record data
        Map<String, Object> requestBodyMap = new Map<String, Object>();
      	
        requestBodyMap.put('quantity', recordData.Quantity__c);
        requestBodyMap.put('targetResalePrice', recordData.Target_Resale_Price__c);
        requestBodyMap.put('mmId', recordData.MMID__c);
        requestBodyMap.put('oldMMId', recordData.MMID__c);
        requestBodyMap.put('orderingCd', recordData.MMID__c);
        requestBodyMap.put('recordId', recordData.Record_Id_from_Response__c);
        
        // Convert the map to a JSON string
        String requestBody = JSON.serialize(requestBodyMap);
        String reqbody='['+requestBody+']';
        system.debug(reqbody);
        return reqbody;
    }
    
    public static void calloutCreateDR(Design_Registration_Stage__c dr){
        try{
            String url ='https://intel--crmqa6.sandbox.my.salesforce.com/services/apexrest/v1.0/design-registration/';
            String apiRequestBody = prepareApiRequestBody(dr);
            system.debug(apiRequestBody);
            String accessToken = getAccessToken();
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
        dr.Response__c = response.getBody();
        dr.Record_Id_from_Response__c = (String) jsonResponse.get('RecordId');
        update dr;
        system.debug(dr);
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
        public static void calloutUpdateDR(Design_Registration_Stage__c dr){
        try{
            String url ='https://intel--crmqa6.sandbox.my.salesforce.com/services/apexrest/v1.0/design-registration/';
            String apiRequestBody = prepareApiRequestBodyUpdate(dr);
            system.debug(apiRequestBody);
            String accessToken = getAccessToken();
            system.debug(accessToken) ; 
            HttpRequest request1 = new HttpRequest();
            request1.setEndpoint(url);
            request1.setMethod('PUT');
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
        dr.Response__c = response.getBody();
        dr.Record_Id_from_Response__c = (String) jsonResponse.get('RecordId');
        update dr;
        system.debug(dr);
    } 
            } else {
                System.debug('API callout failed with status code: ' + response.getStatusCode());
                System.debug('Response body: ' + response.getBody());
            }
        }
        catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
            
        }
    }
    
    public static void calloutCreateDRP(Design_Registration_Product_M2M_Stage__c drp){
        try{
            String url ='https://intel--crmqa6.sandbox.my.salesforce.com/services/apexrest/v1.0/design-registration-product/';
            String apiRequestBody = prepareApiRequestBodyDRP(drp);
            system.debug(apiRequestBody);
            String accessToken = getAccessToken();
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

        Map<String, Object> jsonResponse = (Map<String, Object>) jsonResponseList[0];

        system.debug(jsonResponse);
        drp.Response__c = response.getBody();
        drp.Record_Id_from_Response__c = (String) jsonResponse.get('RecordId');
        update drp;
        system.debug(drp);
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
        public static void calloutUpdateDRP(Design_Registration_Product_M2M_Stage__c drp){
        try{
            String url ='https://intel--crmqa6.sandbox.my.salesforce.com/services/apexrest/v1.0/design-registration-product/';
            String apiRequestBody = prepareApiRequestBodyDRPUpdate(drp);
            system.debug(apiRequestBody);
            String accessToken = getAccessToken();
            system.debug(accessToken) ; 
            HttpRequest request1 = new HttpRequest();
            request1.setEndpoint(url);
            request1.setMethod('PUT');
            request1.setHeader('Authorization', 'Bearer ' +accessToken);
            request1.setHeader('Content-Type', 'application/json');
            request1.setBody(apiRequestBody);
            Http http = new Http();
            HttpResponse response = http.send(request1);

            if (response.getStatusCode() == 201) {
                List<Object> jsonResponseList = (List<Object>) JSON.deserializeUntyped(response.getBody());

    if (jsonResponseList != null && !jsonResponseList.isEmpty()) {

        Map<String, Object> jsonResponse = (Map<String, Object>) jsonResponseList[0];

        system.debug(jsonResponse);
        drp.Response__c = response.getBody();
        drp.Record_Id_from_Response__c = (String) jsonResponse.get('RecordId');
        update drp;
        system.debug(drp);
    } 
            } else {
                System.debug('API callout failed with status code: ' + response.getStatusCode());
                System.debug('Response body: ' + response.getBody());
            }
        }
        catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
            
        }
    }
    
}