/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_ChangeRequestQLI 
* Version     : 1.0 
* Created Date: 19 Aug 2022
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         19/08/2022              Rest API to submit a QuoteLine for Change Request
Rest API to get quoteLine fields and its performance metrics as response
POST=>
Sample API call:- /services/apexrest/v1.0/quoterequest/quotelines?action=changerequest

Description=> Pass the quoteId and quoteLineDetails as an input JSON and it will submit the QuoteLine for Change Request
*****************************************************************************************************************************************/
global without sharing class Pricing_RestAPI_ChangeRequestQuoteLine extends TriggerHandler{
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_ChangeRequestQuoteLine.class.getName();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    public static user currentUser = [Select Id, ContactId,AccountId from User where Id = :UserInfo.getUserId()];
    public static String version = '';
    
    global static Pricing_RestAPI_Response doCRAPI(String reqBody,String ver){
        version = ver;
        processRequest(reqBody); 
        return response;
    }
    
    global static void processRequest(String reqBody){
        try{
            Pricing_RestAPI_QuotelinesV2.isChangeReq = true;
            Pricing_RestAPI_QuotesUtilityV2.QLICRWonLostWrapper quoteLine = (Pricing_RestAPI_QuotesUtilityV2.QLICRWonLostWrapper) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QLICRWonLostWrapper.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 utilObj = new Pricing_RestAPI_QuotesUtilityV2();
            boolean isValidQuoteLine = utilObj.validateQuoteLineCRWonLostWrapper(quoteLine, qErrorMsg, true);
            //validate the given quoteline and performance metrics
            if(isValidQuoteLine){
                Set<Id> qliIds = new Set<Id>();
                for(Pricing_RestAPI_QuotesUtilityV2.QLICRWonLost qli: quoteLine.quotelines){
                    qliIds.add(qli.quotelineId);
                }
                Map<Id,SBQQ__QuoteLine__c> qliMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, Pricing_Status_Nm__c,Pricing_Other_Product_Nm__c,SBQQ__ProductName__c,Pricing_Quote_Line_Number__c,
                                                                                    Pricing_FSE_Recommended_Price_Nm__c, Pricing_ECAP_Price_Amt__c, Pricing_Approved_Start_Date_Dt__c,SBQQ__Quote__r.SBQQ__Account__c,
                                                                                    Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,
                                                                                    Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Additional_Comments_Txt__c,
                                                                                    Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Additional_T_C_s_Txt__c,Pricing_Backdate_Reason_Txt__c,
                                                                                    Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c, SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,
                                                                                    Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,
                                                                                    Pricing_End_Date_dt__c,Pricing_Deal_Description__c,SBQQ__Quote__c,Pricing_Program_Type_Nm__c, Pricing_Consumption_Country__c, Pricing_Consumption_Platform__c, Pricing_Consumption_Sale_Geo__c, Pricing_Consumption_Segment__c, Pricing_Consumption_Region__c 
                                                                                    From SBQQ__QuoteLine__c WHERE Id In :qliIds and SBQQ__Quote__r.SBQQ__Account__c = :currentUser.AccountId]);
                for(Pricing_RestAPI_QuotesUtilityV2.QLICRWonLost qli: quoteLine.quotelines){
                    qliMap.get(qli.quotelineId).Pricing_Additional_Comments_Txt__c = qli.additionalComment;
                    qliMap.get(qli.quotelineId).Pricing_New_Quantity_qty__c = qli.newQuantity;
                    qliMap.get(qli.quotelineId).Pricing_End_Date_dt__c = String.isblank(String.valueOf(qli.quoteLinePricingEndDate)) ? null : date.parse(qli.quoteLinePricingEndDate);
                    qliMap.get(qli.quotelineId).Pricing_Start_Date_dt__c = String.isblank(String.valueOf(qli.quoteLinePricingStartDate)) ? qliMap.get(qli.quotelineId).Pricing_Approved_Start_Date_Dt__c :date.parse(qli.quoteLinePricingStartDate);
                    qliMap.get(qli.quotelineId).Pricing_Request_Discount_Unit_Price_qty__c = qliMap.get(qli.quotelineId).Pricing_Approved_End_Date_Dt__c < System.today() ? qliMap.get(qli.quotelineId).Pricing_ECAP_Price_Amt__c : qli.newRequestedPrice;
                    // consumption mapping
                    qliMap.get(qli.quotelineId).Pricing_Consumption_Platform__c = qli.consumptionPlatform != null || !String.isBlank(qli.consumptionPlatform) ? qli.consumptionPlatform.replaceAll(',',', ') : qli.consumptionPlatform;
                    qliMap.get(qli.quotelineId).Pricing_Consumption_Sale_Geo__c = qli.consumptionSalesGeo != null || !String.isBlank(qli.consumptionSalesGeo) ? qli.consumptionSalesGeo.replaceAll(',',', ') : qli.consumptionSalesGeo;
                    qliMap.get(qli.quotelineId).Pricing_Consumption_Country__c = qli.consumptionCountry != null || !String.isBlank(qli.consumptionCountry) ? qli.consumptionCountry.replaceAll(',',', ') : qli.consumptionCountry;
                    qliMap.get(qli.quotelineId).Pricing_Consumption_Region__c = qli.consumptionRegion != null || !String.isBlank(qli.consumptionRegion) ? qli.consumptionRegion.replaceAll(',',', ') : qli.consumptionRegion;
                    qliMap.get(qli.quotelineId).Pricing_Consumption_Segment__c = qli.consumptionSegment != null || !String.isBlank(qli.consumptionSegment) ? qli.consumptionSegment.replaceAll(',',', ') : qli.consumptionSegment;                    
                }
                createChangeRequest(quoteline,qliMap);
            }else{
                if(!Pricing_RestAPI_QuotelinesV2.isSvdQuoteLine || TriggerHandler.isActive('Pricing_SVD_QuoteLine_Disabled')){
                    system.debug('test:');
                //nullify quoteline errors if Quote Id is not valid as quote error message whould have the validation errors
                if(qErrorMsg.quoteLineErrorMsgs!=null && !qErrorMsg.quoteLineErrorMsgs.isEmpty()){
                    for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qe : qErrorMsg.quoteLineErrorMsgs){
                        if(qe.quoteLineErrors != null && qe.quoteLineErrors.isEmpty()){
                            qe.quoteLineErrors = null;
                        }
                    }
                }
                Pricing_RestAPI_Util.quoteErrMsgsV2 = qErrorMsg;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                }else{
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                    response.errorContent.errorMessage = Label.Pricing_Tender_API_Quotelines_SVD_Changerequest_Error_Msg; 
                }
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,currentUser);            
        }
    }
    
    public Static void createChangeRequest (Pricing_RestAPI_QuotesUtilityV2.QLICRWonLostWrapper quoteLineAPI,Map<Id,SBQQ__QuoteLine__c> quotelineMap) {
        
        Set<Id> sObjectId = new Set<Id>();
        Map<String, String> qliNumberReferIDMap = new Map<String, String>();
        Id currentUserAccountId = currentUser.AccountId;
        for(Pricing_RestAPI_QuotesUtilityV2.QLICRWonLost qli: quoteLineAPI.quotelines){
            sObjectId.add(qli.quotelineId);
            qliNumberReferIDMap.put(qli.quotelineId, qli.quotelineReferenceID);
        }
        //Pricing_Publish_Quote.quoteQTMMemberIdMap;
        List<SBQQ__QuoteLine__c> parentSObjectsRecord;
        List<SBQQ__QuoteLine__c> qliCRLst = new List<SBQQ__QuoteLine__c>();
        String query;
        try {
            // Quote query
            query = String.format(
                'SELECT {0} FROM {1} WHERE Id In : sObjectId and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId',
                new String[] {
                    String.join(
                        new List<String>(
                            SBQQ__QuoteLine__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet()
                        ),
                        ','
                    ),
                        String.valueOf(SBQQ__QuoteLine__c.SObjectType)
                }
            );
            // Query and gets results
            parentSObjectsRecord = Database.query(query);
            
            for(SBQQ__QuoteLine__c parentSObjects: parentSObjectsRecord ){
                SBQQ__QuoteLine__c parent;
                parent = parentSObjects.clone(false, true, false, false);
                // fiRPMCR = false for now we are passing
                parent = Pricing_QuoteLineCloneController.quotelineFieldPopulation(parentSObjects,parent,quoteLineMap.get(parentSObjects.Id),Label.Pricing_Tender_QuoteLine_Action_Request_Change,true,false);
                qliCRLst.add(parent);
            }

            if(!qliCRLst.isEmpty()){
                Database.insert(qliCRLst);
            }
            
            Map<Id,Id> qliIdToCRIdMap = new Map<Id,Id>();
            Set<Id> qliCRIds = new Set<Id>();
            for(SBQQ__QuoteLine__c qli:qliCRLst){
                qliIdToCRIdMap.put(qli.Pricing_Reference_Quote_Line_Nbr__c,qli.id);
                qliCRIds.add(qli.id);
            }
            Pricing_RestAPI_QuotesUtilityV2.createApprovalProcess(qliCRIds,null,null,null,null);
            sendEmailNotification(qliCRIds,'Pricing_AE_QuoteLineCRNotification');    
            // Quote Line query  
            query = String.format(
                'SELECT {0} FROM {1} WHERE Pricing_Quote_Line__c In :sObjectId and Pricing_Quote_Line__r.SBQQ__Quote__r.SBQQ__Account__c=: currentUserAccountId',
                new String[] {
                    String.join(
                        new List<String>(
                            Pricing_Performance_Metric__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet()
                        ),
                        ','
                    ),
                        String.valueOf(Pricing_Performance_Metric__c.SObjectType)
                        
                        }
            );        
            
            List<Pricing_Performance_Metric__c> children = new List<Pricing_Performance_Metric__c>();
            // Query and clone the children. Here you can change anything without affecting the original sObject            
            for(Pricing_Performance_Metric__c child:(List<Pricing_Performance_Metric__c>)Database.query(query)){
                Pricing_Performance_Metric__c newPM = child.clone(false,true); // deep clone
                newPM.Pricing_Quote_Line__c = qliIdToCRIdMap.get(child.Pricing_Quote_Line__c); //set parent ref
                children.add(newPM);
            }
            
            if(!children.isEmpty()){
                Database.insert(children);
            }    
            
            response.totalRecords = qliCRLst.size();
            response.successContent = new List<CreatedCRQLIDetails>();
            for(SBQQ__QuoteLine__c qli: qliCRLst){
                response.successContent.add(new CreatedCRQLIDetails(quotelineMap.get(qli.Pricing_Reference_Quote_Line_Nbr__c).id,quotelineMap.get(qli.Pricing_Reference_Quote_Line_Nbr__c).Pricing_Quote_Line_Number__c,qli.id,qli.Pricing_Quote_Line_Number__c));
            }
            
        }  catch(Exception error) {
            String msg = error.getMessage();
            if(msg.contains('DUPLICATE_VALUE')){
                String recId = msg.substringBetween('id: ', ': []');
                String qliNumber = '';
                Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
                qErrorMsg.quoteLineErrorMsgs = new List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg>();
                Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qle = new Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg();
                qle.quoteLineErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
                List<SBQQ__QuoteLine__c> quoteLine = [SELECT Id, Pricing_Quote_Line_Number__c,Pricing_Reference_Quote_Line_Nbr__c FROM SBQQ__QuoteLine__c WHERE Id =: recId];
                if(!quoteLine.isEmpty()){
                    for(SBQQ__QuoteLine__c qli:qliCRLst){
                        if(qli.Pricing_Quote_Line_Number__c == quoteLine[0].Pricing_Quote_Line_Number__c) {
                            qliNumber = qli.Pricing_Quote_Line_Number__c;
                            break;
                        }
                    }
                    qle.quotelineReferenceID = qliNumberReferIDMap.get(quoteLine[0].Pricing_Reference_Quote_Line_Nbr__c);
                }

                Pricing_RestAPI_QuotesUtilityV2.addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1063,new Map<String,String>{'value'=> qliNumber});
                qErrorMsg.quoteLineErrorMsgs.add(qle);
                Pricing_RestAPI_Util.quoteErrMsgsV2 = qErrorMsg;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                Pricing_Tender_Utility.logError(error);
                //Pricing_RestAPI_Util.processException(error, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
            }
            else{
                Pricing_Tender_Utility.logError(error);
            }
            
        }
    }

    public static void sendEmailNotification(Set<Id> RecList,string EmailTemplate){
        if(!RecList.isEmpty()){
            Pricing_EmailUtility.sendEmailToReciepents(RecList, EmailTemplate);  //Calling Method from Pricing_EmailUtility.cls class
        }    
    }
    
    public class CreatedCRQLIDetails implements Pricing_RestAPI_SuccessContent {
        public String parentQuoteLineId {set;get;}
        public String parentQuoteLineNumber {set;get;}
        public String changeRequestQuoteLineId {set;get;}
        public String changeRequestQuoteLineNumber {set;get;}
        public CreatedCRQLIDetails( String pId, String pQLINo, String crId, String crQLINo){
            parentQuoteLineId = pId;
            parentQuoteLineNumber = pQLINo;
            changeRequestQuoteLineId = crId;
            changeRequestQuoteLineNumber = crQLINo;
        }
    }
}