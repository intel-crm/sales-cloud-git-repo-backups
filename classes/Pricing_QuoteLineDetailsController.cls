public without sharing class Pricing_QuoteLineDetailsController {

    @AuraEnabled(cacheable=true)
    public static string getFields() {
        return 'hallo...';
    }

    @AuraEnabled
    public static List < SBQQ__QuoteLine__c > getQuoteLines(Id recordId) {
        String getQuoteLinesQuery;
        getQuoteLinesQuery='SELECT Id, Name ,Pricing_Processor_Number_Nm__c,(SELECT Id FROM Performance_Metrics__r), Pricing_Unit_Qty__c,Pricing_Family_Name_Nm__c,Pricing_DealProduct_Nm__c, SBQQ__ProductName__c, Pricing_Other_Product_Nm__c, Pricing_Quote_Line_Number__c, Pricing_Status_Nm__c,Pricing_Integration_Status_Nm__c, Pricing_Error_Messages__c,Pricing_Program_Type_Nm__c,Pricing_Total_Volume_Qty__c,Pricing_Req_Discounted_Unit_Price__c,Pricing_ECAP_Price_Amt__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_New_Change_Request_cb__c,Pricing_End_Date_dt__c,Pricing_Approved_End_Date_Dt__c'
                            + ' FROM SBQQ__QuoteLine__c'
                            + ' WHERE SBQQ__Quote__c = : recordId and Pricing_Status_Nm__c !=\'' + Label.Pricing_Tender_QuoteLine_Status_Revised +'\''
                            + ' ORDER BY Pricing_Quote_Line_Number__c ASC';
        return Database.query(getQuoteLinesQuery);
    }

    @AuraEnabled(cacheable=true)
    public static List<Pricing_QuoteLine_Details_Accordion__mdt> getFieldSetForProduct(){
        List<Pricing_QuoteLine_Details_Accordion__mdt> listName = [SELECT Id, Fields__c, Quote_Line_Type__c FROM Pricing_QuoteLine_Details_Accordion__mdt];
        return listName;
    }
}