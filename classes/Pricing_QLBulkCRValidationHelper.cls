/**
* @description       : Helper class is created to validate, clone and insert Quote Line and Performance Matrix records.
* @author            : Rahul Maindalkar
* @group             : 
* @last modified on  : 07-11-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public without sharing class Pricing_QLBulkCRValidationHelper {
    
    public Static Map<Id,String> quoteLineSucessErrorMap = new Map<Id,String>();
    public static Map<Id, SBQQ__QuoteLine__c> updateQLStatusToRevisedMap = New Map<Id, SBQQ__QuoteLine__c>();
    public static Set<Id> oldQLIds = New Set<Id>();
    public static Map<Id, String> QuotelineIdProdMap = New Map<Id, String>();
    public static Map<Id, SBQQ__QuoteLine__c> QuotelineResponseMap = New Map<Id, SBQQ__QuoteLine__c>();
    public static Boolean populateloggedinUser = Pricing_QLBulkCRSendPayloadHelper.WWID_val;
    public static Boolean updatePayQtyFlag = false;
    
    /**
    * @description validateBulkCR - Method is created to validate the Quote Line data for the bulk CR
    * @author Rahul Maindalkar | 08-24-2022 
    * @param oldQuoteLine 
    * @param newQuoteLineMap 
    **/  
    public Static Pricing_QLBulkCRWrapper validateBulkCR(List<SBQQ__QuoteLine__c> oldQuoteLine, Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap){         
        // Validation Variables
        Date today = System.today();
        String typeQuote ='SBQQ__Quote__c';
        String typeQuoteLine ='SBQQ__QuoteLine__c';
        Schema.SObjectType quoteSchema = ((SObject)Type.forName(typeQuote).newInstance()).getSObjectType();
        Schema.SObjectType quoteLineSchema = ((SObject)Type.forName(typeQuoteLine).newInstance()).getSObjectType();
        Map<String, Schema.SObjectField> quoteFieldMap = quoteSchema.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> quoteLineFieldMap = quoteLineSchema.getDescribe().fields.getMap();
        Set < String > mandatoryFields = new Set < String > ((Label.Pricing_Tender_MyDeal_Integration_Mandatory_Fields).split(':'));
        Set<Id> exeQLId = New Set<Id>();
        Map<Id,String> changeRequestParentQL = New Map<Id,String>();
        changeRequestParentQL.putAll(checkExistingChangeRequest(oldQuoteLine));
        
        // get Restricted Accounts
        Map<Id,Boolean> restrictedAccountMap = getRestrictedAccountMap();        
        for(SBQQ__QuoteLine__c oldQLData : oldQuoteLine){
            
            QuotelineIdProdMap.put(oldQLData.Id, oldQLData.SBQQ__ProductName__c);
            QuotelineResponseMap.put(oldQLData.Id, New SBQQ__QuoteLine__c(Pricing_Quote_Line_Number__c = oldQLData.Pricing_Quote_Line_Number__c,
                                                                          Pricing_Deal_RFQ_Id__c = oldQLData.Pricing_Deal_RFQ_Id__c));
            String errorMsg = '';
            Boolean isPastDeal = False;
            Boolean isInflightFutureDeal = False;
            Boolean isInflightDeal = False;
            Boolean expiredQuoteLine = False;
            exeQLId.add(oldQLData.Id);
            // Code for RPM non editable fields for the Past Deal
            if (oldQLData.Pricing_Approved_End_Date_Dt__c < System.today()) {
                newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c = oldQLData.Pricing_Approved_Start_Date_Dt__c;
                newQuoteLineMap.get(oldQLData.Id).Pricing_ECAP_Price_Amt__c = oldQLData.Pricing_ECAP_Price_Amt__c;
                if(oldQLData.Pricing_Status_Nm__c == 'Won'){
                    if(oldQLData.Pricing_New_Change_Request_cb__c == true){
                        newQuoteLineMap.get(oldQLData.Id).Pricing_Revised_Pricing_Start_Date_dt__c = oldQLData.Pricing_Revised_Pricing_Start_Date_dt__c != null ? oldQLData.Pricing_Revised_Pricing_Start_Date_dt__c : oldQLData.Pricing_Approved_Start_Date_Dt__c;
                    }else{
                    newQuoteLineMap.get(oldQLData.Id).Pricing_Revised_Pricing_Start_Date_dt__c = oldQLData.Pricing_Approved_Start_Date_Dt__c;
                    }
                }  
            }
            //approved ql always making effective pricing satrt date as blank.
            if(oldQLData.Pricing_Status_Nm__c == 'Approved'){
                newQuoteLineMap.get(oldQLData.Id).Pricing_Revised_Pricing_Start_Date_dt__c = null;
            }
            // Code for RPM non editable fields for the InFlight Deal
            if (oldQLData.Pricing_Status_Nm__c == 'Won' && (oldQLData.Pricing_Approved_Start_Date_Dt__c <= System.today() && oldQLData.Pricing_Approved_End_Date_Dt__c >= System.today())) {
                newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c = oldQLData.Pricing_Approved_Start_Date_Dt__c;
            }
            
            // Check if the Quote Line is expired
            if(oldQLData.Pricing_Approved_End_Date_Dt__c != null && oldQLData.Pricing_Approved_End_Date_Dt__c <= (System.today() - 91)){
                expiredQuoteLine = True;
                errorMsg = Label.Pricing_Tender_ExpiredCR_ErrorMessage; 
            }
            
            //Check if Change Request already created for the Quote Line
            if(!changeRequestParentQL.containsKey(oldQLData.Id) && !expiredQuoteLine){
                
                // Check if user change the date or quantity if there no change no need of request..
                if (oldQLData.Pricing_Approved_Start_Date_Dt__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c &&
                    oldQLData.Pricing_Approved_End_Date_Dt__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_End_Date_Dt__c &&
                    oldQLData.Pricing_ECAP_Price_Amt__c == newQuoteLineMap.get(oldQLData.Id).Pricing_ECAP_Price_Amt__c &&
                    oldQLData.Pricing_Approved_Unit_Qty__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Unit_Qty__c &&
                    oldQLData.Pricing_Billing_Start_Date_Dt__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Billing_Start_Date_Dt__c &&
                    oldQLData.Pricing_Billing_End_Date_Dt__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Billing_End_Date_Dt__c &&
                    oldQLData.Pricing_Backdate_Reason_Txt__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Backdate_Reason_Txt__c &&
                    oldQLData.Pricing_Additional_T_C_s_Txt__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Additional_T_C_s_Txt__c &&
                    oldQLData.Pricing_Deal_Description__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Deal_Description__c &&
                    oldQLData.Pricing_Payable_Quantity__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Payable_Quantity__c ) {
                    errorMsg = Label.Pricing_Tender_RPMCR_No_Changes_Error;
                }

                // Approved Quote Line: Payable Quantity should not be editable
                if (oldQLData.Pricing_Status_Nm__c != 'Won' && oldQLData.Pricing_Payable_Quantity__c != newQuoteLineMap.get(oldQLData.Id).Pricing_Payable_Quantity__c) {
                    errorMsg = appendErrorMsg(errorMsg, Label.Pricing_PayableQty_Edit_Restric_Error);
                }

                // Restricted vs Non-Restricted Account Handling
                
                Boolean isRestricted = restrictedAccountMap.containsKey(oldQLData.SBQQ__Quote__r.SBQQ__Account__r.Id) && restrictedAccountMap.get(oldQLData.SBQQ__Quote__r.SBQQ__Account__r.Id);
                Decimal newPayableQty = newQuoteLineMap.get(oldQLData.Id).Pricing_Payable_Quantity__c;
                Decimal newApprovedQty = newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Unit_Qty__c;
                if (oldQLData.Pricing_Status_Nm__c == 'Won') {
                    if (isRestricted) {
                        // Restricted Account Validations
                        if (newPayableQty == null) {
                            errorMsg = appendErrorMsg(errorMsg, 'Payable Quantity is mandatory field and cannot be empty');
                        }else if (newPayableQty > newApprovedQty) {
                            errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_QuoteLine_Payable_Quantity_Error);
                        }
                    } else {
                        // Non-Restricted Account Validations
                        if (newPayableQty != null ) {
                            errorMsg = appendErrorMsg(errorMsg, Label.Pricing_PayableQty_NonRestrictEdit_Error);
                        }else if(newPayableQty == null){
                            newQuoteLineMap.get(oldQLData.Id).Pricing_Payable_Quantity__c = newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Unit_Qty__c;
                        }
                    }
                }

                //If QL Status is Not Approved/Won then it will throw error
                if (oldQLData.Pricing_Status_Nm__c != 'Approved' && oldQLData.Pricing_Status_Nm__c != 'Won'){
                    errorMsg = appendErrorMsg(errorMsg, 'Change Request cannot be created for the Quote Line where status ='+oldQLData.Pricing_Status_Nm__c);   
                }
                // check if Approved Quantity must be greater than zero
                if (newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Unit_Qty__c <= 0) {
                    errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_negativeApprovedQuatityvalueError);
                }
                // check if Approved ECAP Price must be greater than zero
                if (newQuoteLineMap.get(oldQLData.Id).Pricing_ECAP_Price_Amt__c <= 0) {
                    errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_negativeApprovedPricevalueError);
                }
                // check if Billing End Date cannot be earlier than the Billing Start Date.
                if (newQuoteLineMap.get(oldQLData.Id).Pricing_Billing_End_Date_Dt__c < newQuoteLineMap.get(oldQLData.Id).Pricing_Billing_Start_Date_Dt__c) {
                    errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_billingDateError);
                }
                // check if Billing End Date cannot be later than the Approved Pricing End Date.
                if (newQuoteLineMap.get(oldQLData.Id).Pricing_Billing_End_Date_Dt__c > newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_End_Date_Dt__c) {
                    errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_billingApprovedDateError);
                }
                // check if Billing Start Date cannot be later than the Approved Pricing Start Date.
                if (newQuoteLineMap.get(oldQLData.Id).Pricing_Billing_Start_Date_Dt__c > newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c) {
                    errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_billingApprovedStrDateError);
                }
                // Check if the Quote Line Status = 'Won' and Effective Pricing Start Date is Null
                if (oldQLData.Pricing_Status_Nm__c == 'Won' && newQuoteLineMap.get(oldQLData.Id).Pricing_Revised_Pricing_Start_Date_dt__c == Null) {                    
                    errorMsg = appendErrorMsg(errorMsg, Label.Pricing_QLI_EffectiveDateRequired_ErrorMsg);
                }
                if (oldQLData.Pricing_Approved_Start_Date_Dt__c != newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c && newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c < System.today() && (newQuoteLineMap.get(oldQLData.Id).Pricing_Backdate_Reason_Txt__c == '' || oldQLData.Pricing_Backdate_Reason_Txt__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Backdate_Reason_Txt__c)) {                    
                    errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_backDateReasonError);
                }
                if (newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_End_Date_Dt__c < newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c) {
                    errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_approvedEndDtBeforeApprovedStartDtError);
                }
                if (newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_End_Date_Dt__c < System.today()) {
                    isPastDeal = true;
                }
                if (newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c > System.today()) {
                    isInflightFutureDeal=true;
                }
                if (newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c <= System.today() && (newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_End_Date_Dt__c) >= System.today()) {
                    isInflightDeal=true;
                }
                if (isInflightFutureDeal && (newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_End_Date_Dt__c != null
                    && (newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_End_Date_Dt__c < newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c) ||
                        (newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_End_Date_Dt__c < System.today()))) {
                        errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_approveEndDtInflightFutureError);
                }
                //check Effective Pricing Start Date must be between Approved Pricing Start Date and Approved Pricing End Date
                //and cannot be earlier than today and the Effective Pricing Start Date of the reference quote line.
                if (isInflightFutureDeal &&
                    ((newQuoteLineMap.get(oldQLData.Id).Pricing_Revised_Pricing_Start_Date_dt__c < newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c)||                        
                     (newQuoteLineMap.get(oldQLData.Id).Pricing_Revised_Pricing_Start_Date_dt__c < oldQLData.Pricing_Revised_Pricing_Start_Date_dt__c) ||
                     (newQuoteLineMap.get(oldQLData.Id).Pricing_Revised_Pricing_Start_Date_dt__c > newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_End_Date_Dt__c))) {
                         //  errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_effPricingStartDtOnChangeError);
                }

                if (isPastDeal && (oldQLData.Pricing_Approved_End_Date_Dt__c < System.today() &&
                                   newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_End_Date_Dt__c < oldQLData.Pricing_Approved_End_Date_Dt__c)) {
                                       errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_PricingApproveEndDtPastCheckError);
                }
                
                //check if MeetComp price is greater than zero
                if (newQuoteLineMap.get(oldQLData.Id).Pricing_Meet_Comp_Price_Amt__c <= 0) {
                    errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_negativeMeetCompPricevalueError);
                }
                // check if My Deals Meet Comp Price and Effective Pricing Start Date
                // cannot be edited unless one of the following fields is changed from the reference quote lines values.
                if ((oldQLData.Pricing_Meet_Comp_Price_Amt__c != newQuoteLineMap.get(oldQLData.Id).Pricing_Meet_Comp_Price_Amt__c ||
                     oldQLData.Pricing_Revised_Pricing_Start_Date_dt__c != newQuoteLineMap.get(oldQLData.Id).Pricing_Revised_Pricing_Start_Date_dt__c) &&
                    (oldQLData.Pricing_Approved_End_Date_Dt__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_End_Date_Dt__c
                     && oldQLData.Pricing_Approved_Unit_Qty__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Unit_Qty__c
                     && oldQLData.Pricing_Payable_Quantity__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Payable_Quantity__c
                     && oldQLData.Pricing_Approved_Start_Date_Dt__c == newQuoteLineMap.get(oldQLData.Id).Pricing_Approved_Start_Date_Dt__c
                     && oldQLData.Pricing_ECAP_Price_Amt__c == newQuoteLineMap.get(oldQLData.Id).Pricing_ECAP_Price_Amt__c)) {
                        errorMsg = appendErrorMsg(errorMsg, Label.Pricing_Tender_CR_MeetCompPriceandEffectiveStartDatevalueError);                                    
                }
            }
            else{
                if(!expiredQuoteLine){
                    errorMsg = appendErrorMsg(errorMsg, (Label.Pricing_Tender_CR_Existing_Request_Error).replace('(${quoteLineNumber})',changeRequestParentQL.get(oldQLData.Id)));       
                }
            }
            if(!String.isBlank(errorMsg)){
                quoteLineSucessErrorMap.put(oldQLData.Id,errorMsg.replace(',',';'));  
            }
            else{
                oldQLIds.add(oldQLData.Id);
            }
        }
        
        //Validation code for myDeals
        List<SBQQ__QuoteLine__c> quoteLines;
        quoteLines = new List<SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id,
                                                   SBQQ__Quote__r.Name, Pricing_EndCustomer_Nm__c, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,
                                                   Pricing_Reference_Quote_Line_Nbr__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,
                                                   SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,
                                                   SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,
                                                   Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c,
                                                   Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,
                                                   Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,
                                                   Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                   Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Project_Nm__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, 
                                                   Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,
                                                   Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,
                                                   SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,
                                                   Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Competetor_Product__r.Name,
                                                   SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_End_Customer__c,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,
                                                   SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c,Pricing_Program_Type_Nm__c,
                                                   SBQQ__Quote__r.Pricing_Is_Sanctioned__c,Pricing_Account_Division_Nm__c,Pricing_Comp_Product_Txt__c,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,
                                                                                                                                                       Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE 
                                                   Id IN : exeQLId]);
        
        
        Boolean isExceptionQuoteLine = false;
        Boolean isWriteInProduct = false;
        if(!quoteLines.isEmpty()){
            for(SBQQ__QuoteLine__c actualQuoteLine : quoteLines) {
                String errorString = '';
                String validationMsg = '';
                Id Pricing_Reference_Quote_Line_Nbr = actualQuoteLine.Id;
                String Pricing_Deal_RFQ_Status_Nm = null ;
                actualQuoteLine.Pricing_Billing_End_Date_Dt__c = newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Billing_End_Date_Dt__c;
                actualQuoteLine.Pricing_ECAP_Price_Amt__c = newQuoteLineMap.get(actualQuoteLine.Id).Pricing_ECAP_Price_Amt__c;
                actualQuoteLine.Pricing_Meet_Comp_Price_Amt__c = newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Meet_Comp_Price_Amt__c;
                actualQuoteLine.Pricing_Approved_Unit_Qty__c = newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Approved_Unit_Qty__c;
                actualQuoteLine.Pricing_Group_Type_nm__c = Label.Pricing_Tender_Default_Group_Type;
                Date old_Pricing_Approved_Start_Date = actualQuoteLine.Pricing_Approved_Start_Date_Dt__c;
                Date old_Pricing_Approved_End_Date = actualQuoteLine.Pricing_Approved_End_Date_Dt__c;
                actualQuoteLine.Pricing_Billing_Start_Date_Dt__c = newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Billing_Start_Date_Dt__c;
                actualQuoteLine.Pricing_Approved_Start_Date_Dt__c = newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Approved_Start_Date_Dt__c;
                actualQuoteLine.Pricing_Approved_End_Date_Dt__c = newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Approved_End_Date_Dt__c;
                
                
                if(actualQuoteLine.Pricing_Product_Nm__r.Name != Label.Pricing_Tender_Write_In_Product){             
                    
                    if(!changeRequestParentQL.containsKey(actualQuoteLine.Id) && !(actualQuoteLine.Pricing_Approved_End_Date_Dt__c <= (System.today() - 91))){                    
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
                        
                        if((!isExceptionQuoteLine) && (actualQuoteLine.Performance_Metrics__r == null || (actualQuoteLine.Performance_Metrics__r).size() == 0)){
                            errorString = appendErrorMsg(errorString,Label.Pricing_MyDeals_PerformanceMetric_RequiredError);
                        }
                        
                        if(newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Approved_End_Date_Dt__c != null && newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Approved_End_Date_Dt__c < System.Today()){
                            errorString = appendErrorMsg(errorString,Label.Pricing_Mydeal_End_Date_Past_Error);
                        }
                        
                        if(newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Billing_Start_Date_Dt__c != null && newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Approved_Start_Date_Dt__c != null){          
                            Integer noOfDaysBetweenDates = newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Billing_Start_Date_Dt__c.daysBetween(newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Approved_Start_Date_Dt__c);
                            if(noOfDaysBetweenDates > Integer.valueof(Label.Pricing_Days)){
                                errorString = appendErrorMsg(errorString,Label.Pricing_Tender_QuoteLine_Billing_Quarter_Error);
                            }
                        }
                        
                        if(newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Revised_Pricing_Start_Date_dt__c!=Null && actualQuoteLine.Pricing_Status_Nm__c == 'Won'){  //CH
                            if((Pricing_Reference_Quote_Line_Nbr != null) &&
                               ((old_Pricing_Approved_Start_Date <= today &&
                                 old_Pricing_Approved_End_Date >= today) ||
                                old_Pricing_Approved_Start_Date > today)
                               && (newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Revised_Pricing_Start_Date_dt__c < newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Approved_Start_Date_Dt__c ||
                                   
                                   newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Revised_Pricing_Start_Date_dt__c < actualQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c
                                   || newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Revised_Pricing_Start_Date_dt__c > newQuoteLineMap.get(actualQuoteLine.Id).Pricing_Approved_End_Date_Dt__c)){
                                       validationMsg = Label.Pricing_Tender_CR_effPricingStartDtOnChangeError;
                                   }
                        }
                        
                        if(String.isNotBlank(errorString) || String.isNotBlank(validationMsg)){
                            if(String.isNotBlank(validationMsg)){
                                validationMsg = validationMsg + '; ';
                            }                    
                            
                            if(String.isNotBlank(errorString) && !isWriteInProduct){
                                if(Pricing_Deal_RFQ_Status_Nm == 'Requested' || (actualQuoteLine.Pricing_Deal_RFQ_Id__c != null && Pricing_Reference_Quote_Line_Nbr != null)){
                                    validationMsg = validationMsg + 'Fields are required to update a Deal: '+errorString;
                                }
                            } 
                            if(quoteLineSucessErrorMap.containsKey(actualQuoteLine.Id)){
                                validationMsg = appendErrorMsg(validationMsg, quoteLineSucessErrorMap.get(actualQuoteLine.Id));
                                quoteLineSucessErrorMap.put(actualQuoteLine.Id,(validationMsg.replace(',',';')));  
                            }
                            else{
                                quoteLineSucessErrorMap.put(actualQuoteLine.Id,(validationMsg.replace(',',';')));
                                oldQLIds.remove(actualQuoteLine.Id);
                            }
                        }
                    }
                }
            }
        }
        
        // Call clone method to clone and insert Quote Line and Performance Matrix
        quoteLineSucessErrorMap.putAll(cloneBulkCR(oldQuoteLine, newQuoteLineMap));
        Pricing_QLBulkCRWrapper crWrapper = New Pricing_QLBulkCRWrapper(quoteLineSucessErrorMap, updateQLStatusToRevisedMap.values(),QuotelineIdProdMap, QuotelineResponseMap);
        return crWrapper;
    }    
 
    /**
    * @description return map Id and boolean if account restricted or not for payable Qt
    * @author Vrushabh Uprikar | 02-27-2025 
    * @return Map<Id, Boolean> 
    **/
    public static Map<Id,Boolean> getRestrictedAccountMap(){
        Map<Id,Boolean> restrictedAccountMap = new Map<Id,Boolean>();
        List<Pricing_QuoteLine_WonLoss_Restriction__mdt> wonLossAccountList = Pricing_QuoteLine_WonLoss_Restriction__mdt.getAll().values();
        for(Pricing_QuoteLine_WonLoss_Restriction__mdt wonLossQuoteLines : wonLossAccountList) {
            restrictedAccountMap.put(wonLossQuoteLines.Pricing_Account_Id__c,wonLossQuoteLines.Pricing_IsActive_Ind__c);
        }
        return restrictedAccountMap;
    }

    /**
    * @description cloneBulkCR - Method is created to clone and insert new Quote Line and Performance Matrix
    * @author Rahul Maindalkar | 08-24-2022 
    * @param oldQuoteLine 
    * @param newQuoteLineMap 
    **/ 
    public static Map<Id, String> cloneBulkCR(List<SBQQ__QuoteLine__c> oldQuoteLine, Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap){
        Map<Id,String> quoteLineIdToErrorMap = new Map<Id,String>();
        Set<Id> quotelinIds = New Set<Id>();
        Set<Id> successQLIds =New Set<Id>();
        Set<Id> successPMIds =New Set<Id>();
        Map<Id, Id> qlNewOldIdsMap = New Map<Id, Id>();
        Map<Id,List<SBQQ__QuoteLine__c>> rejectedQLMap = new Map<Id,List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> newCRList = New List<SBQQ__QuoteLine__c>();
        rejectedQLMap.putAll(checkRejectedRevisionQL(oldQLIds));
        for(SBQQ__QuoteLine__c QLData: oldQuoteLine){
            if(!quoteLineSucessErrorMap.containsKey(QLData.Id)){
                SBQQ__QuoteLine__c quoteline = New SBQQ__QuoteLine__c();
                quoteline = QLData.clone(false, true, false, false); // deep clone
                quoteline = quotelineFieldPopulation(quoteline,QLData,newQuoteLineMap.get(QLData.Id),rejectedQLMap);
                newCRList.add(quoteline);
            }
        }
        
        if(newCRList.size()>0) {
            database.saveresult[] dsr = Database.insert(newCRList, false);
            for (Database.SaveResult sr : dsr) {
                if(sr.isSuccess() && sr.getId()!=Null){
                    successQLIds.add(sr.getId());
                }
            }
        }
        if(successQLIds.size()>0){
            for(SBQQ__QuoteLine__c QLData:[Select Id, Pricing_Reference_Quote_Line_Nbr__c, Pricing_Quote_Line_Number__c,Pricing_Integration_Status_Nm__c,Pricing_Deal_RFQ_Id__c, SBQQ__ProductName__c from SBQQ__QuoteLine__c where Id in : successQLIds]){
                
                qlNewOldIdsMap.put(QLData.Pricing_Reference_Quote_Line_Nbr__c, QLData.Id);
                quotelinIds.add(QLData.Pricing_Reference_Quote_Line_Nbr__c);
                QuotelineIdProdMap.put(QLData.Id, QLData.SBQQ__ProductName__c);
                QuotelineResponseMap.put(QLData.Id, New SBQQ__QuoteLine__c(Pricing_Quote_Line_Number__c=QLData.Pricing_Quote_Line_Number__c,
                                                                           Pricing_Deal_RFQ_Id__c = QLData.Pricing_Deal_RFQ_Id__c));
            }
            
            for(SBQQ__QuoteLine__c QLData:oldQuoteLine){
                        if(!qlNewOldIdsMap.containsKey(QLData.Id) && !quoteLineSucessErrorMap.containsKey(QLData.Id) && !quoteLineIdToErrorMap.containsKey(QLData.Id)){
                            quoteLineIdToErrorMap.put(QLData.Id, 'Insert Failed - Change Request Quote Line'); 
                        }
                        else if(qlNewOldIdsMap.containsKey(QLData.Id)){
                            string successMessage = 'Success_'+string.valueOf(qlNewOldIdsMap.get(QLData.Id));
                            quoteLineIdToErrorMap.put(QLData.Id, successMessage);
                        }
            }
            
            // Remove QL from Map where Change Request record is not created
            for(SBQQ__QuoteLine__c QLData : updateQLStatusToRevisedMap.values()){
                if(!qlNewOldIdsMap.containsKey(QLData.Id)){
                    updateQLStatusToRevisedMap.remove(QLData.Id); 
                }
            }
            
            // Create Performance Matrix
            string query = String.format(
                'SELECT {0} FROM {1} WHERE Pricing_Quote_Line__c in',
                new String[] {
                    String.join(
                        new List<String>(
                            Pricing_Performance_Metric__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet()
                        ),
                        ','
                    ),
                        String.valueOf(Pricing_Performance_Metric__c.SObjectType)
                }
            );
            query+=':quotelinIds';
            List<Pricing_Performance_Metric__c> children = new List<Pricing_Performance_Metric__c>();
            for(Pricing_Performance_Metric__c child:(List<Pricing_Performance_Metric__c>)Database.query(query)){
                Pricing_Performance_Metric__c newPM = child.clone(false,true); // deep clone
                newPM.Pricing_Quote_Line__c = qlNewOldIdsMap.get(newPM.Pricing_Quote_Line__c); 
                children.add(newPM);
            }
            
            if(!children.isEmpty()){
                database.saveresult[] dsrpm = Database.insert(children, false);
                for (Database.SaveResult sr : dsrpm) {
                    if(sr.isSuccess() && sr.getId()!=null){
                            successPMIds.add(sr.getId());
                        }
                }
                /*
                    if(successPMIds.size()>0){
                    for(Pricing_Performance_Metric__c PMData:[Select Id, Pricing_Quote_Line__c from Pricing_Performance_Metric__c where Id in : successPMIds]){
                    successPMQL.add(PMData.Pricing_Quote_Line__c);         
                    }
                    for(Id QLId:qlNewOldIdsMap.values()){
                    if(!successPMQL.contains(QLId) && !quoteLineSucessErrorMap.containsKey(QLId) && !quoteLineIdToErrorMap.containsKey(QLId)){
                    quoteLineIdToErrorMap.put(QLId, 'Insert Failed - Performance Matrix');  
                    }
                    }   
                    }
                    else{
                    for(Id QLId:qlNewOldIdsMap.values()){
                    if(!quoteLineSucessErrorMap.containsKey(QLId) && !quoteLineIdToErrorMap.containsKey(QLId)){
                    quoteLineIdToErrorMap.put(QLId, 'Insert Failed - Performance Matrix');  
                    }
                    }                      
                    }
                */ 
            }
        }
        else{
            for(SBQQ__QuoteLine__c QLData:oldQuoteLine){
                if(!quoteLineSucessErrorMap.containsKey(QLData.Id) && !quoteLineIdToErrorMap.containsKey(QLData.Id)){
                    quoteLineIdToErrorMap.put(QLData.Id, 'Insert Failed - Change Request Quote Line'); 
                }
            }  
        }
        return quoteLineIdToErrorMap;
    }
    
    /**
    * @description quotelineFieldPopulation - Method is created to populate Quote Line fields while creating new QL instance
    * @author Rahul Maindalkar | 08-24-2022 
    * @param parent 
    * @param parentSObjects 
    * @param quoteLine 
    * @param rejectedQLMap 
    **/ 
    public static SBQQ__QuoteLine__c quotelineFieldPopulation(SBQQ__QuoteLine__c parent, SBQQ__QuoteLine__c parentSObjects, SBQQ__QuoteLine__c quoteLine,  Map<Id,List<SBQQ__QuoteLine__c>> rejectedQLMap){
        
        parent.Pricing_Change_Request_Type__c = Pricing_QuoteLineCloneController.populateChangeRequestType(parent,quoteLine,false);// Method to track the field values changed during change request in a picklist field
        parent.Pricing_Reference_Quote_Line_Nbr__c = parentSObjects.Id;
        parent.Pricing_Quote_Line_Number__c = generateQuoteLineNumber(parentSObjects.Id, parentSObjects.Pricing_Quote_Line_Number__c, parentSObjects.Pricing_Reference_Quote_Line_Nbr__c, rejectedQLMap);                                
        
        parent.Pricing_Original_Submitted_By_Id__c = UserInfo.getUserId();
        parent.Pricing_Original_Submitted_Date_dt__c = Datetime.now();
        parent.Pricing_Last_Submitted_Date_dt__c = Datetime.now();
        parent.Pricing_Last_Submitted_By_Id__c = UserInfo.getUserId();
        
        Parent.Pricing_Deal_RFQ_Dup_Id__c = null;
        parent.Pricing_Previous_Status_Nm__c = 'Pending';
        parent.Pricing_Sales_Rep_Approver__c = null;
        parent.Pricing_Ready_for_Review_cb__c = false;
        
        parent.Customer_Revision_Count_Cnt__c = null;
        parent.Field_Revision_Count_Cnt__c = null;
        
        //  parent.Pricing_Integration_Status_Nm__c = null;    //CH
        parent.Pricing_Deal_RFQ_Status_Nm__c = null;
        parent.Pricing_Error_Messages__c = null;
        
        parent.Pricng_Exclude_from_Price_Approval_Rules__c = false;
        parent.Pricing_Group_Type_nm__c = Label.Pricing_Tender_Default_Group_Type;
        parent.Pricing_Quote_Line_Status_Number__c = null;
        //   parent.Pricing_Integration_Time_Stamp__c = null;      //CH
        //   parent.Pricing_Previous_MyDeal_Action_Nm__c = null;   //CH
        //   parent.Pricing_Create_Deal_Actor_Id__c = null;         //CH
        parent.Pricing_Update_Status_to_Rejected_cb__c = false;
        parent.Pricing_Previous_Inbound_Msg_Number__c = null;
        
        parent.Pricing_Recommendation_FeedBack_Nm__c = null;    
        parent.Pricing_Recommended_Price_Amt__c = null;
        
        if(parent.SBQQ__ProductName__c == Label.Pricing_Tender_Write_In_Product && String.isBlank(parent.Pricing_Deal_RFQ_Id__c) && parent.Pricing_Product_Nm__c == parentSObjects.Pricing_Product_Nm__c){ //&& parent.Pricing_Deal_RFQ_Id__c==null && parent.Pricing_Deal_RFQ_Id__c=='' && parent.Pricing_Product_Nm__c == quoteLine.Pricing_Product_Nm__c
            
            parent.Pricing_Change_Request_cb__c = false;
            parent.Pricing_Last_Approved_Date_dt__c = DateTime.now();
            parent.RecordTypeId = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Read_Only) : Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_ReadOnly);
            parent.Pricing_Approved_Start_Date_Dup_Dt__c = quoteLine.Pricing_Approved_Start_Date_Dt__c;
            parent.Pricing_Approved_End_Date_Dup_Dt__c = quoteLine.Pricing_Approved_End_Date_Dt__c;
            parent.Pricing_Approved_Unit_Dup_Qty__c = quoteLine.Pricing_Approved_Unit_Qty__c;
            parent.Pricing_ECAP_Price_Dup_Amt__c = quoteLine.Pricing_ECAP_Price_Amt__c;
            parent.Pricing_Revised_Pricing_Start_Date_D_dt__c = quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
            if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won ){
                parent.Pricing_Quote_Line_Won_Lost_Status__c = Label.Pricing_Tender_QuoteLine_Status_Won;
            } else{
                parent.Pricing_Quote_Line_Won_Lost_Status__c = null;
            }
            
            SBQQ__QuoteLine__c oldQuoteline = new SBQQ__QuoteLine__c(Id = parentSObjects.Id, Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Revised);
            if(parentSObjects.Id != null){
                // update oldQuoteline;
                updateQLStatusToRevisedMap.put(parentSObjects.Id,oldQuoteline);
            }
        }else{
          
            parent.Pricing_Change_Request_cb__c = true;
            parent.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            parent.RecordTypeId = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Submitted) : Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
            parent.Pricing_Approved_Start_Date_Dup_Dt__c = null;
            parent.Pricing_Approved_End_Date_Dup_Dt__c = null;
            parent.Pricing_Approved_Unit_Dup_Qty__c = null;
            parent.Pricing_ECAP_Price_Dup_Amt__c = null;
            parent.Pricing_Revised_Pricing_Start_Date_D_dt__c = null;
            parent.Pricing_Last_Approved_Date_dt__c = null;
            parent.Pricing_Quote_Line_Won_Lost_Status__c = null;
        }
        parent.Pricing_Approved_Start_Date_Dt__c = quoteLine.Pricing_Approved_Start_Date_Dt__c;
        parent.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_Approved_End_Date_Dt__c;
        parent.Pricing_Approved_Unit_Qty__c = quoteLine.Pricing_Approved_Unit_Qty__c;
        parent.Pricing_Payable_Quantity__c = quoteLine.Pricing_Payable_Quantity__c;  
        parent.Pricing_Meet_Comp_Price_Amt__c = quoteLine.Pricing_Meet_Comp_Price_Amt__c;
        parent.Pricing_Revised_Pricing_Start_Date_dt__c = quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
        parent.Pricing_Billing_End_Date_Dt__c = quoteLine.Pricing_Billing_End_Date_Dt__c;
        parent.Pricing_Billing_Start_Date_Dt__c = quoteLine.Pricing_Billing_Start_Date_Dt__c;
        parent.Pricing_ECAP_Price_Amt__c = quoteLine.Pricing_ECAP_Price_Amt__c;
        parent.Pricing_Additional_Comments_Txt__c = quoteLine.Pricing_Additional_Comments_Txt__c;
        parent.Pricing_Additional_T_C_s_Txt__c = quoteLine.Pricing_Additional_T_C_s_Txt__c;
        parent.Pricing_Backdate_Reason_Txt__c = quoteLine.Pricing_Backdate_Reason_Txt__c;
        parent.Pricing_Deal_Description__c = quoteLine.Pricing_Deal_Description__c;
        parent.Pricing_End_Date_dt__c = parent.Pricing_End_Date_dt__c > date.today() ? parent.Pricing_End_Date_dt__c : dateFormat();
        parent.Pricing_Is_Additional_T_C_Not_Blank_cb__c = quoteLine.Pricing_Additional_T_C_s_Txt__c != null ? true : false;
        
        
        // Update Integration Status to Pending
        parent.Pricing_Integration_Status_Nm__c = parentSObjects.Pricing_Deal_RFQ_Id__c == null ? null : Label.Pricing_Tender_MyDeal_Integration_Status_Pending;
        parent.Pricing_Create_Deal_Actor_Id__c = Userinfo.getUserId();
        parent.Pricing_Integration_Time_Stamp__c = System.now();
        parent.Pricing_Previous_MyDeal_Action_Nm__c = 'Update';
        if(populateloggedinUser){
            parent.Pricing_Manager__c = userInfo.getUserId();    
        } else{
            if(quoteLine.Pricing_Manager__c!=Null){
                parent.Pricing_Manager__c = quoteLine.Pricing_Manager__c;
            }
        }
       
        return parent;
    }
    
    /**
    * @description dateFormat - Method is created to format date in GMT
    * @author Rahul Maindalkar | 08-24-2022 
    **/  
    public static date dateFormat(){
        DateTime stringDateTime = date.today();
        DateTime dt = stringDateTime.dateGMT();
        DateTime tomorrow = dt.addDays(1);
        String formattedDateTime = tomorrow.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return date.valueOf(formattedDateTime);
    }   
    
    /**
* @description checkRejectedRevisionQL - Method is created to get Map of QL where status is Rejected, this map will need at the time of Quote Line number generation.
* @author Rahul Maindalkar | 08-24-2022 
* @param quoteLineIds 
**/    
    public static Map<Id, List<SBQQ__QuoteLine__c>> checkRejectedRevisionQL(Set<Id> quoteLineIds){
        Map<Id, List<SBQQ__QuoteLine__c>> rejectedMap = New Map<Id, List<SBQQ__QuoteLine__c>>();
        for(SBQQ__QuoteLine__c quoteLineData :[SELECT Id,Pricing_Reference_Quote_Line_Nbr__c, Pricing_Quote_Line_Number__c FROM SBQQ__QuoteLine__c where Pricing_Reference_Quote_Line_Nbr__c in: quoteLineIds and Pricing_Status_Nm__c = 'Rejected' order by Pricing_Quote_Line_Number__c desc]){
            if(rejectedMap.containsKey(quoteLineData.Pricing_Reference_Quote_Line_Nbr__c)){
                rejectedMap.get(quoteLineData.Pricing_Reference_Quote_Line_Nbr__c).add(quoteLineData);
            }else{
            rejectedMap.put(quoteLineData.Pricing_Reference_Quote_Line_Nbr__c,new List<SBQQ__QuoteLine__c>{quoteLineData});

            }
        }
        return rejectedMap;
    }
    
    /**
* @description generateQuoteLineNumber - Method is created to generate Quote Line number
* @author Rahul Maindalkar | 08-24-2022 
* @param quoteLineId 
* @param parentQuoteLineNbr 
* @param parentReferenceQL 
* @param revisions     
**/    
    public static String generateQuoteLineNumber(Id quoteLineId, string parentQuoteLineNbr,Id parentReferenceQL, Map<Id,List<SBQQ__QuoteLine__c>> revisions){
        String newQuoteLN;
        
        // If revisions exist, next revision number should be increment of last rejected Quote Line number
        String quoteLineNbr;
        quoteLineNbr = (!revisions.isEmpty() && revisions.containsKey(quoteLineId))?revisions.get(quoteLineId)[0].Pricing_Quote_Line_Number__c:parentQuoteLineNbr;
        
        if(parentReferenceQL == null & !revisions.containsKey(quoteLineId)){
            newQuoteLN = quoteLineNbr +'-'+ String.valueOf(1).leftPad(3, '0');
        }
        else{
            integer lineNbr;
            lineNbr = Integer.valueOf(quoteLineNbr.substringAfter('-').substringAfter('-').substringAfter('-'));
            newQuoteLN = quoteLineNbr.substring(0,quoteLineNbr.length()-4) +'-'+ String.valueOf(lineNbr + 1).leftPad(3, '0');          
        }
        return newQuoteLN;
    }
    
    /**
    * @description appendErrorMsg - Method is created to add new error message in the existing string by commma seprated
    * @author Rahul Maindalkar | 08-24-2022 
    * @param originalMsg 
    * @param msgToBeAppended 
    **/     
    public static String appendErrorMsg(String originalMsg,String msgToBeAppended ){
        String retMsg = '';
        if(String.isNotBlank(originalMsg)){
            retMsg = originalMsg + ' ; '+msgToBeAppended;
        }else{
            retMsg = msgToBeAppended;
        }
        return retMsg;
    }
    
    /**
    * @description checkExistingChangeRequest - Method is created to check if there is any existing pending change request present for the Quote Line
    * @author Rahul Maindalkar | 08-24-2022 
    * @param oldQuoteLine 
    **/     
    public static Map<Id,String> checkExistingChangeRequest(List<SBQQ__QuoteLine__c> oldQuoteLine){
        Set<Id> parentQLIds = New Set<Id>();
        Map<Id,String> changeRequestParentQL = New Map<Id,String>();
        for(SBQQ__QuoteLine__c quoteLine : oldQuoteLine){
            parentQLIds.add(quoteLine.Id); 
        }
        for(SBQQ__QuoteLine__c quoteLine : [Select Id,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c, Pricing_Reference_Quote_Line_Nbr__c from SBQQ__QuoteLine__c where Pricing_Reference_Quote_Line_Nbr__c in : parentQLIds AND Pricing_Status_Nm__c !=: Label.Pricing_Tender_QuoteLine_Status_Rejected ]){
            changeRequestParentQL.put(quoteLine.Pricing_Reference_Quote_Line_Nbr__c, quoteLine.Pricing_Quote_Line_Number__c);
        }
        return changeRequestParentQL;
    }    
}