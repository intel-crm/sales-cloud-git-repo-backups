/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_MyDeals 
* Version     : 1.0 
* Created Date: 28 May 2021
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Biswa         28/05/2021                 Rest API to create Inbound integration record for MyDeals integration
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/quoterequest/mydeals2iqr')
global without sharing class Pricing_RestAPI_MyDeals{
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_MyDeals.class.getName();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    
    @HttpPost
    global static Pricing_RestAPI_Response doPostapi(){
        try{
            RestRequest req = RestContext.request;
            String requestBodyStr = req.requestBody.toString();
            if(validateRequestHeader(requestBodyStr)){
                processRequest(requestBodyStr); 
            }else{
                //action is invalid
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }            
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }  
        return response;
    }
    
    public static boolean validateRequestHeader(String reqBody){
        Pricing_JSONString jsonMap = (Pricing_JSONString) System.JSON.deserialize(reqBody, Pricing_JSONString.class);
        String target_sys = jsonMap.Header.target_system;
        String source_sys = jsonMap.Header.source_system;
        if(target_sys == 'Tender' && source_sys == 'MyDeals'){  
            return true;  
        }else{
            //invalid action parameter
            return false;
        }
    }
    
    public static void processRequest(String reqBody){
        try{
            Pricing_JSONString jsonMap = (Pricing_JSONString) System.JSON.deserialize(reqBody, Pricing_JSONString.class);
            List<Core_Integration_Inbound_Message__c> iimList = new List<Core_Integration_Inbound_Message__c>();
            Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
            String tag = jsonMap.RecordDetails.Quote.Id != null ? jsonMap.RecordDetails.Quote.Id + ' - ' : '';
            if(jsonMap.RecordDetails.Quote.QuoteLine != null && jsonMap.RecordDetails.Quote.QuoteLine.Size() > 0){
                tag += jsonMap.RecordDetails.Quote.QuoteLine[0].Id;
            }
            iim.Core_Payload__c = JSON.serialize(jsonMap);
            iim.Core_Message_Type__c = jsonMap.Header.target_system;
            iim.Core_Processing_Status__c = 'Pending';
            iim.Core_Error_Code__c = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200;
            iim.Core_Source_System__c = jsonMap.Header.source_system;
            iim.Core_Tags__c = tag;
            iimList.add(iim);
            Database.SaveResult[] res= Database.insert(iimList, true);
            
            response.successContent = new List<CreatedSucessContent>(); 
            if(res[0].isSuccess()){
                Core_Integration_Inbound_Message__c data = [SELECT ID,Name FROM Core_Integration_Inbound_Message__c WHERE ID=:res[0].Id ];
                response.successContent.add(new CreatedSucessContent(data.Name));
                response.totalRecords = res.Size();
            }
            else{
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.NO_DATA_EXCEPTION_9001, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            user currentUser = [Select Id, AccountId from User where Id = :UserInfo.getUserId()];
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response, currentUser);        
        }  
    }
    
    public class CreatedSucessContent implements Pricing_RestAPI_SuccessContent {
        public String name {set;get;}
        
        public CreatedSucessContent(String iimName){
            name = iimName;
        }
    }
    
}