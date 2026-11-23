/**
 * @description       :
 * @author            : Sandeep Chamate
 * @group             :
 * @last modified on  : 10-10-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public without sharing class Pricing_FinancialIncentive_BusinessLogic {
    
    /******************************************************************************************************************
     *Method Name : opportunityToQuoteLineChangeReq
     *Created Date: 01/21/2024
     *Description : create quote line change request
     * @param OpportunityToQuoteLineCRWrapper - OpportunityToQuoteLineCRWrapper
     *******************************************************************************************************************/
    public static Map<Id, Id> oppIdtoQuoteIdMap = new Map<Id, Id>();
    public static Map<Id,Product_Additional_Attribute__c> prodIdToDealRegEligible = new Map<Id,Product_Additional_Attribute__c>();
    public static Map<Id, List<OpportunityLineItem>> oopIdLineItemMap = new Map<Id, List<OpportunityLineItem>>();
    public static Database.SaveResult[] quoteinsertionSuccessError;
    public static Map<Id, String> qlIdToSuccessMsg = new Map<Id, String>();
    public static Map<Id, Id> oppIdtoDealIdMap = new Map<Id, Id>();
    public static Map<Id,SBQQ__Quote__c> quotesMap = new Map<Id,SBQQ__Quote__c>();
    
    public static List<String> opportunityToQuoteLineChangeReq(List<OpportunityToQuoteLineCRWrapper> opportunityToQuoteLineCRWrapper){
        List<String> results = new List<String>();
        List<String> exceptionErrorList = new List<String>();
        try {
            Boolean hasError = false;
            String errorList = '';
            List<SBQQ__QuoteLine__c> quoteLineChangeReqList = new List<SBQQ__QuoteLine__c>();
            String query;
            List<SBQQ__QuoteLine__c> parentQuoteLine = new List<SBQQ__QuoteLine__c>();
            Map<Id,String> changeRequestParentQL = new Map<Id,String>();
            List<SBQQ__QuoteLine__c> oldQuoteLine = new List<SBQQ__QuoteLine__c>();
            Set<Id> sObjectId = new Set<Id>();
            Map<Id,String> qlIdToErrorMsgsMap = new Map<Id,String>();
            Map<Id,opportunityToQuoteLineCRWrapper> crquotelineDetails = new Map<Id,opportunityToQuoteLineCRWrapper>();
            
            for(OpportunityToQuoteLineCRWrapper quoteLineDetails: opportunityToQuoteLineCRWrapper){
                sObjectId.add(quoteLineDetails.quotelineId);
                crquotelineDetails.put(quoteLineDetails.quotelineId,quoteLineDetails);
            }
            if(sObjectId.size() > 0){
                query = String.format(
                    'SELECT {0} FROM {1} WHERE Id In : sObjectId',
                new String[] {
                    String.join(
                        new List<String>(
                        SBQQ__QuoteLine__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet()
                        ),
                    ','
                        ),
                    String.valueOf(SBQQ__QuoteLine__c.SObjectType)
                }
                );
                parentQuoteLine = Database.query(query);
            }
            // Duplicate change req.
            oldQuoteLine.addAll(parentQuoteLine);
            changeRequestParentQL.putAll(Pricing_QLBulkCRValidationHelper.checkExistingChangeRequest(oldQuoteLine));
            for(SBQQ__QuoteLine__c parentQL : parentQuoteLine){
                SBQQ__QuoteLine__c quoteLineChangeReq = new SBQQ__QuoteLine__c();
                if(!changeRequestParentQL.isEmpty() && changeRequestParentQL.containsKey(parentQL.Id)){
                    errorList += (Label.Pricing_Tender_CR_Existing_Request_Error).replace('(${quoteLineNumber})',changeRequestParentQL.get(parentQL.Id)) +' ';
                    hasError = true;
                }
                
                if(crquotelineDetails.get(parentQL.Id).quoteLineNewQuantity <= 0 || crquotelineDetails.get(parentQL.Id).quoteLineNewQuantity == null){
                    errorList +='Quote Line Quantity should be greater than Zero. ';
                    hasError = true;
                }else {
                    quoteLineChangeReq.Pricing_New_Quantity_qty__c = crquotelineDetails.get(parentQL.Id).quoteLineNewQuantity;
                }
                
                Integer noOfDays = parentQL.Pricing_Approved_End_Date_Dt__c.daysBetween(System.today());
                if (noOfDays > 91){
                    errorList +=Label.Pricing_FI_CRApprovedPricingEndDate_ErrorMessage; //'Change Request cannot be created if Approved Pricing End Date is more than 90 days from the current date. ';
                    hasError = true;
                }
                
                if(crquotelineDetails.get(parentQL.Id).quoteLineStartDate == null || crquotelineDetails.get(parentQL.Id).quoteLineStartDate > crquotelineDetails.get(parentQL.Id).quoteLineEndDate || (crquotelineDetails.get(parentQL.Id).quoteLineStartDate != parentQL.Pricing_Start_Date_dt__c && crquotelineDetails.get(parentQL.Id).quoteLineStartDate < System.today())){
                    errorList +='Quote Line Start Date can not be empty or greater than End Date or earlier than today. ';
                    hasError = true;
                }else {
                    quoteLineChangeReq.Pricing_Start_Date_dt__c = crquotelineDetails.get(parentQL.Id).quoteLineStartDate;
                }
                
                if(crquotelineDetails.get(parentQL.Id).quoteLineEndDate == null || crquotelineDetails.get(parentQL.Id).quoteLineEndDate < crquotelineDetails.get(parentQL.Id).quoteLineStartDate || (crquotelineDetails.get(parentQL.Id).quoteLineEndDate != parentQL.Pricing_End_Date_dt__c && crquotelineDetails.get(parentQL.Id).quoteLineEndDate < System.today())){
                    errorList +='Quote Line End Date can not be empty or earlier than Start Date or earlier than today. ';
                    hasError = true;
                }else {
                    quoteLineChangeReq.Pricing_End_Date_dt__c = crquotelineDetails.get(parentQL.Id).quoteLineEndDate;
                }
                
                if(parentQL.Pricing_Approved_Unit_Qty__c == crquotelineDetails.get(parentQL.Id).quoteLineNewQuantity
                    && parentQL.Pricing_Start_Date_dt__c == crquotelineDetails.get(parentQL.Id).quoteLineStartDate
                && parentQL.Pricing_End_Date_dt__c == crquotelineDetails.get(parentQL.Id).quoteLineEndDate){
                    errorList ='Please Change at least one field. ';
                    hasError = true;
                }
                
                quoteLineChangeReq.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'Pricing_Financial_Incentive_Quote_Line_Edit');
                quoteLineChangeReq.Pricing_Additional_Comments_Txt__c = crquotelineDetails.get(parentQL.Id).quoteLineAdditionalComments;
                quoteLineChangeReq.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
                quoteLineChangeReq.Pricing_Approved_Unit_Qty__c = parentQL.Pricing_Approved_Unit_Qty__c;
                quoteLineChangeReq.Pricing_Approved_Unit_Dup_Qty__c = parentQL.Pricing_Approved_Unit_Dup_Qty__c;
                quoteLineChangeReq.Pricing_Total_Volume_Qty__c = parentQL.Pricing_Total_Volume_Qty__c;
                quoteLineChangeReq.Pricing_FI_Net_RPU_Amt__c = parentQL.Pricing_FI_Net_RPU_Amt__c;
                quoteLineChangeReq.Pricing_Approved_End_Date_Dt__c = parentQL.Pricing_Approved_End_Date_Dt__c;
                quoteLineChangeReq.Pricing_Approved_Start_Date_Dt__c = parentQL.Pricing_Approved_Start_Date_Dt__c;
                quoteLineChangeReq.Pricing_Approved_End_Date_Dup_Dt__c = parentQL.Pricing_Approved_End_Date_Dup_Dt__c;
                quoteLineChangeReq.Pricing_Approved_Start_Date_Dup_Dt__c = parentQL.Pricing_Approved_Start_Date_Dup_Dt__c;
                quoteLineChangeReq.Pricing_Won_Lost_Comments_Txt__c = parentQL.Pricing_Won_Lost_Comments_Txt__c; //need to check
                quoteLineChangeReq.Pricing_Lost_Reason_Nm__c = parentQL.Pricing_Lost_Reason_Nm__c; //need to check
                quoteLineChangeReq.Pricing_pm_approval_comments_nm__c = parentQL.Pricing_pm_approval_comments_nm__c;
                quoteLineChangeReq.Pricing_Rejection_Comments_nm__c = parentQL.Pricing_Rejection_Comments_nm__c;
                quoteLineChangeReq.Pricing_Product_Nm__c = parentQL.Pricing_Product_Nm__c;
                quoteLineChangeReq.SBQQ__Product__c = parentQL.Pricing_Product_Nm__c;
                quoteLineChangeReq.Pricing_Other_Product_Nm__c = parentQL.Pricing_Other_Product_Nm__c;
                quoteLineChangeReq.Pricing_OEM_Name_FI_Nm__c = parentQL.Pricing_OEM_Name_FI_Nm__c;
                quoteLineChangeReq.Pricing_OEM_System_Model_Nm__c = parentQL.Pricing_OEM_System_Model_Nm__c;
                quoteLineChangeReq.Pricing_FI_Write_In_OEM_Name_Txt__c = parentQL.Pricing_FI_Write_In_OEM_Name_Txt__c;
                quoteLineChangeReq.Pricing_Form_Factor_Nm__c = parentQL.Pricing_Form_Factor_Nm__c;
                quoteLineChangeReq.Pricing_Competetor_Product__c = parentQL.Pricing_Competetor_Product__c;
                quoteLineChangeReq.Pricing_Competitor_OEM_Name_FI_Nm__c = parentQL.Pricing_Competitor_OEM_Name_FI_Nm__c;
                quoteLineChangeReq.Pricing_Other_Competitor_Product_Nm__c = parentQL.Pricing_Other_Competitor_Product_Nm__c;
                quoteLineChangeReq.Pricing_Fl_CompWriteInOEMName_Txt__c = parentQL.Pricing_Fl_CompWriteInOEMName_Txt__c;
                quoteLineChangeReq.Pricing_Competitor_System_Model_Nm__c = parentQL.Pricing_Competitor_System_Model_Nm__c;
                quoteLineChangeReq.SBQQ__Quote__c = parentQL.SBQQ__Quote__c;
                quoteLineChangeReq.Pricing_Manager__c = parentQL.Pricing_Manager__c;
                
                quoteLineChangeReq.Pricing_Additional_T_C_s_Txt__c = parentQL.Pricing_Additional_T_C_s_Txt__c;
                quoteLineChangeReq.Pricing_Change_Request_cb__c  = true;
                
                quoteLineChangeReq.Pricing_Reference_Quote_Line_Nbr__c = parentQL.Id;
                quoteLineChangeReq.Pricing_Quote_Line_Number__c = Pricing_QuoteLineCloneController.generateQuoteLineNumber(parentQL.Id, parentQL.Pricing_Quote_Line_Number__c,parentQL.Pricing_Reference_Quote_Line_Nbr__c);
                
                quoteLineChangeReq.Pricing_Original_Submitted_By_Id__c = UserInfo.getUserId();
                quoteLineChangeReq.Pricing_Original_Submitted_Date_dt__c = Datetime.now();
                quoteLineChangeReq.Pricing_Last_Submitted_Date_dt__c = Datetime.now();
                quoteLineChangeReq.Pricing_Last_Submitted_By_Id__c = UserInfo.getUserId();
                quoteLineChangeReq.Pricing_Previous_Status_Nm__c = 'Pending';
                
                quoteLineChangeReq.Pricing_Program_Type_Nm__c = parentQL.Pricing_Program_Type_Nm__c;
                quoteLineChangeReq.Pricing_OEM_Account_Nm__c = parentQL.Pricing_OEM_Account_Nm__c;
                quoteLineChangeReq.Pricing_Primary_Contact_Nm__c = parentQL.Pricing_Primary_Contact_Nm__c;
                quoteLineChangeReqList.add(quoteLineChangeReq);
                if(errorList != null && errorList != ''){
                    qlIdToErrorMsgsMap.put(parentQL.Id,errorList);
                    errorList = '';
                }
            }
            if(hasError){
                String errorMsg;
                for(Id qlId : qlIdToErrorMsgsMap.Keyset()){
                    errorMsg = 'Error:'+ qlId + ':' + qlIdToErrorMsgsMap.get(qlId);
                    results.add(errorMsg);
                }
            }else{
                if(quoteLineChangeReqList.size() > 0){
                    List<Database.SaveResult> quoteInsertResult = Database.insert(quoteLineChangeReqList);
                    for(Database.SaveResult successErrorRes : quoteInsertResult){
                        if (successErrorRes.isSuccess()) {
                            results.add(successErrorRes.getId());
                        }else{
                            for(Database.Error err : successErrorRes.getErrors()) {
                                System.debug('The following error has occurred.');
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }
            }
            system.debug('results:'+results);
            if(results.size() > 0 && qlIdToErrorMsgsMap.size() == 0){
                populateQLNumberOnOppLineItemBulk(results,'Create');
            }
        }catch (Exception e) {
            Pricing_Tender_Utility.logError(e);
            String exceptionError = 'Error: ' + e.getMessage();
            exceptionErrorList.add(exceptionError);
            if(exceptionErrorList.size() > 0){
                return exceptionErrorList;
            }
        }
        return results;
    }
    
    public class OpportunityToQuoteLineCRWrapper{
        public Integer quoteLineNewQuantity;
        public Date quoteLineStartDate;
        public Date quoteLineEndDate;
        public Id quoteLineId;
        public String quoteLineAdditionalComments;
        
        public OpportunityToQuoteLineCRWrapper(Integer newQuantity, Date startDate, Date endDate, Id qlId, String additionalComments ){
            quoteLineNewQuantity = newQuantity;
            quoteLineStartDate = startDate;
            quoteLineEndDate = endDate;
            quoteLineId = qlId;
            quoteLineAdditionalComments = additionalComments;
        }
    }
    
    /******************************************************************************************************************
     *Method Name : updateQuoteLineStatus
     *Created Date: 01/19/2024
     *Author: Adarsh Parashar
     *Description : Update Quote Line status for Financial Incentive QLs based on related Opportunity Line Item Status.
     *******************************************************************************************************************/
    public static void updateQuoteLineStatus(List<OpportunityLineItem> OpportunityLineItemList){
        try{
            Set<Id> quoteLineIdSet = new Set<Id>();
            List<SBQQ__QuoteLine__c> ListToUpdateQLs = new List<SBQQ__QuoteLine__c>();
            if(!OpportunityLineItemList.isEmpty()){
                for(OpportunityLineItem OpptyLI : OpportunityLineItemList){
                    quoteLineIdSet.add(OpptyLI.SBQQ__QuoteLine__c);
                }
            }
            if(!quoteLineIdSet.isEmpty()){
                Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([Select Id,Pricing_Status_Nm__c,Pricing_Approved_Start_Date_Dt__c from SBQQ__QuoteLine__c Where Id IN:quoteLineIdSet 
                                                                                          AND (Pricing_Status_Nm__c IN: ((Label.Pricing_Tender_QuoteLine_Status_ApprovedWon).split(':'))) AND Pricing_Quote_Program_Nm__c =: Label.Pricing_Tender_FinancialIncentive_Quote]);
                
                for(OpportunityLineItem OpptyLI : OpportunityLineItemList){
                    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                    if(OpptyLI.Core_Status__c == Label.Pricing_Opportunity_CoreStatus_Lost && quoteLineMap.containsKey(OpptyLI.SBQQ__QuoteLine__c) && quoteLineMap.get(OpptyLI.SBQQ__QuoteLine__c).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved){
                        quoteLine.Id = quoteLineMap.get(OpptyLI.SBQQ__QuoteLine__c)?.Id;
                        quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Action_Lost;
                        ListToUpdateQLs.add(quoteLine);
                    }
                    if(OpptyLI.Core_Status__c == Label.Pricing_Opportunity_CoreStatus_Win && quoteLineMap.containsKey(OpptyLI.SBQQ__QuoteLine__c) && quoteLineMap.get(OpptyLI.SBQQ__QuoteLine__c).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved){
                        quoteLine.Id = quoteLineMap.get(OpptyLI.SBQQ__QuoteLine__c)?.Id;
                        quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Won;
                        ListToUpdateQLs.add(quoteLine);
                    }
                    if(OpptyLI.Core_Status__c == Label.Pricing_Opportunity_CoreStatus_Cancelled && quoteLineMap.containsKey(OpptyLI.SBQQ__QuoteLine__c)){
                        quoteLine.Id = quoteLineMap.get(OpptyLI.SBQQ__QuoteLine__c)?.Id;
                        
                        // TWC1972-6499 Cancelation Logic here
                        if(quoteLineMap.get(OpptyLI.SBQQ__QuoteLine__c).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved){ // QLI Status = Approved
                            quoteLine.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_Approved_End_Date_Dup_Dt__c = quoteLineMap.get(OpptyLI.SBQQ__QuoteLine__c).Pricing_Approved_Start_Date_Dt__c;
                        }else if(quoteLineMap.get(OpptyLI.SBQQ__QuoteLine__c).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won  // QLI Status = WON
                        && quoteLineMap.get(OpptyLI.SBQQ__QuoteLine__c).Pricing_Approved_End_Date_Dt__c > System.today()){// Approved End Date in Future
                            quoteLine.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_Approved_End_Date_Dup_Dt__c = quoteLineMap.get(OpptyLI.SBQQ__QuoteLine__c).Pricing_Approved_Start_Date_Dt__c < System.today() ? System.today() : quoteLineMap.get(OpptyLI.SBQQ__QuoteLine__c).Pricing_Approved_Start_Date_Dt__c;
                            // Approved Start Date in Past ? Approved End date == Cancelation date : Approved End date == Approved Start date
                        }
                        quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Cancelled;
                        quoteLine.Pricing_Cancellation_Date_dt__c = DateTime.now();
                        ListToUpdateQLs.add(quoteLine);
                    }
                }
            }
            if(!ListToUpdateQLs.isEmpty()){
                SBQQ.TriggerControl.disable();
                QuoteLineBusinessLogic.isFinancialIncentive=true;
                List<Database.SaveResult> updateResults = DataBase.Update(ListToUpdateQLs,false);
                SBQQ.TriggerControl.enable();
            }
        }catch(exception ex){
            Pricing_Tender_Utility.logError(ex);
        }finally{
            QuoteLineBusinessLogic.isFinancialIncentive=false;
            SBQQ.TriggerControl.enable();
        }
    }
    
    /**
     * @description Method to insert Quote and Quoteline records from Opportunity
     * @author Sandeep Chamate | 01-19-2024
     * @param oppIds - List of Opportunity Ids from Platform Events
     **/
    @InvocableMethod(label = 'createQuoteQuoteLine' description = 'To insert Quote and Quoteline records from Opportunity')
    public static void createQuoteQuoteLine(List<Id> oppIds) {
        Map<Id,Opportunity> oppIdRecordMap = new Map<Id,Opportunity>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        
        Id recTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', 'Pricing_Financial_Incentive_Quote_Submitted');
        List<Pricing_Integration_Staging__c> pisRecListToUpdate = new List<Pricing_Integration_Staging__c>();
        Map<Id,OpportunityLineItem> oppIdToOppItemRecMap = new Map<Id,OpportunityLineItem>();
        Map<Id,Id> oppIdToProdId = new Map<Id,Id>();
        List<Id> pisOpptyIdList = new List<Id>();
        List<Id> pisOpptyUpdateIdList = new List<Id>();
        boolean isQuoteExisting = false;
        Map<Id, Id> quoteIdToDealRegId = new Map<Id, Id>();
        List<Id> dealRegFailedIds = new List<Id>();
        Map<Id, Boolean> oppIdToBoolean = new Map<Id, Boolean>();
        List<SBQQ__Quote__c> quoteListToInsert = new List<SBQQ__Quote__c>();
        Map<String,String> noOpptyLineItemsErrorMap = new Map<String,String>();
        List<PCC_Deal_Approval_Process_Communication__e> eventsList = new List<PCC_Deal_Approval_Process_Communication__e>();
        
        Set<Id> accountIdFIQuoteSet = new Set<Id>();
        Map<Id,List<String>> accountIdAffiliationFlagMap = new Map<Id,List<String>>();
        
        try {
            for(OpportunityLineItem oppItem: [SELECT Id,Product2Id,Product2.Name,Core_Design_Registration_Product_Id__r.PCC_Quote_Line_Pricing_Start_Date__c,Core_Design_Registration_Product_Id__r.PCC_Quote_Line_Pricing_End_Date__c,Core_Design_Registration_Product_Id__r.PCC_System_Model__c,Core_Design_Registration_Product_Id__r.PCC_Competitor_System_Model__c,OpportunityId,
                                              Core_Design_Registration_Product_Id__r.PCC_OEM_Name__c,Core_Design_Registration_Product_Id__r.PCC_Write_In_OEM_Name__c,Core_Design_Registration_Product_Id__r.PCC_Competitor_OEM_Name__c,Core_Design_Registration_Product_Id__r.PCC_Competitor_Write_In_OEM_Name__c,Core_Design_Registration_Product_Id__r.PCC_Additional_Comments__c,Core_Design_Registration_Product_Id__r.PCC_Competitor_Name__c, 
                                              Core_Design_Registration_Product_Id__r.PCC_Competitor_Product__c,Core_Design_Registration_Product_Id__r.PCC_Write_In_Competitor_Product__c,Core_Design_Registration_Product_Id__r.PCC_Form_Factor__c,Core_Design_Registration_Product_Id__r.Core_Full_Year_Qty__c,SBQQ__QuoteLine__c,Opportunity.Core_Design_Registration_Id__r.Core_Internal_Comment_Txt__c FROM OpportunityLineItem WHERE OpportunityId IN: oppIds Order By Core_Design_Registration_Product_Id__c]) {
                oppIdToOppItemRecMap.put(oppItem.Id,oppItem);
                oppIdToProdId.put(oppItem.Id,oppItem.Product2Id);
                if(oopIdLineItemMap.containsKey(oppItem.OpportunityId)) {
                    oopIdLineItemMap.get(oppItem.OpportunityId).add(oppItem);
                }
                else {
                    oopIdLineItemMap.put(oppItem.OpportunityId, new List<OpportunityLineItem>{oppItem});
                }
            }
            List<Pricing_Integration_Staging__c> pisRecList = [Select Id,Pricing_SObjectId__c,Pricing_Status__c,Pricing_SObject__c,Pricing_Message_Type__c from Pricing_Integration_Staging__c where Pricing_SObjectId__c IN: oppIds and Pricing_Status__c='Pending'];
            for(Pricing_Integration_Staging__c pisRec : pisRecList){
                if(pisRec.Pricing_Message_Type__c == 'Financial Incentive'){
                    pisOpptyIdList.add(pisRec.Pricing_SObjectId__c);
                }else if(pisRec.Pricing_Message_Type__c == 'Financial Incentive Update'){
                    pisOpptyUpdateIdList.add(pisRec.Pricing_SObjectId__c);
                }
            }
            if(!pisOpptyUpdateIdList.isEmpty()){
                Map<Id,SBQQ__QuoteLine__c> existingQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([Select id, name,SBQQ__Quote__r.SBQQ__Opportunity2__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.SBQQ__Opportunity2__c IN: pisOpptyUpdateIdList AND SBQQ__Quote__r.Pricing_Quote_Program_Nm__c = 'Financial Incentive']);
                for(OpportunityLineItem opptyLI : oppIdToOppItemRecMap.Values()){
                    if(existingQuoteLineMap.containsKey(opptyLI.SBQQ__QuoteLine__c)){
                        oppIdToOppItemRecMap.remove(opptyLI.Id);
                        isQuoteExisting = true;
                    }else{
                        oppIdRecordMap.put(oppIdToOppItemRecMap.get(opptyLI.Id)?.OpportunityId,null);
                    }
                }
            }
            if(!pisOpptyIdList.isEmpty() || (isQuoteExisting == false && !pisOpptyUpdateIdList.isEmpty())){
                List<Id> opptyIdforQuoteCreation = new List<Id>();
                if(!pisOpptyIdList.isEmpty() && (isQuoteExisting == false && !pisOpptyUpdateIdList.isEmpty())){
                    opptyIdforQuoteCreation.addAll(pisOpptyIdList);
                    opptyIdforQuoteCreation.addAll(pisOpptyUpdateIdList);
                }else if(!pisOpptyIdList.isEmpty()){
                    opptyIdforQuoteCreation.addAll(pisOpptyIdList);
                }else if(isQuoteExisting == false && !pisOpptyUpdateIdList.isEmpty()){
                    opptyIdforQuoteCreation.addAll(pisOpptyUpdateIdList);
                }
                Map<String, List<String>> countryRegionMap = Pricing_RestAPI_QuotesUtilityV2.getFieldDependencies('SBQQ__Quote__c', 'Pricing_End_Customer_Country_Nm__c', 'Pricing_Region_Nm__c');
                
                for(Opportunity opp: [SELECT Id,Name,PartnerAccountId,AccountId,Core_Design_Registration_Id__c,Core_Design_Registration_Id__r.PCC_Intel_Response_Requested_By_Date__c,
                                      Core_Design_Registration_Id__r.PCC_Pricing_Start_Date__c,Core_Design_Registration_Id__r.PCC_Pricing_End_Date__c,Owner.Email,Core_External_ID__c,Core_Opportunity_Owner_Geo__c,SBQQ__PrimaryQuote__c, 
                                      Core_Design_Registration_Id__r.PCC_Deal_Description__c,Core_Design_Registration_Id__r.PCC_End_Customer_Use__c,Core_Design_Registration_Id__r.PCC_Deal_Project_Name__c,
                                      Core_Design_Registration_Id__r.PCC_Competition_Assumptions__c,Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__c,Core_Design_Registration_Id__r.Core_Partner_Account_Id__c,Core_Design_Registration_Id__r.Core_Vertical_Market_Nm__c,Owner.ContactId,
                                      Core_Design_Registration_Id__r.Core_Intel_Technical_Owner_Id__r.Email,tolabel(Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__r.BillingCountryCode),Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__r.Owner.Email,Core_Technical_Owner__r.Email,
                                      Core_Design_Registration_Id__r.PCC_Consumption_Countries__c,Core_Design_Registration_Id__r.PCC_Current_EndCustomer_Product_Provider__c,Core_Design_Registration_Id__r.PCC_Partner_Reference_ID__c,Core_Design_Registration_Id__r.PCC_Market_Segment__c FROM Opportunity WHERE Id IN: opptyIdforQuoteCreation order by Core_Design_Registration_Id__c]) {
                    oppIdRecordMap.put(opp.Id, opp);
                    oppIdtoDealIdMap.put(opp.Id,opp.Core_Design_Registration_Id__c);
                    SBQQ__Quote__c quote = new SBQQ__Quote__c();
                    quote.RecordTypeId = recTypeId;
                    quote.SBQQ__Status__c = Label.Pricing_Tender_Quote_Status_Submitted;//'Submitted';
                    quote.SBQQ__Account__c = opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__c;
                    accountIdFIQuoteSet.add(opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__c);
                    quote.Pricing_End_Customer_Account__c = opp.Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__c;
                    quote.Pricing_End_Customer_Country_Nm__c = opp.Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__r.BillingCountryCode;
                    quote.Pricing_Region_Nm__c = countryRegionMap.containsKey(opp.Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__r.BillingCountryCode)?countryRegionMap.get(opp.Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__r.BillingCountryCode)[0] : null;
                    quote.Pricing_Market_Segment_values_Nm__c = opp.Core_Design_Registration_Id__r.PCC_Market_Segment__c;
                    quote.Pricing_Project_Name_Nm__c = opp.Core_Design_Registration_Id__r.PCC_Deal_Project_Name__c;
                    quote.Pricing_ShipmentStDate_Dt__c = opp.Core_Design_Registration_Id__r.PCC_Pricing_Start_Date__c;
                    quote.Pricing_ShipmentEndDate_Dt__c = opp.Core_Design_Registration_Id__r.PCC_Pricing_End_Date__c;
                    quote.Pricing_Primary_Contact_Email__c = opp.Core_Technical_Owner__r.Email;//Email we have add and take value from technical owner Email of opp
                    quote.SBQQ__Opportunity2__c = opp.Id;
                    quote.Pricing_Intel_Sales_Rep_Email_Txt__c = opp.Owner.Email;//opp.Core_Design_Registration_Id__r.Core_Intel_Technical_Owner_Id__r.Email;//opp.Owner.Email;//formula
                    quote.Pricing_Intel_Account_Exec_Email_Txt__c = !String.isBlank(opp.Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__r.Owner.Email)? Pattern.matches(Label.Pricing_IQR_IntelEmail_Regex, opp.Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__r.Owner.Email.toLowerCase()) ? opp.Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__r.Owner.Email : '' : '';
                    quote.Pricing_Deal_description__c = opp.Core_Design_Registration_Id__r.PCC_Deal_Description__c;
                    quote.Pricing_Competition_Assumptions__c = opp.Core_Design_Registration_Id__r.PCC_Competition_Assumptions__c;
                    quote.Pricing_Intel_Uses_End_Customer__c = opp.Core_Design_Registration_Id__r.PCC_End_Customer_Use__c;
                    quote.Pricing_Current_EndCustomer_Product_Prvd__c = opp.Core_Design_Registration_Id__r.PCC_Current_EndCustomer_Product_Provider__c;
                    quote.Pricing_Consumption_Countries__c = opp.Core_Design_Registration_Id__r.PCC_Consumption_Countries__c;
                    quote.Pricing_Deal_Registration_Id__c = opp.Core_Design_Registration_Id__c;
                    quote.Pricing_Customer_Reference_Id__c = opp.Core_Design_Registration_Id__r.PCC_Partner_Reference_ID__c;
                    quote.SBQQ__Primary__c = false;
                    quoteList.add(quote);
                }
            }
            
            if(!accountIdFIQuoteSet.isEmpty()){
                for(PRM_IPA_Affiliation__c affiFlag : [SELECT Id, PRM_Builder_Strategy__r.Name, PRM_Account__c FROM PRM_IPA_Affiliation__c 
                                                       WHERE PRM_Account__c IN:accountIdFIQuoteSet 
                                                       AND PRM_Active__c = true // Active Account Affliation
                                                       AND PRM_Builder_Strategy__r.Name IN:((Label.Pricing_FI_Affiliation_Flags).split(','))]){
                    if(accountIdAffiliationFlagMap.containsKey(affiFlag.PRM_Account__c)){
                        accountIdAffiliationFlagMap.get(affiFlag.PRM_Account__c).add(affiFlag.PRM_Builder_Strategy__r.Name);
                    }else{
                        accountIdAffiliationFlagMap.put(affiFlag.PRM_Account__c,new List<String>{affiFlag.PRM_Builder_Strategy__r.Name});
                    }
                }
            }
            
            for(Product_Additional_Attribute__c attribute : [select Id, Product__c,Eligible_for_Deal_Reg__c from Product_Additional_Attribute__c where Product__c in: oppIdToProdId.values() AND Programs_Eligible__c = 'PDI' AND Eligible_for_Deal_Reg__c = true]){
                prodIdToDealRegEligible.put(attribute.Product__c,attribute);
            }
            
            for(OpportunityLineItem oppItem: [SELECT Id,Product2Id,OpportunityId FROM OpportunityLineItem WHERE Product2Id IN: prodIdToDealRegEligible.keyset()]){
                oppIdToBoolean.put(oppItem.OpportunityId,true);
            }
            
            if(prodIdToDealRegEligible.size()> 0){
                
                if(!quoteList.isEmpty()){
                    for(SBQQ__Quote__c quote : quoteList){
                        if(accountIdAffiliationFlagMap.containsKey(quote.SBQQ__Account__c) && accountIdAffiliationFlagMap.get(quote.SBQQ__Account__c).size() > 0){
                            quote.Pricing_FI_Partner_Type__c = String.join(accountIdAffiliationFlagMap.get(quote.SBQQ__Account__c),';');
                        }
                        if(oppIdToBoolean.containsKey(quote.SBQQ__Opportunity2__c)){
                            quoteListToInsert.add(quote);
                        }
                    }
                }
                if(!quoteListToInsert.isEmpty()) {
                    SBQQ.TriggerControl.disable();
                    quoteinsertionSuccessError = Database.insert(quoteListToInsert, false);
                    SBQQ.TriggerControl.enable();
                }
                
                for(SBQQ__Quote__c quote: [SELECT Id, SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Core_Design_Registration_Id__c,SBQQ__LastCalculatedOn__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN: oppIdRecordMap.keySet() and Pricing_Quote_Program_Nm__c = 'Financial Incentive']) {
                    oppIdtoQuoteIdMap.put(quote.SBQQ__Opportunity2__c, quote.Id);
                    quoteIdToDealRegId.put(quote.Id,quote.SBQQ__Opportunity2__r.Core_Design_Registration_Id__c);
                    oppIdtoDealIdMap.remove(quote.SBQQ__Opportunity2__c);
                    quotesMap.put(quote.Id, quote);
                }
                //dealRegFailedIds.addAll(oppIdtoDealIdMap.values());
                //Method to create QuoteLines
                if(!oppIdtoQuoteIdMap.isEmpty()){
                    createQuoteLines(oppIdToOppItemRecMap);
                    createQuoteSharesForFI(new Set<Id>(oppIds));
                }
            }
            for(Pricing_Integration_Staging__c pisRec : pisRecList){
                if(!oppIdtoQuoteIdMap.isEmpty() && oppIdtoQuoteIdMap.containsKey(pisRec.Pricing_SObjectId__c)){
                    pisRec.Pricing_Status__c = 'Successful';
                }else{
                    pisRec.Pricing_Status__c = 'Failed';
                }
                pisRecListToUpdate.add(pisRec);
            }
            if(!pisRecListToUpdate.isEmpty()){
                List<Database.SaveResult> updateResults = DataBase.Update(pisRecListToUpdate,false);
            }
        }
        catch(Exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }
        try{
            //if no oppLine items to opp and if opp has one oppLine item but that line item is not FI eligible then throwing PE.
            for(Id oppId : oppIds){
                if(!oopIdLineItemMap.containsKey(oppId) || !oppIdToBoolean.containsKey(oppId)){
                    eventsList.add(new PCC_Deal_Approval_Process_Communication__e(
                        PCC_Error_Message__c = 'There are no FI Eligible opportunity Line Items',
                    PCC_Object__c= 'Quote',
                    PCC_Record_ID__c = oppIdtoDealIdMap.get(oppId),//deal reg id
                    PCC_Type__c = 'Failure'));
                    noOpptyLineItemsErrorMap.put('Quote insertion Failed:'+oppIdtoDealIdMap.get(oppId),'There are no FI Eligible opportunity Line Items');
                    oppIdtoDealIdMap.remove(oppId);
                }
            }
            
            dealRegFailedIds.addAll(oppIdtoDealIdMap.values());
            
            if(noOpptyLineItemsErrorMap.size() > 0){
                createLogEntry(noOpptyLineItemsErrorMap);
            }
            if(eventsList.size() > 0){
                List<Database.SaveResult> results = EventBus.publish(eventsList);
            }
            
            //publishing platform event for Quote creation success/Failure.
            publishPlatformEvent(quoteIdToDealRegId,dealRegFailedIds);
            
        }catch(Exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }
    }
    
    /**
     * @description :Method to Create Financial Incentive QuoteLines
     * @author ChangeMeIn@UserSettingsUnder.SFDoc | 03-15-2024
     * @param oppItemIdToOppItemRecMap
     **/
    public static void createQuoteLines(Map<Id,OpportunityLineItem> oppItemIdToOppItemRecMap) {
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        List<OpportunityLineItem> oppItemtoUpdate = new List<OpportunityLineItem>();
        Map<String,String> ProductsAndQlInsertionSuccMap = new Map<String,String>();
        Set<Id> oppItemIdSet = new Set<Id>();
        List<Id> listOppoLineItemIds = new List<Id>();
        Map<Id,String> qlIdErrorMsgMap = new Map<Id,String>();
        Set<Id> quoteIds = new Set<Id>();
        
        Id qliRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'Pricing_Financial_Incentive_Quote_Line_Edit');
        try{
            for(OpportunityLineItem oppItem: oppItemIdToOppItemRecMap.values()){
                
                if(oppIdtoQuoteIdMap.containsKey(oppItem.OpportunityId)){
                    if(prodIdToDealRegEligible.containsKey(oppItem.Product2Id)){
                        quoteIds.add(oppIdtoQuoteIdMap.get(oppItem.OpportunityId));
                        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
                        qli.RecordTypeId = qliRecordTypeId;
                        listOppoLineItemIds.add(oppItem.Id);
                        qli.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;//'Pending Further Intel Review';
                        qli.SBQQ__Quote__c = oppIdtoQuoteIdMap.get(oppItem.OpportunityId);
                        qli.Pricing_Approved_Start_Date_Dt__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Quote_Line_Pricing_Start_Date__c;
                        qli.Pricing_Approved_End_Date_Dt__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Quote_Line_Pricing_End_Date__c;
                        qli.Pricing_Approved_Unit_Qty__c = oppItem.Core_Design_Registration_Product_Id__r.Core_Full_Year_Qty__c;
                        qli.Pricing_New_Quantity_qty__c = null;
                        qli.Pricing_Start_Date_dt__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Quote_Line_Pricing_Start_Date__c;
                        qli.Pricing_End_Date_dt__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Quote_Line_Pricing_End_Date__c;
                        qli.Pricing_Product_Nm__c = oppItem.Product2Id;
                        qli.Pricing_OEM_Name_FI_Nm__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_OEM_Name__c;
                        qli.Pricing_FI_Write_In_OEM_Name_Txt__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Write_In_OEM_Name__c;
                        qli.Pricing_Total_Volume_Qty__c = oppItem.Core_Design_Registration_Product_Id__r.Core_Full_Year_Qty__c;
                        qli.Pricing_OEM_System_Model_Nm__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_System_Model__c;
                        qli.Pricing_Form_Factor_Nm__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Form_Factor__c;
                        qli.Pricing_FI_Net_RPU_Amt__c = null;
                        qli.Pricing_Competetor_Product__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Competitor_Product__c;
                        qli.Pricing_Other_Competitor_Product_Nm__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Write_In_Competitor_Product__c;
                        qli.Pricing_Competitor_OEM_Name_FI_Nm__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Competitor_OEM_Name__c;
                        qli.Pricing_Fl_CompWriteInOEMName_Txt__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Competitor_Write_In_OEM_Name__c;
                        qli.Pricing_Competitor_System_Model_Nm__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Competitor_System_Model__c;
                        qli.Pricing_Additional_Comments_Txt__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Additional_Comments__c;
                        qli.Pricing_Competitor_OEM_Nm__c = oppItem.Core_Design_Registration_Product_Id__r.PCC_Competitor_Name__c;
                        qli.Pricing_Additional_T_C_s_Txt__c = null;
                        qli.Pricing_pm_approval_comments_nm__c = oppItem.Opportunity.Core_Design_Registration_Id__r.Core_Internal_Comment_Txt__c;
                        qli.Pricing_Original_Submitted_Date_dt__c = Datetime.now();
                        qli.Pricing_Last_Submitted_Date_dt__c = Datetime.now();
                        qli.Pricing_Sales_Rep_Approver__c = UserInfo.getUserId();
                        quoteLineList.add(qli);
                    }else{
                        ProductsAndQlInsertionSuccMap.put(oppItem.Id,oppItem.Product2.Name);
                    }
                }
            }
            
            if(!quoteLineList.isEmpty()) {
                Integer counter = 0;
                SBQQ.TriggerControl.disable();
                Database.SaveResult[] results = Database.insert(quoteLineList, false);
                SBQQ.TriggerControl.enable();
                for(database.SaveResult sr : results) {
                    if(sr.isSuccess()) {
                        ProductsAndQlInsertionSuccMap.put(sr.getId(),'Success');
                    }
                    else {
                        for(Database.Error err : sr.getErrors()) {
                            qlIdErrorMsgMap.put(listOppoLineItemIds[counter],err.getMessage());
                        }
                    }
                    counter++;
                }
            }
            
            //Run Calculator Service
            if(!quoteIds.isEmpty()) {
                List<Pricing_IQR_Event__e> newsEventList = new List<Pricing_IQR_Event__e>();
                String quoteIdsStr = String.join(quoteIds,',');
                newsEventList.add(new Pricing_IQR_Event__e(Pricing_QuoteId_Txt__c = quoteIdsStr,
                Pricing_IQR_Action_Nm__c = Label.Pricing_Run_CalculatorService_Event));
                
                if(newsEventList.size() > 0){
                    List<Database.SaveResult> results = EventBus.publish(newsEventList);
                }
            }
            
            //updating Ql id On OppLine Item after Ql insertion.
            for(SBQQ__QuoteLine__c qli: [SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,Pricing_Product_Nm__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: oppIdtoQuoteIdMap.values() AND Pricing_Status_Nm__c =: Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview]) {
                for(OpportunityLineItem oppItem: oopIdLineItemMap.get(qli.SBQQ__Quote__r.SBQQ__Opportunity2__c)) {
                    if(!oppItemIdSet.contains(oppItem.Id) && oppItem.Product2Id == qli.Pricing_Product_Nm__c && oppItem.SBQQ__QuoteLine__c == null) {
                        OpportunityLineItem oppLineItem = new OpportunityLineItem();
                        oppLineItem = oppItem;
                        oppLineItem.SBQQ__QuoteLine__c = qli.Id;
                        oppItemIdSet.add(oppItem.Id);
                        oppItemtoUpdate.add(oppLineItem);
                        break;
                    }
                }
            }
            if(!oppItemtoUpdate.isEmpty()) {
                //Database.update(oppItemtoUpdate, false);
                Core_Opp_Bypass_Validation_Rule__c mapBypassValidation = Core_Opp_Bypass_Validation_Rule__c.getInstance();
                mapBypassValidation.Bypass__c = true;
                upsert mapBypassValidation;
                update oppItemtoUpdate;
            }
            if(!qlIdErrorMsgMap.isEmpty()){
                createQlErrorLogEntry(qlIdErrorMsgMap);
            }
            if(ProductsAndQlInsertionSuccMap.size()>0){
                createLogEntry(ProductsAndQlInsertionSuccMap);
            }
        }catch(Exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }
    }
    
    /**
     * @description :Mthod to send Success/Failure of Quote insertion back to Deal Reg through Platform Event.
     * @author ChangeMeIn@UserSettingsUnder.SFDoc | 03-15-2024
     * @param quoteIdToDealRegId
     * @param dealRegFailedIds
     **/
    public static void publishPlatformEvent(Map<Id, Id> quoteIdToDealRegId,List<Id> dealRegFailedIds) {
        Map<String,String> quoteInsertErrorMsgMap = new Map<String,String>();
        List<PCC_Deal_Approval_Process_Communication__e> eventList = new List<PCC_Deal_Approval_Process_Communication__e>();
        if(quoteinsertionSuccessError != null && quoteinsertionSuccessError.size()> 0){
            Integer count = 0;
            for(database.SaveResult sr : quoteinsertionSuccessError) {
                if(sr.isSuccess()) {
                    eventList.add(new PCC_Deal_Approval_Process_Communication__e(
                        PCC_Error_Message__c = '',
                    PCC_Object__c= 'Quote',
                    PCC_Record_ID__c = quoteIdToDealRegId.get(sr.getId()),
                    PCC_Type__c = 'Success'));
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        eventList.add(new PCC_Deal_Approval_Process_Communication__e(
                            PCC_Error_Message__c = err.getMessage(),
                        PCC_Object__c= 'Quote',
                        PCC_Record_ID__c = dealRegFailedIds[count],
                        PCC_Type__c = 'Failure'));
                        quoteInsertErrorMsgMap.put('Quote insertion Failed:'+dealRegFailedIds[count],err.getMessage());
                    }
                    count++;
                }
            }
        }
        
        if(quoteInsertErrorMsgMap.size() > 0){
            createLogEntry(quoteInsertErrorMsgMap);
        }
        if(eventList.size() > 0){
            List<Database.SaveResult> results = EventBus.publish(eventList);
        }
    }
    
    
    /**
     * @description :Method to pupulate Quote line id on opportunity Line item when QL change Request is created/Rejected/Approved.
     * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-27-2024
     * @param parentId
     * @param childQuoteLineId
     * @param action
     **/
    @future
    public static void populateQLNumberOnOppLineItem(Id parentQuoteLineId,Id childQuoteLineId,String action) {
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItem = new List<OpportunityLineItem>();
        SBQQ__QuoteLine__c qlChild = new SBQQ__QuoteLine__c();
        try{
            if(childQuoteLineId != null){
                qlChild= [SELECT Id,Pricing_Additional_Comments_Txt__c,Pricing_Status_Nm__c,Pricing_Approved_Unit_Qty__c FROM SBQQ__QuoteLine__c WHERE Id =: childQuoteLineId];
            }
            SBQQ__QuoteLine__c qlParent= [SELECT Id,Pricing_Additional_Comments_Txt__c,Pricing_Quote_Line_Number__c,Pricing_Approved_Unit_Qty__c FROM SBQQ__QuoteLine__c WHERE Id =: parentQuoteLineId];
            String query = 'SELECT Id,Product2Id,SBQQ__QuoteLine__c,Core_Design_Registration_Product_Id__r.PCC_Additional_Comments__c,Quantity FROM OpportunityLineItem WHERE ';
            if(parentQuoteLineId != null){
                query = query + 'SBQQ__QuoteLine__c =: parentQuoteLineId';
            }
            if(parentQuoteLineId != null && childQuoteLineId != null){
                query = query + ' OR ';
            }
            if(childQuoteLineId != null){
                query = query + 'SBQQ__QuoteLine__c =: childQuoteLineId';
            }
            if(!String.isBlank(query)){
                oppLineItem = Database.query(query);
            }
            if(oppLineItem.size() > 0){
                for(OpportunityLineItem oppItem :oppLineItem){
                    if(qlChild != null && action != 'Reject' && (qlChild.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview || qlChild.Pricing_Status_Nm__c == 'Approved')){
                        oppItem.SBQQ__QuoteLine__c = qlChild.id;
                    }else if(qlParent!= null && action == 'Reject'){
                        oppItem.SBQQ__QuoteLine__c = qlParent.id;
                    }
                    if(action == 'Approve'){
                        if(qlChild != null && qlChild.Pricing_Approved_Unit_Qty__c != null){
                            oppItem.Quantity =qlChild.Pricing_Approved_Unit_Qty__c;
                        }else if(qlParent!= null && qlParent.Pricing_Approved_Unit_Qty__c != null){
                            oppItem.Quantity =qlParent.Pricing_Approved_Unit_Qty__c;
                        }
                    }
                    oppLineItemList.add(oppItem);
                }
            }
            if(oppLineItemList.size() > 0){
                Core_Opp_Bypass_Validation_Rule__c mapBypassValidation = Core_Opp_Bypass_Validation_Rule__c.getInstance();
                mapBypassValidation.Bypass__c = true;
                SBQQ.TriggerControl.disable();
                upsert mapBypassValidation;
                update oppLineItemList;
                SBQQ.TriggerControl.enable();
            }
        }catch(Exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }finally{
            SBQQ.TriggerControl.enable();
        }
    }
    
    /**
     * @description :Method to insert Quote Line Insertion Failure in Core Log Entry.
     * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-26-2024
     * @param qlErrorMessageMap
     **/
    public static void createQlErrorLogEntry(Map<Id, String> qlErrorMessageMap) {
        List<Core_Log_Entry__c> logEntryList =  new List<Core_Log_Entry__c>();
        for(Id qlId : qlErrorMessageMap.keySet()){
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
            logEntry.Core_Severity__c = 'Critical';
            logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
            logEntry.Core_Origin__c = 'Financial Incentive';
            logEntry.Core_Support_Email__c = System.Label.Pricing_IQR_Support_Email;
            logEntry.Core_Message__c = 'Financial Incentive QuoteLine Insertion Failed';
            logEntry.Core_Details__c = qlErrorMessageMap.get(qlId);
            logEntry.Core_sObjectId__c = qlId;
            logEntry.Core_When__c = system.now();
            logEntryList.add(logEntry);
        }
        
        if(logEntryList.size() > 0) {
            insert logEntryList;
        }
    }
    
    /**
     * @description :Method to insert FI not Eligible products and Quote Line insertion success Message in core log object.
     * @author ChangeMeIn@UserSettingsUnder.SFDoc | 03-15-2024
     * @param ProductAndQlInsertionSuccMap
     **/
    public static void createLogEntry(Map<String,String> ProductAndQlInsertionSuccMap) {
        List<Core_Log_Entry__c> logEntryList =  new List<Core_Log_Entry__c>();
        for(String prodcutOrQlIds :ProductAndQlInsertionSuccMap.keyset()){
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
            logEntry.Core_sObjectId__c = !prodcutOrQlIds.contains('Quote insertion Failed') ? prodcutOrQlIds : prodcutOrQlIds.substringAfter(':');
            //logEntry.Core_sObjectType__c = prodcutOrQlIds != 'Quote insertion Failed' ?prodcutOrQlIds.getSObjectType().getDescribe().getName() : '';
            logEntry.Core_Severity__c = !prodcutOrQlIds.contains('Quote insertion Failed') ? 'Medium' : 'Critical';
            logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
            logEntry.Core_Origin__c = 'Financial Incentive';
            logEntry.Core_Support_Email__c = System.Label.Pricing_IQR_Support_Email;
            logEntry.Core_Message__c = ProductAndQlInsertionSuccMap.get(prodcutOrQlIds) == 'Success' ? 'Financial Incentive QuoteLine Inserted Successfully' :  prodcutOrQlIds.contains('Quote insertion Failed') ? prodcutOrQlIds.substringBefore(':') :'FI Not Eligible Products';
            logEntry.Core_Details__c = ProductAndQlInsertionSuccMap.get(prodcutOrQlIds);
            logEntry.Core_When__c = system.now();
            logEntryList.add(logEntry);
        }
        if(!logEntryList.isEmpty()) {
            insert logEntryList;
        }
    }
    /******************************************************************************************************************
     *Method Name : updateOpportunityOwnerName
     *Created Date: 03/19/2024
     *Author: Adarsh Parashar
     *Description : Update Opportunity Owner & Technical Owner to Financial Incentive Quotes respective fields.
     *******************************************************************************************************************/
    public static void updateOpportunityOwnerName(Map<Id,Opportunity> oppIdToOpptyRecordMap){
        List<SBQQ__Quote__c> quoteListToUpdate = new List<SBQQ__Quote__c>();
        Set<Id> oppIds = new Set<Id>(oppIdToOpptyRecordMap.keySet());
        List<Core_Log_Entry__c> logEntryList =  new List<Core_Log_Entry__c>();
        try{
            List<SBQQ__Quote__c> quoteList = [Select Id,SBQQ__Opportunity2__c,SBQQ__PrimaryContact__c,SBQQ__PrimaryContact__r.OwnerId,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c from SBQQ__Quote__c where SBQQ__Opportunity2__c IN: oppIdToOpptyRecordMap.keySet() AND Pricing_Quote_Program_Nm__c ='Financial Incentive'];
            for(SBQQ__Quote__c quote : quoteList){
                boolean hasOwnerChanged = false;
                if(oppIdToOpptyRecordMap.containsKey(quote.SBQQ__Opportunity2__c)){
                    if(quote.SBQQ__PrimaryContact__c != oppIdToOpptyRecordMap.get(quote.SBQQ__Opportunity2__c).Core_Technical_Owner__r.ContactId){
                        quote.SBQQ__PrimaryContact__c = oppIdToOpptyRecordMap.get(quote.SBQQ__Opportunity2__c).Core_Technical_Owner__r.ContactId;
                        hasOwnerChanged=true;
                    }
                    if(quote.SBQQ__SalesRep__c != oppIdToOpptyRecordMap.get(quote.SBQQ__Opportunity2__c).OwnerId){
                        quote.SBQQ__SalesRep__c = oppIdToOpptyRecordMap.get(quote.SBQQ__Opportunity2__c).OwnerId;
                        quote.Pricing_Intel_Sales_Rep_Email_Txt__c = oppIdToOpptyRecordMap.get(quote.SBQQ__Opportunity2__c).Owner?.Email;
                        hasOwnerChanged=true;
                    }
                }
                if(hasOwnerChanged){
                    quoteListToUpdate.add(quote);
                }
            }
            if(!quoteListToUpdate.isEmpty()){
                Database.SaveResult[] results = Database.update(quoteListToUpdate, false);
                for(database.SaveResult sr : results){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()){
                            Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
                            logEntry.Core_Severity__c = 'Critical';
                            logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
                            logEntry.Core_Origin__c = 'Pricing_FinancialIncentive_BusinessLogic';
                            logEntry.Core_Support_Email__c = System.Label.Pricing_IQR_Support_Email;
                            logEntry.Core_Message__c = 'Financial Incentive Quote Updation Failed for Primary Contact or Sales Rep.';
                            logEntry.Core_Details__c = err.getMessage();
                            logEntry.Core_When__c = system.now();
                            logEntryList.add(logEntry);
                        }
                    }
                }
                createQuoteSharesForFI(oppIds);
            }
            if(!logEntryList.isEmpty()){
                insert logEntryList;
            }
        }catch(exception ex){
            Pricing_Tender_Utility.logError(ex);
        }
    }
    
    /**
     * @description Method to Share Quote Records with Opportunity Team Members
     * @author Sandeep Chamate | 03-18-2024
     * @param oppIds - Opportunity Ids for which Quote needs to be shared
     **/
    public static void createQuoteSharesForFI(Set<Id> oppIds) {
        List<SBQQ__Quote__Share> quoteSharesList = new List<SBQQ__Quote__Share>();
        List<SBQQ__Quote__Share> quoteDeleteShares = new List<SBQQ__Quote__Share>();
        Map<Id,Id> oppIdToQuoteIdMap = new Map<Id,Id>();
        Map<Id,Set<Id>> quoteIdToUserIDsMap = new Map<Id,Set<Id>>();
        Map<Id,Set<SBQQ__Quote__Share>> quoteIdToUserSetMap = new Map<Id,Set<SBQQ__Quote__Share>>();
        Map<Id,Set<Id>> oppIdToOppUserIDsMap = new Map<Id,Set<Id>>();
        try {
            //fetch corresponding Quote Records for Opportunity
            for(SBQQ__Quote__c quote: [SELECT Id,SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN: oppIds AND Pricing_Quote_Program_Nm__c =: Label.Pricing_Tender_FinancialIncentive_Quote]) {
                oppIdToQuoteIdMap.put(quote.SBQQ__Opportunity2__c, quote.Id);
            }
            
            //fetch existing Quote Share Records
            if(!oppIdToQuoteIdMap.isEmpty()){
                for(SBQQ__Quote__Share quoteShr : [SELECT Id,ParentId,UserOrGroupId,Parent.SBQQ__Opportunity2__c FROM SBQQ__Quote__Share WHERE ParentId IN: oppIdToQuoteIdMap.values() AND RowCause =: Schema.SBQQ__Quote__Share.RowCause.Pricing_Opportunity_Sharing__c]) {
                    if(quoteIdToUserIDsMap.containsKey(quoteShr.ParentId)) {
                        quoteIdToUserIDsMap.get(quoteShr.ParentId).add(quoteShr.UserOrGroupId);
                        quoteIdToUserSetMap.get(quoteShr.ParentId).add(quoteShr);
                    }
                    else {
                        quoteIdToUserIDsMap.put(quoteShr.ParentId, new Set<Id>{quoteShr.UserOrGroupId});
                        quoteIdToUserSetMap.put(quoteShr.ParentId, new Set<SBQQ__Quote__Share>{quoteShr});
                    }
                }
                
                //Inserting quote share records if not present
                for(OpportunityTeamMember oppTeam: [SELECT Id,OpportunityId,UserId FROM OpportunityTeamMember WHERE OpportunityId IN: oppIds]) {
                    if(!quoteIdToUserIDsMap.containsKey(oppIdToQuoteIdMap.get(oppTeam.OpportunityId)) || (quoteIdToUserIDsMap.containsKey(oppIdToQuoteIdMap.get(oppTeam.OpportunityId)) && !quoteIdToUserIDsMap.get(oppIdToQuoteIdMap.get(oppTeam.OpportunityId)).contains(oppTeam.UserId))) {
                        SBQQ__Quote__Share quoteShr = new SBQQ__Quote__Share();
                        quoteShr.ParentId = oppIdToQuoteIdMap.get(oppTeam.OpportunityId);
                        quoteShr.UserOrGroupId = oppTeam.UserId;
                        quoteShr.AccessLevel = 'Read';
                        quoteShr.RowCause = Schema.SBQQ__Quote__Share.RowCause.Pricing_Opportunity_Sharing__c;
                        quoteSharesList.add(quoteShr);
                    }
                    if(oppIdToOppUserIDsMap.containsKey(oppTeam.OpportunityId)) {
                        oppIdToOppUserIDsMap.get(oppTeam.OpportunityId).add(oppTeam.UserId);
                    }
                    else {
                        oppIdToOppUserIDsMap.put(oppTeam.OpportunityId, new Set<Id>{oppTeam.UserId});
                    }
                }
                
                //Delete existing records from Quote Share which are not present in Opportunity Team
                if(!quoteIdToUserIDsMap.isEmpty()) {
                    for(Id recId: oppIdToQuoteIdMap.keySet()) {
                        Set<Id> userIdSet = oppIdToOppUserIDsMap.get(recId);
                        if(quoteIdToUserSetMap.containsKey(oppIdToQuoteIdMap.get(recId))) {
                            for(SBQQ__Quote__Share quoteShr: quoteIdToUserSetMap.get(oppIdToQuoteIdMap.get(recId))) {
                                if(!userIdSet.contains(quoteShr.UserOrGroupId)) {
                                    quoteDeleteShares.add(quoteShr);
                                }
                            }
                        }
                    }
                }
                
                if(!quoteSharesList.isEmpty()) {
                    insert quoteSharesList;
                }
                if(!quoteDeleteShares.isEmpty()) {
                    delete quoteDeleteShares;
                }
            }
        }
        catch(exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }
    }
    
    /**
     * @description :Method to pupulate Quote line id on opportunity Line item when QL change Request is created/Rejected/Approved.
     * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-27-2024
     * @param parentId
     * @param
     * @param action
     **/
    @future
    public static void populateQLNumberOnOppLineItemBulk(List<Id> quoteLineIdList,String action) {
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItemToUpdateList = new List<OpportunityLineItem>();
        Map<Id,SBQQ__QuoteLine__c> quoteLineMap;
        Map<Id,SBQQ__QuoteLine__c> referenceQlIdToChildQlRecord = new Map<Id,SBQQ__QuoteLine__c>();
        List<Id> referenceQlIds = new List<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        Boolean isChangedFIProducts = false;
        try{
            system.debug('quoteLineIdList:'+quoteLineIdList);
            if(quoteLineIdList.size() > 0){
                quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id,SBQQ__Quote__c,Pricing_Additional_Comments_Txt__c,Pricing_Quote_Line_Number__c,Pricing_Approved_Unit_Qty__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_New_Quantity_qty__c FROM SBQQ__QuoteLine__c WHERE Id IN : quoteLineIdList]);
                //if(action == 'Create'){
                    for(SBQQ__QuoteLine__c ql :quoteLineMap.values()){
                        quoteIdSet.add(ql.SBQQ__Quote__c);
                        if(action == 'Create'){
                            if(ql.Pricing_Reference_Quote_Line_Nbr__c != null){
                                referenceQlIds.add(ql.Pricing_Reference_Quote_Line_Nbr__c);
                                referenceQlIdToChildQlRecord.put(ql.Pricing_Reference_Quote_Line_Nbr__c,ql);
                            }
                        }
                    }
                    system.debug('quoteIdSet:'+quoteIdSet);
                    String oppQuery = 'SELECT Id,Product2Id,SBQQ__QuoteLine__c,Core_Design_Registration_Product_Id__r.PCC_Additional_Comments__c,Quantity FROM OpportunityLineItem WHERE ';
                    if(action == 'Create' && referenceQlIdToChildQlRecord.size() > 0){
                        oppQuery = oppQuery + 'SBQQ__QuoteLine__c IN : referenceQlIds';
                    }else{
                        oppQuery = oppQuery + 'SBQQ__QuoteLine__c IN : quoteLineIdList';
                    }
                    oppLineItemList = Database.query(oppQuery);
                }
                if(oppLineItemList.size() > 0){
                    for(OpportunityLineItem oppItem : oppLineItemList){
                        if(action == 'Approved' || action == Label.Pricing_Tender_QuoteLine_Action_Approve){
                            oppItem.Quantity = quoteLineMap.get(oppItem.SBQQ__QuoteLine__c).Pricing_Reference_Quote_Line_Nbr__c != null? quoteLineMap.get(oppItem.SBQQ__QuoteLine__c).Pricing_New_Quantity_qty__c :quoteLineMap.get(oppItem.SBQQ__QuoteLine__c).Pricing_Approved_Unit_Qty__c;
                            oppLineItemToUpdateList.add(oppItem);
                        }else if (action == 'Create'){
                            oppItem.SBQQ__QuoteLine__c = referenceQlIdToChildQlRecord.get(oppItem.SBQQ__QuoteLine__c).Id;
                            oppLineItemToUpdateList.add(oppItem);
                        }else if(action == 'Reject' || action == 'Rejected'){
                            if(quoteLineMap.get(oppItem.SBQQ__QuoteLine__c).Pricing_Reference_Quote_Line_Nbr__c != null){
                                oppItem.SBQQ__QuoteLine__c = quoteLineMap.get(oppItem.SBQQ__QuoteLine__c).Pricing_Reference_Quote_Line_Nbr__c;
                                oppLineItemToUpdateList.add(oppItem);
                            }
                        }
                    }
                }
                if(oppLineItemToUpdateList.size() > 0){
                    Core_Opp_Bypass_Validation_Rule__c mapBypassValidation = Core_Opp_Bypass_Validation_Rule__c.getInstance();
                    mapBypassValidation.Bypass__c = true;
                    SBQQ.TriggerControl.disable();
                    upsert mapBypassValidation;
                    update oppLineItemToUpdateList;
                    SBQQ.TriggerControl.enable();
                }
                
                if(quoteIdSet.size() > 0){
                    Id quoteId;
                    for(SBQQ__QuoteLine__c ql : [SELECT Id,Pricing_Program_Type_Nm__c,SBQQ__Quote__c,Pricing_New_Change_Request_cb__c,Pricing_Status_Nm__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN : quoteIdSet]){
                        if(ql.Pricing_Program_Type_Nm__c == 'Financial Incentive' && ql.Pricing_New_Change_Request_cb__c && ((ql.Pricing_Status_Nm__c == 'Approved' || ql.Pricing_Status_Nm__c == 'Rejected') && ql.Pricing_Status_Nm__c != 'Pending Further Intel Review')){
                            isChangedFIProducts = true;
                        }
                        quoteId = ql.SBQQ__Quote__c;
                    }
                    system.debug('isChangedFIProducts:'+isChangedFIProducts);
                    if(isChangedFIProducts){
                        Database.SaveResult fiCRApproveOrRejectEvent = EventBus.publish(new PCC_Deal_Approval_Process_Communication__e(
                            PCC_Error_Message__c = 'Success',
                        PCC_Object__c = 'Quote',
                        PCC_Record_ID__c = quoteId,
                        PCC_Type__c = 'Change Request : Products Changed'));
                        
                        system.debug('fiCRApproveOrRejectEvent:'+fiCRApproveOrRejectEvent);
                    }
                }
            }catch(Exception ex) {
                Pricing_Tender_Utility.logError(ex);
            }finally{
                SBQQ.TriggerControl.enable();
            }
        }
    }