/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_Comments 
* Version     : 1.0 
* Created Date: 20 Nov 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         20/11/2020              Rest API to get comment details as response

Sample API call:- /services/apexrest/v1.0/quoterequest/comments?id=
id => Comment Id

Description=> Pass the Comment Id in the url and this will return comment details as response
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/quoterequest/comments')
global with sharing class Pricing_RestAPI_Comments {

    public static String recId;
    public static String commentId;
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_Comments.class.getName();
    
    @HttpGet
    global static Pricing_RestAPI_Response doGet(){
        try{
            if(validateRequest()){
                //Valid Request'
                getAllCommentDetails();
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
            //Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response);            
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
                commentId = Id.valueOf(recId);
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
        //fetching value of a specific comment from input comment id
        String cmtQuery = label.Pricing_RestAPI_GetCommentDetailsQuery;
        Pricing_Comments__c comment= Database.query(cmtQuery);
        response.successContent = new List<CreatedCommentsDetails>();
        response.successContent.add(new CreatedCommentsDetails(getCommentsDetails(comment)));
        response.totalRecords = 1;
    }
    
    //to forma comments wrapper
    public static Pricing_RestAPI_QuoteDetailsWrapper.QuoteCommentsWithQuoteId getCommentsDetails(Pricing_Comments__c cmt){
        Pricing_RestAPI_QuoteDetailsWrapper.QuoteCommentsWithQuoteId commentObj = new Pricing_RestAPI_QuoteDetailsWrapper.QuoteCommentsWithQuoteId();
        commentObj.commentId = cmt.Id;
        commentObj.question = cmt.Pricing_Question__c;
        commentObj.answer = cmt.Pricing_Answer__c;
        commentObj.quoteId = cmt.Pricing_Quote__c;
        commentObj.quoteNumber = cmt.Pricing_Quote__r.Name;
        commentObj.quoteCommentReferenceId = cmt.Pricing_Comment_Ref_Id__c;
        return commentObj;
    }
    
    public class CreatedCommentsDetails implements Pricing_RestAPI_SuccessContent {
        public Pricing_RestAPI_QuoteDetailsWrapper.QuoteCommentsWithQuoteId commentsDetail {set;get;}
        public CreatedCommentsDetails(Pricing_RestAPI_QuoteDetailsWrapper.QuoteCommentsWithQuoteId cmt){
            commentsDetail = cmt;
        }
    }
}