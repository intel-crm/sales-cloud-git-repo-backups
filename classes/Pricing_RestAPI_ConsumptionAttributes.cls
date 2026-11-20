/**
 * @description       : Rest API to create Integration Inbound record for Consumption Attributes MyDeals Integration.
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 11-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@RestResource(urlMapping='/v1.0/quoterequest/consumptionattributes')
global without sharing class Pricing_RestAPI_ConsumptionAttributes {

    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_ConsumptionAttributes.class.getName();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    
    /**
    * @description method to receive request payload
    * @author Sandeep Chamate | 10-18-2023 
    * @return Pricing_RestAPI_Response 
    **/
    @HttpPost
    global static Pricing_RestAPI_Response doPost(){
        try{
            RestRequest req = RestContext.request;
            processRequest(req.requestBody.toString());         
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
            reqBody = reqBody.replaceAll(Label.Pricing_Consumption_Cust_Platform, Label.Pricing_IQR_ConsumptionPlatform);
            reqBody = reqBody.replaceAll(Label.Pricing_Consumption_Cust_Rpt_Geo, Label.Pricing_IQR_ConsumptionSalesGeo);
            reqBody = reqBody.replaceAll(Label.Pricing_Consumption_Cust_Segment, Label.Pricing_IQR_ConsumptionSegment);
            Pricing_ConsumptionAttributesWrapper jsonMap = (Pricing_ConsumptionAttributesWrapper) System.JSON.deserialize(reqBody, Pricing_ConsumptionAttributesWrapper.class);
            List<Core_Integration_Inbound_Message__c> iimList = new List<Core_Integration_Inbound_Message__c>();
            Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();

            iim.Core_Payload__c = JSON.serialize(jsonMap);
            iim.Core_Message_Type__c = jsonMap.Header.action;
            iim.Core_Processing_Status__c = 'Successful';
            iim.Core_Error_Code__c = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200;
            iim.Core_Source_System__c = jsonMap.Header.source_system;
            iimList.add(iim);
            Database.SaveResult[] res= Database.insert(iimList, true);
            
            response.successContent = new List<CreatedSucessContent>(); 
            if(res[0].isSuccess()){
                Core_Integration_Inbound_Message__c data = [SELECT ID,Name FROM Core_Integration_Inbound_Message__c WHERE ID=:res[0].Id ];
                response.successContent.add(new CreatedSucessContent(data.Name));
                response.totalRecords = res.size();
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
            user currentUser = [Select Id, ContactId,AccountId from User where Id = :UserInfo.getUserId()];
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