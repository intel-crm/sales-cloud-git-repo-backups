public without sharing class UCD_ACM_AddressVerificationOnReqstQueue {
    public static final String Post_Method = 'POST';
    @InvocableMethod
    public static void addressVerificationApiCall(List<Id> ids){
        try{
            List<Account_Create_Request__c> accountRequest=[Select Id,Address__CountryCode__s,Address__Street__s,Address__City__s,Address__StateCode__s,Address__PostalCode__s from Account_Create_Request__c where Id IN: ids];
            List<UCD_ACM_AddressVerificationDataModel.RequestBody> addressRequestBodyList=new List<UCD_ACM_AddressVerificationDataModel.RequestBody>();
            List<UCD_ACM_AddressVerificationDataModel.ResponseBody> loqateResponseBodyList=new List<UCD_ACM_AddressVerificationDataModel.ResponseBody>();
            Map<Id,Account_Create_Request__c> mapOfAccountCreateRquest=new Map<Id,Account_Create_Request__c>();
            List<Account_Create_Request__c> accountRequestToUpdate=new List<Account_Create_Request__c>();
            String finalresponseJson;
            Map<string,string> countryMap = new map<String,String>();
            Map<Id,Account_Create_Request__c> mapOfAccountRquest=new Map<Id,Account_Create_Request__c>();
            for(Account_Create_Request__c accReq: accountRequest){
                mapOfAccountRquest.put(accReq.Id,accReq);
            }
            for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
                countryMap.put(allCountries.Name, allCountries.ISO_Code__c);
            }
            addressRequestBodyList=buildRequestBody(accountRequest);
            if(!addressRequestBodyList.isEmpty()){
                String requestBodyJson=Json.serialize(addressRequestBodyList);
                finalresponseJson=callLoqateApi(requestBodyJson);
                if(String.isNotBlank(finalresponseJson)){
                    loqateResponseBodyList=(List<UCD_ACM_AddressVerificationDataModel.ResponseBody>) System.JSON.deserialize(finalresponseJson,List<UCD_ACM_AddressVerificationDataModel.ResponseBody>.class);
                }
                if(!loqateResponseBodyList.isEmpty()){
                    for(UCD_ACM_AddressVerificationDataModel.ResponseBody response: loqateResponseBodyList){
                        for(UCD_ACM_AddressVerificationDataModel.ResponseCrossWalk crosswalk: response.crosswalks){
                            if(mapOfAccountRquest.containsKey(crosswalk.value)){
                                mapOfAccountCreateRquest=responseMapping(response,mapOfAccountRquest.get(crosswalk.value),countryMap);
                                accountRequestToUpdate.add(mapOfAccountCreateRquest.values());
                            }
                        }
                    }
                }
                system.debug('##accountRequestToUpdate '+accountRequestToUpdate);
                if(!accountRequestToUpdate.isEmpty()){
                    update accountRequestToUpdate;
                }
            }
        }
        catch(Exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_AddressVerificationOnReqstQueue','addressVerificationApiCall','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }

    public static List<UCD_ACM_AddressVerificationDataModel.RequestBody> buildRequestBody(List<Account_Create_Request__c> accountRequest){
        List<UCD_ACM_AddressVerificationDataModel.RequestBody> requestBodyList=new List<UCD_ACM_AddressVerificationDataModel.RequestBody>();
        for(Account_Create_Request__c accReq:accountRequest){
            UCD_ACM_AddressVerificationDataModel.RequestCrossWalk reqCrosswalk=new UCD_ACM_AddressVerificationDataModel.RequestCrossWalk();
            reqCrosswalk.type='configuration/sources/Salesforce';
            reqCrosswalk.value=accReq.Id;

            UCD_ACM_AddressVerificationDataModel.AddressLineInfo addressLineInfo=new UCD_ACM_AddressVerificationDataModel.AddressLineInfo();
            addressLineInfo.value=accReq.Address__Street__s;

            UCD_ACM_AddressVerificationDataModel.AddressCityInfo addressCityInfo=new UCD_ACM_AddressVerificationDataModel.AddressCityInfo();
            addressCityInfo.value=accReq.Address__City__s;

            UCD_ACM_AddressVerificationDataModel.AddressStateInfo addressStateInfo=new UCD_ACM_AddressVerificationDataModel.AddressStateInfo();
            addressStateInfo.value=accReq.Address__StateCode__s;

            UCD_ACM_AddressVerificationDataModel.AddressCountryInfo addressCountryInfo=new UCD_ACM_AddressVerificationDataModel.AddressCountryInfo();
            addressCountryInfo.value=accReq.Address__CountryCode__s;

            UCD_ACM_AddressVerificationDataModel.AddressZip5Info addressZip5Info=new UCD_ACM_AddressVerificationDataModel.AddressZip5Info();
            addressZip5Info.value=accReq.Address__PostalCode__s;

            UCD_ACM_AddressVerificationDataModel.Zipvalue zipVal=new UCD_ACM_AddressVerificationDataModel.Zipvalue();
            zipVal.Zip5=new List<UCD_ACM_AddressVerificationDataModel.AddressZip5Info>{addressZip5Info};

            UCD_ACM_AddressVerificationDataModel.AddressZipInfo addressZipInfo=new UCD_ACM_AddressVerificationDataModel.AddressZipInfo();
            addressZipInfo.value=zipVal;

            UCD_ACM_AddressVerificationDataModel.Attribute attribute=new UCD_ACM_AddressVerificationDataModel.Attribute();
            attribute.AddressLine1=new List<UCD_ACM_AddressVerificationDataModel.AddressLineInfo>{addressLineInfo};
            attribute.City=new List<UCD_ACM_AddressVerificationDataModel.AddressCityInfo>{addressCityInfo};
            attribute.StateProvince=new List<UCD_ACM_AddressVerificationDataModel.AddressStateInfo>{addressStateInfo};
            attribute.Country=new List<UCD_ACM_AddressVerificationDataModel.AddressCountryInfo>{addressCountryInfo};
            attribute.Zip=new List<UCD_ACM_AddressVerificationDataModel.AddressZipInfo>{addressZipInfo};

            UCD_ACM_AddressVerificationDataModel.RequestBody requestBody=new UCD_ACM_AddressVerificationDataModel.RequestBody();
            requestBody.type='configuration/entityTypes/CustomerLocation';
            requestBody.crosswalks=new List<UCD_ACM_AddressVerificationDataModel.RequestCrossWalk>{reqCrosswalk};
            requestBody.attributes=attribute;

            requestBodyList.add(requestBody);
        }
        return requestBodyList;
    }
    private static String callLoqateApi(String requestModel){
        Map < String , String > mapOfHeaders = new Map < String, String> {
            'Content-Type' => 'application/json' };
                
        String endPoint = 'callout:SalesCRM_Apigee/'+System.Label.Loqate_Api_EndPoint;

        System.debug('requestModel@@@'+requestModel);
        Core_RestClient restClient = new Core_RestClient(endPoint, Post_Method, mapOfHeaders, requestModel, Integer.valueOf(System.Label.Reltio_Timeout));
        restClient.invokeAPI();

        return restClient.getHttpResponseBody();
    }

    private static Map<Id,Account_Create_Request__c> responseMapping(UCD_ACM_AddressVerificationDataModel.ResponseBody responseBody,Account_Create_Request__c accountRequest,Map<string,string> countryMap){
        List<Account_Create_Request__c> accountRequestList=new  List<Account_Create_Request__c>();
        Map<Id,Account_Create_Request__c> mapOfaccountRquestUpdate=new Map<Id,Account_Create_Request__c>();
        Map<Id,String> mapOfVerificationStatus=new Map<Id,String>();
        List<String> responseStatus = System.Label.LoqateApi_Response_Status.split(',');
        for(UCD_ACM_AddressVerificationDataModel.AddressVerificationstatus status:responseBody.attributes.VerificationStatus){
            if(status.ov=='true'){
                accountRequest.Standardized_Address_VerificationStatus__c=status.value;
                mapOfaccountRquestUpdate.put(accountRequest.Id,accountRequest);
            }
            if((status.ov=='true') && (!responseStatus.contains(status.value))){
                mapOfaccountRquestUpdate=mapResponseToAccountRequest(mapOfaccountRquestUpdate,responseBody,accountRequest,countryMap);
            }
        }
        System.debug('@@mapOfaccountRquestUpdate '+mapOfaccountRquestUpdate);
        return mapOfaccountRquestUpdate;
    }

    private static Map<Id,Account_Create_Request__c> mapResponseToAccountRequest(Map<Id,Account_Create_Request__c> mapOfaccountRequestRespone,UCD_ACM_AddressVerificationDataModel.ResponseBody responseBody,Account_Create_Request__c accountRequest,Map<string,string> countryMap){
        if(responseBody.attributes.AddressLine1!=null){
            for(UCD_ACM_AddressVerificationDataModel.ResponseAddressLineInfo street:responseBody.attributes.AddressLine1){
                if(street.ov=='true'){
                    //accountRequest.Standardized_Address_Street__c=street.value;
                    mapOfaccountRequestRespone.put(accountRequest.Id,accountRequest);
                }
            }
        }
        else{
            //accountRequest.Standardized_Address_Street__c='';
            mapOfaccountRequestRespone.put(accountRequest.Id,accountRequest);
        }

        if(responseBody.attributes.City!=null){
            for(UCD_ACM_AddressVerificationDataModel.ResponseAddressCityInfo city:responseBody.attributes.City){
                if(city.ov=='true'){
                    accountRequest.Standardized_Address_City__c=city.value;
                    mapOfaccountRequestRespone.put(accountRequest.Id,accountRequest);
                }
            }
        }

        if(responseBody.attributes.Country!=null){
            for(UCD_ACM_AddressVerificationDataModel.ResponseAddressCountryInfo country:responseBody.attributes.Country){
                if(country.ov=='true'){
                    accountRequest.Standardized_Address_Country__c=country.value;
                    accountRequest.Standardized_Address_Country_Code__c=countryMap.get(country.value);
                    mapOfaccountRequestRespone.put(accountRequest.Id,accountRequest);
                }
            }
        }

        if(responseBody.attributes.StateProvince!=null){
            for(UCD_ACM_AddressVerificationDataModel.ResponseAddressStateInfo state:responseBody.attributes.StateProvince){
                if(state.ov=='true'){
                    accountRequest.Standardized_Address_State__c=state.value;
                    if(state.lookupCode!=null){
                        List<String> stateLookUpValue=state.lookupCode.split('_');
                        accountRequest.Standardized_Address_State_Code__c=stateLookUpValue[1];
                    }
                    else{
                        accountRequest.Standardized_Address_State_Code__c='';
                    }
                    mapOfaccountRequestRespone.put(accountRequest.Id,accountRequest);
                }
            }
        }

        if(responseBody.attributes.Zip!=null){
            for(UCD_ACM_AddressVerificationDataModel.ResponseAddressZipInfo zip:responseBody.attributes.Zip){
                if(zip.value.Zip5!=null){
                    for(UCD_ACM_AddressVerificationDataModel.ResponseAddressZip5Info zip5Info:zip.value.Zip5){
                        if(zip5Info.ov=='true'){
                            accountRequest.Standardized_Address_Postal_Code__c=zip5Info.value;
                            mapOfaccountRequestRespone.put(accountRequest.Id,accountRequest);
                        }
                    }
                }
                else if(zip.value.PostalCode!=null){
                    for(UCD_ACM_AddressVerificationDataModel.ResponseAddressPostalCodeInfo postalInfo:zip.value.PostalCode){
                        if(postalInfo.ov=='true'){
                            accountRequest.Standardized_Address_Postal_Code__c=postalInfo.value;
                            mapOfaccountRequestRespone.put(accountRequest.Id,accountRequest);
                        }
                    }
                }
            }
        }
        return mapOfaccountRequestRespone;
    }
    @AuraEnabled
    public static LoqateResponseDataModel addressVerification(String streetName,String cityName, String stateName, String countryName, String postalCode){
        List<UCD_ACM_AddressVerificationDataModel.RequestBody> addressRequestBodyList=new List<UCD_ACM_AddressVerificationDataModel.RequestBody>();
        List<UCD_ACM_AddressVerificationDataModel.ResponseBody> loqateResponseBodyList=new List<UCD_ACM_AddressVerificationDataModel.ResponseBody>();
        LoqateResponseDataModel loqateDataResponse=new LoqateResponseDataModel();
        Map<string,string> countryMap = new map<String,String>();
        for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
            countryMap.put(allCountries.Name, allCountries.ISO_Code__c);
        }
        try{
            String finalresponseJson;
            addressRequestBodyList=buildRequestBody(streetName,cityName,stateName,countryName,postalCode);
            if(!addressRequestBodyList.isEmpty()){
                String requestBodyJson=Json.serialize(addressRequestBodyList);
                finalresponseJson=callLoqateApi(requestBodyJson);
            }
            if(String.isNotBlank(finalresponseJson)){
                loqateResponseBodyList=(List<UCD_ACM_AddressVerificationDataModel.ResponseBody>) System.JSON.deserialize(finalresponseJson,List<UCD_ACM_AddressVerificationDataModel.ResponseBody>.class);
            }
            if(!loqateResponseBodyList.isEmpty()){
                for(UCD_ACM_AddressVerificationDataModel.ResponseBody response: loqateResponseBodyList){
                    loqateDataResponse=mapResponse(response,countryMap);
                }
            }
        }
        catch(Exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_AddressVerificationOnReqstQueue','addressVerification','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
        System.debug('@@ClistofLoqateresponse '+loqateDataResponse);
        return loqateDataResponse;
    }

    public static List<UCD_ACM_AddressVerificationDataModel.RequestBody> buildRequestBody(String streetName,String cityName, String stateName, String countryName, String postalCode){
        List<UCD_ACM_AddressVerificationDataModel.RequestBody> requestBodyList=new List<UCD_ACM_AddressVerificationDataModel.RequestBody>();
        UCD_ACM_AddressVerificationDataModel.RequestCrossWalk reqCrosswalk=new UCD_ACM_AddressVerificationDataModel.RequestCrossWalk();
        reqCrosswalk.type='configuration/sources/Salesforce';
        reqCrosswalk.value='SfdcId';

        UCD_ACM_AddressVerificationDataModel.AddressLineInfo addressLineInfo=new UCD_ACM_AddressVerificationDataModel.AddressLineInfo();
        addressLineInfo.value=streetName;

        UCD_ACM_AddressVerificationDataModel.AddressCityInfo addressCityInfo=new UCD_ACM_AddressVerificationDataModel.AddressCityInfo();
        addressCityInfo.value=cityName;

        UCD_ACM_AddressVerificationDataModel.AddressStateInfo addressStateInfo=new UCD_ACM_AddressVerificationDataModel.AddressStateInfo();
        addressStateInfo.value=stateName;

        UCD_ACM_AddressVerificationDataModel.AddressCountryInfo addressCountryInfo=new UCD_ACM_AddressVerificationDataModel.AddressCountryInfo();
        addressCountryInfo.value=countryName;

        UCD_ACM_AddressVerificationDataModel.AddressZip5Info addressZip5Info=new UCD_ACM_AddressVerificationDataModel.AddressZip5Info();
        addressZip5Info.value=postalCode;

        UCD_ACM_AddressVerificationDataModel.Zipvalue zipVal=new UCD_ACM_AddressVerificationDataModel.Zipvalue();
        zipVal.Zip5=new List<UCD_ACM_AddressVerificationDataModel.AddressZip5Info>{addressZip5Info};

        UCD_ACM_AddressVerificationDataModel.AddressZipInfo addressZipInfo=new UCD_ACM_AddressVerificationDataModel.AddressZipInfo();
        addressZipInfo.value=zipVal;

        UCD_ACM_AddressVerificationDataModel.Attribute attribute=new UCD_ACM_AddressVerificationDataModel.Attribute();
        attribute.AddressLine1=new List<UCD_ACM_AddressVerificationDataModel.AddressLineInfo>{addressLineInfo};
        attribute.City=new List<UCD_ACM_AddressVerificationDataModel.AddressCityInfo>{addressCityInfo};
        attribute.StateProvince=new List<UCD_ACM_AddressVerificationDataModel.AddressStateInfo>{addressStateInfo};
        attribute.Country=new List<UCD_ACM_AddressVerificationDataModel.AddressCountryInfo>{addressCountryInfo};
        attribute.Zip=new List<UCD_ACM_AddressVerificationDataModel.AddressZipInfo>{addressZipInfo};

        UCD_ACM_AddressVerificationDataModel.RequestBody requestBody=new UCD_ACM_AddressVerificationDataModel.RequestBody();
        requestBody.type='configuration/entityTypes/CustomerLocation';
        requestBody.crosswalks=new List<UCD_ACM_AddressVerificationDataModel.RequestCrossWalk>{reqCrosswalk};
        requestBody.attributes=attribute;

        requestBodyList.add(requestBody);

        return requestBodyList;
    }
    public static LoqateResponseDataModel mapResponse(UCD_ACM_AddressVerificationDataModel.ResponseBody response,Map<string,string> countryMap){
        LoqateResponseDataModel loqateApiDataResponse=new LoqateResponseDataModel();
        for(UCD_ACM_AddressVerificationDataModel.AddressVerificationstatus status:response.attributes.VerificationStatus){
            if(status.ov=='true'){
                loqateApiDataResponse.verificationStatus=status.value;
            }
        }
        if(response.attributes.AddressLine1!=null){
            for(UCD_ACM_AddressVerificationDataModel.ResponseAddressLineInfo street:response.attributes.AddressLine1){
                if(street.ov=='true'){
                    loqateApiDataResponse.streetName=street.value;
                }
            }
        }
        if(response.attributes.City!=null){
            for(UCD_ACM_AddressVerificationDataModel.ResponseAddressCityInfo city:response.attributes.City){
                if(city.ov=='true'){
                    loqateApiDataResponse.cityName=city.value;
                }
            }
        }

        if(response.attributes.Country!=null){
            for(UCD_ACM_AddressVerificationDataModel.ResponseAddressCountryInfo country:response.attributes.Country){
                if(country.ov=='true'){
                    loqateApiDataResponse.countryValue=country.value;
                    loqateApiDataResponse.countryName=countryMap.get(country.value);
                }
            }
        }

        if(response.attributes.StateProvince!=null){
            for(UCD_ACM_AddressVerificationDataModel.ResponseAddressStateInfo state:response.attributes.StateProvince){
                if(state.ov=='true'){
                    loqateApiDataResponse.stateValue=state.value;
                }
                if(state.ov=='true' && state.lookupCode!=null){
                    List<String> stateLookUpValue=state.lookupCode.split('_');
                    loqateApiDataResponse.stateName=stateLookUpValue[1];
                }
            }
        }

        if(response.attributes.Zip!=null){
            for(UCD_ACM_AddressVerificationDataModel.ResponseAddressZipInfo zip:response.attributes.Zip){
                if(zip.value.Zip5!=null){
                    for(UCD_ACM_AddressVerificationDataModel.ResponseAddressZip5Info zip5Info:zip.value.Zip5){
                        if(zip5Info.ov=='true'){
                            loqateApiDataResponse.postalCode=zip5Info.value;
                        }
                    }
                }
                else if(zip.value.PostalCode!=null){
                    for(UCD_ACM_AddressVerificationDataModel.ResponseAddressPostalCodeInfo postalInfo:zip.value.PostalCode){
                        if(postalInfo.ov=='true'){
                            loqateApiDataResponse.postalCode=postalInfo.value;
                        }
                    }
                }
            }
        }
        System.debug('@@loqateApiData '+loqateApiDataResponse);
        return loqateApiDataResponse;
    }
    public class LoqateResponseDataModel{
        @AuraEnabled
        public String streetName{set;get;}
        @AuraEnabled
        public String countryName{set;get;}
        @AuraEnabled
        public String countryValue{set;get;}
        @AuraEnabled
        public String stateName{set;get;}
        @AuraEnabled
        public String stateValue{set;get;}
        @AuraEnabled
        public String cityName{set;get;}
        @AuraEnabled
        public String postalCode{set;get;}
        @AuraEnabled
        public String verificationStatus{set;get;}
    }
}