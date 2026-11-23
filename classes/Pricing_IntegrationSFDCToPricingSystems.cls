/******************************************************************************************************************************************************
 * Class Name  : Pricing_IntegrationSFDCToPricingSystems
 * Version     : 1.0
 * Created Date: 6-11-2020
 * Modification Log :
 * Developer                     Date                          Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Intel – Mahesh Biradar       6/11/2020                     Initial Creation
 *******************************************************************************************************************************************************/


public without sharing class Pricing_IntegrationSFDCToPricingSystems {
    //Insert OutBound Messages
    Public Map<String,String> writeMessageMap = new Map<String,String>();
    Public Map<Id,Set<Id>> quoteIdToQuoteLineIdSetMap = new Map<Id,Set<Id>>();
    Public Map<Id,String> quoteIdToFolioIdMap = new Map<Id,String>();
    Public Map<Id,String> quoteLineIdToDealIdMap = new Map<Id,String>();
    Public Map<Id,String> quoteLineIdToDealRFQStatusMap = new Map<Id,String>();
    Public Map<Id,SBQQ__QuoteLine__c> quoteLineIdToQLMap = new Map<Id,SBQQ__QuoteLine__c>();
    Public List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
    Public Map<String,SBQQ__QuoteLine__c> quoteLineMap = new Map<String,SBQQ__QuoteLine__c>();
    Public List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
    Public Map<String,SBQQ__Quote__c> quoteMap = new Map<String,SBQQ__Quote__c>();
    public Map<String,String> qlIdToErrorMsgMap = new Map<String,String>();
    //Unified End Customer
    Public Map<Id,SBQQ__Quote__c> quoteIdquoteMap = new Map<Id,SBQQ__Quote__c>(); //Map of Quote Id and quote
    Public Map<Id,Boolean> quoteLineIdToOnHoldMap = new Map<Id,Boolean>();
    Public Set<String> unifiedEndCustAccSet = new Set<String>();  //Set of L1 object lookup id from quote
    Public Map<Id,Pricing_UnifiedEndCustomerAccountMapping__c> quoteIdL1EndCustomerMap = new Map<Id,Pricing_UnifiedEndCustomerAccountMapping__c>(); //Map of Quote Id and L1 Object to insert
    Public Map<Id,Pricing_UnifiedEndCustomerCountryMapping__c> quoteIdL2EndCustCountryMap = new Map<Id,Pricing_UnifiedEndCustomerCountryMapping__c>(); // Map of Quote Id and L2 Object to insert
    Public Map<String,Map<String,String>> l1IdAccountIdsMap = new Map<String,Map<String,String>>(); //Map of L1 Ids and Map of Account Id and L1 Obj Id for Unique Check
    Public Map<String,Map<String,String>> l2Idl1IdOldMap = new Map<String,Map<String,String>>(); //Map of L2 id with inner map of L1 Id and L2Obj Id for Unique Check
    Public List<Core_Integration_Inbound_Message__c> inboundMsgList = new List<Core_Integration_Inbound_Message__c>();
    Public Set<Id> inboundMsgWithErrorsSet = new Set<Id>();
    Public static String err = '';
    Set<Id> quoteLineIdSet = new Set<Id>();
    Map<Id,String> inboundMsgIdToErrorMsg = new Map<Id,String>();
    Map<Id,String> inboundMsgIdToNameMap = new Map<Id,String>();
    Map<String,Id> inboundMsgNumberToRecordIdMap = new Map<String,Id>();
    Map<String,Id> quoteLineNumberToRecordIdMap = new Map<String,Id>();
    //Set<Id> inboundIdOfferFailedSet = new Set<Id>();
    //Map<Id,String> inboundMsgIdToCreatedDateMap = new Map<Id,String>();
    Map<Id,DateTime> inboundMsgIdToCreatedTimeMap = new Map<Id,DateTime>();
    Set<String> warningErrorMessageCodeSet = new Set<String>((Label.Pricing_Warning_Error_Message_Code).split(':'));
    List<Pricing_Quote_Line_Status_Age__c> tptListToUpdate = new List<Pricing_Quote_Line_Status_Age__c>();
    
    public static Map<Id,String> insertQuoteOutBoundMessage(Map<Id,String> quoteLineIdToActionMap,Map<Id,SBQQ__QuoteLine__c> quoteLineMap,String wwid,Boolean isPricingManager,Map<Id,String> qlIdToRuleIdRuleNameMap){
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        Map<Id,String> quoteLineIdToSuccessOrErrorMap = new Map<Id,String>();   //key(QuoteLineId) Value(Error Messages Separated with NewLine)
        Savepoint sp;
        if (!mapFunctionalityNameTriggerExecution.isEmpty() &&
            mapFunctionalityNameTriggerExecution.containsKey('pricingSendOutboundMessagesIQR') &&
        mapFunctionalityNameTriggerExecution.get('pricingSendOutboundMessagesIQR').Core_Active__c){
            
            try{
                sp = Database.setSavepoint();
                Map<String,List<SBQQ__QuoteLine__c>> quoteIdToQuoteLineMap = new Map<String,List<SBQQ__QuoteLine__c>>();    //key(QuoteId + Action) Value(List of QuoteLine with Similar Action)
                //List<Core_Integration_Outbound_Message__c> IOMList = new List<Core_Integration_Outbound_Message__c>();  //List of Integration OutBound Message
                List<Pricing_Integration_Staging__c> IOMList = new List<Pricing_Integration_Staging__c>();  //List of Integration OutBound Message
                List<Id> quoteIds = new List<Id>();
                List<String> endCustomers = new List<String>();
                List<String> endCustomerCountrys = new List<String>();
                for(Id quoteLineId  : quoteLineMap.keySet()){
                    SBQQ__QuoteLine__c quoteLine = quoteLineMap.get(quoteLineId);
                    if(quoteIdToQuoteLineMap.containsKey(''+quoteLine.SBQQ__Quote__c+':'+quoteLineIdToActionMap.get(quoteLine.Id))){
                        quoteIdToQuoteLineMap.get(''+quoteLine.SBQQ__Quote__c+':'+quoteLineIdToActionMap.get(quoteLine.Id)).add(quoteLine);
                    }else{
                        quoteIdToQuoteLineMap.put(''+quoteLine.SBQQ__Quote__c+':'+quoteLineIdToActionMap.get(quoteLine.Id),new List<SBQQ__QuoteLine__c>{quoteLine});
                    }
                }
                for(String quoteIdActionStr : quoteIdToQuoteLineMap.keySet()){
                    List<SBQQ__QuoteLine__c> quoteLinesList = quoteIdToQuoteLineMap.get(quoteIdActionStr);
                    Pricing_JSONString jsonString = new Pricing_JSONString();
                    Pricing_JSONString.Quote quote = new Pricing_JSONString.Quote();
                    Pricing_JSONString.Header header = new Pricing_JSONString.Header();
                    Pricing_JSONString.RecordDetails recordDetails = new Pricing_JSONString.RecordDetails();
                    
                    //Update the Header Details of the JSON
                    header.source_system = Label.Pricing_Tender_MyDeal_Integration_SystemTender;
                    header.target_system = Label.Pricing_Tender_MyDeal_Integration_SystemMyDeal;
                    header.action = (quoteIdActionStr.split(':'))[1];
                    header.xid = Pricing_Tender_Utility.getGUID();
                    
                    //quote.Id = quoteLinesList[0].SBQQ__Quote__r.Id;
                    //Add Quote Details to the JSON
                    quote.Id = quoteLinesList[0].SBQQ__Quote__c;
                    quote.Name = quoteLinesList[0].SBQQ__Quote__r.Name;
                    quote.EndCustomerCountry = quoteLinesList[0].SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c;
                    quote.FolioID = quoteLinesList[0].SBQQ__Quote__r.Pricing_Folio_ID_Nm__c;
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
                    quote.AIHostNode =quoteLinesList[0].SBQQ__Quote__r.Pricing_AI_Host_Node_cb__c;
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
                    
                    List<Pricing_JSONString.QuoteLine> quoteLineList = new List<Pricing_JSONString.QuoteLine>();
                    for(SBQQ__QuoteLine__c quoteLine : quoteLinesList){
                        Boolean isRollback=(quoteLineIdToActionMap.get(quoteLine.Id) == 'Rollback');
                        Pricing_JSONString.QuoteLine quoteLines = new Pricing_JSONString.QuoteLine();
                        quoteLines.Id = quoteLine.Id;
                        quoteLines.Name = quoteLine.Name;
                        quoteLines.ApprovedECAPPrice = isRollback?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c:quoteLine.Pricing_ECAP_Price_Amt__c;
                        quoteLines.MeetCompPrice = isRollback?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Meet_Comp_Price_Amt__c:quoteLine.Pricing_Meet_Comp_Price_Amt__c;
                        quoteLines.ApprovedQuantity = isRollback?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Unit_Qty__c:quoteLine.Pricing_Approved_Unit_Qty__c;
                        quoteLines.PayableQuantity = header.action == Label.Pricing_Tender_Integration_Header_Action_Update ? quoteLine.Pricing_Payable_Quantity__c : null;
                        quoteLines.ApprovedStartDate = isRollback?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c:quoteLine.Pricing_Approved_Start_Date_Dt__c;
                        quoteLines.ApprovedEndDate = isRollback?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c:quoteLine.Pricing_Approved_End_Date_Dt__c;
                        quoteLines.DealRFQId = quoteLine.Pricing_Deal_RFQ_Id__c;
                        quoteLines.Status = quoteLine.Pricing_Status_Nm__c;
                        quoteLines.IntegrationStatus = quoteLine.Pricing_Integration_Status_Nm__c;
                        quoteLines.DealRFQStatus = quoteLine.Pricing_Deal_RFQ_Status_Nm__c;
                        quoteLines.QuoteLineNumber = quoteLine.Pricing_Quote_Line_Number__c;
                        quoteLines.ReferenceQuoteLineNumber = quoteLine.Pricing_Reference_Quote_Line_Nbr__c;
                        quoteLines.OtherProduct = quoteLine.Pricing_Other_Product_Nm__c;
                        quoteLines.ProductType = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? 'Server' :
                            quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_SSD_Quote ? 'SSD' :
                            quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_PMem_Quote ? 'PMeM' :
                            quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? 'Client' :
                            (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU) ? 'Graphics' :
                            'Ethernet';
                        quoteLines.WWID = isPricingManager ? wwid : quoteLine.Pricing_Manager__r.Core_WWID__c;
                        quoteLines.ApprovedByInfo = !qlIdToRuleIdRuleNameMap.isEmpty()?qlIdToRuleIdRuleNameMap.get(quoteLine.Id):null;
                        quoteLines.OtherCompetitorProduct = quoteLine.Pricing_Other_Competitor_Product_Nm__c;
                        quoteLines.Region = quoteLine.Pricing_RegionQL_Nm__c;//'Worldwide';
                        quoteLines.EndCustomerRegion = quoteLine.SBQQ__Quote__r.Pricing_Region_Nm__c;//quoteLine.Pricing_Region_Nm__c;
                        quoteLines.BackdateReason = isRollback?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Backdate_Reason_Txt__c:quoteLine.Pricing_Backdate_Reason_Txt__c;
                        quoteLines.BillingEndDate = isRollback?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Billing_End_Date_Dt__c:quoteLine.Pricing_Billing_End_Date_Dt__c;
                        quoteLines.BillingStartDate = isRollback?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Billing_Start_Date_Dt__c:quoteLine.Pricing_Billing_Start_Date_Dt__c;
                        quoteLines.GroupType = quoteLine.Pricing_Group_Type_nm__c;
                        //quoteLines.MarketSegment = quoteLine.Pricing_Market_Segment_values_Nm__c;
                        quoteLines.MarketSegment = quoteLine.SBQQ__Quote__r.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? quoteLine.SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c: quoteLine.Pricing_Market_Segment_values_Nm__c;
                        quoteLines.AdditionalTandC = isRollback?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Additional_T_C_s_Txt__c:quoteLine.Pricing_Additional_T_C_s_Txt__c;
                        quoteLines.ExcludeAutomation = quoteLine.Pricng_Exclude_from_Price_Approval_Rules__c;
                        quoteLines.EffectivePricingStartDate = isRollback?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c:quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
                        quoteLines.DealDescription = (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine) && quoteLine.Pricing_SDM_Fast_Track__c == true && (quoteLineIdToActionMap.get(quoteLine.Id) == 'Create' || (quoteLineIdToActionMap.get(quoteLine.Id) == 'Update' && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null)) ? (quoteLine.Pricing_Deal_Description__c == null ? (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? Label.Pricing_Tender_Client_Deal_Description_Value : Label.Pricing_Tender_Data_Center_CPU_Deal_Description_Value) : !quoteLine.Pricing_Deal_Description__c.contains(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? Label.Pricing_Tender_Client_Deal_Description_Value : Label.Pricing_Tender_Data_Center_CPU_Deal_Description_Value) ? quoteLine.Pricing_Deal_Description__c + ' ' + (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? Label.Pricing_Tender_Client_Deal_Description_Value : Label.Pricing_Tender_Data_Center_CPU_Deal_Description_Value) : quoteLine.Pricing_Deal_Description__c) : isRollback?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Deal_Description__c : quoteLine.Pricing_Deal_Description__c;
                        quoteLines.CustomerDivision = quoteLine.Pricing_Account_Division_Nm__c != null ? quoteLine.Pricing_Account_Division_Nm__c.replaceAll(';','/') : quoteLine.Pricing_Account_Division_Nm__c;
                        //in MyDeals for Consumption Region APJ value is not there.so replacing APJ with APAC,IJKK and sending to MyDeals.
                        quoteLines.ConsumptionRegion = !String.isBlank(quoteLine.Pricing_Consumption_Region__c) ? quoteLine.Pricing_Consumption_Region__c.contains('APJ') ? quoteLine.Pricing_Consumption_Region__c.replace('APJ', 'APAC,IJKK').replaceAll(', ',',') : quoteLine.Pricing_Consumption_Region__c.replaceAll(', ',',') : (isRollback && !String.isBlank(quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Region__c))?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Region__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Region__c;
                        quoteLines.ConsumptionCustomerPlatform = quoteLine.Pricing_Consumption_Platform__c != null ? quoteLine.Pricing_Consumption_Platform__c.replaceAll(', ',',') : (isRollback && !String.isBlank(quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Platform__c))?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Platform__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Platform__c;
                        quoteLines.ConsumptionCountry = quoteLine.Pricing_Consumption_Country__c != null ? quoteLine.Pricing_Consumption_Country__c.replaceAll(', ',',') : (isRollback && !String.isBlank(quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Country__c))?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Country__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Country__c;
                        quoteLines.ConsumptionReportedSalesGeo = quoteLine.Pricing_Consumption_Sale_Geo__c != null ? quoteLine.Pricing_Consumption_Sale_Geo__c.replaceAll(', ',',') : (isRollback && !String.isBlank(quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Sale_Geo__c))?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Sale_Geo__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Sale_Geo__c;
                        quoteLines.ConsumptionCustomerSegment = quoteLine.Pricing_Consumption_Segment__c != null ? quoteLine.Pricing_Consumption_Segment__c.replaceAll(', ',',') : (isRollback && !String.isBlank(quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Segment__c))?quoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Consumption_Segment__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Segment__c;
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
                        
                    }
                    quote.QuoteLine = quoteLineList;
                    recordDetails.Quote = quote;
                    jsonString.Header = header;
                    jsonString.RecordDetails = recordDetails;
                    
                    //Serialize the JSON
                    String jsonData = JSON.serialize(jsonString);
                    //Pricing_Integration_Staging__c
                    /*
                    IOMList.add(new Core_Integration_Outbound_Message__c(Core_MessageType__c = Label.Pricing_Tender_MyDeal_Integration_SystemTender,
                    Core_Payload__c = jsonData,
                    Core_Tags__c = Label.Pricing_Tender_MyDeal_Integration_SystemTender));
                    Pricing_SObject__c='Quote'));
                     */
                    IOMList.add(new Pricing_Integration_Staging__c(Pricing_Message_Type__c = Label.Pricing_Tender_MyDeal_Integration_SystemTender,
                    Pricing_Payload__c = jsonData,
                    Pricing_SObjectId__c= quoteLinesList[0].SBQQ__Quote__c+ ' ' + '-' + ' ' +quoteLinesList[0].id,
                    Pricing_SObject__c='Quote - Quote Line'));
                    
                }
                //Database.SaveResult[] srList;
                List<SBQQ__QuoteLine__c> quoteLineToUpdate = new List<SBQQ__QuoteLine__c>();
                if(!IOMList.isEmpty()){
                    try {
                        for(Pricing_Integration_Staging__c IOM : IOMList){
                            //Pricing_Integration_Staging__c IOM = IOMList[i];
                            Pricing_JSONString JSONVar = (Pricing_JSONString)System.JSON.deserialize(IOM.Pricing_Payload__c, Pricing_JSONString.class);
                            Id quoteId = JSONVar.RecordDetails.Quote.Id;
                            String action = JSONVar.Header.action;
                            for(SBQQ__QuoteLine__c updateQuoteLine : quoteIdToQuoteLineMap.get(''+quoteId+':'+action)){
                                updateQuoteLine.Pricing_Integration_Status_Nm__c = Label.Pricing_Tender_MyDeal_Integration_Status_Pending;
                                updateQuoteLine.Pricing_Create_Deal_Actor_Id__c = Userinfo.getUserId();
                                updateQuoteLine.Pricing_Integration_Time_Stamp__c = System.now();
                                updateQuoteLine.Pricing_Previous_MyDeal_Action_Nm__c = action;
                                updateQuoteLine.Pricing_Price_Rule_Error_Message__c = null;
                                updateQuoteLine.Pricing_Deal_Description__c = (updateQuoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || updateQuoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine) && updateQuoteLine.Pricing_SDM_Fast_Track__c == true && (quoteLineIdToActionMap.get(updateQuoteLine.Id) == 'Create' || (quoteLineIdToActionMap.get(updateQuoteLine.Id) == 'Update' && updateQuoteLine.Pricing_Reference_Quote_Line_Nbr__c == null)) ? (updateQuoteLine.Pricing_Deal_Description__c == null ? (updateQuoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? Label.Pricing_Tender_Client_Deal_Description_Value : Label.Pricing_Tender_Data_Center_CPU_Deal_Description_Value) : !updateQuoteLine.Pricing_Deal_Description__c.contains(updateQuoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? Label.Pricing_Tender_Client_Deal_Description_Value : Label.Pricing_Tender_Data_Center_CPU_Deal_Description_Value) ? updateQuoteLine.Pricing_Deal_Description__c + ' ' + (updateQuoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? Label.Pricing_Tender_Client_Deal_Description_Value : Label.Pricing_Tender_Data_Center_CPU_Deal_Description_Value) : updateQuoteLine.Pricing_Deal_Description__c) : updateQuoteLine.Pricing_Deal_Description__c;
                                if(action == Label.Pricing_Tender_Integration_Header_Action_Create){
                                    updateQuoteLine.Pricing_Manager__c = !QuoteLineBusinessLogic.isAutoApproveReject ? userInfo.getUserId() : updateQuoteLine.Pricing_Manager__c;
                                }else if(action == Label.Pricing_Tender_Integration_Header_Action_Update
                                && updateQuoteLine.Pricing_Reference_Quote_Line_Nbr__c != null){
                                    updateQuoteLine.Pricing_Manager__c = userInfo.getUserId();
                                }
                                quoteLineToUpdate.add(updateQuoteLine);
                                quoteLineIdToSuccessOrErrorMap.put(updateQuoteLine.Id,'Success');
                            }
                        }
                        SBQQ.TriggerControl.disable();
                        update quoteLineToUpdate;
                        SBQQ.TriggerControl.enable();
                        try{
                            insertPISRecord(IOMList, false);
                        }catch(Exception exp){
                            insertPISRecord(IOMList, true);
                        }
                    }catch(Exception exp){
                        insertPISRecord(IOMList, true);
                    }
                    finally{
                        SBQQ.TriggerControl.enable();
                    }
                    
                    
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
                system.debug('QuoteLineBusinessLogic.isAutoApproveReject:'+QuoteLineBusinessLogic.isAutoApproveReject);
                
            }catch(DmlException e) {
                //String retMsg = Pricing_Tender_Utility.getExceptionMessage(e);
                Database.RollBack(sp);
                Pricing_Tender_Utility.logError(e);
                quoteLineIdToSuccessOrErrorMap.clear();
                if(!quoteLineIdToActionMap.isEmpty()){
                    for(Id quoteLineId : quoteLineIdToActionMap.keySet()){
                        /*if(retMsg != null){
                            quoteLineIdToSuccessOrErrorMap.put(quoteLineId, retMsg);
                        }*/
                        //else{
                            quoteLineIdToSuccessOrErrorMap.put(quoteLineId,Label.Pricing_Integration_Outbound_Failure_Message);
                        //}
                    }
                }
            } //To Handle All or None Scenario we are Clearing
        }else{
            for(Id quoteLineId : quoteLineIdToActionMap.keySet()){
                quoteLineIdToSuccessOrErrorMap.put(quoteLineId,Label.Pricing_Integration_Outbound_Failure_Message);
            }
        }
        return quoteLineIdToSuccessOrErrorMap;
    }
    private static void insertPISRecord(List<Pricing_Integration_Staging__c> pisRecs, boolean handleException){
        if(pisRecs.size() > 0){
            /*if(handleException){
                for(Pricing_Integration_Staging__c pisRec : pisRecs){
                    pisRec.Pricing_Status__c = 'Failed';
                    pisRec.Pricing_Retry_Number__c = 1;
                }
            }*/
            insert pisRecs;
        }
    }
    
    
    /*****************************************************************************************************
    Method Name:        getJSONPayload
        @parameters:        action: Create/Update/UpdateStatus
    Description:        Send data to MyDeals, inserts payload data to Integration Outbound Messages,
    mulesfort will pick and send it to MyDeals
        Added By:           Mahesh - 6/11/2020
         ******************************************************************************************************/
    public void processUpdateOrCreate(Pricing_JSONString.Quote quoteDetail,SBQQ__Quote__c quote,String writeMsg,List<Pricing_JSONString.QuoteLine> jsonQuoteLineList,Id inboundMsgId,String action){
        Boolean isQuoteValid = true;
        Boolean onHoldQuote = false;
        String writeMessage = '';
        
        writeMessage = appendErrorMsg(writeMessage,action+' Request Recieved');
        if(quoteMap.containsKey(quoteDetail.Id)){
            quote = quoteMap.get(quoteDetail.Id);
        }
        if(String.isNotBlank(quoteDetail.FolioID)
            && quoteIdToFolioIdMap.containsKey(quoteDetail.Id)
            && (quoteDetail.FolioID.isNumeric())
        && (integer.valueof(quoteDetail.FolioID) >= 0)){
            quote.Pricing_Folio_ID_Nm__c = quoteDetail.FolioID;
            writeMessage = appendErrorMsg(writeMessage,'FolioId is : '+quoteDetail.FolioID);
        }
        if(action == Label.Pricing_Tender_Integration_Header_Action_Update && String.isBlank(quoteDetail.FolioID)){
            qlIdToErrorMsgMap.put(quoteDetail.Id,'FolioId is null');
            appendErrorMsgToMap(inboundMsgId,'FolioId is null');
        }
        if(String.isBlank(quoteDetail.Id)){
            qlIdToErrorMsgMap.put(quoteDetail.Id,'QuoteId is null');
            appendErrorMsgToMap(inboundMsgId,'QuoteId is null');
            isQuoteValid = false;
        }else if(!quoteIdToFolioIdMap.containsKey(quoteDetail.Id) ){
            qlIdToErrorMsgMap.put(quoteDetail.Id,'QuoteId is Invalid');
            appendErrorMsgToMap(inboundMsgId,'QuoteId is Invalid');
            isQuoteValid = false;
            
        }else if(action == Label.Pricing_Tender_Integration_Header_Action_Update && quoteIdToFolioIdMap.get(quoteDetail.Id) != quoteDetail.FolioID ){
            qlIdToErrorMsgMap.put(quoteDetail.Id,quoteDetail.FolioID+' does not match with '+quoteIdToFolioIdMap.get(quoteDetail.Id));
            appendErrorMsgToMap(inboundMsgId,'FolioId : '+quoteDetail.FolioID+' does not match with '+quoteIdToFolioIdMap.get(quoteDetail.Id));
        }
        
        if(String.isNotBlank(quoteDetail.Id)){
            if(quoteIdquoteMap.get(quoteDetail.Id).Pricing_On_Hold_Cb__c) {
                onHoldQuote = true;
            }
        }
        if(!jsonQuoteLineList.isEmpty()){
            for(Pricing_JSONString.QuoteLine jsonQuoteLine : jsonQuoteLineList){
                
                //writeMessage = '';
                SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                if(quoteLineMap.containsKey(quoteLine.Id)){
                    quoteLine = quoteLineMap.get(quoteLine.Id);
                }
                
                if(String.isBlank(jsonQuoteLine.DealRFQId)){
                    qlIdToErrorMsgMap.put(jsonQuoteLine.Id,'DealId is null');
                    appendErrorMsgToMap(jsonQuoteLine.id,'DealId is null');
                }
                
                if(String.isBlank(jsonQuoteLine.Id)){
                    qlIdToErrorMsgMap.put('QuoteLineId is null','QuoteLineId is null');
                    appendErrorMsgToMap(inboundMsgId,'QuoteLineId is null'); //CH
                }else if(!quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id)){
                    qlIdToErrorMsgMap.put(jsonQuoteLine.Id,'QuoteLineId : '+jsonQuoteLine.Id+' is Invalid');
                    appendErrorMsgToMap(inboundMsgId,'QuoteLineId : '+jsonQuoteLine.Id+' is Invalid'); //CH
                }else if(action == Label.Pricing_Tender_Integration_Header_Action_Update && quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id)
                && quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Deal_RFQ_Id__c != jsonQuoteLine.DealRFQId){
                    qlIdToErrorMsgMap.put(jsonQuoteLine.Id,'QuoteLineId : '+'QuoteLineId :  '+jsonQuoteLine.Id+' Deal Id : '+jsonQuoteLine.DealRFQId+' does not Match with '+quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Deal_RFQ_Id__c);
                    appendErrorMsgToMap(jsonQuoteLine.id,'QuoteLineId :  '+jsonQuoteLine.Id+' Deal Id : '+jsonQuoteLine.DealRFQId+' does not Match with '+quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Deal_RFQ_Id__c);
                }
                
                if(onHoldQuote && !(jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_Integration_Deal_Status_Won || jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_QuoteLine_Status_Lost || jsonQuoteLine.ErrorMessages != null)) {
                    qlIdToErrorMsgMap.put(jsonQuoteLine.Id,'Quote is on Hold.');
                    appendErrorMsgToMap(jsonQuoteLine.id,'Quote is on Hold.');
                }
                
                if(String.isNotBlank(quoteDetail.Id) && !qlIdToErrorMsgMap.containsKey(quoteDetail.Id) && validateInbound(action,jsonQuoteLine,inboundMsgId,'')){
                    
                    if(String.isNotBlank(jsonQuoteLine.Id) && !qlIdToErrorMsgMap.containsKey(jsonQuoteLine.id)){
                        if(String.isNotBlank(jsonQuoteLine.DealRFQId)
                            && (jsonQuoteLine.DealRFQId.isNumeric())
                            && (integer.valueof(jsonQuoteLine.DealRFQId) >= 0)
                            && quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id)){
                                
                                quoteLine.Pricing_Deal_RFQ_Id__c = jsonQuoteLine.DealRFQId;
                                writeMessage = appendErrorMsg(writeMessage,'DealId is '+jsonQuoteLine.DealRFQId);
                            }
                            if(String.isNotBlank(jsonQuoteLine.DealRFQStatus) && action != Label.Pricing_Tender_QuoteLine_RollBack){
                                quoteLine.Pricing_Deal_RFQ_Status_Nm__c = jsonQuoteLine.DealRFQStatus;
                                if(quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id) && quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Deal_RFQ_Status_Nm__c != jsonQuoteLine.DealRFQStatus){
                                    if((jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_Integration_Deal_Status_offer && quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Approved) || jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_QuoteLine_Edit_DealRFQStatus){
                                        String status = (jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_Integration_Deal_Status_offer)?Label.Pricing_Tender_QuoteLine_Status_Approved:jsonQuoteLine.DealRFQStatus;
                                        tptListToUpdate.addAll(QuoteLineBusinessLogic.getTPTRecordsToUpdate(new List<SBQQ__QuoteLine__c>{quoteLineIdToQLMap.get(jsonQuoteLine.Id)},null,false,true,
                                                                                            'DPM',jsonQuoteLine.ApprovedByInfo,DateTime.now(),status));
                                    }
                                    if(jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_QuoteLine_ReadOnly_DealRFQStatus){
                                        tptListToUpdate.addAll(QuoteLineBusinessLogic.getTPTRecordsToUpdate(new List<SBQQ__QuoteLine__c>{quoteLineIdToQLMap.get(jsonQuoteLine.Id)},null,false,true,
                                                                                            'RPM',(quoteLineIdToQLMap.get(jsonQuoteLine.Id)).Pricing_Create_Deal_Actor_Id__r.Name,DateTime.now(),jsonQuoteLine.DealRFQStatus));
                                    }
                                }
                                if(jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_Integration_Deal_Status_offer){
                                    quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
                                    writeMessage = appendErrorMsg(writeMessage,' QuoteLine Status is : '+quoteLine.Pricing_Status_Nm__c);
                                }
                                
                                if(jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_Integration_Deal_Status_Won &&
                                quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id) && quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Reference_Quote_Line_Nbr__c != null){
                                    quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Won;
                                    writeMessage = appendErrorMsg(writeMessage,' QuoteLine Status is : '+quoteLine.Pricing_Status_Nm__c);
                                }
                            }
                            else if((jsonQuoteLine.ErrorMessages == null || jsonQuoteLine.ErrorMessages.isEmpty()) && action == Label.Pricing_Tender_QuoteLine_RollBack){
                                quoteLine.Pricing_Deal_RFQ_Status_Nm__c = '';
                                quoteLine.Pricing_Integration_Status_Nm__c = '';
                                tptListToUpdate.addAll(QuoteLineBusinessLogic.getTPTRecordsToUpdate(new List<SBQQ__QuoteLine__c>{quoteLineIdToQLMap.get(jsonQuoteLine.Id)},null,false,true,
                                                                                            'RPM',(quoteLineIdToQLMap.get(jsonQuoteLine.Id)).Pricing_Create_Deal_Actor_Id__r.Name,DateTime.now(),''));                           
                            }
                        }
                        else{
                            writeMessage = '';
                        }
                        
                        if(!quoteLineMap.containsKey(quoteLine.Id)){
                            quoteLine.Id = jsonQuoteLine.Id;
                            if(quoteLineIdToQLMap.containsKey(quoteLine.Id) && 
                            quoteLineIdToQLMap.get(quoteLine.Id).Pricing_Status_Nm__c != Label.Pricing_Revised_Status_Label){
                                quoteLineMap.put(quoteLine.Id,quoteLine);
                            }
                        }
                        if(jsonQuoteLine.ErrorMessages != null){
                            quoteLine = updateErrorFieldOnQuoteLine(quoteLine,jsonQuoteLine);
                        }else{
                            quoteLine.Pricing_Error_Messages__c = '';
                        }
                        if(!quoteMap.containsKey(quote.Id) && isQuoteValid){
                            quote.Id = quoteDetail.Id;
                            if(quoteLineIdToQLMap.containsKey(quoteLine.Id) && 
                            quoteLineIdToQLMap.get(quoteLine.Id).Pricing_Status_Nm__c != Label.Pricing_Revised_Status_Label){
                                quoteMap.put(quote.Id,quote);
                            }
                        }
                        if(jsonQuoteLine.ErrorMessages != null){
                            for(Pricing_JSONString.ErrorMessages errorStr : jsonQuoteLine.ErrorMessages){
                                if(!warningErrorMessageCodeSet.contains(errorStr.code)){
                                    if(String.isNotBlank(errorStr.code)){
                                        qlIdToErrorMsgMap.put(jsonQuoteLine.Id,errorStr.code);
                                        appendErrorMsgToMap(jsonQuoteLine.id,errorStr.code);
                                    }
                                    if(String.isNotBlank(errorStr.Message)){
                                        qlIdToErrorMsgMap.put(jsonQuoteLine.Id,errorStr.Message);
                                        appendErrorMsgToMap(jsonQuoteLine.id,errorStr.Message);
                                    }
                                }
                            }
                        }

                        quoteLine.Pricing_Integration_Status_Nm__c = action == Label.Pricing_Tender_QuoteLine_RollBack ? '' : ((String.isBlank(jsonQuoteLine.Id) || (qlIdToErrorMsgMap.containsKey(jsonQuoteLine.id) && err.trim() != Label.Pricing_Deal_Editing_Restriction_Error)) ? Label.Pricing_Tender_MyDeal_Integration_Status_Error: Label.Pricing_Tender_MyDeal_Integration_Status_Complete);
                        quoteLine.Pricing_Integration_Time_Stamp__c = inboundMsgIdToCreatedTimeMap.get(inboundMsgId);
                        quoteLine.Pricing_Previous_MyDeal_Action_Nm__c = action;
                        quoteLine.Pricing_Previous_Inbound_Msg_Number__c = inboundMsgIdToNameMap.get(inboundMsgId);
                    }
                    //when any Error in Ql validations or Core_Error_Code__c not equal to 200 then showing this msg in core log
                if(String.isNotBlank(quoteDetail.Id) && !qlIdToErrorMsgMap.containsKey(quoteDetail.Id)){
                    writeMessage =inboundMsgWithErrorsSet.contains(inboundMsgId) ? appendErrorMsg(writeMessage,' IIM Status is : Failed') : (String.isBlank(jsonQuoteLine.Id) || qlIdToErrorMsgMap.containsKey(jsonQuoteLine.id)) ? appendErrorMsg(writeMessage,' '+qlIdToErrorMsgMap.get(jsonQuoteLine.id)) : appendErrorMsg(writeMessage,' IIM Status is : Successful') ;
                    if(String.isNotBlank(writeMessage)){
                        appendSuccessMsgToMap(jsonQuoteLine.QuoteLineNumber,writeMessage);
                    }
                }
            }
            //when Quote id is null or invalid then showing below msg in core log once only
            if(String.isBlank(quoteDetail.Id) || qlIdToErrorMsgMap.containsKey(quoteDetail.Id)){
                writeMessage = appendErrorMsg(writeMessage,' Quote Id is Null or Invalid');
                if(String.isNotBlank(writeMessage)){
                    appendSuccessMsgToMap(quoteDetail.Name,writeMessage);
                }
            }
        }
    }
    /*****************************************************************************************************
    Method Name:        processMessages
        @parameters:        action: Create/Update/UpdateStatus/Claims
    Description:        Send data to MyDeals, inserts payload data to Integration Outbound Messages,
    mulesfort will pick and send it to MyDeals.Receive Claims data and insert into QuoteLines.
        Added By:           Mahesh - 6/11/2020
         ******************************************************************************************************/
    public void processMessages(List<Core_Integration_Inbound_Message__c> newList){
        //List of Inbounnd Message to add to Error Log Entry in Case of Exception
        Set<String> inboundMsgIdSet = new Set<String>();
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            Map<Id,Pricing_JSONString> jsonParserResultMap = new Map<Id,Pricing_JSONString>();
            Set<Id> quoteIdSet = new Set<Id>();
            Map<String,String> l2IdL1IdMap = new Map<String,String>();
            
            for(Core_Integration_Inbound_Message__c inboundMsg : newList){
                inboundMsgIdSet.add(inboundMsg.Name);
                inboundMsgIdToNameMap.put(inboundMsg.Id,inboundMsg.Name);
                inboundMsgIdToCreatedTimeMap.put(inboundMsg.Id,inboundMsg.CreatedDate);
                if(inboundMsg.Core_Payload__c != null){
                    jsonParserResultMap.put(inboundMsg.Id,(Pricing_JSONString)System.JSON.deserialize(inboundMsg.Core_Payload__c, Pricing_JSONString.class));
                }
                if(inboundMsg.Core_Error_Code__c != '200'){
                    //Error Log for the IIM
                    appendErrorMsgToMap(inboundMsg.Id,'Error code: '+inboundMsg.Core_Error_Code__c+' received and Error has occurred');
                    inboundMsgWithErrorsSet.add(inboundMsg.Id);
                }
                
                inboundMsgList.add(inboundStatusUpdate(new Core_Integration_Inbound_Message__c(Id = inboundMsg.Id,
                Core_Processing_Status__c = inboundMsgWithErrorsSet.contains(inboundMsg.Id) ? 'Failed' : 'Successful',
                Core_Retry_Counter__c = inboundMsg.Core_Retry_Counter__c)));
                Pricing_JSONString jsonParsedOutput = jsonParserResultMap.get(inboundMsg.Id);
                Pricing_JSONString.RecordDetails recDetails = new Pricing_JSONString.RecordDetails();
                Pricing_JSONString.Quote quoteDetail = new Pricing_JSONString.Quote();
                
                if(jsonParsedOutput.Header != null){
                    if(jsonParsedOutput.RecordDetails != null){
                        recDetails = jsonParsedOutput.RecordDetails;
                        if(recDetails.Quote != null){
                            quoteDetail = recDetails.Quote;
                            //jsonQuoteLineList = quoteDetail.QuoteLine;
                            if(quoteDetail.QuoteLine!=null){
                                for(Pricing_JSONString.QuoteLine quoteLine: quoteDetail.QuoteLine){
                                    if(String.isNotBlank(quoteLine.Id)){
                                        quoteLineIdSet.add(quoteLine.Id);
                                        if(!inboundMsgNumberToRecordIdMap.containsKey(inboundMsg.Name)){
                                            inboundMsgNumberToRecordIdMap.put(inboundMsg.Name,quoteLine.Id);
                                        }
                                        quoteLineNumberToRecordIdMap.put(quoteLine.QuoteLineNumber,quoteLine.Id);
                                        inboundMsgIdToNameMap.put(quoteLine.Id, quoteLine.QuoteLineNumber);//CH
                                        inboundMsgNumberToRecordIdMap.put(quoteLine.QuoteLineNumber,quoteLine.Id);//CH
                                    }
                                }
                            }
                            if(String.isNotBlank(quoteDetail.Id)){
                                quoteIdSet.add(quoteDetail.Id);
                                if(!inboundMsgNumberToRecordIdMap.containsKey(inboundMsg.Name)){
                                    inboundMsgNumberToRecordIdMap.put(inboundMsg.Name,quoteDetail.Id);
                                }
                                if(quoteDetail.QuoteLine ==  null && String.isNotBlank(quoteDetail.Name)) {
                                    quoteLineNumberToRecordIdMap.put(quoteDetail.Name,quoteDetail.Id);
                                }
                            }
                            if(String.isNotBlank(quoteDetail.UnifiedEndCustomerId) && String.isNotBlank(quoteDetail.UnifiedCountryEndCustomerId)){
                                if(!l2IdL1IdMap.containsKey(quoteDetail.UnifiedCountryEndCustomerId)){
                                    l2IdL1IdMap.put(quoteDetail.UnifiedCountryEndCustomerId,quoteDetail.UnifiedEndCustomerId);
                                }
                            }
                        }else{
                            appendErrorMsgToMap(inboundMsg.Id,Label.Pricing_Tender_Integration_inbound_Error_QuoteNull);
                        }
                    }
                    else{
                        appendErrorMsgToMap(inboundMsg.Id,Label.Pricing_Tender_Integration_inbound_Record_Details_not_found_Error);
                    }
                }
                else{
                    appendErrorMsgToMap(inboundMsg.Id,Label.Pricing_Tender_Integration_inbound_Header_not_found_Error);
                }
            }
            
            if(!quoteIdSet.isEmpty()){
                for(SBQQ__Quote__c quote : ([SELECT Id,SBQQ__Account__r.Id,Pricing_Folio_ID_Nm__c,Pricing_Customer_Nm__c,Pricing_End_Customer__c,Pricing_Unified_Global_End_Customer_Nm__c,
                                             Pricing_End_Customer__r.Id,Pricing_End_Customer__r.Name,Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,
                                             Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,Pricing_On_Hold_Cb__c,
                                             Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Id__c,Pricing_IsUnifiedCustomer__c,
                                             Pricing_End_Customer_Country_Nm__c,SBQQ__Account__c from SBQQ__Quote__c where Id IN: quoteIdSet])){
                    quoteIdToFolioIdMap.put(quote.Id,quote.Pricing_Folio_ID_Nm__c);
                    quoteIdquoteMap.put(quote.Id,quote);
                    //Set contains the End customer L1 object record ids on the Quotes being processed
                    if(String.isBlank(quote.Pricing_Unified_Global_End_Customer_Nm__c) && String.isBlank(quote.Pricing_Customer_Nm__c)){
                        unifiedEndCustAccSet.add(quote.Pricing_End_Customer__c);
                    }
                }
            }
            
            if(!quoteLineIdSet.isEmpty()){
                for(SBQQ__QuoteLine__c quoteLine : [SELECT Id,Pricing_Deal_RFQ_Id__c,SBQQ__Quote__c,Pricing_Create_Deal_Actor_Id__c,
                                                    Pricing_Create_Deal_Actor_Id__r.Name,Pricing_Status_Nm__c,Pricing_Deal_RFQ_Status_Nm__c,
                                                    Pricing_Quote_Line_Number__c,Pricing_Integration_Time_Stamp__c,Pricing_Previous_MyDeal_Action_Nm__c,
                                                    Pricing_Integration_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_Previous_Inbound_Msg_Number__c,Pricing_Program_Type_Nm__c,
                                                    SBQQ__Quote__r.Pricing_On_Hold_Cb__c from SBQQ__QuoteLine__c where Id IN: quoteLineIdSet]){
                    if(!quoteIdToQuoteLineIdSetMap.containsKey(quoteLine.SBQQ__Quote__c)){
                        quoteIdToQuoteLineIdSetMap.put(quoteLine.SBQQ__Quote__c,new Set<Id>{quoteLine.Id});
                    }else{
                        quoteIdToQuoteLineIdSetMap.get(quoteLine.SBQQ__Quote__c).add(quoteLine.Id);
                    }
                    if(!quoteLineIdToOnHoldMap.containsKey(quoteLine.id)){
                        quoteLineIdToOnHoldMap.put(quoteLine.id,quoteLine.SBQQ__Quote__r.Pricing_On_Hold_Cb__c);
                    }
                    quoteLineIdToQLMap.put(quoteLine.Id,quoteLine);
                    
                }
            }
            //Check for existing L1 object and L2 object data
            if(!l2IdL1IdMap.isEmpty()){
                for(Pricing_UnifiedEndCustomerAccountMapping__c l1ObjRec : [SELECT Id,Name,Pricing_Account_Nm__c,Pricing_Unified_EndCustomer_Id__c FROM Pricing_UnifiedEndCustomerAccountMapping__c 
                                                                            WHERE Pricing_Unified_EndCustomer_Id__c IN :l2IdL1IdMap.values()]){
                    if(!l1IdAccountIdsMap.containsKey(l1ObjRec.Pricing_Unified_EndCustomer_Id__c)){
                        l1IdAccountIdsMap.put(l1ObjRec.Pricing_Unified_EndCustomer_Id__c,new Map<String,String>{l1ObjRec.Pricing_Account_Nm__c => l1ObjRec.Id});
                    }else{
                        if(!l1IdAccountIdsMap.get(l1ObjRec.Pricing_Unified_EndCustomer_Id__c).containsKey(l1ObjRec.Pricing_Account_Nm__c)){
                            l1IdAccountIdsMap.get(l1ObjRec.Pricing_Unified_EndCustomer_Id__c).put(l1ObjRec.Pricing_Account_Nm__c,l1ObjRec.Id);
                        }
                    }
                }
                
                for(Pricing_UnifiedEndCustomerCountryMapping__c l2ObjRec : [SELECT Id,Name,Pricing_Unified_EndCustomer_Id__c,Pricing_Unified_Country_EndCustomer_Id__c 
                                                                            FROM Pricing_UnifiedEndCustomerCountryMapping__c WHERE Pricing_Unified_Country_EndCustomer_Id__c IN:l2IdL1IdMap.keySet() ]){
                    if(!l2Idl1IdOldMap.containsKey(l2ObjRec.Pricing_Unified_Country_EndCustomer_Id__c))  {
                        l2Idl1IdOldMap.put(l2ObjRec.Pricing_Unified_Country_EndCustomer_Id__c,new Map<String,String>{l2ObjRec.Pricing_Unified_EndCustomer_Id__c =>l2ObjRec.Id});
                    }
                }
            }
            
            for(Id inboundMsgId : jsonParserResultMap.keySet()){
                if(!inboundMsgIdToErrorMsg.containsKey(inboundMsgId)){
                    Pricing_JSONString jsonParsedOutput = jsonParserResultMap.get(inboundMsgId);
                    Pricing_JSONString.RecordDetails recDetails = new Pricing_JSONString.RecordDetails();
                    Pricing_JSONString.Quote quoteDetail = new Pricing_JSONString.Quote();
                    SBQQ__Quote__c quote = new SBQQ__Quote__c();
                    String writeMessage = '';
                    List<Pricing_JSONString.QuoteLine> jsonQuoteLineList = new List<Pricing_JSONString.QuoteLine>();
                    recDetails = jsonParsedOutput.RecordDetails;
                    quoteDetail = recDetails.Quote;
                    jsonQuoteLineList = quoteDetail.QuoteLine;
                    
                    if(jsonParsedOutput.Header.action == Label.Pricing_Tender_Integration_Header_Action_CreateResponse || jsonParsedOutput.Header.action == Label.Pricing_Tender_Integration_Header_Action_UpdateResponse ||
                    jsonParsedOutput.Header.action == Label.Pricing_Tender_Integration_Header_Action_UpdateStatusResponse || jsonParsedOutput.Header.action == Label.Pricing_Tender_Integration_Header_Action_DeleteResponse){
                        //processAcknowledgement(writeMessage,jsonQuoteLineList,quoteDetail,inboundMsgId,jsonParsedOutput.Header.action);
                    }
                    else if(jsonParsedOutput.Header.action == Label.Pricing_Tender_Integration_Header_Action_Update || jsonParsedOutput.Header.action == Label.Pricing_Tender_Integration_Header_Action_Create || jsonParsedOutput.Header.action == Label.Pricing_Tender_QuoteLine_RollBack){
                        processUpdateOrCreate(quoteDetail,quote,writeMessage,jsonQuoteLineList,inboundMsgId,jsonParsedOutput.Header.action);
                    }else if(jsonParsedOutput.Header.action == Label.Pricing_Tender_Integration_Header_Action_UpdateStatus || jsonParsedOutput.Header.action == Label.Pricing_Tender_Integration_Header_Action_Delete){
                        processUpdateStatus(quoteDetail, quote, writeMessage, jsonQuoteLineList,inboundMsgId,jsonParsedOutput.Header.action);
                    }
                }
            }
            if(!tptListToUpdate.isEmpty()){
                upsert tptListToUpdate;
            }
            
            Map<String,String> errorMap = new Map<String,String>();
            for(Id inboundId : inboundMsgIdToErrorMsg.keySet()){
                errorMap.put(inboundMsgIdToNameMap.get(inboundId),inboundMsgIdToErrorMsg.get(inboundId));
            }
            List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
            if(!errorMap.isEmpty() && !inboundMsgNumberToRecordIdMap.isEmpty()){
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectIntegration(errorMap,inboundMsgNumberToRecordIdMap,'Critical'));
            }
            if(!writeMessageMap.isEmpty() && !quoteLineNumberToRecordIdMap.isEmpty()){
                logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectIntegration(writeMessageMap,quoteLineNumberToRecordIdMap,'Low'));
            }
            if(!quoteMap.isEmpty()){
                update quoteMap.values();
            }
            
            if(!quoteLineMap.isEmpty()){
                SBQQ.TriggerControl.disable();
                update quoteLineMap.values();
                SBQQ.TriggerControl.enable();
            }
            
            if(!inboundMsgList.isEmpty()){
                update inboundMsgList;
            }
            
            if(!logEntryList.isEmpty()){
                insert logEntryList;
            }
        }catch(Exception e){
            Database.RollBack(sp);
            if(!inboundMsgIdSet.isEmpty()){
                e.setMessage(e.getMessage() +' '+ String.join(new List<String>(inboundMsgIdSet),','));
            }
            Pricing_Tender_Utility.logError(e);
            
            for(Core_Integration_Inbound_Message__c inbound : inboundMsgList){
                inbound.Core_Processing_Status__c = Label.Pricing_Tender_Inbound_Status_Failed;
                inboundStatusUpdate(inbound);
            }
            
            if(!inboundMsgList.isEmpty()){update inboundMsgList;}
            
            ApexClass batchRec = [Select Id,Name From ApexClass where name =: Label.Pricing_Tender_Mydeals_Inbound_Retrigger_Class];
            
            if(!System.isBatch() && !System.isFuture() && !isBatchRunning(batchRec.Id)) {
                Integer batchSize = 1;
                String batchSizeStr = Label.Pricing_Tender_inbound_Retrigger_Batch_Size;
                batchSize = batchSizeStr.isNumeric() ? Integer.valueOf(batchSizeStr) : batchSize;
                //Retrigger Batch if there are Inbound Records to be preocessed
                Pricing_BatchPricingRetriggerInboundMsg inboundBatch = new Pricing_BatchPricingRetriggerInboundMsg();
                database.executeBatch(inboundBatch,batchSize);
            }
        }
        finally{
            SBQQ.TriggerControl.enable();
        }
    }
    public boolean isBatchRunning(String classId){
        List<AsyncApexJob> jobs = [SELECT id 
                                   FROM AsyncApexJob 
                                   WHERE ApexClassID = :classId 
                                   AND Status in ('Holding', 'Queued', 'Preparing','Processing')];
        
        return jobs.size()>0;
    }
    public static Core_Integration_Inbound_Message__c inboundStatusUpdate(Core_Integration_Inbound_Message__c inbound){
        inbound.Core_Retry_Counter__c = (inbound.Core_Retry_Counter__c == null) ? 1 : inbound.Core_Retry_Counter__c + 1;
        if(inbound.Core_Processing_Status__c == Label.Pricing_Tender_Inbound_Status_Failed){
            inbound.Core_Reprocess_Message__c = true;
        }else if(inbound.Core_Processing_Status__c == Label.Pricing_Tender_Inbound_Status_Succesful){
            inbound.Core_Reprocess_Message__c = false;
        }
        //inbound.Core_Processing_Status__c = Label.Pricing_Tender_Inbound_Status_Failed;
        return inbound;
    }
    /*public void processAcknowledgement(String writeMessage,List<Pricing_JSONString.QuoteLine> jsonQuoteLineList,Pricing_JSONString.Quote quoteDetail,Id inboundMsgId,String action){
        String subAction = action.removeEndIgnoreCase('Response');
        writeMessage = '';
        writeMessage = appendErrorMsg(writeMessage,' Acknowledgement Request Recieved');
        
        if(String.isBlank(quoteDetail.Id)){
            appendErrorMsgToMap(inboundMsgId,Label.Pricing_Tender_Integration_inbound_Error_QuoteNull);
        }
        else if(!quoteIdToQuoteLineIdSetMap.containsKey(quoteDetail.Id)){
            appendErrorMsgToMap(inboundMsgId,'QuoteId : '+ quoteDetail.Id +' is Invalid');
        }
        
        if(!jsonQuoteLineList.isEmpty()){
            for(Pricing_JSONString.QuoteLine jsonQuoteLine : jsonQuoteLineList){
                
                Boolean isQuoteLineValid = true;
                if(String.isBlank(jsonQuoteLine.Id)){
                    appendErrorMsgToMap(inboundMsgId,'QuoteLineId is null');
                    isQuoteLineValid = false;
                }
                else if(!quoteIdToQuoteLineIdSetMap.containsKey(quoteDetail.Id) || !quoteIdToQuoteLineIdSetMap.get(quoteDetail.Id).contains(jsonQuoteLine.Id)){
                    appendErrorMsgToMap(inboundMsgId,'QuoteLineId : '+jsonQuoteLine.Id+' is Invalid');
                    isQuoteLineValid = false;
                }
                
                
                //Question: should we consider QL ErrorMessages for Integration Status as Error
                if(isQuoteLineValid && validateInbound(action,jsonQuoteLine,inboundMsgId,subAction)){
                    
                    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                    if(quoteLineMap.containsKey(jsonQuoteLine.Id)){
                        quoteLine = quoteLineMap.get(jsonQuoteLine.Id);
                    }else{
                        quoteLine.Id = jsonQuoteLine.Id;
                        if(quoteLineIdToQLMap.containsKey(quoteLine.Id)
                        && quoteLineIdToQLMap.get(quoteLine.Id).Pricing_Status_Nm__c != Label.Pricing_Revised_Status_Label){
                            quoteLineMap.put(jsonQuoteLine.Id,quoteLine);
                        }
                    }
                    if(jsonQuoteLine.ErrorMessages != null){
                        quoteLine = updateErrorFieldOnQuoteLine(quoteLine,jsonQuoteLine);
                    }else{
                        quoteLine.Pricing_Error_Messages__c = '';
                    }
                    
                    if(!inboundMsgIdToErrorMsg.containsKey(inboundMsgId) && quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id)){
                        appendSuccessMsgToMap(quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Quote_Line_Number__c,'Acknowledgement received for QuoteLine : '+jsonQuoteLine.QuoteLineNumber+ ' with Inbound Msg '+inboundMsgIdToNameMap.get(inboundMsgId));
                    }
                    
                    if(jsonQuoteLine.ErrorMessages != null){
                        for(Pricing_JSONString.ErrorMessages errorStr : jsonQuoteLine.ErrorMessages){
                            if(!warningErrorMessageCodeSet.contains(errorStr.code)){
                                if(String.isNotBlank(errorStr.code)){
                                    appendErrorMsgToMap(inboundMsgId,errorStr.code);
                                }
                                if(String.isNotBlank(errorStr.Message)){
                                    appendErrorMsgToMap(inboundMsgId,errorStr.Message);
                                }
                            }
                        }
                    }
                    quoteLine.Pricing_Integration_Status_Nm__c = inboundMsgIdToErrorMsg.containsKey(inboundMsgId) ? Label.Pricing_Tender_MyDeal_Integration_Status_Error : Label.Pricing_Tender_MyDeal_Integration_Status_InProcess;
                    quoteLine.Pricing_Integration_Time_Stamp__c = inboundMsgIdToCreatedTimeMap.get(inboundMsgId);
                    quoteLine.Pricing_Previous_MyDeal_Action_Nm__c = action;
                    quoteLine.Pricing_Previous_Inbound_Msg_Number__c = inboundMsgIdToNameMap.get(inboundMsgId);
                }
                
                if(inboundMsgWithErrorsSet.contains(inboundMsgId)){
                    writeMessage = appendErrorMsg(writeMessage,' IIM Status is : Failed');
                }
                else{
                    writeMessage = appendErrorMsg(writeMessage, ' IIM Status is : Successful');
                }
                
                if(String.isNotBlank(writeMessage) && quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id)){
                    appendSuccessMsgToMap(quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Quote_Line_Number__c,writeMessage);
                }
            }
        }
    }*/
    
    /**
     * @description called from Integration Inbound Trigger to process the claims data payload sent by MyDeals and store it in respective QLI.
     * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-08-2022
     * @param newList
     **/
    public void processClaimsMessages(List<Core_Integration_Inbound_Message__c> newList){
        Savepoint sp;
        List<String> inboundMsgIdSet = new List<String>();
        try{
            sp = Database.setSavepoint();
            List<SBQQ__QuoteLine__c> qliLst = new List<SBQQ__QuoteLine__c>();
            Map<String,Pricing_ClaimsDataWrapper.claimsData> dealIdToClaimMap = new Map<String,Pricing_ClaimsDataWrapper.claimsData>();
            for(Core_Integration_Inbound_Message__c inboundMsg : newList){
                Pricing_ClaimsDataWrapper jsonMap = (Pricing_ClaimsDataWrapper)System.JSON.deserialize(inboundMsg.Core_Payload__c,Pricing_ClaimsDataWrapper.class);
                for(Pricing_ClaimsDataWrapper.ClaimsData claim: jsonMap.claims){
                    dealIdToClaimMap.put(claim.dealId,claim);
                }
                inboundMsgIdSet.add(inboundMsg.id);
            }
            if(!dealIdToClaimMap.keySet().isEmpty()){
                List<String> claimUpdateStatuses = new List<String>{Label.Pricing_Tender_QuoteLine_Status_Approved,Label.Pricing_Tender_QuoteLine_Status_Won,Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview,Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview};
                qliLst = [Select id,Pricing_Deal_RFQ_Id__c,Pricing_Debit_Volume_qty__c,Pricing_Debit_Dollars_Amt__c,Pricing_Last_Credit_Debit_Date_Dt__c,Pricing_Credit_Volume_qty__c,Pricing_Credit_Dollars_Amt__c from SBQQ__QuoteLine__c where Pricing_Deal_RFQ_Id__c IN :dealIdToClaimMap.keySet() and Pricing_Status_Nm__c IN :claimUpdateStatuses ];
            }
            for(SBQQ__QuoteLine__c qli: qliLst){
                qli.Pricing_Credit_Dollars_Amt__c = dealIdToClaimMap.get(qli.Pricing_Deal_RFQ_Id__c).creditDollars == null ? null: dealIdToClaimMap.get(qli.Pricing_Deal_RFQ_Id__c).creditDollars ;
                qli.Pricing_Credit_Volume_qty__c = dealIdToClaimMap.get(qli.Pricing_Deal_RFQ_Id__c).creditVolume == null ? null: dealIdToClaimMap.get(qli.Pricing_Deal_RFQ_Id__c).creditVolume ;
                qli.Pricing_Last_Credit_Debit_Date_Dt__c = dealIdToClaimMap.get(qli.Pricing_Deal_RFQ_Id__c).lastCreditOrDebitDate == null ? null: Date.parse(dealIdToClaimMap.get(qli.Pricing_Deal_RFQ_Id__c).lastCreditOrDebitDate) ;
                qli.Pricing_Debit_Dollars_Amt__c =  dealIdToClaimMap.get(qli.Pricing_Deal_RFQ_Id__c).debitDollars == null ? null: dealIdToClaimMap.get(qli.Pricing_Deal_RFQ_Id__c).debitDollars ;
                qli.Pricing_Debit_Volume_qty__c = dealIdToClaimMap.get(qli.Pricing_Deal_RFQ_Id__c).debitVolume == null ? null: dealIdToClaimMap.get(qli.Pricing_Deal_RFQ_Id__c).debitVolume ;
            }
            SBQQ.TriggerControl.disable();
            update qliLst;
            SBQQ.TriggerControl.enable();
        }catch(Exception e){
            Database.RollBack(sp);
            if(!inboundMsgIdSet.isEmpty()){
                e.setMessage(e.getMessage() +' '+ String.join(inboundMsgIdSet,','));
            }
            Pricing_Tender_Utility.logError(e);
        }
        finally{
            SBQQ.TriggerControl.enable();
        }
    }
    
    public void processUpdateStatus(Pricing_JSONString.Quote quoteDetail,SBQQ__Quote__c quote,String writeMessage,List<Pricing_JSONString.QuoteLine> jsonQuoteLineList,Id inboundMsgId,String action)
    {
        Boolean onHoldQuote = false;
        writeMessage = '';
        writeMessage = (action == Label.Pricing_Tender_Integration_Header_Action_Delete) ?appendErrorMsg(writeMessage,'Delete Request Recieved') : appendErrorMsg(writeMessage,'UpdateStatus Request Recieved');
        Id rpmCommentsRecTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c', Label.Pricing_Tender_Comment_RecordType_PricingManagerComment);
        Pricing_Comments__c comment = new Pricing_Comments__c();
        List<Pricing_Comments__c> commentsToBeInserted = new List<Pricing_Comments__c>();
        
        for(Pricing_JSONString.QuoteLine quoteLine: quoteDetail.QuoteLine){
            if(String.isNotBlank(quoteLine.Id)){
                if(quoteLineIdToOnHoldMap.get(quoteLine.id)) {
                    onHoldQuote = true;
                }
            }
        }
        if(!jsonQuoteLineList.isEmpty()){
            for(Pricing_JSONString.QuoteLine jsonQuoteLine : jsonQuoteLineList){
                
                SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                if(quoteLineMap.containsKey(jsonQuoteLine.Id)){
                    quoteLine = quoteLineMap.get(jsonQuoteLine.Id);
                }
                if(String.isNotBlank(jsonQuoteLine.DealRFQId)
                    && quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id)
                && quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Deal_RFQ_Id__c == jsonQuoteLine.DealRFQId){
                    quoteLine.Pricing_Deal_RFQ_Id__c = jsonQuoteLine.DealRFQId;
                    writeMessage = appendErrorMsg(writeMessage,'DealId is '+jsonQuoteLine.DealRFQId);
                }
                if(String.isBlank(jsonQuoteLine.DealRFQId)){
                    qlIdToErrorMsgMap.put(jsonQuoteLine.Id,'DealId is null');
                    appendErrorMsgToMap(inboundMsgId,'DealId is null');
                }
                if(String.isBlank(jsonQuoteLine.Id)){
                    qlIdToErrorMsgMap.put('QuoteLineId is null','QuoteLineId is null');
                    appendErrorMsgToMap(inboundMsgId,'QuoteLineId is null');
                }else if(String.isNotBlank(jsonQuoteLine.Id) && !quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id)){
                    qlIdToErrorMsgMap.put(jsonQuoteLine.Id,'QuoteLineId : '+jsonQuoteLine.Id+' is Invalid');
                    appendErrorMsgToMap(inboundMsgId,'QuoteLineId : '+jsonQuoteLine.Id+' is Invalid');
                }else if(quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id)
                && quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Deal_RFQ_Id__c != jsonQuoteLine.DealRFQId){
                    qlIdToErrorMsgMap.put(jsonQuoteLine.Id,'QuoteLineId :  '+jsonQuoteLine.Id+' Deal Id on JSON: '+jsonQuoteLine.DealRFQId+' and Deal Id on QuoteLine: '+quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Deal_RFQ_Id__c+' does not Match');
                    appendErrorMsgToMap(inboundMsgId,'QuoteLineId :  '+jsonQuoteLine.Id+' Deal Id on JSON: '+jsonQuoteLine.DealRFQId+' and Deal Id on QuoteLine: '+quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Deal_RFQ_Id__c+' does not Match');
                }
                if(onHoldQuote && !(jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_Integration_Deal_Status_Won || jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_QuoteLine_Status_Lost || jsonQuoteLine.ErrorMessages != null)) {
                    qlIdToErrorMsgMap.put(jsonQuoteLine.Id,'Quote is on Hold.');
                    appendErrorMsgToMap(jsonQuoteLine.id,'Quote is on Hold.');
                }
                if(validateInbound(action,jsonQuoteLine,inboundMsgId,'')){
                    if(String.isNotBlank(jsonQuoteLine.Id) && !qlIdToErrorMsgMap.containsKey(jsonQuoteLine.Id)){
                        if(String.isNotBlank(jsonQuoteLine.DealRFQStatus)){
                            quoteLine.Pricing_Deal_RFQ_Status_Nm__c = jsonQuoteLine.DealRFQStatus;
                            if(action == Label.Pricing_Tender_Integration_Header_Action_UpdateStatus){
                                if(quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id) && quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Deal_RFQ_Status_Nm__c != jsonQuoteLine.DealRFQStatus){
                                    if((jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_Integration_Deal_Status_offer && quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Approved) || jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_QuoteLine_Edit_DealRFQStatus){
                                        String status = (jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_Integration_Deal_Status_offer)?Label.Pricing_Tender_QuoteLine_Status_Approved:jsonQuoteLine.DealRFQStatus;
                                        tptListToUpdate.addAll(QuoteLineBusinessLogic.getTPTRecordsToUpdate(new List<SBQQ__QuoteLine__c>{quoteLineIdToQLMap.get(jsonQuoteLine.Id)},null,false,true,
                                        'DPM',jsonQuoteLine.ApprovedByInfo,DateTime.now(),status));
                                    }
                                    if(jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_QuoteLine_ReadOnly_DealRFQStatus){
                                        tptListToUpdate.addAll(QuoteLineBusinessLogic.getTPTRecordsToUpdate(new List<SBQQ__QuoteLine__c>{quoteLineIdToQLMap.get(jsonQuoteLine.Id)},null,false,true,
                                        'RPM',(quoteLineIdToQLMap.get(jsonQuoteLine.Id)).Pricing_Create_Deal_Actor_Id__r.Name,DateTime.now(),jsonQuoteLine.DealRFQStatus));
                                    }
                                }
                                if(jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_Integration_Deal_Status_offer){
                                    quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
                                    
                                }
                                //if Deal status is Won and change Request QL then updating Ql status as Won
                                if(jsonQuoteLine.DealRFQStatus == Label.Pricing_Tender_Integration_Deal_Status_Won &&
                                quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id) && quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Reference_Quote_Line_Nbr__c != null){
                                    quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Won;
                                    writeMessage = appendErrorMsg(writeMessage,' QuoteLine Status is : '+quoteLine.Pricing_Status_Nm__c);
                                }
                            }
                            writeMessage = appendErrorMsg(writeMessage,' QuoteLine Status is : '+quoteLine.Pricing_Status_Nm__c);
                            writeMessage = appendErrorMsg(writeMessage,' QuoteLine IntegrationStatus is : '+quoteLine.Pricing_Integration_Status_Nm__c);
                        }
                    }else{
                        writeMessage = '';
                    }
                    if(!quoteLineMap.containsKey(jsonQuoteLine.Id)){
                        quoteLine.Id = jsonQuoteLine.Id;
                        if(quoteLineIdToQLMap.containsKey(quoteLine.Id) &&
                        quoteLineIdToQLMap.get(quoteLine.Id).Pricing_Status_Nm__c != Label.Pricing_Revised_Status_Label){
                            quoteLineMap.put(jsonQuoteLine.Id,quoteLine);
                        }
                    }
                    if(jsonQuoteLine.ErrorMessages != null){
                        quoteLine = updateErrorFieldOnQuoteLine(quoteLine,jsonQuoteLine);
                    }else{
                        quoteLine.Pricing_Error_Messages__c = '';
                    }
                    
                    if(jsonQuoteLine.ErrorMessages != null){
                        for(Pricing_JSONString.ErrorMessages errorStr : jsonQuoteLine.ErrorMessages){
                            if(!warningErrorMessageCodeSet.contains(errorStr.code)){
                                if(String.isNotBlank(errorStr.code)){
                                    qlIdToErrorMsgMap.put(jsonQuoteLine.Id,errorStr.code);
                                    appendErrorMsgToMap(inboundMsgId,errorStr.code);
                                }
                                if(String.isNotBlank(errorStr.Message)){
                                    qlIdToErrorMsgMap.put(jsonQuoteLine.Id,errorStr.Message);
                                    appendErrorMsgToMap(inboundMsgId,errorStr.Message);
                                }
                            }
                        }
                    }
                    if(!qlIdToErrorMsgMap.containsKey(jsonQuoteLine.Id) && action == Label.Pricing_Tender_Integration_Header_Action_Delete){
                        quoteLine.Pricing_Deal_RFQ_Id__c = '';
                        quoteLine.Pricing_Deal_RFQ_Dup_Id__c = '';
                        quoteLine.Pricing_Deal_RFQ_Status_Nm__c = '';
                    }
                     if( jsonQuoteLine.RevisionReasonComment != null && jsonQuoteLine.RevisionReasonComment != ''){
                      
                         if(quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id) && !commentsToBeInserted.contains(comment)){
                            
                             comment.Pricing_Quote__c = quoteLineIdToQLMap.get(jsonQuoteLine.Id).SBQQ__Quote__c;
                                comment.RecordTypeId = rpmCommentsRecTypeId;
                                comment.Pricing_Answer__c = quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Quote_Line_Number__c + ' : ' + quoteLineIdToQLMap.get(quoteLine.Id).Pricing_Status_Nm__c + '\n'+ jsonQuoteLine.RevisionReasonComment;//citrus modified quoteline number extraction
                                commentsToBeInserted.add(comment);
                         }
                    }
                    quoteLine.Pricing_Integration_Status_Nm__c = (String.isBlank(jsonQuoteLine.Id) || (qlIdToErrorMsgMap.containsKey(jsonQuoteLine.id) && err.trim() != Label.Pricing_Deal_Editing_Restriction_Error)) ?Label.Pricing_Tender_MyDeal_Integration_Status_Error : Label.Pricing_Tender_MyDeal_Integration_Status_Complete;
                    //when offer packet comes first instead of submit packet added Generic error msg.
                    // quoteLine.Pricing_Error_Messages__c = quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Deal_RFQ_Status_Nm__c != Label.Pricing_Tender_MyDeal_RFQ_Status_Submitted ? Label.Pricing_Mydeals_Support_Error : quoteLine.Pricing_Error_Messages__c;
                    quoteLine.Pricing_Integration_Time_Stamp__c = inboundMsgIdToCreatedTimeMap.get(inboundMsgId);
                    quoteLine.Pricing_Previous_MyDeal_Action_Nm__c = action;
                    quoteLine.Pricing_Previous_Inbound_Msg_Number__c = inboundMsgIdToNameMap.get(inboundMsgId);
                }
                writeMessage =inboundMsgWithErrorsSet.contains(inboundMsgId) ? appendErrorMsg(writeMessage,' IIM Status is : Failed') : (String.isBlank(jsonQuoteLine.Id) || qlIdToErrorMsgMap.containsKey(jsonQuoteLine.id)) ? appendErrorMsg(writeMessage,' '+qlIdToErrorMsgMap.get(jsonQuoteLine.id)) : appendErrorMsg(writeMessage,' IIM Status is : Successful') ;
                if(String.isNotBlank(writeMessage) && quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id)){
                    appendSuccessMsgToMap(quoteLineIdToQLMap.get(jsonQuoteLine.Id).Pricing_Quote_Line_Number__c,writeMessage);
                }
            }
        }
        if(!commentsToBeInserted.isEmpty()){
            insert commentsToBeInserted;
        }
    }
    
    public boolean validateInbound(String action,Pricing_JSONString.QuoteLine jsonQuoteLine,Id inboundMsgId,String subAction){
        Integer currentInboundNumber;
        Integer previousInboundNumber;
        SBQQ__QuoteLIne__c quoteLine = new SBQQ__QuoteLine__c();
        if(quoteLineIdToQLMap.containsKey(jsonQuoteLine.Id)){
            if(inboundMsgIdToNameMap.containsKey(inboundMsgId) && String.isNotBlank(inboundMsgIdToNameMap.get(inboundMsgId))){
                String currentInboundNumberStr = inboundMsgIdToNameMap.get(inboundMsgId).subStringAfter('IIM-');
                currentInboundNumber = integer.valueof(currentInboundNumberStr);
            }
            quoteLine = quoteLineIdToQLMap.get(jsonQuoteLine.Id);
            if(String.isNotBlank(quoteLine.Pricing_Previous_Inbound_Msg_Number__c)){
                String previousInboundNumberStr =   quoteLine.Pricing_Previous_Inbound_Msg_Number__c.subStringAfter('IIM-');
                previousInboundNumber = integer.valueof(previousInboundNumberStr);
            }
            if(action == Label.Pricing_Tender_Integration_Header_Action_CreateResponse
                || action == Label.Pricing_Tender_Integration_Header_Action_UpdateResponse
                || action == Label.Pricing_Tender_Integration_Header_Action_UpdateStatusResponse
            || action == Label.Pricing_Tender_Integration_Header_Action_DeleteResponse){
                if((quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Pending
                    && subAction == quoteLine.Pricing_Previous_MyDeal_Action_Nm__c
                    && (quoteLine.Pricing_Integration_Time_Stamp__c == null
                    || inboundMsgIdToCreatedTimeMap.get(inboundMsgId) > quoteLine.Pricing_Integration_Time_Stamp__c)
                    && (quoteLine.Pricing_Previous_Inbound_Msg_Number__c == null
                    || ((currentInboundNumber != null && previousInboundNumber != null)
                && (currentInboundNumber > previousInboundNumber))))){
                    return true;
                }
                else{
                    return false;
                }
            }
            else if(action == Label.Pricing_Tender_Integration_Header_Action_Update
                || action == Label.Pricing_Tender_Integration_Header_Action_Create
                || action == Label.Pricing_Tender_Integration_Header_Action_UpdateStatus
                || action == Label.Pricing_Tender_Integration_Header_Action_Delete
            || action == Label.Pricing_Tender_QuoteLine_RollBack) {
                if(((quoteLine.Pricing_Integration_Time_Stamp__c == null
                    || inboundMsgIdToCreatedTimeMap.get(inboundMsgId) >= quoteLine.Pricing_Integration_Time_Stamp__c))
                    && (quoteLine.Pricing_Previous_Inbound_Msg_Number__c == null
                    || (currentInboundNumber != null && previousInboundNumber != null
                && (currentInboundNumber >= previousInboundNumber)))){
                    return true;
                }else{
                    return false;
                }
            }
        }
        return false;
    }
    
    public SBQQ__QuoteLine__c updateErrorFieldOnQuoteLine(SBQQ__QuoteLine__c quoteLine,Pricing_JSONString.QuoteLine jsonQuoteLine){
        for(Pricing_JSONString.ErrorMessages errorStr : jsonQuoteLine.ErrorMessages){
            if(!warningErrorMessageCodeSet.contains(errorStr.code)){
                if(String.isNotBlank(errorStr.code)){
                    err = err + errorStr.code;
                }
                if(String.isNotBlank(errorStr.Message)){
                    err = String.isBlank(errorStr.code) ? err : err + ' - ';
                    err = err + errorStr.Message + ';' +' ';
                }
            }
        }
        if(jsonQuoteLine.ErrorMessages != null && jsonQuoteLine.ErrorMessages.size() == 0){
            quoteLine.Pricing_Error_Messages__c = '';
        }
        if(String.isNotBlank(err) && err.trim() != Label.Pricing_Deal_Editing_Restriction_Error){
            quoteLine.Pricing_Error_Messages__c = err.substring(0, Math.min(err.length(), 1000));
        }
        return quoteLine;
    }
    
    public String appendErrorMsg(String originalMsg,String msgToBeAppended ){
        String retMsg = '';
        if(String.isNotBlank(originalMsg)){
            retMsg = originalMsg + ' \n '+msgToBeAppended;
        }else{
            retMsg = msgToBeAppended;
        }
        return retMsg;
    }
    
    /*public Map<Id,SBQQ__Quote__c> getQuoteLineExistenceMap(Set<Id> quoteIdSet, Set<Id> quoteLineIdSet){
        Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap = new Map<Id,SBQQ__Quote__c>();
        if(!quoteIdSet.isEmpty()){
            quoteIdToQuoteMap = new Map<Id,SBQQ__Quote__c>([SELECT Id,Pricing_Folio_ID_Nm__c, (SELECT Id,Pricing_Deal_RFQ_Id__c from SBQQ__LineItems__r where Id IN: quoteLineIdSet) from SBQQ__Quote__c where Id IN: quoteIdSet]);
        }
        return quoteIdToQuoteMap;
    }*/
    
    public void appendErrorMsgToMap(Id inboundMsgId, String errorMsg){
        if(String.isNotBlank(errorMsg)){
            if(!inboundMsgIdToErrorMsg.containsKey(inboundMsgId)){
                inboundMsgIdToErrorMsg.put(inboundMsgId,errorMsg);
            }
            else{
                inboundMsgIdToErrorMsg.put(inboundMsgId,inboundMsgIdToErrorMsg.get(inboundMsgId)+' \n '+ errorMsg);
            }
        }
        system.debug('inboundMsgIdToErrorMsg 1080:'+inboundMsgIdToErrorMsg);
    }
    
    public void appendSuccessMsgToMap(String quoteLineNumber, String successMsg){
        if(String.isNotBlank(successMsg)){
            if(!writeMessageMap.containsKey(quoteLineNumber)){
                writeMessageMap.put(quoteLineNumber,successMsg);
            }
            else{
                writeMessageMap.put(quoteLineNumber,writeMessageMap.get(quoteLineNumber)+' \n '+ successMsg);
            }
        }
    }
    
    public Map<Id,String> validationMethod(List<SBQQ__QuoteLine__c> quoteLines){
        
        Map<Id,String> quoteLineIdToErrorMap = new Map<Id,String>();
        Date today = System.today();
        String typeQuote ='SBQQ__Quote__c';
        String typeQuoteLine ='SBQQ__QuoteLine__c';
        Schema.SObjectType quoteSchema = ((SObject)Type.forName(typeQuote).newInstance()).getSObjectType();
        Schema.SObjectType quoteLineSchema = ((SObject)Type.forName(typeQuoteLine).newInstance()).getSObjectType();
        Map<String, Schema.SObjectField> quoteFieldMap = quoteSchema.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> quoteLineFieldMap = quoteLineSchema.getDescribe().fields.getMap();
        Set < String > mandatoryFields = new Set < String > ((Label.Pricing_Tender_MyDeal_Integration_Mandatory_Fields).split(':'));
        List<Date> approvedStartDateList = new List<Date>();
        Map<String, Pricing_ConsumptionAccountMapping__c> consumptionPlatformMap = new Map<String, Pricing_ConsumptionAccountMapping__c>();
        Map<String, Pricing_ConsumptionAccountMapping__c> consumptionSalesGeoMap = new Map<String, Pricing_ConsumptionAccountMapping__c>();
        Map<String, Pricing_ConsumptionAccountMapping__c> consumptionSegmentMap = new Map<String, Pricing_ConsumptionAccountMapping__c>();
        Set<Id> quoteLineIdInvalidPlatformSet = new Set<Id>();
        Set<Id> quoteLineIdInvalidSalesGeoSet = new Set<Id>();
        Set<Id> quoteLineIdInvalidSegmentSet = new Set<Id>();
        
        for(Pricing_ConsumptionAccountMapping__c rec: [SELECT Name, Pricing_Consumption_Type_Nm__c FROM Pricing_ConsumptionAccountMapping__c WHERE 
                                                        Pricing_Account_Nm__c =: quoteLines[0].SBQQ__Quote__r.SBQQ__Account__r.Id AND Pricing_Active_ind__c = true]) {
            if(rec.Pricing_Consumption_Type_Nm__c == Label.Pricing_IQR_ConsumptionPlatform) {
                consumptionPlatformMap.put(rec.Name, rec);
            }
            else if(rec.Pricing_Consumption_Type_Nm__c == Label.Pricing_IQR_ConsumptionSalesGeo) {
                consumptionSalesGeoMap.put(rec.Name, rec);
            }
            else {
                consumptionSegmentMap.put(rec.Name, rec);
            }
        }
        
        for(SBQQ__QuoteLine__c quoteLine: quoteLines){
            if(!approvedStartDateList.contains(quoteLine.Pricing_Approved_Start_Date_Dt__c)){
                approvedStartDateList.add(quoteLine.Pricing_Approved_Start_Date_Dt__c);
            }
            approvedStartDateList.sort();
            if(!String.isBlank(quoteLine.Pricing_Consumption_Platform__c)) {
                for(String str: quoteLine.Pricing_Consumption_Platform__c.split(', ')) {
                    if(!consumptionPlatformMap.containsKey(str)) {
                        quoteLineIdInvalidPlatformSet.add(quoteLine.Id);
                        break;
                    }
                }
            }
            if(!String.isBlank(quoteLine.Pricing_Consumption_Sale_Geo__c)) {
                for(String str: quoteLine.Pricing_Consumption_Sale_Geo__c.split(', ')) {
                    if(!consumptionSalesGeoMap.containsKey(str)) {
                        quoteLineIdInvalidSalesGeoSet.add(quoteLine.Id);
                        break;
                    }
                }
            }
            if(!String.isBlank(quoteLine.Pricing_Consumption_Segment__c)) {
                for(String str: quoteLine.Pricing_Consumption_Segment__c.split(', ')) {
                    if(!consumptionSegmentMap.containsKey(str)) {
                        quoteLineIdInvalidSegmentSet.add(quoteLine.Id);
                        break;
                    }
                }
            }
        }
        // Billing start date check
        
        integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = :Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager
                        ];
        
        Boolean isExceptionQuoteLine = false;
        Boolean isWriteInProduct = false;
        if(!quoteLines.isEmpty()){
            for(SBQQ__QuoteLine__c actualQuoteLine : quoteLines) {
                String errorString = '';
                String validationMsg = '';
                
                if(TriggerHandler.isActive('Pricing_UCD_Switch') && actualQuoteLine.SBQQ__Quote__r.Pricing_Is_Sanctioned__c == true && actualQuoteLine.Pricing_Reference_Quote_Line_Nbr__c == null) {
                    validationMsg = Label.Pricing_UCD_DealCreation_Error;
                }
                
                /*for(String fieldStr : mandatoryFields){
                    if(actualQuoteLine.get(fieldStr) == null){
                        if(fieldStr != 'Pricing_Meet_Comp_Price_Amt__c' || (fieldStr  == 'Pricing_Meet_Comp_Price_Amt__c' && (actualQuoteLine.Pricing_Program_Type_Nm__c!=Label.Pricing_Tender_PMem_Quote && actualQuoteLine.Pricing_Program_Type_Nm__c!= Label.Pricing_Tender_SSD_Quote))) {
                            errorString = appendErrorMsg(errorString,quoteLineFieldMap.get(fieldStr).getDescribe().getLabel());
                        }
                        if((fieldStr != 'Pricing_Market_Segment_values_Nm__c' || fieldStr  != 'Pricing_Market_Segment_Nm__c') &&
                            ((fieldStr == 'Pricing_Market_Segment_values_Nm__c' || fieldStr  == 'Pricing_Market_Segment_Nm__c') &&
                        actualQuoteLine.Pricing_Program_Type_Nm__c!=Label.Pricing_Tender_CCG_Quote)) {
                            errorString = appendErrorMsg(errorString,quoteLineFieldMap.get(fieldStr).getDescribe().getLabel());
                        }
                    }
                }*/
                
                for(String fieldStr : mandatoryFields){
                    if(actualQuoteLine.get(fieldStr) == null){
                        if(actualQuoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_CCG_Quote &&
                            (fieldStr != 'Pricing_Meet_Comp_Price_Amt__c' || (fieldStr  == 'Pricing_Meet_Comp_Price_Amt__c' &&
                            (actualQuoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_PMem_Quote &&
                        actualQuoteLine.Pricing_Program_Type_Nm__c!= Label.Pricing_Tender_SSD_Quote)))) {
                            errorString = appendErrorMsg(errorString,quoteLineFieldMap.get(fieldStr).getDescribe().getLabel());
                        }
                        if(actualQuoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote &&
                        (fieldStr != 'Pricing_Market_Segment_values_Nm__c' && fieldStr  != 'Pricing_Market_Segment_Nm__c')) {
                            errorString = appendErrorMsg(errorString,quoteLineFieldMap.get(fieldStr).getDescribe().getLabel());
                        }
                    }
                }
                
                //set the Attribute to true for the program type(SSD) mentioned in the label to ignore Performance metric validation
                for(String str : Label.Pricing_Tender_ExceptionQuoteType.split(',')){
                    if(str == actualQuoteLine.Pricing_Program_Type_Nm__c){
                        isExceptionQuoteLine = true;
                        break;
                    }
                }
                
                if(actualQuoteLine.SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c == null){
                    errorString = appendErrorMsg(errorString,quoteFieldMap.get('Pricing_My_Deals_Folio_Name_Nm__c').getDescribe().getLabel());
                }
                
                if(actualQuoteLine.Pricing_Backdate_Reason_Txt__c == null && actualQuoteLine.Pricing_Reference_Quote_Line_Nbr__c == null && actualQuoteLine.Pricing_Approved_Start_Date_Dt__c != null
                && actualQuoteLine.Pricing_Approved_Start_Date_Dt__c < System.today()){
                    errorString = appendErrorMsg(errorString,quoteLineFieldMap.get('Pricing_Backdate_Reason_Txt__c').getDescribe().getLabel());
                }
                
                if((!isExceptionQuoteLine) && (actualQuoteLine.Performance_Metrics__r == null || (actualQuoteLine.Performance_Metrics__r).size() == 0)){
                    errorString = appendErrorMsg(errorString,Label.Pricing_MyDeals_PerformanceMetric_RequiredError);
                }
                
                if(actualQuoteLine.Pricing_Approved_End_Date_Dt__c != null && actualQuoteLine.Pricing_Approved_End_Date_Dt__c < System.Today()){
                    errorString = appendErrorMsg(errorString,Label.Pricing_Mydeal_End_Date_Past_Error);
                }
                
                if(actualQuoteLine.Pricing_Billing_Start_Date_Dt__c != null && actualQuoteLine.Pricing_Approved_Start_Date_Dt__c != null){
                    Integer noOfDaysBetweenDates = actualQuoteLine.Pricing_Billing_Start_Date_Dt__c.daysBetween(actualQuoteLine.Pricing_Approved_Start_Date_Dt__c);
                    if(noOfDaysBetweenDates > Integer.valueof(Label.Pricing_AllowedBillingDateBackDating_days)){
                        errorString = appendErrorMsg(errorString,Label.Pricing_Tender_QuoteLine_Billing_Quarter_Error);
                    }
                }
                
                if( (((actualQuoteLine.Pricing_Deal_RFQ_Status_Nm__c != Label.Pricing_Tender_MyDeal_RFQ_Status_Requested
                    || (actualQuoteLine.Pricing_Deal_RFQ_Status_Nm__c == Label.Pricing_Tender_MyDeal_RFQ_Status_Requested && actualQuoteLine.Pricing_Integration_Status_Nm__c == 'Complete')
                    ) && actualQuoteLine.Pricing_Reference_Quote_Line_Nbr__c == null )
                    ) && (quoteLineIdInvalidPlatformSet.contains(actualQuoteLine.Id) || quoteLineIdInvalidSalesGeoSet.contains(actualQuoteLine.Id) || quoteLineIdInvalidSegmentSet.contains(actualQuoteLine.Id))
                ) {
                    validationMsg = Label.Pricing_Inactive_ConsumptionValues_ErrorMsg;
                }
                
                //To check for Intel Product if Application is CoSP, then Workload is mandatory for Data center Xeon CPU
                if(actualQuoteLine.Pricing_Server_Deal_Type_Nm__c == Label.Pricing_Tender_CoSP_Application_Value && actualQuoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine && actualQuoteLine.Pricing_Workload_Nm__c == null && actualQuoteLine.Pricing_New_Change_Request_cb__c != true){
                    validationMsg = validationMsg +Label.Pricing_Mandatory_Workload_Selection;
                }
                
                //To check for Intel Product Data Center Xeon CPU QLI Workload field is not mandatory when Application is Non CoSP.
                if(actualQuoteLine.Pricing_Server_Deal_Type_Nm__c != Label.Pricing_Tender_CoSP_Application_Value && actualQuoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine && actualQuoteLine.Pricing_Workload_Nm__c != null && actualQuoteLine.Pricing_New_Change_Request_cb__c != true){
                    validationMsg = validationMsg +Label.Pricing_Non_Mandatory_Workload_Selection;
                }
                
                if((actualQuoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && actualQuoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c == 'Won') && //CH
                    ((actualQuoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c <= today &&
                    actualQuoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c >= today) ||
                    actualQuoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c > today)
                    && (actualQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c < actualQuoteLine.Pricing_Approved_Start_Date_Dt__c ||
                    /*actualQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c < today || */
                actualQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c < actualQuoteLine.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c
                || actualQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c > actualQuoteLine.Pricing_Approved_End_Date_Dt__c)){
                    validationMsg = Label.Pricing_Tender_CR_effPricingStartDtOnChangeError;
                }
                
                
                if(String.isNotBlank(errorString) || String.isNotBlank(validationMsg)){
                    if(String.isNotBlank(validationMsg)){
                        validationMsg = validationMsg + '\n';
                    }
                    if(String.isNotBlank(errorString) && !isWriteInProduct){
                        if(actualQuoteLine.Pricing_Deal_RFQ_Status_Nm__c == 'Requested' || (actualQuoteLine.Pricing_Deal_RFQ_Id__c != null && actualQuoteLine.Pricing_Reference_Quote_Line_Nbr__c != null)){
                            validationMsg = validationMsg + 'The following fields are required to update a Deal: \n'+errorString;
                        }
                        else{
                            validationMsg = validationMsg + 'The following fields are required to create a Deal: \n'+errorString;
                        }
                    }
                    quoteLineIdToErrorMap.put(actualQuoteLine.Id,(validationMsg));
                }else{
                    quoteLineIdToErrorMap.put(actualQuoteLine.Id,'Success');
                }
            }
        }
        return quoteLineIdToErrorMap;
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