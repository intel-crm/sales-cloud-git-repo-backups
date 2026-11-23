/****************************************************************************************************
Apex Class Name : PSG_Quote_Price_Prediction_Controller
Version         : 1.0 
Created Date    : 08/10/2024
Function        : Class is used to get the predicted suggested resale and Design Win Convertible 
                  Attributes from the ML Price Prediction Model.
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ranjit                  08/10/2024                 Created
*****************************************************************************************************/

public without sharing class PSG_Quote_Price_Prediction_Controller {
    
/************************************************************************************************************
    *Method Name : getQuoteLines
    *Created Date: 08/10/2024
    *Author: Ranjit
    *Description : get the quoteline details for the quote.
************************************************************************************************************/
   
    public static List<SBQQ__QuoteLine__c> getQuoteLines(String quoteId) {
        quoteId = String.escapeSingleQuotes(quoteId);
        return [select name,Core_OPN__c, price_suggested_resale_amt__c, core_cpq_resale_guidance__c,core_cpq_intel_margin_pct__c, 
                                               core_cpq_design_win_convertible__c, core_cpq_disregarding_price_guidance__c, SBQQ__Quantity__c, price_brokencost_amt__c,core_cpq_distributor_margin_pct__c, 
                                               price_msvp_l2_amt__c,SBQQ__Quote__r.core_cpq_account_tier__c,core_cpq_sap_ecp_nm__r.Name, core_cpq_years_nbr__c,price_requested_resale_amt__c,SBQQ__Quote__r.core_cpq_business_unit_nm__c, 
                                               core_cpq_product_nm__r.Name,SBQQ__ListPrice__c,SBQQ__Quote__r.core_cpq_end_customer_nm__r.Core_Geo__c,SBQQ__Quote__r.core_cpq_end_customer_nm__r.name,core_cpq_quote_line_type_txt__c,SBQQ__Product__c,price_std_fwd_cost_amt__c,core_cpq_product_nm__r.Core_Product_Group__c  from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId];
        
    }
    
/************************************************************************************************************
    *Method Name : updateQuoteLines
    *Created Date: 08/10/2024
    *Author: Ranjit
    *Description : Update the Quote Line.
************************************************************************************************************/    
    
    @AuraEnabled
    public static void updateQuoteLines(List<SBQQ__QuoteLine__c> quoteLines) {
        try {
            update quoteLines;
        } catch (Exception e) {
            PSG_Utility.createCoreLogEntry('PSG_Quote_Price_Prediction_Controller','updateQuoteLines','Failed while Updating the QuoteLines ',e.getMessage()
                                          ,'SBQQ__QuoteLine__c','High','');
            throw new AuraHandledException(e.getMessage());
        }
    }
    
/************************************************************************************************************
 *Method Name : sendQuoteLinesToEndpoint
 *Created Date: 08/10/2024
 *Author: Ranjit
 *Description : Send the Quoteline details to ML Price Predict Model to get the Predicted Suggested Resale.
************************************************************************************************************/    
       
    @AuraEnabled
    public static PSG_Quote_Price_Prediction_Controller.LightningResponse sendQuoteLinesToEndpoint(String quoteId) {
        quoteId = String.escapeSingleQuotes(quoteId);
        PSG_Quote_Price_Prediction_Controller.LightningResponse lr=new PSG_Quote_Price_Prediction_Controller.LightningResponse();
	    List<SBQQ__QuoteLine__c> finalqlList=new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLines = getQuoteLines(quoteId);
        List<Object> strDataList= new List<Object>();
        List<Object> strpredictDataList= new List<Object>();
        List<Map<String, Object>> classificationrequestpayload = QuotelineMapping(quoteLines,'classification');
        List<Map<String, Object>> predictionrequestpayload = QuotelineMapping(quoteLines,'prediction');
        Map<String, String> dwinConvertMap = new Map<String, String>();
        Map<String, Decimal> qlNametoAIPriceMap = new Map<String, Decimal>();
        String classificationjsonBody = JSON.serialize(classificationrequestpayload);
        string classificationPayload='{"data":{"ndarray":' + classificationjsonBody + ' } }';
        String predictionjsonBody = JSON.serialize(predictionrequestpayload);
        string predictionPayload='{"data":{"ndarray":' + predictionjsonBody + ' } }';
        system.debug('classificationrequest--->'+classificationPayload);
        system.debug('predictionrequest--->'+predictionPayload);
        HttpRequest classificationrequest = new HttpRequest();
        Http classificationhttp = new Http();
        classificationrequest.setEndpoint('callout:PSG_Price_prediction'+'/v1/classification');  
        classificationrequest.setMethod('POST');
        classificationrequest.setHeader('Content-Type', 'application/json');
        classificationrequest.setBody(classificationPayload);
        system.debug('classificationrequest-->'+classificationrequest);
        HttpRequest predictionreq = new HttpRequest();
        Http predictionhttp = new Http();
        predictionreq.setEndpoint('callout:PSG_Price_prediction'+'/v1/prediction');
        predictionreq.setMethod('POST');
        predictionreq.setHeader('Content-Type', 'application/json');
        predictionreq.setBody(predictionPayload);
        
        
        
        try {
            HttpResponse classificationresponse = classificationhttp.send(classificationrequest);
            system.debug('classificationresponse--->'+classificationresponse.getBody());
            if(classificationresponse.getStatusCode()==Integer.valueOf(Label.PSG_ALN_SuccessCode)){
                HttpResponse predictionresponse = predictionhttp.send(predictionreq);
                system.debug('predictionresponse--->'+predictionresponse.getBody());
                if(predictionresponse.getStatusCode()==Integer.valueOf(Label.PSG_ALN_SuccessCode)){
                    Map<String,Object> classificationresMap= (Map<String,Object>)JSON.deserializeUntyped(classificationresponse.getBody());
                    Map<String,Object> predictionresMap= (Map<String,Object>)JSON.deserializeUntyped(predictionresponse.getBody());
                    system.debug('classificationresMap'+classificationresMap);
                    system.debug('predictionresMap'+predictionresMap);
                    system.debug('str-->'+classificationresMap.get('strData'));
                    
                    String classificationjsonResponse = (String) classificationresMap.get('strData');
                    strDataList = (List<Object>) JSON.deserializeUntyped(classificationjsonResponse);
                    system.debug('strDataList-->'+strDataList);
                    String predictionjsonResponse = (String) predictionresMap.get('strData');
                    strpredictDataList = (List<Object>) JSON.deserializeUntyped(predictionjsonResponse);
                    system.debug('strpredictDataList-->'+strpredictDataList);
                    if(!strDataList.isempty()){
                        for (Object CObj : strDataList) {
                            Map<String, Object> entry = (Map<String, Object>) CObj;
                            String qlName = String.valueof(entry.get('QuoteLineNumber'));
                            String dwinConvertValue = entry.get('predicted_value') == 1 ?'Yes':'No';
                            dwinConvertMap.put(qlName, dwinConvertValue);
                        }
                    }
                    if(!strpredictDataList.isempty()){
                        for (Object PObj : strpredictDataList) {
                            Map<String, Object> entry1 = (Map<String, Object>) PObj;
                            String qlName = String.valueof(entry1.get('QuoteLineNumber'));
                            Decimal AIpricevalue= Decimal.valueOf(String.valueOf(entry1.get('predicted_value'))).setScale(2);
                            qlNametoAIPriceMap.put(qlName, AIpricevalue);  
                        } 
                    }
                    
                    system.debug('dwinConvertMap-->'+dwinConvertMap);
                    system.debug('qlNametoAIPriceMap-->'+qlNametoAIPriceMap);
                    for(SBQQ__QuoteLine__c ql:quoteLines){
                        string QLName=ql.Name.replaceFirst('^QL-0*', '');
                        ql.core_cpq_design_win_convertible__c=dwinConvertMap.get(QLName);
                        ql.core_cpq_resale_guidance__c=qlNametoAIPriceMap.get(QLName);
                        finalqlList.add(ql);
                    }
                    lr.isSuccess=true;
                    lr.qlList=finalqlList;
                }else{
                    PSG_Utility.createCoreLogEntry('PSG_Quote_Price_Prediction_Controller','sendQuoteLinesToEndpoint','Failed while fetching QuoteLine details from ML Model','predictionresponse---> ' + predictionresponse.getBody()
                                          ,'SBQQ__QuoteLine__c','High','');
                    lr.isSuccess=false;
                    lr.errorMessage= 'error while fetching QuoteLine details from ML Model';
                }
            }else{
                    PSG_Utility.createCoreLogEntry('PSG_Quote_Price_Prediction_Controller','sendQuoteLinesToEndpoint','Failed while fetching QuoteLine details from ML Model', 'classificationresponse---> '+ classificationresponse.getBody()
                                          ,'SBQQ__QuoteLine__c','High','');
                    lr.isSuccess=false;
                    lr.errorMessage= 'error while fetching QuoteLine details from ML Model';
                
            }
        
        } catch (Exception e) {
                  PSG_Utility.createCoreLogEntry('PSG_Quote_Price_Prediction_Controller','sendQuoteLinesToEndpoint','Failed while fetching QuoteLine details from ML Model',e.getMessage()
                                          ,'SBQQ__QuoteLine__c','High','');
                    lr.isSuccess=false;
                    lr.errorMessage= e.getMessage();
        }
        system.debug('lr-->'+lr);
        return lr;
    }

/************************************************************************************************************
 *Method Name : QuotelineMapping
 *Created Date: 08/20/2024
 *Author: Ranjit
 *Description : method to create the quoteline mapping.
************************************************************************************************************/
    
    public static List<Map<String, Object>> QuotelineMapping(List<SBQQ__QuoteLine__c> quoteLines , string requesttype) {
        List<Map<String, Object>> requestpayloadmap = new List<Map<String, Object>>();
        
        for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
            Map<String, Object> quoteLineMap = new Map<String, Object>();
            quoteLineMap.put('IntelMargin%', quoteLine.core_cpq_intel_margin_pct__c);
            quoteLineMap.put('ColumnPrice', quoteLine.SBQQ__ListPrice__c==null ? 0:quoteLine.SBQQ__ListPrice__c);
            quoteLineMap.put('OPN', quoteLine.Core_OPN__c);
            quoteLineMap.put('ProductLevel4', quoteLine.core_cpq_product_nm__r.Core_Product_Group__c );
            quoteLineMap.put('DistyMargin%', quoteLine.core_cpq_distributor_margin_pct__c);
            quoteLineMap.put('MarketSegmentBusinessUnit', quoteLine.SBQQ__Quote__r.core_cpq_business_unit_nm__c);
            quoteLineMap.put('QuoteLineType', quoteLine.core_cpq_quote_line_type_txt__c);
            if(requesttype=='classification'){
                quoteLineMap.put('SuggestedResalePrice', quoteLine.price_suggested_resale_amt__c);
            }
            quoteLineMap.put('RequestedResalePrice', quoteLine.price_requested_resale_amt__c==null ? 0 : quoteLine.price_requested_resale_amt__c);
            quoteLineMap.put('Quantity', Integer.valueof(quoteLine.SBQQ__Quantity__c));
            quoteLineMap.put('Numberofyears', quoteLine.core_cpq_years_nbr__c);
            quoteLineMap.put('ECPricingParentName', quoteLine.core_cpq_sap_ecp_nm__r.Name);
            quoteLineMap.put('EndCustomerCategory', quoteLine.SBQQ__Quote__r.core_cpq_account_tier__c);
            quoteLineMap.put('EndCustomerName', quoteLine.SBQQ__Quote__r.core_cpq_end_customer_nm__r.name);
            //TWC3133-5964 Geo Change
            String region = '';
            region = (quoteLine.SBQQ__Quote__r.core_cpq_end_customer_nm__r.Core_Geo__c == 'INDIA')?'APJ' : quoteLine.SBQQ__Quote__r.core_cpq_end_customer_nm__r.Core_Geo__c;
            quoteLineMap.put('EndCustomerRegion', region);
            quoteLineMap.put('QuoteLineNumber', quoteLine.Name);
            
            requestpayloadmap.add(quoteLineMap);
            
        }
        return requestpayloadmap;
    }
    
    public class LightningResponse{
        @AuraEnabled 
        public Boolean isSuccess;
        @AuraEnabled 
        public String errorMessage;
        @AuraEnabled
        public List<SBQQ__QuoteLine__c> QlList;
    } 
    
        
}