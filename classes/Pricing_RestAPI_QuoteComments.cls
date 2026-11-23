/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_QuoteComments 
* Version     : 1.0 
* Created Date: 29 October 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         10/29/2020              Rest API to create Comments with no sections

Sample API call:- /services/apexrest/v1.0/quoterequest/quotecomments

Description=> Pass the quoteId and quoteComments as an input JSON and it will create the Quote Comments
*****************************************************************************************************************************************/
@RestResource(urlMapping='/*/quoterequest/quotecomments')
global without sharing class Pricing_RestAPI_QuoteComments {            //change class name to QuoteComments
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_QuoteComments.class.getName();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    public static String quoteId1;
    
    public static String recId;
    public static String quoteId;
    
    @HttpPost
    //global static QuoteComment doPost(){
    global static Pricing_RestAPI_Response doPost(){
        try{
            RestRequest req = RestContext.request;
            String reqBody = req.requestBody.toString();
            Pricing_RestAPI_QuotesUtilityV2.QuoteCommentWrapperDetails quotecommentWrapper = (Pricing_RestAPI_QuotesUtilityV2.QuoteCommentWrapperDetails) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuoteCommentWrapperDetails.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 utilObj = new Pricing_RestAPI_QuotesUtilityV2();
            boolean isValidComment= utilObj.validateQuoteCommentsWrapper(quotecommentWrapper , qErrorMsg);
            
            //validate quote comments
            if(isValidComment){
                List<Pricing_Comments__c> qComms = Pricing_RestAPI_QuotesUtilityV2.createQuoteComments(quotecommentWrapper.quoteId, quotecommentWrapper.quoteComments);
                if(qComms.size() > 0) {
                    upsert qComms;      //create validated quote comments
                    response.successContent = new List<CreatedQuoteCommentDetails>();
                    Integer i = 0;
                    for(Pricing_Comments__c qComm : qComms){
                        response.successContent.add(new CreatedQuoteCommentDetails(qComm.Id, quotecommentWrapper.quoteComments[i].quoteCommentReferenceId));
                        i++; 
                    }                    
                    response.totalRecords = qComms.size();
                }
            }else{                
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
  
    /*global class QuoteComment {
        public Pricing_RestAPI_QuotesUtility.QuoteComment quotecomment {set; get;}
        public String quoteId {set;get;}
    }*/
    
    
    public class CreatedQuoteCommentDetails implements Pricing_RestAPI_SuccessContent {
        public String quoteCommentId {set;get;}
        public String quoteCommentReferenceId {set;get;}
        public CreatedQuoteCommentDetails( String recId, String refId){
            quoteCommentId = recId;
            quoteCommentReferenceId = refId;
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
    @httpPatch
    global static Pricing_RestAPI_Response updateComments(){
        try{
            RestRequest req = RestContext.request;
            String reqBody = req.requestBody.toString();
            Pricing_RestAPI_QuotesUtilityV2.QuoteCommentWrapperDetails quotecomment = (Pricing_RestAPI_QuotesUtilityV2.QuoteCommentWrapperDetails) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuoteCommentWrapperDetails.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 utilObj = new Pricing_RestAPI_QuotesUtilityV2();
            boolean isValidComment= utilObj.validateQuoteCommentsWrapper(quotecomment , qErrorMsg);
            if(isValidComment){
                //valid quote comments
                upsertQuoteComments(quotecomment);    
            }else{
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
    
    
    public static void upsertQuoteComments(Pricing_RestAPI_QuotesUtilityV2.QuoteCommentWrapperDetails qcWrapper){
        List<Pricing_Comments__c> commList=Pricing_RestAPI_QuotesUtilityV2.createQuoteComments(qcWrapper.quoteId, qcWrapper.quoteComments);
        if(commList.size() > 0) {
            update commList;    //update quote comments if quoestion provided in JSON
            response.successContent = new List<Pricing_RestAPI_SuccessContent>();
            Integer i = 1;
            for(Pricing_Comments__c qc: commList){
                response.successContent.add(new UpdatedQuoteCommentDetails(qc.Id, qcWrapper.quoteComments[i-1].quoteCommentReferenceId));
                i++;
            }
            response.totalRecords = commList.size();      
        }
    }
     
    
    public class UpdatedQuoteCommentDetails implements Pricing_RestAPI_SuccessContent {
        public String quoteCommentId {set;get;}
        public String quoteCommentReferenceId {set;get;}
        public UpdatedQuoteCommentDetails( String recId, String refId){
            quoteCommentId = recId;
            quoteCommentReferenceId = refId;
        }
    } 
    
    //-----------------------------------------------------------------------------------------------------------------------------
     @HttpGet
    global static Pricing_RestAPI_Response doGet(){
    user currentUser = [Select Id, AccountId from User where Id = :UserInfo.getUserId()];
        try{
            RestRequest restReq = RestContext.request;
            if(restReq.params.containsKey('id')){   
                if(validateRequest(currentUser)){
                    getAllCommentDetails();
                }
                else{
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                }
            }else{
                getCommentCodes();
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,currentUser);
        }
        return response;
    }
    
    //to check weather request is valid or not
    private static boolean validateRequest(user currentUser){
        boolean isValid=false;
        RestRequest restReq = RestContext.request;
        recId = restReq.params.get('id');
        if(!String.isBlank(recId)){
            try{
                quoteId = Id.valueOf(recId);
                SBQQ__Quote__c quote = [Select Id, SBQQ__Account__c from SBQQ__Quote__c where Id = :quoteId and SBQQ__Account__c = :currentUser.AccountId];
                isValid = true;                
            }catch(Exception exp){
                Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME); 
        }          
       return isValid;
    }
    
    //to get all comments details
    public static void getAllCommentDetails(){        
        String cmtQuery = label.Pricing_RestAPI_GetCmtsDetailFromQuoteQuery;
        List<Pricing_Comments__c> cmtList= Database.query(cmtQuery);
        if(cmtList.size() > 0){
            getCommentsDetailsWrapper(cmtList);
            response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200;
            response.totalRecords = cmtList.size();
        }else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }        
    }
    
    //to forma comments wrapper
    public static void getCommentsDetailsWrapper(List<Pricing_Comments__c> cmt){
        response.successContent = new List<CreatedCommentsDetails>();
        List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteCommentsWithId> commentDetailsList = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteCommentsWithId>();
        for(Pricing_Comments__c comment: cmt){
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteCommentsWithId commentObj = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteCommentsWithId();
            commentObj.commentId = comment.Id;
            commentObj.question = comment.Pricing_Question__c;
            commentObj.answer = comment.Pricing_Answer__c;
            commentObj.quoteCommentReferenceId = comment.Pricing_Comment_Ref_Id__c;
            commentDetailsList.add(commentObj);
        }
        response.successContent.add(new CreatedCommentsDetails(commentDetailsList));
    }
    
    public static void getCommentCodes(){
        String query = Label.Pricing_RestAPI_CommentCodes_Query;   
        List<Core_CPQ_Tender_Comments__mdt> commentList = database.query(query);
        if(commentList.size()>0){
            response.totalRecords = commentList.size();
            response.successContent = new List<Pricing_RestAPI_SuccessContent>();
            for(Core_CPQ_Tender_Comments__mdt cmt: commentList){
                response.successContent.add(new Pricing_RestAPI_QuoteDetailsWrapperV2.CommentDetails(cmt.Pricing_Comment_Ref_Id__c, cmt.Pricing_Question__c));
            }
        }
    }
    
    public class CreatedCommentsDetails implements Pricing_RestAPI_SuccessContent {
        public List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteCommentsWithId> quoteCommentDetails {set;get;}
        public CreatedCommentsDetails(List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteCommentsWithId> cmt){
            quoteCommentDetails = cmt;
        }
    }
    
}