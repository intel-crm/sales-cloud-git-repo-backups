public without sharing class UCD_ACM_ReltioService implements UCD_ACM_ServiceContracts.IMDMService {
    private static UCD_ACM_ServiceContracts.IMDMService instance = null;
    public static final String Post_Method = 'POST';

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
     * description : Serialize request
     * params : UCD_ACM_Models.SearchRequest RequestModel
     * return : String
     * author and date : ankit1x.sharma@intel.com, 22 Jun 2022
     */
    private  String parseRequestBody(UCD_ACM_Models.SearchRequest RequestModel){
        String  RequestJson = Json.serialize(RequestModel);
        return RequestJson ;
    }
    
     /*
     * description : Search API calling And mapping the response
     * params : UCD_ACM_Models.SearchRequest requestPayload
     * return : String
     * author and date : ankit1x.sharma@intel.com, 22 Jun 2022
     */

    public List<UCD_ACM_Models.ReltioResponse> searchAccountReltio(UCD_ACM_Models.SearchRequest requestPayload){
        List<UCD_ACM_Models.ReltioResponse> finalResponses = new List<UCD_ACM_Models.ReltioResponse>();
        try{
            String finalResponseJson = '';
            UCD_ACM_Models.list_items responseFromReltio ;

            if(requestPayload != null){
                finalResponseJson = callAPI(parseRequestBody(requestPayload));
            }
            
            if(String.isNotBlank(finalResponseJson)){
                responseFromReltio  = (UCD_ACM_Models.list_items) System.JSON.deserialize(finalResponseJson, UCD_ACM_Models.list_items.class);   
            }
            finalResponses = mappingResponse(responseFromReltio);

            
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_ReltioService','searchAccountReltio','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }
        return finalResponses;
    }
    
    /*
     * description : Search API calling 
     * params : String  requestModel
     * return : String
     * author and date : ankit1x.sharma@intel.com, 22 Jun 2022
     */
    private String callAPI(String  requestModel){
        Map < String , String > mapofHader = new Map < String, String> {
                'Content-Type' => 'application/json' };
                    
        String endPointReltio = 'callout:SalesCRM_Apigee/ucd/v1/sbr';

        UCD_ACM_Logger.information('UCD_ACM_ReltioService', 'callAPI', 'Reltio API Payload - '+requestModel, 'SBR');

        Core_RestClient restClient1 = new Core_RestClient(endPointReltio, Post_Method, mapofHader, requestModel, Integer.valueOf(System.Label.Reltio_Timeout));
        restClient1.invokeAPI();

        return restClient1.getHttpResponseBody();
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
}