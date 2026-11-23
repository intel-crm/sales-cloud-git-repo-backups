public class PSG_AIPricePrediction {
   
    @InvocableMethod(callout=true label='AIPricePrediction' category='QuoteLine')
    public static List<String> predictPrice(List<Id> recordId){
    //public static void predictPrice(string recordId){
    //List<String> quoteline = new List<String>();
     List<SBQQ__QuoteLine__c> quoteline = [SELECT id,name,SBQQ__Quote__r.core_cpq_end_customer_nm__r.Core_Geo__c,SBQQ__Quote__r.core_cpq_account_tier__c,core_cpq_sap_ecp_nm__r.name,SBQQ__Quote__r.core_cpq_quote_type_nm__c,price_peak_annual_resale_amt__c,
                                 core_cpq_quantity_nm__c,price_requested_resale_amt__c,price_suggested_resale_amt__c,
                                 core_cpq_quote_line_type_txt__c,SBQQ__Quote__r.core_cpq_business_unit_nm__c,
                                 core_cpq_intel_margin_pct__c,core_cpq_disti_pct__c,core_cpq_product_family_txt__c,
                                 core_cpq_product_nm__r.Core_OPN__c,core_cpq_sap_ecp_nm__r.Core_Direct_Account_Id__c from SBQQ__QuoteLine__c WHERE Id in :recordId LIMIT 1];  
         SBQQ__QuoteLine__c ql = quoteline[0];
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        String region = '';
        region = (ql.SBQQ__Quote__r.core_cpq_end_customer_nm__r.Core_Geo__c == 'INDIA')?'APJ' : ql.SBQQ__Quote__r.core_cpq_end_customer_nm__r.Core_Geo__c;
        jsGen.writeStringField('Region', region);
        //jsGen.writeStringField('Region',ql.SBQQ__Quote__r.core_cpq_end_customer_nm__r.Core_Geo__c);
        jsGen.writeStringField('ITEM_ROW_ID',ql.Id);
        jsGen.writeStringField('CLASS',ql.SBQQ__Quote__r.core_cpq_account_tier__c);
        jsGen.writeStringField('ECP',ql.core_cpq_sap_ecp_nm__r.name);
        jsGen.writeStringField('ECP_ID',ql.core_cpq_sap_ecp_nm__r.Core_Direct_Account_Id__c);
        jsGen.writeStringField('QUOTE TYPE',ql.SBQQ__Quote__r.core_cpq_quote_type_nm__c);
        jsGen.writeStringField('ColumnResalePrice',ql.price_peak_annual_resale_amt__c==null?'':String.valueof(ql.price_peak_annual_resale_amt__c));// ?
        jsGen.writeStringField('X_QTY_EAU',ql.core_cpq_quantity_nm__c==null?'':String.valueof(ql.core_cpq_quantity_nm__c));
        jsGen.writeStringField('RequestedResalePrice',ql.price_requested_resale_amt__c==null?'':String.valueof(ql.price_requested_resale_amt__c));
        jsGen.writeStringField('X_SUGGESTED_PRICE',ql.price_suggested_resale_amt__c==null?'':String.valueof(ql.price_suggested_resale_amt__c));
        jsGen.writeStringField('QuoteLineType',ql.core_cpq_quote_line_type_txt__c);
        jsGen.writeStringField('BU',ql.SBQQ__Quote__r.core_cpq_business_unit_nm__c);
        jsGen.writeStringField('IntelMargin',ql.core_cpq_intel_margin_pct__c==null?'':String.valueof(ql.core_cpq_intel_margin_pct__c));
        jsGen.writeStringField('DistiMargin',ql.core_cpq_disti_pct__c==null?'':String.valueof(ql.core_cpq_disti_pct__c));
        jsGen.writeStringField('ProductFamily',ql.core_cpq_product_family_txt__c);
        jsGen.writeStringField('Product',ql.core_cpq_product_nm__r.Core_OPN__c);
        
        
        jsGen.writeEndObject();
       System.debug('String'+jsGen.getAsString());
       System.debug('String'+jsGen.toString());        
     return  new List<String>{jsGen.getAsString()} ;
       
    }

    
    
    }
    
        
  /* List<SBQQ__QuoteLine__c> ql = [SELECT id,name,SBQQ__Quote__r.core_cpq_end_customer_nm__r.Core_Geo__c,SBQQ__Quote__r.core_cpq_account_tier__c,core_cpq_sap_ecp_nm__r.name,SBQQ__Quote__r.core_cpq_quote_type_nm__c,price_peak_annual_resale_amt__c,
                                 core_cpq_quantity_nm__c,price_requested_resale_amt__c,price_suggested_resale_amt__c,
                                 core_cpq_quote_line_type_txt__c,SBQQ__Quote__r.core_cpq_business_unit_nm__c,
                                 core_cpq_intel_margin_pct__c,core_cpq_disti_pct__c,core_cpq_product_family_txt__c,
                                 core_cpq_product_nm__r.Core_OPN__c,core_cpq_sap_ecp_nm__r.Core_Direct_Account_Id__c from SBQQ__QuoteLine__c WHERE id =:recordId LIMIT 1];
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeStringField('Region',ql.SBQQ__Quote__r.core_cpq_end_customer_nm__r.Core_Geo__c);
        jsGen.writeStringField('ITEM_ROW_ID',ql.Id);
        jsGen.writeStringField('CLASS',ql.SBQQ__Quote__r.core_cpq_account_tier__c);
        jsGen.writeStringField('ECP',ql.core_cpq_sap_ecp_nm__r.name);
        jsGen.writeStringField('ECP_ID',ql.core_cpq_sap_ecp_nm__r.Core_Direct_Account_Id__c);
        jsGen.writeStringField('QUOTE TYPE',ql.SBQQ__Quote__r.core_cpq_quote_type_nm__c);
        jsGen.writeStringField('ColumnResalePrice',ql.price_peak_annual_resale_amt__c==null?'':String.valueof(ql.price_peak_annual_resale_amt__c));// ?
        jsGen.writeStringField('X_QTY_EAU',ql.core_cpq_quantity_nm__c==null?'':String.valueof(ql.core_cpq_quantity_nm__c));
        jsGen.writeStringField('RequestedResalePrice',ql.price_requested_resale_amt__c==null?'':String.valueof(ql.price_requested_resale_amt__c));
        jsGen.writeStringField('X_SUGGESTED_PRICE',ql.price_suggested_resale_amt__c==null?'':String.valueof(ql.price_suggested_resale_amt__c));
        jsGen.writeStringField('QuoteLineType',ql.core_cpq_quote_line_type_txt__c);
        jsGen.writeStringField('BU',ql.SBQQ__Quote__r.core_cpq_business_unit_nm__c);
        jsGen.writeStringField('IntelMargin',ql.core_cpq_intel_margin_pct__c==null?'':String.valueof(ql.core_cpq_intel_margin_pct__c));
        jsGen.writeStringField('DistiMargin',ql.core_cpq_disti_pct__c==null?'':String.valueof(ql.core_cpq_disti_pct__c));
        jsGen.writeStringField('ProductFamily',ql.core_cpq_product_family_txt__c);
        jsGen.writeStringField('Product',ql.core_cpq_product_nm__r.Core_OPN__c);
        
        
        jsGen.writeEndObject();
*/
       
        
       /* System.debug('String'+jsGen.getAsString());
                      HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:AIPredictionService');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json;charset=UTF-8');
              req.setBody(jsGen.getAsString());
                Http http = new Http();
                HTTPResponse res = http.send(req);*/