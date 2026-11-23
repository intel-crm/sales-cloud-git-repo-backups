/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_Quotes 
* Version     : 1.0 
* Created Date: 12 Nov 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         11/12/2020              Rest API to create or submit all 4 sections
Rest API to get all 4 section details as response
POST=>
Sample API call:- /services/apexrest/v1.0/quoterequest/quotes?action=
action => create (to create all 4 sections with draft status)
action => submit (to submit all 4 sections with quote as submitted status)
action => getstatus (get status of all quotelines)

GET=>
Sample API call:- /services/apexrest/v1.0/quoterequest/quotes?type=&id=
type => quote (fetch section 1 details)
type => blank, all (fetch all 4 section details)
id => quoteId

Description=> Pass the quoteDetails as an input JSON and it will submit or create the Quote
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/quoterequest/quotes')
global without sharing class Pricing_RestAPI_Quotes{
    
   /* private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_Quotes.class.getName();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    
    public static boolean isGetStatus = false;
    public static boolean isCreateQuoteTeam = false;
    public static boolean isSvdQuote = false;
    public static boolean isResubmit = false;
    public static String type;
    public static String recId;
    public static Id quoteId;
    public static String QUOTE = 'quote';
    public static Map<Id, List<Pricing_Performance_Metric__c>> pmMap = new Map<Id, List<Pricing_Performance_Metric__c>>();
    public static QuoteWrapper quoteWrapper = new QuoteWrapper();
    public static String currentUserContactId;
    public static User currentUser;
    
    @HttpPost
    global static Pricing_RestAPI_Response doPost(){
        RestRequest req = RestContext.request;
        currentUser = [Select Id,ContactId,AccountId,Email from User where Id = :UserInfo.getUserId()];
        //currentUserContactId = [Select Id,ContactId,Email from User where Id = :UserInfo.getUserId()].ContactId;
        //validate the action parameters if its create or submit
        if(validateActionParam()){
            processRequest(req.requestBody.toString()); 
        }else{
            //action is invalid
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    public static boolean validateActionParam(){
        String typeParam = Pricing_RestAPI_Util.getRequestParam('type');
        if(typeParam != null && typeParam.toLowerCase() == 'svd'){
            isSvdQuote = true;
        }
        String actionType = Pricing_RestAPI_Util.getRequestParam('action');
        if(actionType != null && (actionType.toLowerCase() == 'create' || actionType.toLowerCase() == 'submit' || actionType.toLowerCase() == 'getstatus' || actionType.toLowerCase() == 'quoteteam')){ 
            //if action is create then create Quote in draft status
            //if action is submit then create Quote and submit it for Intel Review
            Pricing_RestAPI_QuotesUtility.isCreateDraftQuote = (actionType.toLowerCase()=='create') ? true : false;     
            isGetStatus = (actionType.toLowerCase()=='getstatus') ? true : false;
            isCreateQuoteTeam = (actionType.toLowerCase()=='quoteteam') ? true : false;
            return true;  
        }else{
            //invalid action parameter
            return false;
        }
    }
    public static Pricing_RestAPI_Response processRequest(String reqBody){
        try {
            if(isGetStatus){
                Set<Id> quoteIds = new Set<Id>();
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(reqBody);
                List<Object> reqQuoteIds = (List<Object>) jsonMap.get('quoteIds');
                Pricing_RestAPI_QuotesUtility quoteUtility = new Pricing_RestAPI_QuotesUtility();
                Pricing_RestAPI_QuotesUtility.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
                for(Object obj:reqQuoteIds){
                    String quoteId = (String)obj;
                    if(quoteId.length() == 18 && Pattern.matches('[a-zA-Z0-9]{15,18}',quoteId)){
                        quoteIds.add(quoteId);
                    }
                }
                getStatusDetails(quoteIds);
            }else if(isCreateQuoteTeam){
                Pricing_RestAPI_QuotesUtilityV2.QuoteWrapperDCAI quote = (Pricing_RestAPI_QuotesUtilityV2.QuoteWrapperDCAI) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuoteWrapperDCAI.class);
                Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
                Pricing_RestAPI_QuotesUtility quoteUtility = new Pricing_RestAPI_QuotesUtility();
                boolean isValid = quoteUtility.validateQuote(quote, quoteErrors, true);
                String quoteId = quote.quoteId;
                if(isValid){
                    List<Pricing_Quote_Team__c> quoteTeamInsertList = new List<Pricing_Quote_Team__c>();
                    if(!String.isBlank(Pricing_RestAPI_QuotesUtility.primaryAEEmail)){
                        User aeUser = [SELECT Id, Email FROM User where Email = :Pricing_RestAPI_QuotesUtility.primaryAEEmail and IsActive = true];
                        Pricing_Quote_Team__c aeQTM = new Pricing_Quote_Team__c(Pricing_Quote_Id__c=quoteId, Pricing_Quote_Team_Member_Id__c=aeUser.Id, 
                                                                                Pricing_Role_Nm__c = Label.Pricing_Quote_Team_Role_Account_Executive, RecordTypeId = Pricing_RestAPI_QuotesUtility.quoteTeamRecordTypeId);
                        quoteTeamInsertList.add(aeQTM);
                    }
                    if(Pricing_RestAPI_QuotesUtility.ITSEmailUserList.size() > 0){
                        List<Pricing_Quote_Team__c> itsQTM = Pricing_RestAPI_QuotesUtility.createITSQuoteTeam(quoteId);
                        if(itsQTM.size() > 0){
                            //insert itsQTM;
                            quoteTeamInsertList.addAll(itsQTM);
                        }
                    }
                    if(Pricing_RestAPI_QuotesUtility.validFSEEmailIdMap.size() > 0){
                        List<Pricing_Quote_Team__c> fseQTM = Pricing_RestAPI_QuotesUtility.createFSEQuoteTeam(quoteId);
                        if(fseQTM.size() > 0){
                            //insert fseQTM;
                            quoteTeamInsertList.addAll(fseQTM);
                        }
                    }
                    if(Pricing_RestAPI_QuotesUtility.AEEmailUserList.size() > 0){
                        List<Pricing_Quote_Team__c> aeQTM = Pricing_RestAPI_QuotesUtility.createAEQuoteTeam(quoteId);
                        if(aeQTM.size() > 0){
                            //insert aeQTM;
                            quoteTeamInsertList.addAll(aeQTM);
                        }
                    }
                    if(quoteTeamInsertList.size()>0){
                        Pricing_QuoteTeam_Trigger_Handler.isInertedFromQuoteTriggerorApi = true;
                        insert quoteTeamInsertList;
                    }
                    response.totalRecords = Pricing_RestAPI_QuotesUtility.AEEmailUserList.size() + Pricing_RestAPI_QuotesUtility.ITSEmailUserList.size() + Pricing_RestAPI_QuotesUtility.validFSEEmailIdMap.size();
                    response.successContent = new List<QuoteTeamCreation>();
                    response.successContent.add(new QuoteTeamCreation('Created Successfully'));                
                }else{
                    //Pricing_RestAPI_Util.quoteErrMsgs = quoteErrors;
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                }
            }else{
                Pricing_RestAPI_QuotesUtilityV2.QuoteWrapperDCAI quote = (Pricing_RestAPI_QuotesUtilityV2.QuoteWrapperDCAI) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuoteWrapperDCAI.class);
                Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
                Pricing_RestAPI_QuotesUtility quoteUtility = new Pricing_RestAPI_QuotesUtility();
                List<SBQQ__QuoteLine__c> qoteLines = new List<SBQQ__QuoteLine__c>();
                List<Pricing_Performance_Metric__c> perfMetricsList = new List<Pricing_Performance_Metric__c>();
                boolean isValid = quoteUtility.validateQuote(quote, quoteErrors, true);//validate Quote, Quote Line, Performance Metrics, and Quote Comments 
                
                if(isValid){
                    SBQQ__Quote__c newQuote = Pricing_RestAPI_QuotesUtility.createQuoteRecord(quote.quoteDetails);
                    insert newQuote;
                    List<Pricing_Quote_Team__c> quoteTeamInsertList = new List<Pricing_Quote_Team__c>();
                    if(Pricing_RestAPI_QuotesUtility.validFSEEmailIdMap.size() > 1){
                        List<Pricing_Quote_Team__c> fseQTM = Pricing_RestAPI_QuotesUtility.createFSEQuoteTeam(newQuote.Id);
                        if(fseQTM.size() > 0){
                            //insert fseQTM;
                            quoteTeamInsertList.addAll(fseQTM);
                        }
                    }
                    if(Pricing_RestAPI_QuotesUtility.AEEmailUserList.size() > 1){
                        List<Pricing_Quote_Team__c> aeQTM = Pricing_RestAPI_QuotesUtility.createAEQuoteTeam(newQuote.Id);
                        if(aeQTM.size() > 0){
                            //insert aeQTM;
                            quoteTeamInsertList.addAll(aeQTM);
                        }
                    }
                    if(Pricing_RestAPI_QuotesUtility.ITSEmailUserList.size() > 0){
                        List<Pricing_Quote_Team__c> itsQTM = Pricing_RestAPI_QuotesUtility.createITSQuoteTeam(newQuote.Id);
                        if(itsQTM.size() > 0){
                            //insert itsQTM;
                            quoteTeamInsertList.addAll(itsQTM);
                        }
                    }
                    if(quoteTeamInsertList.size()>0){
                        insert quoteTeamInsertList;
                    }
                    
                    Map<Id,SBQQ__QuoteLine__c> quoteLineIdMap;
                    Set<Id> qlIdSet = new Set<Id>();
                    if(quote.quoteDetails.quoteLines!=null){
                        qoteLines = Pricing_RestAPI_QuotesUtility.createQuoteLineRecords(newQuote.Id, quote.quoteDetails.quoteLines);
                        if(qoteLines.size() > 0){
                            insert qoteLines;                            
                            for(SBQQ__QuoteLine__c ql:qoteLines){
                                qlIdSet.add(ql.Id);
                            }
                            quoteLineIdMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT id, Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,
                                                                             Pricing_Program_Type_Nm__c,RecordTypeId,Pricing_Ready_for_Review_cb__c,Pricing_Original_Submitted_By_Id__c,
                                                                             Pricing_Original_Submitted_Date_dt__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Last_Submitted_By_Id__c 
                                                                             FROM SBQQ__QuoteLine__c WHERE Id IN:qlIdSet]);
                            integer i = 0;
                            for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI qli : quote.quoteDetails.quoteLines){
                                if(qli.performanceMetrics!=null){
                                    Pricing_RestAPI_QuotesUtility.createPerformanceMetricsRecord(qoteLines[i].id, qli.performanceMetrics, perfMetricsList);
                                }
                                i++;                        
                            }
                        }  
                    }else{
                        qoteLines = null;
                    }
                    if(perfMetricsList.size() > 0) {
                        insert perfMetricsList;
                    }else{
                        perfMetricsList = null;
                    }
                    List<Pricing_Comments__c> qComments = Pricing_RestAPI_QuotesUtility.createQuoteComments(newQuote.Id, quote.quoteDetails.quoteComments);
                    List<CreatedQuoteComments> commentDetails = new List<CreatedQuoteComments>();
                    if(qComments.size() > 0){
                        upsert qComments;
                        for(Pricing_Comments__c cmt: qComments){
                            commentDetails.add(new CreatedQuoteComments(cmt.Id, cmt.Pricing_Comment_Ref_Id__c));
                        }
                    }else{
                        commentDetails = null;
                    }
                    if(!Pricing_RestAPI_QuotesUtility.isCreateDraftQuote ){
                        //US1104158
                        Pricing_RestAPI_QuotesUtility.publishQuoteAndQuoteLines(newQuote.Id, quote.quoteDetails.primaryContactEmail, currentUser.AccountId,quoteLineIdMap,Pricing_RestAPI_QuotesUtility.validFSEEmailIdMap,qlIdSet,'SBQQ__Quote__c');                         
                    }
                    else if(Pricing_RestAPI_QuotesUtility.isCreateDraftQuote && (!String.isEmpty(quote.quoteDetails.primaryContactEmail) && currentUser.Email != quote.quoteDetails.primaryContactEmail)){
                        //Primary contact is not the currunet user
                        changePrimaryContact(newQuote.Id, quote.quoteDetails.primaryContactEmail, currentUser.AccountId);
                    }
                    //creating response
                    Integer i = 0;
                    List<CreatedQuoteLineDetails> quotelineDetailsList = new List<CreatedQuoteLineDetails>();
                    if(quote.quoteDetails.quoteLines!=null){
                        Integer j = 0;
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI qli : quote.quoteDetails.quoteLines){                            
                            List<CreatedPMDetails> pmDetailsList = new List<CreatedPMDetails>();
                            if(qli.performanceMetrics!=null){
                                for(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics pm : qli.performanceMetrics){
                                    pmDetailsList.add(new CreatedPMDetails(perfMetricsList[j].Id, pm.performanceMetricsReferenceId));
                                    j++;
                                }
                            }
                            if(pmDetailsList.size() == 0){
                                pmDetailsList = null;
                            }
                            quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, pmDetailsList));
                            i++;
                        }
                    }
                    if(quotelineDetailsList.size()==0){
                        quotelineDetailsList = null;
                    }
                    SBQQ__Quote__c quoteNew = new SBQQ__Quote__c();
                    quoteNew = [Select id, Name, SBQQ__Status__c from SBQQ__Quote__c where id =:newQuote.Id];
                    response.totalRecords = 1;
                    response.successContent = new List<CreatedQuoteDetails>();
                    response.successContent.add(new CreatedQuoteDetails(String.valueOf(newQuote.Id),quoteNew.Name,quoteNew.SBQQ__Status__c, quote.quoteDetails.referenceRequestID, quotelineDetailsList, commentDetails));
                }else {
                    //Pricing_RestAPI_Util.quoteErrMsgs = quoteErrors;
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                }
            }
            return response;
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
            return response;
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
           // Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response); 
            return response;
        }        
    }
    
    public static void getStatusDetails(Set<Id> quoteIds){        
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id,Name, SBQQ__Status__c, Pricing_Customer_Reference_Id__c,(SELECT Id,Pricing_Quote_Line_Number__c, Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c,Pricing_Lost_Reason_Nm__c FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c where Id IN :quoteIds and SBQQ__Account__c = :Pricing_RestAPI_QuotesUtility.currentUserAccountId]);
        response.successContent = new List<GetStatusQuoteDetails>();
        Integer recordCount = 0;
        for(Id quoteId: quoteIds){
            if(quoteMap.get(quoteId)!=null){
                recordCount++;
                List<GetStatusQuoteLineDetails> quotelineDetailsList = new List<GetStatusQuoteLineDetails>();
                if(quoteMap.get(quoteId).SBQQ__LineItems__r != null){
                    List<SBQQ__QuoteLine__c> quoteLineList = quoteMap.get(quoteId).SBQQ__LineItems__r;
                    for(SBQQ__QuoteLine__c quoteline: quoteLineList){
                        string qliType = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Label.Pricing_RestAPI_Products_CPU_Param : 
                        quoteLine.Pricing_Program_Type_Nm__c  == Label.Pricing_Tender_SSD_Quote ? Label.Pricing_RestAPI_Products_SSD_Param :
                        quoteLine.Pricing_Program_Type_Nm__c  == Label.Pricing_Tender_PMem_Quote ? Label.Pricing_RestAPI_Products_PMem_Param : 
                        quoteLine.Pricing_Program_Type_Nm__c  == Label.Pricing_Tender_NIC_Quote ? Label.Pricing_RestAPI_Products_NIC_Param : Label.Pricing_RestAPI_Products_Client_Param ;
                        quotelineDetailsList.add(new GetStatusQuoteLineDetails(String.valueOf(quoteline.Id),quoteline.Pricing_Quote_Line_Number__c, quoteline.Pricing_Status_Nm__c,qliType,quoteline.Pricing_Lost_Reason_Nm__c));
                    }
                }else{
                    quotelineDetailsList = null;
                }
                response.successContent.add(new GetStatusQuoteDetails(String.valueOf(quoteId),quoteMap.get(quoteId).Name, quoteMap.get(quoteId).Pricing_Customer_Reference_Id__c,quoteMap.get(quoteId).SBQQ__Status__c, quotelineDetailsList));
            }
        }
        response.totalRecords = recordCount;        
    }
    
    @future
    public static void changePrimaryContact(Id recId, String primaryContactEmailId, Id accountId){
        try{   
            List<User> usrs = [SELECT id,ContactId FROM User WHERE Email = :primaryContactEmailId AND AccountId= :accountId];
            if(usrs.size() > 0){
                List<SBQQ__Quote__c> quotes = [SELECT Id,SBQQ__PrimaryContact__c FROM SBQQ__Quote__c WHERE Id= :recId] ;
                if(quotes.size() > 0){
                    quotes[0].SBQQ__PrimaryContact__c = usrs[0].ContactId;
                    update quotes[0];
                }
            }
        }catch(Exception exp){Pricing_Tender_Utility.logError(exp);}
    }
    
    
    public class CreatedQuoteDetails implements Pricing_RestAPI_SuccessContent {
        public String quoteId {set;get;} 
        public String quoteNumber {set;get;}
        public String quoteStatus {set;get;}
        public String referenceRequestID {set;get;}
        public List<CreatedQuoteLineDetails> quoteLineDetails {set;get;}
        public List<CreatedQuoteComments> commentDetails {set;get;}
        public CreatedQuoteDetails(String recId, String qNumber, String qStatus, String referenceId, List<CreatedQuoteLineDetails> quotelines, List<CreatedQuoteComments> comment){
            quoteId = recId;
            quoteNumber = qNumber;
            quoteStatus = qStatus;
            referenceRequestID = referenceId;
            quoteLineDetails = quotelines;
            commentDetails = comment;
        }
    }
    
    public class CreatedQuoteLineDetails {
        public String quoteLineId {set;get;} 
        public String quoteLineNumber {set;get;}
        public String quotelineReferenceID {set;get;}
        public List<CreatedPMDetails> performanceMetricsDetails {set;get;}
        public CreatedQuoteLineDetails(String recId,String qlNumber, String referenceId, List<CreatedPMDetails> pms){
            quoteLineId = recId;
            quoteLineNumber = qlNumber;
            quotelineReferenceID = referenceId;
            performanceMetricsDetails = pms;
        }
    }
    
    public class CreatedPMDetails {
        public String performanceMetricsId {set;get;} 
        public String performanceMetricsReferenceId {set;get;}
        public CreatedPMDetails(String recId, String referenceId){
            performanceMetricsId = recId;
            performanceMetricsReferenceId = referenceId;
        }
    }
    
    public class CreatedQuoteComments {
        public String quoteCommentReferenceId {set;get;}
        public String quoteCommentId {set;get;}
        public CreatedQuoteComments(String recId, String referenceId){
            quoteCommentId = recId;
            quoteCommentReferenceId = referenceId;
        }
    }
    
    public class GetStatusQuoteDetails implements Pricing_RestAPI_SuccessContent {
        public String quoteId {set;get;} 
        public String quoteNumber {set;get;}
        public String quoteStatus {set;get;}
        public String referenceRequestID {set;get;}
        public List<GetStatusQuoteLineDetails> quoteLineDetails {set;get;}
        public GetStatusQuoteDetails(String recId,String qNumber, String referenceId, String qStatus, List<GetStatusQuoteLineDetails> quotelines){
            quoteId = recId;
            quoteNumber = qNumber;
            quoteStatus = qStatus;
            referenceRequestID = referenceId;
            quoteLineDetails = quotelines;
        }
    }
    
    public class GetStatusQuoteLineDetails {
        public String quoteLineId {set;get;} 
        public String quoteLineNumber {set;get;}
        public String quotelineStatus {set;get;}
        public String quotelineType {set;get;}
        public String lostReason {set;get;}
        public GetStatusQuoteLineDetails(String recId, String qlNumber, String status, String qliType,String lostReasonVal){
            quoteLineId = recId;
            quoteLineNumber = qlNumber;
            quotelineStatus = status;
            quotelineType = qliType;
            lostReason = lostReasonVal;
        }
    }
    
    public class QuoteTeamCreation implements Pricing_RestAPI_SuccessContent {
        public String record {set;get;}
        public QuoteTeamCreation(String msg){
            record = msg;
        }
    }
    
    //-----------------------------------------------------------------------------------------------------------------
    
    @HttpGet
    global static Pricing_RestAPI_Response doGet(){
        if(validateRequest()){
            //Valid Request
            getAllDetails();
        }else{
            //Not a Valid Request
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    
    //validating QuoteLineId and type
    private static boolean validateRequest(){
        boolean isValid=false;
        RestRequest restReq = RestContext.request;
        type = String.isEmpty(restReq.params.get('type')) ? 'all' : restReq.params.get('type').toLowerCase();
        recId = restReq.params.get('id');
        try{                             
            if(!String.isEmpty(recId) && (String.isEmpty(type) || type.toLowerCase() == 'all' || type.toLowerCase() == 'quote')){
                try{
                    quoteId = Id.valueOf(recId);
                    String currentUserAccountId = [Select Id, AccountId from User where Id = :UserInfo.getUserId()].AccountId;
                    SBQQ__Quote__c quote = [Select Id, SBQQ__Account__c from SBQQ__Quote__c where Id = :quoteId and SBQQ__Account__c = :currentUserAccountId];
                    isValid=true;
                }catch(Exception  exp){
                    isValid=false;
                }
            }
            else if(String.isEmpty(recId) && type.toLowerCase() == 'getsvdquota'){
                isValid = true;
            }
            else{
                isValid = false;
            }
            if(!isValid){
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
            }
            
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
           // Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response);            
        } 
        return isValid;
    }
    
    public static void getAllDetails(){        
        List<SBQQ__Quote__c> quotes = getAllQuoteDetails();
        if(quotes.size()>0){
            quoteWrapper.quoteDetails = new Pricing_RestAPI_QuoteDetailsWrapper.QuoteDetails();
            
            //for type = all or empty : get all four sections
            if(String.isEmpty(type) || type.toLowerCase() == 'all'){
                getQuoteDetails(quotes[0], quoteWrapper.quoteDetails);  
                getQuoteLineDetails(quoteWrapper.quoteDetails, quotes[0].SBQQ__LineItems__r );
                getQuoteComments(quoteWrapper.quoteDetails, quotes[0].Comments__r );
                
                //for type = quote : get quote details only 
            }
            else if(type.toLowerCase() == 'quote'){
                getQuoteDetails(quotes[0], quoteWrapper.quoteDetails);        
            }
            
            response.successContent = new List<QuoteWrapper>();
            response.successContent.add(quoteWrapper);
            response.totalRecords= 1;
        }
        else if(type.toLowerCase() == 'getsvdquota'){
            getSVDQuotaDetails();
        }
        else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
    }
    
    public static Pricing_RestAPI_Response getSVDQuotaDetails(){
        Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
        String currentUserAccountId = [Select Id, AccountId from User where Id = :UserInfo.getUserId()].AccountId;
        Pricing_RestAPI_QuotesUtility util = new Pricing_RestAPI_QuotesUtility();
        Boolean isValid=util.validateSVDQuota(quoteErrors);
        
        if(isValid){
            List<String> capDetails = Pricing_Manage_Small_Volume_Deal.capSizeCheck(currentUserAccountId).split(':');
            List<String> dateDetails = Pricing_RestAPI_QuotesUtility.quarterStartEndDate().split(':');
            if(!capDetails.isEmpty()){
                response.successContent = new List<svdQuotaDetailsWrapper>();
                response.successContent.add(new svdQuotaDetailsWrapper(capDetails[1],capDetails[2],dateDetails[0],dateDetails[1]));
                response.totalRecords= 1;
            }
        }
        else{
            //Pricing_RestAPI_Util.quoteErrMsgs = quoteErrors;
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    
    
    public static List<SBQQ__Quote__c> getAllQuoteDetails(){
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        //for type = empty or all : query all four sections
        if(String.isEmpty(type) || type.toLowerCase() == 'all'){
            String typeCheck = 'where Pricing_Program_Type_Nm__c =\''+ Label.Pricing_Tender_Standard_QuoteLine +'\' or Pricing_Program_Type_Nm__c =\''+ Label.Pricing_Tender_Small_Volume_Quote +'\' order by CreatedDate asc),';
            String qli2 = Label.Pricing_RestAPI_QuoteLineQuery2.replace('order by CreatedDate asc),',typeCheck);
            quotes = Database.query(Label.Pricing_RestAPI_QuoteQuery + Label.Pricing_RestAPI_QuoteLineQuery1  + qli2 + Label.Pricing_RestAPI_QuoteComments);
        }            
        //for type = quote : query section 1
        else if(type.toLowerCase() == 'quote'){
            quotes = Database.query(Label.Pricing_RestAPI_GetQuoteQuery);
        }
        
        List<Pricing_Performance_Metric__c> pmList = new List<Pricing_Performance_Metric__c>();
        Set<Id> quoteLineIds = new Set<Id>();
        if(quotes.size()>0 && quotes.size()!=0){
            for(SBQQ__QuoteLine__c qli :quotes[0].SBQQ__LineItems__r){
                quoteLineIds.add(qli.Id);
            }
        }
        
        if(quoteLineIds.size() > 0){
            List<Pricing_Performance_Metric__c> pmetrics= Database.query(Label.Pricing_RestAPI_PerfMetricsQuery);
            for(Pricing_Performance_Metric__c pm : pmetrics){
                if(pmMap.containsKey(pm.Pricing_Quote_Line__r.id)){
                    pmMap.get(pm.Pricing_Quote_Line__r.id).add(pm);
                }else{
                    pmMap.put(pm.Pricing_Quote_Line__r.id, new List<Pricing_Performance_Metric__c>{pm});
                }
            }
        }
        
        return quotes;
    }
    
    //getting quoteDetails
    public static void getQuoteDetails(SBQQ__Quote__c quote, Pricing_RestAPI_QuoteDetailsWrapper.QuoteDetails qDetails){
        
        qDetails.quoteId=quote.Id;
        qDetails.quoteName = quote.Name;
        qDetails.endCustomer= quote.Pricing_Customer_Nm__c;
        qDetails.unifiedEndCustomer= quote.Pricing_End_Customer__r.Name;
        qDetails.unifiedEndCustomerId= quote.Pricing_End_Customer__r.Id;
        qDetails.endCustomerCountry= quote.Pricing_End_Customer_Country_Nm__c;
        qDetails.endCustomerRegion = quote.Pricing_Region_Nm__c;
        qDetails.projectName = quote.Pricing_Project_Name_Nm__c;
        qDetails.application = quote.Pricing_Server_Deal_Type_Nm__c;
        qDetails.proposalDueDate = quote.Pricing_Bid_Dt__c; 
        qDetails.intelResponseRequestedDate = quote.Pricing_Intel_Response_Requested_By_Date__c; 
        qDetails.pricingStartDate = quote.Pricing_ShipmentStDate_Dt__c;
        qDetails.pricingEndDate = quote.Pricing_ShipmentEndDate_Dt__c;
        qDetails.intelSalesRepEmail = quote.Pricing_Intel_Sales_Rep_Email_Txt__c;
        qDetails.intelAccountExecutiveEmail = quote.Pricing_Intel_Account_Exec_Email_Txt__c;
        qDetails.primaryContactName = quote.SBQQ__PrimaryContact__r.Name;
        qDetails.referenceRequestID = quote.Pricing_Customer_Reference_Id__c;
        qDetails.secondaryContact = quote.Pricing_SecondaryContact_Nm__c;
        qDetails.quoteType = quote.Pricing_Program_Type_Nm__c;
        qDetails.quoteStatus = quote.SBQQ__Status__c;
        qDetails.additionalQuoteLetterRecipients= quote.Pricing_AdditionalRecipients__c;
    }
    
    public static void getQuoteComments(Pricing_RestAPI_QuoteDetailsWrapper.QuoteDetails qDetails, List<Pricing_Comments__c> quoteComments){
        qDetails.quoteComments = new List<Pricing_RestAPI_QuoteDetailsWrapper.QuoteComments>();
        for(Pricing_Comments__c comm : quoteComments){
            Pricing_RestAPI_QuoteDetailsWrapper.QuoteComments qComment = new Pricing_RestAPI_QuoteDetailsWrapper.QuoteComments();
            qComment.question=comm.Pricing_Question__c;
            qComment.answer=comm.Pricing_Answer__c;
            qComment.quoteCommentReferenceId = comm.Pricing_Comment_Ref_Id__c;
            qDetails.quoteComments.add(qComment); 
        }
    }
    
    public static void getQuoteLineDetails(Pricing_RestAPI_QuoteDetailsWrapper.QuoteDetails qDetails, List<SBQQ__QuoteLine__c> quoteLines){
        
        qDetails.quoteLineItems= new List<Pricing_RestAPI_QuoteDetailsWrapper.QuoteLineItems>();
        for(SBQQ__QuoteLine__c qli : quoteLines){
            Pricing_RestAPI_QuoteDetailsWrapper.QuoteLineItems qliWrapper = new Pricing_RestAPI_QuoteDetailsWrapper.QuoteLineItems();
            qliWrapper.quoteLineId = qli.id;
            qliWrapper.quoteLineNumber=qli.Pricing_Quote_Line_Number__c;
            qliWrapper.quoteLineStatus=qli.Pricing_Status_Nm__c;
            qliWrapper.changeRequest = qli.Pricing_New_Change_Request_cb__c;//Pricing_Change_Request_cb__c
            qliWrapper.approvedPricingStartDate= qli.Pricing_Approved_Start_Date_Dup_Dt__c;
            qliWrapper.approvedPricingEndDate=qli.Pricing_Approved_End_Date_Dup_Dt__c;
            qliWrapper.approvedQuantity = qli.Pricing_Approved_Unit_Dup_Qty__c;
            qliWrapper.effectivePricingStartDate = qli.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
            qliWrapper.billingEndDate = qli.Pricing_Billing_End_Date_Dt__c;
            qliWrapper.billingStartDate = qli.Pricing_Billing_Start_Date_Dt__c;
            qliWrapper.additionalTermsandConditions = qli.Pricing_Additional_T_C_s_Txt__c;
            qliWrapper.newRequestedDiscountUnitPrice = qli.Pricing_Request_Discount_Unit_Price_qty__c;
            qliWrapper.competitiveBidDiscount = qli.Pricing_Competitive_Bid_Discount_Pct__c;
            qliWrapper.approvedECAPPrice = qli.Pricing_ECAP_Price_Dup_Amt__c;
            qliWrapper.dealId = qli.Pricing_Deal_RFQ_Dup_Id__c;
            qliWrapper.newQuantity = qli.Pricing_New_Quantity_qty__c;
            qliWrapper.readyForReview= qli.Pricing_Ready_for_Review_cb__c;
            qliWrapper.lastSubmittedDate = qli.Pricing_Last_Submitted_Date_dt__c;
            qliWrapper.approvedDate = qli.Pricing_Last_Approved_Date_dt__c;
            qliWrapper.lastSubmittedById = qli.Pricing_Last_Submitted_By_Id__c;
            qliWrapper.lastSubmittedByName = qli.Pricing_Last_Submitted_By_Id__r.Name;
            qliWrapper.quoteLinePricingEndDate = qli.Pricing_End_Date_dt__c;
            qliWrapper.quoteLinePricingStartDate = qli.Pricing_Start_Date_dt__c;
            qliWrapper.productId=qli.Pricing_Product_Nm__c;
            qliWrapper.productName = qli.SBQQ__ProductName__c;
            qliWrapper.processorNumber = qli.Pricing_Processor_Number_Nm__c;
            qliWrapper.quantity = qli.Pricing_Unit_Qty__c;
            qliWrapper.writeInProduct=qli.Pricing_Other_Product_Nm__c;
            qliWrapper.systemModel=qli.Pricing_OEM_System_Model_Nm__c;
            qliWrapper.noOfSystems=qli.Pricing_Systems_qty__c;
            qliWrapper.noOfCPUsPerSystem = qli.Pricing_CPUs_per_system_qty__c;
            qliWrapper.singleSystemPrice = qli.Pricing_Single_System_Price_Amt__c;
            qliWrapper.customerStdUnitPrice=qli.Pricing_OEM_Standard_Unit_Price_Amt__c;
            qliWrapper.requestedDiscountUnitPrice=qli.Pricing_Req_Discounted_Unit_Price__c;
            qliWrapper.totalBidWithoutDiscount= qli.Pricing_Total_Bid_without_Discount_Amt__c;
            qliWrapper.netIntelBidPrice = qli.Pricing_Net_IA_Bid_Price_Amt__c;
            qliWrapper.intelDiscount = qli.Pricing_Intel_Discount_Pct__c;
            qliWrapper.customerDiscount = qli.Pricing_OEM_Discount_Pct__c;
            qliWrapper.totalIntelDiscount =qli.Pricing_Total_Intel_Discount_Amt__c;
            qliWrapper.intelBidDiscount = qli.Pricing_IA_Bid_Discount_Pct__c;
            
            qliWrapper.additionalDiscount=qli.Pricing_Additional_OEM_Discount_Amt__c;
            qliWrapper.competitorName=qli.Pricing_Competitor_OEM_Nm__c;
            qliWrapper.competitorSystemModel=qli.Pricing_Competitor_System_Model_Nm__c;
            qliWrapper.competitorProductId=qli.Pricing_Competetor_Product__c;
            qliWrapper.competitorProductName = qli.Pricing_Competetor_Product__r.Name;
            qliWrapper.writeInCompetitorProduct=qli.Pricing_Other_Competitor_Product_Nm__c;
            qliWrapper.competitorProductProvider = qli.Pricing_comp_Product_Provider_nm__c;
            qliWrapper.competitorNoOfSystems = qli.Pricing_Competitor_Systems_Cnt__c;
            qliWrapper.competitorNoOfCPUsPerSystem = qli.Pricing_Comp_CPUs_per_system_Cnt__c;
            qliWrapper.competitorQuantity= qli.Pricing_Comp_Units_Cnt__c;
            qliWrapper.competitorSingleSystemPrice = qli.Pricing_Comp_Single_System_Price_Amt__c;
            qliWrapper.competitorAdditionalDiscount = qli.Pricing_Comp_Additional_OEM_Disc_Amt__c;
            qliWrapper.competitorTotalWithoutDiscount = qli.Pricing_Comp_Total_without_discount_Amt__c;
            qliWrapper.netCompetitorBidPrice = qli.Pricing_Net_Comp_Bid_Price_Amt__c;
            qliWrapper.additionalComments = qli.Pricing_Additional_Comments_Txt__c; 
            qliWrapper.referenceQuoteLineNumberId = qli.Pricing_Reference_Quote_Line_Nbr__c;
            qliWrapper.referenceQuoteLineNumber=qli.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c;
            if(pmMap.containsKey(qli.Id)){
                getPerformanceMetricsDetails(qliWrapper, pmMap.get(qli.Id));
            }  
            qDetails.quoteLineItems.add(qliWrapper);
        }
    }
    
    public static void getPerformanceMetricsDetails(Pricing_RestAPI_QuoteDetailsWrapper.QuoteLineItems qliWrapper, List<Pricing_Performance_Metric__c> perfMetrics){
        
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
    
    public class QuoteWrapper implements Pricing_RestAPI_SuccessContent {
        Pricing_RestAPI_QuoteDetailsWrapper.QuoteDetails quoteDetails;
    }
    
    public class svdQuotaDetailsWrapper implements Pricing_RestAPI_SuccessContent {
        public String maximumSVDQuotesAllowed {set;get;}
        public String remainingNoOfQuotes {set;get;}
        public String quarterStartDate {set;get;}
        public String quarterEndDate {set;get;}
        public svdQuotaDetailsWrapper( String maxSvd, String remSVD, String startDate, String endDate){
            maximumSVDQuotesAllowed = maxSvd;
            remainingNoOfQuotes = remSVD;
            quarterStartDate = startDate;
            quarterEndDate = endDate;
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------------
    
    @HttpPatch
    global static Pricing_RestAPI_Response doPatch(){
        RestRequest req = RestContext.request;
        currentUser = [Select Id,ContactId,AccountId,Email from User where Id = :UserInfo.getUserId()];
        //validate the action parameters if its update
        if(validateUpdateParam()){
            processUpdateRequest(req.requestBody.toString()); 
        }else{
            //action is invalid
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    public static boolean validateUpdateParam(){
        
        String actionType = Pricing_RestAPI_Util.getRequestParam('action');
        if(actionType != null && (actionType.toLowerCase() == 'update' || actionType.toLowerCase() == 'resubmit')){
            Pricing_RestAPI_QuotesUtility.isCreateDraftQuote = (actionType.toLowerCase()=='update') ? true : false;
            Pricing_RestAPI_QuotesUtility.isUpdateDraftQuote = (actionType.toLowerCase()=='update' || actionType.toLowerCase()=='resubmit') ? true : false;
            isResubmit = (actionType.toLowerCase()=='resubmit') ? true : false;
            return true;  
        }else{
            //invalid action parameter
            return false;
        }
    }
    public static void processUpdateRequest(String reqBody){
        try {
            Pricing_RestAPI_QuotesUtilityV2.QuoteWrapperDCAI quote = (Pricing_RestAPI_QuotesUtilityV2.QuoteWrapperDCAI) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuoteWrapperDCAI.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtility quoteUtility = new Pricing_RestAPI_QuotesUtility();
            List<SBQQ__QuoteLine__c> qoteLines = new List<SBQQ__QuoteLine__c>();
            Map<String,Id> validFSEEmailIdMapDetails;
            List<Pricing_Performance_Metric__c> perfMetricsList = new List<Pricing_Performance_Metric__c>();
            boolean isValid = quoteUtility.validateQuote(quote, quoteErrors, true);//validate Quote, Quote Line, Performance Metrics, and Quote Comments 
            
            if(isValid){
                SBQQ__Quote__c newQuote = Pricing_RestAPI_QuotesUtility.createQuoteRecord(quote.quoteDetails);
                newQuote.Id = quote.quoteId;
                update newQuote;
                List<Pricing_Quote_Team__c> quoteTeamInsertList = new List<Pricing_Quote_Team__c>();
                if(Pricing_RestAPI_QuotesUtility.validFSEEmailIdMap.size() > 1){
                    validFSEEmailIdMapDetails = new Map<String,Id>(Pricing_RestAPI_QuotesUtility.validFSEEmailIdMap);
                    List<Pricing_Quote_Team__c> fseQTM = Pricing_RestAPI_QuotesUtility.createFSEQuoteTeam(newQuote.Id);
                    if(fseQTM.size() > 0){
                        //insert fseQTM;
                        quoteTeamInsertList.addAll(fseQTM);
                    }
                }
                if(Pricing_RestAPI_QuotesUtility.AEEmailUserList.size() > 1){
                    List<Pricing_Quote_Team__c> aeQTM = Pricing_RestAPI_QuotesUtility.createAEQuoteTeam(newQuote.Id);
                    if(aeQTM.size() > 0){
                        //insert aeQTM;
                        quoteTeamInsertList.addAll(aeQTM);
                    }
                }
                if(Pricing_RestAPI_QuotesUtility.ITSEmailUserList.size() > 0){
                    List<Pricing_Quote_Team__c> itsQTM = Pricing_RestAPI_QuotesUtility.createITSQuoteTeam(newQuote.Id);
                    if(itsQTM.size() > 0){
                        //insert itsQTM;
                        quoteTeamInsertList.addAll(itsQTM);
                    }
                }
                if(quoteTeamInsertList.size()>0){
                    insert quoteTeamInsertList;
                }
                
                Map<Id,SBQQ__QuoteLine__c> quoteLineIdMap;
                if(quote.quoteDetails.quoteLines!=null){
                    qoteLines = Pricing_RestAPI_QuotesUtility.createQuoteLineRecords(newQuote.Id, quote.quoteDetails.quoteLines);
                    Integer j = 0;
                    for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI qli : quote.quoteDetails.quoteLines){
                        if(qli.quoteLineId != null && !String.isBlank(qli.quoteLineId.trim())){
                            qoteLines[j].Id = qli.quoteLineId;
                        }
                        j++;
                    }
                }
                Set<Id> qlIdSet = new Set<Id>();
                if(qoteLines.size() > 0){
                    upsert qoteLines;  //updated for resubmit quote               
                    for(SBQQ__QuoteLine__c ql:qoteLines){
                        qlIdSet.add(ql.Id);
                    }
                    quoteLineIdMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT id, Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,
                                                                     Pricing_Program_Type_Nm__c,RecordTypeId,Pricing_Ready_for_Review_cb__c,Pricing_Original_Submitted_By_Id__c,
                                                                     Pricing_Original_Submitted_Date_dt__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Last_Submitted_By_Id__c 
                                                                     FROM SBQQ__QuoteLine__c WHERE Id IN:qlIdSet]);
                    
                    Integer i = 0; // updated fot resubmit quote
                    for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI qli : quote.quoteDetails.quoteLines){
                        Pricing_RestAPI_QuotesUtility.createPerformanceMetricsRecord(qoteLines[i].Id, qli.performanceMetrics, perfMetricsList); //updated for quote resubmit
                        i++;
                    }
                }else{
                    qoteLines = null;
                }
                if(perfMetricsList.size() > 0) {
                    upsert perfMetricsList;
                }else{
                    perfMetricsList = null;
                }
                List<Pricing_Comments__c> qComments = Pricing_RestAPI_QuotesUtility.createQuoteComments(newQuote.Id, quote.quoteDetails.quoteComments);
                List<CreatedQuoteComments> commentDetails = new List<CreatedQuoteComments>();
                if(qComments.size() > 0){
                    upsert qComments;
                    for(Pricing_Comments__c cmt: qComments){
                        commentDetails.add(new CreatedQuoteComments(cmt.Id, cmt.Pricing_Comment_Ref_Id__c));
                    }
                }else{
                    commentDetails = null;
                }
                //update and submit quote
                if(isResubmit){
                    //US1104158
                    Pricing_RestAPI_QuotesUtility.publishQuoteAndQuoteLines(newQuote.Id, quote.quoteDetails.primaryContactEmail, currentUser.AccountId,quoteLineIdMap,validFSEEmailIdMapDetails,qlIdSet,'SBQQ__Quote__c');                         
                    //Pricing_RestAPI_QuotesUtility.publishQuoteAndQuoteLines(quoteLineIdMap,validFSEEmailIdMapDetails,qlIdSet,'SBQQ__Quote__c');
                    //Pricing_Publish_Quote.globalVariables gVars = Pricing_Publish_Quote.PublishTenderQuote(String.valueOf(newQuote.Id));
                }
                else if(!isResubmit && (!String.isEmpty(quote.quoteDetails.primaryContactEmail) && currentUser.Email != quote.quoteDetails.primaryContactEmail)){
                    //Primary contact is not the currunet user
                    changePrimaryContact(newQuote.Id, quote.quoteDetails.primaryContactEmail, currentUser.AccountId);
                }
                
                //creating response
                Integer i = 0;
                List<CreatedQuoteLineDetails> quotelineDetailsList = new List<CreatedQuoteLineDetails>();
                if(quote.quoteDetails.quoteLines!=null){
                    Integer j = 0;
                    for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI qli : quote.quoteDetails.quoteLines){
                        List<CreatedPMDetails> pmDetailsList = new List<CreatedPMDetails>();
                        if(qli.performanceMetrics!=null){
                            for(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics pm : qli.performanceMetrics){
                                pmDetailsList.add(new CreatedPMDetails(perfMetricsList[j].Id, pm.performanceMetricsReferenceId));
                                j++;
                            }
                        }
                        if(pmDetailsList.size() == 0){
                            pmDetailsList = null;
                        }
                        quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, pmDetailsList));
                        i++;
                    }
                }
                if(quotelineDetailsList.size()==0){
                    quotelineDetailsList = null;
                }
                SBQQ__Quote__c quoteNew = new SBQQ__Quote__c();
                quoteNew = [Select id, Name, SBQQ__Status__c from SBQQ__Quote__c where id =:newQuote.Id];
                response.totalRecords = 1;
                response.successContent = new List<CreatedQuoteDetails>();
                response.successContent.add(new CreatedQuoteDetails(String.valueOf(newQuote.Id),quoteNew.Name, quoteNew.SBQQ__Status__c , quote.quoteDetails.referenceRequestID, quotelineDetailsList, commentDetails));
            }else {
                //Pricing_RestAPI_Util.quoteErrMsgs = quoteErrors;
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
    }*/
}