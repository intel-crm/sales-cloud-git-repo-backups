/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_GetAllQuotes 
* Version     : 1.0 
* Created Date: 09 NOV 2021
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         11/09/2021              Rest API to send all quotes as response to the calling system

Sample API call:- /services/apexrest/v1.0/quoterequest/getallquotes?id=&endDate=&status=&limit=&offset=
The above call sends the records of Quote object as response
*****************************************************************************************************************************************/

@RestResource(urlMapping='/v1.0/quoterequest/getallquotes')
global without sharing class Pricing_RestAPI_GetAllQuotes {
    public static String rowsLimit;
    public static String rowsOffset;
    public static String recId;
    public static String status;
    public static String endDate;
    public static Integer intRowsLimit=0;
    public static Integer intRowsOffset=-1;
    public static List<String> statusSet;
    public static QuoteWrapper quoteWrapper = new QuoteWrapper();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_GetAllQuotes.class.getName();
    
    @HttpGet
    global static Pricing_RestAPI_Response doGet() {
        if(validateRequest()) {//checking if request is valid
            getAllQuoteDetails();
        }
        else {
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    
    //validate the input parameters
    private static boolean validateRequest() {
        boolean isValid = true;
        RestRequest restReq = RestContext.request;
        recId = restReq.params.get('id');
        rowsLimit = restReq.params.get('limit');
        rowsOffset = restReq.params.get('offset');
        endDate = restReq.params.get('endDate');
        status = restReq.params.get('status');
        
        //verify if recId/rowsLimit/rowsOffset are valid
        isValid = (!String.isEmpty(rowsLimit) && rowsLimit.isNumeric() && Integer.valueOf(rowsLimit)<=0) || (!String.isEmpty(rowsOffset) && rowsOffset.isNumeric() && Integer.valueOf(rowsOffset)<0)|| (!String.isEmpty(recId) && recId.length()!=15 && recId.length()!=18)? false:setFilterValue(); 
        
        return isValid;
    }
    private static Boolean setFilterValue() { 
        recId= String.isEmpty(recId) ? null : String.escapeSingleQuotes(recId);
        intRowsLimit = String.isEmpty(rowsLimit) ? 0 : Integer.valueOf(rowsLimit);
        intRowsOffset = String.isEmpty(rowsOffset) ? 0 : Integer.valueOf(rowsOffset);
        endDate = String.isEmpty(endDate) ? null : String.escapeSingleQuotes(endDate);
        status = String.isEmpty(status) ? null : String.escapeSingleQuotes(status);
        if(!String.isEmpty(status)) {
            statusSet = status.split(',');
        }
        return true;
    }
    //method which creates response with all quotes
    private static void getAllQuoteDetails() { 
        try {
            Pricing_RestAPI_QuotesUtilityV2 quoteUtility = new Pricing_RestAPI_QuotesUtilityV2();
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            quoteErrors.quoteErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
            Boolean valid = endDate!=null?quoteUtility.validateGetAllQuoteDate(endDate,'endDate',quoteErrors.quoteErrors):true;
            if(valid) {
                String whereCaluse = getWhereClause();
                String currentUserAccountId = [Select Id, AccountId from User where Id = :UserInfo.getUserId()].AccountId;
                String query = String.escapeSingleQuotes(Label.Pricing_RestAPI_LenovoAPIQuoteQuery) + String.escapeSingleQuotes(Label.Pricing_RestAPI_LenovoAPIQuoteLineQuery)  + String.escapeSingleQuotes(Label.Pricing_RestAPI_LenovoAPIQuoteLineQuery2) + String.escapeSingleQuotes(Label.Pricing_RestAPI_LenovoAPIQuoteLineQuery3); //ch
                query = String.isEmpty(whereCaluse) ? query.replace('{{filter}}','') : query.replace('{{filter}}',whereCaluse);
                List<SBQQ__QuoteLine__c> quotelines = database.query(query);           
                if(quotelines.size()>0) {
                    response.totalRecords = quotelines.size();
                    response.successContent = getFinalList(quotelines) ;                           
                }
                else {
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.NO_DATA_EXCEPTION_9001, response, RESTAPI_NAME, ENTRY_TIME);
                }
            }
            else {
                Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteErrors;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }
        catch(Exception exp) {  
            System.debug(exp.getMessage());
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            //Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response);            
        }                
    }
    //method to form the where clause for the query based on the keyword
    private static String getWhereClause(){
        String whereClause = '';
        if(recId!=null || !String.isEmpty(recId)){
            whereClause += ' AND SBQQ__Quote__r.id =\''+ recId +'\'';
        }
        if(endDate!=null){
            whereClause += ' AND SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c <= '+endDate;
        }
        if(status!=null){
            whereClause += ' AND SBQQ__Quote__r.SBQQ__Status__c IN :statusSet';
        }     
        whereClause +=' AND (Pricing_Program_Type_Nm__c =\''+ Label.Pricing_Tender_Standard_QuoteLine +'\' OR Pricing_Program_Type_Nm__c =\''+ Label.Pricing_Tender_Small_Volume_Quote +'\')';              
        return whereClause;
    }
    
    //get the list based on limit/offset
    private static List<QuoteWrapper> getFinalList(List<SBQQ__QuoteLine__c> quotelines){
        List<QuoteWrapper> quotesLst = new List<QuoteWrapper>();
        
        if(intRowsOffset >= quotelines.size()){            
            intRowsOffset = 0;   //if offset is greater than no. of quotes, default the offset to 0(zero)
        }
        if(intRowsLimit > 0 && intRowsOffset >= 0){     //if offset is valid
            Integer counter = 0;
            
            //fetches the records from offset till the limit
            for(Integer start=intRowsOffset; counter < intRowsLimit && start < quotelines.size()  ; start++){
                SBQQ__QuoteLine__c quoteline = quotelines.get(start);
                QuoteWrapper quoteWrapper = new QuoteWrapper();
                quotesLst.add(getQuotesAndQLI(quoteline,quoteWrapper));
                ++counter;
            }
        }
        else {
            
            //if there is no limit and offset, return complete quotes list
            for(SBQQ__QuoteLine__c quoteline: quotelines){
                QuoteWrapper quoteWrapper = new QuoteWrapper();
                quotesLst.add(getQuotesAndQLI(quoteline,quoteWrapper));
            }
        }        
        return quotesLst;
    }  
    //method to populate the response variables
    public static QuoteWrapper getQuotesAndQLI(SBQQ__QuoteLine__c quoteline, QuoteWrapper quoteDetails) {
        QuoteDetails qDetails = new QuoteDetails();
        qDetails.quoteId = quoteline.SBQQ__Quote__r.Id;
        qDetails.quoteName = quoteline.SBQQ__Quote__r.Name;
        qDetails.endCustomer = quoteline.SBQQ__Quote__r.Pricing_Customer_Nm__c;
        qDetails.unifiedEndCustomer = quoteline.SBQQ__Quote__r.Pricing_End_Customer__r.Name;
        qDetails.unifiedEndCustomerId = quoteline.SBQQ__Quote__r.Pricing_End_Customer__r.Id;
        qDetails.endCustomerCountry = quoteline.SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c;
        qDetails.endCustomerRegion = quoteline.SBQQ__Quote__r.Pricing_Region_Nm__c;
        qDetails.projectName = quoteline.SBQQ__Quote__r.Pricing_Project_Name_Nm__c;
        qDetails.application = quoteline.SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c;
        qDetails.proposalDueDate = quoteline.SBQQ__Quote__r.Pricing_Bid_Dt__c; 
        qDetails.intelResponseRequestedDate = quoteline.SBQQ__Quote__r.Pricing_Intel_Response_Requested_By_Date__c; 
        qDetails.pricingStartDate = quoteline.SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c;
        qDetails.pricingEndDate = quoteline.SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c;
        qDetails.intelSalesRepEmail = quoteline.SBQQ__Quote__r.Pricing_Intel_Sales_Rep_Email_Txt__c;
        qDetails.intelAccountExecutiveEmail = quoteline.SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c;
        qDetails.primaryContactName = quoteline.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name;
        qDetails.referenceRequestID = quoteline.SBQQ__Quote__r.Pricing_Customer_Reference_Id__c;
        qDetails.secondaryContact = quoteline.SBQQ__Quote__r.Pricing_SecondaryContact_Nm__c;
        qDetails.quoteType = quoteline.SBQQ__Quote__r.Pricing_Program_Type_Nm__c;
        qDetails.quoteStatus = quoteline.SBQQ__Quote__r.SBQQ__Status__c;
        qDetails.additionalQuoteLetterRecipients = quoteline.SBQQ__Quote__r.Pricing_AdditionalRecipients__c;
        qDetails.quoteLineId = quoteline.id;
        qDetails.quoteLineNumber = quoteline.Pricing_Quote_Line_Number__c;
        qDetails.quoteLineStatus = quoteline.Pricing_Status_Nm__c;
        qDetails.changeRequest = quoteline.Pricing_New_Change_Request_cb__c;//Pricing_Change_Request_cb__c
        qDetails.approvedPricingStartDate = quoteline.Pricing_Approved_Start_Date_Dup_Dt__c;
        qDetails.approvedPricingEndDate = quoteline.Pricing_Approved_End_Date_Dup_Dt__c;
        qDetails.approvedQuantity = quoteline.Pricing_Approved_Unit_Dup_Qty__c;
        qDetails.effectivePricingStartDate = quoteline.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
        qDetails.billingEndDate = quoteline.Pricing_Billing_End_Date_Dt__c;
        qDetails.billingStartDate = quoteline.Pricing_Billing_Start_Date_Dt__c;
        qDetails.additionalTermsandConditions = quoteline.Pricing_Additional_T_C_s_Txt__c;
        qDetails.newRequestedDiscountUnitPrice = quoteline.Pricing_Request_Discount_Unit_Price_qty__c;
        qDetails.competitiveBidDiscount = quoteline.Pricing_Competitive_Bid_Discount_Pct__c;
        qDetails.approvedECAPPrice = quoteline.Pricing_ECAP_Price_Dup_Amt__c;
        qDetails.dealId = quoteline.Pricing_Deal_RFQ_Dup_Id__c;
        qDetails.newQuantity = quoteline.Pricing_New_Quantity_qty__c;
        qDetails.readyForReview = quoteline.Pricing_Ready_for_Review_cb__c;
        qDetails.lastSubmittedDate = quoteline.Pricing_Last_Submitted_Date_dt__c;
        qDetails.approvedDate = quoteline.Pricing_Last_Approved_Date_dt__c;
        qDetails.lastSubmittedById = quoteline.Pricing_Last_Submitted_By_Id__c;
        qDetails.lastSubmittedByName = quoteline.Pricing_Last_Submitted_By_Id__r.Name;
        qDetails.quoteLinePricingEndDate = quoteline.Pricing_End_Date_dt__c;
        qDetails.productId = quoteline.Pricing_Product_Nm__c;
        qDetails.productName = quoteline.SBQQ__ProductName__c;
        qDetails.processorNumber = quoteline.Pricing_Processor_Number_Nm__c;
        qDetails.quantity = quoteline.Pricing_Unit_Qty__c;
        qDetails.writeInProduct = quoteline.Pricing_Other_Product_Nm__c;
        qDetails.systemModel = quoteline.Pricing_OEM_System_Model_Nm__c;
        qDetails.noOfSystems = quoteline.Pricing_Systems_qty__c;
        qDetails.noOfCPUsPerSystem = quoteline.Pricing_CPUs_per_system_qty__c;
        qDetails.singleSystemPrice = quoteline.Pricing_Single_System_Price_Amt__c;
        qDetails.customerStdUnitPrice = quoteline.Pricing_OEM_Standard_Unit_Price_Amt__c;
        qDetails.requestedDiscountUnitPrice = quoteline.Pricing_Req_Discounted_Unit_Price__c;
        qDetails.totalBidWithoutDiscount = quoteline.Pricing_Total_Bid_without_Discount_Amt__c;
        qDetails.netIntelBidPrice = quoteline.Pricing_Net_IA_Bid_Price_Amt__c;
        qDetails.intelDiscount = quoteline.Pricing_Intel_Discount_Pct__c;
        qDetails.customerDiscount = quoteline.Pricing_OEM_Discount_Pct__c;
        qDetails.totalIntelDiscount =quoteline.Pricing_Total_Intel_Discount_Amt__c;
        qDetails.intelBidDiscount = quoteline.Pricing_IA_Bid_Discount_Pct__c;
        
        qDetails.additionalDiscount = quoteline.Pricing_Additional_OEM_Discount_Amt__c;
        qDetails.competitorName = quoteline.Pricing_Competitor_OEM_Nm__c;
        qDetails.competitorSystemModel = quoteline.Pricing_Competitor_System_Model_Nm__c;
        qDetails.competitorProductId = quoteline.Pricing_Competetor_Product__c;
        qDetails.competitorProductName = quoteline.Pricing_Competetor_Product__r.Name;
        qDetails.writeInCompetitorProduct = quoteline.Pricing_Other_Competitor_Product_Nm__c;
        qDetails.competitorProductProvider = quoteline.Pricing_comp_Product_Provider_nm__c;
        qDetails.competitorNoOfSystems = quoteline.Pricing_Competitor_Systems_Cnt__c;
        qDetails.competitorNoOfCPUsPerSystem = quoteline.Pricing_Comp_CPUs_per_system_Cnt__c;
        qDetails.competitorQuantity = quoteline.Pricing_Comp_Units_Cnt__c;
        qDetails.competitorSingleSystemPrice = quoteline.Pricing_Comp_Single_System_Price_Amt__c;
        qDetails.competitorAdditionalDiscount = quoteline.Pricing_Comp_Additional_OEM_Disc_Amt__c;
        qDetails.competitorTotalWithoutDiscount = quoteline.Pricing_Comp_Total_without_discount_Amt__c;
        qDetails.netCompetitorBidPrice = quoteline.Pricing_Net_Comp_Bid_Price_Amt__c;
        qDetails.referenceQuoteLineNumberId = quoteline.Pricing_Reference_Quote_Line_Nbr__c;
        qDetails.referenceQuoteLineNumber = quoteline.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c;
        quoteDetails.quoteDetails = qDetails;
        return quoteDetails;
    }
    
    //wrapper class for success content
    public class QuoteWrapper implements Pricing_RestAPI_SuccessContent {
        QuoteDetails quoteDetails;
    }
    //wrapper class for response details wrapper
    public class QuoteDetails {
        public String quoteId {set;get;}
        public String quoteName {set;get;}
        public String endCustomer {set;get;}
        public String unifiedEndCustomer {set;get;}
        public String unifiedEndCustomerId {set;get;}
        public String projectName {set;get;}
        public String application {set;get;}
        public Date proposalDueDate {set;get;}
        public Date intelResponseRequestedDate {set;get;}
        public Date pricingStartDate {set;get;}
        public Date pricingEndDate {set;get;}
        public String intelSalesRepEmail {set;get;}
        public String intelAccountExecutiveEmail {set;get;}
        public String endCustomerCountry {set;get;}
        public String endCustomerRegion {set;get;}
        public String primaryContactName {set;get;}
        public String referenceRequestID {set;get;}
        public String secondaryContact {set;get;}
        public String quoteType {set;get;}
        public String quoteStatus {set;get;}
        public String additionalQuoteLetterRecipients {set;get;}
        public String quoteLineId {get; set;}
        public String quoteLineNumber {get; set;}
        public String quoteLineStatus {set;get;}
        public Boolean changeRequest {get;set;}
        public Date approvedPricingStartDate {get;set;}
        public Date approvedPricingEndDate {get;set;}
        public Decimal approvedQuantity {get;set;}
        public Date effectivePricingStartDate {get;set;}//
        public Date billingEndDate {get;set;}//
        public Date billingStartDate {get;set;}//
        public String additionalTermsandConditions {get;set;}//
        public Decimal newRequestedDiscountUnitPrice {get;set;}//
        public Decimal competitiveBidDiscount {get;set;}//       
        public Decimal approvedECAPPrice {get;set;}
        public String dealID {set;get;}
        public Decimal newQuantity {get;set;}
        public Boolean readyForReview{get;set;}
        public Date quoteLinePricingEndDate {get; set;}
        public String productId {get; set;}
        public String productName {get;set;}
        public String processorNumber{get;set;}
        public Decimal quantity {get;set;}
        public String writeInProduct {get; set;}
        public String systemModel {get;set;}
        public Decimal noOfSystems {get;set;}
        public Decimal noOfCPUsPerSystem {get; set;}
        public Decimal singleSystemPrice {get;set;}
        public Decimal customerStdUnitPrice {get;set;}
        public Decimal requestedDiscountUnitPrice {get;set;}
        public Decimal totalBidWithoutDiscount {get;set;}
        public Decimal additionalDiscount {get;set;}
        public Decimal netIntelBidPrice {get;set;}
        public Decimal intelDiscount {get;set;}
        public Decimal customerDiscount {get;set;}
        public Decimal totalIntelDiscount {get;set;}
        public Decimal intelBidDiscount {get;set;}
        public String competitorName {get; set;}
        public String competitorSystemModel {get; set;}
        public String competitorProductId {get; set;}
        public String competitorProductName {get; set;}
        public String writeInCompetitorProduct  {get; set;}
        public String competitorProductProvider {get;set;}
        public Decimal competitorNoOfSystems {get; set;}
        public Decimal competitorNoOfCPUsPerSystem {get; set;}
        public Decimal competitorQuantity {get;set;}
        public Decimal competitorSingleSystemPrice {get; set;}
        public Decimal competitorAdditionalDiscount {get;set;}
        public Decimal competitorTotalWithoutDiscount {get;set;}
        public Decimal netCompetitorBidPrice {get;set;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
    }
    
}