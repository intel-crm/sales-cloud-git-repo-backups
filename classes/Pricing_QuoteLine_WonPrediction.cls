/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-02-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QuoteLine_WonPrediction {
    @future(callout = true)
    public static void predictionQlStatusMarkAsWon(Set<Id> qlIds){

        try{
            List<SBQQ__QuoteLine__c> quoteLineList = [select id,Pricing_Quote_Line_Number__c,Pricing_QuoteLine_Won_Prediction__c,SBQQ__Quote__r.Pricing_Bid_Dt__c,SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Competetor_Product__r.Name,Pricing_Product_Nm__r.Name,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c
                                                        ,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Unit_Qty__c,Pricing_OEM_Account_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Approved_Unit_Qty__c
                                                         from SBQQ__QuoteLine__c where Id in :qlIds order by Pricing_Quote_Line_Number__c];
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:IQR_Prediction_Model_Cred/services/data/v48.0/smartdatadiscovery/predict');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            
            //model ID
            String predictionDefinition = Label.Pricing_Prediction_Model_Id;//'1ORD300000007NqOAI';
            String type = 'RawData';

            List<String> columnNames = new List<String>{'QlWithProduct.Name',
                                                        'Pricing_Unit_Qty__c',
                                                        'Pricing_Approved_Unit_Qty__c',
                                                        'Pricing_ECAP_Price_Dup_Amt__c',
                                                        'Pricing_OEM_Account_Nm__c',
                                                        'QuoteAndQuoteLine.Pricing_Region_Nm__c',
                                                        'QuoteAndQuoteLine.Pricing_Server_Deal_Type_Nm__c',
                                                        'QuoteAndQuoteLine.Pricing_Bid_Dt__c',
                                                        'QuoteAndQuoteLine.Pricing_Intel_Account_Exec_Email_Txt__c',
                                                        'QlWithProductAndCompProd.Name',
                                                        'CompetitorProductNameAndProductName'};
    
            // List to store row data
            List<List<Object>> rows = new List<List<Object>>();

            for(SBQQ__QuoteLine__c qli:quoteLineList){
                String competitorProductAndProductName = qli.Pricing_Competetor_Product__r.Name+','+qli.Pricing_Product_Nm__r.Name;
                List<Object> row = new List<Object>{qli.Pricing_Product_Nm__r.Name,
                                                    qli.Pricing_Unit_Qty__c,
                    								qli.Pricing_Approved_Unit_Qty__c,
                                                    qli.Pricing_ECAP_Price_Amt__c,
                                                    qli.Pricing_OEM_Account_Nm__c,
                                                    qli.SBQQ__Quote__r.Pricing_Region_Nm__c,
                                                    qli.SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,
                                                    qli.SBQQ__Quote__r.Pricing_Bid_Dt__c,
                                                    qli.SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c,
                    								qli.Pricing_Competetor_Product__r.Name,
                                                    competitorProductAndProductName
                };
                rows.add(row);
            }

            EinsteinDiscoveryWrapper requestWrapper = new EinsteinDiscoveryWrapper(predictionDefinition,type, columnNames, rows);

            String jsonBody = JSON.serialize(requestWrapper);
            
            request.setBody(jsonBody);
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 201){
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> predictionObjects = (List<Object>) responseMap.get('predictions');
                List<Map<String, Object>> predictions = new List<Map<String, Object>>();
                for (Object obj : predictionObjects) {
                    predictions.add((Map<String, Object>) obj);
                }

                for (Integer i = 0; i < quoteLineList.size(); i++) {
                    SBQQ__QuoteLine__c ql = quoteLineList[i];
                    Map<String, Object> predictionDetails = (Map<String, Object>) predictions[i].get('prediction');
                    
                    Decimal wonPrediction = (Decimal) predictionDetails.get('total');
                    ql.Pricing_QuoteLine_Won_Prediction__c = wonPrediction;
                }
                if(quoteLineList.size() > 0){
                    SBQQ.TriggerControl.disable();
                   update quoteLineList;
                   SBQQ.TriggerControl.enable();
                }
            }  
        }
        catch(Exception ex){
        Pricing_Tender_Utility.logError(ex);
        }
    }

    //Wrapper
    public class EinsteinDiscoveryWrapper {
        public String predictionDefinition;
        public String type;
        public List<String> columnNames;
        public List<List<Object>> rows;
    
        // Constructor
        public EinsteinDiscoveryWrapper(String modelId,String type, List<String> columnNames, List<List<Object>> rows) {
            this.predictionDefinition = modelId;
            this.type = type;
            this.columnNames = columnNames;
            this.rows = rows;
        }
    }
}