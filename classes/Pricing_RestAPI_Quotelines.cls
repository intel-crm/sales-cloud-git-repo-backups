/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_Quotelines 
* Version     : 1.0 
* Created Date: 04 Nov 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         11/04/2020              Rest API to submit a QuoteLine
Rest API to get quoteLine fields and its performance metrics as response
POST=>
Sample API call:- /services/apexrest/v1.0/quoterequest/quotelines?action=
action => create (to create quoteline with draft status)
action => submit (to submit quoteline as PIFR status)

Description=> Pass the quoteId and quoteLineDetails as an input JSON and it will submit the QuoteLine

GET=>
Sample API call:- /services/apexrest/v1.0/quoterequest/quotelines?type=&id=
type => quoteLine (fetch quoteLine details only i.e, section 2 details)
type => blank or all (fetch section 2 and section 3 details)
id=>quoteLineId

Description=> Pass the type and quoteLineId as an url input and it will return quoteDetails
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/quoterequest/quotelines')
global without sharing class Pricing_RestAPI_Quotelines {   
    /*private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_Quotelines.class.getName();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    public static boolean isStatusChange = false;
    public static boolean isCreateDraftQuoteLine = false;
    public static boolean isUpdateDraftQuoteLine = false;
    public static boolean isResubmit = false;
    public static boolean isChangeReq = false; 
    
    public static String reqtype;
    public static String recId;
    public static Id quoteLineId;
    public static QuoteLineWrapper quoteLineWrapper = new QuoteLineWrapper();
    public static Map<Id, List<Pricing_Performance_Metric__c>> pmMap = new Map<Id, List<Pricing_Performance_Metric__c>>();
    public static List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI> statusChangeQuotelines = new List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI>();
    public static Id currentUserAccountId = [Select Id, AccountId from User where Id = :UserInfo.getUserId()].AccountId;
    //update quoteline
    public static boolean isPatch = false;
    public static boolean isSvdQuoteLine = false;
    
    @HttpPost
    global static Pricing_RestAPI_Response doPost(){
        RestRequest req = RestContext.request;
        //validate the action parameters if its create or submit
        if(validateActionParam()){
            if(isChangeReq){
                response = Pricing_RestAPI_ChangeRequestQuoteLine.doCRAPI(req.requestBody.toString(),'v1.0'); 
            }else{
                processRequest(req.requestBody.toString()); 
            }
        }else{
            //action is invalid
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    public static boolean validateActionParam(){
        String actionType = Pricing_RestAPI_Util.getRequestParam('action');
        if(actionType!= null && (actionType.toLowerCase() == 'create' || actionType.toLowerCase() == 'submit' || actionType.toLowerCase() == 'statuschange' || actionType.toLowerCase() == 'changerequest' )){  
            //if action is create then create Quoteline in draft status
            //if action is submit then create Quoteline and submit it for Intel Review
            isCreateDraftQuoteLine = (actionType.toLowerCase()=='create') ? true : false;
            isCreateDraftQuoteLine = (actionType.toLowerCase()=='submit') ? false : true;
            isStatusChange = (actionType.toLowerCase()=='statuschange') ? true : false;
            isChangeReq = (actionType.toLowerCase()=='changerequest') ? true : false;
            return true;
        }else{
            //invalid action parameter
            return false;
        }
    }
    
    global static Pricing_RestAPI_Response processRequest(String reqBody){
        try{
            Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapperDCAI quoteLine = (Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapperDCAI) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityv2.QuoteLineWrapperDCAI.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
            boolean isValidQuoteLine = utilObj.validateQuoteLineWrapper(quoteLine, qErrorMsg, !isCreateDraftQuoteLine);
            
            //validate the given quoteline and performance metrics
            if(isValidQuoteLine){
                if(isStatusChange){
                    updateQuoteline();
                    if(qErrorMsg.quoteLineErrorMsgs!=null && !qErrorMsg.quoteLineErrorMsgs.isEmpty()){
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qe : qErrorMsg.quoteLineErrorMsgs){
                            if(qe.quoteLineErrors != null && qe.quoteLineErrors.isEmpty()){
                                qe.quoteLineErrors = null;
                            }
                        }                        
                        //Pricing_RestAPI_Util.quoteErrMsgs = qErrorMsg;
                        Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                    }
                }
                else{
                    createQuoteLine(quoteLine, qErrorMsg.quoteLineErrorMsgs);
                }
                
            }else{
                //nullify quoteline errors if Quote Id is not valid as quote error message whould have the validation errors
                if(qErrorMsg.quoteLineErrorMsgs!=null && !qErrorMsg.quoteLineErrorMsgs.isEmpty()){
                    for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qe : qErrorMsg.quoteLineErrorMsgs){
                        if(qe.quoteLineErrors != null && qe.quoteLineErrors.isEmpty()){
                            qe.quoteLineErrors = null;
                        }
                    }
                }
                //Pricing_RestAPI_Util.quoteErrMsgs = qErrorMsg;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
            return response;
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
            return response;
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            //Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response); 
            return response;
        }
    }
    
    
    public static void createQuoteLine(Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapperDCAI quoteLine, List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg> quoteLineErrors){
        try{
            Map<Id,SBQQ__QuoteLine__c> quoteLineIdMap;
            List<Pricing_Performance_Metric__c> perfMetrics = new List<Pricing_Performance_Metric__c>();
            List<SBQQ__QuoteLine__c> quoteLineListInsert = Pricing_RestAPI_QuotesUtility.createQuoteLineRecords((ID)quoteLine.quoteId, quoteLine.quoteLines);//updateQuoteLineDetails(quoteLine);
            if(quoteLineListInsert.size()>0){
                insert quoteLineListInsert;     //create validated quotelines
                Set<Id> qlIdSet = new Set<Id>();
                for(SBQQ__QuoteLine__c ql:quoteLineListInsert){
                    qlIdSet.add(ql.Id);
                }
                quoteLineIdMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT id, Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,
                                                                 Pricing_Program_Type_Nm__c,RecordTypeId,Pricing_Ready_for_Review_cb__c,Pricing_Original_Submitted_By_Id__c,
                                                                 Pricing_Original_Submitted_Date_dt__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Last_Submitted_By_Id__c 
                                                                 FROM SBQQ__QuoteLine__c WHERE Id IN:qlIdSet and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId]);
                Integer j = 0;
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI q: quoteLine.quoteLines){
                    if(q.performanceMetrics != null){
                        Pricing_RestAPI_QuotesUtility.createPerformanceMetricsRecord(quoteLineListInsert[j].id, q.performanceMetrics, perfMetrics);
                    }
                    j++;
                }
                if(!perfMetrics.isEmpty()){
                    insert perfMetrics;     //create validated performance metrics
                }
                if(!isCreateDraftQuoteLine){
                    Pricing_RestAPI_QuotesUtility.publishQuoteAndQuoteLines(null,null,null,quoteLineIdMap,null,qlIdSet,'SBQQ__QuoteLine__c'); 
                }
                response.successContent = new List<Pricing_RestAPI_SuccessContent>();
                Map<Id, List<CreatedPMDetails>> quotelineToPmMap = new Map<Id, List<CreatedPMDetails>>();
                Integer i = 0;
                for(SBQQ__QuoteLine__c ql: quoteLineListInsert){
                    List<CreatedPMDetails> pmDetailList = new List<CreatedPMDetails>();
                    j = 1;
                    for(Pricing_Performance_Metric__c pm: perfMetrics){
                        if(pm.Pricing_Quote_Line__c == ql.Id){
                            pmDetailList.add(new CreatedPMDetails(pm.Id, quoteLine.quoteLines[i].performanceMetrics[j-1].performanceMetricsReferenceId));
                            j++;
                        }
                    }
                    if(pmDetailList.size()==0){
                        pmDetailList = null;
                    }
                    quotelineToPmMap.put(ql.id, pmDetailList);
                    i++;
                }
                i = 1;
                for(SBQQ__QuoteLine__c ql: quoteLineListInsert){
                    response.successContent.add(new CreatedQuoteLineDetails(ql.Id,quoteLineIdMap.get(ql.Id).Pricing_Quote_Line_Number__c, quotelineToPmMap.get(ql.Id), quoteLine.quoteLines[i-1].quotelineReferenceID));
                    i++;
                }
                response.totalRecords = i-1;
            }
            
            
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            //Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response);            
        } 
    } 
    
    public static void updateQuoteline(){
        List<SBQQ__QuoteLine__c> quotelineList = new List<SBQQ__QuoteLine__c>();
        String res = 'Record/s updated successfully for Quotelines: ';
        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI qline: statusChangeQuotelines){
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.Id = qline.quotelineId;
            if(qline.status.trim().toLowerCase() == 'won'){
                ql.Pricing_Status_Nm__c = 'Won';
            }else{
                ql.Pricing_Status_Nm__c = 'Lost';
            }
            ql.Pricing_Won_Lost_Comments_Txt__c = qline.wonLostComments;
            ql.Pricing_Lost_Reason_Nm__c = qline.lostReason;
            quotelineList.add(ql);
            
            res+= qline.quotelineId + ', ';
        }
        res = res.substring(0, res.length()-2);
        if(quotelineList.size() > 0){
            update quotelineList;
            
            response.totalRecords = quotelineList.size();
            response.successContent = new List<Pricing_RestAPI_SuccessContent>();
            response.successContent.add(new UpdateQuoteLineDetails(res));
        }        
    }
    
    public class UpdateQuoteLineDetails implements Pricing_RestAPI_SuccessContent {
        String quoteLines {set;get;}
        public UpdateQuoteLineDetails(String msg){
            quotelines = msg;
        }
    }
    
    public class CreatedQuoteLineDetails implements Pricing_RestAPI_SuccessContent {
        public String quoteLineId {set;get;} 
        public String quoteLineNumber {set;get;}
        public String quotelineReferenceID {set;get;}
        public List<CreatedPMDetails> performanceMetrics {set;get;}
        public CreatedQuoteLineDetails(String recId,String qlNumber, List<CreatedPMDetails> pmList, String quoteLineRefID){
            quoteLineId = recId;
            quoteLineNumber = qlNumber;
            quotelineReferenceID = quoteLineRefID;
            performanceMetrics = pmList;            
        }
    }
    
    public class CreatedPMDetails{
        public String performanceMetricsId {set;get;} 
        public String performanceMetricsReferenceId {set;get;}
        public CreatedPMDetails(String recId, String refId){
            performanceMetricsId = recId;
            performanceMetricsReferenceId = refId;
        }
    }
    
    
    
    
    //-----------------------------------------------------------------------------------------------------------------------
    
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
            //Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response);            
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
                quoteLineId = Id.valueOf(recId);    //check if the input record Id is a valid salesforce Id
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
        String query = String.escapeSingleQuotes(Label.Pricing_RestAPI_GetQuoteLineQuery1)+String.escapeSingleQuotes(Label.Pricing_RestAPI_GetQuoteLineQuery2);//ch
        String typeCheck = 'and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId and (Pricing_Program_Type_Nm__c =\''+ Label.Pricing_Tender_Standard_QuoteLine +'\' or Pricing_Program_Type_Nm__c =\''+ Label.Pricing_Tender_Small_Volume_Quote +'\')';
        if(String.isEmpty(reqtype) || reqtype.toLowerCase() == 'all'){
            //if reqType is all add performance metrics subquery to quoteline query
            query = query + String.escapeSingleQuotes(Label.Pricing_RestAPI_GetQuoteLineQuery3.replace('{{PMQUERY}}',String.escapeSingleQuotes(label.Pricing_RestAPI_PMSubQuery)));//ch
            query = query.replace('{{accCheck}}',typeCheck);
        }else{
            //if reqType is quoteline remove placeholder string from query
            query = query + String.escapeSingleQuotes(Label.Pricing_RestAPI_GetQuoteLineQuery3.replace('{{PMQUERY}}',''));//ch
            query = query.replace('{{accCheck}}',typeCheck);
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
        qlDetails.approvedPricingStartDate= quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c;
        qlDetails.approvedPricingEndDate=quoteLine.Pricing_Approved_End_Date_Dup_Dt__c;
        qlDetails.approvedQuantity = quoteLine.Pricing_Approved_Unit_Dup_Qty__c;
        qlDetails.effectivePricingStartDate = quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
        qlDetails.billingEndDate = quoteLine.Pricing_Billing_End_Date_Dt__c;
        qlDetails.billingStartDate = quoteLine.Pricing_Billing_Start_Date_Dt__c;
        qlDetails.additionalTermsandConditions = quoteLine.Pricing_Additional_T_C_s_Txt__c;
        qlDetails.newRequestedDiscountUnitPrice = quoteLine.Pricing_Request_Discount_Unit_Price_qty__c;
        qlDetails.competitiveBidDiscount = quoteLine.Pricing_Competitive_Bid_Discount_Pct__c;
        qlDetails.approvedECAPPrice = quoteLine.Pricing_ECAP_Price_Dup_Amt__c;
        qlDetails.dealId = quoteLine.Pricing_Deal_RFQ_Dup_Id__c;
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
    
    public class QuoteLineWrapper implements Pricing_RestAPI_SuccessContent {
        Pricing_RestAPI_QuoteDetailsWrapper.QuoteLineDetails quoteLineDetails;
    }
    
    //----------------------------------------------------------------------------------------------------------------------------
    @httpPatch
    global static Pricing_RestAPI_Response doPatch(){
        RestRequest req = RestContext.request;
        //validate the action parameters if its create or submit
        if(validateUpdateActionParam()){
            validateUpdateQli(req.requestBody.toString());
        }else{
            //action is invalid
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    
    public static boolean validateUpdateActionParam(){
        String actionType = Pricing_RestAPI_Util.getRequestParam('action');
        if(actionType!= null && (actionType.toLowerCase() == 'update' || actionType.toLowerCase() == 'resubmit')){  
            //if action is create then create Quoteline in draft status
            //if action is submit then create Quoteline and submit it for Intel Review
            isUpdateDraftQuoteLine = (actionType.toLowerCase()=='update') ? true : false;
            isUpdateDraftQuoteLine = (actionType.toLowerCase()=='resubmit') ? false : true;
            isResubmit = (actionType.toLowerCase()=='resubmit') ? true : false;
            return true;
        }else{
            //invalid action parameter
            return false;
        }
    }
    
    global static Pricing_RestAPI_Response validateUpdateQli(String reqBody){
        try{
            isPatch = true;
            Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapperDCAI quoteLine = (Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapperDCAI) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapperDCAI.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility utilObj = new Pricing_RestAPI_QuotesUtility();
            boolean isValidQuoteLine = utilObj.validateQuoteLineWrapper(quoteLine, qErrorMsg, !isUpdateDraftQuoteLine);
            if(isValidQuoteLine){
                //valid Performance metrics
                updateValidQuoteLines(quoteLine, qErrorMsg.quoteLineErrorMsgs);
            }else{
                //Invalid Performance metrics
                //Pricing_RestAPI_Util.quoteErrMsgs = qErrorMsg;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200;
            }
            //Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response);
        }
        isPatch = false;
        return response;
    }
    
    public static void updateValidQuoteLines(Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapperDCAI quoteLine, List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg> quoteLineErrors){
        try{
            Map<Id,SBQQ__QuoteLine__c> quoteLineIdMap;
            List<Pricing_Performance_Metric__c> perfMetrics = new List<Pricing_Performance_Metric__c>();
            List<SBQQ__QuoteLine__c> quoteLineListUpdate = Pricing_RestAPI_QuotesUtility.createQuoteLineRecords((ID)quoteLine.quoteId, quoteLine.quoteLines);//updateQuoteLineDetails(quoteLine);
            if(quoteLineListUpdate.size()>0){
                //update validated quotelines
                Set<Id> qlIdSet = new Set<Id>();
                Integer i = 0;
                for(SBQQ__QuoteLine__c ql:quoteLineListUpdate){
                    ql.Id = quoteLine.quoteLines[i].quotelineId;
                    qlIdSet.add(ql.Id);
                    i++;
                }
                update quoteLineListUpdate;
                quoteLineIdMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT id, Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,
                                                                 Pricing_Program_Type_Nm__c,RecordTypeId,Pricing_Ready_for_Review_cb__c,Pricing_Original_Submitted_By_Id__c,
                                                                 Pricing_Original_Submitted_Date_dt__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Last_Submitted_By_Id__c 
                                                                 FROM SBQQ__QuoteLine__c WHERE Id IN:qlIdSet and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId]);
                Integer j = 0;
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI q: quoteLine.quoteLines){
                    if(q.performanceMetrics != null){
                        Pricing_RestAPI_QuotesUtility.createPerformanceMetricsRecord(quoteLineListUpdate[j].id, q.performanceMetrics, perfMetrics);
                    }
                    j++;
                }
                if(!perfMetrics.isEmpty()){
                    upsert perfMetrics;     //upsert validated performance metrics
                }
                if(!isUpdateDraftQuoteLine){
                    //US1104158
                    Pricing_RestAPI_QuotesUtility.publishQuoteAndQuoteLines(null,null,null,quoteLineIdMap,null,qlIdSet,'SBQQ__QuoteLine__c'); 
                }
                response.successContent = new List<Pricing_RestAPI_SuccessContent>();
                Map<Id, List<CreatedPMDetails>> quotelineToPmMap = new Map<Id, List<CreatedPMDetails>>();
                i = j = 0;
                for(SBQQ__QuoteLine__c ql:quoteLineListUpdate){
                    List<CreatedPMDetails> pmDetailList = new List<CreatedPMDetails>();
                    for(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics pm: quoteLine.quoteLines[i].performanceMetrics){
                        if(perfMetrics[j].Pricing_Quote_Line__c == ql.Id){
                            pmDetailList.add(new CreatedPMDetails(perfMetrics[j].Id, pm.performanceMetricsReferenceId));
                            j++;
                        }else if(perfMetrics[j].Pricing_Quote_Line__c == null){
                            pmDetailList.add(new CreatedPMDetails(perfMetrics[j].Id, pm.performanceMetricsReferenceId));
                            j++;
                        }
                    }
                    if(pmDetailList.size()==0){
                        pmDetailList = null;
                    }
                    quotelineToPmMap.put(ql.id, pmDetailList);
                    i++;
                }
                i = 1;
                for(SBQQ__QuoteLine__c ql: quoteLineListUpdate){
                    response.successContent.add(new CreatedQuoteLineDetails(ql.Id,quoteLineIdMap.get(ql.Id).Pricing_Quote_Line_Number__c, quotelineToPmMap.get(ql.Id), quoteLine.quoteLines[i-1].quotelineReferenceID));
                    i++;
                }
                response.totalRecords = i-1;
            }    
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            //Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response);            
        } 
    }
    
    public class GlobalVariables implements Pricing_RestAPI_SuccessContent {
        Set<String> messageNotification {set;get;}
    }*/
}