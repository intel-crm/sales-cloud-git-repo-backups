/**************************************************************************************
Apex Class Name  : UCD_ACM_ReltioService
Author And Date  : Ankit Sharma, 22 June 2022
Function         : This class has code WRT to Reltio API calls
Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Ankit Sharma              22/06/2022              Created
* Chethan Kunder            22/05/2024              Added code WRT Entity Update APIs
* Rajveer Ranawat           20/06/2024              Added code WRT Update APIs
***************************************************************************************/
public without sharing class UCD_ACM_ReltioService implements UCD_ACM_ServiceContracts.IMDMService {
    private static UCD_ACM_ServiceContracts.IMDMService instance = null;
    public static final String HTTP_POST = 'POST';
    private static final String SBR_API = '/ucd/v1/sbr';
    private static final String UPDATE_API = '/ucd/v1/crosswalks/{0}';
    public static final string HTTP_PATCH = 'PATCH';  
    
    //Deafult Constrctor
    public UCD_ACM_ReltioService() {
    }
    
    public static UCD_ACM_ServiceContracts.IMDMService getInstance(){
        if (instance  == null){
            instance  = new UCD_ACM_ReltioService();
        }
        return instance;
    }
    
    /*
* description : Reltio API Call
* params : String request
* return : Core_RestClient
* author and date : ankit1x.sharma@intel.com, 22 Jun 2022
* Updated: chethan.s.kunder@intel.com, 22 May 2024
*/
    private Core_RestClient callAPI(String request, String endPoint,string HTTP){
        Map<String,String> mapofHader = new Map<String,String> { 'Content-Type' => 'application/json' };
            List<Object> endPointParams = new List<Object> { endPoint };
                String apiURI = String.format('callout:SalesCRM_Apigee{0}', endPointParams);
        UCD_ACM_Logger.information('UCD_ACM_ReltioService', 'callAPI', 'Reltio API Payload - '+request, 'SBR');
        Core_RestClient restClient = new Core_RestClient(apiURI, HTTP, mapofHader, request, Integer.valueOf(System.Label.Reltio_Timeout));
        restClient.invokeAPI();
        return restClient;
    }
    
    /*
* description : Serialize request
* params : UCD_ACM_Models.SearchRequest RequestModel
* return : String
* author and date : ankit1x.sharma@intel.com, 22 Jun 2022
*/
    private String parseRequestBody(UCD_ACM_Models.SearchRequest RequestModel){
        String  RequestJson = Json.serialize(RequestModel);
        return RequestJson ;
    }
    
    /*
* description : Serialize update request
* params : UCD_ACM_ReltioModels.UpdateRequest requestModel
* return : String
*/
    private String parseRequestBodyForUpdateApi(UCD_ACM_ReltioModels.UpdateRequest updateRequest){
        String requestJson = Json.serialize(updateRequest);
        return requestJson ;
    }
    
    /*
* description : Search API calling And mapping the response
* params : UCD_ACM_Models.SearchRequest requestPayload
* return : String
* author and date : ankit1x.sharma@intel.com, 22 Jun 2022
* Updated : chethan.s.kunder@intel.com, 23 May, 2024
*/
    public List<UCD_ACM_Models.ReltioResponse> searchAccountReltio(UCD_ACM_Models.SearchRequest requestPayload){
        List<UCD_ACM_Models.ReltioResponse> finalResponses = new List<UCD_ACM_Models.ReltioResponse>();
        try{
            String finalResponseJson = '';
            UCD_ACM_Models.list_items responseFromReltio;
            Core_RestClient rawResponse = new Core_RestClient();
            
            if(requestPayload != null){
                rawResponse = callAPI(parseRequestBody(requestPayload), SBR_API, HTTP_POST);
                finalResponseJson = rawResponse.getHttpResponseBody();
            }
            
            if(checkIfResponseHasError(rawResponse.getHttpResponseStatusCode())) {
                UCD_GenericAcctSearch_SBR.setErrorMessage('Reltio API Response: '+'Status Code: '+rawResponse.getHttpResponseStatusCode()+' Status message: '+rawResponse.getHttpResponseStatus());
            } else if(String.isNotBlank(finalResponseJson)){
                responseFromReltio  = (UCD_ACM_Models.list_items) System.JSON.deserialize(finalResponseJson, UCD_ACM_Models.list_items.class);   
            }
            finalResponses = mappingResponse(responseFromReltio);
            
        } catch(Exception ex){
            UCD_GenericAcctSearch_SBR.setErrorMessage(String.valueOf(ex.getMessage()));
            UCD_ACM_Logger.error('UCD_ACM_ReltioService','searchAccountReltio','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        } finally{
            UCD_ACM_Logger.setLogDetails();
        }
        
        return finalResponses;
    }
    
    /*
* description : Mapping the responses into the wrapper. 
* params : UCD_ACM_Models.list_items responseFromReltio
* return : List<UCD_ACM_Models.ReltioResponse> 
* author and date : ankit1x.sharma@intel.com, 22 Jun 2022
*/
    
    private List<UCD_ACM_Models.ReltioResponse> mappingResponse(UCD_ACM_Models.list_items responseFromReltio){
        List<UCD_ACM_Models.ReltioResponse> finalResponses = new List<UCD_ACM_Models.ReltioResponse>();
        if(responseFromReltio != null && responseFromReltio.list_items != null){
            for(UCD_ACM_Models.ReltioResponsesAPI reltioresponse : responseFromReltio.list_items){
                UCD_ACM_Models.ReltioResponse modelResponse = new UCD_ACM_Models.ReltioResponse();
                modelResponse.Uri = reltioresponse.uri ;
                modelResponse.Relevance = reltioresponse.relevance;
                modelResponse.CustomerAggregationType =reltioresponse.CustomerAggregationTypeCd ;
                modelResponse.WebsiteURL = reltioresponse.WebsiteURL;
                modelResponse.Addresses = reltioresponse.Addresses;
                modelResponse.CustomerProcessEngagementCode = reltioresponse.CustomerProcessEngagement ;
                modelResponse.BusinessPartyId = (reltioresponse.Record_Label.split(' \\| ').size()>0 ? reltioresponse.Record_Label.split(' \\| ')[0]:null); 
                String sName = (reltioresponse.Record_Label.split(' \\|').size()>1  ? reltioresponse.Record_Label.split(' \\|')[1] : null);
                modelResponse.Name = ((sName != null)?sName.trim():null) ;
                List<UCD_ACM_Models.BusinessOrganisationName> businessOrgNames = new List<UCD_ACM_Models.BusinessOrganisationName>();
                for(UCD_ACM_Models.BusinessOrganizationNameAPI  businessorg : reltioresponse.BusinessOrganizationName){
                    UCD_ACM_Models.BusinessOrganisationName businessOrgName = new UCD_ACM_Models.BusinessOrganisationName();
                    businessOrgName.Name = businessorg.BusinessOrganizationNm;
                    businessOrgName.Type = businessorg.BusinessNameTypeCd;
                    businessOrgNames.add(businessOrgName);
                }
                
                modelResponse.BusinessOrganisationNames = businessOrgNames;
                List<UCD_ACM_Models.ParentDetail> PrentDatas = new List<UCD_ACM_Models.ParentDetail>();
                if(reltioresponse.AggregateParent != null){
                    for(UCD_ACM_Models.AggregateParent  aggregateParent : reltioresponse.AggregateParent){
                        UCD_ACM_Models.ParentDetail ParentData = new UCD_ACM_Models.ParentDetail();
                        
                        ParentData.ParentBusinessPartyId = (aggregateParent.label.split(' \\| ').size()>0 ? aggregateParent.label.split(' \\| ')[0]:null);
                        string parentName= (aggregateParent.label.split(' \\|').size()>1 ? aggregateParent.label.split(' \\|')[1] : null);
                        ParentData.ParentName = ((parentName!= null) ? parentName.trim(): null);
                        ParentData.ParentAccountType = aggregateParent.relationshipLabel;
                        PrentDatas.add(ParentData);
                    }
                }
                modelResponse.ParentDetails = PrentDatas;
                finalResponses.add(modelResponse);
            }
        }
        return finalResponses;
    }
    
    /*
* description : Check if reltio response has Error
* params : Integer
* return : Boolean
* author and date : ajayx.gat@intel.com, 9 Feb 2024
*/
    private Boolean checkIfResponseHasError(Integer responseCode){
        Map<String, UCD_Reltio_SBR_API_Response__c> ucdResponseSettings = UCD_Reltio_SBR_API_Response__c.getAll();
        if(ucdResponseSettings.containsKey(String.valueOf(responseCode))) {
            return ucdResponseSettings.get(String.valueOf(responseCode)).UCD_Is_Error__c;
        }
        return false;
    }
    
    
    /*  Description : Reltio entity update API call and getting response
*   Params  :  List<UCD_ACM_ReltioModels.UpdateRequest> updateRequests
*   Returns :  List<UCD_ACM_ReltioModels.UpdateResponseModel>
*   Author and date : rajveer.ranawat@intel.com, 23 May, 2024  */
    public List<UCD_ACM_ReltioModels.UpdateResponseModel> updateEntity(Map<String, UCD_ACM_ReltioModels.UpdateRequest> updateRequests) {
        List<UCD_ACM_ReltioModels.UpdateResponseModel> listResponse = new List<UCD_ACM_ReltioModels.UpdateResponseModel>();
        Map<String, Object> accountIdAndResponse = new Map<String, object>();
        String response='';
        try {
            Core_RestClient rawResponse = new Core_RestClient();
            for(String key:updateRequests.keySet()) {
                rawResponse = callAPI(parseRequestBodyForUpdateApi(updateRequests.get(key)), String.format(UPDATE_API, new List<String>{key.split(':')[0]}), HTTP_PATCH);
                accountIdAndResponse.put(updateRequests.get(key).value, rawResponse);
                response = rawResponse.getHttpResponseBody();
                Object deserializedList = (Object) JSON.deserializeUntyped(response);
                // Map<String, Object> dataMap = (Map<String, Object>)deserializedList;
                accountIdAndResponse.put(updateRequests.get(key).value, deserializedList);
                if(rawResponse.getHttpResponseStatusCode() != 200){
                    UCD_ACM_Logger.error('UCD_ACM_ReltioService','updateEntity','Message: '+(String) ((Map<String, Object>)deserializedList).get('message')+'. statusCode: '+String.valueOf(rawResponse.getHttpResponseStatusCode()),key.split(':')[1]);
                }
                
            }
            
            for(String accid:accountIdAndResponse.keyset()){
                // Map<String, Object> dataMap = (Map<String, Object>)accountIdAndResponse.get(accid);
                UCD_ACM_ReltioModels.UpdateResponseModel updateResponseModel = new UCD_ACM_ReltioModels.UpdateResponseModel();  
                if(accountIdAndResponse.get(accid)!=null && (String) ((Map<String, Object>) accountIdAndResponse.get(accid)).get('status')== 'modified'){
                    updateResponseModel.accountid = accid;
                    updateResponseModel.status = (String) ((Map<String, Object>) accountIdAndResponse.get(accid)).get('status');
                }
                else {  
                    updateResponseModel.accountid = accid;
                    updateResponseModel.status = (String) ((Map<String, Object>) accountIdAndResponse.get(accid)).get('status');
                    updateResponseModel.errorDescription =(String) ((Map<String, Object>) accountIdAndResponse.get(accid)).get('message');   
                    
                    
                }
                listResponse.add(updateResponseModel);
            } 
        }catch(Exception ex) {
            String accountIds = String.join(new List<String>(accountIdAndResponse.keySet()), ', ');
            UCD_ACM_Logger.error('UCD_ACM_ReltioService','updateEntity','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString() +'.Response: '+response , accountIds);
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
        return listResponse;
    }
}