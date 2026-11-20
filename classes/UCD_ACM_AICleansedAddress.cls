public without sharing class UCD_ACM_AICleansedAddress {
    @AuraEnabled
    public static AIAddressResponseDataModel addressVerification(String organizationName, String streetName, String countryName, String stateName, String cityName, String postalCode){
        UCD_ACM_AICleansedAddressDataModel.RequestBody addressRequestBody=new UCD_ACM_AICleansedAddressDataModel.RequestBody();
        UCD_ACM_AICleansedAddressDataModel.ResponseBody responseBody=new UCD_ACM_AICleansedAddressDataModel.ResponseBody();
        AIAddressResponseDataModel aiResponse=new AIAddressResponseDataModel();
        try{
            String finalresponseJson;
            addressRequestBody=buildRequestBody(organizationName, streetName, countryName, stateName, cityName, postalCode);
            System.debug('##ReqestBody '+addressRequestBody);
            if(addressRequestBody!=null){
                String requestBodyJson=Json.serialize(addressRequestBody);
                System.debug('$$requestBodyJson '+requestBodyJson);
                finalresponseJson=callApi(requestBodyJson);
                System.debug('##finalresponseJson '+finalresponseJson);
            }
            if(String.isNotBlank(finalresponseJson)){
                responseBody=(UCD_ACM_AICleansedAddressDataModel.ResponseBody) System.JSON.deserialize(finalresponseJson,UCD_ACM_AICleansedAddressDataModel.ResponseBody.class);
            }
            if(responseBody!=null && responseBody.cleansed!=null){
                aiResponse=mapResponse(responseBody);
            }
            System.debug('$AIResponse '+aiResponse);
        }
        catch(Exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_AICleansedAddress','addressVerification','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
        return aiResponse;
    }

    public static String callApi(String requestModel){
        Map < String , String > mapOfHeaders = new Map < String, String> {
            'Content-Type' => 'application/json' };
        
        Core_ACM_CalloutService.RequestConfig requestConfig = Core_ACM_CalloutService.getRequestConfig('AddressCleanser');
        String endPoint = requestConfig.Endpoint;

        System.debug('requestModel@@@'+requestModel);
        Core_RestClient restClient = new Core_RestClient(endPoint, 'POST', mapOfHeaders, requestModel, Integer.valueOf(System.Label.Reltio_Timeout));
        restClient.invokeAPI();

        Integer statusCode = restClient.getHttpResponseStatusCode();
        String responseBody = restClient.getHttpResponseBody();
        System.debug('AICleansedAddress statusCode@@@'+statusCode);

        // Only treat 2xx responses as valid; log and skip parsing for others (e.g. 503 Service Unavailable)
        if(statusCode==null || statusCode<200 || statusCode>=300){
            UCD_ACM_Logger.error('UCD_ACM_AICleansedAddress','callApi','Address cleanser API returned status '+statusCode+'. Response: '+responseBody,NULL);
            return null;
        }

        return responseBody;
    }

    public static UCD_ACM_AICleansedAddressDataModel.RequestBody buildRequestBody(String organizationName, String streetName, String countryName, String stateName, String cityName, String postalCode){
        UCD_ACM_AICleansedAddressDataModel.RequestBody requestBody=new UCD_ACM_AICleansedAddressDataModel.RequestBody();
        UCD_ACM_AICleansedAddressDataModel.RequestData requestedData = new UCD_ACM_AICleansedAddressDataModel.RequestData();
        requestedData.organization=organizationName;
        requestedData.address=streetName;
        requestedData.country=countryName;
        requestedData.stateProvince=stateName;
        requestedData.city=cityName;
        requestedData.postalCode=postalCode;
        requestBody.data=requestedData;
        return requestBody;
    }


    public static AIAddressResponseDataModel mapResponse(UCD_ACM_AICleansedAddressDataModel.ResponseBody response){
        AIAddressResponseDataModel aiResponse=new AIAddressResponseDataModel();
        Map<string,string> countryMap = new map<String,String>();
        for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
            countryMap.put(allCountries.Name, allCountries.ISO_Code__c);
        }
        Map<String, Map<String,String>> mapOfAllStateCodeAndNameByCountry = new Map<String, Map<String,String>>();
        mapOfAllStateCodeAndNameByCountry = UCD_ACM_Utils.getGlobalPickList();
        Map<String,String> mapOfstateCodeAndName=mapOfAllStateCodeAndNameByCountry.get(countryMap.get(response.cleansed.country));
        for(String currentStatesCode : mapOfstateCodeAndName.keySet()){
            if(mapOfstateCodeAndName.get(currentStatesCode)==response.cleansed.stateProvince){
                aiResponse.stateCode=currentStatesCode;
            }
        }
        aiResponse.countryCode=countryMap.get(response.cleansed.country);
        aiResponse.streetName=response.cleansed.address;
        aiResponse.cityName=response.cleansed.city;
        aiResponse.countryName=response.cleansed.country;
        aiResponse.stateName=response.cleansed.stateProvince;
        aiResponse.postalCode=response.cleansed.postalCode;
        aiResponse.verificationStatus=response.cleansed.addrVerificationStatus;
        return aiResponse;
    }

    public class AIAddressResponseDataModel{
        @AuraEnabled
        public String streetName{set;get;}
        @AuraEnabled
        public String countryName{set;get;}
        @AuraEnabled
        public String countryCode{set;get;}
        @AuraEnabled
        public String stateName{set;get;}
        @AuraEnabled
        public String stateCode{set;get;}
        @AuraEnabled
        public String cityName{set;get;}
        @AuraEnabled
        public String postalCode{set;get;}
        @AuraEnabled
        public String verificationStatus{set;get;}
    }
}