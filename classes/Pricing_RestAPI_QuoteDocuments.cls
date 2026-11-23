/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(urlMapping='/v1.0/quoterequest/quotedocumets')
global without sharing class Pricing_RestAPI_QuoteDocuments {
	private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_PickList.class.getName();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    public static String type;
    public static String recId;
    
    @HttpGet
    global static Pricing_RestAPI_Response doGet(){
        if(validateRequest()){
            //Valid Request
            getQuoteDocument();
        }else{
            //Not a Valid Request
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    
    //validating QuoteLineId and type
    private static boolean validateRequest(){
        boolean isValid=false;
        //RestRequest restReq = RestContext.request;
        //type = String.isEmpty(restReq.params.get('type')) ? null : restReq.params.get('type').toLowerCase();
        //recId = restReq.params.get('id');
        try{       
            isValid=true;
            /*if(!String.isEmpty(recId) && (String.isEmpty(type))){
                try{                    
                    isValid=true;
                }catch(Exception  exp){
                    isValid=false;
                }
            }
            else{
                isValid = false;
            }
            if(!isValid){
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
            }*/
            
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            user currentUser = [Select Id,ContactId, AccountId from User where Id = :UserInfo.getUserId()];
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,currentUser);            
        } 
        return isValid;
    }
    
    public static void getQuoteDocument(){
        SBQQ__QuoteDocument__c quoteDoc = [select id,CreatedDate,SBQQ__ViewRecordId__c from SBQQ__QuoteDocument__c  where SBQQ__Quote__c ='a9Y2D000000DD1rUAG' LIMIT 1];
		Document doc = [select id,ContentType, Body from Document where id='0152D000000W60UQAS' LIMIT 1]; //SBQQ__ViewRecordId__c as Id 
        //body: /services/data/v55.0/sobjects/Document/0152D000000W60UQAS/Body    
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET'); 
        request.setHeader('Content-type', 'application/json');
        request.setEndpoint('/services/data/v55.0/sobjects/Document/0152D000000W60UQAS/Body'); 
        HttpResponse response = http.send(request); 
    }
}