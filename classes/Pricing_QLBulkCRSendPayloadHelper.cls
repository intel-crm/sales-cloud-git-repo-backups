/**
* @description       : Helper class is created to generate payload and send request to MyDeals
* @author            : Rahul Maindalkar
* @group             : 
* @last modified on  : 04-10-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QLBulkCRSendPayloadHelper {
    public static Boolean WWID_val = [Select Id, User_WWID__c from Pricing_Bulk_Change_Request__mdt where DeveloperName='Bulk_CR_001'].User_WWID__c;    
    /**
* @description Method to generate the MyDeals payload and send request to MyDeals 
* @author Rahul Maindalkar | 08-24-2022 
* @param quoteLineIdSet 
* @param quoteLineData
* @param actionUpdate 
* @param groupByQuote 
**/     
    public static Map<Id, String> createpayload(Set<Id> quoteLineIdSet,List<SBQQ__QuoteLine__c> quoteLineData , String actionUpdate, Boolean groupByQuote){
        String wwid;
        if(WWID_val){
            User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];
            wwid=loggedInUser.Core_WWID__c;
        }
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        Map<Id,String> quoteLineIdToSuccessOrErrorMap = new Map<Id,String>();
        List<SBQQ__QuoteLine__c> quoteLineToUpdate = new List<SBQQ__QuoteLine__c>();
        if ((!mapFunctionalityNameTriggerExecution.isEmpty() &&
             mapFunctionalityNameTriggerExecution.containsKey('pricingSendOutboundMessagesIQR') &&
             mapFunctionalityNameTriggerExecution.get('pricingSendOutboundMessagesIQR').Core_Active__c) || Test.isRunningTest()){
                 
                 try{
                     Map<String,List<SBQQ__QuoteLine__c>> quoteIdToQuoteLineMap = new Map<String,List<SBQQ__QuoteLine__c>>();    //key(QuoteId + Action) Value(List of QuoteLine with Similar Action)
                     List<Pricing_Integration_Staging__c> PISList = new List<Pricing_Integration_Staging__c>();  //List of Integration OutBound Message 
                     List<Id> quoteIds = new List<Id>();
                     List<String> endCustomers = new List<String>();
                     List<String> endCustomerCountrys = new List<String>();
                     for(SBQQ__QuoteLine__c quoteLine  : quoteLineData){
                         if(quoteIdToQuoteLineMap.containsKey(''+quoteLine.SBQQ__Quote__c+':'+actionUpdate)){
                             quoteIdToQuoteLineMap.get(''+quoteLine.SBQQ__Quote__c+':'+actionUpdate).add(quoteLine);
                         }else{
                             quoteIdToQuoteLineMap.put(''+quoteLine.SBQQ__Quote__c+':'+actionUpdate,new List<SBQQ__QuoteLine__c>{quoteLine});
                         }                                                                               
                     }
                     List<Pricing_BulkCR_JSONString.Quote> quoteList = New List<Pricing_BulkCR_JSONString.Quote>();
                     String quoteIdval; 
                     String quotelineIdval;
                     for(String quoteIdActionStr : quoteIdToQuoteLineMap.keySet()){
                         List<SBQQ__QuoteLine__c> quoteLinesList = quoteIdToQuoteLineMap.get(quoteIdActionStr);
                         Pricing_BulkCR_JSONString jsonString = new Pricing_BulkCR_JSONString();
                         Pricing_BulkCR_JSONString.Quote quote = new Pricing_BulkCR_JSONString.Quote();
                         Pricing_BulkCR_JSONString.Header header = new Pricing_BulkCR_JSONString.Header();
                         Pricing_BulkCR_JSONString.RecordDetails recordDetails = new Pricing_BulkCR_JSONString.RecordDetails();
                         
                         //Add Quote Details to the JSON
                         quote.Id = quoteLinesList[0].SBQQ__Quote__c;
                         quote.Name = quoteLinesList[0].SBQQ__Quote__r.Name;
                         quote.EndCustomerCountry = quoteLinesList[0].SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c;
                         quote.FolioID = quoteLinesList[0].SBQQ__Quote__r.Pricing_Folio_ID_Nm__c;
                         quote.DealType = quoteLinesList[0].SBQQ__Quote__r.Pricing_Deal_Type_Nm__c;
                         quote.ProjectName = quoteLinesList[0].SBQQ__Quote__r.Pricing_Project_Name_Nm__c;
                         quote.ShipmentStartDate = quoteLinesList[0].SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c;
                         quote.ShipmentEndDate = quoteLinesList[0].SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c;  
                         quote.ServerDealType = quoteLinesList[0].SBQQ__Quote__r.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? null : quoteLinesList[0].SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c;                       
                         quote.FolioName = quoteLinesList[0].SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c;
                         quote.EndCustomer =quoteLinesList[0].SBQQ__Quote__r.Pricing_Customer_Nm__c; //write in field
                         quote.UnifiedEndCustomer = (quoteLinesList[0].SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == true)?quoteLinesList[0].SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name:quoteLinesList[0].SBQQ__Quote__r.Pricing_End_Customer__r.Name; //lookup field
                         quote.UnifiedEndCustomerId = (quoteLinesList[0].SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c == true)?quoteLinesList[0].SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c:quoteLinesList[0].SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c; 
                         quote.UnifiedCountryEndCustomerId =quoteLinesList[0].SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c;                        
                         quote.IsUnifiedEndCustomer = quoteLinesList[0].SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c;
                         quote.UnifiedEndCustomerGlobalName = quoteLinesList[0].SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Name;
                         quote.ComplianceWatchList = quoteLinesList[0].SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c;
                         if(!quote.IsUnifiedEndCustomer){
                             quoteIds.add(quote.Id);
                         }
                         endCustomers.add(quoteLinesList[0].SBQQ__Quote__r.Pricing_End_Customer_Name__c);
                         endCustomerCountrys.add(quote.EndCustomerCountry);
                         
                         Pricing_BulkCR_JSONString.Account acc = new Pricing_BulkCR_JSONString.Account();
                         acc.Id = quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Id;
                         
                         acc.CIMId = Pricing_Tender_Utility.getCIMId(quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Id, quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c);
                         //Forming Customer mapping Id and assigning CIM Id (If CIM Id is present we are passing CIM Id, If not there then we are passing Business party id)
                         acc.CustomerMappingId = Pricing_Tender_Utility.getCIMId(quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Id, quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c);
                         
                         acc.Name = quoteLinesList[0].SBQQ__Quote__r.SBQQ__Account__r.Name;
                         quote.Account = acc;
                         
                         List<Pricing_BulkCR_JSONString.QuoteLine> quoteLineList = new List<Pricing_BulkCR_JSONString.QuoteLine>();
                         for(SBQQ__QuoteLine__c quoteLine : quoteLinesList){
                             Pricing_BulkCR_JSONString.QuoteLine quoteLines = new Pricing_BulkCR_JSONString.QuoteLine();
                             quoteLines.Id = quoteLine.Id;
                             quoteLines.Name = quoteLine.Name;
                             quoteLines.ApprovedECAPPrice = quoteLine.Pricing_ECAP_Price_Amt__c;
                             quoteLines.MeetCompPrice = quoteLine.Pricing_Meet_Comp_Price_Amt__c;
                             quoteLines.ApprovedQuantity = quoteLine.Pricing_Approved_Unit_Qty__c;
                             quoteLines.PayableQuantity = quoteLine.Pricing_Payable_Quantity__c;
                             quoteLines.ApprovedStartDate = quoteLine.Pricing_Approved_Start_Date_Dt__c;
                             quoteLines.ApprovedEndDate = quoteLine.Pricing_Approved_End_Date_Dt__c;
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
                             quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU ? 'Graphics' :
                            'Ethernet';
                             quoteLines.WWID = WWID_val ? wwid : quoteLine.Pricing_Manager__r.Core_WWID__c;
                             quoteLines.OtherCompetitorProduct = quoteLine.Pricing_Other_Competitor_Product_Nm__c;
                             quoteLines.Region = quoteLine.Pricing_RegionQL_Nm__c;//'Worldwide';
                             quoteLines.EndCustomerRegion = quoteLine.SBQQ__Quote__r.Pricing_Region_Nm__c;//quoteLine.Pricing_Region_Nm__c;
                             quoteLines.BackdateReason = quoteLine.Pricing_Backdate_Reason_Txt__c;
                             quoteLines.BillingEndDate = quoteLine.Pricing_Billing_End_Date_Dt__c;
                             quoteLines.BillingStartDate = quoteLine.Pricing_Billing_Start_Date_Dt__c;
                             quoteLines.GroupType = quoteLine.Pricing_Group_Type_nm__c;
                             quoteLines.MarketSegment = quoteLine.SBQQ__Quote__r.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? quoteLine.SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c: quoteLine.Pricing_Market_Segment_values_Nm__c;
                             quoteLines.AdditionalTandC = quoteLine.Pricing_Additional_T_C_s_Txt__c;
                             quoteLines.ExcludeAutomation = quoteLine.Pricng_Exclude_from_Price_Approval_Rules__c;
                             quoteLines.EffectivePricingStartDate = quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
                             quoteLines.DealDescription = quoteLine.Pricing_Deal_Description__c;
                             quoteLines.CustomerDivision = quoteLine.Pricing_Account_Division_Nm__c != null ? quoteLine.Pricing_Account_Division_Nm__c.replaceAll(';','/') : quoteLine.Pricing_Account_Division_Nm__c;
                             //in MyDeals for Consumption Region APJ value is not there.so replacing APJ with APAC,IJKK and sending to MyDeals.
                            quoteLines.ConsumptionRegion = !String.isBlank(quoteLine.Pricing_Consumption_Region__c) ? quoteLine.Pricing_Consumption_Region__c.contains('APJ') ? quoteLine.Pricing_Consumption_Region__c.replace('APJ', 'APAC,IJKK').replaceAll(', ',',') : quoteLine.Pricing_Consumption_Region__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Region__c;
                            quoteLines.ConsumptionCustomerPlatform = quoteLine.Pricing_Consumption_Platform__c != null ? quoteLine.Pricing_Consumption_Platform__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Platform__c;
                            quoteLines.ConsumptionCountry = quoteLine.Pricing_Consumption_Country__c != null ? quoteLine.Pricing_Consumption_Country__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Country__c;
                            quoteLines.ConsumptionReportedSalesGeo = quoteLine.Pricing_Consumption_Sale_Geo__c != null ? quoteLine.Pricing_Consumption_Sale_Geo__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Sale_Geo__c;
                            quoteLines.ConsumptionCustomerSegment = quoteLine.Pricing_Consumption_Segment__c != null ? quoteLine.Pricing_Consumption_Segment__c.replaceAll(', ',',') : quoteLine.Pricing_Consumption_Segment__c;
                             
                             Pricing_BulkCR_JSONString.Product prod = new Pricing_BulkCR_JSONString.Product();
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
                             Pricing_BulkCR_JSONString.CompetitorProduct compProd = new Pricing_BulkCR_JSONString.CompetitorProduct();
                             compProd.Id = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || !Label.Pricing_Tender_ExceptionQuoteType.split(',').contains(quoteLine.Pricing_Program_Type_Nm__c) ? quoteLine.Pricing_Competetor_Product__r.Id : null;
                             compProd.Name = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || !Label.Pricing_Tender_ExceptionQuoteType.split(',').contains(quoteLine.Pricing_Program_Type_Nm__c) ? (quoteLine.Pricing_Competetor_Product__r.Name == 'Write In Product' ? quoteline.Pricing_Other_Competitor_Product_Nm__c : quoteLine.Pricing_Competetor_Product__r.Name) : quoteLine.Pricing_Comp_Product_Txt__c;
                             quoteLines.CompetitorProduct = compProd;
                             
                             List<Pricing_BulkCR_JSONString.PerformanceMetric> performanceMetric = new List<Pricing_BulkCR_JSONString.PerformanceMetric>();
                             if(Label.Pricing_Tender_ExceptionQuoteType.split(',').contains(quoteLine.Pricing_Program_Type_Nm__c))
                             {
                                 Pricing_BulkCR_JSONString.PerformanceMetric perMetric = new Pricing_BulkCR_JSONString.PerformanceMetric();
                                 performanceMetric.add(perMetric);
                                 quoteLines.PerformanceMetric = performanceMetric;
                             }
                             else{
                                 for(Pricing_Performance_Metric__c pm : quoteLine.Performance_Metrics__r){
                                     //Add Performance Metrics to JSON
                                     Pricing_BulkCR_JSONString.PerformanceMetric perMetric = new Pricing_BulkCR_JSONString.PerformanceMetric();
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
                         
                         if(groupByQuote){
                             
                             //Update the Header Details of the JSON
                             header.source_system = Label.Pricing_Tender_MyDeal_Integration_SystemTender;
                             header.target_system = Label.Pricing_Tender_MyDeal_Integration_SystemMyDeal;
                             header.action = (quoteIdActionStr.split(':'))[1];
                             header.xid = Pricing_Tender_Utility.getGUID();                            
                             
                             quote.QuoteLine = quoteLineList;
                             quoteList.add(quote);
                             recordDetails.Quote = quoteList;
                             jsonString.Header = header;
                             jsonString.RecordDetails = recordDetails;
                             
                             //Serialize the JSON
                             String jsonData = JSON.serialize(jsonString); 
                             
                             string Status ;
                             jsonData = jsonData.replace('{"Quote":[{','{"Quote":{');
                             jsonData = jsonData.replace(']},"Header":','},"Header":');   
                             string response = sendPayloadBulkCR(jsonData);  // MyDeal Callout
                             if(response == 'Failed'){
                                 Status = 'Failed';
                             }
                             else{
                                 Status = 'Successful'; 
                             }
                             
                             PISList.add(new Pricing_Integration_Staging__c(Pricing_Message_Type__c = Label.Pricing_Tender_MyDeal_Integration_SystemTender,
                                                                            Pricing_Payload__c = jsonData,
                                                                            Pricing_SObjectId__c= quoteLinesList[0].SBQQ__Quote__c+ ' ' + '-' + ' ' +quoteLinesList[0].id,
                                                                            Pricing_SObject__c='Quote - Quote Line',
                                                                            Pricing_Status__c= Status,
                                                                            Pricing_Bulk_ChangeRequest_chk__c=true));
                             quoteList.clear();
                         }
                         if(!groupByQuote){
                             quote.QuoteLine = quoteLineList;
                             quoteList.add(quote);
                             quoteIdval = String.isBlank(quoteIdval)?quoteLinesList[0].SBQQ__Quote__c:quoteIdval;
                             quotelineIdval = String.isBlank(quotelineIdval)?quoteLinesList[0].id:quotelineIdval;
                         }
                         
                     }
                     
                     if(!groupByQuote){
                         
                         Pricing_BulkCR_JSONString jsonString = new Pricing_BulkCR_JSONString();
                         Pricing_BulkCR_JSONString.Header header = new Pricing_BulkCR_JSONString.Header();
                         Pricing_BulkCR_JSONString.RecordDetails recordDetails = new Pricing_BulkCR_JSONString.RecordDetails(); 
                         
                         //Update the Header Details of the JSON
                         header.source_system = Label.Pricing_Tender_MyDeal_Integration_SystemTender;
                         header.target_system = Label.Pricing_Tender_MyDeal_Integration_SystemMyDeal;
                         header.action = actionUpdate;
                         header.xid = Pricing_Tender_Utility.getGUID();                             
                         
                         recordDetails.Quote = quoteList;
                         jsonString.Header = header;
                         jsonString.RecordDetails = recordDetails;
                         
                         //Serialize the JSON
                         String jsonData = JSON.serialize(jsonString); 
                         string Status ;
                         string response = sendPayloadBulkCR(jsonData); // MyDeal Callout
                         if(response == 'Failed'){
                             Status = 'Failed';
                         }
                         else{
                             Status = 'Successful'; 
                         }
                         
                         PISList.add(new Pricing_Integration_Staging__c(Pricing_Message_Type__c = Label.Pricing_Tender_MyDeal_Integration_SystemTender,
                                                                        Pricing_Payload__c = jsonData,
                                                                        Pricing_SObject__c='Quote - Quote Line',
                                                                        Pricing_SObjectId__c=quoteIdval+ ' ' + '-'+ ' ' +quotelineIdval,
                                                                        Pricing_Status__c= Status,
                                                                        Pricing_Bulk_ChangeRequest_chk__c=true));                        
                     } 
                     
                     if(!PISList.isEmpty()){ 
                         for(String quoteId : quoteIdToQuoteLineMap.keySet()){
                             for(SBQQ__QuoteLine__c updateQuoteLine : quoteIdToQuoteLineMap.get(quoteId)){
                                 SBQQ__QuoteLine__c QLupdate = New SBQQ__QuoteLine__c(Id=updateQuoteLine.Id);
                                 QLupdate.Pricing_Integration_Status_Nm__c = Label.Pricing_Tender_MyDeal_Integration_Status_Pending;
                                 QLupdate.Pricing_Create_Deal_Actor_Id__c = Userinfo.getUserId();
                                 QLupdate.Pricing_Integration_Time_Stamp__c = System.now();
                                 QLupdate.Pricing_Previous_MyDeal_Action_Nm__c = actionUpdate;
                                 if(actionUpdate == Label.Pricing_Tender_Integration_Header_Action_Update
                                    && updateQuoteLine.Pricing_Reference_Quote_Line_Nbr__c != null){
                                        QLupdate.Pricing_Manager__c = userInfo.getUserId();
                                    }
                                 quoteLineToUpdate.add(QLupdate);
                             }
                         }
                         
                         
                         /*
if(quoteLineToUpdate.size()>0){
SBQQ.TriggerControl.disable(); 
//  update quoteLineToUpdate;
database.saveresult[] dsrQL = Database.update(quoteLineToUpdate, false);  
SBQQ.TriggerControl.enable();

for (Database.SaveResult sr : dsrQL) 
{
if (!sr.isSuccess()) 
{
string errorMsg='';
for(Database.Error err : sr.getErrors()) 
{
errorMsg = string.isBlank(errorMsg) ? err.getMessage() : errorMsg +'; '+ err.getMessage();              
}
quoteLineIdToSuccessOrErrorMap.put(sr.getId(), errorMsg); 
}
else{
quoteLineIdToSuccessOrErrorMap.put(sr.getId(), 'Success');
}                
}                        
}
*/
                         // insert PISList;
                         database.saveresult[] dsr = Database.insert(PISList, false);           
                                                                          
                     }
                 }catch(DmlException e) { 
                     Pricing_Tender_Utility.logError(e);
                 } 
             }
        return quoteLineIdToSuccessOrErrorMap;  
    }
    
    /**
* @description Created method for MyDeals Callout
* @author Rahul Maindalkar | 08-24-2022 
* @param payload
**/    
    public static string sendPayloadBulkCR(String payload){
        string responseData='Failed';   
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:APIGEE_MyDeals');
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');            
            req.setBody(payload);
            HttpResponse resp = new Http().send(req);
            if(resp.getStatus() == 'SUCCESS' || resp.getStatus() == 'OK'){
                responseData = resp.getBody();              
            }else{
                responseData = 'Failed'; 
            }            
        }catch(Exception exp){
            responseData = 'Failed';
        } 
        return responseData;
    }

    /**
    * @description Method to form Ethernet Write In Product payload
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-10-2025 
    * @param quoteLine 
    * @return Pricing_BulkCR_JSONString.Product 
    **/
    //@TestVisible
    private static Pricing_BulkCR_JSONString.Product insertEthernetWriteInProd(SBQQ__QuoteLine__c quoteLine){
        Pricing_BulkCR_JSONString.Product prod = new Pricing_BulkCR_JSONString.Product();
        prod.Id = null;
        prod.Name = null;
        prod.ProductNameEPMID = null;
        prod.ProductLevel = 'MaterialID';
        prod.Family = null;
        prod.DealProductName = null;
        prod.ProcessorNumber = null;
        prod.MaterialID = quoteLine.SBQQ__Product__r.Name == Label.Pricing_Tender_Write_In_Product ? quoteLine.Pricing_Other_Product_Nm__c : quoteLine.SBQQ__Product__r.Core_Item_Id__c;

        return prod;
    }
}