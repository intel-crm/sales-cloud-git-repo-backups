/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-30-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QuoteLine_Bulk_CR_Controller {

     @AuraEnabled
    public static List<SBQQ__QuoteLine__c>  getQuoteLineDetails(Id quoteId){
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,SBQQ__Quote__c,Pricing_Quote_Line_Number__c,Pricing_Request_Discount_Unit_Price_qty__c,Pricing_New_Quantity_qty__c,Pricing_Product_Nm__r.Id,Pricing_Product_Nm__r.Name,Pricing_Req_Discounted_Unit_Price__c,Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,
                                                Pricing_ECAP_Price_Amt__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Payable_Quantity__c,Pricing_Backdate_Reason_Txt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Program_Type_Nm__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Name,
                                                Pricing_Group_Type_nm__c,Pricing_Market_Segment_values_Nm__c,Pricing_Market_Segment_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_Deal_RFQ_Id__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,Pricing_Start_Date_dt__c,Pricing_End_Date_dt__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,
                                                Pricing_Competetor_Product__c,Pricing_Competetor_Product__r.Name,Pricing_Comp_Product_Txt__c,Pricing_Processor_Number_Nm__c,Pricing_Family_Name_Nm__c,pricing_TDP__c,Pricing_DealProduct_Nm__c,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,Pricing_Workload_Nm__c,Pricing_Server_Deal_Type_Nm__c,Pricing_EndCustomer_Nm__c,Pricing_Unit_Qty__c,
                                                Pricing_Manager__c,Pricing_Manager__r.Name,Pricing_Additional_T_C_s_Txt__c,Pricing_RegionQL_Nm__c,Pricing_Additional_Comments_Txt__c,Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c,Pricing_Deal_Description__c,SBQQ__Quote__r.SBQQ__Account__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Segment__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Region__c,Pricing_Consumption_Country__c
                                                FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND Pricing_Status_Nm__c =: Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview AND Pricing_Other_Product_Nm__c = '' AND
                                                Pricing_Deal_RFQ_Id__c != '' and Pricing_Deal_RFQ_Status_Nm__c = '' and Pricing_Integration_Status_Nm__c = '' AND Pricing_Reference_Quote_Line_Nbr__c != ''
                                                ORDER By Pricing_Quote_Line_Number__c];
        //Pricing_Deal_RFQ_Id__c != '' and
        
        return quoteLineList;
    }

   //this method we should not migrate to production as it related to auto approval of ql without sending to mydeals request.
   @InvocableMethod
    //public static void manualInsertIIM(List<SBQQ__QuoteLine__c> quoteLinesList,String action){
    public static void manualInsertIIM(List<List<SBQQ__QuoteLine__c>> qlList){
        List<Id> quoteIds = new List<Id>();
        List<String> endCustomers = new List<String>();
        List<String> endCustomerCountrys = new List<String>();
        String action;
        String tag;
        List<SBQQ__QuoteLine__c> quoteLinesList = new List<SBQQ__QuoteLine__c>();
        Pricing_JSONString jsonString = new Pricing_JSONString();
        Pricing_JSONString.Quote quote = new Pricing_JSONString.Quote();
        Pricing_JSONString.Header header = new Pricing_JSONString.Header();
        Pricing_JSONString.RecordDetails recordDetails = new Pricing_JSONString.RecordDetails();

        system.debug('qlList:'+qlList);
         Set<Id> qlIdSet = new Set<Id>();
            for(List<SBQQ__Quoteline__c> quoteLines: qlList){
                for(SBQQ__QuoteLine__c quoteLine: quoteLines){       
                    qlIdSet.add(quoteLine.Id); 
                }
            }

        if(qlIdSet.size() > 0){
            quoteLinesList = [SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,
                                                       SBQQ__Quote__r.Name, Pricing_EndCustomer_Nm__c, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,
                                                       Pricing_Reference_Quote_Line_Nbr__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,
                                                       SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,
                                                       Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,
                                                       Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,
                                                       Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Workload_Nm__c,Pricing_New_Change_Request_cb__c,
                                                       Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,SBQQ__Product__r.Core_Item_Id__c,
                                                       Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                       Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Project_Nm__c,Pricing_Approved_Unit_Qty__c,Pricing_Payable_Quantity__c,Pricing_Deal_RFQ_Status_Nm__c,Pricing_Consumption_Segment__c,
                                                       Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Country__c,Pricing_Consumption_Region__c,
                                                       Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Name,
                                                       SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,
                                                       Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Competetor_Product__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c,
                                                       SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__c,SBQQ__Quote__r.Pricing_End_Customer__c,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,
                                                       SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c,Pricing_Program_Type_Nm__c,Pricing_SDM_Fast_Track__c,
                                                       SBQQ__Quote__r.Pricing_Is_Sanctioned__c,Pricing_Account_Division_Nm__c,Pricing_Comp_Product_Txt__c,Pricing_Performance_Metric_Nm__c,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,
                                                        Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE 
                                                       Id  In: qlIdSet];

                
        }
       
        
        //Add Quote Details to the JSON
        tag = quoteLinesList[0].SBQQ__Quote__c != null ? quoteLinesList[0].SBQQ__Quote__c + ' - ' : '';
        quote.Id = quoteLinesList[0].SBQQ__Quote__c;
        quote.Name = quoteLinesList[0].SBQQ__Quote__r.Name;
        quote.EndCustomerCountry = quoteLinesList[0].SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c;
        quote.FolioID = quoteLinesList[0].SBQQ__Quote__r.Pricing_Folio_ID_Nm__c == null ? quote.Name.remove('Q-') : quoteLinesList[0].SBQQ__Quote__r.Pricing_Folio_ID_Nm__c;
        quote.DealType = quoteLinesList[0].SBQQ__Quote__r.Pricing_Deal_Type_Nm__c;
        //quote.EndCustomer = quoteLinesList[0].SBQQ__Quote__r.Pricing_Customer_Nm__c;
        quote.ProjectName = quoteLinesList[0].SBQQ__Quote__r.Pricing_Project_Name_Nm__c;
        quote.ShipmentStartDate = quoteLinesList[0].SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c;
        quote.ShipmentEndDate = quoteLinesList[0].SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c;  
        quote.ServerDealType = quoteLinesList[0].Pricing_Server_Deal_Type_Nm__c;
        //quote.MarketSegment = quoteLinesList[0].SBQQ__Quote__r.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? quoteLinesList[0].SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c : null ;
        quote.FolioName = quoteLinesList[0].SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c;
        quote.EndCustomer =quoteLinesList[0].SBQQ__Quote__r.Pricing_Customer_Nm__c; //write in field
        quote.UnifiedEndCustomer = (quoteLinesList[0].SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == true)?quoteLinesList[0].SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name:quoteLinesList[0].SBQQ__Quote__r.Pricing_End_Customer__r.Name; //lookup field
        quote.UnifiedEndCustomerId = (quoteLinesList[0].SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == true)?quoteLinesList[0].SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c:quoteLinesList[0].SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c;
        quote.UnifiedCountryEndCustomerId =quoteLinesList[0].SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c;
        quote.IsUnifiedEndCustomer = quoteLinesList[0].SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c;
        quote.UnifiedEndCustomerGlobalName = quoteLinesList[0].SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Name;
        quote.ComplianceWatchList = quoteLinesList[0].SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c;
        if(!quote.IsUnifiedEndCustomer && header.action != Label.Pricing_Tender_Integration_Header_Action_UpdateStatus){
        quoteIds.add(quote.Id);
        }
        endCustomers.add(quoteLinesList[0].SBQQ__Quote__r.Pricing_End_Customer_Name__c);
        endCustomerCountrys.add(quote.EndCustomerCountry);
        
        Pricing_JSONString.Account acc = new Pricing_JSONString.Account();
        acc.Id = quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Id;
        
        acc.CIMId = Pricing_Tender_Utility.getCIMId(quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Id, quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c);
        //Forming Customer mapping Id and assigning CIM Id (If CIM Id is present we are passing CIM Id, If not there then we are passing Business party id)
        acc.CustomerMappingId = Pricing_Tender_Utility.getCIMId(quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Id, quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c);
        
        acc.Name = quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Name;
        quote.Account = acc;
        Integer count = 0;
        List<Pricing_JSONString.QuoteLine> quoteLineList = new List<Pricing_JSONString.QuoteLine>();          
        for(SBQQ__QuoteLine__c quoteLine : quoteLinesList){
            tag += quoteLine.Id;
            action = quoteLine.Pricing_Deal_RFQ_Id__c == null ? 'Create' : 'Update';
            Pricing_JSONString.QuoteLine quoteLines = new Pricing_JSONString.QuoteLine();
            quoteLines.Id = quoteLine.Id;
            quoteLines.Name = quoteLine.Name;
            quoteLines.ApprovedECAPPrice = quoteLine.Pricing_ECAP_Price_Amt__c;
            quoteLines.MeetCompPrice = quoteLine.Pricing_Meet_Comp_Price_Amt__c;
            quoteLines.ApprovedQuantity = quoteLine.Pricing_Approved_Unit_Qty__c;
            quoteLines.PayableQuantity = header.action == Label.Pricing_Tender_Integration_Header_Action_Update ? quoteLine.Pricing_Payable_Quantity__c : null;
            quoteLines.ApprovedStartDate = quoteLine.Pricing_Approved_Start_Date_Dt__c;
            quoteLines.ApprovedEndDate = quoteLine.Pricing_Approved_End_Date_Dt__c;
            quoteLines.DealRFQId = action == 'create' ? quote.FolioID + count : quoteLine.Pricing_Deal_RFQ_Id__c;
            quoteLines.Status = quoteLine.Pricing_Status_Nm__c;
            quoteLines.IntegrationStatus = quoteLine.Pricing_Integration_Status_Nm__c;
            quoteLines.DealRFQStatus = action == 'Create' ? 'Submitted' : 'Offer';
            quoteLines.QuoteLineNumber = quoteLine.Pricing_Quote_Line_Number__c;
            quoteLines.ReferenceQuoteLineNumber = quoteLine.Pricing_Reference_Quote_Line_Nbr__c;  
            quoteLines.OtherProduct = quoteLine.Pricing_Other_Product_Nm__c;
            quoteLines.ProductType = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? 'Server' :
                                        quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_SSD_Quote ? 'SSD' :
                                        quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_PMem_Quote ? 'PMeM' : 
                                        quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? 'Client' : 
                                        (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU) ? 'Graphics' :
                                        'Ethernet';
            quoteLines.WWID = quoteLine.Pricing_Manager__r.Core_WWID__c;
            quoteLines.ApprovedByInfo = null;
            quoteLines.OtherCompetitorProduct = quoteLine.Pricing_Other_Competitor_Product_Nm__c;
            quoteLines.Region = quoteLine.Pricing_RegionQL_Nm__c;//'Worldwide';
            quoteLines.EndCustomerRegion = quoteLine.SBQQ__Quote__r.Pricing_Region_Nm__c;//quoteLine.Pricing_Region_Nm__c;
            quoteLines.BackdateReason = quoteLine.Pricing_Backdate_Reason_Txt__c;
            quoteLines.BillingEndDate = quoteLine.Pricing_Billing_End_Date_Dt__c;
            quoteLines.BillingStartDate = quoteLine.Pricing_Billing_Start_Date_Dt__c;
            quoteLines.GroupType = quoteLine.Pricing_Group_Type_nm__c;
            //quoteLines.MarketSegment = quoteLine.Pricing_Market_Segment_values_Nm__c;
            quoteLines.MarketSegment = quoteLine.SBQQ__Quote__r.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? quoteLine.SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c: quoteLine.Pricing_Market_Segment_values_Nm__c;
            quoteLines.AdditionalTandC = quoteLine.Pricing_Additional_T_C_s_Txt__c;
            quoteLines.ExcludeAutomation = quoteLine.Pricng_Exclude_from_Price_Approval_Rules__c;
            quoteLines.EffectivePricingStartDate = quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
            quoteLines.DealDescription = (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine) && quoteLine.Pricing_SDM_Fast_Track__c == true && action == 'Create' || action == 'Update' && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null ? (quoteLine.Pricing_Deal_Description__c == null ? (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? Label.Pricing_Tender_Client_Deal_Description_Value : Label.Pricing_Tender_Data_Center_CPU_Deal_Description_Value) : !quoteLine.Pricing_Deal_Description__c.contains(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? Label.Pricing_Tender_Client_Deal_Description_Value : Label.Pricing_Tender_Data_Center_CPU_Deal_Description_Value) ? quoteLine.Pricing_Deal_Description__c + ' ' + (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? Label.Pricing_Tender_Client_Deal_Description_Value : Label.Pricing_Tender_Data_Center_CPU_Deal_Description_Value) : quoteLine.Pricing_Deal_Description__c)  : quoteLine.Pricing_Deal_Description__c;
            quoteLines.CustomerDivision = quoteLine.Pricing_Account_Division_Nm__c != null ? quoteLine.Pricing_Account_Division_Nm__c.replaceAll(';','/') : quoteLine.Pricing_Account_Division_Nm__c;
            //in MyDeals for Consumption Region APJ value is not there.so replacing APJ with APAC,IJKK and sending to MyDeals.
            quoteLines.ConsumptionRegion = !String.isBlank(quoteLine.Pricing_Consumption_Region__c) ? quoteLine.Pricing_Consumption_Region__c.contains('APJ') ? quoteLine.Pricing_Consumption_Region__c.replace('APJ', 'APAC,IJKK').replaceAll(', ',',') : quoteLine.Pricing_Consumption_Region__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Region__c;
            quoteLines.ConsumptionCustomerPlatform = quoteLine.Pricing_Consumption_Platform__c != null ? quoteLine.Pricing_Consumption_Platform__c.replaceAll(', ',',') :  quoteLine.Pricing_Consumption_Platform__c;
            quoteLines.ConsumptionCountry = quoteLine.Pricing_Consumption_Country__c != null ? quoteLine.Pricing_Consumption_Country__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Country__c;
            quoteLines.ConsumptionReportedSalesGeo = quoteLine.Pricing_Consumption_Sale_Geo__c != null ? quoteLine.Pricing_Consumption_Sale_Geo__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Sale_Geo__c;
            quoteLines.ConsumptionCustomerSegment = quoteLine.Pricing_Consumption_Segment__c != null ? quoteLine.Pricing_Consumption_Segment__c.replaceAll(', ',',') :  quoteLine.Pricing_Consumption_Segment__c;
            //quoteLines.ErrorMessages = new List<Pricing_JSONString.ErrorMessages>();
            
            Pricing_JSONString.Product prod = new Pricing_JSONString.Product();

            if(quoteLine.SBQQ__Product__r.Name == Label.Pricing_Tender_Write_In_Product || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU){
                prod = insertEthernetWriteInProd(quoteLine);
            }
            else{
                prod.Id = quoteLine.SBQQ__Product__r.Id;
                prod.Name = quoteLine.SBQQ__Product__r.Name;
                prod.ProductNameEPMID = quoteLine.SBQQ__Product__r.Core_Product_Name_EPM_ID__c;
                prod.ProductLevel = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? 'Processor' :
                                    quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_SSD_Quote ? 'Family' :
                                    quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_PMem_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_NIC_Quote? 'DealProductName' : null;
                prod.Family= quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_SSD_Quote ? quoteLine.SBQQ__Product__r.Core_Family_Nm__c : null;
                prod.DealProductName= quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_PMem_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_NIC_Quote ? quoteLine.SBQQ__Product__r.Core_Forecast_Product_Name__c : null;
                prod.ProcessorNumber= quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? quoteLine.SBQQ__Product__r.Core_Processor_Number_Nm__c : null ;
                prod.MaterialID = null;
            }
            quoteLines.Product = prod;
            
            //Add Competitor Product to JSON
            Pricing_JSONString.CompetitorProduct compProd = new Pricing_JSONString.CompetitorProduct();
            compProd.Id = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || !Label.Pricing_Tender_ExceptionQuoteType.split(',').contains(quoteLine.Pricing_Program_Type_Nm__c) || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU ? quoteLine.Pricing_Competetor_Product__r.Id : null;
            compProd.Name = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || !Label.Pricing_Tender_ExceptionQuoteType.split(',').contains(quoteLine.Pricing_Program_Type_Nm__c) || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU ? (quoteLine.Pricing_Competetor_Product__r.Name == 'Write In Product' ? quoteline.Pricing_Other_Competitor_Product_Nm__c : quoteLine.Pricing_Competetor_Product__r.Name) : quoteLine.Pricing_Comp_Product_Txt__c;
            quoteLines.CompetitorProduct = compProd;
            
            List<Pricing_JSONString.PerformanceMetric> performanceMetric = new List<Pricing_JSONString.PerformanceMetric>();
            if(Label.Pricing_Tender_ExceptionQuoteType.split(',').contains(quoteLine.Pricing_Program_Type_Nm__c))
            {
                Pricing_JSONString.PerformanceMetric perMetric = new Pricing_JSONString.PerformanceMetric();
                perMetric.Id = null;
                perMetric.Name = null;
                perMetric.Weighting = null;
                perMetric.CompSKUPerformance = quoteLine.Pricing_Comp_SKU_Performance_Nbr__c != null ? quoteLine.Pricing_Comp_SKU_Performance_Nbr__c : null;
                perMetric.IntelSKUPerformance = quoteLine.Pricing_Intel_SKU_Performance_Nbr__c != null ? quoteLine.Pricing_Intel_SKU_Performance_Nbr__c : null;
                perMetric.PerformanceMetric = quoteLine.Pricing_Performance_Metric_Nm__c != null ? quoteLine.Pricing_Performance_Metric_Nm__c : null;
                performanceMetric.add(perMetric);
                quoteLines.PerformanceMetric = performanceMetric;
            }
            else{
                for(Pricing_Performance_Metric__c pm : quoteLine.Performance_Metrics__r){
                    //Add Performance Metrics to JSON
                    Pricing_JSONString.PerformanceMetric perMetric = new Pricing_JSONString.PerformanceMetric();
                    perMetric.Id = pm.Id;
                    perMetric.Name = pm.Name;
                    perMetric.CompSKUPerformance = pm.Pricing_Comp_SKU_Performance_Nbr__c;
                    perMetric.IntelSKUPerformance = pm.Pricing_Intel_SKU_Performance_Nbr__c;
                    perMetric.PerformanceMetric = pm.Pricing_Performance_Metric_Nm__c ;
                    perMetric.Weighting = pm.Pricing_Weighting_Pct__c;
                    performanceMetric.add(perMetric);
                    quoteLines.PerformanceMetric = performanceMetric;
                }
            }
            quoteLineList.add(quoteLines);
            count++;
        }


        if(!quoteIds.isEmpty()){		
            List<Pricing_Integration_Staging__c> existingPISRecords = [SELECT Id,Pricing_Payload__c FROM  Pricing_Integration_Staging__c WHERE Pricing_QuoteID__c =: quoteIds[0]];
            List<Pricing_Integration_Staging__c> PISRecordsList = new List<Pricing_Integration_Staging__c>();
            for(Pricing_Integration_Staging__c pis : existingPISRecords){
                if(pis.Pricing_Payload__c.contains(endCustomers[0]) && pis.Pricing_Payload__c.contains(endCustomerCountrys[0])){
                    PISRecordsList.add(pis);
                }
            }
            if(PISRecordsList.isEmpty()) {
                Pricing_UCD_IQR_FormRequest.sendRequestToUCD(quoteIds);
            }
        } 


         //Update the Header Details of the JSON
        header.source_system =  Label.Pricing_Tender_MyDeal_Integration_SystemMyDeal;
        header.target_system =  Label.Pricing_Tender_MyDeal_Integration_SystemTender;
        header.action = action;
        header.xid = Pricing_Tender_Utility.getGUID();

        quote.QuoteLine = quoteLineList;
        recordDetails.Quote = quote;
        jsonString.Header = header;
        jsonString.RecordDetails = recordDetails;
        system.debug('action123:'+action);
        //Serialize the JSON
        String jsonData = JSON.serialize(jsonString);
        
        IIMInsertCreateUpdate(jsonData,header.source_system,header.target_system,tag);
        
    }

    public static void IIMInsertCreateUpdate(String jsonMap,String source_system, String target_system, String tag){
        List<Core_Integration_Inbound_Message__c> iimList = new List<Core_Integration_Inbound_Message__c>();
        Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
                                iim.Core_Payload__c = jsonMap;
                                iim.Core_Message_Type__c = target_system;
                                iim.Core_Processing_Status__c = 'Pending';
                                iim.Core_Error_Code__c = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200;
                                iim.Core_Source_System__c = source_system;
                                iim.Core_Tags__c = tag;
                                iimList.add(iim);
                                system.debug('iimList12'+iimList.size());
        insert iimList;

    }
     /**
    * @description Method to form Ethernet Write In Product payload
    * @author Sandeep Chamate | 10-17-2023 
    * @param quoteLine
    * @return Pricing_JSONString.Product 
    **/
    @TestVisible
    private static Pricing_JSONString.Product insertEthernetWriteInProd(SBQQ__QuoteLine__c quoteLine){
        Pricing_JSONString.Product prod = new Pricing_JSONString.Product();
        prod.Id = quoteLine.SBQQ__Product__r.Name == Label.Pricing_Tender_Write_In_Product ? null : quoteLine.SBQQ__Product__r.Id;
        prod.Name = quoteLine.SBQQ__Product__r.Name == Label.Pricing_Tender_Write_In_Product ? null : quoteLine.SBQQ__Product__r.Name;
        prod.ProductNameEPMID = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU ? quoteLine.SBQQ__Product__r.Core_Product_Name_EPM_ID__c :null;
        prod.ProductLevel = 'MaterialID';
        prod.Family = null;
        prod.DealProductName = null;
        prod.ProcessorNumber = null;
        prod.MaterialID = quoteLine.SBQQ__Product__r.Name == Label.Pricing_Tender_Write_In_Product ? quoteLine.Pricing_Other_Product_Nm__c : quoteLine.SBQQ__Product__r.Core_Item_Id__c;

        return prod;
    }
}