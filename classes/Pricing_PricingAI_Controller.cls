/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 10-01-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_PricingAI_Controller {
    //Pricing_PricingAI_Controller.getQuoteLineDetails('a9U2D000000PxtnUAC');
    @AuraEnabled
    public static List<String> makeCallout(String quoteLineId){     
        quoteLineId = String.escapeSingleQuotes(quoteLineId);
        Response resp = new Response();
        String qlRecJSONString;
        String errRespJSONString;
        String invalidInpJSONString;
        String excepRespJSONString;
        List<String> pricingAIRespJSONString = new List<String>();
        List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
        try{
            SBQQ__QuoteLine__c qlRec = [SELECT Id, Name, Pricing_Recommended_Price_Amt__c,Pricing_Recommendation_FeedBack_Nm__c
                                        FROM SBQQ__QuoteLine__c WHERE Id =: quoteLineId LIMIT 1];
            Map<String,String> successMsgMap = new Map<String,String>();
            Map<String,String> errorMsgMap = new Map<String,String>();
            Map<String,String> invalidJSONMap = new Map<String,String>();
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
                Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                List<Object> resultslist = (List<Object>)results.get('successContent');
                if(resultslist != null && resultsList.size()>0){
                    resp.isSuccess = true;
                    resp.successContent = response.getBody();
                    successMsgMap.put(qlRec.Name,inputJSON);
                    qlNameToQLIdMap.put(qlRec.Name,qlRec.Id);
                    logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectPricingAIIntegration(successMsgMap, qlNameToQLIdMap, 'Low'));
                    if(logEntryList.size() > 0){
                        insert logEntryList;    
                    }
                    for(Object resultMap:resultslist ){
                        Map<String,Object> tempMap = new MAP<String,Object>((Map<String,Object>)resultMap);
                        Pricing_PricingAI_Controller.QuoteLineWrapper qlWrap = new Pricing_PricingAI_Controller.QuoteLineWrapper();
                        qlWrap.recommendedPrice = ((Decimal)tempMap.get('recommendedPrice'))!=null?(Decimal)tempMap.get('recommendedPrice'):0;
                        qlWrap.priceInterval = (String.valueOf(tempMap.get('priceInterval')))!=null?String.valueOf(tempMap.get('priceInterval')):'';
                        discountPrice = ((String)tempMap.get('discount')).replaceAll('%', '');
                        qlWrap.discount = (Decimal.valueOf(discountPrice))*100;
                        qlWrap.warningMessage = (String.valueOf(tempMap.get('warningMessage'))) != null ? String.valueOf(tempMap.get('warningMessage')) : '';
                        qlRecJSONString = JSON.serialize(qlWrap);
                        pricingAIRespJSONString.add(qlRecJSONString);
                    }
                }
                else{
                    resp.isSuccess = false;
                    resp.successContent = null;
                    Map<String,Object> errorRes = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());                    
                    List<Object> errResList = (List<Object>)errorRes.get('errorContent');                        
                    for(Object errResMap:errResList ){                                
                        Map<String,Object> tempErrMap = new MAP<String,Object>((Map<String,Object>)errResMap);
                        Pricing_PricingAI_Controller.errorContentWrapper errContentWrap = new Pricing_PricingAI_Controller.errorContentWrapper();
                        errContentWrap.message = String.valueOf(tempErrMap.get('message'));
                        errContentWrap.quoteLineNumber = String.valueOf(tempErrMap.get('quoteLineNumber'));
                        errRespJSONString = JSON.serialize(errContentWrap);
                        pricingAIRespJSONString.add(errRespJSONString);
                        errorMsgMap.put(qlRec.Name,errContentWrap.message);
                        errorQLNameToQLIdMap.put(qlRec.Name,qlRec.Id);
                        logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectPricingAIIntegration(errorMsgMap, errorQLNameToQLIdMap, 'Critical'));
                    }                    
                    
                    if(logEntryList.size() > 0){
                        insert logEntryList;    
                    }
                    return pricingAIRespJSONString;
                }
            }else{
                resp.isSuccess = false;
                resp.successContent = null;
                String msg = 'Quote Line Record - '+qlRec.Name+' is processed with an error, as the inputJSON is invalid. Please check the request.';
                invalidJSONMap.put(qlRec.Name,msg);
                errorJSONQLNameToQLIdMap.put(qlRec.Name,qlRec.Id);
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectPricingAIIntegration(invalidJSONMap, errorJSONQLNameToQLIdMap, 'Critical'));
                if(logEntryList.size() > 0){
                    insert logEntryList;    
                }
                Pricing_PricingAI_Controller.errorContentWrapper errInpJSONWrap = new Pricing_PricingAI_Controller.errorContentWrapper();
                errInpJSONWrap.message = msg;
                errInpJSONWrap.quoteLineNumber = '';
                invalidInpJSONString = JSON.serialize(errInpJSONWrap);
                pricingAIRespJSONString.add(invalidInpJSONString);
                return pricingAIRespJSONString;
            }
        }catch(Exception exp){
            resp.isSuccess = false;
            resp.successContent = null;
            Pricing_Tender_Utility.logError(exp);
            String expMsg = Label.Pricing_PricingAI_Error_Response_Msg;
            Pricing_PricingAI_Controller.errorContentWrapper exContentWrap = new Pricing_PricingAI_Controller.errorContentWrapper();
            exContentWrap.message = expMsg;
            exContentWrap.quoteLineNumber = '';
            excepRespJSONString = JSON.serialize(exContentWrap);
            pricingAIRespJSONString.add(excepRespJSONString);
            return pricingAIRespJSONString;
        }     
        
        return pricingAIRespJSONString;
    }    
    
    public static String getQuoteLineDetails(String quoteLineId){
        quoteLineId = String.escapeSingleQuotes(quoteLineId);
        String jsonObj = null;
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
                                              FROM SBQQ__QuoteLine__c WHERE Id=:quoteLineId];
        
        if(quoteLines.size() > 0){
            User usr = [SELECT id,Core_WWID__c FROM User WHERE id=:UserInfo.getUserId()];
            Pricing_PricingAI_Wrapper.CalloutInputWrapper calloutWrapper = new Pricing_PricingAI_Wrapper.CalloutInputWrapper();
            //calloutWrapper.accountDetails = new AccountWrapper();
            calloutWrapper.productDetails = new Pricing_PricingAI_Wrapper.ProductWrapper();
            
            Pricing_PricingAI_Wrapper.AccountWrapper accountDetails = new Pricing_PricingAI_Wrapper.AccountWrapper();
            accountDetails.name = quoteLines[0].SBQQ__Quote__r.SBQQ__Account__r.Name;
            
            accountDetails.cimId = Pricing_Tender_Utility.getCIMId(quoteLines[0].SBQQ__Quote__r.SBQQ__Account__c, quoteLines[0].SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c);
            
            accountDetails.id = quoteLines[0].SBQQ__Quote__r.SBQQ__Account__c;
            calloutWrapper.accountDetails = accountDetails;
            //calloutWrapper.accountDetails.name=quoteLines[0].SBQQ__Quote__r.SBQQ__Account__r.Name;
            //calloutWrapper.accountDetails.cimId = quoteLines[0].SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID_Old__c!=null?quoteLines[0].SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID_Old__c:'';
            //calloutWrapper.accountDetails.id = quoteLines[0].SBQQ__Quote__r.SBQQ__Account__c;
            
            //Use CPQ Product Field
            calloutWrapper.productDetails.name = quoteLines[0].SBQQ__Product__r.Name;
            calloutWrapper.productDetails.epmId = quoteLines[0].SBQQ__Product__r.Core_Product_Name_EPM_ID__c;
            calloutWrapper.productDetails.processorNumber = quoteLines[0].SBQQ__Product__r.Core_Processor_Number_Nm__c!=null? quoteLines[0].SBQQ__Product__r.Core_Processor_Number_Nm__c: '';
            calloutWrapper.productDetails.id = quoteLines[0].SBQQ__Product__c;
            
            calloutWrapper.endCustomer = quoteLines[0].Pricing_EndCustomer_Nm__c;
            calloutWrapper.application = quoteLines[0].Pricing_Server_Deal_Type_Nm__c;
            calloutWrapper.groupType = quoteLines[0].Pricing_Group_Type_nm__c;
            
            calloutWrapper.approvedStartDate = getFormattedDate((quoteLines[0].Pricing_Approved_Start_Date_Dt__c!=null ? quoteLines[0].Pricing_Approved_Start_Date_Dt__c : quoteLines[0].SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c));
            calloutWrapper.approvedEndDate = getFormattedDate((quoteLines[0].Pricing_Approved_End_Date_Dt__c!=null ? quoteLines[0].Pricing_Approved_End_Date_Dt__c : quoteLines[0].Pricing_End_Date_dt__c));
            calloutWrapper.unifiedEndCustomer = quoteLines[0].Pricing_UnifiedEndCustomer__c;
            //Change - Code Name
            calloutWrapper.productFamily = quoteLines[0].SBQQ__Product__r.Core_Product_Family__c!=null? quoteLines[0].SBQQ__Product__r.Core_Product_Family__c: '';
            calloutWrapper.processorNumber = quoteLines[0].SBQQ__Product__r.Core_Processor_Number_Nm__c!=null? quoteLines[0].SBQQ__Product__r.Core_Processor_Number_Nm__c: '';
            calloutWrapper.meetCompPrice = quoteLines[0].Pricing_Meet_Comp_Price_Amt__c;
           
            calloutWrapper.requestedDiscountPrice = quoteLines[0].Pricing_New_Change_Request_cb__c == true && quoteLines[0].Pricing_Req_Discounted_Unit_Price__c==null?quoteLines[0].Pricing_Request_Discount_Unit_Price_qty__c:quoteLines[0].Pricing_Req_Discounted_Unit_Price__c;
            calloutWrapper.unifiedCountryEndCustomerId = quoteLines[0].SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c;
            calloutWrapper.competitorProductName = quoteLines[0].Pricing_Competetor_Product__r.Name!=Label.Pricing_Tender_Write_In_Product ? quoteLines[0].Pricing_Competetor_Product__r.Name: quoteLines[0].Pricing_Other_Competitor_Product_Nm__c;
            calloutWrapper.effectivePricingStartDate = getFormattedDate(quoteLines[0].Pricing_Revised_Pricing_Start_Date_dt__c);
            calloutWrapper.endCustomerRegion = quoteLines[0].Pricing_Region_Nm__c;
            calloutWrapper.endCustomerCountry = quoteLines[0].Pricing_End_Customer_Country__c;
            calloutWrapper.unifiedEndCustomerId = quoteLines[0].SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c;
            calloutWrapper.billingEndDate = getFormattedDate(quoteLines[0].Pricing_Billing_End_Date_Dt__c);
            calloutWrapper.quoteLineId = quoteLines[0].Id;
            calloutWrapper.name = quoteLines[0].Name;
            calloutWrapper.region = quoteLines[0].Pricing_RegionQL_Nm__c;
            calloutWrapper.marketSegment = quoteLines[0].Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? quoteLines[0].SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c : quoteLines[0].Pricing_Market_Segment_values_Nm__c;
            calloutWrapper.billingStartDate = getFormattedDate(quoteLines[0].Pricing_Billing_Start_Date_Dt__c);
            calloutWrapper.formFactor = quoteLines[0].Pricing_Form_Factor_Nm__c;
            calloutWrapper.competitorName = quoteLines[0].Pricing_Competitor_OEM_Nm__c;
            
            calloutWrapper.approvedQuantity = quoteLines[0].Pricing_New_Change_Request_cb__c == true && quoteLines[0].Pricing_Approved_Unit_Qty__c==null? quoteLines[0].Pricing_New_Quantity_qty__c:quoteLines[0].Pricing_Approved_Unit_Qty__c;
            calloutWrapper.quoteLineNumber = quoteLines[0].Pricing_Quote_Line_Number__c;            
            calloutWrapper.productName = quoteLines[0].SBQQ__Product__r.Name;
            calloutWrapper.noOfCPUPerSystem = quoteLines[0].Pricing_CPUs_per_system_qty__c;
            calloutWrapper.noOfCompCPUPerSystem = quoteLines[0].Pricing_Comp_CPUs_per_system_Cnt__c;
            calloutWrapper.quoteLineType = quoteLines[0].Pricing_Program_Type_Nm__c;
            calloutWrapper.wwid = usr.Core_WWID__c;
            calloutWrapper.intelAccountExecutiveEmail=!String.isBlank(quoteLines[0].SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c)?quoteLines[0].SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c : '';
            calloutWrapper.sdmFastTrack = quoteLines[0].Pricing_SDM_Fast_Track__c;
            List<Pricing_PricingAI_Wrapper.CalloutInputWrapper> calloutWrapperList = new List<Pricing_PricingAI_Wrapper.CalloutInputWrapper>();
            calloutWrapperList.add(calloutWrapper);
            jsonObj = JSON.serialize(calloutWrapperList);            
        }  
        system.debug('jsonObj:'+jsonObj);      
        return jsonObj;        
    }    
    
    //public static SearchResultWrapper getSearchResults(String objectName, String fieldName, String searchType, String searchText){
    @AuraEnabled
    public static SearchResultWrapper getSearchResults(String jsonObj){
        jsonObj =  String.escapeSingleQuotes(String.valueOf(jsonObj));
        SearchParams searchObj = (SearchParams) JSON.deserialize(jsonObj, SearchParams.class);
        String partialSrchText = '\'%'+searchObj.searchText+'%\'';
        String fullSearchText = '\''+searchObj.searchText+'\'';
        SearchResultWrapper resWrapper = new SearchResultWrapper();
        try{
            if(searchObj.searchText!=null){
                String query = String.format('SELECT id,{0} FROM {1} WHERE {2} {3} {4}',
                                             new List<String>{searchObj.fieldName, searchObj.objectName, searchObj.fieldName, 
                                                 (searchObj.searchType=='Partial'?'LIKE':'='),
                                                 (searchObj.searchType=='Partial'? partialSrchText : fullSearchText)
                                                 });
                
                if(!String.isEmpty(searchObj.filterFieldName) && !String.isEmpty(searchObj.filterFieldvalue)){
                    query = query + ' AND '+searchObj.filterFieldName+'=\''+searchObj.filterFieldvalue+'\'';
                }
                query = String.escapeSingleQuotes(String.valueOf(query));
                List<Sobject> records = database.query(query);
                if(records.size() > 0){
                    resWrapper.isSuccess = true;
                    resWrapper.searchResults = new List<SearchResult>();
                    for(SObject obj : records){
                        SearchResult res = new SearchResult((String)obj.get('Id'), 
                                                            (String)obj.get(searchObj.fieldName));
                        resWrapper.searchResults.add(res);
                    }
                }
            }else{
                resWrapper.isSuccess = false;
                resWrapper.searchResults = null;
            }            
        }catch(Exception exp){
            resWrapper.isSuccess = false;
            resWrapper.searchResults = null;
            resWrapper.errorContent = 'Exception ==>'+exp+';;'+exp.getStackTraceString()+';;'+exp.getLineNumber();
        }
        return resWrapper;
    }
    
    public Static String getFormattedDate(DateTime dt){
        return (dt==null? null : dt.format('MM/dd/yyyy'));
    }

    public Static String getFormattedDate(Date dt){
        return (dt==null? null : dt.format());
    }
    
    public class SearchResultWrapper{
        @AuraEnabled public boolean isSuccess;
        @AuraEnabled public List<SearchResult> searchResults;
        @AuraEnabled public String errorContent {set;get;}
    }
    
    public class SearchResult {
        @AuraEnabled public String recordId;
        @AuraEnabled public String fldValue;
        public SearchResult(String recordId, String fldValue){
            this.recordId = recordId;
            this.fldValue = fldValue;
        }
    }

    public class Response {
        @AuraEnabled public boolean isSuccess {set;get;}
        @AuraEnabled public String successContent {set;get;}        
    }
    
    public class SearchParams {
        @AuraEnabled public String objectName {set;get;}
        @AuraEnabled public String fieldName {set;get;}
        @AuraEnabled public String searchType {set;get;} 
        @AuraEnabled public String searchText {set;get;}
        @AuraEnabled public String filterFieldName {set;get;}
        @AuraEnabled public String filterFieldValue {set;get;}
    }
    
    public class QuoteLineWrapper{
        public Decimal recommendedPrice;
        public String priceInterval;
        public Decimal discount;
        public String warningMessage;
    }

    public class errorContentWrapper{
        public String message;
        public String quoteLineNumber;
    }
}