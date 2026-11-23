/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_GetPerfMetricsDetails 
* Version     : 1.0 
* Created Date: 20 Nov 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         11/20/2020              Rest API to get performance metrics details as response

Sample API call:- /services/apexrest/v1.0/quoterequest/getperformancemetricsdetails?id=
id => Performance Metrics Id

Description=> Pass the Performance Metrics Id in the url and this will return performanceMetrics details as response
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/quoterequest/getperformancemetricsdetails123')
global without sharing class Pricing_RestAPI_GetPerfMetricsDetails123 {

    public static String recId;
    public static String perfMetricsId;
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_PickList.class.getName();
    
    @HttpGet
    global static Pricing_RestAPI_Response doGet(){
        try{
            if(validateRequest()){
                //Valid Request
                getAllPMDetails();
            }else{
                //Not a Valid Request
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response);            
        }        
        return response;
    }
    
    //to check weather request is valid or not
    private static boolean validateRequest(){
        boolean isValid=false;
        RestRequest restReq = RestContext.request;
        recId = restReq.params.get('id');
        if(!String.isEmpty(recId)){            
            try{
                perfMetricsId = Id.valueOf(recId);
                isValid = true;
            }catch(Exception exp){
                Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return isValid;
    }
    
    //to get all PM details
    public static void getAllPMDetails(){
        String pmQuery = label.Pricing_RestAPI_GetPerfMetricsDetailsQuery;
        Pricing_Performance_Metric__c pmetrics= Database.query(pmQuery);
        response.successContent = new List<CreatedPMDetails>();
        response.successContent.add(new CreatedPMDetails(getPerformanceMetricsDetailsWrapper(pmetrics)));
        response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200;
        response.totalRecords = 1;
    }
    
    //to form a performance metrics wrapper
    public static Pricing_RestAPI_QuoteDetailsWrapper.PerformanceMetricsDetailWrapper getPerformanceMetricsDetailsWrapper(Pricing_Performance_Metric__c pm){
        Pricing_RestAPI_QuoteDetailsWrapper.PerformanceMetricsDetailWrapper pmetric = new Pricing_RestAPI_QuoteDetailsWrapper.PerformanceMetricsDetailWrapper();
        pmetric.performanceMetricsId= pm.Id;
        pmetric.performanceMetricsUsed = pm.Pricing_Performance_Metric_Nm__c;
        pmetric.intelScore = pm.Pricing_Intel_SKU_Performance_Nbr__c;
        pmetric.compScore = pm.Pricing_Comp_SKU_Performance_Nbr__c;
        pmetric.weighting = pm.Pricing_Weighting_Pct__c;
        pmetric.otherText = pm.Pricing_Other_Nm__c;
        pmetric.quotelineId = pm.Pricing_Quote_Line__c;
        return pmetric;
    }
    
    public class CreatedPMDetails implements Pricing_RestAPI_SuccessContent {
        public Pricing_RestAPI_QuoteDetailsWrapper.PerformanceMetricsDetailWrapper performanceMetrics {set;get;}
        public CreatedPMDetails(Pricing_RestAPI_QuoteDetailsWrapper.PerformanceMetricsDetailWrapper pm){
            performanceMetrics = pm;
        }
    }
}