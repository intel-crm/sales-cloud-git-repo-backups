/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 04-28-2026
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QuoteLineCloneController {   
    /**
* @description Clone parent and its children
* @param id of the parent sObject
* @return new parent id
*/
    
    static Boolean isChangedProduct = false;
    
    @AuraEnabled
    public Static GlobalVariables doClone (SBQQ__QuoteLine__c quoteLine, String action) {
        String sObjectId = quoteLine.Id;
        Boolean oemCR  = false;
        Boolean fiRPMCR = false;
        GlobalVariables globalVar = new GlobalVariables();
        //Pricing_Publish_Quote.quoteQTMMemberIdMap;
        List<SBQQ__QuoteLine__c> parentSObjects;
        SBQQ__QuoteLine__c parent;
        String query;
        String quoteLineNumber = '';
        Map<Id,Set<Id>> quoteIdQTMMemberIdMap = new Map<Id,Set<Id>>();
        try {
            // Quote query
            query = String.format(
                'SELECT {0} FROM {1} WHERE Id = \'\'{2}\'\'',
                new String[] {
                    String.join(
                        new List<String>(
                            SBQQ__QuoteLine__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet()
                        ),
                        ','
                    ),
                        String.valueOf(SBQQ__QuoteLine__c.SObjectType),
                        String.escapeSingleQuotes(sObjectId)
                        }
            );            
            // Query and gets results
            parentSObjects = Database.query(query);
            
            // Clone the original object. Here you can change anything without affecting the original sObject
            parent = parentSObjects[0].clone(false, true, false, false);
            if(action == Label.Pricing_Tender_QuoteLine_Action_Request_Change){
                List<String> rpmPermissionList = new List<String>();
                if(parentSObjects[0].Pricing_Quote_Program_Nm__c == 'Financial Incentive'){
                    rpmPermissionList = userHasFIPMPermissionSet();
                }else{
                    rpmPermissionList = userHasRPMPermissionSet();
                }
                oemCR = (rpmPermissionList != null)?false:true;
                Set<Id> userIds = new Set<Id>{UserInfo.getUserId()};
                    Set<Id> userHasFIRPMPermissionSetIds = new Set<Id>();
                userHasFIRPMPermissionSetIds = Pricing_EmailUtility.checkUserHasValidPermission(userIds,Label.Pricing_Tender_PermissionSets_FinancialIncentivePricingManager);
                fiRPMCR = userHasFIRPMPermissionSetIds.size() > 0?true:false;
            }
            parent = quotelineFieldPopulation(parentSObjects[0],parent,quoteLine,action,oemCR,fiRPMCR);
            quoteLineNumber = parent.Pricing_Quote_Line_Number__c;
            if(!oemCR && action == Label.Pricing_Tender_QuoteLine_Action_Request_Change && TriggerHandler.isActive('Pricing_RPMCR_TriggerEnable')){
                SBQQ.TriggerControl.disable();
                Database.insert(parent);
                SBQQ.TriggerControl.enable();
                if(parentSObjects[0].Pricing_Quote_Program_Nm__c == 'Financial Incentive'){
                    Pricing_FinancialIncentive_BusinessLogic.populateQLNumberOnOppLineItem(parentSObjects[0].id,parent.id,'Approve');
                }
            }
            else{
                Database.insert(parent);
            }
            //Validate FSE and create Approval records for valid FSEs
            if(parent.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && parent.Pricing_Change_Request_cb__c == true){
                //Retrigger Approval Process for OEM Change Request
                quoteIdQTMMemberIdMap = Pricing_Publish_Quote.validateQtmFse(new Set<Id>{parent.SBQQ__Quote__c});
                if(quoteIdQTMMemberIdMap.size() > 0){
                    Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(new Set<Id>{parent.Id});
                    Pricing_EmailUtility.sendEmailToReciepents(new Set<Id>{parent.Id}, 'Pricing_AE_QuoteLineCRNotification');
                }
            }
            
        } catch (Exception error) {
            String retMsg = null;
            return Pricing_Tender_Utility.handleError(globalVar, error, retMsg, sObjectId, quoteLineNumber);     
        }
        finally{
            SBQQ.TriggerControl.enable();
        }
        
        // Quote Line query  
        query = String.format(
            'SELECT {0} FROM {1} WHERE Pricing_Quote_Line__c = \'\'{2}\'\'',
            new String[] {
                String.join(
                    new List<String>(
                        Pricing_Performance_Metric__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet()
                    ),
                    ','
                ),
                    String.valueOf(Pricing_Performance_Metric__c.SObjectType),
                    String.escapeSingleQuotes(sObjectId)//ch
                    }
        );        
        
        List<Pricing_Performance_Metric__c> children = new List<Pricing_Performance_Metric__c>();
        try {
            // Query and clone the children. Here you can change anything without affecting the original sObject            
            for(Pricing_Performance_Metric__c child:(List<Pricing_Performance_Metric__c>)Database.query(query)){
                Pricing_Performance_Metric__c newPM = child.clone(false,true); // deep clone
                newPM.Pricing_Quote_Line__c = parent.Id; //set parent ref
                children.add(newPM);
            }            
            
            if(!children.isEmpty()){
                Database.insert(children);
            }                        
            
        }  catch(Exception error) {
            String retMsg = null;
            return Pricing_Tender_Utility.handleError(globalVar, error, retMsg, sObjectId, null);
        }
        doCloneReqChange(action,parent,globalVar);
        globalVar.quoteLineId = parent.Id;
        return globalVar;
    }
    
    public static SBQQ__QuoteLine__c quotelineFieldPopulation(SBQQ__QuoteLine__c parentSObjects,SBQQ__QuoteLine__c parent,SBQQ__QuoteLine__c quoteLine,String action,Boolean oemCR, Boolean fiRPMCR){ 
        
        if(action == Label.Pricing_Tender_QuoteLine_Action_Request_Change){
            if(fiRPMCR || !oemCR){
                rpmCRAutoPopulation(parentSObjects ,parent, quoteLine);    
            }else{
                oEMCRAutoPopulation(parent, quoteLine);
            }
            parent.Pricing_Reference_Quote_Line_Nbr__c = parentSObjects.Id;
            parent.Pricing_Quote_Line_Number__c = generateQuoteLineNumber(parentSObjects.Id, parentSObjects.Pricing_Quote_Line_Number__c,parentSObjects.Pricing_Reference_Quote_Line_Nbr__c);                                
            //parent.Pricing_Change_Request_cb__c = true;
            
            //TPT
            parent.Pricing_Original_Submitted_By_Id__c = UserInfo.getUserId();
            parent.Pricing_Original_Submitted_Date_dt__c = Datetime.now();
            parent.Pricing_Last_Submitted_Date_dt__c = Datetime.now();
            parent.Pricing_Last_Submitted_By_Id__c = UserInfo.getUserId();
            //TPT
        }
        else{
            cloneAutopopulation(parent, quoteLine);
        }
        Parent.Pricing_Deal_RFQ_Dup_Id__c = null; //Duplicate Field            
        parent.Pricing_Previous_Status_Nm__c = 'Pending';
        parent.Pricing_Sales_Rep_Approver__c = null;
        parent.Pricing_Ready_for_Review_cb__c = false;
        
        //TPT            
        parent.Customer_Revision_Count_Cnt__c = null;
        parent.Field_Revision_Count_Cnt__c = null;            
        //TPT
        
        //walk story updates US544539
        parent.Pricing_Integration_Status_Nm__c = null;
        parent.Pricing_Deal_RFQ_Status_Nm__c = null;
        parent.Pricing_Error_Messages__c = null;
        parent.Pricing_Price_Rule_Error_Message__c = null;
        parent.Pricing_Approval_Price_Rule_Name__c = null;
        //walk story updates US544539
        
        
        parent.Pricng_Exclude_from_Price_Approval_Rules__c = false;
        parent.Pricing_Group_Type_nm__c = Label.Pricing_Tender_Default_Group_Type;
        parent.Pricing_Quote_Line_Status_Number__c = null;
        parent.Pricing_Integration_Time_Stamp__c = null;
        parent.Pricing_Previous_MyDeal_Action_Nm__c = null;
        parent.Pricing_Create_Deal_Actor_Id__c = null;
        parent.Pricing_Update_Status_to_Rejected_cb__c = false;
        parent.Pricing_Previous_Inbound_Msg_Number__c = null;
        parent.Pricing_Approved_Rejected_Month_Txt__c = null;
        
        //blank out Performance Metrics fields for Client Quote Line on Clone
        if(parent.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote){
            parent.Pricing_Comp_SKU_Performance_Nbr__c = null;
            parent.Pricing_Intel_SKU_Performance_Nbr__c = null;
            parent.Pricing_Performance_Metric_Nm__c = null;
            parent.Pricing_Write_In_Performance_Metric_Nm__c = null;
        }
        
        //blank out AI fields on clone, OEM CR, RPM CR
        
        parent.Pricing_Recommendation_FeedBack_Nm__c = null;  
        parent.Pricing_Recommended_Price_Amt__c = null;
        
        parent.Pricing_Rejection_Reason__c = null;
        parent.Pricing_Save_After_Calculation_cb__c = false;
        parent.Pricing_Lost_Reason_Nm__c = null;
        
        parent.Pricing_Application_Agent_Status__c = null; 
        parent.Pricing_Rationale_for_Pricing__c = null;
        parent.Pricing_HPC_Eligible_Pricing_Envelope__c = null;//PAA V2
        return parent;
    }
    
    public static void doCloneReqChange(String action,SBQQ__QuoteLine__c parent,GlobalVariables globalVar){
        if(action == Label.Pricing_Tender_QuoteLine_Action_Request_Change){
            List<String> rpmPermissionList = new List<String>();
            rpmPermissionList = userHasRPMPermissionSet();
            if(rpmPermissionList != null && !rpmPermissionList.isEmpty() && (String.isNotBlank(parent.Pricing_Deal_RFQ_Id__c) || isChangedProduct)) {
                String dealAction = isChangedProduct ? 'Create' : 'Update';
                String process = Pricing_QuoteLineController.insertOutbound(parent.Id,dealAction);                
                if(process == 'Success'){
                    globalVar.messageResult = Label.Pricing_ChangeRequest_RPM_Success_Message;
                    globalVar.isSuccess = true;
                }else{
                    globalVar.messageResult = process;//Label.Pricing_ChangeRequest_RPM_Error_Message;
                    globalVar.isSuccess = false;
                }
            }else{
                globalVar.messageResult = Label.Pricing_ChangeRequest_OEM_Success_Message;
                globalVar.isSuccess = true;
            }
            
        }else{
            globalVar.messageResult = Label.Pricing_Tender_QuoteLine_Clone_Success_Message;
            globalVar.isSuccess = true;
        }
    }
    
    @AuraEnabled
    public static SBQQ__QuoteLine__c getQuoteLine(Id quoteLineId){
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Pricing_Status_Nm__c,Pricing_Other_Product_Nm__c,SBQQ__ProductName__c,Pricing_Quote_Line_Number__c,
                                        Pricing_FSE_Recommended_Price_Nm__c, Pricing_ECAP_Price_Amt__c, Pricing_Approved_Start_Date_Dt__c,Pricing_Quote_Program_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,
                                        Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Unit_Qty__c,
                                        Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Payable_Quantity__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Additional_Comments_Txt__c,
                                        Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Additional_T_C_s_Txt__c,Pricing_Backdate_Reason_Txt__c,
                                        Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c, SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Deal_RFQ_Id__c,Pricing_Consumption_Segment__c,
                                        Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,Pricing_Consumption_Region__c,
                                        Pricing_End_Date_dt__c,Pricing_Deal_Description__c,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Account__c,Pricing_Program_Type_Nm__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Country__c,
                                        Pricing_Product_Nm__c,Pricing_SIPP_Cb__c,Pricing_Market_Segment_values_Nm__c,Pricing_Change_Request_cb__c,Pricing_Additional_RPM_Notify_Recipients__c From SBQQ__QuoteLine__c WHERE Id= :quoteLineId];
        return quoteLine;
    }
    
    @AuraEnabled
    public static Boolean restrictedAccountMethod(Id recordId, String pricingRegion){
        Boolean accountRestriced = false;
        if(recordId != null)
        {
            List<Pricing_QuoteLine_WonLoss_Restriction__mdt> wonLossAccountList = Pricing_QuoteLine_WonLoss_Restriction__mdt.getAll().values();
            for(Pricing_QuoteLine_WonLoss_Restriction__mdt wonLossQuoteLines : wonLossAccountList)
            {
                if(wonLossQuoteLines.Pricing_Account_Id__c == recordId && wonLossQuoteLines.Pricing_IsActive_Ind__c == true){
                    accountRestriced = true;
                    break;
                }
            }            
        }
        return accountRestriced;
    }
    
    //Setup date format
    private static date dateFormat(){
        DateTime stringDateTime = date.today();
        DateTime dt = stringDateTime.dateGMT();
        DateTime tomorrow = dt.addDays(1);
        String formattedDateTime = tomorrow.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return date.valueOf(formattedDateTime);
    }
    
    public class GlobalVariables {
        @AuraEnabled public String messageResult {get;set;}
        @AuraEnabled public Id quoteLineId {get;set;}
        @AuraEnabled public Boolean isSuccess {get;set;}
    }    
    
    @AuraEnabled
    public static List<String> userHasRPMPermissionSet() {
        integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : Userinfo.getUserId() AND PermissionSet.Name =:
                         Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager];
        
        return count>0 ?  getPicklistValuesQLI() : null;
    }
    
    @AuraEnabled
    public static List<String> userHasFIPMPermissionSet() {
        integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : Userinfo.getUserId() AND PermissionSet.Name =:
                         Label.Pricing_Tender_PermissionSets_FinancialIncentivePricingManager];
        
        return count>0 ?  getPicklistValuesQLI() : null;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<String> getPicklistValuesQLI(){
        List<String> pickListValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = SBQQ__QuoteLine__c.Pricing_Backdate_Reason_Txt__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry f : ple){
            pickListValues.add(f.getValue());
            
        }
        if(!pickListValues.isEmpty()){
            return pickListValues;
        }else{
            return null; 
        }
    }
    
    public static String generateQuoteLineNumber(Id quoteLineId, string parentQuoteLineNbr,Id parentReferenceQL){
        String newQuoteLN;
        
        // Check if there are any Rejected Revisions exist for a Quote Line
        List<SBQQ__QuoteLine__c> revisions = [SELECT Id, Pricing_Quote_Line_Number__c FROM SBQQ__QuoteLine__c 
                                              where Pricing_Reference_Quote_Line_Nbr__c=: quoteLineId and Pricing_Status_Nm__c = 'Rejected' order by Pricing_Quote_Line_Number__c desc];
        
        // If revisions exist, next revision number should be increment of last rejected Quote Line number
        String quoteLineNbr;
        quoteLineNbr = (!revisions.isEmpty())?revisions[0].Pricing_Quote_Line_Number__c:parentQuoteLineNbr;
        
        if(parentReferenceQL == null & revisions.isEmpty()){            
            newQuoteLN = quoteLineNbr +'-'+ String.valueOf(1).leftPad(3, '0');
        }
        else{
            integer lineNbr;
            lineNbr = Integer.valueOf(quoteLineNbr.substringAfter('-').substringAfter('-').substringAfter('-'));
            newQuoteLN = quoteLineNbr.substring(0,quoteLineNbr.length()-4) +'-'+ String.valueOf(lineNbr + 1).leftPad(3, '0');          
        }
        return newQuoteLN;
    }
    
    @AuraEnabled
    public static Date fetchDate(){
        return System.today();
    } 
    
    public static void rpmCRAutoPopulation(SBQQ__QuoteLine__c parentQL ,SBQQ__QuoteLine__c parent, SBQQ__QuoteLine__c quoteLine){
        parent.Pricing_Change_Request_Type__c = populateChangeRequestType(parent,quoteLine,false);
        if((parent.SBQQ__ProductName__c == Label.Pricing_Tender_Write_In_Product && 
            String.isBlank(parent.Pricing_Deal_RFQ_Id__c) && 
            parent.Pricing_Product_Nm__c == quoteLine.Pricing_Product_Nm__c) || 
           parent.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
               parent.Pricing_Change_Request_cb__c = false;
               parent.Pricing_Last_Approved_Date_dt__c = DateTime.now();
               parent.RecordTypeId = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Read_Only) : quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'Pricing_Financial_Incentive_Quote_Line_Read_Only') : Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_ReadOnly);
               parent.Pricing_Approved_Start_Date_Dup_Dt__c = quoteLine.Pricing_Approved_Start_Date_Dt__c;
               parent.Pricing_Approved_End_Date_Dup_Dt__c = quoteLine.Pricing_Approved_End_Date_Dt__c;
               parent.Pricing_Approved_Unit_Dup_Qty__c = quoteLine.Pricing_Approved_Unit_Qty__c;
               parent.Pricing_ECAP_Price_Dup_Amt__c = quoteLine.Pricing_ECAP_Price_Amt__c;
               parent.Pricing_Revised_Pricing_Start_Date_D_dt__c = quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
               parent.Pricing_Quote_Line_Won_Lost_Status__c = (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won)?Label.Pricing_Tender_QuoteLine_Status_Won:null;
               SBQQ__QuoteLine__c oldQuoteline = new SBQQ__QuoteLine__c(Id = parentQL.Id,
                                                                        Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Revised);
               if(parentQL.Id != null){
                   update oldQuoteline;
               }
           }else{
               if(parent.Pricing_Product_Nm__c != quoteLine.Pricing_Product_Nm__c){ // set product from WIP to Non-WIP RPM CR 
                   isChangedProduct = true;
                   parent.Pricing_Product_Nm__c = quoteLine.Pricing_Product_Nm__c;
                   parent.SBQQ__Product__c = quoteLine.SBQQ__Product__c;
                   parent.Pricing_Other_Product_Nm__c = null;
               }
               parent.Pricing_Change_Request_cb__c = true;
               parent.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
               parent.RecordTypeId = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Submitted) : quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'Pricing_Financial_Incentive_Quote_Line_Read_Only') : Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
               parent.Pricing_Approved_Start_Date_Dup_Dt__c = null;
               parent.Pricing_Approved_End_Date_Dup_Dt__c = null;
               parent.Pricing_Approved_Unit_Dup_Qty__c = null;
               parent.Pricing_ECAP_Price_Dup_Amt__c = null;
               parent.Pricing_Revised_Pricing_Start_Date_D_dt__c = quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
               parent.Pricing_Last_Approved_Date_dt__c = null;
               parent.Pricing_Quote_Line_Won_Lost_Status__c = null;            
           } 
        
        parent.Pricing_Approved_Start_Date_Dt__c = quoteLine.Pricing_Approved_Start_Date_Dt__c;
        parent.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_Approved_End_Date_Dt__c;
        parent.Pricing_Approved_Unit_Qty__c = quoteLine.Pricing_Approved_Unit_Qty__c;
        parent.Pricing_Payable_Quantity__c = isChangedProduct ? null : quoteLine.Pricing_Payable_Quantity__c;
        parent.Pricing_Meet_Comp_Price_Amt__c = quoteLine.Pricing_Meet_Comp_Price_Amt__c;
        parent.Pricing_Revised_Pricing_Start_Date_dt__c = quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
        parent.Pricing_Billing_End_Date_Dt__c = quoteLine.Pricing_Billing_End_Date_Dt__c;
        parent.Pricing_Billing_Start_Date_Dt__c = quoteLine.Pricing_Billing_Start_Date_Dt__c;
        parent.Pricing_ECAP_Price_Amt__c = quoteLine.Pricing_ECAP_Price_Amt__c;
        parent.Pricing_Additional_Comments_Txt__c = quoteLine.Pricing_Additional_Comments_Txt__c;
        parent.Pricing_Additional_RPM_Notify_Recipients__c = quoteLine.Pricing_Additional_RPM_Notify_Recipients__c;
        parent.Pricing_Additional_T_C_s_Txt__c = quoteLine.Pricing_Additional_T_C_s_Txt__c;
        parent.Pricing_Backdate_Reason_Txt__c = quoteLine.Pricing_Backdate_Reason_Txt__c;
        parent.Pricing_Deal_Description__c = quoteLine.Pricing_Deal_Description__c;
        parent.Pricing_End_Date_dt__c = parent.Pricing_End_Date_dt__c > date.today() ? parent.Pricing_End_Date_dt__c : dateFormat();
        parent.Pricing_Consumption_Platform__c = quoteLine.Pricing_Consumption_Platform__c;
        parent.Pricing_Consumption_Sale_Geo__c = quoteLine.Pricing_Consumption_Sale_Geo__c;
        parent.Pricing_Consumption_Country__c = quoteLine.Pricing_Consumption_Country__c;
        parent.Pricing_Consumption_Region__c = quoteLine.Pricing_Consumption_Region__c; 
        parent.Pricing_Consumption_Segment__c = quoteLine.Pricing_Consumption_Segment__c;
        parent.Pricing_Is_Additional_T_C_Not_Blank_cb__c = quoteLine.Pricing_Additional_T_C_s_Txt__c != null ? true : false;
        if(parent.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote){
            parent.Pricing_Comp_SKU_Performance_Nbr__c = quoteLine.Pricing_Comp_SKU_Performance_Nbr__c;
            parent.Pricing_Intel_SKU_Performance_Nbr__c = quoteLine.Pricing_Intel_SKU_Performance_Nbr__c;
            parent.Pricing_Performance_Metric_Nm__c = quoteLine.Pricing_Performance_Metric_Nm__c;
            parent.Pricing_Write_In_Performance_Metric_Nm__c = quoteLine.Pricing_Write_In_Performance_Metric_Nm__c;
        }
    }
    
    @TestVisible
    private static void oEMCRAutoPopulation(SBQQ__QuoteLine__c parent , SBQQ__QuoteLine__c quoteLine){
        parent.Pricing_Change_Request_Type__c = populateChangeRequestType(parent,quoteLine,true);
        parent.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview;
        parent.RecordTypeId =quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ?  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Submitted) : Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
        // Values entered by Change Request
        parent.Pricing_Change_Request_cb__c = true;
        parent.Pricing_Additional_Comments_Txt__c = quoteLine.Pricing_Additional_Comments_Txt__c;
        parent.Pricing_New_Quantity_qty__c = quoteLine.Pricing_New_Quantity_qty__c;
        parent.Pricing_End_Date_dt__c = quoteLine.Pricing_End_Date_dt__c;
        parent.Pricing_Request_Discount_Unit_Price_qty__c = quoteLine.Pricing_Request_Discount_Unit_Price_qty__c;
        parent.Pricing_Start_Date_dt__c = quoteLine.Pricing_Start_Date_dt__c;
        parent.Pricing_Approved_Start_Date_Dt__c = null;
        parent.Pricing_Approved_Start_Date_Dup_Dt__c = null;
        parent.Pricing_Approved_Unit_Qty__c = null;
        parent.Pricing_Approved_Unit_Dup_Qty__c = null;
        parent.Pricing_Approved_End_Date_Dt__c = null;
        parent.Pricing_Approved_End_Date_Dup_Dt__c = null;
        parent.Pricing_Revised_Pricing_Start_Date_dt__c = quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won && quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c == null ? quoteLine.Pricing_Approved_Start_Date_Dt__c : quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
        parent.Pricing_Revised_Pricing_Start_Date_D_dt__c = quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won && quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c == null ? quoteLine.Pricing_Approved_Start_Date_Dt__c : quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
        parent.Pricing_ECAP_Price_Amt__c = null;
        parent.Pricing_ECAP_Price_Dup_Amt__c = null;
        parent.Pricing_Additional_T_C_s_Txt__c = null;
        parent.Pricing_Backdate_Reason_Txt__c = null;
        parent.Pricing_Won_Lost_Comments_Txt__c = null;
        parent.Pricing_pm_approval_comments_nm__c = null;
        parent.Pricing_Rejection_Comments_nm__c = null;
        parent.Pricing_Last_Approved_Date_dt__c = null;
        parent.Pricing_Is_Additional_T_C_Not_Blank_cb__c = false;
        parent.Pricing_Quote_Line_Won_Lost_Status__c = null;
        parent.Pricing_Consumption_Platform__c = quoteLine.Pricing_Consumption_Platform__c;
        parent.Pricing_Consumption_Sale_Geo__c = quoteLine.Pricing_Consumption_Sale_Geo__c;
        parent.Pricing_Consumption_Country__c = quoteLine.Pricing_Consumption_Country__c;
        parent.Pricing_Consumption_Region__c = quoteLine.Pricing_Consumption_Region__c; 
        parent.Pricing_Consumption_Segment__c = quoteLine.Pricing_Consumption_Segment__c;
        if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won && Pricing_QuoteLineCloneController.restrictedAccountMethod(quoteLine.SBQQ__Quote__r.SBQQ__Account__c,'') /*&&  parent.Pricing_New_Change_Request_cb__c == false*/){
            parent.Pricing_Payable_Quantity__c = 0;
        }
        
    }
    
    private static void cloneAutopopulation(SBQQ__QuoteLine__c parent , SBQQ__QuoteLine__c quoteLine){
        SBQQ__QuoteLine__c qli = [SELECT Id, Pricing_Competetor_Product__r.Pricing_Active_cb__c FROM SBQQ__QuoteLine__c 
                                  WHERE Id =: quoteLine.Id];
        Set<Id> userHasRPMPermissionSetIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>{UserInfo.getUserId()};
            userHasRPMPermissionSetIds = Pricing_EmailUtility.checkUserHasValidPermission(userIds,Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);      
        parent.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Draft;
        parent.RecordTypeId = (parent.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote)?Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Create):Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
        
        parent.SBQQ__Source__c=quoteline.Id;
        parent.Pricing_Reference_Quote_Line_Nbr__c = null;
        parent.Pricing_Quote_Line_Number__c = null;
        parent.Pricing_Manager__c = null;
        parent.Pricing_Meet_Comp_Price_Amt__c = null;
        parent.Pricing_MMBP_System_Nm__c = null;
        parent.Pricing_Additional_Comments_Txt__c = null;
        parent.Pricing_End_Date_dt__c = parent.Pricing_End_Date_dt__c > date.today() ? parent.Pricing_End_Date_dt__c : dateFormat();
        parent.Pricing_FSE_Recommended_Price_Nm__c = null;
        parent.Pricing_Change_Request_cb__c = false;
        
       parent.Pricing_Change_Request_Type__c = null;

        parent.Pricing_New_Quantity_qty__c = null;
        parent.Pricing_Request_Discount_Unit_Price_qty__c = null;
        parent.Pricing_Original_Submitted_By_Id__c = null;
        parent.Pricing_Original_Submitted_Date_dt__c = null;
        parent.Pricing_Last_Submitted_By_Id__c = null;
        parent.Pricing_Last_Submitted_Date_dt__c = null;
        parent.Pricing_Start_Date_dt__c = null;
        
        parent.Pricing_RegionQL_Nm__c = Label.Pricing_Tender_Default_Region_Worldwide;
        parent.Pricing_Deal_RFQ_Id__c = null;
        parent.Pricing_Backdate_Reason_Txt__c = null;
        parent.Pricing_Approved_Start_Date_Dt__c = null;
        parent.Pricing_Approved_Start_Date_Dup_Dt__c = null;
        parent.Pricing_Approved_Unit_Qty__c = null;
        parent.Pricing_Approved_Unit_Dup_Qty__c = null;
        parent.Pricing_Payable_Quantity__c = null;
        parent.Pricing_Approved_End_Date_Dt__c = null;
        parent.Pricing_Approved_End_Date_Dup_Dt__c = null;
        parent.Pricing_Revised_Pricing_Start_Date_dt__c = null;
        parent.Pricing_Revised_Pricing_Start_Date_D_dt__c = null;
        parent.Pricing_ECAP_Price_Amt__c = null;
        parent.Pricing_ECAP_Price_Dup_Amt__c = null;
        parent.Pricing_Additional_T_C_s_Txt__c = null;
        parent.Pricing_Won_Lost_Comments_Txt__c = null;
        parent.Pricing_pm_approval_comments_nm__c = null;
        parent.Pricing_Rejection_Comments_nm__c = null;
        parent.Pricing_Last_Approved_Date_dt__c = null;
        parent.Pricing_Deal_Description__c = null;
        parent.Pricing_Is_Additional_T_C_Not_Blank_cb__c = false;
        parent.Pricing_Billing_Start_Date_Dt__c = null;
        parent.Pricing_Billing_End_Date_Dt__c = null;
        parent.Pricing_Quote_Line_Won_Lost_Status__c = null;
        parent.Pricing_Debit_Volume_qty__c = null;
        parent.Pricing_Debit_Dollars_Amt__c = null;
        parent.Pricing_Last_Credit_Debit_Date_Dt__c = null;
        parent.Pricing_Credit_Volume_qty__c = null;
        parent.Pricing_Credit_Dollars_Amt__c = null;
        parent.Pricing_Additional_RPM_Notify_Recipients__c = null;
        parent.Pricing_SDM_Fast_Track__c = false;
        parent.Pricing_Consumption_Platform__c = null;
        parent.Pricing_Consumption_Sale_Geo__c = null;
        parent.Pricing_Consumption_Country__c = null;
        parent.Pricing_Consumption_Region__c = null;
        parent.Pricing_Consumption_Segment__c = null;
        if(!qli.Pricing_Competetor_Product__r.Pricing_Active_cb__c){
            parent.Pricing_Competetor_Product__c = null;
        }
        //blank out Performance Metrics fields for Client Quote Line on Clone
        if(parent.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote){
            parent.Pricing_Comp_SKU_Performance_Nbr__c = null;
            parent.Pricing_Intel_SKU_Performance_Nbr__c = null;
            parent.Pricing_Performance_Metric_Nm__c = null;
            parent.Pricing_Write_In_Performance_Metric_Nm__c = null;
        }
        else{
            parent.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_Market_Segment_Default;
            parent.Pricing_Market_Segment_values_Nm__c = Label.Pricing_Tender_Market_Segment_Values_Default;
        }
        
    }
    
    //Billing start date check for Quarter logic on RPM change Request
    @AuraEnabled
    public static Boolean billingStartDateCheck(SBQQ__QuoteLine__c quoteLine) {
        
        Boolean startDateValid = false;
        if(quoteLine.Pricing_Billing_Start_Date_Dt__c != null && quoteLine.Pricing_Approved_Start_Date_Dt__c != null){          
            Integer noOfDaysBetweenDates = quoteLine.Pricing_Billing_Start_Date_Dt__c.daysBetween(quoteLine.Pricing_Approved_Start_Date_Dt__c);
            if(noOfDaysBetweenDates > Integer.valueof(Label.Pricing_AllowedBillingDateBackDating_days)){
                startDateValid = true;
            }
        }
        
        /* Boolean startDateValid = false;
Map<Date,Date> dateMap = new Map<Date,Date>();
for(Period periodRec: [Select Id,startdate, EndDate, number From Period Where type = 'Quarter'
AND EndDate <=:quoteLine.Pricing_Approved_Start_Date_Dt__c order by startdate desc  LIMIT 1]){
if(periodRec.startdate != null){
dateMap.put(periodRec.startdate,periodRec.EndDate);
}
}
integer count = [SELECT count() FROM PermissionSetAssignment
WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = :Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager
];

if(quoteLine.Pricing_Billing_Start_Date_Dt__c != null && quoteLine.Pricing_Approved_Start_Date_Dt__c != null){          
Date previousDate = null;
billingStartDatePreviousDate(dateMap, quoteLine, previousDate);

if(quoteLine.Pricing_Billing_Start_Date_Dt__c < previousDate && count > 0){
startDateValid =  true;
}
}*/
        return startDateValid;
    }
    
    /*public static void billingStartDatePreviousDate(Map<Date,Date> dateMap,SBQQ__QuoteLine__c quoteLine,Date previousDate){
for(Date startDate : dateMap.keySet()){
if((startDate <= quoteLine.Pricing_Approved_Start_Date_Dt__c) && (quoteLine.Pricing_Approved_Start_Date_Dt__c <= dateMap.get(startDate)) && previousDate != null){
break;
}
previousDate = startDate;
}
}*/
    
    //Method to validate Quote Team FSE on OEM Change Request.
    @AuraEnabled
    public static Boolean validateQuoteTeamFSE(SBQQ__QuoteLine__c quoteLine){
        Map<Id,Set<Id>> quoteQTMMap = new Map<Id,Set<Id>>();
        Boolean isValidFSE = true;
        try{
            if(quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote){
                quoteQTMMap = Pricing_Publish_Quote.validateQtmFse(new Set<Id>{quoteLine.SBQQ__Quote__c});
                if(quoteQTMMap.size() == 0){
                    isValidFSE = false;
                }
            }
            return isValidFSE;
        }
        catch(Exception error) {
            Pricing_Tender_Utility.logError(error);
            return false;
        }   
    } 
    
    /**
* @description Search Project and return product list
* @param searchKey Seach Key 
* @param quoteLineType Quote Line Type
* @return  List<Product2>
*/
    @AuraEnabled
    public static List<Product2> searchProductsSOQL(String searchKey, String quoteLineType){
        return Pricing_QuoteLineController.searchProductsSOQL(searchKey,quoteLineType);
    }
    
    @AuraEnabled
    public static List<Pricing_ConsumptionAccountMapping__c> getConsumptionPicklistValues(String quoteId){ 
        return Pricing_ConsumptionAttr_Controller.getPlatformAndSalesGeoPickList(quoteId); 
    }
    
    /**
* @description Method return true if user is having 'Tender Business User Admin' Permission Set
* @author Bharath Chandrashekar | 09-29-2022 
* @param UserId 
**/
    @InvocableMethod(label = 'getLoggedinUserPermissionSetBusinessAdmin' description = 'return true if user is having Tender Business User Admin Permission Set')
    public static List<String> getLoggedinUserPermissionSetBusinessAdmin(){
        return QuoteLineBusinessLogic.checkCurrentUserPs(Label.Pricing_Tender_PermissionSets_TenderBusinessUserAdmin) ? new List<String>{'True'} : new List<String>{'False'};
            }
    /***********************************************************************************************************
Method Name:       populateChangeRequestField
Description:       Method to track the field values changed during change request in a picklist field
Added By:          Rishabh - 14-April-2026
Modified By:        Date:       Changes:
**********************************************************************************************************/
    
    public static String populateChangeRequestType(SBQQ__QuoteLine__c parent, SBQQ__QuoteLine__c quoteLine, Boolean oemCR) {
        
        Set<String> changeRequestTypes = new Set<String>();
        if(!oemCR){
            // Date Change
            if (
                (parent.Pricing_Approved_Start_Date_Dt__c != null &&
                 quoteLine.Pricing_Approved_Start_Date_Dt__c != null &&
                 parent.Pricing_Approved_Start_Date_Dt__c != quoteLine.Pricing_Approved_Start_Date_Dt__c)
                
                ||
                
                (parent.Pricing_Approved_End_Date_Dt__c != null &&
                 quoteLine.Pricing_Approved_End_Date_Dt__c != null &&
                 parent.Pricing_Approved_End_Date_Dt__c != quoteLine.Pricing_Approved_End_Date_Dt__c)
                
                ||
                
                (parent.Pricing_Billing_Start_Date_Dt__c != null &&
                 quoteLine.Pricing_Billing_Start_Date_Dt__c != null &&
                 parent.Pricing_Billing_Start_Date_Dt__c != quoteLine.Pricing_Billing_Start_Date_Dt__c)
                
                ||
                
                (parent.Pricing_Billing_End_Date_Dt__c != null &&
                 quoteLine.Pricing_Billing_End_Date_Dt__c != null &&
                 parent.Pricing_Billing_End_Date_Dt__c != quoteLine.Pricing_Billing_End_Date_Dt__c)
            ) {
                changeRequestTypes.add('Date Change');
            }
            
            // Price Change
            if (parent.Pricing_ECAP_Price_Amt__c != null &&
                quoteLine.Pricing_ECAP_Price_Amt__c != null &&
                parent.Pricing_ECAP_Price_Amt__c != quoteLine.Pricing_ECAP_Price_Amt__c) {
                    changeRequestTypes.add('Price Change');
                }
            
            // Volume Change
            if (parent.Pricing_Approved_Unit_Qty__c != null &&
                quoteLine.Pricing_Approved_Unit_Qty__c != null &&
                parent.Pricing_Approved_Unit_Qty__c != quoteLine.Pricing_Approved_Unit_Qty__c) {
                    changeRequestTypes.add('Volume Change');
                }
            
            // Payable Quantity Change
            if (parent.Pricing_Payable_Quantity__c != null &&
                quoteLine.Pricing_Payable_Quantity__c != null &&
                parent.Pricing_Payable_Quantity__c != quoteLine.Pricing_Payable_Quantity__c) {
                    changeRequestTypes.add('Payable Quantity Change');
                }
        }else{
            // Date Change
            if (
                (parent.Pricing_Approved_Start_Date_Dt__c != null &&
                 quoteLine.Pricing_Start_Date_dt__c != null &&
                 parent.Pricing_Approved_Start_Date_Dt__c != quoteLine.Pricing_Start_Date_dt__c)
                
                ||
                
                (parent.Pricing_Approved_End_Date_Dt__c != null &&
                 quoteLine.Pricing_End_Date_dt__c != null &&
                 parent.Pricing_Approved_End_Date_Dt__c != quoteLine.Pricing_End_Date_dt__c)
            ) {
                changeRequestTypes.add('Date Change');
            }
            
            // Quantity
            if (parent.Pricing_Approved_Unit_Qty__c != null && quoteLine.Pricing_New_Quantity_qty__c != null &&
                parent.Pricing_Approved_Unit_Qty__c != quoteLine.Pricing_New_Quantity_qty__c) {
                    changeRequestTypes.add('Volume Change');
                }
            
            // Price
            if (parent.Pricing_ECAP_Price_Amt__c != null && quoteLine.Pricing_Request_Discount_Unit_Price_qty__c != null &&
                parent.Pricing_ECAP_Price_Amt__c != quoteLine.Pricing_Request_Discount_Unit_Price_qty__c) {
                    changeRequestTypes.add('Price Change');
                }
        }
        
        if (hasConsumptionFieldChanged(parent.Pricing_Consumption_Platform__c, quoteLine.Pricing_Consumption_Platform__c) || hasConsumptionFieldChanged(parent.Pricing_Consumption_Region__c, quoteLine.Pricing_Consumption_Region__c) ||
            hasConsumptionFieldChanged(parent.Pricing_Consumption_Country__c, quoteLine.Pricing_Consumption_Country__c) || hasConsumptionFieldChanged(parent.Pricing_Consumption_Sale_Geo__c, quoteLine.Pricing_Consumption_Sale_Geo__c) ||
            hasConsumptionFieldChanged(parent.Pricing_Consumption_Segment__c, quoteLine.Pricing_Consumption_Segment__c)) {
                changeRequestTypes.add('Consumption Reason Change');
            }
        
        return String.join(new List<String>(changeRequestTypes), ';');
    }
    
    private static Boolean hasConsumptionFieldChanged(String a, String b) {
        String valA = String.isBlank(a) ? '' : a.trim();
        String valB = String.isBlank(b) ? '' : b.trim();
        if (!String.isBlank(a) && !String.isBlank(b)) {
            return valA != valB;
        }
        
        return false;
        
    }
    
    
}