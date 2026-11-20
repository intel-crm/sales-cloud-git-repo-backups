/**
* @description       : Batch is created to generate the MyDeals payload and send request to MyDeals
* @author            : Rahul Maindalkar
* @group             : 
* @last modified on  : 05-08-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_QLBulkCRSendPayloadBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    public Map<Id, String> ResultMap = New Map<Id, String>(); 
    public Set<Id> newQLData = New Set<Id>();
    public List<SBQQ__QuoteLine__c> qlToUpdate = New List<SBQQ__QuoteLine__c>();
    // Constructor to get QL set to create payload
    public Pricing_QLBulkCRSendPayloadBatch(Set<Id> newQLSet){
        newQLData.addAll(newQLSet);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, 
                                         SBQQ__Quote__r.Name, Pricing_EndCustomer_Nm__c, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,
                                         Pricing_Reference_Quote_Line_Nbr__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,
                                         SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,
                                         SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,
                                         Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,
                                         Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,
                                         Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,
                                         Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                         Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Project_Nm__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, 
                                         Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,Pricing_Consumption_Region__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Country__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Segment__c,
                                         Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Payable_Quantity__c,SBQQ__Product__r.Core_Item_Id__c,
                                         SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,
                                         Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Competetor_Product__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,
                                         SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_End_Customer__c,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c,
                                         SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c,Pricing_Program_Type_Nm__c,
                                         SBQQ__Quote__r.Pricing_Is_Sanctioned__c,Pricing_Account_Division_Nm__c,Pricing_Comp_Product_Txt__c,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,
                                                                                                                                             Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE Id IN : newQLData AND ((Pricing_Product_Nm__r.Name = 'Write In Product' AND Pricing_Deal_RFQ_Id__c != null) OR (Pricing_Product_Nm__r.Name != 'Write In Product')) order by SBQQ__Quote__c]);      
    }    

    /**
    * @description Calling helper class method to generate the MyDeals payload and send request to MyDeals 
    * @author Rahul Maindalkar | 08-24-2022 
    * @param bc 
    * @param quoteLine 
    **/       
    public void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> quoteLine){
        String groupByQuote=Label.Pricing_Bulk_CR_GroupByQuote;  //Variable for group by quotes functionality
        // Calling helper class method to generate the MyDeals payload and send request to MyDeals
        ResultMap.putAll(Pricing_QLBulkCRSendPayloadHelper.createpayload(newQLData, quoteLine, 'Update', Boolean.valueOf(groupByQuote)));
    } 
    
    public void finish(database.BatchableContext bc) {
    }    
    
}