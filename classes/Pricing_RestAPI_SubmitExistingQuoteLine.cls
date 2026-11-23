@RestResource(urlMapping='/v1.0/quoterequest/submitexistingquoteline')
global without sharing class Pricing_RestAPI_SubmitExistingQuoteLine {
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_PickList.class.getName();
     public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    public static Id quoteLineId {set;get;}
	@HttpPost
    global static Pricing_RestAPI_Response doPost(){
        RestRequest req = RestContext.request;
        Pricing_RestAPI_QuotesUtility.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtility.QuoteErrorMsg();
        //quoteErrors.quoteErrors = new Map<String,Pricing_RestAPI_QuotesUtility.ErrorMsg>();
        quoteErrors.quoteLineErrorMsgs = new List<Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg>();
        Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg qlErrorMsg = new Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg();  
        qlErrorMsg.quoteLineErrors = new Map<String,Pricing_RestAPI_QuotesUtility.ErrorMsg>();
        String recId = Pricing_RestAPI_Util.getRequestParam('id');
        Pricing_RestAPI_QuotesUtility utilityObj = new Pricing_RestAPI_QuotesUtility();
        
        if(validateQuoteLineIdForSubmission(recId, quoteLineId, qlErrorMsg)){
           system.debug('recId ==>'+recId);
           Pricing_Publish_Quote.globalVariables gVars = Pricing_Publish_Quote.PublishTenderQuote(recId); 
           GlobalVariables gvs = new GlobalVariables();
           gvs.messageNotification = gVars.messageNotification;
           if(gVars.isSuccess){
               response.totalRecords = 1;
               response.successContent = new List<GlobalVariables>();
               response.successContent.add(gvs); 
           }else{ 
              String errors = '';
               system.debug('Errors==>'+gvs.messageNotification);
               for(String err : gvs.messageNotification){
                 system.debug('Error==>'+err);
                 errors = String.isEmpty(errors) ? err : errors+', '+err; 
               }              
              qlErrorMsg.quoteLineErrors.put('quote', new Pricing_RestAPI_QuotesUtility.ErrorMsg(null, errors));
              quoteErrors.quoteLineErrorMsgs.add(qlErrorMsg);
              Pricing_RestAPI_Util.quoteErrMsgs = quoteErrors;
              Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
           }
        }else{
            quoteErrors.quoteLineErrorMsgs.add(qlErrorMsg);
            Pricing_RestAPI_Util.quoteErrMsgs = quoteErrors;
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }    
    public static boolean validateQuoteLineIdForSubmission(String recId, Id quoteLineId, Pricing_RestAPI_QuotesUtility.QuoteLineErrorMsg quoteLineErrorMsgs ){
         boolean isRecIdValid = false;  
        //addValidationError(quoteErrors.quoteErrors, 'quoteComments', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1030, null);
        try{
            if(!String.isEmpty(recId)){
                quoteLineId = Id.valueOf(recId);
                List<SBQQ__QuoteLine__c> quoteLineItems = [SELECT id,Pricing_Status_Nm__c,SBQQ__Quote__r.SBQQ__Status__c FROM SBQQ__QuoteLine__c WHERE Id=:quoteLineId];
                system.debug('quoteLineItems===>'+quoteLineItems);
                if(quoteLineItems.size() > 0){
                    if(quoteLineItems[0].SBQQ__Quote__r.SBQQ__Status__c != 'Draft'){
                        if(quoteLineItems[0].Pricing_Status_Nm__c=='Draft'){
                            isRecIdValid = true; 
                        }else{
                            //system.debug('Quoteline is already submitted');
                            Pricing_RestAPI_QuotesUtility.addValidationError(quoteLineErrorMsgs.quoteLineErrors, 'quoteLine', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1045, null);
                        }                     
                    }else{
                       //system.debug('Quote is not submitted');
                       Pricing_RestAPI_QuotesUtility.addValidationError(quoteLineErrorMsgs.quoteLineErrors, 'quoteLine', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1032, null); 
                    }                    
                }else{
                    system.debug('Quote Line not found');
                    Pricing_RestAPI_QuotesUtility.addValidationError(quoteLineErrorMsgs.quoteLineErrors, 'quoteLine', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null);  
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