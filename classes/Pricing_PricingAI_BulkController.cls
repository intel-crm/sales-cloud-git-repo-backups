/**
 * @description       : Class to run Bulk Pricing AI from Bulk Create Deal Popup
 * @author            : Sandeep
 * @group             : Accenture
 * @last modified on  : 03-27-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_PricingAI_BulkController {

    /**
    * @description method to call the pricing AI Integrtion
    * @author Sandeep | 11-11-2022 
    * @param List<String> containing QuoteLine Ids 
    * @return List<String> containing error or pricing AI fields with quoteline number
    **/
    @AuraEnabled
    public static  List<String> makeCallout(List<String> quoteLineId){     
        String qlRecJSONString;
        String invalidInpJSONString;
        String excepRespJSONString;
        List<String> pricingAIRespJSONString = new List<String>();
        List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
        try{
            List<SBQQ__QuoteLine__c>  quoteLineList = [SELECT Id, Name,Pricing_Quote_Line_Number__c, Pricing_Recommended_Price_Amt__c 
                                        FROM SBQQ__QuoteLine__c WHERE Id IN: quoteLineId];
            Map<String,String> successMsgMap = new Map<String,String>();
            Map<String,String> errorMsgMap = new Map<String,String>();
            Map<String,String> invalidJSONMap = new Map<String,String>();
            Map<String,SBQQ__QuoteLine__c> qlNameToQLRecMap = new Map<String,SBQQ__QuoteLine__c>();
            Map<String,Id> qlNameToQLIdMap = new Map<String,Id>();
            Map<String,Id> errorQLNameToQLIdMap = new Map<String,Id>();
            Map<String,Id> errorJSONQLNameToQLIdMap = new Map<String,Id>();
            String discountPrice;
            String inputJSON = getQuoteLineDetails(quoteLineId);
            if(inputJSON!=null){
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Pricing_APIGEE_AI');
                req.setHeader('content-type', 'application/json');
                req.setMethod('POST');
                req.setBody(inputJSON);
                HttpResponse response = new Http().send(req);
                if(response.getStatusCode() == 200){
                Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                List<Object> successContentList = (List<Object>)results.get('successContent');
                List<Object> errorContestList = (List<Object>)results.get('errorContent');
                for(SBQQ__QuoteLine__c qli: quoteLineList){
                    qlNameToQLRecMap.put(qli.Pricing_Quote_Line_Number__c,qli);
                }
                if(successContentList.size()>0){
                    for(Object resultMap:successContentList){
                        Map<String,Object> tempMap = (Map<String,Object>)resultMap;
                        Pricing_PricingAI_BulkController.QuoteLineWrapper qlWrap = new Pricing_PricingAI_BulkController.QuoteLineWrapper();
                        qlWrap.recommendedPrice = ((Decimal)tempMap.get('recommendedPrice'))!=null?(Decimal)tempMap.get('recommendedPrice'):0;
                        qlWrap.priceInterval = (String.valueOf(tempMap.get('priceInterval')))!=null?String.valueOf(tempMap.get('priceInterval')):'';
                        discountPrice = ((String)tempMap.get('discount')).replaceAll('%', '');
                        qlWrap.discount = (Decimal.valueOf(discountPrice));
                        qlWrap.quoteLineNumber = (String.valueOf(tempMap.get('quoteLineNumber')))!=null?String.valueOf(tempMap.get('quoteLineNumber')):'';
                        qlWrap.warningMessage = (String.valueOf(tempMap.get('warningMessage'))) != null ? String.valueOf(tempMap.get('warningMessage')) : '';
                        qlRecJSONString = JSON.serialize(qlWrap);
                        pricingAIRespJSONString.add(qlRecJSONString);
                        successMsgMap.put(qlNameToQLRecMap.get(qlWrap.quoteLineNumber).Name,inputJSON);
                        qlNameToQLIdMap.put(qlNameToQLRecMap.get(qlWrap.quoteLineNumber).Name,qlNameToQLRecMap.get(qlWrap.quoteLineNumber).Id);
                    }
                    logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectPricingAIIntegration(successMsgMap, qlNameToQLIdMap, 'Low'));
                }
                if(errorContestList.size()>0){
                    for(Object resultMap:errorContestList){
                        Map<String,Object> tempMap = (Map<String,Object>)resultMap;
                        Pricing_PricingAI_BulkController.QuoteLineWrapper qlWrap = new Pricing_PricingAI_BulkController.QuoteLineWrapper();
                        qlWrap.message = (String.valueOf(tempMap.get('message')))!=null?String.valueOf(tempMap.get('message')):'';
                        qlWrap.quoteLineNumber = (String.valueOf(tempMap.get('quoteLineNumber')))!=null?String.valueOf(tempMap.get('quoteLineNumber')):'';
                        qlRecJSONString = JSON.serialize(qlWrap);
                        pricingAIRespJSONString.add(qlRecJSONString);
                        errorMsgMap.put(qlNameToQLRecMap.get(qlWrap.quoteLineNumber).Name,qlWrap.message);
                        errorQLNameToQLIdMap.put(qlNameToQLRecMap.get(qlWrap.quoteLineNumber).Name,qlNameToQLRecMap.get(qlWrap.quoteLineNumber).Id);
                    }
                    logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectPricingAIIntegration(errorMsgMap, errorQLNameToQLIdMap, 'Critical'));
                }
                if(logEntryList.size() > 0){
                    insert logEntryList;    
                }
                }
            }else{
                String msg = 'Quote Line Records are processed with an error, as the inputJSON is invalid. Please check the request.';
                for(SBQQ__QuoteLine__c qli: quoteLineList){
                    invalidJSONMap.put(qli.Name,msg);
                    errorJSONQLNameToQLIdMap.put(qli.Name,qli.Id);
                }
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectPricingAIIntegration(invalidJSONMap, errorJSONQLNameToQLIdMap, 'Critical'));
                if(logEntryList.size() > 0){
                    insert logEntryList;    
                }
                Pricing_PricingAI_BulkController.QuoteLineWrapper errInpJSONWrap = new Pricing_PricingAI_BulkController.QuoteLineWrapper();
                errInpJSONWrap.message = msg;
                errInpJSONWrap.quoteLineNumber = '';
                invalidInpJSONString = JSON.serialize(errInpJSONWrap);
                pricingAIRespJSONString.add(invalidInpJSONString);
                return pricingAIRespJSONString;
            }
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
            String expMsg = Label.Pricing_PricingAI_Error_Response_Msg;
            Pricing_PricingAI_BulkController.QuoteLineWrapper exContentWrap = new Pricing_PricingAI_BulkController.QuoteLineWrapper();
            exContentWrap.message = expMsg;
            exContentWrap.quoteLineNumber = '';
            excepRespJSONString = JSON.serialize(exContentWrap);
            pricingAIRespJSONString.add(excepRespJSONString);
            return pricingAIRespJSONString;
        }     
        return pricingAIRespJSONString;
    }    
    
    /**
    * @description Method to form JSON string for Pricing AI
    * @author Sandeep | 11-11-2022 
    * @param List<String> containing QuoteLine Ids  
    * @return String containing QuoteLine Details 
    **/
    public static String getQuoteLineDetails(List<String> quoteLineId){
        String jsonObj = null;
        List<Pricing_PricingAI_Wrapper.CalloutInputWrapper> calloutWrapperList = new List<Pricing_PricingAI_Wrapper.CalloutInputWrapper>();
        List<SBQQ__QuoteLine__c> quoteLines= [SELECT id,Name,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,
                                              //Account Details
                                              SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c,
                                              //Product Details
                                              Pricing_Product_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Product_Nm__r.Core_Code_Name_EPM_ID__c,Pricing_Product_Nm__r.Core_Product_Name_EPM_ID__c,Pricing_Product_Nm__r.Core_Processor_Number_Nm__c,
                                              SBQQ__Product__c,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Code_Name_EPM_ID__c,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,
                                              //Quote Details
                                              SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,
                                              //Quote Line Details
                                              Pricing_EndCustomer_Nm__c,Pricing_UnifiedEndCustomer__c,Pricing_Group_Type_nm__c,Pricing_Approved_Start_Date_Dt__c,SBQQ__Product__r.Core_Product_Family__c,Pricing_Approved_End_Date_Dt__c,
                                              SBQQ__ProductFamily__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Req_Discounted_Unit_Price__c,
                                              SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,
                                              Pricing_Region_Nm__c,Pricing_End_Customer_Country__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_RegionQL_Nm__c,Pricing_Market_Segment_Nm__c,Pricing_Market_Segment_values_Nm__c,
                                              SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_CPUs_per_system_qty__c,Pricing_Comp_CPUs_per_system_Cnt__c,
                                              Pricing_Competetor_Product__r.Name,Pricing_Other_Competitor_Product_Nm__c,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_End_Date_dt__c,Pricing_Unit_Qty__c,
                                              Pricing_New_Change_Request_cb__c,Pricing_New_Quantity_qty__c,Pricing_Request_Discount_Unit_Price_qty__c,Pricing_Server_Deal_Type_Nm__c,Pricing_Program_Type_Nm__c,
                                              Pricing_Form_Factor_Nm__c,Pricing_SDM_Fast_Track__c,Pricing_Competitor_OEM_Nm__c,SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c
                                              FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineId];
        if(quoteLines.size() > 0){
            User usr = [SELECT id,Core_WWID__c FROM User WHERE id=:UserInfo.getUserId()];
            String CIMiId = Pricing_Tender_Utility.getCIMId(quoteLines[0].SBQQ__Quote__r.SBQQ__Account__c, quoteLines[0].SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c);

            for(SBQQ__QuoteLine__c qli: quoteLines){
                Pricing_PricingAI_Wrapper.CalloutInputWrapper calloutWrapper = new Pricing_PricingAI_Wrapper.CalloutInputWrapper();

                calloutWrapper.productDetails = new Pricing_PricingAI_Wrapper.ProductWrapper();
                
                Pricing_PricingAI_Wrapper.AccountWrapper accountDetails = new Pricing_PricingAI_Wrapper.AccountWrapper();
                accountDetails.name = qli.SBQQ__Quote__r.SBQQ__Account__r.Name;
                accountDetails.cimId = CIMiId;
                //Forming Customer mapping Id and assigning CIM Id (If CIM Id is present we are passing CIM Id, If not there then we are passing Business party id)
                accountDetails.CustomerMappingId = CIMiId;
                accountDetails.id = qli.SBQQ__Quote__r.SBQQ__Account__c;
                calloutWrapper.accountDetails = accountDetails;
                
                //Use CPQ Product Field
                calloutWrapper.productDetails.name = qli.SBQQ__Product__r.Name;
                calloutWrapper.productDetails.epmId = qli.SBQQ__Product__r.Core_Product_Name_EPM_ID__c;
                calloutWrapper.productDetails.processorNumber = qli.SBQQ__Product__r.Core_Processor_Number_Nm__c!=null? qli.SBQQ__Product__r.Core_Processor_Number_Nm__c: '';
                calloutWrapper.productDetails.id = qli.SBQQ__Product__c;
                
                calloutWrapper.endCustomer = qli.Pricing_EndCustomer_Nm__c;
                calloutWrapper.application = qli.Pricing_Server_Deal_Type_Nm__c;
                calloutWrapper.groupType = qli.Pricing_Group_Type_nm__c;
                
                calloutWrapper.approvedStartDate = getFormattedDate((qli.Pricing_Approved_Start_Date_Dt__c!=null ? qli.Pricing_Approved_Start_Date_Dt__c : qli.SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c));
                calloutWrapper.approvedEndDate = getFormattedDate((qli.Pricing_Approved_End_Date_Dt__c!=null ? qli.Pricing_Approved_End_Date_Dt__c : qli.Pricing_End_Date_dt__c));
                calloutWrapper.unifiedEndCustomer = qli.Pricing_UnifiedEndCustomer__c;
                //Change - Code Name
                calloutWrapper.productFamily = qli.SBQQ__Product__r.Core_Product_Family__c!=null? qli.SBQQ__Product__r.Core_Product_Family__c: '';
                calloutWrapper.processorNumber = qli.SBQQ__Product__r.Core_Processor_Number_Nm__c!=null? qli.SBQQ__Product__r.Core_Processor_Number_Nm__c: '';
                calloutWrapper.meetCompPrice = qli.Pricing_Meet_Comp_Price_Amt__c;
               
                
                calloutWrapper.requestedDiscountPrice = qli.Pricing_New_Change_Request_cb__c == true && qli.Pricing_Req_Discounted_Unit_Price__c==null?qli.Pricing_Request_Discount_Unit_Price_qty__c:qli.Pricing_Req_Discounted_Unit_Price__c;
                calloutWrapper.unifiedCountryEndCustomerId = qli.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c;
                calloutWrapper.competitorProductName = qli.Pricing_Competetor_Product__r.Name!=Label.Pricing_Tender_Write_In_Product ? qli.Pricing_Competetor_Product__r.Name: qli.Pricing_Other_Competitor_Product_Nm__c;
                calloutWrapper.effectivePricingStartDate = getFormattedDate(qli.Pricing_Revised_Pricing_Start_Date_dt__c);
                calloutWrapper.endCustomerRegion = qli.Pricing_Region_Nm__c;
                calloutWrapper.endCustomerCountry = qli.Pricing_End_Customer_Country__c;
                calloutWrapper.unifiedEndCustomerId = qli.SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c;
                calloutWrapper.billingEndDate = getFormattedDate(qli.Pricing_Billing_End_Date_Dt__c);
                calloutWrapper.quoteLineId = qli.Id;
                calloutWrapper.name = qli.Name;
                calloutWrapper.region = qli.Pricing_RegionQL_Nm__c;
                calloutWrapper.marketSegment = qli.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? qli.SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c : qli.Pricing_Market_Segment_values_Nm__c;
                calloutWrapper.billingStartDate = getFormattedDate(qli.Pricing_Billing_Start_Date_Dt__c);
                calloutWrapper.formFactor = qli.Pricing_Form_Factor_Nm__c;
                calloutWrapper.competitorName = qli.Pricing_Competitor_OEM_Nm__c;
                
                calloutWrapper.approvedQuantity = qli.Pricing_New_Change_Request_cb__c == true && qli.Pricing_Approved_Unit_Qty__c==null? qli.Pricing_New_Quantity_qty__c:qli.Pricing_Approved_Unit_Qty__c;
                calloutWrapper.quoteLineNumber = qli.Pricing_Quote_Line_Number__c;            
                calloutWrapper.productName = qli.SBQQ__Product__r.Name;
                calloutWrapper.noOfCPUPerSystem = qli.Pricing_CPUs_per_system_qty__c;
                calloutWrapper.noOfCompCPUPerSystem = qli.Pricing_Comp_CPUs_per_system_Cnt__c;
                calloutWrapper.quoteLineType = qli.Pricing_Program_Type_Nm__c;
                calloutWrapper.intelAccountExecutiveEmail=!String.isBlank(qli.SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c)?qli.SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c : '';
                calloutWrapper.sdmFastTrack = qli.Pricing_SDM_Fast_Track__c;
                calloutWrapper.wwid = usr.Core_WWID__c;
                calloutWrapperList.add(calloutWrapper);
            }

            jsonObj = JSON.serialize(calloutWrapperList);
        }
        return jsonObj;
    }

    /**
    * @description Method created to disable Run AI based on the Trigger Switch
    * @author Bharath Chandrashekar | 01-18-2025 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean isPricingAIEnabled(){
        try {
            return TriggerHandler.isActive('Pricing_AI');
        }
        catch (Exception e) {
            Pricing_Tender_Utility.logError(e);
            return false;
        }
    }   
    
    public Static String getFormattedDate(DateTime dt){
        return (dt==null? null : dt.format('MM/dd/yyyy'));
    }
    public Static String getFormattedDate(Date dt){
        return (dt==null? null : dt.format());
    }
    
    public class QuoteLineWrapper{
        public Decimal recommendedPrice;
        public String priceInterval;
        public Decimal discount;
        public String message;
        public String quoteLineNumber;
        public String warningMessage;
    }
}