/**
 * @description       : 
 * @author            : Vrushabh
 * @group             : Accenture
 * @last modified on  : 01-16-2025
 * @last modified by  : Vrushabh Uprikar
**/
public with sharing class Pricing_ConsumptionAttr_Controller {
   
    /**
    * @description This method will save Consumption parameter values on Quote Line
    * @author Vrushabh | 11-13-2023
    * @param quoteLineId Quote Line Id, platformValue Consumption platform Value, regionValue Consumption region Value ,countryValue  Consumption country Value, salesGeoValue Consumption SalesGeo Value
    **/
    @AuraEnabled
    public static String saveConsumptionTxtData(String quoteLineId, String platformValue, String regionValue, String countryValue, String salesGeoValue, String segmentValue) {
        String result = 'false';
        try {
            SBQQ__QuoteLine__c qli = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id = :quoteLineId LIMIT 1];

            if (qli != null) {
                qli.Pricing_Consumption_Platform__c = platformValue;
                qli.Pricing_Consumption_Region__c = regionValue;
                qli.Pricing_Consumption_Country__c = countryValue;
                qli.Pricing_Consumption_Sale_Geo__c = salesGeoValue;
                qli.Pricing_Consumption_Segment__c = segmentValue;

                SBQQ.TriggerControl.disable();
                update qli;
                SBQQ.TriggerControl.enable();
                result = 'true';
            }
            return result;
        } catch (Exception errors) {
            Pricing_Tender_Utility.logError(errors);
            return errors.getMessage().contains(Label.Pricing_Tender_No_Access_FSE_Error_Message) ?
                Label.Pricing_Tender_No_Access_FSE_Error_Message : errors.getMessage();
        } finally{
            SBQQ.TriggerControl.enable();
        }
    }

    /**
    * @description this method returns Consumption parameter of Quote Line
    * @author Vrushabh | 11-13-2023
    * @param quoteLineId Quote Line Id
    **/
    @AuraEnabled(cacheable=false)
    public static SBQQ__QuoteLine__c getConsumptionTxtData(String quoteLineId) {
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
    
        if (!String.isBlank(quoteLineId)) {
            quoteLine = [SELECT Id, Pricing_Consumption_Platform__c, Pricing_Consumption_Country__c, Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Region__c,Pricing_Consumption_Segment__c
                         FROM SBQQ__QuoteLine__c
                         WHERE Id = :quoteLineId
                         LIMIT 1];
        }
        quoteLine.Pricing_Consumption_Platform__c = quoteLine.Pricing_Consumption_Platform__c == null ? '' : quoteLine.Pricing_Consumption_Platform__c; 
        quoteLine.Pricing_Consumption_Country__c = quoteLine.Pricing_Consumption_Country__c == null ? '' : quoteLine.Pricing_Consumption_Country__c;
        quoteLine.Pricing_Consumption_Sale_Geo__c = quoteLine.Pricing_Consumption_Sale_Geo__c == null ? '' : quoteLine.Pricing_Consumption_Sale_Geo__c;
        quoteLine.Pricing_Consumption_Region__c = quoteLine.Pricing_Consumption_Region__c == null ? '' : quoteLine.Pricing_Consumption_Region__c;
        quoteLine.Pricing_Consumption_Segment__c = quoteLine.Pricing_Consumption_Segment__c == null ? '' : quoteLine.Pricing_Consumption_Segment__c;
        return quoteLine; 
    }

    /**
    * @description this method retuns Consumption Platform and SalesGeo PickList Values
    * @author Vrushabh | 11-13-2023
    * @param quoteId Quote Id
    **/
    @AuraEnabled(cacheable=true)
    public static List<Pricing_ConsumptionAccountMapping__c> getPlatformAndSalesGeoPickList(String quoteId) {
        List<Pricing_ConsumptionAccountMapping__c> consumptionTypeList = new List<Pricing_ConsumptionAccountMapping__c>();

        if (quoteId != null) {
            consumptionTypeList = [SELECT Name, Pricing_Consumption_Type_Nm__c
                                    FROM Pricing_ConsumptionAccountMapping__c
                                    WHERE Pricing_Active_ind__c = true
                                    AND Pricing_Account_Nm__c IN (
                                        SELECT SBQQ__Account__c
                                        FROM SBQQ__Quote__c
                                        WHERE Id = :quoteId
                                )];                                
        }
        return consumptionTypeList;
    }

 
    /**
    * @description return parent quoteline with consumption param 
    * @author Vrushabh Uprikar | 01-15-2025 
    * @param quotelineId 
    * @return SBQQ__QuoteLine__c 
    **/
    @AuraEnabled(cacheable=true)
    public static SBQQ__QuoteLine__c getParentQuoteLine(String quoteLineId) {
        SBQQ__QuoteLine__c childQuoteLine = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c parentQuoteLines = new SBQQ__QuoteLine__c();
        if (String.isBlank(quoteLineId)) {
            return null; // Return null if the input is blank or null
        }    
        try {
             childQuoteLine = [
                SELECT Id,Pricing_Reference_Quote_Line_Nbr__c 
                FROM SBQQ__QuoteLine__c 
                WHERE Id = :quoteLineId 
                  AND Pricing_New_Change_Request_cb__c = true 
                  AND Pricing_Reference_Quote_Line_Nbr__c != null LIMIT 1
            ];
    
            if (childQuoteLine != null) {
                parentQuoteLines = [
                    SELECT Id, 
                           Pricing_Consumption_Platform__c, 
                           Pricing_Consumption_Country__c, 
                           Pricing_Consumption_Sale_Geo__c,
                           Pricing_Consumption_Region__c,
                           Pricing_Consumption_Segment__c
                    FROM SBQQ__QuoteLine__c
                    WHERE Id = :childQuoteLine.Pricing_Reference_Quote_Line_Nbr__c AND Pricing_Status_Nm__c = 'Won'
                    LIMIT 1
                ];
            }
            return parentQuoteLines;
        } catch (Exception e) {
            System.debug('Error retrieving parent quote line: ' + e.getMessage());
            return null;
        }
    }    
}