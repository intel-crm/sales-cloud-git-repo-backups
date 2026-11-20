/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_ClaimsData
* Version     : 1.0 
* Created Date: 28 May 2021
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture              28/05/2021                 Rest API to create Inbound integration record for MyDeals integration
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/quoterequest/claims')
global without sharing class Pricing_RestAPI_ClaimsData extends TriggerHandler{
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_ClaimsData.class.getName();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    
    /**
    * @description method which receives the request payload
    * @author Accenture | 04-06-2022 
    * @return Pricing_RestAPI_Response 
    **/
    @HttpPost
    global static Pricing_RestAPI_Response doPost(){
        try{
            //Enable/Disable Underlying Integration for Claims data
            if(TriggerHandler.isActive('Pricing_Claims_Data_Switch')){
                RestRequest req = RestContext.request;
                processRequest(req.requestBody.toString());
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }  
        return response;
    }
    
    /**
    * @description deserialises the json and create a record in the Intgeration Inbound Object.
    * @author Accenture | 04-06-2022 
    * @param reqBody 
    **/
    public static void processRequest(String reqBody){
        try{
            Pricing_ClaimsDataWrapper jsonMap = (Pricing_ClaimsDataWrapper) System.JSON.deserialize(reqBody, Pricing_ClaimsDataWrapper.class);
            List<Core_Integration_Inbound_Message__c> iimList = new List<Core_Integration_Inbound_Message__c>();
            Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
            String tag='';
            for(Pricing_ClaimsDataWrapper.ClaimsData claims:jsonMap.claims){
                tag = claims.quoteLineNumber != null ? claims.quoteLineNumber:'';
                break;
                    }
            iim.Core_Payload__c = JSON.serialize(jsonMap);
            iim.Core_Message_Type__c = jsonMap.Header.action;
            iim.Core_Processing_Status__c = 'Successful';
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
            user currentUser = [SELECT id,Name,AccountId,ContactId,Email FROM User WHERE id= :UserInfo.getUserId()];
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