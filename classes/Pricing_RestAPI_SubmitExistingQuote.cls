/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_SubmitExistingQuote 
* Version     : 1.0 
* Created Date: 04 Dec 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         12/04/2020              Rest API to submit a draft quote

Sample API call:- /services/apexrest/v1.0/quoterequest/submitexistingquote?id={quote-record-id}
Description=> Submits an existing Draft quote by passing the quote id as an input
*****************************************************************************************************************************************/

@RestResource(urlMapping='/v1.0/quoterequest/submitexistingquote')
global without sharing class Pricing_RestAPI_SubmitExistingQuote {
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_PickList.class.getName();
     public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    public static Id quoteId {set;get;}
	@HttpPost
    global static Pricing_RestAPI_Response doPost(){
        RestRequest req = RestContext.request;
        Pricing_RestAPI_QuotesUtility.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
        quoteErrors.quoteErrors = new Map<String,Pricing_RestAPI_QuotesUtility.ErrorMsg>();
        String recId = Pricing_RestAPI_Util.getRequestParam('id');
        Pricing_RestAPI_QuotesUtility utilityObj = new Pricing_RestAPI_QuotesUtility();
        
        if(validateQuoteIdForSubmission(recId, quoteId, quoteErrors)){
           //system.debug('recId ==>'+recId);
           //Submi quote and get the response
           Pricing_Publish_Quote.globalVariables gVars = Pricing_Publish_Quote.PublishTenderQuote(recId); 
           GlobalVariables gvs = new GlobalVariables();
           gvs.messageNotification = gVars.messageNotification;
           if(gVars.isSuccess){
               response.totalRecords = 1;
               response.successContent = new List<GlobalVariables>();
               response.successContent.add(gvs); 
           }else{ 
              String errors = '';
               //system.debug('Errors==>'+gvs.messageNotification);
               for(String err : gvs.messageNotification){
                 //system.debug('Error==>'+err);
                 errors = String.isEmpty(errors) ? err : errors+', '+err; 
               }              
              quoteErrors.quoteErrors.put('quote', new Pricing_RestAPI_QuotesUtility.ErrorMsg(null, errors));
              Pricing_RestAPI_Util.quoteErrMsgs = quoteErrors;
              Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
           }
        }else{
            Pricing_RestAPI_Util.quoteErrMsgs = quoteErrors;
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }    
    public static boolean validateQuoteIdForSubmission(String recId, Id quoteId, Pricing_RestAPI_QuotesUtility.QuoteErrorMsg quoteErrors ){
         boolean isRecIdValid = false;  
        //addValidationError(quoteErrors.quoteErrors, 'quoteComments', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1030, null);
        try{
            if(!String.isEmpty(recId)){
               	quoteId = Id.valueOf(recId);
                List<SBQQ__Quote__c> quotes = [SELECT id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id=:quoteId];
                if(quotes.size() > 0){
                    if(quotes[0].SBQQ__Status__c=='Draft'){
                        isRecIdValid = true; 
                    }else{
                        system.debug('Quote is already submitted');
                        Pricing_RestAPI_QuotesUtility.addValidationError(quoteErrors.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1043, null);
                    }                   
                }else{
                    system.debug('Quote not found');
                  	Pricing_RestAPI_QuotesUtility.addValidationError(quoteErrors.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);  
                }
            }            
        }catch(Exception exp){
          //do nothing  
        }
        return isRecIdValid; 
    }
    public class GlobalVariables implements Pricing_RestAPI_SuccessContent {
        Set<String> messageNotification {set;get;}
    }
}