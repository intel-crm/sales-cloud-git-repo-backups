/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_QuotelinesV2 
* Version     : 2.0 
* Created Date: 06 May 2022
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         06/05/2022              Rest API to submit a QuoteLine Ver-2
Rest API to get quoteLine fields and its performance metrics as response
POST=>
Sample API call:- /services/apexrest/v2.0/quoterequest/quotelines?action=
action => create (to create quoteline with draft status)
action => submit (to submit quoteline as PIFR status)

Description=> Pass the quoteId and quoteLineDetails as an input JSON and it will submit the QuoteLine

GET=>
Sample API call:- /services/apexrest/v2.0/quoterequest/quotelines?type=&id=
type => quoteLine (fetch quoteLine details only i.e, section 2 details)
type => blank or all (fetch section 2 and section 3 details)
id=>quoteLineId

Description=> Pass the type and quoteLineId as an url input and it will return quoteDetails
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v2.0/quoterequest/quotelines')
global without sharing class Pricing_RestAPI_QuotelinesV2 extends TriggerHandler{   
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_QuotelinesV2.class.getName();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    public static boolean isStatusChange = false;
    public static boolean isCreateDraftQuoteLine = false;
    public static boolean isUpdateDraftQuoteLine = false;
    public static boolean isResubmit = false;
    public static boolean isSSD = false;
    public static boolean isPMem = false;
    public static boolean isNIC = false;
    public static boolean isGPU = false;
    public static boolean isClient = false;
    public static boolean isDPG = false;
    public static boolean isChangeReq = false; 
    public static String reqtype;
    public static String recId;
    public static Id quoteLineId;
    public static String quoteLineName;
    public static QuoteLineWrapper quoteLineWrapper = new QuoteLineWrapper();
    public static QuoteLineWrapperClient quoteLineWrapperClient = new QuoteLineWrapperClient();
    public static List<Pricing_RestAPI_QuotesUtilityV2.QLICRWonLost> statusChangeQuotelines = new List<Pricing_RestAPI_QuotesUtilityV2.QLICRWonLost>();
    public static Map<Id, List<Pricing_Performance_Metric__c>> pmMap = new Map<Id, List<Pricing_Performance_Metric__c>>();
    //public static Id currentUserAccountId = [Select Id, AccountId from User where Id = :UserInfo.getUserId()].AccountId;
    //update quoteline
    public static boolean isPatch = false;
    public static boolean isRollBack = false;
    public static boolean isSvdQuoteLine = false;
    public static String actionType;
    
    @HttpPost
    global static Pricing_RestAPI_Response doPost(){
        RestRequest req = RestContext.request;
        //validate the action parameters if its create or submit
        if(validateActionParam()){
            if(isChangeReq){
                response = Pricing_RestAPI_ChangeRequestQuoteLine.doCRAPI(req.requestBody.toString(),'v2.0'); 
            }else if(isStatusChange){
                response = processQLIWonLostRequest(req.requestBody.toString()); 
            }else if(isRollBack){
                processRollBackRequest(req.requestBody.toString());
            }
            else{
                processRequest(req.requestBody.toString()); 
            } 
        }else{
            //action is invalid
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    public static boolean validateActionParam(){
        actionType = Pricing_RestAPI_Util.getRequestParam('action');
        String recId = Pricing_RestAPI_Util.getRequestParam('id');
        if(actionType!= null && (actionType.toLowerCase() == 'create' || actionType.toLowerCase() == 'submit' || actionType.toLowerCase() == 'statuschange'  || actionType.toLowerCase() == 'changerequest')){  
            //if action is create then create Quoteline in draft status
            //if action is submit then create Quoteline and submit it for Intel Review
            isCreateDraftQuoteLine = (actionType.toLowerCase()=='create') ? true : false;
            isCreateDraftQuoteLine = (actionType.toLowerCase()=='submit') ? false : true;
            isChangeReq = (actionType.toLowerCase()=='changerequest') ? true : false;
            isStatusChange = (actionType.toLowerCase()=='statuschange') ? true : false;
            return true;
        }else if(actionType != null && actionType.toLowerCase() == 'recall' && !String.isBlank(recId)){
            isRollBack = true;
            quoteLineId = recId instanceOf Id ? Id.valueOf(recId) : null;
            return true;
        } else{
            //invalid action parameter
            return false;
        }
    }
    
    /**
* @description process the request json and validate the fieleds and insert the record
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @param reqBody 
**/
    global static void processRequest(String reqBody){
        try{
            Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapper quoteLine = (Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapper) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapper.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 utilObj = new Pricing_RestAPI_QuotesUtilityV2();
            boolean isValidQuoteLine = utilObj.validateQuoteLineWrapper(quoteLine, qErrorMsg, !isCreateDraftQuoteLine);
            
            //validate the given quoteline and performance metrics
            if(isValidQuoteLine){
                createQuoteLine(quoteLine, qErrorMsg.quoteLineErrorMsgs);
            }else{
                if((actionType.toLowerCase() == 'submit' || actionType.toLowerCase() == 'create') && (!isSvdQuoteLine || TriggerHandler.isActive('Pricing_SVD_QuoteLine_Disabled'))){
                //nullify quoteline errors if Quote Id is not valid as quote error message whould have the validation errors
                if(qErrorMsg.quoteLineErrorMsgs!=null && !qErrorMsg.quoteLineErrorMsgs.isEmpty()){
                    for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qe : qErrorMsg.quoteLineErrorMsgs){
                        if(qe.quoteLineErrors != null && qe.quoteLineErrors.isEmpty()){
                            qe.quoteLineErrors = null;
                        }
                    }
                }
                Pricing_RestAPI_Util.quoteErrMsgsV2 = qErrorMsg;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
                else{
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                response.errorContent.errorMessage = Label.Pricing_Tender_API_Quotelines_SVD_Submit_Error_Msg;
                }
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response, Pricing_RestAPI_QuotesUtilityV2.currentUser);            
        }
    }
    
    global static Pricing_RestAPI_Response processQLIWonLostRequest(String reqBody){
        try{
            Pricing_RestAPI_QuotesUtilityV2.QLICRWonLostWrapper quoteLine = (Pricing_RestAPI_QuotesUtilityV2.QLICRWonLostWrapper) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QLICRWonLostWrapper.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 utilObj = new Pricing_RestAPI_QuotesUtilityV2();
            boolean isValidQuoteLine = utilObj.validateQuoteLineCRWonLostWrapper(quoteLine, qErrorMsg, !isCreateDraftQuoteLine);
            
            //validate the given quoteline
            if(isValidQuoteLine){
                if(isStatusChange){
                    updateQuotelineRecord();
                    if(qErrorMsg.quoteLineErrorMsgs!=null && !qErrorMsg.quoteLineErrorMsgs.isEmpty()){
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qe : qErrorMsg.quoteLineErrorMsgs){
                            if(qe.quoteLineErrors != null && qe.quoteLineErrors.isEmpty()){
                                qe.quoteLineErrors = null;
                            }
                        }                      
                        Pricing_RestAPI_Util.quoteErrMsgsV2 = qErrorMsg;  
                        Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                    }
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
                Pricing_RestAPI_Util.quoteErrMsgsV2 = qErrorMsg;
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
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response, Pricing_RestAPI_QuotesUtilityV2.currentUser); 
            return response;
        }
    }
    
    /**
* @description Recall the quoteline which is in Pending Intel Field Review
* @author Sandeep | 05-11-2023 
* @param method 
**/
    public static void processRollBackRequest(String reqBody) {
        try {
            RecallRequest recallReq = String.isBlank(reqBody) ? new RecallRequest() : (RecallRequest) JSON.deserialize(reqBody, RecallRequest.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            quoteMsg.quoteLineErrorMsgs = new List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg>();
            Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qlErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg();
            qlErrorMsg.quoteLineErrors = new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
            Pricing_RestAPI_QuotesUtilityV2 quoteUtility = new Pricing_RestAPI_QuotesUtilityV2();
            Boolean isValid = true;
            
            List<SBQQ__QuoteLine__c> rollBackQuoteLine = [SELECT Id,Pricing_Quote_Line_Number__c,Pricing_Last_Submitted_By_Id__c,Pricing_Status_Nm__c,Pricing_Ready_for_Review_cb__c,Customer_Revision_Count_Cnt__c,Pricing_Reference_Quote_Line_Nbr__c,SBQQ__Quote__c,Pricing_Program_Type_Nm__c
                                                          FROM SBQQ__QuoteLine__c WHERE Id =: quoteLineId AND SBQQ__Quote__r.SBQQ__Account__c =: Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId];
            if(rollBackQuoteLine.size() > 0){
                if(rollBackQuoteLine[0].Pricing_Program_Type_Nm__c!=Label.Pricing_Tender_Small_Volume_Quote || TriggerHandler.isActive('Pricing_SVD_QuoteLine_Disabled')){   
                if(!String.isBlank(recallReq.comment) && recallReq.comment.length()>8000){
                    Pricing_RestAPI_QuotesUtilityV2.addValidationError(qlErrorMsg.quoteLineErrors, 'comment', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1019, new Map<String,String>{'{{dataMaxLimit}}'=> '8000'});
                    isValid = false;
                }
                if(!(rollBackQuoteLine[0].Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && rollBackQuoteLine[0].Pricing_Reference_Quote_Line_Nbr__c == null)){
                    Pricing_RestAPI_QuotesUtilityV2.addValidationError(qlErrorMsg.quoteLineErrors, 'quoteLine', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1085, null);
                    isValid = false;
                }      
                if(isValid){
                    Pricing_BulkSalesRepActionController.recordApproval(rollBackQuoteLine, Label.Pricing_Tender_QuoteLine_Action_Rollback, null, false);
                    
                    // creating a chatter post for the quote
                    FeedItem post = new FeedItem();
                    post.Body = String.isBlank(recallReq.comment) ? UserInfo.getName() + ' recalled ' + rollBackQuoteLine[0].Pricing_Quote_Line_Number__c + '.': recallReq.comment;
                    post.ParentId = rollBackQuoteLine[0].SBQQ__Quote__c;
                    post.Visibility = 'AllUsers';
                    insert post;
                    
                    String res = 'Recall successful.';
                    response.totalRecords = 1;
                    response.successContent = new List<RollBackDetails>();
                    response.successContent.add(new RollBackDetails(rollBackQuoteLine[0].Id, res, rollBackQuoteLine[0].Pricing_Status_Nm__c, rollBackQuoteLine[0].Pricing_Quote_Line_Number__c));
                }
                else{
                    quoteMsg.quoteLineErrorMsgs.add(qlErrorMsg);
                    Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteMsg;
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                }
                }else{
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                    response.errorContent.errorMessage = Label.Pricing_Tender_API_Quotelines_SVD_Recall_Error_Msg;
                }
            }
            else{
                Pricing_RestAPI_QuotesUtilityV2.addValidationError(qlErrorMsg.quoteLineErrors, 'quoteLine', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null);
                quoteMsg.quoteLineErrorMsgs.add(qlErrorMsg);
                Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteMsg;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }catch(Exception exp) {
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200;
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response, Pricing_RestAPI_QuotesUtilityV2.currentUser);
        }
    }
    
    /**
* @description Wrapper Class for Recall Request JSON
* @author Sandeep | 06-15-2023 
**/
    public class RecallRequest{
        public String comment {set;get;}
    }
    /**
* @description Wrapper Class for Recall Success Response
* @author Sandeep | 05-11-2023 
**/
    public class RollBackDetails implements Pricing_RestAPI_SuccessContent {
        String quoteLineId {set;get;}
        String message {set;get;}
        String status {set;get;}
        String quoteLineNumber {set;get;}
        public RollBackDetails(String qliId, String successMsg, String qliStatus, String qliNumber){
            message = successMsg;
            quoteLineId = qliId;
            status = qliStatus;
            quoteLineNumber = qliNumber;
        }
    }
    
    /**
* @description create record for valid quoteline
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @param quoteLine 
* @param quoteLineErrors 
**/
    public static void createQuoteLine(Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapper quoteLine, List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg> quoteLineErrors){
        try{
            Map<Id,SBQQ__QuoteLine__c> quoteLineIdMap;
            List<Pricing_Performance_Metric__c> perfMetrics = new List<Pricing_Performance_Metric__c>();
            List<SBQQ__QuoteLine__c> quoteLineListInsert = Pricing_RestAPI_QuotesUtilityV2.createQuoteLineRecords((ID)quoteLine.quoteId, quoteLine.quoteLines);
            if(quoteLineListInsert.size()>0){
                insert quoteLineListInsert;     //create validated quotelines
                Set<Id> qlIdSet = new Set<Id>();
                for(SBQQ__QuoteLine__c ql:quoteLineListInsert){
                    qlIdSet.add(ql.Id);
                }
                quoteLineIdMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT id, Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,
                                                                 Pricing_Program_Type_Nm__c,RecordTypeId,Pricing_Ready_for_Review_cb__c,Pricing_Original_Submitted_By_Id__c,
                                                                 Pricing_Original_Submitted_Date_dt__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Last_Submitted_By_Id__c 
                                                                 FROM SBQQ__QuoteLine__c WHERE Id IN:qlIdSet and SBQQ__Quote__r.SBQQ__Account__c = :Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId]);
                Integer j = 0;
                
                //Integer j = 0;
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineCPU q: quoteLine.quoteLines.DataCenterCPU){
                    if(q.performanceMetrics != null){
                        Pricing_RestAPI_QuotesUtilityV2.createPerformanceMetricsRecord(quoteLineListInsert[j].id, q.performanceMetrics, perfMetrics);
                    }
                    j++;
                }
                if(!perfMetrics.isEmpty()){
                    insert perfMetrics;     //create validated performance metrics
                }
                if(!isCreateDraftQuoteLine){
                    Pricing_RestAPI_QuotesUtilityV2.publishQuoteAndQuoteLines(null,null,null,quoteLineIdMap,null,qlIdSet,'SBQQ__QuoteLine__c'); 
                }
                response.successContent = new List<CreatedQuoteLineDetails>();
                List<CreatedQuoteLineDetails> quotelineDetailsList = new List<CreatedQuoteLineDetails>();
                Map<Id, List<CreatedPMDetails>> quotelineToPmMap = new Map<Id, List<CreatedPMDetails>>();
                Integer i = 0;
                for(SBQQ__QuoteLine__c ql: quoteLineListInsert){
                    List<CreatedPMDetails> pmDetailList = new List<CreatedPMDetails>();
                    j = 1;
                    for(Pricing_Performance_Metric__c pm: perfMetrics){
                        if(pm.Pricing_Quote_Line__c == ql.Id){
                            pmDetailList.add(new CreatedPMDetails(pm.Id, quoteLine.quoteLines.DataCenterCPU[i].performanceMetrics[j-1].performanceMetricsReferenceId));
                            j++;
                        }
                    }
                    if(pmDetailList.size()==0){
                        pmDetailList = null;
                    }
                    quotelineToPmMap.put(ql.id, pmDetailList);
                    i++;
                }
                i = 0;
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineCPU qli : quoteLine.quoteLines.DataCenterCPU){
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListInsert[i].Id,quoteLineIdMap.get(quoteLineListInsert[i].id).Pricing_Quote_Line_Number__c,quotelineToPmMap.get(quoteLineListInsert[i].Id), qli.quotelineReferenceID ));
                    i++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineGPU qli : quoteLine.quoteLines.DataCenterGPU){
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListInsert[i].Id,quoteLineIdMap.get(quoteLineListInsert[i].id).Pricing_Quote_Line_Number__c,quotelineToPmMap.get(quoteLineListInsert[i].Id), qli.quotelineReferenceID ));
                    i++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineSSD qli : quoteLine.quoteLines.OptaneSSD){                           
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListInsert[i].Id,quoteLineIdMap.get(quoteLineListInsert[i].id).Pricing_Quote_Line_Number__c,quotelineToPmMap.get(quoteLineListInsert[i].Id), qli.quotelineReferenceID));
                    i++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLinePMem qli : quoteLine.quoteLines.OptanePMem){
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListInsert[i].Id,quoteLineIdMap.get(quoteLineListInsert[i].id).Pricing_Quote_Line_Number__c,quotelineToPmMap.get(quoteLineListInsert[i].Id), qli.quotelineReferenceID ));
                    i++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineEthernet qli : quoteLine.quoteLines.Ethernet){
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListInsert[i].Id,quoteLineIdMap.get(quoteLineListInsert[i].id).Pricing_Quote_Line_Number__c,quotelineToPmMap.get(quoteLineListInsert[i].Id), qli.quotelineReferenceID ));
                    i++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineClient qli : quoteLine.quoteLines.Client){
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListInsert[i].Id,quoteLineIdMap.get(quoteLineListInsert[i].id).Pricing_Quote_Line_Number__c,quotelineToPmMap.get(quoteLineListInsert[i].Id), qli.quotelineReferenceID ));
                    i++;
                }
                response.totalRecords = i;
                response.successContent.addAll(quotelineDetailsList);
            }
            
            
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response, Pricing_RestAPI_QuotesUtilityV2.currentUser);            
        } 
    } 
    
    public static void updateQuotelineRecord(){
        List<SBQQ__QuoteLine__c> quotelineList = new List<SBQQ__QuoteLine__c>();
        String res = 'Record/s updated successfully for Quotelines: ';
        for(Pricing_RestAPI_QuotesUtilityV2.QLICRWonLost qline: statusChangeQuotelines){
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
    
    /**
* @description forms the response for get api
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @return Pricing_RestAPI_Response 
**/
    @HttpGet
    global static Pricing_RestAPI_Response doGet(){
        user currentUser = [Select Id, ContactId,AccountId from User where Id = :UserInfo.getUserId()];
        try{
            if(validateRequest(currentUser.AccountId)){
                if(!isDPG && !isClient){
                    //Valid Request
                    fetchQuoteLineDetails(currentUser.AccountId);
                }
                else if(isSSD){
                    fetchQuoteLineDetailsSSD(currentUser.AccountId);
                }
                else if(isPMem){
                    fetchQuoteLineDetailsPMem(currentUser.AccountId);
                }
                else if(isNIC){
                    fetchQuoteLineDetailsNIC(currentUser.AccountId);
                }
                else if(isGPU){
                    fetchQuoteLineDetailsGPU(currentUser.AccountId);
                }
                else if(isClient){
                    fetchQuoteLineDetailsClient(currentUser.AccountId);
                }
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
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,currentUser);            
        } 
        return response;
    }
    
    /**
* @description validating the parameter for get api
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @return boolean 
**/
    private static boolean validateRequest(String currentUserAccountId){
        boolean isValid=false;
        RestRequest restReq = RestContext.request;
        reqtype = Pricing_RestAPI_Util.getRequestParam('type');
        recId = Pricing_RestAPI_Util.getRequestParam('id');
        quoteLineName = Pricing_RestAPI_Util.getRequestParam('quoteLineNumber');
        if((!String.isBlank(recId) || !String.isBlank(quoteLineName)) && (String.isBlank(reqtype) || reqtype.toLowerCase() == 'all' || reqtype.toLowerCase() == 'quoteline')){
            try{
                if(!String.isBlank(recId)) {
                    quoteLineId = Id.valueOf(recId);
                }
                SBQQ__QuoteLine__c qli = !String.isBlank(recId) ? [Select id,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where id =: quoteLineId and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId ] 
                    : [Select id,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where Pricing_Quote_Line_Number__c = :quoteLineName and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId ];
                        quoteLineId = qli.Id;
                isSSD = qli.Pricing_Program_Type_Nm__c==Label.Pricing_Tender_SSD_Quote;
                isPMem =  qli.Pricing_Program_Type_Nm__c==Label.Pricing_Tender_PMem_Quote;
                isNIC = qli.Pricing_Program_Type_Nm__c==Label.Pricing_Tender_NIC_Quote;
                isGPU = qli.Pricing_Program_Type_Nm__c==Label.Pricing_Tender_DataCenter_GPU;
                isClient = qli.Pricing_Program_Type_Nm__c==Label.Pricing_Tender_CCG_Quote;
                isDPG = (isSSD || isPMem || isNIC || isGPU);
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
    
    /**
* @description fetching the quotelin deatils based on qli type
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
**/
    public static void fetchQuoteLineDetails(String currentUserAccountId){
        List<SBQQ__QuoteLine__c> quoteLinesList = getAllQuoteLineDetails(currentUserAccountId);
        if(quoteLinesList.size() > 0){
            quoteLineWrapper.quoteLines = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLines();
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU qliCPU = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU();
            //show quoteLinedetails and its performance Metrics
            quoteLineWrapper.quoteLines.DataCenterCPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU>();
            quoteLineWrapper.quoteLines.OptaneSSD = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineSSD>();
            quoteLineWrapper.quoteLines.OptanePMem = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinePMem>();
            quoteLineWrapper.quoteLines.Ethernet = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineEthernet>();
            quoteLineWrapper.quoteLines.DataCenterGPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineGPU>();
            getQuoteLineDetailsWrapper(quoteLinesList[0], qliCPU);
            quoteLineWrapper.quoteLines.DataCenterCPU.add(qliCPU);
            response.successContent = new List<QuoteLineWrapper>();
            response.successContent.add(quoteLineWrapper);
            response.totalRecords= 1;
        }else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
        }
    } 
    
    public static void fetchQuoteLineDetailsSSD(String currentUserAccountId){
        List<SBQQ__QuoteLine__c> quoteLinesList = getAllQuoteLineDetailsSSD(currentUserAccountId);
        if(quoteLinesList.size() > 0){
            quoteLineWrapper.quoteLines = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLines();
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineSSD qliSSD = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineSSD();
            //show quoteLinedetails and its performance Metrics
            quoteLineWrapper.quoteLines.DataCenterCPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU>();
            quoteLineWrapper.quoteLines.OptaneSSD = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineSSD>();
            quoteLineWrapper.quoteLines.OptanePMem = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinePMem>();
            quoteLineWrapper.quoteLines.Ethernet = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineEthernet>();
            quoteLineWrapper.quoteLines.DataCenterGPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineGPU>();
            getQuoteLineDetailsWrapperSSD(quoteLinesList[0], qliSSD); 
            quoteLineWrapper.quoteLines.OptaneSSD.add(qliSSD); 
            response.successContent = new List<QuoteLineWrapper>();
            response.successContent.add(quoteLineWrapper);
            response.totalRecords= 1;
        }else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
        }
    }
    
    public static void fetchQuoteLineDetailsPMem(String currentUserAccountId){
        List<SBQQ__QuoteLine__c> quoteLinesList = getAllQuoteLineDetailsPMem(currentUserAccountId);
        if(quoteLinesList.size() > 0){
            quoteLineWrapper.quoteLines = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLines();
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinePMem qliPMem = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinePMem();
            //show quoteLinedetails and its performance Metrics
            quoteLineWrapper.quoteLines.DataCenterCPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU>();
            quoteLineWrapper.quoteLines.OptaneSSD = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineSSD>();
            quoteLineWrapper.quoteLines.OptanePMem = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinePMem>();
            quoteLineWrapper.quoteLines.Ethernet = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineEthernet>();
            quoteLineWrapper.quoteLines.DataCenterGPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineGPU>();
            getQuoteLineDetailsWrapperPMem(quoteLinesList[0], qliPMem);
            quoteLineWrapper.quoteLines.OptanePMem.add(qliPMem);           
            response.successContent = new List<QuoteLineWrapper>();
            response.successContent.add(quoteLineWrapper);
            response.totalRecords= 1;
        }else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
        }
    }
    
    public static void fetchQuoteLineDetailsNIC(String currentUserAccountId){
        List<SBQQ__QuoteLine__c> quoteLinesList = getAllQuoteLineDetailsNIC(currentUserAccountId);
        if(quoteLinesList.size() > 0){
            quoteLineWrapper.quoteLines = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLines();
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineEthernet qliEthernet = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineEthernet();
            //show quoteLinedetails and its performance Metrics
            quoteLineWrapper.quoteLines.DataCenterCPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU>();
            quoteLineWrapper.quoteLines.OptaneSSD = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineSSD>();
            quoteLineWrapper.quoteLines.OptanePMem = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinePMem>();
            quoteLineWrapper.quoteLines.Ethernet = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineEthernet>();
            quoteLineWrapper.quoteLines.DataCenterGPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineGPU>();
            getQuoteLineDetailsWrapperNIC(quoteLinesList[0], qliEthernet);
            quoteLineWrapper.quoteLines.Ethernet.add(qliEthernet);
            response.successContent = new List<QuoteLineWrapper>();
            response.successContent.add(quoteLineWrapper);
            response.totalRecords= 1;
        }else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
        }
    }

    public static void fetchQuoteLineDetailsGPU(String currentUserAccountId){
        List<SBQQ__QuoteLine__c> quoteLinesList = getAllQuoteLineDetailsGPU(currentUserAccountId);
        if(quoteLinesList.size() > 0){
            quoteLineWrapper.quoteLines = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLines();
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineGPU qliGPU = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineGPU();
            //show quoteLinedetails and its performance Metrics
            quoteLineWrapper.quoteLines.DataCenterCPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU>();
            quoteLineWrapper.quoteLines.OptaneSSD = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineSSD>();
            quoteLineWrapper.quoteLines.OptanePMem = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinePMem>();
            quoteLineWrapper.quoteLines.Ethernet = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineEthernet>();
            quoteLineWrapper.quoteLines.DataCenterGPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineGPU>();
            getQuoteLineDetailsWrapperGPU(quoteLinesList[0], qliGPU);
            quoteLineWrapper.quoteLines.DataCenterGPU.add(qliGPU);
            response.successContent = new List<QuoteLineWrapper>();
            response.successContent.add(quoteLineWrapper);
            response.totalRecords= 1;
        }else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
        }
    }
    
    /**
* @description Method written to fetch the Client Quote Line details to form the response
* @author Bharath Chandrashekar | 06-20-2022 
**/
    public static void fetchQuoteLineDetailsClient(String currentUserAccountId){
        List<SBQQ__QuoteLine__c> quoteLinesList = getAllQuoteLineDetailsClient(currentUserAccountId);
        if(quoteLinesList.size() > 0){
            quoteLineWrapperClient.quoteLinesClient = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinesClient();
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineClient qliClient = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineClient();
            //show quoteLinedetails and its performance Metrics
            quoteLineWrapperClient.quoteLinesClient.Client = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineClient>();
            getQuoteLineDetailsWrapperClient(quoteLinesList[0], qliClient);
            quoteLineWrapperClient.quoteLinesClient.Client.add(qliClient);
            response.successContent = new List<QuoteLineWrapperClient>();
            response.successContent.add(quoteLineWrapperClient);
            response.totalRecords= 1;
        }else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
        }
    }
    
    /**
* @description retriving the quoteline value based on quoteline  type
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @return List<SBQQ__QuoteLine__c> 
**/
    public static List<SBQQ__QuoteLine__c> getAllQuoteLineDetails(String currentUserAccountId){
        String query = String.escapeSingleQuotes(Label.Pricing_RestAPI_GetQuoteLineQuery1)+String.escapeSingleQuotes(Label.Pricing_RestAPI_GetQuoteLineQuery2);//ch
        if(String.isBlank(reqtype) || reqtype.toLowerCase() == 'all'){
            //if reqType is all add performance metrics subquery to quoteline query
            query = query + String.escapeSingleQuotes(Label.Pricing_RestAPI_GetQuoteLineQuery3.replace('{{PMQUERY}}',String.escapeSingleQuotes(label.Pricing_RestAPI_PMSubQuery)));//ch
            query = query.replace('{{accCheck}}','and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId');
        }else{
            //if reqType is quoteline remove placeholder string from query
            query = query + String.escapeSingleQuotes(Label.Pricing_RestAPI_GetQuoteLineQuery3.replace('{{PMQUERY}}',''));//ch
            query = query.replace('{{accCheck}}','and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId');
        }
        return Database.query(query);  
    }
    
    public static List<SBQQ__QuoteLine__c> getAllQuoteLineDetailsSSD(String currentUserAccountId){
        String query = String.escapeSingleQuotes(Label.Pricing_RestAPI_SSDGetQuoteLineQuery1) + String.escapeSingleQuotes(Label.Pricing_RestAPI_SSDGetQuoteLineQuery2.replace('{{accCheck}}','and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId'));
        return Database.query(query);  
    }
    
    public static List<SBQQ__QuoteLine__c> getAllQuoteLineDetailsPMem(String currentUserAccountId){
        String query = String.escapeSingleQuotes(Label.Pricing_RestAPI_PMemGetQuoteLineQuery1) + String.escapeSingleQuotes(Label.Pricing_RestAPI_PMemGetQuoteLineQuery3)+ String.escapeSingleQuotes(Label.Pricing_RestAPI_PMemGetQuoteLineQuery2.replace('{{accCheck}}','and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId'));
        return Database.query(query);  
    }
    
    public static List<SBQQ__QuoteLine__c> getAllQuoteLineDetailsNIC(String currentUserAccountId){
        String query = String.escapeSingleQuotes(Label.Pricing_RestAPI_NICGetQuoteLineQuery1) + String.escapeSingleQuotes(Label.Pricing_RestAPI_NICGetQuoteLineQuery3)+ String.escapeSingleQuotes(Label.Pricing_RestAPI_NICGetQuoteLineQuery2.replace('{{accCheck}}','and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId'));
        return Database.query(query);  
    }

    public static List<SBQQ__QuoteLine__c> getAllQuoteLineDetailsGPU(String currentUserAccountId){
        String query = String.escapeSingleQuotes(Label.Pricing_RestAPI_GPUGetQuoteLineQuery1) + String.escapeSingleQuotes(Label.Pricing_RestAPI_GPUGetQuoteLineQuery2) + String.escapeSingleQuotes(Label.Pricing_RestAPI_GPUGetQuoteLineQuery3.replace('{{accCheck}}','and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId'));
        return Database.query(query);
    }
    
    /**
* @description Method written to retrieve the Client Quote Line field values
* @author Bharath CHandrashekar | 06-20-2022 
* @return List<SBQQ__QuoteLine__c> 
**/
    public static List<SBQQ__QuoteLine__c> getAllQuoteLineDetailsClient(String currentUserAccountId){
        String query = String.escapeSingleQuotes(Label.Pricing_RestAPI_ClientGetQuoteLineQuery1)+String.escapeSingleQuotes(Label.Pricing_RestAPI_ClientGetQuoteLineQuery3)+String.escapeSingleQuotes(Label.Pricing_RestAPI_ClientGetQuoteLineQuery2.replace('{{accCheck}}','and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId'));
        return Database.query(query);  
    }
    
    /**
* @description formig the wrapper for response based on quoteline type
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @param quoteLine 
* @param qlDetails 
**/
    public static void getQuoteLineDetailsWrapper(SBQQ__QuoteLine__c quoteLine, Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU qlDetails){
        qlDetails.quotelineId = quoteLine.id;
        qlDetails.quoteId = quoteLine.SBQQ__Quote__c;
        qlDetails.quoteLineType = Label.Pricing_RestAPI_Products_CPU_Param ;
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
        qlDetails.newRequestedPrice = quoteLine.Pricing_Request_Discount_Unit_Price_qty__c;
        qlDetails.competitiveBidDiscount = quoteLine.Pricing_Competitive_Bid_Discount_Pct__c;
        qlDetails.approvedECAPPrice = quoteLine.Pricing_ECAP_Price_Dup_Amt__c;
        qlDetails.dealId = quoteLine.Pricing_Deal_RFQ_Dup_Id__c;
        qlDetails.newQuantity = quoteLine.Pricing_New_Quantity_qty__c;
        qlDetails.readyForReview= quoteLine.Pricing_Ready_for_Review_cb__c;
        qlDetails.lastSubmittedDate = quoteLine.Pricing_Last_Submitted_Date_dt__c;
        qlDetails.firstSubmittedDate = quoteLine.Pricing_Original_Submitted_Date_dt__c;
        qlDetails.approvedDate = quoteLine.Pricing_Last_Approved_Date_dt__c;
        qlDetails.lastSubmittedById = quoteLine.Pricing_Last_Submitted_By_Id__c;
        qlDetails.lastSubmittedByName = quoteLine.Pricing_Last_Submitted_By_Id__r.Name;
        qlDetails.quoteLinePricingEndDate = quoteLine.Pricing_End_Date_dt__c;
        qlDetails.quoteLinePricingStartDate = quoteLine.Pricing_Start_Date_dt__c;
        qlDetails.productId=quoteLine.Pricing_Product_Nm__c;
        qlDetails.productName = quoteLine.SBQQ__ProductName__c;
        qlDetails.processorNumber = quoteLine.Pricing_Processor_Number_Nm__c;
        qlDetails.quantity = quoteLine.Pricing_Unit_Qty__c;
        qlDetails.payableQuantity = quoteLine.Pricing_Payable_Quantity__c;
        qlDetails.writeInProduct=quoteLine.Pricing_Other_Product_Nm__c;
        qlDetails.systemModel=quoteLine.Pricing_OEM_System_Model_Nm__c;
        qlDetails.noOfSystems=quoteLine.Pricing_Systems_qty__c;
        qlDetails.noOfCPUsPerSystem = quoteLine.Pricing_CPUs_per_system_qty__c;
        qlDetails.singleSystemPricePoint =quoteLine.Pricing_Single_System_Price_Amt__c;
        qlDetails.customerStdUnitPrice=quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c;
        qlDetails.requestedUnitPrice=quoteLine.Pricing_Req_Discounted_Unit_Price__c;
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
        qlDetails.sourceQuoteLineId=quoteLine.SBQQ__Source__c;
        qlDetails.rejectionReason = quoteLine.Pricing_Rejection_Reason__c;
        qlDetails.rejectionComments = quoteLine.Pricing_Rejection_Comments_nm__c;
        qlDetails.createdByEmail = quoteLine.CreatedBy.Email;
        qlDetails.lostReason = quoteLine.Pricing_Lost_Reason_Nm__c;
        qlDetails.coreCount = quoteLine.pricing_core_count__c;
        qlDetails.consumptionPlatform = quoteLine.Pricing_Consumption_Platform__c != null ? quoteLine.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
        qlDetails.consumptionSalesGeo = quoteLine.Pricing_Consumption_Sale_Geo__c != null ? quoteLine.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
        qlDetails.consumptionCountry = quoteLine.Pricing_Consumption_Country__c != null ? quoteLine.Pricing_Consumption_Country__c.replace(', ', ',') : null;
        qlDetails.consumptionRegion = quoteLine.Pricing_Consumption_Region__c != null ? quoteLine.Pricing_Consumption_Region__c.replace(', ', ',') : null;
        qlDetails.consumptionSegment = quoteLine.Pricing_Consumption_Segment__c != null ? quoteLine.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
        qlDetails.tdp = quoteLine.pricing_TDP__c;
        if(String.isBlank(reqtype) || reqtype.toLowerCase() == 'all'){
            getPerformanceMetricsDetails(qlDetails, quoteLine.Performance_Metrics__r);
        }
    }
    
    public static void getQuoteLineDetailsWrapperSSD(SBQQ__QuoteLine__c quoteLine, Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineSSD qlDetails){
        qlDetails.quoteLineId = quoteLine.id;
        qlDetails.quoteId = quoteLine.SBQQ__Quote__c;
        qlDetails.quoteLineType = Label.Pricing_RestAPI_Products_SSD_Param;
        qlDetails.quote = quoteLine.SBQQ__Quote__r.Name;
        qlDetails.quoteLineNumber=quoteLine.Pricing_Quote_Line_Number__c;
        qlDetails.quoteLineStatus=quoteLine.Pricing_Status_Nm__c;
        qlDetails.changeRequest = quoteLine.Pricing_New_Change_Request_cb__c;//Pricing_Change_Request_cb__c
        qlDetails.approvedPricingStartDate= quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c;
        qlDetails.approvedPricingEndDate=quoteLine.Pricing_Approved_End_Date_Dup_Dt__c;
        qlDetails.approvedQuantity = quoteLine.Pricing_Approved_Unit_Dup_Qty__c;
        qlDetails.effectivePricingStartDate = quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
        qlDetails.billingEndDate = quoteLine.Pricing_Billing_End_Date_Dt__c;
        qlDetails.billingStartDate = quoteLine.Pricing_Billing_Start_Date_Dt__c;
        qlDetails.additionalTermsandConditions = quoteLine.Pricing_Additional_T_C_s_Txt__c;
        qlDetails.newRequestedPrice = quoteLine.Pricing_Request_Discount_Unit_Price_qty__c;
        qlDetails.approvedECAPPrice = quoteLine.Pricing_ECAP_Price_Dup_Amt__c;
        qlDetails.dealId = quoteLine.Pricing_Deal_RFQ_Dup_Id__c;
        qlDetails.newQuantity = quoteLine.Pricing_New_Quantity_qty__c;
        qlDetails.readyForReview= quoteLine.Pricing_Ready_for_Review_cb__c;
        qlDetails.lastSubmittedDate = quoteLine.Pricing_Last_Submitted_Date_dt__c;
        qlDetails.firstSubmittedDate = quoteLine.Pricing_Original_Submitted_Date_dt__c;
        qlDetails.approvedDate = quoteLine.Pricing_Last_Approved_Date_dt__c;
        qlDetails.lastSubmittedById = quoteLine.Pricing_Last_Submitted_By_Id__c;
        qlDetails.lastSubmittedByName = quoteLine.Pricing_Last_Submitted_By_Id__r.Name;
        qlDetails.quoteLinePricingEndDate = quoteLine.Pricing_End_Date_dt__c;
        qlDetails.quoteLinePricingStartDate = quoteLine.Pricing_Start_Date_dt__c;
        qlDetails.productId=quoteLine.Pricing_Product_Nm__c;
        qlDetails.productName = quoteLine.SBQQ__ProductName__c;
        qlDetails.familyName = quoteLine.Pricing_Family_Name_Nm__c;
        qlDetails.quantity = quoteLine.Pricing_Total_Volume_Qty__c;
        qlDetails.payableQuantity = quoteLine.Pricing_Payable_Quantity__c;
        qlDetails.requestedUnitPrice=quoteLine.Pricing_Req_Discounted_Unit_Price__c;
        qlDetails.requestedDiscountUnitPricePerGB = quoteLine.Pricing_ReqDiscUnitPricePerGB_Amt__c;
        qlDetails.competitorName=quoteLine.Pricing_Competitor_OEM_Nm__c;
        qlDetails.competitorProduct=quoteLine.Pricing_Comp_Product_Txt__c;
        qlDetails.competitorSingleSystemPricePoint=quoteLine.Pricing_Comp_Unit_Price_Amt__c;
        qlDetails.competitorUnitPricePerGB = quoteLine.Pricing_CompUnitPricePerGB_Amt__c;
        qlDetails.competitorDensity=quoteLine.Pricing_Comp_Density_Nbr__c;
        qlDetails.volumeByQuarterAndReasoning=quoteLine.Pricing_VolumeByQuarterAndReasoning_Txt__c;
        qlDetails.additionalComments = quoteLine.Pricing_Additional_Comments_Txt__c; 
        qlDetails.referenceQuoteLineNumberId = quoteLine.Pricing_Reference_Quote_Line_Nbr__c;
        qlDetails.referenceQuoteLineNumber=quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c;
        qlDetails.sourceQuoteLineId=quoteLine.SBQQ__Source__c;
        qlDetails.rejectionReason = quoteLine.Pricing_Rejection_Reason__c;
        qlDetails.rejectionComments = quoteLine.Pricing_Rejection_Comments_nm__c;
        qlDetails.createdByEmail = quoteLine.CreatedBy.Email;
        qlDetails.lostReason = quoteLine.Pricing_Lost_Reason_Nm__c;
        qlDetails.writeInProduct=quoteLine.Pricing_Other_Product_Nm__c;
        qlDetails.density = quoteline.Pricing_Density__c;
        qlDetails.consumptionPlatform = quoteLine.Pricing_Consumption_Platform__c != null ? quoteLine.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
        qlDetails.consumptionSalesGeo = quoteLine.Pricing_Consumption_Sale_Geo__c != null ? quoteLine.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
        qlDetails.consumptionCountry = quoteLine.Pricing_Consumption_Country__c != null ? quoteLine.Pricing_Consumption_Country__c.replace(', ', ',') : null;
        qlDetails.consumptionRegion = quoteLine.Pricing_Consumption_Region__c != null ? quoteLine.Pricing_Consumption_Region__c.replace(', ', ',') : null;
        qlDetails.consumptionSegment = quoteLine.Pricing_Consumption_Segment__c != null ? quoteLine.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
        qlDetails.tdp = quoteLine.pricing_TDP__c;
        
    }
    
    public static void getQuoteLineDetailsWrapperPMem(SBQQ__QuoteLine__c quoteLine, Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinePMem qlDetails){
        qlDetails.quoteLineId = quoteLine.id;
        qlDetails.quoteId = quoteLine.SBQQ__Quote__c;
        qlDetails.quoteLineType = Label.Pricing_RestAPI_Products_PMem_Param;
        qlDetails.quote = quoteLine.SBQQ__Quote__r.Name;
        qlDetails.quoteLineNumber=quoteLine.Pricing_Quote_Line_Number__c;
        qlDetails.quoteLineStatus=quoteLine.Pricing_Status_Nm__c;
        qlDetails.changeRequest = quoteLine.Pricing_New_Change_Request_cb__c;//Pricing_Change_Request_cb__c
        qlDetails.approvedPricingStartDate= quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c;
        qlDetails.approvedPricingEndDate=quoteLine.Pricing_Approved_End_Date_Dup_Dt__c;
        qlDetails.approvedQuantity = quoteLine.Pricing_Approved_Unit_Dup_Qty__c;
        qlDetails.effectivePricingStartDate = quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
        qlDetails.billingEndDate = quoteLine.Pricing_Billing_End_Date_Dt__c;
        qlDetails.billingStartDate = quoteLine.Pricing_Billing_Start_Date_Dt__c;
        qlDetails.additionalTermsandConditions = quoteLine.Pricing_Additional_T_C_s_Txt__c;
        qlDetails.newRequestedPrice = quoteLine.Pricing_Request_Discount_Unit_Price_qty__c;
        qlDetails.approvedECAPPrice = quoteLine.Pricing_ECAP_Price_Dup_Amt__c;
        qlDetails.dealId = quoteLine.Pricing_Deal_RFQ_Dup_Id__c;
        qlDetails.newQuantity = quoteLine.Pricing_New_Quantity_qty__c;
        qlDetails.readyForReview= quoteLine.Pricing_Ready_for_Review_cb__c;
        qlDetails.lastSubmittedDate = quoteLine.Pricing_Last_Submitted_Date_dt__c;
        qlDetails.firstSubmittedDate = quoteLine.Pricing_Original_Submitted_Date_dt__c;
        qlDetails.approvedDate = quoteLine.Pricing_Last_Approved_Date_dt__c;
        qlDetails.lastSubmittedById = quoteLine.Pricing_Last_Submitted_By_Id__c;
        qlDetails.lastSubmittedByName = quoteLine.Pricing_Last_Submitted_By_Id__r.Name;
        qlDetails.quoteLinePricingEndDate = quoteLine.Pricing_End_Date_dt__c;
        qlDetails.quoteLinePricingStartDate = quoteLine.Pricing_Start_Date_dt__c;
        qlDetails.productId=quoteLine.Pricing_Product_Nm__c;
        qlDetails.productName = quoteLine.SBQQ__ProductName__c;
        qlDetails.quantity = quoteLine.Pricing_Unit_Qty__c;
        qlDetails.payableQuantity = quoteLine.Pricing_Payable_Quantity__c;
        qlDetails.requestedUnitPrice=quoteLine.Pricing_Req_Discounted_Unit_Price__c;
        qlDetails.writeInProduct = quoteLine.Pricing_Other_Product_Nm__c;
        qlDetails.competitorName=quoteLine.Pricing_Competitor_OEM_Nm__c;
        qlDetails.competitorSingleSystemPricePoint=quoteLine.Pricing_Comp_Unit_Price_Amt__c;
        qlDetails.competitorDensity=quoteLine.Pricing_Comp_Density_Nbr__c;
        qlDetails.systemModel = quoteLine.Pricing_OEM_System_Model_Nm__c;
        qlDetails.noOfSystems = quoteLine.Pricing_Systems_qty__c;
        qlDetails.noOfUnitsPerSystem = quoteLine.Pricing_Units_per_system_qty__c;
        qlDetails.pairedCPU = quoteLine.Pricing_CPU_Txt__c;
        qlDetails.dramDensity = quoteLine.Pricing_DRAM_Density_Nbr__c;
        qlDetails.noOfDRAMPerSystem = quoteLine.Pricing_DRAM_per_System_qty__c;
        qlDetails.competitorQuantity = quoteLine.Pricing_Comp_Units_Cnt__c;
        qlDetails.noOfCPUsPerSystem = quoteLine.Pricing_CPU_Quantity_per_System_qty__c;
        qlDetails.serverIntegration = quoteLine.Pricing_Server_Integration_Nm__c;
        qlDetails.workload = quoteLine.Pricing_Workload_Txt__c;
        qlDetails.pocTestingResults = quoteLine.Pricing_POC_testing_results_Txt__c;
        qlDetails.additionalComments = quoteLine.Pricing_Additional_Comments_Txt__c; 
        qlDetails.referenceQuoteLineNumberId = quoteLine.Pricing_Reference_Quote_Line_Nbr__c;
        qlDetails.referenceQuoteLineNumber=quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c;
        qlDetails.sourceQuoteLineId=quoteLine.SBQQ__Source__c;
        qlDetails.competitorNoOfSystems = quoteLine.Pricing_Competitor_Systems_Cnt__c;
        qlDetails.competitorNoOfUnitsPerSystem = quoteLine.Pricing_Comp_CPUs_per_system_Cnt__c;
        qlDetails.forecastProductName = quoteLine.Pricing_DealProduct_Nm__c;
        qlDetails.requestedDiscountUnitPricePerGB = quoteLine.Pricing_ReqDiscUnitPricePerGB_Amt__c;
        qlDetails.competitorUnitPricePerGB = quoteLine.Pricing_CompUnitPricePerGB_Amt__c;
        qlDetails.rejectionReason = quoteLine.Pricing_Rejection_Reason__c;
        qlDetails.rejectionComments = quoteLine.Pricing_Rejection_Comments_nm__c;
        qlDetails.createdByEmail = quoteLine.CreatedBy.Email;
        qlDetails.density = quoteline.Pricing_Density__c;
        qlDetails.lostReason = quoteLine.Pricing_Lost_Reason_Nm__c;
        qlDetails.customerStdUnitPrice = quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c;
        qlDetails.consumptionPlatform = quoteLine.Pricing_Consumption_Platform__c != null ? quoteLine.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
        qlDetails.consumptionSalesGeo = quoteLine.Pricing_Consumption_Sale_Geo__c != null ? quoteLine.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
        qlDetails.consumptionCountry = quoteLine.Pricing_Consumption_Country__c != null ? quoteLine.Pricing_Consumption_Country__c.replace(', ', ',') : null;
        qlDetails.consumptionRegion = quoteLine.Pricing_Consumption_Region__c != null ? quoteLine.Pricing_Consumption_Region__c.replace(', ', ',') : null;
        qlDetails.consumptionSegment = quoteLine.Pricing_Consumption_Segment__c != null ? quoteLine.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
        
        qlDetails.tdp = quoteLine.pricing_TDP__c;
    }
    
    public static void getQuoteLineDetailsWrapperNIC(SBQQ__QuoteLine__c quoteLine, Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineEthernet qlDetails){
        qlDetails.quoteLineId = quoteLine.id;
        qlDetails.quoteLineType = Label.Pricing_RestAPI_Products_NIC_Param;
        qlDetails.quoteId = quoteLine.SBQQ__Quote__c;
        qlDetails.quote = quoteLine.SBQQ__Quote__r.Name;
        qlDetails.quoteLineNumber=quoteLine.Pricing_Quote_Line_Number__c;
        qlDetails.quoteLineStatus=quoteLine.Pricing_Status_Nm__c;
        qlDetails.changeRequest = quoteLine.Pricing_New_Change_Request_cb__c;//Pricing_Change_Request_cb__c
        qlDetails.approvedPricingStartDate= quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c;
        qlDetails.approvedPricingEndDate=quoteLine.Pricing_Approved_End_Date_Dup_Dt__c;
        qlDetails.approvedQuantity = quoteLine.Pricing_Approved_Unit_Dup_Qty__c;
        qlDetails.effectivePricingStartDate = quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
        qlDetails.billingEndDate = quoteLine.Pricing_Billing_End_Date_Dt__c;
        qlDetails.billingStartDate = quoteLine.Pricing_Billing_Start_Date_Dt__c;
        qlDetails.additionalTermsandConditions = quoteLine.Pricing_Additional_T_C_s_Txt__c;
        qlDetails.newRequestedPrice = quoteLine.Pricing_Request_Discount_Unit_Price_qty__c;
        qlDetails.approvedECAPPrice = quoteLine.Pricing_ECAP_Price_Dup_Amt__c;
        qlDetails.dealId = quoteLine.Pricing_Deal_RFQ_Dup_Id__c;
        qlDetails.newQuantity = quoteLine.Pricing_New_Quantity_qty__c;
        qlDetails.readyForReview= quoteLine.Pricing_Ready_for_Review_cb__c;
        qlDetails.lastSubmittedDate = quoteLine.Pricing_Last_Submitted_Date_dt__c;
        qlDetails.firstSubmittedDate = quoteLine.Pricing_Original_Submitted_Date_dt__c;
        qlDetails.approvedDate = quoteLine.Pricing_Last_Approved_Date_dt__c;
        qlDetails.lastSubmittedById = quoteLine.Pricing_Last_Submitted_By_Id__c;
        qlDetails.lastSubmittedByName = quoteLine.Pricing_Last_Submitted_By_Id__r.Name;
        qlDetails.quoteLinePricingEndDate = quoteLine.Pricing_End_Date_dt__c;
        qlDetails.quoteLinePricingStartDate = quoteLine.Pricing_Start_Date_dt__c;
        qlDetails.productId=quoteLine.Pricing_Product_Nm__c;
        qlDetails.productName = quoteLine.SBQQ__ProductName__c;
        qlDetails.quantity = quoteLine.Pricing_Total_Volume_Qty__c;
        qlDetails.payableQuantity = quoteLine.Pricing_Payable_Quantity__c;
        qlDetails.requestedUnitPrice=quoteLine.Pricing_Req_Discounted_Unit_Price__c;
        qlDetails.competitorProduct=quoteLine.Pricing_Comp_Product_Txt__c;
        qlDetails.competitorSingleSystemPricePoint=quoteLine.Pricing_Comp_Unit_Price_Amt__c;
        qlDetails.additionalComments = quoteLine.Pricing_Additional_Comments_Txt__c; 
        qlDetails.referenceQuoteLineNumberId = quoteLine.Pricing_Reference_Quote_Line_Nbr__c;            
        qlDetails.competitorQuantity = quoteLine.Pricing_Competitor_Quantity_nbr__c;
        qlDetails.referenceQuoteLineNumber=quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c;
        qlDetails.sourceQuoteLineId=quoteLine.SBQQ__Source__c;
        qlDetails.rejectionReason = quoteLine.Pricing_Rejection_Reason__c;
        qlDetails.rejectionComments = quoteLine.Pricing_Rejection_Comments_nm__c;
        qlDetails.createdByEmail = quoteLine.CreatedBy.Email;
        qlDetails.writeInProduct=quoteLine.Pricing_Other_Product_Nm__c;
        qlDetails.consumptionPlatform = quoteLine.Pricing_Consumption_Platform__c != null ? quoteLine.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
        qlDetails.consumptionSalesGeo = quoteLine.Pricing_Consumption_Sale_Geo__c != null ? quoteLine.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
        qlDetails.consumptionCountry = quoteLine.Pricing_Consumption_Country__c != null ? quoteLine.Pricing_Consumption_Country__c.replace(', ', ',') : null;
        qlDetails.consumptionRegion = quoteLine.Pricing_Consumption_Region__c != null ? quoteLine.Pricing_Consumption_Region__c.replace(', ', ',') : null;
        qlDetails.consumptionSegment = quoteLine.Pricing_Consumption_Segment__c != null ? quoteLine.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
        qlDetails.lostReason = quoteLine.Pricing_Lost_Reason_Nm__c;
        qlDetails.tdp = quoteLine.pricing_TDP__c;
    }
    
    public static void getQuoteLineDetailsWrapperGPU(SBQQ__QuoteLine__c quoteLine, Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineGPU qlDetails){
        qlDetails.quoteLineId = quoteLine.id;
        qlDetails.quoteId = quoteLine.SBQQ__Quote__c;
        qlDetails.quoteLineType = Label.Pricing_RestAPI_Products_GPU_Param;
        qlDetails.quote = quoteLine.SBQQ__Quote__r.Name;
        qlDetails.quoteLineNumber=quoteLine.Pricing_Quote_Line_Number__c;
        qlDetails.quoteLineStatus=quoteLine.Pricing_Status_Nm__c;
        qlDetails.writeInPairedCPU = quoteLine.Pricing_Write_In_Paired_CPU_Nm__c;
        qlDetails.noOfGPUs = quoteLine.Pricing_No_of_GPUs__c;
        qlDetails.noOfGPUsPerSystem = quoteLine.Pricing_No_of_GPUs_per_system_nbr__c;
        qlDetails.changeRequest = quoteLine.Pricing_New_Change_Request_cb__c;
        qlDetails.approvedPricingStartDate= quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c;
        qlDetails.approvedPricingEndDate=quoteLine.Pricing_Approved_End_Date_Dup_Dt__c;
        qlDetails.approvedQuantity = quoteLine.Pricing_Approved_Unit_Dup_Qty__c;
        qlDetails.effectivePricingStartDate = quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
        qlDetails.billingEndDate = quoteLine.Pricing_Billing_End_Date_Dt__c;
        qlDetails.billingStartDate = quoteLine.Pricing_Billing_Start_Date_Dt__c;
        qlDetails.additionalTermsandConditions = quoteLine.Pricing_Additional_T_C_s_Txt__c;
        qlDetails.newRequestedPrice = quoteLine.Pricing_Request_Discount_Unit_Price_qty__c;
        qlDetails.competitiveBidDiscount = quoteLine.Pricing_Competitive_Bid_Discount_Pct__c;
        qlDetails.approvedECAPPrice = quoteLine.Pricing_ECAP_Price_Dup_Amt__c;
        qlDetails.dealId = quoteLine.Pricing_Deal_RFQ_Dup_Id__c;
        qlDetails.newQuantity = quoteLine.Pricing_New_Quantity_qty__c;
        qlDetails.readyForReview= quoteLine.Pricing_Ready_for_Review_cb__c;
        qlDetails.lastSubmittedDate = quoteLine.Pricing_Last_Submitted_Date_dt__c;
        qlDetails.firstSubmittedDate = quoteLine.Pricing_Original_Submitted_Date_dt__c;
        qlDetails.approvedDate = quoteLine.Pricing_Last_Approved_Date_dt__c;
        qlDetails.lastSubmittedById = quoteLine.Pricing_Last_Submitted_By_Id__c;
        qlDetails.lastSubmittedByName = quoteLine.Pricing_Last_Submitted_By_Id__r.Name;
        qlDetails.quoteLinePricingEndDate = quoteLine.Pricing_End_Date_dt__c;
        qlDetails.quoteLinePricingStartDate = quoteLine.Pricing_Start_Date_dt__c;
        qlDetails.productId=quoteLine.Pricing_Product_Nm__c;
        qlDetails.productName = quoteLine.SBQQ__ProductName__c;
        qlDetails.pairedCPUId=quoteLine.Pricing_Paired_CPU_Nm__c;
        qlDetails.quantity = quoteLine.Pricing_Unit_Qty__c;
        qlDetails.payableQuantity = quoteLine.Pricing_Payable_Quantity__c;
        qlDetails.writeInProduct=quoteLine.Pricing_Other_Product_Nm__c;
        qlDetails.systemModel=quoteLine.Pricing_OEM_System_Model_Nm__c;
        qlDetails.noOfSystems=quoteLine.Pricing_Systems_qty__c;
        qlDetails.noOfCPUsPerSystem = quoteLine.Pricing_CPUs_per_system_qty__c;
        qlDetails.pairedCPU = quoteLine.Pricing_CPU_Txt__c;
        qlDetails.singleSystemPricePoint =quoteLine.Pricing_Single_System_Price_Amt__c;
        qlDetails.customerStdUnitPrice=quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c;
        qlDetails.requestedUnitPrice=quoteLine.Pricing_Req_Discounted_Unit_Price__c;
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
        qlDetails.competitorNoOfGPUs = quoteLine.Pricing_Competitor_No_of_GPUs__c;
        qlDetails.competitorNoOfGPUsPerSystem = quoteLine.Pricing_Comp_No_of_GPUs_per_Sys__c;
        qlDetails.competitorPairedCPU = quoteLine.Pricing_Competitor_Paired_CPU_Nm__c;
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
        qlDetails.sourceQuoteLineId=quoteLine.SBQQ__Source__c;
        qlDetails.rejectionReason = quoteLine.Pricing_Rejection_Reason__c;
        qlDetails.rejectionComments = quoteLine.Pricing_Rejection_Comments_nm__c;
        qlDetails.createdByEmail = quoteLine.CreatedBy.Email;
        qlDetails.lostReason = quoteLine.Pricing_Lost_Reason_Nm__c;
        qlDetails.consumptionPlatform = quoteLine.Pricing_Consumption_Platform__c != null ? quoteLine.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
        qlDetails.consumptionSalesGeo = quoteLine.Pricing_Consumption_Sale_Geo__c != null ? quoteLine.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
        qlDetails.consumptionCountry = quoteLine.Pricing_Consumption_Country__c != null ? quoteLine.Pricing_Consumption_Country__c.replace(', ', ',') : null;
        qlDetails.consumptionRegion = quoteLine.Pricing_Consumption_Region__c != null ? quoteLine.Pricing_Consumption_Region__c.replace(', ', ',') : null;
        qlDetails.consumptionSegment = quoteLine.Pricing_Consumption_Segment__c != null ? quoteLine.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
        qlDetails.tdp = quoteLine.pricing_TDP__c;
    }

    /**
* @description Method written to form the wrapper response for Client Quote Line type
* @author Bharath Chandrashekar | 06-20-2022 
* @param quoteLine 
* @param qlDetailsClient 
**/
    public static void getQuoteLineDetailsWrapperClient(SBQQ__QuoteLine__c quoteLine, Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineClient qlDetailsClient){
        qlDetailsClient.quotelineId = quoteLine.id;
        qlDetailsClient.quoteId = quoteLine.SBQQ__Quote__c;
        qlDetailsClient.quoteLineType = Label.Pricing_RestAPI_Products_Client_Param;
        qlDetailsClient.quote = quoteLine.SBQQ__Quote__r.Name;
        qlDetailsClient.quoteLineNumber=quoteLine.Pricing_Quote_Line_Number__c;
        qlDetailsClient.quoteLineStatus=quoteLine.Pricing_Status_Nm__c;
        qlDetailsClient.changeRequest = quoteLine.Pricing_New_Change_Request_cb__c;
        qlDetailsClient.approvedPricingStartDate= quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c;
        qlDetailsClient.approvedPricingEndDate=quoteLine.Pricing_Approved_End_Date_Dup_Dt__c;
        qlDetailsClient.approvedQuantity = quoteLine.Pricing_Approved_Unit_Dup_Qty__c;
        qlDetailsClient.effectivePricingStartDate = quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
        qlDetailsClient.billingEndDate = quoteLine.Pricing_Billing_End_Date_Dt__c;
        qlDetailsClient.billingStartDate = quoteLine.Pricing_Billing_Start_Date_Dt__c;
        qlDetailsClient.additionalTermsandConditions = quoteLine.Pricing_Additional_T_C_s_Txt__c;
        qlDetailsClient.newRequestedPrice = quoteLine.Pricing_Request_Discount_Unit_Price_qty__c;
        qlDetailsClient.approvedECAPPrice = quoteLine.Pricing_ECAP_Price_Dup_Amt__c;
        qlDetailsClient.dealId = quoteLine.Pricing_Deal_RFQ_Dup_Id__c;
        qlDetailsClient.newQuantity = quoteLine.Pricing_New_Quantity_qty__c;
        qlDetailsClient.readyForReview= quoteLine.Pricing_Ready_for_Review_cb__c;
        qlDetailsClient.lastSubmittedDate = quoteLine.Pricing_Last_Submitted_Date_dt__c;
        qlDetailsClient.firstSubmittedDate = quoteLine.Pricing_Original_Submitted_Date_dt__c;
        qlDetailsClient.approvedDate = quoteLine.Pricing_Last_Approved_Date_dt__c;
        qlDetailsClient.lastSubmittedById = quoteLine.Pricing_Last_Submitted_By_Id__c;
        qlDetailsClient.lastSubmittedByName = quoteLine.Pricing_Last_Submitted_By_Id__r.Name;
        qlDetailsClient.quoteLinePricingEndDate = quoteLine.Pricing_End_Date_dt__c;
        qlDetailsClient.quoteLinePricingStartDate = quoteLine.Pricing_Start_Date_dt__c;
        qlDetailsClient.productId=quoteLine.Pricing_Product_Nm__c;
        qlDetailsClient.productName = quoteLine.SBQQ__ProductName__c;
        qlDetailsClient.processorNumber = quoteLine.Pricing_Processor_Number_Nm__c;
        qlDetailsClient.quantity = quoteLine.Pricing_Total_Volume_Qty__c;
        qlDetailsClient.payableQuantity = quoteLine.Pricing_Payable_Quantity__c;
        qlDetailsClient.writeInProduct=quoteLine.Pricing_Other_Product_Nm__c;
        qlDetailsClient.systemModel=quoteLine.Pricing_OEM_System_Model_Nm__c;
        qlDetailsClient.singleSystemPricePoint =quoteLine.Pricing_Single_System_Price_Amt__c;
        qlDetailsClient.customerStdUnitPrice=quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c;
        qlDetailsClient.requestedUnitPrice=quoteLine.Pricing_Req_Discounted_Unit_Price__c;
        qlDetailsClient.formFactor = quoteLine.Pricing_Form_Factor_Nm__c;
        qlDetailsClient.competitorName=quoteLine.Pricing_Competitor_OEM_Nm__c;
        qlDetailsClient.competitorSystemModel=quoteLine.Pricing_Competitor_System_Model_Nm__c;
        qlDetailsClient.competitorProductId=quoteLine.Pricing_Competetor_Product__c;
        qlDetailsClient.competitorProductName = quoteLine.Pricing_Competetor_Product__r.Name;
        qlDetailsClient.writeInCompetitorProduct=quoteLine.Pricing_Other_Competitor_Product_Nm__c;
        qlDetailsClient.competitorProductProvider = quoteLine.Pricing_comp_Product_Provider_nm__c;
        qlDetailsClient.competitorSingleSystemPricePoint = quoteLine.Pricing_Comp_Unit_Price_Amt__c;
        qlDetailsClient.additionalComments = quoteLine.Pricing_Additional_Comments_Txt__c; 
        qlDetailsClient.referenceQuoteLineNumberId = quoteLine.Pricing_Reference_Quote_Line_Nbr__c;
        qlDetailsClient.referenceQuoteLineNumber=quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c;
        qlDetailsClient.sourceQuoteLineId=quoteLine.SBQQ__Source__c;
        qlDetailsClient.rejectionReason = quoteLine.Pricing_Rejection_Reason__c;
        qlDetailsClient.rejectionComments = quoteLine.Pricing_Rejection_Comments_nm__c;
        qlDetailsClient.createdByEmail = quoteLine.CreatedBy.Email;
        qlDetailsClient.coreCount = quoteLine.pricing_core_count__c;
        qlDetailsClient.consumptionPlatform = quoteLine.Pricing_Consumption_Platform__c != null ? quoteLine.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
        qlDetailsClient.consumptionSalesGeo = quoteLine.Pricing_Consumption_Sale_Geo__c != null ? quoteLine.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
        qlDetailsClient.consumptionCountry = quoteLine.Pricing_Consumption_Country__c != null ? quoteLine.Pricing_Consumption_Country__c.replace(', ', ',') : null;
        qlDetailsClient.consumptionRegion = quoteLine.Pricing_Consumption_Region__c != null ? quoteLine.Pricing_Consumption_Region__c.replace(', ', ',') : null;
        qlDetailsClient.consumptionSegment = quoteLine.Pricing_Consumption_Segment__c != null ? quoteLine.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
        qlDetailsClient.lostReason = quoteLine.Pricing_Lost_Reason_Nm__c;
        qlDetailsClient.tdp = quoteLine.pricing_TDP__c;
    }
    
    public static void getPerformanceMetricsDetails(Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU qliWrapper, List<Pricing_Performance_Metric__c> perfMetrics){
        qliWrapper.performanceMetrics = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.PerformanceMetricsWrapper>(); 
        for(Pricing_Performance_Metric__c pm : perfMetrics){
            Pricing_RestAPI_QuoteDetailsWrapperV2.PerformanceMetricsWrapper pmetric = new Pricing_RestAPI_QuoteDetailsWrapperV2.PerformanceMetricsWrapper();
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
        Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLines quoteLines;
    }
    
    public class QuoteLineWrapperClient implements Pricing_RestAPI_SuccessContent {
        Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinesClient quoteLinesClient;
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
    
    /**
* @description validating update parameters
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @return boolean 
**/
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
    
    /**
* @description validating update fields and updating reocrd
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @param reqBody 
* @return Pricing_RestAPI_Response 
**/
    global static Pricing_RestAPI_Response validateUpdateQli(String reqBody){
        try{
            isPatch = true;
            Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapper quoteLine = (Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapper) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapper.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 utilObj = new Pricing_RestAPI_QuotesUtilityV2();
            boolean isValidQuoteLine = utilObj.validateQuoteLineWrapper(quoteLine, qErrorMsg, !isUpdateDraftQuoteLine);
            if(isValidQuoteLine){
                //valid Performance metrics
                updateValidQuoteLines(quoteLine, qErrorMsg.quoteLineErrorMsgs);
            }else{
                if((!isSvdQuoteLine || TriggerHandler.isActive('Pricing_SVD_QuoteLine_Disabled') && actionType.toLowerCase() == 'resubmit')||actionType.toLowerCase() == 'update'){
                    //Invalid Performance metrics
                    Pricing_RestAPI_Util.quoteErrMsgsV2 = qErrorMsg;
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                }else{
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                    response.errorContent.errorMessage = Label.Pricing_Tender_API_Quotelines_SVD_Resubmit_Error_Msg;
                }
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
    
    /**
* @description updating valid records
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @param quoteLine 
* @param quoteLineErrors 
**/
    public static void updateValidQuoteLines(Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapper quoteLine, List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg> quoteLineErrors){
        try{
            Map<Id,SBQQ__QuoteLine__c> quoteLineIdMap;
            List<Pricing_Performance_Metric__c> perfMetrics = new List<Pricing_Performance_Metric__c>();
            List<SBQQ__QuoteLine__c> quoteLineListUpdate = Pricing_RestAPI_QuotesUtilityV2.createQuoteLineRecords((ID)quoteLine.quoteId, quoteLine.quoteLines);
            if(quoteLineListUpdate.size()>0){
                //update validated quotelines
                Set<Id> qlIdSet = new Set<Id>();
                Integer j = 0;
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineCPU qli : quoteLine.quoteLines.DataCenterCPU){
                    quoteLineListUpdate[j].Id = qli.quoteLineId;
                    qlIdSet.add(qli.quoteLineId);
                    j++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineGPU qli : quoteLine.quoteLines.DataCenterGPU){
                    quoteLineListUpdate[j].Id = qli.quoteLineId;
                    qlIdSet.add(qli.quoteLineId);
                    j++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineSSD qli : quoteLine.quoteLines.OptaneSSD){
                    quoteLineListUpdate[j].Id = qli.quoteLineId;
                    qlIdSet.add(qli.quoteLineId);
                    j++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLinePMem qli : quoteLine.quoteLines.OptanePMem){
                    quoteLineListUpdate[j].Id = qli.quoteLineId;
                    qlIdSet.add(qli.quoteLineId);
                    j++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineEthernet qli : quoteLine.quoteLines.Ethernet){
                    quoteLineListUpdate[j].Id = qli.quoteLineId;
                    qlIdSet.add(qli.quoteLineId);
                    j++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineClient qli : quoteLine.quoteLines.Client){
                    quoteLineListUpdate[j].Id = qli.quoteLineId;
                    qlIdSet.add(qli.quoteLineId);
                    j++;
                }
                update quoteLineListUpdate;
                quoteLineIdMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT id, Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,
                                                                 Pricing_Program_Type_Nm__c,RecordTypeId,Pricing_Ready_for_Review_cb__c,Pricing_Original_Submitted_By_Id__c,
                                                                 Pricing_Original_Submitted_Date_dt__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Last_Submitted_By_Id__c 
                                                                 FROM SBQQ__QuoteLine__c WHERE Id IN:qlIdSet and SBQQ__Quote__r.SBQQ__Account__c = :Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId]);
                j = 0;
                //Integer j = 0;
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineCPU q: quoteLine.quoteLines.DataCenterCPU){
                    if(q.performanceMetrics != null){
                        Pricing_RestAPI_QuotesUtilityV2.createPerformanceMetricsRecord(quoteLineListUpdate[j].id, q.performanceMetrics, perfMetrics);
                    }
                    j++;
                }
                if(!perfMetrics.isEmpty()){
                    upsert perfMetrics;     //upsert validated performance metrics
                }
                if(!isUpdateDraftQuoteLine){
                    //US1104158
                    Pricing_RestAPI_QuotesUtilityV2.publishQuoteAndQuoteLines(null,null,null,quoteLineIdMap,null,qlIdSet,'SBQQ__QuoteLine__c'); 
                }
                response.successContent = new List<CreatedQuoteLineDetails>();
                List<CreatedQuoteLineDetails> quotelineDetailsList = new List<CreatedQuoteLineDetails>();
                Map<Id, List<CreatedPMDetails>> quotelineToPmMap = new Map<Id, List<CreatedPMDetails>>();
                Integer i;
                i = j = 0;
                
                for(SBQQ__QuoteLine__c ql:quoteLineListUpdate){
                    List<CreatedPMDetails> pmDetailList = new List<CreatedPMDetails>();
                    if(quoteLine.quoteLines.DataCenterCPU.size() > i && quoteLine.quoteLines.DataCenterCPU[i].performanceMetrics != null){
                        for(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics pm: quoteLine.quoteLines.DataCenterCPU[i].performanceMetrics){
                            if(perfMetrics[j].Pricing_Quote_Line__c == ql.Id){
                                pmDetailList.add(new CreatedPMDetails(perfMetrics[j].Id, pm.performanceMetricsReferenceId));
                                j++;
                            }else if(perfMetrics[j].Pricing_Quote_Line__c == null){
                                pmDetailList.add(new CreatedPMDetails(perfMetrics[j].Id, pm.performanceMetricsReferenceId));
                                j++;
                            }
                        }
                    }
                    if(pmDetailList.size()==0){
                        pmDetailList = null;
                    }
                    quotelineToPmMap.put(ql.id, pmDetailList);
                    i++;
                }
                i = 0;
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineCPU qli : quoteLine.quoteLines.DataCenterCPU){
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListUpdate[i].Id,quoteLineIdMap.get(quoteLineListUpdate[i].id).Pricing_Quote_Line_Number__c,quotelineToPmMap.get(quoteLineListUpdate[i].Id), qli.quotelineReferenceID ));
                    i++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineGPU qli : quoteLine.quoteLines.DataCenterGPU){                           
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListUpdate[i].Id,quoteLineIdMap.get(quoteLineListUpdate[i].id).Pricing_Quote_Line_Number__c,null, qli.quotelineReferenceID));
                    i++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineSSD qli : quoteLine.quoteLines.OptaneSSD){                           
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListUpdate[i].Id,quoteLineIdMap.get(quoteLineListUpdate[i].id).Pricing_Quote_Line_Number__c,null, qli.quotelineReferenceID));
                    i++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLinePMem qli : quoteLine.quoteLines.OptanePMem){
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListUpdate[i].Id,quoteLineIdMap.get(quoteLineListUpdate[i].id).Pricing_Quote_Line_Number__c,null, qli.quotelineReferenceID ));
                    i++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineEthernet qli : quoteLine.quoteLines.Ethernet){
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListUpdate[i].Id,quoteLineIdMap.get(quoteLineListUpdate[i].id).Pricing_Quote_Line_Number__c,null, qli.quotelineReferenceID ));
                    i++;
                }
                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineClient qli : quoteLine.quoteLines.Client){
                    quotelineDetailsList.add(new CreatedQuoteLineDetails(quoteLineListUpdate[i].Id,quoteLineIdMap.get(quoteLineListUpdate[i].id).Pricing_Quote_Line_Number__c,null, qli.quotelineReferenceID ));
                    i++;
                }
                response.successContent.addAll(quotelineDetailsList);
                response.totalRecords = i;
            }    
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,Pricing_RestAPI_QuotesUtilityV2.currentUser);            
        } 
    }
    
    //----------------------------------------------------------------------------------------------------------------------------
    @httpDelete
    global static Pricing_RestAPI_Response doDelete(){
        RestRequest req = RestContext.request;
        //validate the action parameters if its create or submit
        if(validateDeleteActionParam()){
            processDeleteQuoteline();
        }else{
            //action is invalid
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    
    /**
* @description validating update parameters
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @return boolean 
**/
    public static boolean validateDeleteActionParam(){
        recId = Pricing_RestAPI_Util.getRequestParam('id');
        return !String.isBlank(recId) && recId instanceOf Id ? true : false ;
    }
    
    /**
* @description validating update fields and updating reocrd
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @param reqBody 
* @return Pricing_RestAPI_Response 
**/
    global static void processDeleteQuoteline(){
        try{
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 utilObj = new Pricing_RestAPI_QuotesUtilityV2();
            boolean isValidQuoteLine = utilObj.validateQuoteLineDelete(recId, qErrorMsg);
            if(isValidQuoteLine){
                SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id = : recId];
                List<Pricing_Quote_Line_Status_Age__c> deleteTPTList = new List<Pricing_Quote_Line_Status_Age__c>();
                deleteTPTList = [SELECT Id,Pricing_TPT_Quote_Line_Number__c from Pricing_Quote_Line_Status_Age__c where 
                                 Pricing_TPT_Quote_Line_Number__c =: recId];
                if(quoteLine != null) {
                    delete quoteLine;
                }
                if(!deleteTPTList.isEmpty()){
                    delete deleteTPTList;
                }
                String res = 'Record/s deleted successfully for QuoteLine: '+recId;
                response.totalRecords = 1;
                response.successContent = new List<DeletedQuoteLineDetails>();
                response.successContent.add(new DeletedQuoteLineDetails(res));
            }else{
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
    }
    public class DeletedQuoteLineDetails implements Pricing_RestAPI_SuccessContent {
        String quoteline {set;get;}
        public DeletedQuoteLineDetails(String msg){
            quoteline = msg;
        }
    }
    public class GlobalVariables implements Pricing_RestAPI_SuccessContent {
        Set<String> messageNotification {set;get;}
    }
}