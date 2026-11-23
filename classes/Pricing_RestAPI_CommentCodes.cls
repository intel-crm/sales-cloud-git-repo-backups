/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_CommentCodes 
* Version     : 1.0 
* Created Date: 17 DEC 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         17/12/2020              Rest API to get all comment codes

Sample API call:- /services/apexrest/v1.0/quoterequest/questioncodemapping
*****************************************************************************************************************************************/

@RestResource(urlMapping='/v1.0/quoterequest/questioncodemapping')
global without sharing class Pricing_RestAPI_CommentCodes {
    
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_PickList.class.getName();
    
    @HttpGet
    global static Pricing_RestAPI_Response doGet(){
        try{ 
            String query = Label.Pricing_RestAPI_CommentCodes_Query;   
            List<Core_CPQ_Tender_Comments__mdt> commentList = database.query(query);
            if(commentList.size()>0){
                response.totalRecords = commentList.size();
                response.successContent = new List<Pricing_RestAPI_SuccessContent>();
                for(Core_CPQ_Tender_Comments__mdt cmt: commentList){
                    response.successContent.add(new CommentDetails(cmt.Pricing_Comment_Ref_Id__c, cmt.Pricing_Question__c));
                }
            }else{  
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.NO_DATA_EXCEPTION_9001, response, RESTAPI_NAME, ENTRY_TIME);
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
    
    public class CommentDetails implements Pricing_RestAPI_SuccessContent {
        public String quoteCommentReferenceId {set;get;}
        public String question {set;get;}
        public CommentDetails(String recId, String ques){
            quoteCommentReferenceId = recId; 
            question = ques;
        }
    }
    
}