/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_GetQuoteLineDetails 
* Version     : 1.0 
* Created Date: 20 Nov 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         20/11/2020              Rest API to get quoteLine fields and its performance metrics as response

Sample API call:- /services/apexrest/v1.0/quoterequest/getquotelinedetails?type=&id=
type => quoteLine (fetch quoteLine details only i.e, section 2 details)
type => blank or all (fetch section 2 and section 3 details)
id=>quoteLineId

Description=> Pass the type and quoteLineId as an url input and it will return quoteDetails
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/quoterequest/getquotelinedetails')
global with sharing class Pricing_RestAPI_GetQuoteLineDetails {
    public static String reqtype;
	public static String recId;
    public static Id quoteLineId;
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    public static QuoteLineWrapper quoteLineWrapper = new QuoteLineWrapper();
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_PickList.class.getName();
    public static Map<Id, List<Pricing_Performance_Metric__c>> pmMap = new Map<Id, List<Pricing_Performance_Metric__c>>();
    
    @HttpGet
    global static Pricing_RestAPI_Response doGet(){
        try{
            if(validateRequest()){
                //Valid Request
                fetchQuoteLineDetails();
            }else{
                //Not a Valid Request
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response);            
        } 
        return response;
    }
    
    private static boolean validateRequest(){
        boolean isValid=false;
        RestRequest restReq = RestContext.request;
        reqtype = Pricing_RestAPI_Util.getRequestParam('type');
        recId = Pricing_RestAPI_Util.getRequestParam('id');
        if(!String.isEmpty(recId) && (String.isEmpty(reqtype) || reqtype.toLowerCase() == 'all' || reqtype.toLowerCase() == 'quoteline')){
            try{
                quoteLineId = Id.valueOf(recId);	//check if the input record Id is a valid salesforce Id
                isValid=true;
            }catch(Exception  exp){
                isValid=false;
            }
        }
        if(!isValid){
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
        }       
        return isValid;
    }
    
    public static void fetchQuoteLineDetails(){
        List<SBQQ__QuoteLine__c> quoteLinesList = getAllQuoteLineDetails();
        if(quoteLinesList.size() > 0){
            quoteLineWrapper.quoteLineDetails = new Pricing_RestAPI_QuoteDetailsWrapper.QuoteLineDetails();
            //show quoteLinedetails and its performance Metrics
            getQuoteLineDetailsWrapper(quoteLinesList[0], quoteLineWrapper.quoteLineDetails);            
            response.successContent = new List<QuoteLineWrapper>();
            response.successContent.add(quoteLineWrapper);
            response.totalRecords= 1;
        }else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
        }
    } 
    
    public static List<SBQQ__QuoteLine__c> getAllQuoteLineDetails(){
        String query = Label.Pricing_RestAPI_GetQuoteLineQuery1;
        if(String.isEmpty(reqtype) || reqtype.toLowerCase() == 'all'){
            //if reqType is all add performance metrics subquery to quoteline query
            query = query + Label.Pricing_RestAPI_GetQuoteLineQuery2.replace('{{PMQUERY}}',label.Pricing_RestAPI_PMSubQuery);
        }else{
            //if reqType is quoteline remove placeholder string from query
            query = query + Label.Pricing_RestAPI_GetQuoteLineQuery2.replace('{{PMQUERY}}','');
        }
        return Database.query(query);  
    }
    
    public static void getQuoteLineDetailsWrapper(SBQQ__QuoteLine__c quoteLine, Pricing_RestAPI_QuoteDetailsWrapper.QuoteLineDetails qlDetails){
        qlDetails.quotelineId = quoteLine.id;
        qlDetails.quoteId = quoteLine.SBQQ__Quote__c;
        qlDetails.quote = quoteLine.SBQQ__Quote__r.Name;
        qlDetails.quoteLineNumber=quoteLine.Pricing_Quote_Line_Number__c;
        qlDetails.quoteLineStatus=quoteLine.Pricing_Status_Nm__c;
        qlDetails.changeRequest = quoteLine.Pricing_New_Change_Request_cb__c;//Pricing_New_Change_Request_cb__c//Pricing_Change_Request_cb__c
        qlDetails.approvedPricingStartDate= quoteLine.Pricing_Approved_Start_Date_Dt__c;
        qlDetails.approvedPricingEndDate=quoteLine.Pricing_Approved_End_Date_Dt__c;
        qlDetails.approvedQuantity = quoteLine.Pricing_Approved_Unit_Qty__c;
        qlDetails.effectivePricingStartDate = quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
        qlDetails.billingEndDate = quoteLine.Pricing_Billing_End_Date_Dt__c;
        qlDetails.billingStartDate = quoteLine.Pricing_Billing_Start_Date_Dt__c;
        qlDetails.additionalTermsandConditions = quoteLine.Pricing_Additional_T_C_s_Txt__c;
        qlDetails.newRequestedDiscountUnitPrice = quoteLine.Pricing_Request_Discount_Unit_Price_qty__c;
        qlDetails.competitiveBidDiscount = quoteLine.Pricing_Competitive_Bid_Discount_Pct__c;
        qlDetails.approvedECAPPrice = quoteLine.Pricing_ECAP_Price_Amt__c;
        qlDetails.dealId = quoteLine.Pricing_Deal_RFQ_Id__c;
        qlDetails.newQuantity = quoteLine.Pricing_New_Quantity_qty__c;
        qlDetails.readyForReview= quoteLine.Pricing_Ready_for_Review_cb__c;
        qlDetails.lastSubmittedDate = quoteLine.Pricing_Last_Submitted_Date_dt__c;
        qlDetails.approvedDate = quoteLine.Pricing_Last_Approved_Date_dt__c;
        qlDetails.lastSubmittedById = quoteLine.Pricing_Last_Submitted_By_Id__c;
        qlDetails.lastSubmittedByName = quoteLine.Pricing_Last_Submitted_By_Id__r.Name;
        qlDetails.quoteLinePricingEndDate = quoteLine.Pricing_End_Date_dt__c;
        qlDetails.productId=quoteLine.Pricing_Product_Nm__c;
        qlDetails.productName = quoteLine.SBQQ__ProductName__c;
        qlDetails.processorNumber = quoteLine.Pricing_Processor_Number_Nm__c;
        qlDetails.quantity = quoteLine.Pricing_Unit_Qty__c;
        qlDetails.writeInProduct=quoteLine.Pricing_Other_Product_Nm__c;
        qlDetails.systemModel=quoteLine.Pricing_OEM_System_Model_Nm__c;
        qlDetails.noOfSystems=quoteLine.Pricing_Systems_qty__c;
        qlDetails.noOfCPUsPerSystem = quoteLine.Pricing_CPUs_per_system_qty__c;
        qlDetails.singleSystemPrice =quoteLine.Pricing_Single_System_Price_Amt__c;
        qlDetails.customerStdUnitPrice=quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c;
        qlDetails.requestedDiscountUnitPrice=quoteLine.Pricing_Req_Discounted_Unit_Price__c;
        qlDetails.totalBidWithoutDiscount=quoteLine.Pricing_Total_Bid_without_Discount_Amt__c;
        qlDetails.netIntelBidPrice = quoteLine.Pricing_Net_IA_Bid_Price_Amt__c;
        qlDetails.intelDiscount = quoteLine.Pricing_Intel_Discount_Pct__c;
        qlDetails.customerDiscount = quoteLine.Pricing_OEM_Discount_Pct__c;
        qlDetails.totalIntelDiscount = quoteLine.Pricing_Total_Intel_Discount_Amt__c;
        qlDetails.intelBidDiscount = quoteLine.Pricing_IA_Bid_Discount_Pct__c;          
        qlDetails.additionalDiscount=quoteLine.Pricing_Additional_OEM_Discount_Amt__c;
        qlDetails.competitorName=quoteLine.Pricing_Competitor_OEM_Nm__c;
        qlDetails.competitorSystemModel=quoteLine.Pricing_Competitor_System_Model_Nm__c;
        qlDetails.competitorProductId=quoteLine.Pricing_Competetor_Product__c;
        qlDetails.competitorProductName = quoteLine.Pricing_Competetor_Product__r.Name;
        qlDetails.writeInCompetitorProduct=quoteLine.Pricing_Other_Competitor_Product_Nm__c;
        qlDetails.competitorProductProvider = quoteLine.Pricing_comp_Product_Provider_nm__c;
        qlDetails.competitorNoOfSystems = quoteLine.Pricing_Competitor_Systems_Cnt__c;
        qlDetails.competitorNoOfCPUsPerSystem = quoteLine.Pricing_Comp_CPUs_per_system_Cnt__c;
        qlDetails.competitorQuantity= quoteLine.Pricing_Comp_Units_Cnt__c;
        qlDetails.competitorSingleSystemPrice = quoteLine.Pricing_Comp_Single_System_Price_Amt__c;
        qlDetails.competitorAdditionalDiscount = quoteLine.Pricing_Comp_Additional_OEM_Disc_Amt__c;
        qlDetails.competitorTotalWithoutDiscount = quoteLine.Pricing_Comp_Total_without_discount_Amt__c;
        qlDetails.netCompetitorBidPrice = quoteLine.Pricing_Net_Comp_Bid_Price_Amt__c;
        qlDetails.additionalComments = quoteLine.Pricing_Additional_Comments_Txt__c; 
        qlDetails.referenceQuoteLineNumberId = quoteLine.Pricing_Reference_Quote_Line_Nbr__c;
        qlDetails.referenceQuoteLineNumber=quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c; 
        if(String.isEmpty(reqtype) || reqtype.toLowerCase() == 'all'){
            getPerformanceMetricsDetails(qlDetails, quoteLine.Performance_Metrics__r);
        }
    }
    
    public static void getPerformanceMetricsDetails(Pricing_RestAPI_QuoteDetailsWrapper.QuoteLineDetails qliWrapper, List<Pricing_Performance_Metric__c> perfMetrics){
        qliWrapper.performanceMetrics = new List<Pricing_RestAPI_QuoteDetailsWrapper.PerformanceMetricsWrapper>(); 
        for(Pricing_Performance_Metric__c pm : perfMetrics){
            Pricing_RestAPI_QuoteDetailsWrapper.PerformanceMetricsWrapper pmetric = new Pricing_RestAPI_QuoteDetailsWrapper.PerformanceMetricsWrapper();
            pmetric.performanceMetricsId= pm.Id;
            pmetric.performanceMetricsUsed = pm.Pricing_Performance_Metric_Nm__c;
            pmetric.intelScore = pm.Pricing_Intel_SKU_Performance_Nbr__c.setScale(2);
            pmetric.compScore = pm.Pricing_Comp_SKU_Performance_Nbr__c.setScale(2);
            pmetric.weighting = pm.Pricing_Weighting_Pct__c;
            pmetric.otherText = pm.Pricing_Other_Nm__c;
            qliWrapper.performanceMetrics.add(pmetric);
        }        
    }
        
    public static void processExp(Exception exp, String errorCode){
        response.successContent = null;
        Pricing_RestAPI_Util.processException(exp, errorCode, response, RESTAPI_NAME, ENTRY_TIME);
    }    
  
    public class QuoteLineWrapper implements Pricing_RestAPI_SuccessContent {
        Pricing_RestAPI_QuoteDetailsWrapper.QuoteLineDetails quoteLineDetails;
    }
	
}