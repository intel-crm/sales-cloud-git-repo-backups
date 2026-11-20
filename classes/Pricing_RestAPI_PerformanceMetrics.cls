/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_PerformanceMetrics 
* Version     : 1.0 
* Created Date: 28 October 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         10/28/2020              Rest API to create/update Performance Metrics with no sections
Rest API to get performance metrics details as response

Sample API call:- /services/apexrest/v1.0/quoterequest/performancemetrics

Description=> Pass the quotelineId and performancemetrics as an input JSON and it will create the Performance Metrics
*****************************************************************************************************************************************/
@RestResource(urlMapping='/*/quoterequest/performancemetrics')
global with sharing class Pricing_RestAPI_PerformanceMetrics {
    
    public static String recId;
    public static String perfMetricsId;
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_PerformanceMetrics.class.getName();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    public static boolean isPatch = false;
    
    public static String quoteLineId1;
    
    @HttpPost
    global static Pricing_RestAPI_Response doPost(){
        try{
            RestRequest req = RestContext.request;
            Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDetails perfometrics = (Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDetails) JSON.deserialize(req.requestBody.toString(), Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDetails.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 utilObj = new Pricing_RestAPI_QuotesUtilityV2();
            boolean isValidMetric = utilObj.validatePerformanceMetricsWrapper(perfometrics, qErrorMsg);
            
            //validate performance metrics
            if(isValidMetric){
                List<Pricing_Performance_Metric__c> perfMetricsList = Pricing_RestAPI_QuotesUtilityV2.createPerformanceMetricsRecordDetails(perfometrics);
                if(perfMetricsList.size()>0){
                    insert perfMetricsList;     //create validated performance metrics
                    response.successContent = new List<Pricing_RestAPI_SuccessContent>();
                    Integer i = 1;
                    for(Pricing_Performance_Metric__c pm: perfMetricsList){
                        response.successContent.add(new CreatedPerformanceMetricsDetails(perfometrics.performanceMetrics[i-1].performanceMetricsReferenceId,pm.Id));
                        i++;
                    }
                    response.totalRecords = i-1;
                }
            }
            else{
                Pricing_RestAPI_Util.quoteErrMsgsV2 = qErrorMsg;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,Pricing_RestAPI_QuotesUtilityV2.currentUser);            
        }
        return response;
    }
    
    public class CreatedPerformanceMetricsDetails implements Pricing_RestAPI_SuccessContent {   
        public String performanceMetricsId {set;get;} 
        public String performanceMetricsReferenceId {set;get;}
        public CreatedPerformanceMetricsDetails(String reference, String recId){
            performanceMetricsReferenceId = reference;
            performanceMetricsId = recId;
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------------------
    @httpPatch
    global static Pricing_RestAPI_Response updatePM(){
        try{
            isPatch = true;
            RestRequest req = RestContext.request;
            Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDetails perfometrics = (Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDetails) JSON.deserialize(req.requestBody.toString(), Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDetails.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 utilObj = new Pricing_RestAPI_QuotesUtilityV2();
            boolean isValidMetric = utilObj.validatePerformanceMetricsWrapper(perfometrics, qErrorMsg);
            if(isValidMetric){
                //valid Performance metrics
                updatePerfMetrics(perfometrics);
            }
            else{
                //Invalid Performance metrics
                Pricing_RestAPI_Util.quoteErrMsgsV2 = qErrorMsg;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,Pricing_RestAPI_QuotesUtilityV2.currentUser);            
        }    
        isPatch = false;
        return response;      
    }
    
    public static void updatePerfMetrics(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDetails pmWrapper){
        List<Pricing_Performance_Metric__c> pmList= new List<Pricing_Performance_Metric__c>();
        Pricing_RestAPI_QuotesUtilityV2.createPerformanceMetricsRecord(pmWrapper.quoteLineId, pmWrapper.performanceMetrics, pmList);   
        if(pmList.size() > 0) {
            update pmList;      //update existing performance metrics record if Id is provided in JSON else insert new record
        }
        Integer i = 1;
        response.successContent = new List<UpdatedPerformanceMetricsDetails>();
        for(Pricing_Performance_Metric__c metric : pmList){
            response.successContent.add(new UpdatedPerformanceMetricsDetails(metric.Id, pmWrapper.performanceMetrics[i-1].performanceMetricsReferenceId));
            i++;
        }
        response.totalRecords=pmList.size();
    }
    public class UpdatedPerformanceMetricsDetails implements Pricing_RestAPI_SuccessContent {
        public String performanceMetricsId {set;get;} 
        public String performanceMetricsReferenceId {set;get;} 
        public UpdatedPerformanceMetricsDetails(String recId, String refId){
            performanceMetricsId = recId;
            performanceMetricsReferenceId = refId;
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------------------
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
            user currentUser = [SELECT id,Name,AccountId,ContactId,Email FROM User WHERE id= :UserInfo.getUserId()];
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,currentUser);            
        }        
        return response;
    }
    
    //to check weather request is valid or not
    private static boolean validateRequest(){
        boolean isValid=false;
        RestRequest restReq = RestContext.request;
        recId = restReq.params.get('id');
        if(!String.isBlank(recId)){            
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
    public static Pricing_RestAPI_QuoteDetailsWrapperV2.PerformanceMetricsDetailWrapper getPerformanceMetricsDetailsWrapper(Pricing_Performance_Metric__c pm){
        Pricing_RestAPI_QuoteDetailsWrapperV2.PerformanceMetricsDetailWrapper pmetric = new Pricing_RestAPI_QuoteDetailsWrapperV2.PerformanceMetricsDetailWrapper();
        pmetric.performanceMetricsId= pm.Id;
        pmetric.performanceMetricsUsed = pm.Pricing_Performance_Metric_Nm__c;
        pmetric.intelScore = pm.Pricing_Intel_SKU_Performance_Nbr__c.setScale(2);
        pmetric.compScore = pm.Pricing_Comp_SKU_Performance_Nbr__c.setScale(2);
        pmetric.weighting = pm.Pricing_Weighting_Pct__c;
        pmetric.otherText = pm.Pricing_Other_Nm__c;
        pmetric.quotelineId = pm.Pricing_Quote_Line__c;
        pmetric.quotelineNumber = pm.Pricing_Quote_Line__r.Pricing_Quote_Line_Number__c;
        return pmetric;
    }
    
    public class CreatedPMDetails implements Pricing_RestAPI_SuccessContent {
        public Pricing_RestAPI_QuoteDetailsWrapperV2.PerformanceMetricsDetailWrapper performanceMetrics {set;get;}
        public CreatedPMDetails(Pricing_RestAPI_QuoteDetailsWrapperV2.PerformanceMetricsDetailWrapper pm){
            performanceMetrics = pm;
        }
    }
    
    
}