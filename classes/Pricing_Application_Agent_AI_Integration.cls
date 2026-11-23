/****************************************************************************************************************************************************
 * Class Name      : Pricing_Application_Agent_AI_Integration
 * Version               : 1.0
 * Created Date          :  04-02-2026 
 * Modification Log      :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 *  Sinduja   04-02-2026        This class implements the Pricing Application Agent AI
 ******************************************************************************************************************************************************/

public class Pricing_Application_Agent_AI_Integration {      

    /*****************************************************************************************************************************************
    Method Name:        populateJSON
    Description:        To Fetch Quote, QuoteLine,Quote Comments and serialize into JSON
    @Added By:          Sinduja - 02-April-2026
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    public static void populateJSON(List<Id> quoteLineIds, Map<String,Integer> recordIdToPrevRetryCountMap) {
        try{
            Map<String,String> quoteIdToJsonMap = new Map<String,String>();
            Map<String,Set<Id>> quoteIdToQuoteLineIdsMap = new Map<String,Set<Id>>(); // Track QuoteLine IDs per Quote
    
            // Get performance metrics for quote lines**
            Map<Id, List<PerformanceMetricWrapper>> performanceMetricsMap = fetchPerformanceMetrics(quoteLineIds);
            
            // Get QuoteLine data grouped by Quote ID (now with performance metrics)
            Map<Id,List<QuoteLineWrapper>> quoteIdToQuoteLinesMap = fetchQuoteLineDetails(quoteLineIds, performanceMetricsMap);
           
            if(quoteIdToQuoteLinesMap.isEmpty()) {
                return;
            }
            
            // Extract unique quote IDs from the quoteIdToQuoteLinesMap keyset
            Set<Id> quoteIds = quoteIdToQuoteLinesMap.keySet();
            
            if(!quoteIds.isEmpty()) {
                
                // Get Quote Details
                Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap = fetchQuoteDetails(new List<Id>(quoteIds));
                
                // Get Quote Comments
                Map<Id,List<QuoteCommentWrapper>> quoteIdToCommentsWrapperMap = getQuoteCommentsWrapper(quoteIds);
                
                // Create JSON for each quote (one JSON per quote)
                for(Id quoteId : quoteIds){
                    SBQQ__Quote__c quoteRecord = quoteIdToQuoteMap.get(quoteId);
                    if(quoteRecord == null) continue;
                    
                    // Create Quote Wrapper for this quote
                    MainWrapper mainWrap = new MainWrapper();
                    mainWrap.Id = String.valueOf(quoteId);//Store quote Id
                    
                    // Populate quote fields from SBQQ__Quote__c record
                    if(quoteRecord.Pricing_Program_Type_Nm__c == 'Client'){
                        mainWrap.MarketSegment = quoteRecord.Pricing_Market_Segment_values_Nm__c;
                    }
                   
                    mainWrap.primaryContact = quoteRecord.SBQQ__PrimaryContact__r.Name;
                    mainWrap.EndCustomer = quoteRecord.Pricing_End_Customer__r.Name;
                    mainWrap.writeInEndCustomer = quoteRecord.Pricing_Customer_Nm__c;
                    mainWrap.UnifiedEndCustomerGlobalName = quoteRecord.Pricing_Unified_Global_End_Customer_Nm__r.Name;
                    mainWrap.IsUnifiedEndCustomer = quoteRecord.Pricing_IsUnifiedCustomer__c;
                    mainWrap.DealType = quoteRecord.Pricing_Deal_Type_Nm__c;
                    mainWrap.ProjectName = quoteRecord.Pricing_Project_Name_Nm__c;
                    mainWrap.ServerDealType = quoteRecord.Pricing_Server_Deal_Type_Nm__c;//changed application to ServerDealType
                    mainWrap.intelResponseRequestedByDate = quoteRecord.Pricing_Intel_Response_Requested_By_Date__c;
                    mainWrap.proposalDueDate = quoteRecord.Pricing_Bid_Dt__c;
                    mainWrap.ShipmentStartDate = quoteRecord.Pricing_ShipmentStDate_Dt__c;
                    mainWrap.ShipmentEndDate = quoteRecord.Pricing_ShipmentEndDate_Dt__c;
                    mainWrap.endCustSalesGeo = quoteRecord.Pricing_Region_Nm__c;
                    mainWrap.EndCustomerCountry = quoteRecord.Pricing_End_Customer_Country_Nm__c;
                    mainWrap.salesRep = quoteRecord.SBQQ__SalesRep__r.Name;
                    mainWrap.intelSalesRepEmail = quoteRecord.Pricing_Intel_Sales_Rep_Email_Txt__c;
                    mainWrap.intelAccountExecutive = quoteRecord.Pricing_Account_Executive_Nm__r.Name;
                    mainWrap.intelAccountExecutiveEmail = quoteRecord.Pricing_Intel_Account_Exec_Email_Txt__c;
                    mainWrap.FolioName = quoteRecord.Pricing_My_Deals_Folio_Name_Nm__c;
                    mainWrap.FolioID = quoteRecord.Pricing_Folio_ID_Nm__c;
                    mainWrap.endCustomerOpportunityId = quoteRecord.Pricing_End_Customer_Opportunity_Txt__c;
                    mainWrap.referenceRequestId = quoteRecord.Pricing_Customer_Reference_Id__c;
                    mainWrap.secondaryContact = quoteRecord.Pricing_SecondaryContact_Nm__c;
                    mainWrap.quoteType = quoteRecord.Pricing_Program_Type_Nm__c;
                    //mainWrap.AIHostNode = quoteRecord.Pricing_AI_Host_Node_cb__c;
                    mainWrap.onHold = quoteRecord.Pricing_On_Hold_Cb__c;
                    mainWrap.autoGenerateQuoteLetter = quoteRecord.Pricing_Auto_generate_Quote_Letter__c;
                    mainWrap.onRestrictedPartyList = quoteRecord.Pricing_Is_Sanctioned__c;
                    mainWrap.additionalQLRecepients = quoteRecord.Pricing_AdditionalRecipients__c;
                    
                    //New changes start
                    AccountWrapper accWrapper = new AccountWrapper();
                    accWrapper.Name = quoteRecord.Pricing_Account_Name__c;
                    accWrapper.Id = quoteRecord.SBQQ__Account__r.Id;
                    //Forming Customer mapping Id and assigning CIM Id (If CIM Id is present we are passing CIM Id, If not there then we are passing Business party id)
                    accWrapper.CustomerMappingId = Pricing_Tender_Utility.getCIMId(quoteRecord.SBQQ__Account__r.Id,quoteRecord.SBQQ__Account__r.Core_Business_Party_Id__c);
                    mainWrap.Account = accWrapper;
                    //New changes end
                        
                    // Set quote comments
                    mainWrap.quoteComments = quoteIdToCommentsWrapperMap.get(quoteId);
                    
                    // Set the quote lines list for this quote
                    mainWrap.quoteLines = quoteIdToQuoteLinesMap.get(quoteId);
                    
                    String jsonPayload = JSON.serialize(mainWrap);
                    system.debug('JSON PAYLOAD for Quote ' + quoteId + ': ' + jsonPayload);
                    quoteIdToJsonMap.put(String.valueOf(quoteId), jsonPayload);
                    
                    // Collect QuoteLine IDs for this Quote
                    Set<Id> quoteLineIdsForThisQuote = new Set<Id>();//change to set
                    for(QuoteLineWrapper qlw : quoteIdToQuoteLinesMap.get(quoteId)) {
                        quoteLineIdsForThisQuote.add(qlw.Id);
                    }
                    quoteIdToQuoteLineIdsMap.put(String.valueOf(quoteId), quoteLineIdsForThisQuote);
                }
            }
            if(!quoteIdToJsonMap.isEmpty()){
                // Serialize the quoteIdToQuoteLineIdsMap to JSON string for Future method
                String serializedQuoteLineIdsMap = JSON.serialize(quoteIdToQuoteLineIdsMap);
				if(System.isBatch()) {
					makeCDBCallout(quoteIdToJsonMap, serializedQuoteLineIdsMap, recordIdToPrevRetryCountMap);
				} 
				else {//Trigger.isExecuting - future
					makeCDBCalloutWithFuture(quoteIdToJsonMap, serializedQuoteLineIdsMap, recordIdToPrevRetryCountMap);
				}
            }
    
        } catch (Exception exp) {       
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = exp.getMessage(), Core_Origin__c='Pricing_Application_Agent_AI_Integration.populateJSON', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'IQR');          
            insert logEntry;
        }
    }

    /*****************************************************************************************************************************************
    Method Name:        fetchPerformanceMetrics
    Description:        To retrieve performance metrics for quote lines from Pricing_Performance_Metric__c
    @Added By:          Sinduja - 02-April-2026
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    public static Map<Id, List<PerformanceMetricWrapper>> fetchPerformanceMetrics(List<Id> quoteLineIds) {
    Map<Id, List<PerformanceMetricWrapper>> performanceMetricsMap = new Map<Id, List<PerformanceMetricWrapper>>();
    
    if (quoteLineIds == null || quoteLineIds.isEmpty()) {
        return performanceMetricsMap;
    }
    
    try {
        List<Pricing_Performance_Metric__c> performanceMetrics = [
            SELECT Id, Pricing_Quote_Line__c, Pricing_Performance_Metric_Nm__c, Pricing_Weighting_Pct__c, 
                   Pricing_Intel_SKU_Performance_Nbr__c, Pricing_Comp_SKU_Performance_Nbr__c, Pricing_Other_Nm__c
            FROM Pricing_Performance_Metric__c 
            WHERE Pricing_Quote_Line__c IN :quoteLineIds 
            ORDER BY Pricing_Quote_Line__c
        ];
        
        // Map performance metrics by quote line ID
        for (Pricing_Performance_Metric__c metric : performanceMetrics) {
            if(!performanceMetricsMap.containsKey(metric.Pricing_Quote_Line__c)) {
                performanceMetricsMap.put(metric.Pricing_Quote_Line__c, new List<PerformanceMetricWrapper>());
            }
            
            PerformanceMetricWrapper metricWrapper = new PerformanceMetricWrapper();
            metricWrapper.PerformanceMetric = metric.Pricing_Performance_Metric_Nm__c;
            metricWrapper.Weighting = metric.Pricing_Weighting_Pct__c;
            metricWrapper.IntelSKUPerformance = metric.Pricing_Intel_SKU_Performance_Nbr__c;
            metricWrapper.CompSKUPerformance = metric.Pricing_Comp_SKU_Performance_Nbr__c;
            metricWrapper.otherText = metric.Pricing_Other_Nm__c;
            
            performanceMetricsMap.get(metric.Pricing_Quote_Line__c).add(metricWrapper);
        }
        
    } catch (Exception exp) {
        Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Core_Message__c = 'Error retrieving performance metrics', Core_Details__c = exp.getMessage(), 
            Core_Origin__c = 'Pricing_Application_Agent_AI_Integration.fetchPerformanceMetrics', Core_Severity__c = 'Medium', Core_When__c = System.Now(), Core_Project__c = 'IQR');
        insert logEntry;
    }
    
    return performanceMetricsMap;
}
	/***********************************************************************************************************
    Method Name:        makeCDBCalloutWithFuture
    Description:        To call sendCDBPayload method with CDB Payload and handle retry logic in future context
    @Added By:          Sinduja - 02-April-2026
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
	@Future(callout=true)
		public static void makeCDBCalloutWithFuture(Map<String, String> quoteIdToJsonMap, String serializedQuoteLineIdsMap, Map<String, Integer> recordIdToPrevRetryCount){
			makeCDBCallout(quoteIdToJsonMap, serializedQuoteLineIdsMap, recordIdToPrevRetryCount);
		}

    /***********************************************************************************************************
    Method Name:        makeCDBCallout
    Description:        To call sendCDBPayload method with CDB Payload and handle retry logic.
    @Added By:          Sinduja - 02-April-2026
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    public static void makeCDBCallout(Map<String, String> quoteIdToJsonMap, String serializedQuoteLineIdsMap, Map<String, Integer> recordIdToPrevRetryCount)
    {
        try {
            List<Core_CDB_Integration_Log__c> cdbLogList = new List<Core_CDB_Integration_Log__c>();
            List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
            List<Exception> calloutExceptions = new List<Exception>();
            
            // Deserialize the QuoteLine IDs map
            Map<String, List<String>> quoteIdToQuoteLineIdsMap = new Map<String, List<String>>();
            if(String.isNotBlank(serializedQuoteLineIdsMap)) {
                quoteIdToQuoteLineIdsMap = (Map<String, List<String>>) JSON.deserialize(serializedQuoteLineIdsMap, Map<String, List<String>>.class);
            }
            
            // Process each Quote payload (one callout per Quote)
            for (String quoteId : quoteIdToJsonMap.keySet()) {
                
                String payload = quoteIdToJsonMap.get(quoteId);
                List<String> quoteLineIdStrings = quoteIdToQuoteLineIdsMap.get(quoteId);
                
                if (String.isBlank(payload) || quoteLineIdStrings == null || quoteLineIdStrings.isEmpty()) {
                    continue;
                }
                
                // Convert String IDs to Id type
                List<Id> quoteLineIds = new List<Id>();
                Map<Id,Integer> quoteLineIdRetryMap = new Map<Id,Integer>();
                
                for(String qlIdStr : quoteLineIdStrings) {
                   Id quoteLineId = Id.valueOf(qlIdStr);
                   quoteLineIds.add(quoteLineId);
                    
                    // Add QuoteLine record to update list with status 'In Progress'
                    SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
                    ql.Id = quoteLineId;
                    ql.Pricing_Application_Agent_Status__c = 'In Progress';
                    quoteLineList.add(ql);
                    
                    // Calculate retry counter for this Quote
                    Integer newRetryCounter = 0;
                    if (recordIdToPrevRetryCount != null && !recordIdToPrevRetryCount.isEmpty()) {
                        Integer prevRetryCounter = recordIdToPrevRetryCount.get(quoteLineId);
                        if (prevRetryCounter != null) {
                            newRetryCounter = prevRetryCounter + 1;
                        }  
                	}
                    quoteLineIdRetryMap.put(quoteLineId,newRetryCounter);
                }
                
                // Send payload to CDB (ONE callout per Quote)
                HttpResponse res = Pricing_QuoteAgentic_Utility.sendCDBPayload(payload,'APIGEE_PRICING_APPLICATION');
                Boolean isSuccess = (res != null && (res.getStatus() == 'SUCCESS' || res.getStatus() == 'OK' || res.getStatus() == 'Accepted')) ? true : false;
                
                // Handle exceptions
                if (!isSuccess && res != null && res.getStatusCode() == 503 && res.getStatus() == 'APEX_EXCEPTION') {
                    String expnMsg = res.getBody();
                    if (String.isBlank(expnMsg)) {
                        expnMsg = 'Unhandled Apex exception during CDB callout';
                    }
                    calloutExceptions.add(new CDBCalloutException(expnMsg));
                }
            
                
                // OPTIMIZED: Create CDB logs for quoteline records in bulk instead of individual loop
                if(!quoteLineIds.isEmpty()) {
                    List<Core_CDB_Integration_Log__c> bulkCdbLogs = Pricing_QuoteAgentic_Utility.createBulkCDBLogs('Pricing Application Agent', quoteLineIds, res, isSuccess, quoteLineIdRetryMap);
                    if(!bulkCdbLogs.isEmpty()) {
                        cdbLogList.addAll(bulkCdbLogs);
                    }
                }
            }
            
            // Update QuoteLine records
            if(!quoteLineList.isEmpty()){
                SBQQ.TriggerControl.disable();
                Database.SaveResult[] quoteLineUpdateResults = Database.update(quoteLineList);
                SBQQ.TriggerControl.enable();
            }
            
            // Insert log records if we have any
            if (!cdbLogList.isEmpty()) {
                system.debug('INSIDE CDBLOGLIST SIZE:'+cdbLogList.size());
                Pricing_QuoteAgentic_Utility.upsertCDBIntegrationLogList(cdbLogList);
            }
               
          
        }
        catch (Exception exp) {
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = exp.getMessage(), Core_Origin__c='Pricing_Application_Agent_AI_Integration.makeCDBCallout', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'IQR');          
        	insert logEntry;
        }
    }
    /*****************************************************************************************************************************************
    Method Name:        fetchQuoteDetails
    Description:        To Fetch Quote details and return Map<Id,SBQQ__Quote__c>
    @Added By:          Sinduja - 24-April-2026
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    public static Map<Id,SBQQ__Quote__c> fetchQuoteDetails(List<Id> quoteIds) {
        Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap = new Map<Id,SBQQ__Quote__c>();
        
        try {
            // Get Quote data
            quoteIdToQuoteMap =  new Map<Id,SBQQ__Quote__c>([
                SELECT Id,Pricing_Market_Segment_values_Nm__c,Pricing_Account_Name__c,SBQQ__PrimaryContact__r.Name,
                Pricing_End_Customer__r.Name,Pricing_Customer_Nm__c,Pricing_Unified_Global_End_Customer_Nm__r.Name,Pricing_IsUnifiedCustomer__c,
                Pricing_Project_Name_Nm__c,Pricing_Server_Deal_Type_Nm__c,Pricing_Intel_Response_Requested_By_Date__c,
                Pricing_Bid_Dt__c,Pricing_ShipmentStDate_Dt__c,Pricing_ShipmentEndDate_Dt__c,Pricing_Region_Nm__c,Pricing_End_Customer_Country_Nm__c,
                SBQQ__SalesRep__r.Name,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Account_Executive_Nm__r.Name,Pricing_Intel_Account_Exec_Email_Txt__c,
                Pricing_My_Deals_Folio_Name_Nm__c,Pricing_Folio_ID_Nm__c,Pricing_End_Customer_Opportunity_Txt__c,
                Pricing_Customer_Reference_Id__c,Pricing_SecondaryContact_Nm__c,Pricing_Program_Type_Nm__c,
                SBQQ__Account__r.Name,SBQQ__Account__c,SBQQ__Account__r.Core_CIM_ID__c,SBQQ__Account__r.Core_Business_Party_Id__c,Pricing_Deal_Type_Nm__c,Pricing_On_Hold_Cb__c,
                Pricing_Auto_generate_Quote_Letter__c,Pricing_Is_Sanctioned__c,Pricing_AdditionalRecipients__c
                FROM SBQQ__Quote__c 
                WHERE Id IN :quoteIds
              ]);
            
            // Populate the map with Quote Id as key and Quote record as value
            /*for(SBQQ__Quote__c quote : listofQuote) {
                quoteIdToQuoteMap.put(quote.Id, quote);
            }*/
             
        } catch (Exception exp) {       
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = exp.getMessage(), Core_Origin__c='Pricing_Application_Agent_AI_Integration.fetchQuoteDetails', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'IQR');          
            insert logEntry;
        }
        
        return quoteIdToQuoteMap;
    }
    
    /*****************************************************************************************************************************************
    Method Name:        fetchQuoteLineDetails
    Description:        To Fetch QuoteLine details for given Quote Line IDs and return Map<Id,List<QuoteLineWrapper>>
    @Added By:          Sinduja - 02-April-2026
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    public static Map<Id,List<QuoteLineWrapper>> fetchQuoteLineDetails(List<Id> quoteLineIds, Map<Id, List<PerformanceMetricWrapper>> performanceMetricsMap) {
        Map<Id,List<QuoteLineWrapper>> quoteIdToQuoteLineWrappersMap = new Map<Id,List<QuoteLineWrapper>>();
        
        try {
            // Get QuoteLine data with all required fields - 5 fields per line for readability
            List<SBQQ__QuoteLine__c> quoteLines = [
                SELECT Pricing_Status_Nm__c, Pricing_Quote_Line_Number__c, Id, Pricing_Market_Segment_values_Nm__c, Name,
                       Pricing_Product_Name__c, Pricing_Other_Product_Nm__c, Pricing_Processor_Number_Nm__c, Pricing_Approved_Start_Date_Dt__c, Pricing_Approved_End_Date_Dt__c, Pricing_Revised_Pricing_Start_Date_dt__c,
                       Pricing_ECAP_Price_Amt__c, Pricing_Billing_Start_Date_Dt__c, Pricing_Billing_End_Date_Dt__c, Pricing_Approved_Unit_Qty__c, Pricing_pm_approval_comments_nm__c,
                       Pricing_Won_Lost_Comments_Txt__c,Pricing_End_Date_dt__c, Pricing_New_Quantity_qty__c, Pricing_Request_Discount_Unit_Price_qty__c, Pricing_Backdate_Reason_Txt__c, Pricing_OEM_System_Model_Nm__c,
                       Pricing_Systems_qty__c, Pricing_CPUs_per_system_qty__c, Pricing_Single_System_Price_Amt__c, Pricing_OEM_Standard_Unit_Price_Amt__c, Pricing_Req_Discounted_Unit_Price__c,
                       Pricing_Total_Bid_without_Discount_Amt__c, Pricing_Additional_OEM_Discount_Amt__c, Pricing_Net_IA_Bid_Price_Amt__c, Pricing_Intel_Discount_Pct__c, Pricing_OEM_Discount_Pct__c,
                       Pricing_Total_Intel_Discount_Amt__c, Pricing_IA_Bid_Discount_Pct__c, Pricing_Competitor_OEM_Nm__c, Pricing_Competitor_System_Model_Nm__c,Pricing_Competetor_Product__r.Name ,
                       Pricing_Other_Competitor_Product_Nm__c, Pricing_comp_Product_Provider_nm__c, Pricing_Competitor_Systems_Cnt__c, Pricing_Comp_CPUs_per_system_Cnt__c, Pricing_Comp_Units_Cnt__c,
                       Pricing_Comp_Single_System_Price_Amt__c, Pricing_Comp_Additional_OEM_Disc_Amt__c, Pricing_Comp_Total_without_discount_Amt__c, Pricing_Net_Comp_Bid_Price_Amt__c, Pricing_Competitive_Bid_Discount_Pct__c,
                       Pricing_Manager__c, Pricing_FSE_Recommended_Price_Nm__c, Pricing_Additional_Comments_Txt__c, Pricing_Original_Submitted_Date_dt__c, Pricing_Last_Submitted_Date_dt__c,
                       Pricing_Last_Approved_Date_dt__c, Pricing_Last_Submitted_By_Id__r.Name, Pricing_Deal_RFQ_Id__c, Pricing_Meet_Comp_Price_Amt__c, Pricing_Deal_Description__c,
                       Pricing_RegionQL_Nm__c, Pricing_Market_Segment_Nm__c, Pricing_Group_Type_nm__c, Pricing_Additional_T_C_s_Txt__c, Pricng_Exclude_from_Price_Approval_Rules__c,
                       Pricing_Deal_RFQ_Status_Nm__c, Pricing_Integration_Status_Nm__c, Pricing_Error_Messages__c, CreatedBy.Name, CreatedDate,
                       LastModifiedBy.Name, LastModifiedDate, Pricing_Performance_Metric_Nm__c, Pricing_Intel_SKU_Performance_Nbr__c, Pricing_Comp_SKU_Performance_Nbr__c,
                       SBQQ__Quote__c, Pricing_Unit_Qty__c, SBQQ__Quote__r.Pricing_Program_Type_Nm__c, SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,
                       Pricing_Account_Division_Nm__c, Pricing_No_of_GPUs_per_system_nbr__c, Pricing_No_of_GPUs__c, Pricing_Write_In_Paired_CPU_Nm__c,
                       Pricing_Comp_No_of_GPUs_per_Sys__c, Pricing_Competitor_No_of_GPUs__c, Pricing_DealProduct_Nm__c, Pricing_Comp_Unit_Price_Amt__c,
                       Pricing_Density__c, Pricing_Units_per_system_qty__c, Pricing_ReqDiscUnitPricePerGB_Amt__c, Pricing_CPU_Txt__c,
                       Pricing_DRAM_Density_Nbr__c,Pricing_DRAM_per_System_qty__c, Pricing_Comp_Density_Nbr__c, Pricing_CompUnitPricePerGB_Amt__c, Pricing_Workload_Txt__c,
                	   Pricing_Sales_Rep_Approver__r.Name,Pricing_Payable_Quantity__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Region__c,Pricing_Consumption_Segment__c,
                	   Pricing_Consumption_Platform__c,Pricing_Consumption_Country__c,Pricing_Product_Nm__c,Pricing_Product_Nm__r.Core_Product_Name_EPM_ID__c,
                	   Pricing_Product_Nm__r.Core_Product_Type__c,Pricing_Program_Type_Nm__c,Pricing_POC_testing_results_Txt__c,Pricing_Server_Integration_Nm__c,Pricing_Family_Name_Nm__c,Pricing_VolumeByQuarterAndReasoning_Txt__c,
            		   Pricing_Form_Factor_Nm__c,Pricing_New_Change_Request_cb__c,Pricing_SDM_Fast_Track__c,Pricing_Lost_Reason_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,
                	   Pricing_Rejection_Comments_nm__c,Pricing_Product_Nm__r.Core_Processor_Number_Nm__c
                FROM SBQQ__QuoteLine__c 
                WHERE Id IN :quoteLineIds
            ];
            
            // Initialize map for all unique quote IDs
            Set<Id> uniqueQuoteIds = new Set<Id>();
            for(SBQQ__QuoteLine__c quoteLine : quoteLines) {
                uniqueQuoteIds.add(quoteLine.SBQQ__Quote__c);
            }
            
            for(Id quoteId : uniqueQuoteIds) {
                quoteIdToQuoteLineWrappersMap.put(quoteId, new List<QuoteLineWrapper>());
            }
            
            // Process each quote line and populate all fields
            for(SBQQ__QuoteLine__c quoteLine : quoteLines){
                QuoteLineWrapper quoteLineWrap = new QuoteLineWrapper();
                
                //New change start
                ProductWrapper productWrapper = new ProductWrapper();
                productWrapper.ProductNameEPMID = quoteLine.Pricing_Product_Nm__r.Core_Product_Name_EPM_ID__c;
                productWrapper.ProductLevel = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? 'Processor' :
                                quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_SSD_Quote ? 'Family' :
                                quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_PMem_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_NIC_Quote? 'DealProductName' : null;
                            
                productWrapper.Name = quoteLine.Pricing_Product_Name__c;
                productWrapper.Id =  quoteLine.Pricing_Product_Nm__c;
                productWrapper.ProcessorNumber = quoteLine.Pricing_Product_Nm__r.Core_Processor_Number_Nm__c;
                quoteLineWrap.Product = productWrapper;
                //New change start end
                
                // Populate fields in the exact order from wrapper
                quoteLineWrap.Status = quoteLine.Pricing_Status_Nm__c;
                quoteLineWrap.QuoteLineNumber = quoteLine.Pricing_Quote_Line_Number__c;
                quoteLineWrap.Id = quoteLine.Id;
                
                if(quoteLine.SBQQ__Quote__r.Pricing_Program_Type_Nm__c == 'Data Center'){
                    quoteLineWrap.MarketSegment = quoteLine.Pricing_Market_Segment_values_Nm__c;
                }
                
                quoteLineWrap.Name = quoteLine.Name;
                quoteLineWrap.OtherProduct = quoteLine.Pricing_Other_Product_Nm__c;//indicates writeInProduct
                quoteLineWrap.processor = quoteLine.Pricing_Processor_Number_Nm__c;
                quoteLineWrap.ApprovedStartDate = quoteLine.Pricing_Approved_Start_Date_Dt__c;
                quoteLineWrap.ApprovedEndDate = quoteLine.Pricing_Approved_End_Date_Dt__c;
                quoteLineWrap.EffectivePricingStartDate = quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
                quoteLineWrap.ApprovedECAPPrice = quoteLine.Pricing_ECAP_Price_Amt__c;
                quoteLineWrap.BillingStartDate = quoteLine.Pricing_Billing_Start_Date_Dt__c;
                quoteLineWrap.BillingEndDate = quoteLine.Pricing_Billing_End_Date_Dt__c;
                quoteLineWrap.ApprovedQuantity = quoteLine.Pricing_Approved_Unit_Qty__c;
                quoteLineWrap.approvalComments = quoteLine.Pricing_pm_approval_comments_nm__c;
                quoteLineWrap.wonLostComments = quoteLine.Pricing_Won_Lost_Comments_Txt__c;
                quoteLineWrap.quoteLineEndDate = quoteLine.Pricing_End_Date_dt__c;
                quoteLineWrap.newQuantity = quoteLine.Pricing_New_Quantity_qty__c;
                quoteLineWrap.newRequestedPrice = quoteLine.Pricing_Request_Discount_Unit_Price_qty__c;
                quoteLineWrap.BackdateReason = quoteLine.Pricing_Backdate_Reason_Txt__c;
                quoteLineWrap.systemModel = quoteLine.Pricing_OEM_System_Model_Nm__c;
                quoteLineWrap.noOfSystems = quoteLine.Pricing_Systems_qty__c;
                quoteLineWrap.noOfCPUPerSystem = quoteLine.Pricing_CPUs_per_system_qty__c;
                quoteLineWrap.singleSystemPricePoint = quoteLine.Pricing_Single_System_Price_Amt__c;
                quoteLineWrap.customerStandardUnitPrice = quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c;
                quoteLineWrap.requestedUnitPrice = quoteLine.Pricing_Req_Discounted_Unit_Price__c;
                quoteLineWrap.totalBidWithoutDiscount = quoteLine.Pricing_Total_Bid_without_Discount_Amt__c;
                quoteLineWrap.additionalDiscount = quoteLine.Pricing_Additional_OEM_Discount_Amt__c;
                quoteLineWrap.netIntelBidPrice = quoteLine.Pricing_Net_IA_Bid_Price_Amt__c;
                quoteLineWrap.intelDiscount = quoteLine.Pricing_Intel_Discount_Pct__c;
                quoteLineWrap.customerDiscount = quoteLine.Pricing_OEM_Discount_Pct__c;
                quoteLineWrap.totalIntelDiscount = quoteLine.Pricing_Total_Intel_Discount_Amt__c;
                quoteLineWrap.intelBidDiscount = quoteLine.Pricing_IA_Bid_Discount_Pct__c;
                quoteLineWrap.competitorName = quoteLine.Pricing_Competitor_OEM_Nm__c;
                quoteLineWrap.competitorSystemModel = quoteLine.Pricing_Competitor_System_Model_Nm__c;
                quoteLineWrap.competitorProduct = quoteLine.Pricing_Competetor_Product__r.Name;
                quoteLineWrap.OtherCompetitorProduct = quoteLine.Pricing_Other_Competitor_Product_Nm__c;//indicates writeInCompetitorProduct 
                quoteLineWrap.competitorProductProvider = quoteLine.Pricing_comp_Product_Provider_nm__c;
                quoteLineWrap.compNoOfSystems = quoteLine.Pricing_Competitor_Systems_Cnt__c;
                quoteLineWrap.compNoOfUnitsPerSystem = quoteLine.Pricing_Comp_CPUs_per_system_Cnt__c;
                quoteLineWrap.competitorQuantity = quoteLine.Pricing_Comp_Units_Cnt__c;//check
                quoteLineWrap.compSingleSystemPrice = quoteLine.Pricing_Comp_Single_System_Price_Amt__c;
                quoteLineWrap.compAdditionalDiscount = quoteLine.Pricing_Comp_Additional_OEM_Disc_Amt__c;
                quoteLineWrap.compTotalWithoutDiscount = quoteLine.Pricing_Comp_Total_without_discount_Amt__c;
                quoteLineWrap.netCompBidPrice = quoteLine.Pricing_Net_Comp_Bid_Price_Amt__c;
                quoteLineWrap.compBidDiscount = quoteLine.Pricing_Competitive_Bid_Discount_Pct__c;
                quoteLineWrap.pricingManager = quoteLine.Pricing_Manager__c;
                quoteLineWrap.whatIsNeededToWinBid = quoteLine.Pricing_FSE_Recommended_Price_Nm__c;
                quoteLineWrap.additionalComments = quoteLine.Pricing_Additional_Comments_Txt__c;
                quoteLineWrap.firstSubmittedDate = quoteLine.Pricing_Original_Submitted_Date_dt__c;
                quoteLineWrap.lastSubmittedDate = quoteLine.Pricing_Last_Submitted_Date_dt__c;
                quoteLineWrap.approvedRejectedDate = quoteLine.Pricing_Last_Approved_Date_dt__c;
                quoteLineWrap.lastSubmittedBy = quoteLine.Pricing_Last_Submitted_By_Id__r.Name;
                quoteLineWrap.dealId = quoteLine.Pricing_Deal_RFQ_Id__c;
                quoteLineWrap.MeetCompPrice = quoteLine.Pricing_Meet_Comp_Price_Amt__c;
                quoteLineWrap.DealDescription = quoteLine.Pricing_Deal_Description__c;
                quoteLineWrap.Region = quoteLine.Pricing_RegionQL_Nm__c;
                quoteLineWrap.MarketSegment = quoteLine.Pricing_Market_Segment_Nm__c;
                quoteLineWrap.GroupType = quoteLine.Pricing_Group_Type_nm__c;
                quoteLineWrap.AdditionalTandC = quoteLine.Pricing_Additional_T_C_s_Txt__c;
                quoteLineWrap.excludeFromPriceRules = quoteLine.Pricng_Exclude_from_Price_Approval_Rules__c;
                quoteLineWrap.dealStatus = quoteLine.Pricing_Deal_RFQ_Status_Nm__c;
                quoteLineWrap.IntegrationStatus = quoteLine.Pricing_Integration_Status_Nm__c;
                quoteLineWrap.errorMessage = quoteLine.Pricing_Error_Messages__c;
                quoteLineWrap.createdBy = quoteLine.CreatedBy.Name;
                quoteLineWrap.createdDate = quoteLine.CreatedDate;
                quoteLineWrap.lastModifiedBy = quoteLine.LastModifiedBy.Name;
                quoteLineWrap.lastModifiedDate = quoteLine.LastModifiedDate;
                quoteLineWrap.quantity = quoteLine.Pricing_Unit_Qty__c;
                quoteLineWrap.CustomerDivision = quoteLine.Pricing_Account_Division_Nm__c;
                quoteLineWrap.noOfGPUPerSystem = quoteLine.Pricing_No_of_GPUs_per_system_nbr__c;
				quoteLineWrap.noOfGPU = quoteLine.Pricing_No_of_GPUs__c;    
                quoteLineWrap.writeInPairedCPU = quoteLine.Pricing_Write_In_Paired_CPU_Nm__c; 
                quoteLineWrap.competitorNoOfGPUPerSystem = quoteLine.Pricing_Comp_No_of_GPUs_per_Sys__c; 
                quoteLineWrap.competitorNoOfGPU = quoteLine.Pricing_Competitor_No_of_GPUs__c; 
                quoteLineWrap.competitorPairedCPU = quoteLine.Pricing_Competitor_No_of_GPUs__c; 
                quoteLineWrap.forecastProductName = quoteLine.Pricing_DealProduct_Nm__c; 
                quoteLineWrap.competitorSingleSystemPricePoint = quoteLine.Pricing_Comp_Unit_Price_Amt__c; 
                quoteLineWrap.densityGB = quoteLine.Pricing_Density__c; 
                quoteLineWrap.noOfUnitsPerSystem = quoteLine.Pricing_Units_per_system_qty__c; 
                quoteLineWrap.requestedDiscountUnitPriceGB = quoteLine.Pricing_ReqDiscUnitPricePerGB_Amt__c; 
                quoteLineWrap.pairedCPU = quoteLine.Pricing_CPU_Txt__c; 
                quoteLineWrap.dramDensityGB = quoteLine.Pricing_DRAM_Density_Nbr__c; 
                quoteLineWrap.noOfDRAMPerSystem = quoteLine.Pricing_DRAM_per_System_qty__c; 
                quoteLineWrap.competitorDensityGB = quoteLine.Pricing_Comp_Density_Nbr__c; 
                quoteLineWrap.competitorUnitPriceGB = quoteLine.Pricing_CompUnitPricePerGB_Amt__c;
                quoteLineWrap.workload = quoteLine.Pricing_Workload_Txt__c;
                quoteLineWrap.salesRepApprover = quoteLine.Pricing_Sales_Rep_Approver__r.Name;
                quoteLineWrap.PayableQuantity = quoteLine.Pricing_Payable_Quantity__c;
                quoteLineWrap.ConsumptionReportedSalesGeo = quoteLine.Pricing_Consumption_Sale_Geo__c;
                quoteLineWrap.ConsumptionRegion = quoteLine.Pricing_Consumption_Region__c;
                quoteLineWrap.ConsumptionCustomerSegment = quoteLine.Pricing_Consumption_Segment__c;
                quoteLineWrap.ConsumptionCustomerPlatform = quoteLine.Pricing_Consumption_Platform__c;
                quoteLineWrap.ConsumptionCountry = quoteLine.Pricing_Consumption_Country__c;
                quoteLineWrap.ProductType = quoteLine.Pricing_Product_Nm__r.Core_Product_Type__c;
                quoteLineWrap.pocTestingResults = quoteLine.Pricing_POC_testing_results_Txt__c;
                quoteLineWrap.serverIntegration = quoteLine.Pricing_Server_Integration_Nm__c;
                quoteLineWrap.familyName = quoteLine.Pricing_Family_Name_Nm__c;
                quoteLineWrap.volumeByQuarterAndReasoning = quoteLine.Pricing_VolumeByQuarterAndReasoning_Txt__c;
                quoteLineWrap.formFactor =  quoteLine.Pricing_Form_Factor_Nm__c;
                quoteLineWrap.changeRequest = quoteLine.Pricing_New_Change_Request_cb__c;
                quoteLineWrap.sdmFastTrack = quoteLine.Pricing_SDM_Fast_Track__c;
                quoteLineWrap.lostReason = quoteLine.Pricing_Lost_Reason_Nm__c;
                quoteLineWrap.referenceQuoteLineNumber = quoteLine.Pricing_Reference_Quote_Line_Nbr__c;
                quoteLineWrap.rejectionCancellationComments = quoteLine.Pricing_Rejection_Comments_nm__c;
                                  
                //Populate performance metrics from PerformanceMetricWrapper list
                if (performanceMetricsMap != null && performanceMetricsMap.containsKey(quoteLine.Id)) {
                    if(quoteLine.SBQQ__Quote__r.Pricing_Program_Type_Nm__c == 'Data Center'){
                        // For Data Center quotes, use the performance metrics from the custom object
                        quoteLineWrap.performanceMetrics = performanceMetricsMap.get(quoteLine.Id);
                    }
                    
                } else {
                    // Initialize empty list if no performance metrics found
                    quoteLineWrap.performanceMetrics = new List<PerformanceMetricWrapper>();
                }
                
                //If Client take perfromance metric from quoteline
                if(quoteLine.SBQQ__Quote__r.Pricing_Program_Type_Nm__c == 'Client'){
                    
                    quoteLineWrap.performanceMetricsUsed = quoteLine.Pricing_Performance_Metric_Nm__c;
                    quoteLineWrap.intelScore = quoteLine.Pricing_Intel_SKU_Performance_Nbr__c;
                    quoteLineWrap.compScore = quoteLine.Pricing_Comp_SKU_Performance_Nbr__c;
                }
                
                // Add the wrapper to the appropriate quote's list
                quoteIdToQuoteLineWrappersMap.get(quoteLine.SBQQ__Quote__c).add(quoteLineWrap);
            }
            
            system.debug('Quote ID to QuoteLine Wrappers Map: ' + quoteIdToQuoteLineWrappersMap);
            
        } catch (Exception exp) {       
            system.debug('INSIDE QUOTELINEWRAPPER EXECPETION:'+exp);
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Core_Message__c = 'Error', Core_Details__c = exp.getMessage(), Core_Origin__c='Pricing_Application_Agent_AI_Integration.fetchQuoteLineDetails', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'IQR');
            insert logEntry;
        }
        
        return quoteIdToQuoteLineWrappersMap;
    }
    
    /***********************************************************************************************************
    Method Name:        getQuoteCommentsData
    Description:        Query and return scorecard data for given case IDs
    Added By:           Sinduja/Shubhra 02-02-2025
    ************************************************************************************************************/
    public static Map<Id,List<QuoteCommentWrapper>> getQuoteCommentsWrapper(Set<Id> quoteIds) {
        Map<Id,List<QuoteCommentWrapper>> quoteIdToCommentsWrapMap = new Map<Id,List<QuoteCommentWrapper>>();
              
        try {
            // Initialize map for all quote IDs
            for(Id quoteId : quoteIds) {
                quoteIdToCommentsWrapMap.put(quoteId, new List<QuoteCommentWrapper>());
            }
            
            // Query Pricing_Comments__c records
            for (Pricing_Comments__c commentRec : [
                SELECT Id, Pricing_Quote__c,
                    Pricing_Question__c, Pricing_Answer__c, Pricing_Comment_Ref_Id__c
                FROM Pricing_Comments__c 
                WHERE Pricing_Quote__c IN :quoteIds
            ]) {
                // Create new QuoteCommentWrapper for each Pricing_Comments__c record
                QuoteCommentWrapper commentWrapper = new QuoteCommentWrapper();
                
                // Populate the wrapper fields from Pricing_Comments__c fields
                commentWrapper.question = commentRec.Pricing_Question__c;     
                commentWrapper.answer = commentRec.Pricing_Answer__c;         
                commentWrapper.referenceId = commentRec.Pricing_Comment_Ref_Id__c; 
                
                // Add the wrapper to the map
                quoteIdToCommentsWrapMap.get(commentRec.Pricing_Quote__c).add(commentWrapper);
            }
            
        } catch (Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
        }
        
        return quoteIdToCommentsWrapMap;
}
	//Quote Wrapper
   public class MainWrapper extends Pricing_JSONString.Quote
  {
        public String primaryContact;
        public String writeInEndCustomer;
        public Date intelResponseRequestedByDate;
        public Date proposalDueDate;
        public String endCustSalesGeo;
        public String EndCustomerCountry;
        public String salesRep;
        public String intelSalesRepEmail;
        public String intelAccountExecutive;
        public String intelAccountExecutiveEmail;
        public String endCustomerOpportunityId;
        public String referenceRequestId;
        public String secondaryContact;
        public String quoteType;
        public AccountWrapper Account;
      	public Boolean onHold;
      	public Boolean autoGenerateQuoteLetter;
      	public Boolean onRestrictedPartyList;
      	public String additionalQLRecepients;
        public List<QuoteLineWrapper> quoteLines; //List of QuoteLines 
        public List<QuoteCommentWrapper> quoteComments; //Quote Comments
   }
    public class QuoteLineWrapper extends Pricing_JSONString.QuoteLine{
        public String processor;
        public String approvalComments;
        public String wonLostComments;
        public Date quoteLineEndDate;
        public Decimal newQuantity;
        public Decimal newRequestedPrice;
        public String systemModel;
        public Decimal noOfSystems;
        public Decimal noOfCPUPerSystem;
        public Decimal quantity;
        public Decimal singleSystemPricePoint;
        public Decimal customerStandardUnitPrice;
        public Decimal requestedUnitPrice;
        public Decimal totalBidWithoutDiscount;
        public Decimal additionalDiscount;
        public Decimal netIntelBidPrice;
        public Decimal intelDiscount;
        public Decimal customerDiscount;
        public Decimal totalIntelDiscount;
        public Decimal intelBidDiscount;
        public String competitorName;
        public String competitorSystemModel;
        public String competitorProduct;
        public String competitorProductProvider;
        public Decimal compNoOfSystems;
        public Decimal compNoOfUnitsPerSystem;
        public Decimal competitorQuantity;
        public Decimal compSingleSystemPrice;
        public Decimal compAdditionalDiscount;
        public Decimal compTotalWithoutDiscount;
        public Decimal netCompBidPrice;
        public Decimal compBidDiscount;
        public String pricingManager;
        public String whatIsNeededToWinBid;
        public String additionalComments;
        public DateTime firstSubmittedDate;
        public DateTime lastSubmittedDate;
        public DateTime approvedRejectedDate;
        public String lastSubmittedBy;
        public String dealId;
        public Boolean excludeFromPriceRules;
        public String dealStatus;
        public String errorMessage;
        public String createdBy;
        public DateTime createdDate;
        public String lastModifiedBy;
        public DateTime lastModifiedDate;
        public String performanceMetricsUsed;
        public Decimal intelScore;
        public Decimal compScore;
        public Decimal noOfGPUPerSystem;
        public Decimal noOfGPU;
		public String writeInPairedCPU;
        public Decimal competitorNoOfGPUPerSystem;
        public Decimal competitorNoOfGPU;
        public Decimal competitorPairedCPU; 
        public String forecastProductName;
        public Decimal competitorSingleSystemPricePoint;
        public Decimal densityGB;
        public Decimal noOfUnitsPerSystem;
        public Decimal requestedDiscountUnitPriceGB;
        public String pairedCPU;
        public Decimal dramDensityGB;
        public Decimal noOfDRAMPerSystem;
        public Decimal competitorDensityGB;
        public Decimal competitorUnitPriceGB;
        public String workload;
        public String salesRepApprover;
        public String pocTestingResults;//new
        public String serverIntegration;//new 
        public String familyName;//new
        public String volumeByQuarterAndReasoning;//new
        public String formFactor;//new
        public Boolean changeRequest;//new
        public Boolean sdmFastTrack;//new
        public String lostReason;//new
        public String referenceQuoteLineNumber;//new
        public String rejectionCancellationComments;//new
        public List<PerformanceMetricWrapper> performanceMetrics;//List of Performance Metrics
    }

    //Performance Metric Wrapper Class
    public class PerformanceMetricWrapper extends Pricing_JSONString.PerformanceMetric  {
        public String otherText;
    }
    
    public class ProductWrapper extends Pricing_JSONString.Product{}
    public class AccountWrapper extends Pricing_JSONString.Account{}

    // Quote Comment Wrapper
    public class QuoteCommentWrapper {
        public String question;
        public String answer;
        public String referenceId;
    }
    // Custom exception for callout errors that can be instantiated anywhere
     public class CDBCalloutException extends Exception {}
}