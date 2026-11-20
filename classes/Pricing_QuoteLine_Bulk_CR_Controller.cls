/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QuoteLine_Bulk_CR_Controller {

     @AuraEnabled
    public static List<SBQQ__QuoteLine__c>  getQuoteLineDetails(Id quoteId){
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,SBQQ__Quote__c,Pricing_Quote_Line_Number__c,Pricing_Request_Discount_Unit_Price_qty__c,Pricing_New_Quantity_qty__c,Pricing_Product_Nm__r.Id,Pricing_Product_Nm__r.Name,Pricing_Req_Discounted_Unit_Price__c,Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,
                                                Pricing_ECAP_Price_Amt__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Payable_Quantity__c,Pricing_Backdate_Reason_Txt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Program_Type_Nm__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Name,
                                                Pricing_Group_Type_nm__c,Pricing_Market_Segment_values_Nm__c,Pricing_Market_Segment_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_Discount_Pct__c,Pricing_Deal_RFQ_Id__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,Pricing_Start_Date_dt__c,Pricing_End_Date_dt__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,
                                                Pricing_Competetor_Product__c,Pricing_Competetor_Product__r.Name,Pricing_Comp_Product_Txt__c,Pricing_Processor_Number_Nm__c,Pricing_Family_Name_Nm__c,pricing_TDP__c,Pricing_DealProduct_Nm__c,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,Pricing_Workload_Nm__c,Pricing_Server_Deal_Type_Nm__c,Pricing_EndCustomer_Nm__c,Pricing_Unit_Qty__c,
                                                Pricing_Manager__c,Pricing_Manager__r.Name,Pricing_Additional_T_C_s_Txt__c,Pricing_RegionQL_Nm__c,Pricing_Additional_Comments_Txt__c,Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c,Pricing_Deal_Description__c,SBQQ__Quote__r.SBQQ__Account__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Segment__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Region__c,Pricing_Consumption_Country__c
                                                FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND Pricing_Status_Nm__c =: Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview AND Pricing_Other_Product_Nm__c = '' AND
                                                Pricing_Deal_RFQ_Id__c != '' and Pricing_Deal_RFQ_Status_Nm__c = '' and Pricing_Integration_Status_Nm__c = '' AND Pricing_Reference_Quote_Line_Nbr__c != ''
                                                ORDER By Pricing_Quote_Line_Number__c];
        //Pricing_Deal_RFQ_Id__c != '' and
        
        return quoteLineList;
    }
}