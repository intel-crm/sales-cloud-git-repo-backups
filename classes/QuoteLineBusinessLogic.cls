/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 09-16-2026
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class QuoteLineBusinessLogic { 
    public static boolean changeTwinField = false;
    public static boolean isStopTriggerFromFlow = false;
    public static Map<Id, Boolean> isAutoPopulateMeetComp = new Map<Id, Boolean>();
    public static boolean hasRunOnce = false;
    public static Boolean isOEMRecall = false;
    public static User currentUser =  [SELECT Id,ContactId,contact.accountId,contact.Account.Name,contact.Email,Core_User_Profile_Name__c, (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
                                        FROM User WHERE Id =: UserInfo.getUserId() and IsActive = true];
    public static Id svdSubmitRecordType = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Submitted);
    public static Id standardSubmitRecordType = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
    public static Id svdEditRecordType = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Edit);
    public static Id finInctvEditRecordType = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Financial_Incentive_Quote_Line_Edit);
    public static Id standardEditRecordType = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Edit);
    private static Map < Id, SBQQ__Quote__c > existingQuote = new Map < Id, SBQQ__Quote__c > ();
    public static Set<Id> competitorProductsIds = new Set<Id>();
    public static Set<String> applicationSetforAutoPop = new Set<String>();
    public static List<Pricing_Competitor_Product_Price__c> competitorProductPriceList = new List<Pricing_Competitor_Product_Price__c>();
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static Boolean isAutoApproveReject = false; //Boolean Variable for Auto Approval Process Check
    public static Boolean isFinancialIncentive=false;
    public static  Boolean isBillingStartDateUpdate = false;
    public static String accountId;
    public static Boolean hasAIIntegrationRun = false;//Citrus change

    public static void validateChangeRequestEdit(List < SBQQ__QuoteLine__c > lstquoteLines, boolean isInsert, Map < id, SBQQ__QuoteLine__c > oldMap) {
        if(lstquoteLines!=null && !lstquoteLines.isEmpty()){
            Set < String > changeRequestFieldsEditableByOEMField = new Set < String > ((Label.Pricing_Tender_Change_Request_OEM_Field_Edit_Fields).split(':'));
            Set < String > changeRequestFieldsEditableByRPM = new Set < String > ((Label.Pricing_Tender_Change_Request_RPM_Edit_Fields + Label.Pricing_Tender_Change_Request_RPM_Edit_Fields1).split(':'));
            Set < String > changeRequestFieldsNonEditable = new Set < String > ();
            Boolean isOEMField = checkCurrentUserPs(Label.Pricing_Tender_PermissionSets_TenderUser);
            Boolean isRPM = checkCurrentUserPs(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);

            if(isOEMField || isRPM) {
                changeRequestFieldsNonEditable.addAll(getFieldsFromLayout());
                //New fields added for SSD/PMem that should be non editable on Change requests by FSE/RPM to be added in Pricing_CR_Additional_Non_Editable_Fields.
                Set < String > cRFldsAdditionalNonEditable = new Set < String > ((Label.Pricing_CR_Additional_Non_Editable_Fields).split(':'));
                changeRequestFieldsNonEditable.addAll(cRFldsAdditionalNonEditable);
                if(isOEMField) {
                    changeRequestFieldsNonEditable.removeAll(changeRequestFieldsEditableByOEMField);
                } else if(isRPM) {
                    changeRequestFieldsNonEditable.removeAll(changeRequestFieldsEditableByRPM);
                }
            }
            for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                if(quoteLine.Pricing_Change_Request_cb__c) {
                    //Pricing_QuoteLine_AutoApprovalController.isChangeRequestQl this change is related to autoApprove it should not go to production
                    if(isOEMField && !Pricing_QuoteLine_AutoApprovalController.isChangeRequestQl) {
                        if(!Pricing_QuoteLine_AutoApprovalController.isChangeRequestPriceRule){
                        for(String field: changeRequestFieldsNonEditable) {
                            if(quoteLine.get(field) != oldMap.get(quoteLine.Id).get(field)) {
                                quoteLine.addError(Label.Pricing_Tender_Change_Request_OEMField_Validation_Error_Message);
                                break;
                            }
                        }
                    }
                    } else if(isRPM) {
                        for(String field: changeRequestFieldsNonEditable) {
                            if(quoteLine.get(field) != oldMap.get(quoteLine.Id).get(field)) {
                                quoteLine.addError(Label.Pricing_Tender_Change_Request_RPM_Validation_Error_Message);
                                break;
                            }
                        }
                    }
                }
            }
        }  
    }
    
    public static void updateQuoteLineDetails(List < SBQQ__QuoteLine__c > lstquoteLines, boolean isInsert, Map < id, SBQQ__QuoteLine__c > oldMap) {
       try{
        if(lstquoteLines!=null && !lstquoteLines.isEmpty()){
            Map < ID, Schema.RecordTypeInfo > rtMap = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosById();
            Set < Id > quoteIds = new Set < Id > ();
            Boolean isAutoAI = false;
            Boolean isCCG = false;
            Id writeInProdId;
            Set < Id > quoteLineIds = new Set < Id > ();
            Set < Id > wonQuoteIds = new Set < Id > ();
            List<String> RPM_Emails = new List<String>();
            List<String> regionList = new List<String>();
            List<String> programType = Label.Pricing_TenderProgramTypeForMeetCompAutoPopulate.split(',');
            Boolean  hasPermissionSetAPI = currentUserHasAPIPs();
            
            for(SBQQ__QuoteLine__c ql: lstquoteLines) {
                if(!String.isEmpty(ql.Pricing_Additional_RPM_Notify_Recipients__c)){
                    ql.Pricing_Additional_RPM_Notify_Recipients__c = (ql.Pricing_Additional_RPM_Notify_Recipients__c).deleteWhitespace();
                    RPM_Emails.addAll(((ql.Pricing_Additional_RPM_Notify_Recipients__c).deleteWhitespace()).split(';'));
                }
                quoteIds.add(ql.SBQQ__Quote__c);
                quoteLineIds.add(ql.Id);
            }
            
            Map<String,Decimal> quoteLineNumberToStatusMap = new Map<String,Decimal>(); 
            getQuoteLineStatusMap(quoteLineNumberToStatusMap);
            Boolean isRPMUser = checkCurrentUserPs(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
            Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id,Pricing_Program_Type_Nm__c,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,SBQQ__Quote__r.Pricing_End_Customer_Opportunity_Txt__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,(SELECT Id,Name,Pricing_Quote_Line__c FROM Performance_Metrics__r),SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Status__c,Pricing_Competetor_Product__c,SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Competetor_Product__r.Pricing_Active_cb__c
                                                                                        FROM SBQQ__QuoteLine__c where Id IN :quoteLineIds]);

            
            //querying product2 object to get write in product id.
            if(!hasPermissionSetAPI){
                writeInProdId = [SELECT Id FROM Product2 WHERE name =: Label.Pricing_Tender_Write_In_Product AND isActive = true].Id;
            }
            if(isInsert) {
                Map < Id, SBQQ__Quote__c > quoteDtls = new Map < id, SBQQ__Quote__c > ([Select Id, Pricing_ShipmentEndDate_Dt__c, SBQQ__SalesRep__c, Pricing_Project_Name_Nm__c,SBQQ__Status__c,
                                                                                        Pricing_End_Customer_Country_Nm__c, Pricing_Customer_Nm__c, Pricing_Server_Deal_Type_Nm__c,
                                                                                        Pricing_Region_Nm__c, SBQQ__Account__r.Name, SBQQ__PrimaryContact__c, Pricing_ShipmentStDate_Dt__c,
                                                                                        Pricing_Program_Type_Nm__c,Pricing_End_Customer_Name__c,Pricing_Market_Segment_values_Nm__c from SBQQ__Quote__c
                                                                                        where Id IN: quoteIds
                                                                                       ]);
                
                //querying competitor product price object to auto populate meet comp price on quoteLine.
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {


                    //if(rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_Tender_QuoteLine_RecordType_Create || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_SVD_Quote_Line_Create) {
                    if(rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_Tender_QuoteLine_RecordType_Create || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_SVD_Quote_Line_Create || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_SSD_Quote_Line_Create || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_PMem_Quote_Line_Create  || 
                        rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_NIC_Quote_Line_Create  || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_CCG_Quote_Line_Create || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == Label.Pricing_GPU_DataCenter_QuoteLine_Create || rtMap.get(quoteLine.RecordTypeId).getDeveloperName() == 'Pricing_Financial_Incentive_Quote_Line_Edit') {
                        if(quoteLine.Pricing_Market_Segment_Nm__c == Label.Pricing_Tender_QuoteLine_Market_Segment_Embedded 
                           && String.isNotBlank(quoteLine.Pricing_Market_Segment_values_Nm__c) 
                           && quoteLine.Pricing_Market_Segment_values_Nm__c.containsIgnoreCase(';')){
                               quoteLine.addError(System.Label.Pricing_Market_Segment_Exceed_Exception);
                               Continue;
                           }
                           
                           if(quoteLine.Pricing_Product_Nm__c != null) {
                            quoteLine.SBQQ__Product__c = quoteLine.Pricing_Product_Nm__c;
                            quoteLine.Pricing_Product_Series_Name__c = quoteLine.Pricing_Product_Series__c;
                        }
                        if(isRPMUser && quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote){
                            populateApprovedFields(quoteLine,quoteDtls,programType,writeInProdId);                            
                            getCompetitorProductIdsRegions(quoteLine,programType,regionList,quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Server_Deal_Type_Nm__c,quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Region_Nm__c, quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_End_Customer_Name__c);
                            
                        }else{
                            quoteLine.Pricing_Status_Nm__c = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote ? Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview: Label.Pricing_Tender_QuoteLine_Status_Draft;
                            quoteLine.RecordTypeId = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? svdEditRecordType : quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote ? finInctvEditRecordType : standardEditRecordType;
                        }
                        if(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote){
                            if(!quoteDtls.isEmpty() && !String.isBlank(quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Market_Segment_values_Nm__c) 
                            && Label.Pricing_Market_Segment_Non_Embedded.split(',').contains(quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Market_Segment_values_Nm__c)) {                                                             
                                quoteLine.Pricing_Market_Segment_Nm__c='Non Embedded';
                            }
                            else{
                                quoteLine.Pricing_Market_Segment_Nm__c='Embedded';
                            }
                        }
                        
                        if((quoteLine.Pricing_Program_Type_Nm__c != quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Program_Type_Nm__c && (quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Program_Type_Nm__c != Label.Pricing_Tender_Standard_Quote ) && (quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Program_Type_Nm__c != Label.Pricing_Tender_CCG_Quote ))
                            || ((quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote )
                            && (quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote)) 
                            || (quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote && quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_CCG_Quote)) {
                            String ErrorMsg = Label.Pricing_Quote_Line_Type_Error_Message.replace('{QliType}',quoteLine.Pricing_Program_Type_Nm__c );
                            ErrorMsg = ErrorMsg.replace('{QType}',quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Program_Type_Nm__c );
                           quoteLine.addError(ErrorMsg);
                        }
                        quoteLine.Pricing_Group_Type_nm__c = Label.Pricing_Tender_Default_Group_Type;
                        if(quoteLine.Pricing_Market_Segment_Nm__c == Label.Pricing_Tender_QuoteLine_Market_Segment_Non_Embedded 
                            && String.isBlank(quoteLine.Pricing_Market_Segment_values_Nm__c) 
                            && quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_CCG_Quote){
                            quoteLine.Pricing_Market_Segment_values_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Values_Corp;
                        }
                        
                        populateTwinFields(quoteLine,quoteDtls);
                    }

                    //Revert Status fix
                    if(quoteLineNumberToStatusMap.containsKey(quoteLine.Pricing_Status_Nm__c)){
                        quoteLine.Pricing_Quote_Line_Status_Number__c = quoteLineNumberToStatusMap.get(quoteLine.Pricing_Status_Nm__c);
                    }

                    //Populate Pricing Manager for Write In Product Quoteline on RPM CR for Write In Product
                    if(String.isBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && 
                       (quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && 
                        (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved))){
                            quoteLine.Pricing_Manager__c = currentUser.Id;
                    }

                    //Validate QuoteLine Text fields and throw error if Non Latin Characters are present
                    validateQLTextFieldsForLatinChars(quoteLine,oldMap,true);   
                    
                    //Validation for Write in paired CPU
                    if(!hasPermissionSetAPI && quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU){
                        validateWriteInPairedCPU(quoteLine, writeInProdId);
                    }
                    //PAA V2 - Rationale for Pricing default value is set if the quoteline is not eligible for Pricing 
                    if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && Pricing_QuoteLineController.eligibleForPricingSupportCheck(quoteLine)){
                        quoteLine.Pricing_Rationale_for_Pricing__c = Label.Pricing_Not_Eligible_For_Pricing;
                    }
                }
            } else {
                Map<String,Decimal> accountIdMtdRecordMap = new Map<String,Decimal>();
                List<String> Emails = new List<String>();
                boolean isCalculationPending = false;
                Boolean statusRevertFixSwitch = TriggerHandler.isActive('Pricing_Status_Revert_Fix');
                Boolean oemStatusRevertFixSwitch = TriggerHandler.isActive('Pricing_OEM_Draft_Status_Revert_Fix');
                Boolean isOEMRecallStatusRevertSwitch = TriggerHandler.isActive('Pricing_OEM_Revert_Switch');
                Boolean checkPMSwitch = TriggerHandler.isActive('Pricing_Check_Performance_Metrics');
                Boolean ucdSwitch = TriggerHandler.isActive('Pricing_UCD_Switch');
                Boolean isOEM = (getUserRole() == 'OEM');
                Map<Id,Id> quoteNotifyMap= new Map <Id,Id>();
                Set<Id> qlIds = new Set<Id>();
                if(!RPM_Emails.isEmpty() && isRPMUser){
                    Emails = usersHasValidRPMPermission(RPM_Emails,new Set < String > {
                        Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager});
                }
                if(TriggerHandler.isActive('Pricing_Prevent_Save_After_Calculation')) {
                    for(SBQQ__QuoteLine__c quoteLine: lstquoteLines){
                        if(!quoteLine.Pricing_Save_After_Calculation_cb__c && System.isQueueable()){
                            isCalculationPending = true;
                            quoteLine.Pricing_Save_After_Calculation_cb__c = true;
                        }  
                    }
                    
                    for(SBQQ__QuoteLine__c quoteLine: lstquoteLines){
                        if(System.isQueueable() && !isCalculationPending && !isFinancialIncentive){
                            quoteLine.addError('From Calculator Service handled error, Environment: '+ Label.Pricing_IQR_SFDC_Environment);
                            break;
                        }    
                    }                    
                }
                Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
                List<Pricing_Comments__c> commentsFilled = new List<Pricing_Comments__c>([SELECT Id,Pricing_Quote__c,Pricing_Answer__c 
                                                                                          FROM Pricing_Comments__c WHERE Pricing_Quote__c IN: quoteIds
                                                                                          and Pricing_Required_Ind__c = true and recordtypeid =: commentRecordTypeId]); 
                
                Set<Id> pfirQLSet = new Set<Id>();
                Set<Id> quoteLinePrimaryStatusSet = new Set<Id>();
                Set<Id> quoteLineSecondaryStatusSet = new Set<Id>();
                Set<Id> restrictWonNotUnifiedSet = new Set<Id>();
                Set<Id> qliQuarterSet = new Set<Id>();
                Set<Id> autoRejectSanctionedQLSet = new Set<Id>();  //Set of Quote Lines which are auto rejected that are sanctioned on submission
                Set<Id> autoRejectedECCommentsQLSet = new Set<Id>();  //Set of Quote Lines where RPL status is EC
                Map<Id,Set<Id>> qliToMultipleFSEUserIdMap = new Map<Id,Set<Id>>();
                Set<String> restrictedAccounts = new Set<String>();
                
                
                Map<String,Pricing_QuoteLine_WonLoss_Restriction__mdt> met = Pricing_QuoteLine_WonLoss_Restriction__mdt.getAll();
                for(Pricing_QuoteLine_WonLoss_Restriction__mdt m: met.values()){
                    restrictedAccounts.add(m.Pricing_Account_Id__c);
                }
                
                //creating map of quoteline to pending approval user
                getPendingApprovalFSEMap(quoteLineIds,qliToMultipleFSEUserIdMap);
                //creating list of non editable fields for user not present in above map
                Set < String > fieldsNonEditable = new Set < String > ();
                fieldsNonEditable.addALL(getFieldsFromLayout());
                fieldsNonEditable.removeAll(Label.Pricing_Tender_Field_Edit_With_PIFR.split(':'));
                fieldsNonEditable.addAll(Label.Pricing_PIFR_Additional_Non_Editable_Fields.split(':'));
                
                //Date highestApprovedStartDate;
                String rpmEmailsWithNoPermission='';
                String rpmEmailsWithoutRPMPS = '';
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines){
                    //Logic to send notification when the first Quoteline is approved and Quote staus goes to Approved from Submitted
                    if(quotelinemap.containskey(quoteline.id)){
                        if(!quoteNotifyMap.containsKey(quoteLine.SBQQ__Quote__c) && quotelinemap.get(quoteline.id).SBQQ__Quote__r.SBQQ__Status__c == Label.Pricing_Tender_Quote_Status_Submitted && oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_Quote_Status_Approved && quotelinemap.get(quoteline.id).SBQQ__Quote__r.SBQQ__Opportunity2__c == null && !String.isBlank(quotelinemap.get(quoteline.id).SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c) && quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote){
                            quoteNotifyMap.put(quoteLine.SBQQ__Quote__c, quoteLine.Id);
                        }
                    }
                    //PAA V2 - Rationale for Pricing default value is set if the quoteline is not eligible for Pricing 
                    if(oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c &&  quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && Pricing_QuoteLineController.eligibleForPricingSupportCheck(quoteLine)){
                        quoteLine.Pricing_Rationale_for_Pricing__c = Label.Pricing_Not_Eligible_For_Pricing;
                    
                    }
                    
                    if(!System.isBatch() && !System.isFuture() && TriggerHandler.isActive('Pricing_Won_Prediction_Switch') && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == 'Pending Further Intel Review' && quoteLine.Pricing_Status_Nm__c == 'Approved'){
                        qlIds.add(quoteLine.Id);
                        
                    }

                    //Validation to prevent RPM to edit Draft Quote Lines
                    if((!Test.isRunningTest()) && isRPMUser && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && !changeTwinField){
                        quoteLine.addError(Label.Pricing_Prevent_Save_DraftQLStatus_RPM_Err_Msg);
                    }
                    if(oldMap.get(quoteLine.Id).Pricing_Additional_RPM_Notify_Recipients__c != quoteLine.Pricing_Additional_RPM_Notify_Recipients__c && quoteLine.Pricing_Additional_RPM_Notify_Recipients__c != null && quoteLine.Pricing_Additional_RPM_Notify_Recipients__c != '' && isRPMUser){
                        rpmEmailsWithoutRPMPS = '';
                        rpmEmailsWithoutRPMPS = validateAdditionalRecipients(quoteLine, rpmEmailsWithNoPermission, Emails, isRPMUser);
                        //Validation to check if Additional RPM Recipients have RPM Permission Set and if they are a valid user
                        if(rpmEmailsWithoutRPMPS != ''){
                            quoteLine.addError(Label.Pricing_Addition_RPM_Recipients_Validation_Error_Msg.replace('<<placeholder for RPM emails>>',rpmEmailsWithoutRPMPS.removeEnd(';')));
                        }
                        String emailRegex = Label.Pricing_IQR_Regex_intel;
                        Pattern p = Pattern.compile(emailRegex);
                        Matcher m = p.matcher(quoteLine.Pricing_Additional_RPM_Notify_Recipients__c);
                        if(!m.matches()){
                            quoteLine.addError(label.Pricing_IQR_Intel_Email_Error);
                        }
                    }
                    if(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote){
                        if(!quoteLineMap.isEmpty() && !String.isBlank(quoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c)
                        && Label.Pricing_Market_Segment_Non_Embedded.split(',').contains(quoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c)) {
                            quoteLine.Pricing_Market_Segment_Nm__c='Non Embedded';
                        }
                        else{
                            quoteLine.Pricing_Market_Segment_Nm__c='Embedded';
                        }
                    }
                   
                    //Validation for Write in paired CPU
                    if(!hasPermissionSetAPI && quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU && (oldMap.get(quoteLine.Id).Pricing_Paired_CPU_Nm__c != quoteLine.Pricing_Paired_CPU_Nm__c || oldMap.get(quoteLine.Id).Pricing_Write_In_Paired_CPU_Nm__c != quoteLine.Pricing_Write_In_Paired_CPU_Nm__c)){
                        validateWriteInPairedCPU(quoteLine, writeInProdId);
                    }
                    if(statusRevertFixSwitch) {
                        statusRevertFix(quoteLine,oldMap);
                    }
                    
                    // Fix for status revert from Submitted to Draft when 
                    if(oemStatusRevertFixSwitch){
                        //Boolean isOEM = (getUserRole() == 'OEM');
                        if(isOEM && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && !isOEMRecall) {
                            quoteLine.Pricing_Status_Nm__c =  Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview;
                        }
                        if(isOEMRecallStatusRevertSwitch && isOEM && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && System.isQueueable()) {
                            quoteLine.Pricing_Status_Nm__c =  Label.Pricing_Tender_QuoteLine_Status_Draft;
                        }
                    }
                
                //Restricting non QTM FSE to edit quoteline during Field review
                    if(qliToMultipleFSEUserIdMap.get(quoteLine.id) != null && !qliToMultipleFSEUserIdMap.get(quoteLine.id).contains(currentUser.Id) && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview &&
                        oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview) {
                            for(String field: fieldsNonEditable) {
                            if(quoteLine.get(field) != oldMap.get(quoteLine.Id).get(field)) {
                                quoteLine.addError(Label.Pricing_Tender_No_Access_FSE_Error_Message);
                                break;
                            }
                        }
                    }

                
                if(quoteLine.Pricing_Market_Segment_Nm__c == Label.Pricing_Tender_QuoteLine_Market_Segment_Embedded 
                    && (oldMap.get(quoteLine.id).Pricing_Market_Segment_values_Nm__c != quoteLine.Pricing_Market_Segment_values_Nm__c) 
                    && String.isNotBlank(quoteLine.Pricing_Market_Segment_values_Nm__c) 
                    && quoteLine.Pricing_Market_Segment_values_Nm__c.containsIgnoreCase(';')){
                        quoteLine.addError(System.Label.Pricing_Market_Segment_Exceed_Exception);
                        Continue;
                }

                    if(oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c){
                        if((quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) ||
                           (quoteLine.Pricing_Change_Request_cb__c && quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && 
                            (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected || 
                             quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won))){
                                pfirQLSet.add(quoteLine.Id);
                        }
                    }

                    if(quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c) {
                        //Populate Pricing Manager for Write In Product Quoteline on Approval/Rejection
                        if(String.isBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && 
                           oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview &&
                           ((quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || 
                             quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected) || (quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && 
                                                                                                                   quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won))) {
                                                                                                                       quoteLine.Pricing_Manager__c = !isAutoApproveReject ? currentUser.Id : quoteLine.Pricing_Manager__c;
                        }                   
                        //Populate Pricing Manager for Intel Product Quoteline if Rejected before deal creation                                                                                        }
                        if(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product &&
                           oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview &&
                           quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected && (quoteLine.Pricing_Integration_Status_Nm__c == '' || quoteLine.Pricing_Integration_Status_Nm__c == null)) {
                               quoteLine.Pricing_Manager__c = !isAutoApproveReject ? currentUser.Id : quoteLine.Pricing_Manager__c;
                        }
                    }
                    
                    if (!mapFunctionalityNameTriggerExecution.isEmpty() &&
                        mapFunctionalityNameTriggerExecution.containsKey('pricingSendOutboundMessagesIQR') &&
                        mapFunctionalityNameTriggerExecution.get('pricingSendOutboundMessagesIQR').Core_Active__c){
                            if((quoteLine.Pricing_Quote_Program_Nm__c == 'Tender' && oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && 
                               (quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product) &&
                               ((oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved && 
                                 quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won) ||
                                (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved && 
                                 quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost) ||
                                (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost && 
                                 quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) ||
                                (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Cancelled) || 
                                (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && 
                                 quoteLine.Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Complete 
                                 && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected))) {
                                     quoteLine.Pricing_Integration_Status_Nm__c = Label.Pricing_Tender_MyDeal_Integration_Status_Pending;
                                 }
                        }
                    
                    if((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && 
                       (((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) && 
                         (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won || 
                          quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost)) ||
                        (oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && 
                         quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won && 
                         quoteLine.Pricing_Reference_Quote_Line_Nbr__c !=null))){
                             quoteLineSecondaryStatusSet.add(quoteLine.Id);
                         }
                    
                    if((oldMap.get(quoteLine.Id).Pricing_Quote_Line_Won_Lost_Status__c != quoteLine.Pricing_Quote_Line_Won_Lost_Status__c) && 
                       (oldMap.get(quoteLine.Id).Pricing_Quote_Line_Won_Lost_Status__c == null) && 
                       (quoteLine.Pricing_Quote_Line_Won_Lost_Status__c == Label.Pricing_Tender_QuoteLine_Status_Won || 
                        quoteLine.Pricing_Quote_Line_Won_Lost_Status__c == Label.Pricing_Tender_QuoteLine_Status_Lost)){
                            quoteLinePrimaryStatusSet.add(quoteLine.Id);
                        }
                    
                    if ((oldMap.get(quoteLine.Id).Pricing_Quote_Line_Won_Lost_Status__c != quoteLine.Pricing_Quote_Line_Won_Lost_Status__c) && 
                        (oldMap.get(quoteLine.Id).Pricing_Quote_Line_Won_Lost_Status__c == null) && 
                        (quoteLine.Pricing_Quote_Line_Won_Lost_Status__c == Label.Pricing_Tender_QuoteLine_Status_Won)) {
                            restrictWonNotUnifiedSet.add(quoteLine.Id);
                        }
                    
                    if(quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Approved && 
                       (oldMap.get(quoteLine.Id).Pricing_Quote_Line_Won_Lost_Status__c != quoteLine.Pricing_Quote_Line_Won_Lost_Status__c)){
                           quoteLine.addError(Label.Pricing_Restrict_Bulk_Won_Lost_Error);
                       }
                    
                    //Validation for restricting RA to do WON/LOST for restricted accounts.
                    
                    if((quoteLine.Pricing_Quote_Line_Won_Lost_Status__c == Label.Pricing_Tender_QuoteLine_Status_Won || quoteLine.Pricing_Quote_Line_Won_Lost_Status__c == Label.Pricing_Tender_QuoteLine_Status_Lost) && 
                       oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved && (restrictedAccounts.contains(quoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.SBQQ__Account__c)) && !isRPMUser){
                           quoteLine.addError(Label.Pricing_WonLost_AccountRestrict_RA_Error_Message);
                       }
                    
                    
                    //Populate Approved/Rejected Date on Approval/Rejection and Change request Won QL
                    if((oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && (((oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview &&
                                                                                                               (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won)) ||
                                                                                                              quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected)) || (quoteLine.Pricing_Is_Sanctioned__c == true && 
                                                                                                                                                                                                     (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview || 
                                                                                                                                                                                                                                                                                                       quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview)))){
                                                                                                                                                                                                                                                                                                           qliQuarterSet.add(quoteLine.id);
                                                                                                                                                                                                                                                                                                       }
                    //Auto Rejection of quotelines on submission i.e. Draft => PIFR and Draft => PFIR and Is sanctioned = true
                    if(quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c && quoteLine.Pricing_Is_Sanctioned__c == true && 
                       (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview || 
                                                                                                                         quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview))) {
                                                                                                                             autoRejectSanctionedQLSet.add(quoteLine.Id);
                                                                                                                         }

                    //Auto population of Meet Comp price on submission of Quoteline  i.e Draft => PIFR , Draft => PFIR ,PIFR =>PFIR
                    accountId = 'Id_' +quoteLineMap.get(quoteLine.id).SBQQ__Quote__r.SBQQ__Account__c;
                    accountIdMtdRecordMap = Pricing_QuoteLine_BulkDealController.accountToCIMIdMappingMtdRec();
                    if(quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c && ((oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) 
                                                                                                           || (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview)) && (String.isBlank(quoteLine.Pricing_Other_Competitor_Product_Nm__c) && quoteLineMap.get(quoteLine.Id).Pricing_Competetor_Product__c != null) && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null) {
                                                                                                               getCompetitorProductIdsRegions(quoteLine,programType,regionList,quoteLine.Pricing_Server_Deal_Type_Nm__c,quoteLine.Pricing_Region_Nm__c,quoteLine.Pricing_EndCustomer_Nm__c);
                                                                                                              
                                                                                                           }

                    //Billing start date population from Custom metadata
                    if(quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c && ((oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) 
                    || (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview)) && quoteLine.Pricing_Reference_Quote_Line_Nbr__c == null && !accountIdMtdRecordMap.isEmpty() && accountIdMtdRecordMap.containskey(accountId) && accountIdMtdRecordMap.get(accountId) != null) {
                        isBillingStartDateUpdate = true;
                    }


                    if(String.isBlank(quoteLine.Pricing_Folio_ID_Nm__c) && isRPMUser && (oldMap.get(quoteLine.Id).Pricing_Product_Nm__c != quoteLine.Pricing_Product_Nm__c) && String.isNotBlank(quoteLine.Pricing_Other_Product_Nm__c) && quoteLine.Pricing_Integration_Status_Nm__c == 'Error')
                    {
                        quoteLine.Pricing_Error_Messages__c = ''; 
                        quoteLine.Pricing_Integration_Status_Nm__c = '';
                    }  
                }

                if(!quoteNotifyMap.isEmpty()){
                    Pricing_EmailUtility.sendEmailToReciepents(new Set<Id>(quoteNotifyMap.values()),Label.Pricing_Quote_Line_Approve_AE_Notification);
                }
                Map<Id,SBQQ__QuoteLine__c> changeRequestQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                
                if(!pfirQLSet.isEmpty()){
                    changeRequestQuoteLineMap =  new Map<Id,SBQQ__QuoteLine__c>([SELECT Id,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,
                                                                                 Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,
                                                                                 Pricing_Reference_Quote_Line_Nbr__r.Pricing_Request_Discount_Unit_Price_qty__c,
                                                                                 Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,
                                                                                 Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Unit_Qty__c,
                                                                                 Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c,
                                                                                 Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,
                                                                                 Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,
                                                                                 Pricing_Reference_Quote_Line_Nbr__r.Pricing_Won_Lost_Comments_Txt__c,
                                                                                 Pricing_Reference_Quote_Line_Nbr__r.Pricing_Product_Nm__c 
                                                                                 from SBQQ__QuoteLine__c where Id IN: pfirQLSet]); 
                } 
                Set < String > quoteLineReadOnlyStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_ReadOnly_Status).split(':'));
                Set < String > quoteLineEditStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_Edit_Status).split(':'));
                
                Set < String > quoteLineReadOnlyDealRFQStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_ReadOnly_DealRFQStatus).split(':'));
                Set < String > quoteLineEditDealRFQStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_Edit_DealRFQStatus).split(':'));         
                
                Set < String > quoteLineReadOnlyIntegrationStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_ReadOnly_IntegrationStatus).split(':'));
                Set < String > quoteLineEditIntegrationStatusSet = new Set < String > ((Label.Pricing_Tender_QuoteLine_Edit_IntegrationStatus).split(':'));
                
                List<SBQQ__QuoteLine__c> hasPendingChangeRequestList = [SELECT Pricing_Reference_Quote_Line_Nbr__c FROM SBQQ__QuoteLine__c where Pricing_Reference_Quote_Line_Nbr__c IN: quoteLinePrimaryStatusSet AND Pricing_Status_Nm__c IN: Label.Pricing_QuotelineStatus_AllPicklistValues_Except_Rejected.split(',')];
                Set<Id> hasPendingChangeRequestSet =  new Set<Id>();
                Map<Id, String>  restrictStatusUnifiedQuoteLineMsgMap = new Map<Id, String>();
                if(!hasPendingChangeRequestList.isEmpty()){
                    for(SBQQ__QuoteLine__c qLId : hasPendingChangeRequestList){
                        hasPendingChangeRequestSet.add(qLId.Pricing_Reference_Quote_Line_Nbr__c);
                    }
                }
                if(restrictWonNotUnifiedSet.size() > 0) {
                    restrictStatusUnifiedQuoteLineMsgMap = Pricing_QuoteLineController.isNotUnifiedQuoteLineBulk(restrictWonNotUnifiedSet);
                }
                String quarter;
                List<String> quarterLst = new List<String>();
                List<Period> month = new List<Period>();
                if(qliQuarterSet.size()>0){
                    quarter = [SELECT FullyQualifiedLabel FROM Period WHERE FiscalYearSettings.YearType='Custom' and Type = 'Quarter' and StartDate <= : System.today() order by StartDate desc limit 1][0].FullyQualifiedLabel ;
                    month = [SELECT FiscalYearSettings.Name, Number FROM Period where FiscalYearSettings.YearType = 'Custom' And Type = 'Month' And StartDate <= : System.today() order by StartDate desc limit 1];
                    quarterLst = quarter.split(' ');
                }
                
                //Auto Rejection of quotelines on submission if Sanctioned and get Quotelines that have RPL status as EC
                if(autoRejectSanctionedQLSet.size() > 0) {
                    for(SBQQ__QuoteLine__c qLine : [SELECT Id,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c 
                                                    FROM SBQQ__QuoteLine__c WHERE Id IN:autoRejectSanctionedQLSet ]) {
                                                        List<String> complianceWatchList = qLine.SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c.split(';');
                                                        if(complianceWatchList.contains('EC')){
                                                            autoRejectedECCommentsQLSet.add(qLine.Id);
                                                        }
                                                    }
                }
                
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines){
                    
                    if(oldMap.get(quoteLine.Id).Pricing_Product_Nm__c != quoteLine.Pricing_Product_Nm__c) {
                        quoteLine.SBQQ__Product__c = quoteLine.Pricing_Product_Nm__c;
                        quoteLine.Pricing_Product_Series_Name__c = quoteLine.Pricing_Product_Series__c;
                    }
                    if((oldMap.get(quoteLine.Id).Pricing_Update_Status_to_Rejected_cb__c 
                        != quoteLine.Pricing_Update_Status_to_Rejected_cb__c) 
                       && quoteLine.Pricing_Update_Status_to_Rejected_cb__c
                       && Pricing_QuoteTeam_Trigger_Handler.hasQuoteLineResubmission == false){
                           quoteLine.Pricing_Update_Status_to_Rejected_cb__c = false;
                           if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview){
                               quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
                               quoteLine.Pricing_Sales_Rep_Approver__c = currentUser.Id;
                               if(quoteLine.Pricing_Change_Request_cb__c){
                                   quoteLine.Pricing_Change_Request_cb__c = false;
                               }
                           }
                       }
                    
                    //Auto Rejection of quotelines on submission i.e. Draft => PIFR and Draft => PFIR
                    if(ucdSwitch && autoRejectSanctionedQLSet.contains(quoteLine.Id)) {
                        quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
                        quoteLine.Pricing_Change_Request_cb__c = false;
                        quoteLine.Pricing_Last_Approved_Date_dt__c = DateTime.now();
                        quoteLine.Pricing_Approved_Rejected_Quarter__c = quarterLst[3]+'-'+quarterLst[0]+quarterLst[1];
                        String monthVal = month[0].Number < 10 ? '0' + String.valueOf(month[0].Number) : String.valueOf(month[0].Number);
                        quoteline.Pricing_Approved_Rejected_Month_Txt__c = month[0].FiscalYearSettings.Name+'-'+monthVal;
                        quoteLine.Pricing_Previous_Status_Nm__c = 'Rejected';
                        //If RPL status is EC 
                        quoteLine.Pricing_Rejection_Reason__c = Label.Pricing_rejection_reason_other_value;
                        quoteLine.Pricing_Rejection_Comments_nm__c = autoRejectedECCommentsQLSet.contains(quoteLine.Id) ? Label.Pricing_UCD_Auto_Rejection_Comments_For_EC:Label.Pricing_UCD_Auto_Rejection_Comments;
                        quoteLine.Pricing_pm_approval_comments_nm__c  = '';
                    } 

                    if((!quoteLineReadOnlyStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && (quoteLineReadOnlyStatusSet.contains(quoteLine.Pricing_Status_Nm__c))) || 
                       (!quoteLineReadOnlyDealRFQStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Deal_RFQ_Status_Nm__c != quoteLine.Pricing_Deal_RFQ_Status_Nm__c) && (quoteLineReadOnlyDealRFQStatusSet.contains(quoteLine.Pricing_Deal_RFQ_Status_Nm__c))) ||
                       (!quoteLineReadOnlyIntegrationStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Integration_Status_Nm__c != quoteLine.Pricing_Integration_Status_Nm__c) && (quoteLineReadOnlyIntegrationStatusSet.contains(quoteLine.Pricing_Integration_Status_Nm__c)))) { 
                           quoteLine.RecordTypeId = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Read_Only) : quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote ? Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'Pricing_Financial_Incentive_Quote_Line_Read_Only') : Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_ReadOnly);
                       } else if((!quoteLineEditStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && (quoteLineEditStatusSet.contains(quoteLine.Pricing_Status_Nm__c))) ||
                                 (!quoteLineEditDealRFQStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Deal_RFQ_Status_Nm__c != quoteLine.Pricing_Deal_RFQ_Status_Nm__c) && (quoteLineEditDealRFQStatusSet.contains(quoteLine.Pricing_Deal_RFQ_Status_Nm__c))) ||
                                 (!quoteLineEditIntegrationStatusSet.isEmpty() && (oldMap.get(quoteLine.id).Pricing_Integration_Status_Nm__c != quoteLine.Pricing_Integration_Status_Nm__c) && (quoteLineEditIntegrationStatusSet.contains(quoteLine.Pricing_Integration_Status_Nm__c) 
                                                                                                                                                                                                && ((String.isBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c))
                                                                                                                                                                                                    || (String.isNotBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && (quoteLineEditDealRFQStatusSet.contains(quoteLine.Pricing_Deal_RFQ_Status_Nm__c) || (String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c) && (quoteLineEditIntegrationStatusSet.contains(quoteLine.Pricing_Integration_Status_Nm__c))))))))) {                    
                                                                                                                                                                                                        quoteLine.RecordTypeId = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? svdSubmitRecordType : standardSubmitRecordType;
                                                                                                                                                                                                    } else if((oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft){
                                                                                                                                                                                                        quoteLine.RecordTypeId =quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? svdEditRecordType : quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote ? finInctvEditRecordType: standardEditRecordType;
                                                                                                                                                                                                    }
                    //TPT
                    if(oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) {
                        //Populate Approved/Rejected Date on Approval/Rejection and Change request Won QL
                        /*if((oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && 
                            (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won)) || 
                            quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected){*/
                        if(qliQuarterSet.contains(quoteLine.id)){
                            quoteLine.Pricing_Last_Approved_Date_dt__c = DateTime.now();
                            quoteLine.Pricing_Approved_Rejected_Quarter__c = quarterLst[3]+'-'+quarterLst[0]+quarterLst[1];
                            String monthVal = month[0].Number < 10 ? '0' + String.valueOf(month[0].Number) : String.valueOf(month[0].Number);                         
                            quoteline.Pricing_Approved_Rejected_Month_Txt__c = month[0].FiscalYearSettings.Name+'-'+monthVal;
                        }
                        if(quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null 
                           &&(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected || 
                              quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won)) {
                                  //Check if Change Request Quote Line is getting Approved then make the Parent as Revised
                                  if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved 
                                     && changeRequestQuoteLineMap.containsKey(quoteLine.Id)) {
                                         SBQQ__QuoteLine__c changeRequestQL =  changeRequestQuoteLineMap.get(quoteLine.Id);
                                         if(changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Action_Won && quoteLine.Pricing_Product_Nm__c == changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Product_Nm__c) {
                                             quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Action_Won;
                                             quoteLine.Pricing_Won_Lost_Comments_Txt__c = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Won_Lost_Comments_Txt__c;
                                         }
                                     }
                                  quoteLine.Pricing_Change_Request_cb__c = false;
                              }
                        
                        if((quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) || (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won) || (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost) || (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Revised)){
                            quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c=quoteLine.Pricing_Approved_Start_Date_Dt__c;
                            quoteLine.Pricing_Approved_End_Date_Dup_Dt__c=quoteLine.Pricing_Approved_End_Date_Dt__c;
                            quoteLine.Pricing_Approved_Unit_Dup_Qty__c=quoteLine.Pricing_Approved_Unit_Qty__c;
                            quoteLine.Pricing_ECAP_Price_Dup_Amt__c=quoteLine.Pricing_ECAP_Price_Amt__c;
                            quoteLine.Pricing_Deal_RFQ_Dup_Id__c=quoteLine.Pricing_Deal_RFQ_Id__c;
                            quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
                            
                        }
                        
                        //US750594
                        if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview){
                            if(quoteLine.Pricing_Change_Request_cb__c){
                                if(changeRequestQuoteLineMap.containsKey(quoteLine.Id)){
                                    SBQQ__QuoteLine__c changeRequestQL =  changeRequestQuoteLineMap.get(quoteLine.Id);
                                    quoteLine.Pricing_Approved_Start_Date_Dt__c = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c;
                                    quoteLine.Pricing_Approved_End_Date_Dt__c = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c;
                                    quoteLine.Pricing_Approved_Unit_Qty__c = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Unit_Qty__c;
                                    quoteLine.Pricing_ECAP_Price_Amt__c = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c;
                                    /*Date maxDate = System.today();
                                    if(changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c != null 
                                    && maxDate < changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c){
                                        maxDate = changeRequestQL.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c;
                                    }*/
                                }
                            }else{
                                if(quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c && quoteLine.Pricing_Program_Type_Nm__c == label.Pricing_Tender_CCG_Quote && ((oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) || (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview))){
                                    isCCG = true;
                                }
                                //flag to populate Approved fields using AI
                                isAutoAI = checkforAuotoPopLogic(quoteLine, quoteLine.Pricing_Server_Deal_Type_Nm__c, quoteLine.Pricing_EndCustomer_Nm__c) && 
                                            quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product &&  quoteLine.Pricing_Tentative_ECAP_Price_Amt__c == null ? true : false;
                                if(changeRequestQuoteLineMap.containsKey(quoteLine.Id)){
                                    quoteLine.Pricing_Approved_Start_Date_Dt__c = isAutoAI ? null : changeRequestQuoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c;
                                }
                                quoteLine.Pricing_Approved_End_Date_Dt__c = isAutoAI ? null : isCCG ? quoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c : quoteLine.Pricing_End_Date_dt__c;
                                quoteLine.Pricing_Billing_End_Date_Dt__c = isAutoAI ? null : isCCG ? quoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c : quoteLine.Pricing_End_Date_dt__c;
                                quoteLine.Pricing_Billing_Start_Date_Dt__c = isAutoAI ? null : changeRequestQuoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c;
                                
                                quoteLine.Pricing_Approved_Unit_Qty__c = (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_SSD_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_NIC_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ) ? quoteLine.Pricing_Total_Volume_Qty__c : quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU ? quoteLine.Pricing_No_of_GPUs__c : quoteLine.Pricing_Unit_Qty__c;
                                quoteLine.Pricing_ECAP_Price_Amt__c = null;//quoteLine.Pricing_Req_Discounted_Unit_Price__c;
                                quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = null;  
                                quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = null;
                                
                                //To check if it is CCG, then it will populate meet comp price as OEM's Requested price and Billing start date will populate as Approved start date - Account's No of Days.
                                if(isCCG){
                                    quoteLine.Pricing_Meet_Comp_Price_Amt__c = quoteLine.Pricing_Req_Discounted_Unit_Price__c;
                                    quoteLine.Pricing_Billing_Start_Date_Dt__c = quoteLine.Pricing_Approved_Start_Date_Dt__c.addDays(-Integer.valueOf(Label.Pricing_NoOfDays_NotPresent_CIMIdMtd));
                                }    
                            }
                        }
                    }
                    if(oldMap.get(quoteLine.Id).Pricing_Revised_Pricing_Start_Date_dt__c != quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c){
                        quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c;
                    }
                    if(quoteLine.Pricing_Additional_T_C_s_Txt__c != null && 
                       oldMap.get(quoteLine.Id).Pricing_Additional_T_C_s_Txt__c != quoteLine.Pricing_Additional_T_C_s_Txt__c){
                           quoteLine.Pricing_Is_Additional_T_C_Not_Blank_cb__c = true;
                       }else if (quoteLine.Pricing_Additional_T_C_s_Txt__c == null){
                           quoteLine.Pricing_Is_Additional_T_C_Not_Blank_cb__c = false;   
                       }
                    //Validation to check if the comments are filled for Data Center or a Client Quote if Ready for Review is set to True
                    if(oldMap.get(quoteLine.Id).Pricing_Ready_for_Review_cb__c != quoteLine.Pricing_Ready_for_Review_cb__c) {
                        String errorMessage = '';
                        if(quoteLine.Pricing_Ready_for_Review_cb__c == true){
                            for(Pricing_Comments__c cmnt:commentsFilled){
                                if(quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_Small_Volume_Quote && cmnt.Pricing_Quote__c == quoteLine.SBQQ__Quote__c && cmnt.Pricing_Answer__c == null){                                
                                    errorMessage = Label.Pricing_Tender_Quote_Comment_Submit_Error_Message;
                                    break;
                                }
                            }
                            if(!Label.Pricing_Tender_ExceptionQuoteType.contains(quoteLineMap.get(quoteLine.Id).Pricing_Program_Type_Nm__c) && quoteLineMap.get(quoteLine.Id).Performance_Metrics__r.IsEmpty() && checkPMSwitch){
                                if(errorMessage != ''){
                                    errorMessage = errorMessage+'<br/>'+Label.Pricing_Tender_QuoteLine_Performance_Metric_Submit_Error_Message;
                                }else{
                                    errorMessage = Label.Pricing_Tender_QuoteLine_Performance_Metric_Submit_Error_Message;
                                }
                            }
                            if(!String.isEmpty(errorMessage)){
                                quoteLine.addError(errorMessage,true);  
                            }
                        }    
                    }
                    
                    if((!quoteLinePrimaryStatusSet.isEmpty() && quoteLinePrimaryStatusSet.contains(quoteLine.Id)) || (!restrictStatusUnifiedQuoteLineMsgMap.isEmpty()  && restrictStatusUnifiedQuoteLineMsgMap.containsKey(quoteLine.Id))){
                        if(hasPendingChangeRequestSet.contains(quoteLine.Id)){
                            quoteLine.addError(Label.Pricing_CR_Reference_Status_Change_Message_Trigger);
                        }else if (restrictStatusUnifiedQuoteLineMsgMap.containsKey(quoteLine.Id)) {
                            quoteLine.addError(restrictStatusUnifiedQuoteLineMsgMap.get(quoteLine.Id));
                        } else {
                            quoteLine.Pricing_Status_Nm__c = quoteLine.Pricing_Quote_Line_Won_Lost_Status__c;
                            //calling Update At risk check on QuoteLine Won
                            if(quoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.Pricing_End_Customer_Opportunity_Txt__c != null && quoteLine.Pricing_Quote_Line_Won_Lost_Status__c == Label.Pricing_Tender_QuoteLine_Status_Won) {
                                wonQuoteIds.add(quoteLine.SBQQ__Quote__c);
                            }
                        }
                    }
                    if(!quoteLineSecondaryStatusSet.isEmpty() && quoteLineSecondaryStatusSet.contains(quoteLine.Id)  && quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program){                       
                        quoteLine.Pricing_Quote_Line_Won_Lost_Status__c = quoteLine.Pricing_Status_Nm__c;                       
                        if(quoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.Pricing_End_Customer_Opportunity_Txt__c != null && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won) {
                            wonQuoteIds.add(quoteLine.SBQQ__Quote__c);
                        }
                    }
                    //Revert Status fix
                    if(quoteLineNumberToStatusMap.containsKey(quoteLine.Pricing_Status_Nm__c)){
                        quoteLine.Pricing_Quote_Line_Status_Number__c = quoteLineNumberToStatusMap.get(quoteLine.Pricing_Status_Nm__c);
                        if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview){
                            if(quoteLineReadOnlyDealRFQStatusSet.contains(quoteLine.Pricing_Deal_RFQ_Status_Nm__c) || quoteLineEditDealRFQStatusSet.contains(quoteLine.Pricing_Deal_RFQ_Status_Nm__c) || quoteLineReadOnlyIntegrationStatusSet.contains(quoteLine.Pricing_Integration_Status_Nm__c)){
                                quoteLine.Pricing_Quote_Line_Status_Number__c = 45;
                            }else if((quoteLineEditIntegrationStatusSet.contains(quoteLine.Pricing_Integration_Status_Nm__c) || String.isBlank(quoteLine.Pricing_Integration_Status_Nm__c)) && String.isBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && String.isBlank(quoteLine.Pricing_Deal_RFQ_Status_Nm__c)){
                                quoteLine.Pricing_Quote_Line_Status_Number__c = 40;
                            }
                        }
                    }
                    //Validate QuoteLine Text fields and throw error if Non Latin Characters are present on Update
                    validateQLTextFieldsForLatinChars(quoteLine,oldMap,false); 
                    
                    if(quoteLine.Pricing_Previous_Status_Nm__c == 'Pending' && 
                       (oldMap.get(quoteLine.id).Pricing_Quote_Line_Status_Number__c == 10 ||
                        oldMap.get(quoteLine.id).Pricing_Quote_Line_Status_Number__c == 40 || 
                        oldMap.get(quoteLine.id).Pricing_Quote_Line_Status_Number__c == 30 || 
                        oldMap.get(quoteLine.id).Pricing_Quote_Line_Status_Number__c == 45) && quoteLine.Pricing_Quote_Line_Status_Number__c ==20) {
                            quoteLine.Pricing_Previous_Status_Nm__c = 'Rejected';
                    }
                    if(isBillingStartDateUpdate && !isAutoAI && !changeRequestQuoteLineMap.isEmpty()){
                        quoteLine.Pricing_Billing_Start_Date_Dt__c = changeRequestQuoteLineMap.get(quoteLine.Id).SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c.addDays(-Integer.valueOf((accountIdMtdRecordMap.get(accountId))));
                    }
                }
                if(qlIds.size() > 0){
                    Pricing_QuoteLine_WonPrediction.predictionQlStatusMarkAsWon(qlIds);
                }
            }
            if(!wonQuoteIds.isEmpty() && !System.isBatch()){
                Core_UpdateOptyRiskStatusFromQuote.updateAtRiskForTenderQuotes(wonQuoteIds);
            }    
            if(!competitorProductsIds.isEmpty() && !regionList.isEmpty() && !applicationSetforAutoPop.isEmpty()){
                Map<Id,Pricing_Competitor_Product_Price__c> compProductPriceMap = new Map<Id,Pricing_Competitor_Product_Price__c>();
                
                competitorProductPriceList = (competitorProductsIds != null ? (new List<Pricing_Competitor_Product_Price__c>([select id, Name, Pricing_Final_Meet_Comp_Price__c,Pricing_Competitor_Product__c,Pricing_Application_Nm__c from Pricing_Competitor_Product_Price__c where Pricing_Competitor_Product__c IN : competitorProductsIds and Pricing_Region_Nm__c IN :regionList and Pricing_Final_Meet_Comp_Price__c > 0 AND Pricing_Application_Nm__c IN: applicationSetforAutoPop])) : new List<Pricing_Competitor_Product_Price__c>()); //c
                for(Pricing_Competitor_Product_Price__c compProduct: competitorProductPriceList){
                    compProductPriceMap.Put(compProduct.Pricing_Competitor_Product__c,compProduct);
                }
                autoPopulateMeetComp(lstquoteLines,compProductPriceMap);
            }
        }
    }catch(Exception ex) { //try end 
        Pricing_Tender_Utility.logError(ex); 
    }
    }
    
    @TestVisible private static List<String>  usersHasValidRPMPermission(List<String> Emails,Set < string > permissionSets) {
        List<String> EmailwithPermission = new List<String>();
        for(PermissionSetAssignment RPM_permission : [SELECT Id, AssigneeId,Assignee.Email FROM PermissionSetAssignment WHERE Assignee.Email in: Emails AND Assignee.IsActive = true 
                                                      AND  PermissionSet.Name IN: permissionSets])
        {
            EmailwithPermission.add(RPM_permission.Assignee.Email);
        }
        
        return EmailwithPermission;
    }
    
    /**
    * @description Method written to validate the Addtional RPM Recipients
    * @author Bharath Chandrashekar | 01-17-2023 
    * @param SBQQ__QuoteLine__c quoteLine 
    * @param String rpmEmailsWithNoPermission 
    * @param List<String> Emails 
    * @param Boolean isRPMUser 
    * @return String 
    **/
    @TestVisible private static String validateAdditionalRecipients(SBQQ__QuoteLine__c quoteLine, String rpmEmailsWithNoPermission, List<String> Emails, Boolean isRPMUser){
        rpmEmailsWithNoPermission='';
        if(quoteLine.Pricing_Additional_RPM_Notify_Recipients__c != null && quoteLine.Pricing_Additional_RPM_Notify_Recipients__c != '' && isRPMUser){
            for(String email : ((quoteLine.Pricing_Additional_RPM_Notify_Recipients__c).deleteWhitespace()).split(';')){
                if(!Emails.contains(email)){
                    rpmEmailsWithNoPermission += email+';';
                }
            }
        }
        return rpmEmailsWithNoPermission;
    }
    
    public static Map < Id, List < SBQQ__QuoteLine__c >> generateQuoteLineMap(List < SBQQ__QuoteLine__c > lstquoteLines) {
        Set < Id > quoteIds = new Set < Id > ();
        for(SBQQ__QuoteLine__c ql: lstquoteLines) {
            quoteIds.add(ql.SBQQ__Quote__c);
        }
        Map < Id, List < SBQQ__QuoteLine__c >> quoteLineDtls = new Map < Id, List < SBQQ__QuoteLine__c >> ();
        List < SBQQ__QuoteLine__c > mapQuoteLine = new List < SBQQ__QuoteLine__c > (
            [SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.Name, Pricing_Quote_Line_Number__c FROM SBQQ__QuoteLine__c
             WHERE SBQQ__Quote__c IN: quoteIds AND Pricing_Reference_Quote_Line_Nbr__c = null
            ]);
        existingQuote = new Map < id, SBQQ__Quote__c > ([Select Id, Name from SBQQ__Quote__c where Id IN: quoteIds]);
        For(SBQQ__QuoteLine__c ql: mapQuoteLine) {
            if(quoteLineDtls.containsKey(ql.SBQQ__Quote__c)) {
                List < SBQQ__QuoteLine__c > quoteLine = quoteLineDtls.get(ql.SBQQ__Quote__c);
                quoteLine.add(ql);
                quoteLineDtls.put(ql.SBQQ__Quote__c, quoteLine);
            } else {
                quoteLineDtls.put(ql.SBQQ__Quote__c, new List < SBQQ__QuoteLine__c > {
                    ql
                        });
            }
        }
        return quoteLineDtls;
    }
    
    public static void updateQuoteLineNumber(List < SBQQ__QuoteLine__c > lstquoteLines) {
       try{
        if(lstquoteLines!=null && !lstquoteLines.isEmpty()){
            Map < Id, List < SBQQ__QuoteLine__c >> mapOfQuoteAndQuoteLine = generateQuoteLineMap(lstquoteLines); 
            Map<Id,List<Integer>> mapOfQuoteIdQLINumber = new Map<Id,List<Integer>>();
            Map<Id,Integer> mapOfQIdNumber = new Map<Id,Integer>();
            for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                List < SBQQ__QuoteLine__c > existingQuoteLine = new List < SBQQ__QuoteLine__c > ();
                if(mapOfQuoteAndQuoteLine != null && mapOfQuoteAndQuoteLine.containsKey(quoteLine.SBQQ__Quote__c) && !mapOfQuoteIdQLINumber.containsKey(quoteLine.SBQQ__Quote__c)) {
                    existingQuoteLine = mapOfQuoteAndQuoteLine.get(quoteLine.SBQQ__Quote__c);
                    if(existingQuoteLine.size() > 0) {
                        for(SBQQ__QuoteLine__c ql: existingQuoteLine) {
                            if(ql.Pricing_Quote_Line_Number__c != null && ql.Pricing_Quote_Line_Number__c != '') {                               
                                if(mapOfQuoteIdQLINumber.containsKey(ql.SBQQ__Quote__c)){
                                    mapOfQuoteIdQLINumber.get(ql.SBQQ__Quote__c).add(Integer.valueOf(ql.Pricing_Quote_Line_Number__c.substringAfter('-').substringAfter('-')));
                                }else{
                                    mapOfQuoteIdQLINumber.put(ql.SBQQ__Quote__c, new List<Integer> {Integer.valueOf(ql.Pricing_Quote_Line_Number__c.substringAfter('-').substringAfter('-'))});
                                }
                            }
                        }                       
                    }
                }                 
            }            
            
            
            for(Id quoteId: mapOfQuoteIdQLINumber.keySet()){
                mapOfQuoteIdQLINumber.get(quoteId).sort();
            }
            for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {               
                if(mapOfQuoteIdQLINumber.containsKey(quoteLine.SBQQ__Quote__c)) {
                    List<integer> lineNbr = mapOfQuoteIdQLINumber.get(quoteLine.SBQQ__Quote__c);                                        
                    if(quoteLine.Pricing_Quote_Line_Number__c == null || quoteLine.Pricing_Quote_Line_Number__c == '') {
                        quoteLine.Pricing_Quote_Line_Number__c = existingQuote.get(quoteLine.SBQQ__Quote__c).Name + '-' + String.valueOf(lineNbr.get(lineNbr.Size() - 1) + 1).leftPad(3, '0');
                        mapOfQuoteIdQLINumber.get(quoteLine.SBQQ__Quote__c).add(lineNbr.get(lineNbr.Size() - 1) + 1);  //added for multiple quote line
                    }                    
                }else if(quoteLine.Pricing_Quote_Line_Number__c == null || quoteLine.Pricing_Quote_Line_Number__c == '') {
                    Integer qliNumber = 1;
                    if(mapOfQIdNumber.containsKey(quoteLine.SBQQ__Quote__c)){
                        qliNumber = mapOfQIdNumber.get(quoteLine.SBQQ__Quote__c);
                    }                    
                    quoteLine.Pricing_Quote_Line_Number__c = existingQuote.get(quoteLine.SBQQ__Quote__c).Name + '-' + String.valueOf(qliNumber).leftPad(3, '0');
                    mapOfQIdNumber.put(quoteLine.SBQQ__Quote__c, qliNumber+1);
                }                
            }
        }
        }
        catch(Exception ex) {
            Pricing_Tender_Utility.logError(ex); 
        }
    }  

    
    public static void updateQuoteStatus(List < SBQQ__QuoteLine__c > lstquoteLines, Map < id, SBQQ__QuoteLine__c > oldMap){
        if(lstquoteLines!=null && !lstquoteLines.isEmpty()){
            try {
                Set<Id> quoteLineIdSet = new Set<Id>();
                Set<Id> changeRequestUpdationIdSet = new Set<Id>();
                Set<Id> quoteLineIdSetToApprove = new Set<Id>();
                Set<Id> quoteLineIdSetToReject = new Set<Id>();
                Set<Id> aeNotificationSubmittedQli = new Set<Id>();
                Set<Id> aeNotificationSubmittedQliQuote = new Set<Id>();
                Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__r.Pricing_On_Hold_Cb__c FROM SBQQ__QuoteLine__c WHERE Id IN: oldMap.keySet()]);
                Boolean hasPermissionSetAPI = currentUserHasAPIPs();

                for(SBQQ__QuoteLine__c ql: lstquoteLines){
                    if(currentUser.Core_User_Profile_Name__c != Label.Pricing_Tender_Profiles_Partner  && !hasPermissionSetAPI){
                        if(quoteLineMap.get(ql.Id).SBQQ__Quote__r.Pricing_On_Hold_Cb__c && ql.Pricing_Status_Nm__c != oldMap.get(ql.id).Pricing_Status_Nm__c && oldMap.get(ql.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview) {
                            ql.addError(Label.Pricing_Quote_Line_On_Hold_Error_Msg);
                        }
                    }
                    if(ql.Pricing_Reference_Quote_Line_Nbr__c != null && ql.Pricing_Status_Nm__c != oldMap.get(ql.id).Pricing_Status_Nm__c && (ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved 
                                                                                                                                               || ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won || ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected)){
                                                                                                                                                   changeRequestUpdationIdSet.add(ql.Pricing_Reference_Quote_Line_Nbr__c);
                                                                                                                                               }
                    if(oldMap.get(ql.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && ql.Pricing_Status_Nm__c != oldMap.get(ql.id).Pricing_Status_Nm__c){
                        if(ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview ) {
                            quoteLineIdSetToApprove.add(ql.Id);
                        }else if(ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected){
                            quoteLineIdSetToReject.add(ql.Id);
                        }
                    }
                    
                    if(oldMap.get(ql.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft && 
                    (ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview || 
                     ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview)){
                        aeNotificationSubmittedQli.add(ql.Id);
                    }
                }
                
                if(!aeNotificationSubmittedQli.isEmpty()){
                    for(SBQQ__QuoteLine__c quoteLine : [Select Id,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where Id IN : aeNotificationSubmittedQli and SBQQ__Quote__r.SBQQ__Status__c IN: Label.Pricing_Quote_Status_NotEqualsTo_Draft.split(',')]){
                        aeNotificationSubmittedQliQuote.add(quoteLine.Id);
                    }   
                }

                Map<Id,SBQQ__QuoteLine__c> referenceQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                if(!changeRequestUpdationIdSet.isEmpty()){
                    for(SBQQ__QuoteLine__c quoteLine : [Select Id,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__c,Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c, Pricing_Status_Nm__c,Pricing_Deal_RFQ_Status_Nm__c,Pricing_Integration_Status_Nm__c,Pricing_Deal_RFQ_Id__c from SBQQ__QuoteLine__c where Id IN : changeRequestUpdationIdSet]){
                        referenceQuoteLineMap.put(quoteLine.Id,quoteLine);
                    }   
                }
                
                if(!quoteLineIdSetToApprove.isEmpty()){
                    Pricing_Publish_Quote.setFSEActionOnQuoteLine(quoteLineIdSetToApprove,Label.Pricing_Tender_QuoteLine_Action_Approve,null,true);
                }
                if(!System.isBatch()){
                    if(!quoteLineIdSetToReject.isEmpty()){
                        Pricing_Publish_Quote.setFSEActionOnQuoteLine(quoteLineIdSetToReject,Label.Pricing_Tender_QuoteLine_Action_Reject,null,true);
                    }
                }
                Map<Id,SBQQ__QuoteLine__c> referenceQuoteLineUpdateMap = new Map<Id,SBQQ__QuoteLine__c>();
                Map<String, Set<Id>> quoteLineActionMap = new Map<String, Set<Id>>();
                Set<Id> approvedQLIIds = new Set<Id>();
                Set<Id> rejectedQLIIds = new Set<Id>();
                Set<Id> rejectedFIQLIIds = new Set<Id>();
                Set<Id> cancelledQLIIds = new Set<Id>();
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {   
                    if (!mapFunctionalityNameTriggerExecution.isEmpty() && mapFunctionalityNameTriggerExecution.containsKey('pricingSendOutboundMessagesIQR') &&
                    mapFunctionalityNameTriggerExecution.get('pricingSendOutboundMessagesIQR').Core_Active__c){
                    if((oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && 
                       //updated By Naresh
                       //(quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product) &&
                       ((oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved && 
                         (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won || 
                          quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost)) ||
                        (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost && 
                         quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) ||
                        (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Cancelled) ||
                        (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && 
                         oldMap.get(quoteLine.id).Pricing_Integration_Status_Nm__c == Label.Pricing_Tender_MyDeal_Integration_Status_Complete
                         && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected)
                       )){
                           //updated By Naresh
                           String action = '';
                           if(String.isNotBlank(quoteLine.Pricing_Deal_RFQ_Id__c)) {
                               quoteLineIdSet.add(quoteLine.Id);
                               action = Label.Pricing_IQR_Event_Action_Won_Lost_Integration;
                           }else if(quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote){
                               action = Label.Pricing_IQR_Event_Action_Won_Lost_Notification;
                           } 
                           if(!String.isEmpty(action)){
                               if(quoteLineActionMap.containsKey(action)){
                                   quoteLineActionMap.get(action).add(quoteLine.Id);
                               }else{
                                   quoteLineActionMap.put(action, new Set<id>{quoteLine.Id});
                               }
                            }
                        }
                    }

                    //RPM Email Notification Triggering scenario
                    if(oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c && 
                       String.isNotBlank(quoteLine.Pricing_Deal_RFQ_Id__c) && 
                       oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview &&
                        (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || 
                         quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won) && quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote) {
                             approvedQLIIds.add(quoteLine.id);
                    }
                    

                    //Cancellation Email Notification for FI
                    if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote && oldMap.get(quoteLine.id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c 
                    && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Cancelled) {
                        cancelledQLIIds.add(quoteLine.id);
                    }


                    if(quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null && quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c 
                    && (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won) 
                    && referenceQuoteLineMap.containsKey(quoteLine.Pricing_Reference_Quote_Line_Nbr__c)){
                        SBQQ__QuoteLine__c referenceQuoteLine = referenceQuoteLineMap.get(quoteLine.Pricing_Reference_Quote_Line_Nbr__c);
                        if(referenceQuoteLineUpdateMap.containsKey(referenceQuoteLine.Id)){
                            referenceQuoteLineUpdateMap.get(referenceQuoteLine.Id).Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Revised;
                        }else{//#ticket
                            if(referenceQuoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Revised){
                                referenceQuoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Revised;
                                referenceQuoteLineUpdateMap.put(referenceQuoteLine.Id,referenceQuoteLine);
                            }
                        }
                    }

                    if((quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected) && (oldMap.get(quoteLine.id).Pricing_Previous_Status_Nm__c == 'Pending' && quoteLine.Pricing_Previous_Status_Nm__c == 'Rejected') && 
                    quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c && 
                    (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview)) {
                            rejectedFIQLIIds.add(quoteLine.Id);
                    }
                    //Rejection Email Notification Triggering scenario
                    if((quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_FinancialIncentive_Quote && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected) && (oldMap.get(quoteLine.id).Pricing_Previous_Status_Nm__c == 'Pending' && quoteLine.Pricing_Previous_Status_Nm__c == 'Rejected') && 
                       quoteLine.Pricing_Status_Nm__c != oldMap.get(quoteLine.id).Pricing_Status_Nm__c && 
                       (oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft || 
                        oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview || 
                        oldMap.get(quoteLine.id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview)) {
                            rejectedQLIIds.add(quoteLine.Id);
                    }
                }
                if(!referenceQuoteLineUpdateMap.isEmpty()){
                    SBQQ.TriggerControl.disable();
                    update referenceQuoteLineUpdateMap.values();
                    SBQQ.TriggerControl.enable();
                }
                
                
                    
                
                //updated By Naresh
                if(quoteLineActionMap.size() > 0){
                    publishIQR(quoteLineActionMap);
                }
                /*
                    if(!quoteLineIdToUserIdNotifyRPMMap.isEmpty()){
                    sendEmailNotification(quoteLineIdToUserIdNotifyRPMMap,Label.Pricing_RPM_Notification_Email_Template_Name);
                    }*/
                if(approvedQLIIds.size() > 0){
                    Pricing_EmailUtility.sendEmail(approvedQLIIds, Label.Pricing_RPM_Notification_Email_Template_Name);
                }
                if(rejectedQLIIds.size() > 0){
                    Pricing_EmailUtility.sendEmail(rejectedQLIIds, Label.Pricing_QuoteLineRejectedNotification_Template);
                }
                if(rejectedFIQLIIds.size() > 0){
                    Pricing_EmailUtility.sendEmailToReciepents(rejectedFIQLIIds, 'Pricing_FI_QL_Rejection_Notification');
                }
                if(cancelledQLIIds.size() > 0){
                    Pricing_EmailUtility.sendEmail(cancelledQLIIds, 'Pricing_FI_QL_Cancel_Notification');
                }
                if(aeNotificationSubmittedQliQuote.size() > 0){
                    Pricing_EmailUtility.sendEmail(aeNotificationSubmittedQliQuote, 'Pricing_AE_QuoteLineCRNotification');
                }

            } catch(exception ex) {Pricing_Tender_Utility.logError(ex);}
            finally{
                SBQQ.TriggerControl.enable();
            }
        }
    }

    /*
    public static void publishIQR(Set<Id> quoteLineIdSet){
    try{
    // List to hold event objects to be published.
    List<Pricing_IQR_Event__e> newsEventList = new List<Pricing_IQR_Event__e>();
    // Create event objects.
    String quoteLineIdStr;
    if(!quoteLineIdSet.isEmpty()){
    List<Id> quoteLineIdList = new List<Id>();
    quoteLineIdList.addAll(quoteLineIdSet);
    quoteLineIdStr = String.join(quoteLineIdList,',');
    }
    if(quoteLineIdStr != null){
    // Add event objects to the list.
    newsEventList.add(new Pricing_IQR_Event__e(
    Pricing_QuoteLineId_Txt__c = quoteLineIdStr,
    Pricing_IQR_Action_Nm__c = Label.Pricing_IQR_Event_Action_Won_Lost_Integration));

    // Call method to publish events.
    List<Database.SaveResult> results = EventBus.publish(newsEventList);
    // Inspect publishing result for each event
    for (Database.SaveResult sr : results) {
    if (sr.isSuccess()) {
    
    } else {
    for(Database.Error err : sr.getErrors()) {
    
    }
    }
    }
    }
    }catch(exception ex) {Pricing_Tender_Utility.logError(ex);}
    }
    */

    //updated By Naresh
    public static void publishIQR(Map<String, Set<Id>> quoteLineIdActionMap){
        try{
            //List to hold event objects to be published.
            List<Pricing_IQR_Event__e> newsEventList = new List<Pricing_IQR_Event__e>();
            for(String actionKey : quoteLineIdActionMap.keySet()){
                List<Id> quoteLineIds = new List<Id>();
                for(Id qliId : quoteLineIdActionMap.get(actionKey)){
                    quoteLineIds.add(qliId);
                }
                String quoteLineIdStr =  String.join(quoteLineIds,',');               
                if(!String.isEmpty(quoteLineIdStr)){
                    newsEventList.add(new Pricing_IQR_Event__e(
                        Pricing_QuoteLineId_Txt__c = quoteLineIdStr,
                        Pricing_IQR_Action_Nm__c = actionKey));
                    //Label.Pricing_IQR_Event_Action_Won_Lost_Integration)); 
                }
            }
            if(newsEventList.size() > 0){               
                // Call method to publish events.
                List<Database.SaveResult> results = EventBus.publish(newsEventList);
            }                            
        }catch(exception ex) {Pricing_Tender_Utility.logError(ex);}
    }
    
    public static void validateQLEditWithPFIRNotRPM(List < SBQQ__QuoteLine__c > lstquoteLines, Map < id, SBQQ__QuoteLine__c > oldMap) {
        if(lstquoteLines!=null && !lstquoteLines.isEmpty()){
            Set < String > fieldsEditableWithPFIR = new Set < String > ((Label.Pricing_Tender_Field_Edit_With_PFIR).split(':'));
            Set < String > fieldsNonEditable = new Set < String > ();
            Boolean isRPM = checkCurrentUserPs(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
        
        if(!Test.isRunningTest()) {
            List<User> usr = [SELECT Id, name, username, profileid From User where Id =: UserInfo.getUserId() and profile.name = 'Integration'];
            if(usr.size() > 0 && usr[0].Name.contains('Integration User')){
                return;
            }
        }
        if(!isRPM && !isAutoApproveReject) {
            fieldsNonEditable.addAll(getFieldsFromLayout());
            fieldsNonEditable.addAll(Label.Pricing_PFIR_Additional_Non_Editable_Fields.split(':'));
            fieldsNonEditable.removeAll(fieldsEditableWithPFIR);
        }
        for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
            if(!isRPM && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview &&
                oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) {
                    for(String field: fieldsNonEditable) {
                        if(quoteLine.get(field) != oldMap.get(quoteLine.Id).get(field)) {
                            quoteLine.addError(Label.Pricing_Tender_No_Access_Error_Message);
                            break;
                        }
                    }
                }
        }
    }
}

    public static Group adminQueue = null;
    public static List<Pricing_Quote_Line_Status_Age__c> PopulateQLStatusAgeRecord(List <SBQQ__QuoteLine__c> lstquoteLines,
                                                                                   Map <Id, SBQQ__QuoteLine__c> oldObjectMap,Boolean isInsert,Boolean isIntegration,String userRole,String actorName,DateTime integrationTime,String subStatus){                                                                                    
                                                                                    Id  tptRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Quote_Line_Status_Age__c','Pricing_Financial_Incentive_TPT');
                                                                                       List<Pricing_Quote_Line_Status_Age__c> statusChanges = new List<Pricing_Quote_Line_Status_Age__c>();
                                                                                       if(adminQueue == null){
                                                                                           adminQueue = [Select Id from Group where DeveloperName =:Label.Pricing_Tender_TPT_Admin_Queue];
                                                                                       }
                                                                                       if(isInsert){ 
                                                                                        
                                                                                           for (SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                                                                                               Pricing_Quote_Line_Status_Age__c statusChange = new Pricing_Quote_Line_Status_Age__c();
                                                                                               //TPT record owner assigned to queue
                                                                                               statusChange.OwnerId = adminQueue.Id;                 
                                                                                               statusChange.Pricing_TPT_Quote_Line_Number__c = quoteLine.Id;
                                                                                               statusChange.Pricing_TPT_Status_From__c = quoteLine.Pricing_Status_Nm__c;
                                                                                               statusChange.Pricing_TPT_Set_Time__c = Datetime.now();
                                                                                               statusChange.Pricing_TPT_From_Actor_Nm__c = UserInfo.getName();
                                                                                               statusChange.Pricing_TPT_Change_Request_QuoteLine_cb__c = quoteLine.Pricing_Change_Request_cb__c;
                                                                                               statusChange.Pricing_TPT_Role_Aggregate_cb__c = true;   //AggregateLogic 
                                                                                               statusChange.Pricing_TPT_Share_Required__c = true;
                                                                                               if(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote) {
                                                                                                statusChange.RecordTypeId = tptRecordTypeId;
                                                                                           }
                                                                                               statusChanges.add(statusChange);
                                                                                           }
                                                                                       }else{
                                                                                           for (SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                                                                                               if (isIntegration  || (oldObjectMap.containsKey(quoteLine.Id) && 
                                                                                                                      quoteLine.Pricing_Status_Nm__c != (oldObjectMap.get(quoteLine.Id)).Pricing_Status_Nm__c
                                                                                                                      && ((quoteLine.Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Approved 
                                                                                                                        && ((oldObjectMap.get(quoteLine.Id)).Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Rejected 
                                                                                                                            && (oldObjectMap.get(quoteLine.Id)).Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Cancelled 
                                                                                                                                && (oldObjectMap.get(quoteLine.Id)).Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Revised)) 
                                                                                                                                || (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved
                                                                                                                                    && ((oldObjectMap.get(quoteLine.Id)).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost
                                                                                                                                    || String.isBlank(quoteLine.Pricing_Deal_RFQ_Id__c)
                                                                                                                                        ))))){ 
                                                                                                                                     
                                                                                                                                     Pricing_Quote_Line_Status_Age__c statusChange = new Pricing_Quote_Line_Status_Age__c();
                                                                                                                                     statusChange.OwnerId = adminQueue.Id;
                                                                                                                                     statusChange.Pricing_TPT_Quote_Line_Number__c = quoteLine.Id;
                                                                                                                                     if(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote) {
                                                                                                                                        statusChange.RecordTypeId = tptRecordTypeId;
                                                                                                                                   }
                                                                                                                                     
                                                                                                                                     if(isIntegration && !String.isBlank(subStatus)){
                                                                                                                                         statusChange.Pricing_TPT_Status_From__c = (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview)?(subStatus == Label.Pricing_Tender_QuoteLine_Status_Approved) ? 
                                                                                                                                             subStatus : (quoteLine.Pricing_Status_Nm__c +'-'+subStatus) : quoteLine.Pricing_Status_Nm__c;                                                                                                                                             
                                                                                                                                    }else{
                                                                                                                                                     statusChange.Pricing_TPT_Status_From__c = quoteLine.Pricing_Status_Nm__c;                                                                                                                                                     
                                                                                                                                                 }
                                                                                                                                     statusChange.Pricing_TPT_From_Actor_Nm__c =  isIntegration ? actorName : UserInfo.getName();
                                                                                                                                     statusChange.Pricing_TPT_Set_Time__c = isIntegration ? integrationTime : Datetime.now();
                                                                                                                                     if(!isIntegration){
                                                                                                                                         SBQQ__QuoteLine__c oldObjectRec = oldObjectMap.get(quoteLine.Id);
                                                                                                                                         if(((oldObjectRec.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview 
                                                                                                                                              || oldObjectRec.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview)
                                                                                                                                             && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Draft) 
                                                                                                                                            || (oldObjectRec.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview
                                                                                                                                                && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview)){
                                                                                                                                                    statusChange.Revision_QuoteLine__c = true;  
                                                                                                                                                }
                                                                                                                                     }
                                                                                                                                     statusChange.Pricing_TPT_Share_Required__c = true;
                                                                                                                                     statusChanges.add(statusChange);
                                                                                                                                 }
                                                                                           }
                                                                                       }
                                                                                       return statusChanges;
                                                                                   }
    
    private static String getAge(Decimal milliseconds) {
        Double duration = milliseconds;
        Double d = Math.floor(duration/86400000); //Get whole days
        duration -= d*86400000;
        Double h = Math.floor(duration/3600000); //Get whole hours
        duration -= h*3600000;
        Double m = Math.floor(duration/60000);
        duration -= m*60000;
        Double s = Math.floor(duration/1000);
        return d.format()+' days '+h.format()+' hours '+ m.format() + ' minutes ' + s.format() +' seconds';
    }

    private static String getUserRole(){
        Set < String > ps = new Set < String >{Label.Pricing_Tender_PermissionSets_TenderUser,
            Label.Pricing_Tender_PermissionSets_TenderPartner,
            Label.Pricing_Tender_PermissionSets_TenderDrafter,
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager,
            Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator,
            Label.Pricing_Tender_PermissionSets_TenderAccountExecutive,
            Label.Pricing_Tender_Permission_Set_IT_Specialist,
            Label.Pricing_Tender_PermissionSets_PartnerLimitedAccess,
            Label.Pricing_Tender_PermissionSets_TenderDrafterLimited};
                
                if(!String.isEmpty(Label.Pricing_IQR_API_UserPermissionSets) ){
                    ps.addAll(Label.Pricing_IQR_API_UserPermissionSets.split(','));
                }                                     
        String role='';
        List<String> externalPs = new List<String>{'Tender_Partner' , 'Pricing_Tender_Partner_Administrator' , 'Tender_Partner_Drafter_Access' , 'Tender_Partner_Limited_Access' , 'Tender_Partner_Drafter_Limited_Access', 'Pricing_IQR_HPE_B2B', 'Pricing_IQR_Cisco_B2B', 'Pricing_IQR_Lenovo_B2B'};
            if(!currentUser.PermissionSetAssignments.isEmpty()){
                for(PermissionSetAssignment psa :currentUser.PermissionSetAssignments){
                    String psUser = psa.PermissionSet.Name;
                    if(externalPs.contains(psUser)){
                        role = 'OEM';
                    }
                    switch on psUser {
                        when 'Tender_User' {
                            role = 'SDM';
                        }
                        when 'Tender_Account_Executive' {
                            role = 'Account Executive';
                        }
                        when 'Pricing_Tender_Permission_Set_IT_Specialist' {
                            role = 'IT Specialist';
                        }
                        when 'Pricing_Tender_Regional_Pricing_Manager' , 'Pricing_Financial_Incentive_Regional_Pricing_Manager'{
                            role ='RPM';
                        }
                        when else {
                            role = '';
                        }
                    }
                }
                if(!String.isEmpty(role)){
                    return role;
                }
                else {
                    return Label.Pricing_User_Role;
                }
            }
        else{
            return null;
        }
    }

    public static void CreateQuoteLineStatusAgeRecord(SBQQ__QuoteLine__c[] newObjects,Boolean isInsert){
        if(newObjects!=null && !newObjects.isEmpty()){
            try{                
                List<Pricing_Quote_Line_Status_Age__c> tptList = new List<Pricing_Quote_Line_Status_Age__c>();
                tptList.addAll(PopulateQLStatusAgeRecord(newObjects, null, isInsert,false,null,null,null,null));
                insert tptList;
            }catch(exception ex) {Pricing_Tender_Utility.logError(ex);}
        }
    }
    
    public static void UpdateQuoteLineStatusAgeRecord(SBQQ__QuoteLine__c[] updatedObjects, Map<Id, SBQQ__QuoteLine__c> oldObjectMap, 
                                                      Boolean isInsert,Boolean isIntegration,String userRole,String actorName,
                                                      DateTime integrationTime,String subStatus){                                                          
                                                          List<Pricing_Quote_Line_Status_Age__c> tptListToUpdate = new List<Pricing_Quote_Line_Status_Age__c>();
                                                          tptListToUpdate.addAll(getTPTRecordsToUpdate(updatedObjects, oldObjectMap, isInsert, isIntegration, userRole, actorName, integrationTime, subStatus));
                                                        if(!tptListToUpdate.isEmpty()){
                                                            upsert tptListToUpdate;
                                                        }
    }

    public static Set<Pricing_Quote_Line_Status_Age__c> getTPTRecordsToUpdate(SBQQ__QuoteLine__c[] updatedObjects, Map<Id, SBQQ__QuoteLine__c> oldObjectMap, 
        Boolean isInsert,Boolean isIntegration,String userRole,String actorName,
        DateTime integrationTime,String subStatus){        
        if(updatedObjects!=null && !updatedObjects.isEmpty()){
            try{
                                                                                          Set<Pricing_Quote_Line_Status_Age__c> tptList = new Set<Pricing_Quote_Line_Status_Age__c>();
                Set<String> oldStatusSet = new Set<String>();
                Set<Id> quoteLineIdSet = new Set<Id>();
                Map<Id,SBQQ__QuoteLine__c> quoteLinesMap = new Map<Id,SBQQ__QuoteLine__c>();
                Map<Id,Pricing_Quote_Line_Status_Age__c> quoteLineIdToTPTMap = new Map<Id,Pricing_Quote_Line_Status_Age__c>();
                tptList.addAll(PopulateQLStatusAgeRecord(updatedObjects, oldObjectMap, isInsert,isIntegration,userRole,
                                                         actorName,integrationTime,subStatus));                
                
                for (Pricing_Quote_Line_Status_Age__c statusChange: tptList) {
                    quoteLineIdSet.add(statusChange.Pricing_TPT_Quote_Line_Number__c);  
                }    
                if(quoteLineIdSet.size() > 0){
                    quoteLinesMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id,Pricing_Last_Approved_Date_dt__c,Pricing_Original_Submitted_Date_dt__c,Pricing_Last_Submitted_Date_dt__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIdSet]);
                }                                     
                //construct old status List and Ids to retrieve old case status changes to update the business hours
                for (Pricing_Quote_Line_Status_Age__c statusChange: tptList) {
                    if(quoteLinesMap.containsKey(statusChange.Pricing_TPT_Quote_Line_Number__c)){
                        SBQQ__QuoteLine__c qli = quoteLinesMap.get(statusChange.Pricing_TPT_Quote_Line_Number__c);
                        if(isIntegration && substatus==Label.Pricing_Tender_QuoteLine_Status_Approved){
                            DateTime apprdDt = (qli.Pricing_Last_Approved_Date_dt__c==null? Datetime.now() : qli.Pricing_Last_Approved_Date_dt__c);
                            if(qli.Pricing_Original_Submitted_Date_dt__c!=null){                                
                                Decimal firstResponseInMillSecs = calculateStatusAge(qli.Pricing_Original_Submitted_Date_dt__c, apprdDt);
                                statusChange.Pricing_First_SubmissionToResponse_Time__c = (firstResponseInMillSecs/(60*60*1000));
                            }   
                            if(qli.Pricing_Last_Submitted_Date_dt__c!=null){
                                Decimal lastResponseInMillSecs = calculateStatusAge(qli.Pricing_Last_Submitted_Date_dt__c, apprdDt);
                                statusChange.Pricing_Last_Submission_to_Response_Time__c = (lastResponseInMillSecs/(60*60*1000));
                            }                        
                        }else{
                            if(qli.Pricing_Last_Approved_Date_dt__c!=null && qli.Pricing_Original_Submitted_Date_dt__c!=null){
                                Decimal firstResponseInMillSecs = calculateStatusAge(qli.Pricing_Original_Submitted_Date_dt__c, qli.Pricing_Last_Approved_Date_dt__c);
                                statusChange.Pricing_First_SubmissionToResponse_Time__c = (firstResponseInMillSecs/(60*60*1000));
                            }   
                            if(qli.Pricing_Last_Approved_Date_dt__c!=null && qli.Pricing_Last_Submitted_Date_dt__c!=null){
                                Decimal lastResponseInMillSecs = calculateStatusAge(qli.Pricing_Last_Submitted_Date_dt__c, qli.Pricing_Last_Approved_Date_dt__c);
                                statusChange.Pricing_Last_Submission_to_Response_Time__c = (lastResponseInMillSecs/(60*60*1000));
                            }                     
                        }
                    }
                    oldStatusSet.add(statusChange.Pricing_TPT_Status_From__c);                   
                    quoteLineIdToTPTMap.put(statusChange.Pricing_TPT_Quote_Line_Number__c,statusChange);
                }
                
                //Query for Previous TPT
                if (!quoteLineIdSet.isEmpty() && !oldStatusSet.isEmpty()) {             
                    String currentUserRole = isIntegration ? userRole : (UserInfo.getName()==Label.Pricing_Integration_User? 'DPM' : getUserRole());

                    List<Pricing_Quote_Line_Status_Age__c> oldTPTList = new List<Pricing_Quote_Line_Status_Age__c>();
                    Map<String,Pricing_Quote_Line_Status_Age__c> aggreagateTPTMap = new Map<String,Pricing_Quote_Line_Status_Age__c>();
                    for(Pricing_Quote_Line_Status_Age__c oldStatusChange : [SELECT Id, Name,Pricing_TPT_Status_From__c,Pricing_TPT_Status_Name__c,Pricing_TPT_Aggregate_Role_Time__c, Pricing_TPT_Role_Aggregate_cb__c,Pricing_TPT_User_Role__c,Pricing_TPT_Set_Time__c,Pricing_TPT_Change_Time__c,Pricing_TPT_To_Stage_Actor_Nm__c,Pricing_TPT_Quote_Line_Number__c,Pricing_TPT_Change_Request_QuoteLine_cb__c,Revision_QuoteLine__c from Pricing_Quote_Line_Status_Age__c 
                                                                            where (Pricing_TPT_Quote_Line_Number__c IN : quoteLineIdSet 
                                                                                   and (Pricing_TPT_Change_Time__c = null or (Pricing_TPT_Role_Aggregate_cb__c = true and Pricing_TPT_User_Role__c =: currentUserRole)))]) {
                                                                                       if(oldStatusChange.Pricing_TPT_Change_Time__c == null){
                                                                                           oldTPTList.add(oldStatusChange);
                                                                                       }
                                                                                       if(oldStatusChange.Pricing_TPT_Role_Aggregate_cb__c && oldStatusChange.Pricing_TPT_User_Role__c == currentUserRole){
                                                                                           aggreagateTPTMap.put(oldStatusChange.Pricing_TPT_Quote_Line_Number__c,oldStatusChange);
                                                                                       }
                                                                                   }
                    
                    Set<Id> tptIdSet = new Set<Id>();
                    for (Pricing_Quote_Line_Status_Age__c oldStatusChange : oldTPTList) {
                        if(!tptIdSet.contains(oldStatusChange.Id) && (!quoteLineIdToTPTMap.containsKey(oldStatusChange.Id) || (oldStatusChange.Pricing_TPT_Status_From__c != oldStatusChange.Pricing_TPT_Status_Name__c)) ){
                            tptIdset.add(oldStatusChange.Id);
                            oldStatusChange.Pricing_TPT_Change_Time__c = isIntegration ? integrationTime : Datetime.now();
                            //Convert the difference to milliseconds
                            //Double milliseconds = (oldStatusChange.Pricing_TPT_Change_Time__c.getTime() - oldStatusChange.Pricing_TPT_Set_Time__c.getTime());
                            Decimal milliseconds = calculateStatusAge(oldStatusChange.Pricing_TPT_Set_Time__c, oldStatusChange.Pricing_TPT_Change_Time__c);
                            //oldStatusChange.Pricing_TPT_Status_Time__c = (Decimal.valueOf(milliseconds)).Divide((60*60*1000), 2);
                            oldStatusChange.Pricing_TPT_Status_Time__c = (milliseconds).Divide((60*60*1000), 2);
                            if(aggreagateTPTMap.containsKey(oldStatusChange.Pricing_TPT_Quote_Line_Number__c)){
                                oldStatusChange.Pricing_TPT_Aggregate_Role_Time__c = aggreagateTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c).Pricing_TPT_Aggregate_Role_Time__c + oldStatusChange.Pricing_TPT_Status_Time__c;
                                
                                oldStatusChange.Pricing_TPT_Role_Aggregate_cb__c = true; 
                                aggreagateTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c).Pricing_TPT_Role_Aggregate_cb__c = false;
                                tptList.add(aggreagateTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c));                                
                            }else{
                                oldStatusChange.Pricing_TPT_Aggregate_Role_Time__c = oldStatusChange.Pricing_TPT_Status_Time__c;
                                oldStatusChange.Pricing_TPT_Role_Aggregate_cb__c = true;
                            }
                            oldStatusChange.Pricing_TPT_Age__c = getAge(milliseconds);
                            oldStatusChange.Pricing_TPT_Current_QL_Approver__c = isIntegration ? actorName : UserInfo.getName();
                            oldStatusChange.Pricing_TPT_User_Role__c  = isIntegration ? userRole : currentUserRole;
                            oldStatusChange.Pricing_TPT_To_Stage_Actor_Nm__c = isIntegration ? actorName : UserInfo.getName();
                            
                            if(quoteLineIdToTPTMap.containsKey(oldStatusChange.Pricing_TPT_Quote_Line_Number__c)){
                                oldStatusChange.Pricing_TPT_Status_Name__c = quoteLineIdToTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c).Pricing_TPT_Status_From__c;
                                quoteLineIdToTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c).Pricing_TPT_Change_Request_QuoteLine_cb__c = oldStatusChange.Pricing_TPT_Change_Request_QuoteLine_cb__c;
                                if(oldStatusChange.Revision_QuoteLine__c){
                                    quoteLineIdToTPTMap.get(oldStatusChange.Pricing_TPT_Quote_Line_Number__c).Revision_QuoteLine__c = oldStatusChange.Revision_QuoteLine__c;
                                }
                            }
                            if(!tptList.contains(oldStatusChange)){
                                tptList.add(oldStatusChange);                            
                            }                            
                        }
                    }
                }
                //Create new TPT 
                if(!tptList.isEmpty()){
                    return tptList;
                }
            }catch(exception ex) {
                Pricing_Tender_Utility.logError(ex);
                return new Set<Pricing_Quote_Line_Status_Age__c>();
            }
    }                                                                              return new Set<Pricing_Quote_Line_Status_Age__c>();
    }

    //Method to check if Non-Latin characters are present in Text fields
    public static void validateQLTextFieldsForLatinChars(SBQQ__QuoteLine__c quoteLine,Map < id, SBQQ__QuoteLine__c > oldMap, Boolean isInsert){
        try{
            Set<String> quoteLineTextFields = new Set < String > ((Label.Pricing_Tender_Quote_Line_Text_Fields).split(':'));
            if(quoteLineTextFields.size()>0){
                for(String field:quoteLineTextFields){
                    String fieldValue = '';
                    if(isInsert){
                        if(quoteLine.get(field) != null){
                            fieldValue = (String)quoteLine.get(field);
                        }
                    }else{
                        if((String)quoteLine.get(field) != (String)oldMap.get(quoteLine.Id).get(field)){
                            fieldValue = (String)quoteLine.get(field);
                        }
                    }
                    if(!String.isEmpty(fieldValue) && Pricing_Tender_Utility.validateNonLatinChars(fieldValue)){
                            quoteLine.addError(field,Label.Pricing_Non_Latin_Char_Validation_Error);
                    }
                }
            }
        }catch(exception ex){Pricing_Tender_Utility.logError(ex);}  
    }
    
    /**
    * @description Method to validate the Write in Paired CPU
    * @author Sreekanth Kodathala | 08-19-2024 
    * @param SBQQ__QuoteLine__c quoteLine 
    * @param Id writeInPairedCPUId 
    **/
    public static void validateWriteInPairedCPU(SBQQ__QuoteLine__c quoteLine, Id writeInPairedCPUId){
        if(quoteLine.Pricing_Paired_CPU_Nm__c == writeInPairedCPUId && String.isBlank(quoteLine.Pricing_Write_In_Paired_CPU_Nm__c)){
            quoteLine.addError(Label.Pricing_Write_In_Paired_CPU_Mandatory);
        }
        else if(quoteLine.Pricing_Paired_CPU_Nm__c != writeInPairedCPUId && !String.isBlank(quoteLine.Pricing_Write_In_Paired_CPU_Nm__c)){
            quoteLine.addError(Label.Pricing_Write_In_Paired_CPU_Restrict);
        }
    }

    public static Decimal calculateStatusAge(DateTime startDateTime, DateTime endDateTime){    
        Decimal timeDiff = 0;  
        try{            
            Decimal oneDayinMilliSecs = (24*60*60*1000);
            timeDiff = endDateTime.getTime() - startDateTime.getTime();
            
            String startDay  = startDateTime.format('EEEE');
            String endDay  = endDateTime.format('EEEE');        
            
            Date startDate = date.newinstance(startDateTime.year(), startDateTime.month(), startDateTime.day());
            Date endDate = date.newinstance(endDateTime.year(), endDateTime.month(), endDateTime.day());
            
            startDate = startDate.toStartOfWeek();
            endDate = endDate.toStartOfWeek();
            
           
            
            integer weeksbetween = startDate.daysBetween(endDate)/7;
            
            if(weeksbetween > 0){
                timeDiff = (timeDiff - (weeksbetween * 2 * oneDayinMilliSecs));
                
                if(startDay == 'Saturday') {
                    timeDiff = timeDiff + oneDayinMilliSecs;
                }
                
                if(endDay == 'Sunday') {
                    timeDiff = timeDiff + oneDayinMilliSecs;
                }
            }
        }catch(exception ex) {Pricing_Tender_Utility.logError(ex);}
        return timeDiff;
    }  
    
    public static void generateQuoteLetter(List < SBQQ__QuoteLine__c > lstquoteLines, Map < id, SBQQ__QuoteLine__c > oldMap){
        Set<Id> quoteIds = new Set<Id>();
        
        for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
            if((quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote 
                && quoteLine.Pricing_Reference_Quote_Line_Nbr__c != null
                && quoteLine.Pricing_Status_Nm__c==Label.Pricing_Tender_QuoteLine_Status_Approved) 
                || ((quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote
                || String.isNotBlank(quoteLine.Pricing_Deal_RFQ_Id__c)
                || quoteLine.SBQQ__ProductName__c != Label.Pricing_Tender_Write_In_Product)
            && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c
            && (quoteLine.Pricing_Status_Nm__c==Label.Pricing_Tender_QuoteLine_Status_Approved 
            || quoteLine.Pricing_Status_Nm__c==Label.Pricing_Tender_QuoteLine_Status_Rejected
            || (oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview 
                && quoteLine.Pricing_Status_Nm__c==Label.Pricing_Tender_QuoteLine_Status_Won)
            ))
            ){
                quoteIds.add(quoteLine.SBQQ__Quote__c);
            }
        }
        
        Boolean isCalculateRun = false;
        if(quoteIds.size() > 0){
            Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c quoteLine : [SELECT id,SBQQ__Quote__c,Pricing_Save_After_Calculation_cb__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.Pricing_Auto_generate_Quote_Letter__c=TRUE AND SBQQ__Quote__c IN :quoteIds]){
                quoteLineMap.put(quoteLine.id,quoteLine);
            }
            if(quoteLineMap.size() > 0){
                String quoteIdsStr = '';
                Id quoteId;
                for(Id quoteLineId : quoteLineMap.keySet()){
                    if(quoteLineMap.get(quoteLineId).Pricing_Save_After_Calculation_cb__c == false){ //SBQQ__Uncalculated__c
                        isCalculateRun = true;
                        quoteId = quoteLineMap.get(quoteLineId).SBQQ__Quote__c;
                        break;
                    }
                    else{
                        quoteIdsStr = String.isEmpty(quoteIdsStr) ? String.valueOf(quoteLineMap.get(quoteLineId).SBQQ__Quote__c) : quoteIdsStr+','+String.valueOf(quoteLineMap.get(quoteLineId).SBQQ__Quote__c);
                    }
                }
                if(isCalculateRun  && quoteId != null){
                    runCalculatorService(quoteId);
                }
                if(!String.isEmpty(quoteIdsStr)){
                    publishQuoteLetter(quoteIdsStr);
                }                
            }
        }
    }
    public static void publishQuoteLetter(String quoteIdsStr){   
        Database.SaveResult result = EventBus.publish(new Pricing_Quote_Letter_Event__e(
                    Pricing_QuoteIds_Txt__c = quoteIdsStr,
                    Pricing_Action_Nm__c = Label.Pricing_Generate_QuoteLetter_Action));
    }
    public static void runCalculatorService(Id quoteId){
        List<SBQQ__Quote__c> quotesList  = [SELECT id,SBQQ__LastCalculatedOn__c FROM SBQQ__Quote__c WHERE Pricing_Auto_generate_Quote_Letter__c=TRUE AND Id  =: quoteId];
        if(quotesList.size() > 0){
            QuoteModel quoteModel = new QuoteModel();
            quoteModel.record = quotesList[0];
            Pricing_QuoteCalculator calculator = new Pricing_QuoteCalculator();
            if(!Test.isRunningTest()){
                calculator.calculate(quoteModel, 'Pricing_CalculatorCallBack');
            }
        }
    }
    
    //Method to get list of product Ids based on program type
    public static Map<String, List<Id>> validateQuoteLineProduct (Map<String, List<Id>> prdTypeNewProductListMap) {
        Map<String, List<Id>> quoteLineTypeProductIdsMap = new Map<String, List<Id>>();//product Type ==> List of product Ids
        Map<String, String> quoteLineTypeProductQueryMap = new Map<String, String>();//product Type ==> product SOQL
        
        //List<Pricing_Dynamic_Data_Table__mdt> productTypeMetadataList = Pricing_Dynamic_Data_Table__mdt.getall().values();
        List<Pricing_Dynamic_Data_Table__mdt> productTypeMetadataList = [SELECT Id, Pricing_Query__c, Pricing_Record_Type_Pkl__c, Pricing_Where_Clause__c FROM Pricing_Dynamic_Data_Table__mdt WHERE Pricing_Record_Type_Pkl__c IN : prdTypeNewProductListMap.keySet()];
        if(productTypeMetadataList.size() > 0) {
            for(Pricing_Dynamic_Data_Table__mdt mdt : productTypeMetadataList ) {
                if(String.isNotBlank(mdt.Pricing_Query__c) && String.isNotBlank(mdt.Pricing_Where_Clause__c)) {
                    String query =  mdt.Pricing_Query__c + ' ' +mdt.Pricing_Where_Clause__c;
                    if(!quoteLineTypeProductQueryMap.containsKey(mdt.Pricing_Record_Type_Pkl__c)) {
                        quoteLineTypeProductQueryMap.put(mdt.Pricing_Record_Type_Pkl__c, query);
                    }
                }
            }
        }
        if(!quoteLineTypeProductQueryMap.isEmpty() && !prdTypeNewProductListMap.isEmpty()) {
            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_SSD_Quote) && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_SSD_Quote)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_SSD_Quote, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_SSD_Quote), prdTypeNewProductListMap.get(Label.Pricing_Tender_SSD_Quote));
            }  
            
            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_PMem_Quote) && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_PMem_Quote)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_PMem_Quote, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_PMem_Quote), prdTypeNewProductListMap.get(Label.Pricing_Tender_PMem_Quote));
            }
            
            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_NIC_Quote) && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_NIC_Quote)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_NIC_Quote, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_NIC_Quote), prdTypeNewProductListMap.get(Label.Pricing_Tender_NIC_Quote));
            }
            
            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_Standard_QuoteLine) && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_Standard_QuoteLine)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_Standard_QuoteLine, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_Standard_QuoteLine), prdTypeNewProductListMap.get(Label.Pricing_Tender_Standard_QuoteLine));
            }
            
            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_Small_Volume_Quote)  && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_Small_Volume_Quote)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_Small_Volume_Quote, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_Small_Volume_Quote), prdTypeNewProductListMap.get(Label.Pricing_Tender_Small_Volume_Quote));
            }
            
            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_CCG_Quote) && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_CCG_Quote)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_CCG_Quote, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_CCG_Quote), prdTypeNewProductListMap.get(Label.Pricing_Tender_CCG_Quote));
            }

            if(prdTypeNewProductListMap.containsKey(Label.Pricing_Tender_DataCenter_GPU) && quoteLineTypeProductQueryMap.containsKey(Label.Pricing_Tender_DataCenter_GPU)) {
                quoteLineTypeProductIdsMap = getQuoteLineProduct(Label.Pricing_Tender_DataCenter_GPU, quoteLineTypeProductQueryMap.get(Label.Pricing_Tender_DataCenter_GPU), prdTypeNewProductListMap.get(Label.Pricing_Tender_DataCenter_GPU));
            }
        }
        return quoteLineTypeProductIdsMap;
    }
    
    //Method to get list of product Ids based on program type
    public static Map<String, List<Id>> getQuoteLineProduct(String type, String productQuery, List<Id> prdList) {
        Map<String, List<Id>> qlProductListMap = new Map<String, List<Id>>();//product Type ==> List of product Ids
        List<Product2> productList = new List<Product2>();
        String query1 = productQuery + ' AND Id IN : prdList';
        productList = Database.query(query1);

        if(productList.size() > 0) {
            for(Product2 prd : productList) {
                if(!qlProductListMap.containsKey(type)) {
                    qlProductListMap.put(type, new List<Id>{prd.Id});
                } else {
                    qlProductListMap.get(type).add(prd.Id);
                }
            }
        }
        return qlProductListMap;
    }
    
    //method to validate the product mismatch on insert and update of Quote Line
    public static void validateProductMismatch(List<SBQQ__QuoteLine__c> lstquoteLines, boolean isInsert, Map<Id, SBQQ__QuoteLine__c> oldMap) {
        try {
            if(lstquoteLines!= null && !lstquoteLines.isEmpty()) {
                Map<String, List<Id>> productTypeProductIdsMap = new Map<String, List<Id>>();
                Map<String, List<Id>> productTypeNewProductIdMap = new Map<String, List<String>>();
                
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                    if((isInsert || (!isInsert && oldMap.get(quoteLine.id).Pricing_Product_Nm__c != quoteLine.Pricing_Product_Nm__c)) && quoteLine.Pricing_Product_Nm__c != null) {
                        if(!productTypeNewProductIdMap.containsKey(quoteLine.Pricing_Program_Type_Nm__c)) {
                            productTypeNewProductIdMap.put(quoteLine.Pricing_Program_Type_Nm__c, new List<String>{quoteLine.Pricing_Product_Nm__c});
                        } else {
                            productTypeNewProductIdMap.get(quoteLine.Pricing_Program_Type_Nm__c).add(quoteLine.Pricing_Product_Nm__c);
                        }
                    }              
                }
                
                if(!productTypeNewProductIdMap.isEmpty()) {
                    productTypeProductIdsMap = validateQuoteLineProduct(productTypeNewProductIdMap);
                }
                
                for(SBQQ__QuoteLine__c quoteLine: lstquoteLines) {
                    if((isInsert || (!isInsert && oldMap.get(quoteLine.id).Pricing_Product_Nm__c != quoteLine.Pricing_Product_Nm__c)) 
                       && !(isInsert && quoteLine.Pricing_New_Change_Request_cb__c) && quoteLine.Pricing_Product_Nm__c != null && (productTypeProductIdsMap.isEmpty() || ( productTypeProductIdsMap.get(quoteLine.Pricing_Program_Type_Nm__c) != null && !(productTypeProductIdsMap.get(quoteLine.Pricing_Program_Type_Nm__c)).contains(quoteLine.Pricing_Product_Nm__c)))) {
                           string label = Label.Pricing_IQR_Product_Mismatch_Error.replace('<quote type>', quoteLine.Pricing_Program_Type_Nm__c);
                           quoteLine.addError(label);
                       }
                }
            }
        } catch (exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }
    }
    
    /**
    * @description method to update QuoteLine Records from Flow  
    * @author Accenture | 04-25-2022 
    * @param quoteLineList 
    **/
    @InvocableMethod(label = 'updateQuoteLineRecords' description = 'To update QuoteLine Records')
    public static void updateQuoteLineRecords(List<List<SBQQ__QuoteLine__c>> quoteLineList){
        List<SBQQ__QuoteLine__c> qliListtoUpdate = new List<SBQQ__QuoteLine__c>();
        Set<Id> quoteIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> newQuoteLineList = new List<SBQQ__QuoteLine__c>();
        try{
            if(!quoteLineList.isEmpty()){
                for(List<SBQQ__QuoteLine__c> qliList: quoteLineList){
                    for(SBQQ__QuoteLine__c qli: qliList){
                        quoteIds.add(qli.SBQQ__Quote__c);
                        if(!newQuoteLineList.contains(qli)){
                            newQuoteLineList.add(qli);
                        }
                    }
                }

                Map<String, SBQQ__Quote__c> quoteIdtoRecMap =new Map<String, SBQQ__Quote__c>( [SELECT Id,Name,Pricing_End_Customer_Country_Nm__c,Pricing_Customer_Nm__c,SBQQ__Account__r.Name,SBQQ__PrimaryContact__c,Pricing_Project_Name_Nm__c,
                                                            Pricing_Region_Nm__c,SBQQ__SalesRep__c,Pricing_Server_Deal_Type_Nm__c,Pricing_Market_Segment_values_Nm__c, Pricing_Program_Type_Nm__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds]);

                for(SBQQ__QuoteLine__c qli: newQuoteLineList){
                    qli.Pricing_End_Customer_Country__c = quoteIdtoRecMap.get(qli.SBQQ__Quote__c).Pricing_End_Customer_Country_Nm__c;
                    qli.Pricing_End_Customer_Nm__c = quoteIdtoRecMap.get(qli.SBQQ__Quote__c).Pricing_Customer_Nm__c;
                    qli.Pricing_OEM_Account_Nm__c = quoteIdtoRecMap.get(qli.SBQQ__Quote__c).SBQQ__Account__r.Name;
                    qli.Pricing_Primary_Contact_Nm__c = quoteIdtoRecMap.get(qli.SBQQ__Quote__c).SBQQ__PrimaryContact__c;
                    qli.Pricing_Project_Nm__c = quoteIdtoRecMap.get(qli.SBQQ__Quote__c).Pricing_Project_Name_Nm__c;
                    qli.Pricing_Region_Nm__c = quoteIdtoRecMap.get(qli.SBQQ__Quote__c).Pricing_Region_Nm__c;
                    qli.Pricing_Sales_Rep__c = quoteIdtoRecMap.get(qli.SBQQ__Quote__c).SBQQ__SalesRep__c;
                    qli.Pricing_Server_Deal_Type_Nm__c = quoteIdtoRecMap.get(qli.SBQQ__Quote__c).Pricing_Server_Deal_Type_Nm__c;
                    if(quoteIdtoRecMap.get(qli.SBQQ__Quote__c).Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || quoteIdtoRecMap.get(qli.SBQQ__Quote__c).Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
                        qli.Pricing_Market_Segment_values_Nm__c = quoteIdtoRecMap.get(qli.SBQQ__Quote__c).Pricing_Market_Segment_values_Nm__c;
                    }
                    qliListtoUpdate.add(qli);
                }

                if(!qliListtoUpdate.isEmpty()){
                    isStopTriggerFromFlow = true;
                    SBQQ.TriggerControl.disable();
                    Database.SaveResult[] quoteLineUpdatedRecords = Database.update(qliListtoUpdate, false);
                    SBQQ.TriggerControl.enable();
                    isStopTriggerFromFlow = false;
                }
            }
        }
        catch(Exception ex){
            Pricing_Tender_Utility.logError(ex);
        }
    }
    
    /**
    * @description : Method to Auto Populate Meet comp Price when status of QuoteLine is moved from Draft => PFIR ,PIFR =>PFIR 
    * @author Divya Gangasaram | 02-20-2023 
    * @param SBQQ__QuoteLine__c quoteLine 
    * @param id competitorProductId 
    **/
    public static void autoPopulateMeetComp(List<SBQQ__QuoteLine__c> lstquoteLines , Map<id,Pricing_Competitor_Product_Price__c> compProductIdMap){
        for(SBQQ__QuoteLine__c quoteLine : lstquoteLines){
            if(isAutoPopulateMeetComp.containsKey(quoteLine.Id) && isAutoPopulateMeetComp.get(quoteLine.Id) && compProductIdMap.get(quoteLine.Pricing_Competetor_Product__c) != null && quoteLine.Pricing_Meet_Comp_Price_Amt__c != compProductIdMap.get(quoteLine.Pricing_Competetor_Product__c).Pricing_Final_Meet_Comp_Price__c && quoteLine.Pricing_Competetor_Product__c == compProductIdMap.get(quoteLine.Pricing_Competetor_Product__c).Pricing_Competitor_Product__c && quoteLine.Pricing_Server_Deal_Type_Nm__c == compProductIdMap.get(quoteLine.Pricing_Competetor_Product__c).Pricing_Application_Nm__c){
                quoteLine.Pricing_Meet_Comp_Price_Amt__c = compProductIdMap.get(quoteLine.Pricing_Competetor_Product__c).Pricing_Final_Meet_Comp_Price__c;
            }            
        }
    }
    
    /**
    * @description: Method to make flag true,add QL competitor product ids to set of ids and QL region to List of string. 
    * @author Divya Gangasaram | 03-07-2023 
    * @param SBQQ__QuoteLine__c quoteLine 
    * @param List<String> programType 
    * @param List<String> regionList 
    * @param String application 
    * @param String region 
    **/
    public static void getCompetitorProductIdsRegions(SBQQ__QuoteLine__c quoteLine,List<String> programType, List<String> regionList,String application,String region,String endCustomerName){
        isAutoPopulateMeetComp.put(quoteLine.Id, false);
        if(checkforAuotoPopLogic(quoteLine, application, endCustomerName)) {
            isAutoPopulateMeetComp.put(quoteLine.Id, true);
            competitorProductsIds.add(quoteLine.Pricing_Competetor_Product__c);
            regionList.add(region);
            applicationSetforAutoPop.add(application);
    }
    
}

/***********************************************************Refactored Methods************************************************************/    

/**
* @description return set of fields from layout
* @author Subhanku | 03-16-2023 
* @return Set<String> 
**/
public static Set<String> getFieldsFromLayout(){
    Set<String> fieldList = new Set<String>();
    List < Metadata.Metadata > layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List < String > {
        'SBQQ__QuoteLine__c-Pricing Tender Quote Line Layout - Int - Edit'
            });
    Metadata.Layout layoutMd = (Metadata.Layout) layouts.get(0);
    for(Metadata.LayoutSection section: layoutMd.layoutSections) {
        for(Metadata.LayoutColumn column: section.layoutColumns) {
            if(column.layoutItems != null) {
                for(Metadata.LayoutItem item: column.layoutItems) {
                    if(item.field != null) {
                        fieldList.add(item.field);
                    }
                }
            }
        }
    }
    return fieldList;
}

    /**
    * @description create quote line statsu map
    * @author Subhanku | 03-16-2023 
    * @param Map<String Decimal> quoteLineNumberToStatusMap 
    **/
    public static void getQuoteLineStatusMap(Map<String,Decimal> quoteLineNumberToStatusMap){
        quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_Draft,10); 
        quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_Rejected,20);
        quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview,30);
        quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview,40);
        quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_Approved,50);
        quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_Lost,60);
        quoteLineNumberToStatusMap.put(Label.Pricing_Tender_QuoteLine_Status_Won,70);
    }

    /**
    * @description method to check current user Persona based in PS name
    * @author Subhanku | 03-16-2023 
    * @param String permissionSetName 
    * @return Boolean 
    **/
    public static Boolean checkCurrentUserPs(String permissionSetName){
        Boolean containsPs = false;
        for(PermissionSetAssignment permissionSetAssignmentRec: currentUser.PermissionSetAssignments) {
            if(permissionSetAssignmentRec.PermissionSet.Name == permissionSetName) {
                containsPs = true;
                break;
            }
        }
        return containsPs;
    }

    /**
    * @description method where approved fields are populated in RPM insert
    * @author Subhanku | 03-16-2023 
    * @param SBQQ__QuoteLine__c quoteLine 
    * @param Map<Id SBQQ__Quote__c> quoteDtls 
    **/
    public static void populateApprovedFields(SBQQ__QuoteLine__c quoteLine,Map < Id, SBQQ__Quote__c > quoteDtls,List<String> programType,Id writeInProdId){
        quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        quoteLine.RecordTypeId = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? svdSubmitRecordType : standardSubmitRecordType;

        //flag to populate Approved fields using AI
        Boolean isAutoAI = checkforAuotoPopLogic(quoteLine, quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Server_Deal_Type_Nm__c, quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_End_Customer_Name__c) && 
                            quoteLine.SBQQ__Product__c != writeInProdId &&  quoteLine.Pricing_Tentative_ECAP_Price_Amt__c == null ? true : false;
        //Revert Status fix
        quoteLine.Pricing_Original_Submitted_By_Id__c = currentUser.Id;
        quoteLine.Pricing_Original_Submitted_Date_dt__c = Datetime.now();
        quoteLine.Pricing_Last_Submitted_Date_dt__c = Datetime.now();
        quoteLine.Pricing_Last_Submitted_By_Id__c = currentUser.Id;
        //US750594
        quoteLine.Pricing_Approved_Unit_Qty__c = (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_SSD_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_NIC_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ) ? quoteLine.Pricing_Total_Volume_Qty__c : quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU ? quoteLine.Pricing_No_of_GPUs__c : quoteLine.Pricing_Unit_Qty__c;
        quoteLine.Pricing_ECAP_Price_Amt__c = null;//quoteLine.Pricing_Req_Discounted_Unit_Price__c; //US817773
        
        quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = null;
        quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = null;
        
        quoteLine.Pricing_Approved_Start_Date_Dt__c = isAutoAI ? null : quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_ShipmentStDate_Dt__c;
        quoteLine.Pricing_Approved_End_Date_Dt__c = isAutoAI ? null : quoteLine.Pricing_End_Date_dt__c;
        quoteLine.Pricing_Billing_End_Date_Dt__c = isAutoAI ? null : quoteLine.Pricing_End_Date_dt__c;
        quoteLine.Pricing_Billing_Start_Date_Dt__c = isAutoAI ? null : quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_ShipmentStDate_Dt__c;
    }

    /**
    * @description method where twin fields get populated in insert
    * @author Subhanku | 03-16-2023 
    * @param SBQQ__QuoteLine__c quoteLine 
    * @param Map<Id SBQQ__Quote__c> quoteDtls 
    **/
    public static void populateTwinFields(SBQQ__QuoteLine__c quoteLine,Map < Id, SBQQ__Quote__c > quoteDtls){
        //field required for Quote Letter
        quoteLine.SBQQ__ListPrice__c = 0;//field required for Quote Letter
        quoteLine.SBQQ__SpecialPrice__c = 0;//field required for Quote Letter
        quoteLine.SBQQ__Quantity__c = 1;//field required for Quote Letter
        quoteLine.SBQQ__NetPrice__c = 0;//field required for Quote Letter
        quoteLine.Pricing_Sales_Rep__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).SBQQ__SalesRep__c;
        quoteLine.Pricing_Region_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Region_Nm__c;
        quoteLine.Pricing_Server_Deal_Type_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Server_Deal_Type_Nm__c;
        quoteLine.Pricing_End_Customer_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Customer_Nm__c;
        quoteLine.Pricing_OEM_Account_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).SBQQ__Account__r.Name;
        quoteLine.Pricing_Project_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Project_Name_Nm__c;
        quoteLine.Pricing_End_Customer_Country__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_End_Customer_Country_Nm__c;
        quoteLine.Pricing_Primary_Contact_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).SBQQ__PrimaryContact__c;

        // TWC1972-4021 : Update QuoteLine Market Segment From Quote Market Segment 
        if(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
            quoteLine.Pricing_Market_Segment_values_Nm__c = quoteDtls.get(quoteLine.SBQQ__Quote__c).Pricing_Market_Segment_values_Nm__c;
        }
    }

    /**
    * @description method to create map of pending FSE Approval
    * @author Subhanku | 03-16-2023 
    * @param Set<Id> quoteLineIds 
    * @param Map<Id Set<Id>> qliToMultipleFSEUserIdMap 
    **/
    public static void getPendingApprovalFSEMap(Set < Id > quoteLineIds,Map<Id,Set<Id>> qliToMultipleFSEUserIdMap){
        for(ProcessInstanceWorkitem workItem : [SELECT p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,
                                                p.ProcessInstanceId, p.OriginalActorId, p.Id FROM ProcessInstanceWorkitem p
                                                WHERE p.ProcessInstance.TargetObjectId IN : quoteLineIds AND ProcessInstance.Status = 'Pending']){
                                                    if(!qliToMultipleFSEUserIdMap.containsKey(workItem.ProcessInstance.TargetObjectId))
                                                        qliToMultipleFSEUserIdMap.put(workItem.ProcessInstance.TargetObjectId,new Set<Id>{workItem.OriginalActorId});
                                                    else
                                                        qliToMultipleFSEUserIdMap.get(workItem.ProcessInstance.TargetObjectId).add(workItem.OriginalActorId);
                                                }
    }
    
    /**
    * @description logic for status flip flop issue
    * @author Subhanku | 03-16-2023 
    * @param SBQQ__QuoteLine__c quoteLine 
    * @param Map<id SBQQ__QuoteLine__c> oldMap 
    **/
    public static void statusRevertFix(SBQQ__QuoteLine__c quoteLine,Map < id, SBQQ__QuoteLine__c > oldMap){
        //revert status fix Approved ==> PFIR
        if((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) {
            quoteLine.Pricing_Status_Nm__c =  Label.Pricing_Tender_QuoteLine_Status_Approved;
            //Duplicate filelds populating
            quoteLine.Pricing_Approved_Start_Date_Dt__c = quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c = oldMap.get(quoteLine.Id).Pricing_Approved_Start_Date_Dt__c;
            quoteLine.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_Approved_End_Date_Dup_Dt__c = oldMap.get(quoteLine.Id).Pricing_Approved_End_Date_Dt__c;
            quoteLine.Pricing_Approved_Unit_Qty__c = quoteLine.Pricing_Approved_Unit_Dup_Qty__c = oldMap.get(quoteLine.Id).Pricing_Approved_Unit_Qty__c;
            quoteLine.Pricing_ECAP_Price_Amt__c = quoteLine.Pricing_ECAP_Price_Dup_Amt__c = oldMap.get(quoteLine.Id).Pricing_ECAP_Price_Amt__c;
            quoteLine.Pricing_Billing_Start_Date_Dt__c = oldMap.get(quoteLine.Id).Pricing_Billing_Start_Date_Dt__c;
            quoteLine.Pricing_Billing_End_Date_Dt__c = oldMap.get(quoteLine.Id).Pricing_Billing_End_Date_Dt__c;
            quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = oldMap.get(quoteLine.Id).Pricing_Revised_Pricing_Start_Date_dt__c;
            quoteLine.Pricing_Deal_RFQ_Id__c = quoteLine.Pricing_Deal_RFQ_Dup_Id__c = oldMap.get(quoteLine.Id).Pricing_Deal_RFQ_Id__c;
            quoteLine.Pricing_Deal_RFQ_Status_Nm__c = oldMap.get(quoteLine.Id).Pricing_Deal_RFQ_Status_Nm__c;
            quoteLine.Pricing_Last_Approved_Date_dt__c = DateTime.now();
        }

        //revert status fix Won ==> PFIR
        if((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) {
            quoteLine.Pricing_Status_Nm__c =  Label.Pricing_Tender_QuoteLine_Status_Won;
            //Duplicate filelds populating
            quoteLine.Pricing_Approved_Start_Date_Dt__c = quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c = oldMap.get(quoteLine.Id).Pricing_Approved_Start_Date_Dt__c;
            quoteLine.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_Approved_End_Date_Dup_Dt__c = oldMap.get(quoteLine.Id).Pricing_Approved_End_Date_Dt__c;
            quoteLine.Pricing_Approved_Unit_Qty__c = quoteLine.Pricing_Approved_Unit_Dup_Qty__c = oldMap.get(quoteLine.Id).Pricing_Approved_Unit_Qty__c;
            quoteLine.Pricing_ECAP_Price_Amt__c = quoteLine.Pricing_ECAP_Price_Dup_Amt__c = oldMap.get(quoteLine.Id).Pricing_ECAP_Price_Amt__c;
            quoteLine.Pricing_Billing_Start_Date_Dt__c = oldMap.get(quoteLine.Id).Pricing_Billing_Start_Date_Dt__c;
            quoteLine.Pricing_Billing_End_Date_Dt__c = oldMap.get(quoteLine.Id).Pricing_Billing_End_Date_Dt__c;
            quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = oldMap.get(quoteLine.Id).Pricing_Revised_Pricing_Start_Date_dt__c;
            quoteLine.Pricing_Deal_RFQ_Id__c = quoteLine.Pricing_Deal_RFQ_Dup_Id__c = oldMap.get(quoteLine.Id).Pricing_Deal_RFQ_Id__c;
            quoteLine.Pricing_Deal_RFQ_Status_Nm__c = oldMap.get(quoteLine.Id).Pricing_Deal_RFQ_Status_Nm__c;
            quoteLine.Pricing_Last_Approved_Date_dt__c = DateTime.now();
        }

         //revert status fix Cancelled ==> Approved
        if((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Cancelled && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) {
            quoteLine.Pricing_Status_Nm__c =  Label.Pricing_Tender_QuoteLine_Status_Cancelled;
            //Duplicate filelds populating
            quoteLine.Pricing_Approved_Start_Date_Dt__c = quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c = oldMap.get(quoteLine.Id).Pricing_Approved_Start_Date_Dt__c;
            quoteLine.Pricing_Approved_End_Date_Dt__c = quoteLine.Pricing_Approved_End_Date_Dup_Dt__c = oldMap.get(quoteLine.Id).Pricing_Approved_End_Date_Dt__c;
            quoteLine.Pricing_Approved_Unit_Qty__c = quoteLine.Pricing_Approved_Unit_Dup_Qty__c = oldMap.get(quoteLine.Id).Pricing_Approved_Unit_Qty__c;
            quoteLine.Pricing_ECAP_Price_Amt__c = quoteLine.Pricing_ECAP_Price_Dup_Amt__c = oldMap.get(quoteLine.Id).Pricing_ECAP_Price_Amt__c;
            quoteLine.Pricing_Billing_Start_Date_Dt__c = oldMap.get(quoteLine.Id).Pricing_Billing_Start_Date_Dt__c;
            quoteLine.Pricing_Billing_End_Date_Dt__c = oldMap.get(quoteLine.Id).Pricing_Billing_End_Date_Dt__c;
            quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = quoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = oldMap.get(quoteLine.Id).Pricing_Revised_Pricing_Start_Date_dt__c;
            quoteLine.Pricing_Deal_RFQ_Id__c = quoteLine.Pricing_Deal_RFQ_Dup_Id__c = oldMap.get(quoteLine.Id).Pricing_Deal_RFQ_Id__c;
            quoteLine.Pricing_Deal_RFQ_Status_Nm__c = oldMap.get(quoteLine.Id).Pricing_Deal_RFQ_Status_Nm__c;
            quoteLine.Pricing_Last_Approved_Date_dt__c = DateTime.now();
        }
        
        //revert fix pricing manager value ==> null
        if((oldMap.get(quoteLine.Id).Pricing_Manager__c != quoteLine.Pricing_Manager__c) && oldMap.get(quoteLine.Id).Pricing_Manager__c != null && quoteLine.Pricing_Manager__c == null) {
            quoteLine.Pricing_Manager__c = oldMap.get(quoteLine.Id).Pricing_Manager__c;
        }
        
        //revert status fix Rejected ==> PFIR
        if((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) {
            quoteLine.Pricing_Status_Nm__c =  Label.Pricing_Tender_QuoteLine_Status_Rejected;
        }
    
        //revert status fix Won ==> Approved
        if((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved) {
            quoteLine.Pricing_Status_Nm__c =  Label.Pricing_Tender_QuoteLine_Status_Won;
        }

         //revert status fix Revised ==> Approved
         if((oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c) && oldMap.get(quoteLine.Id).Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Revised && (quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Approved || quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won)) {
            quoteLine.Pricing_Status_Nm__c =  Label.Pricing_Tender_QuoteLine_Status_Revised;
        }
    }

    /**
    * @description Method to verify condition for auto population of meetcomp and auto AI
    * @author Sandeep Chamate | 09-06-2023 
    * @param quoteLine - quoteline record to be checked
    * @param application - application of the quoteline record
    * @param endCustomerName - End customer name of quoteline record
    * @return Boolean 
    **/
    /* Condition used -- Pricing_TenderProgramTypeForMeetCompAutoPopulate label should contain quoteline type and Pricing_TenderApplicationForMeetcompAutoPopulate label should contain application and
    if quoteline type is not Data Center Xeon CPU  set value to true else if quotelinetype is Data Center Xweon CPU and quantity <= 100 and if application is not CSP set to true else
    if application is not CSP and end Customer is not part of Custom setting Pricing_CSP_End_Customer_Exclusion_List__c set it to true else set it to false*/
    public static Boolean checkforAuotoPopLogic(SBQQ__QuoteLine__c quoteLine, String application, String endCustomerName){
        Set<String> excludedEndCustomerNameSet = new Set<String>();
        excludedEndCustomerNameSet = Pricing_CSP_End_Customer_Exclusion_List__c.getAll().keySet();
        Boolean isAutoPop = !isAutoApproveReject && Label.Pricing_TenderProgramTypeForMeetCompAutoPopulate.split(',').contains(quoteLine.Pricing_Program_Type_Nm__c) && Label.Pricing_TenderApplicationForMeetcompAutoPopulate.split(',').contains(application) && 
                            (quoteLine.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_Standard_QuoteLine || (quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine && quoteLine.Pricing_Unit_Qty__c <= Decimal.ValueOf(Label.Pricing_Quantity) && 
                            (application != 'CSP' || (application == 'CSP' && !excludedEndCustomerNameSet.contains(endCustomerName))))) ? true : 
                            false;

        return isAutoPop;
    }

    /**
    * @description :Method whcih retruns true if looged in user has API Permission set.
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 11-05-2024 
    * @return Boolean 
    **/
    public static Boolean currentUserHasAPIPs(){
        List<String> apiUserPermissionSets = label.Pricing_IQR_API_UserPermissionSets.split(',');
        boolean hasAPIPermissionSet = false;
                
        for (PermissionSetAssignment psa : currentUser.PermissionSetAssignments) {
            if(apiUserPermissionSets.contains(psa.PermissionSet.Name)){
                hasAPIPermissionSet = true;
            }
        }
        return hasAPIPermissionSet;
    }
    
    /*****************************************************************************************************************************************
    Method Name:        handleAIIntegrationForPricing
    Description:        To invoke method for Pricing Application AI Integration
    @Added By:          Sinduja - 30-April-2026
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    public static void handleAIIntegrationForPricing(List<SBQQ__QuoteLine__c> lstquoteLines, Map<Id, SBQQ__QuoteLine__c> oldMap,Boolean isInsert) {
        try {
            // Recursion control - exit if AI integration has already run in this transaction
            if(hasAIIntegrationRun) {
                return;
            }
            
            List<Id> quoteLineIdsForAI = new List<Id>();
            
            // Check for status change to 'Pending Further Intel Review'
            for(SBQQ__QuoteLine__c quoteLine : lstquoteLines) {
                Boolean notEligibleForPricing = Pricing_QuoteLineController.eligibleForPricingSupportCheck(quoteLine);
                if(isInsert){
                    if(quoteLine.Pricing_New_Change_Request_cb__c == false && quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && !notEligibleForPricing) {
                        quoteLineIdsForAI.add(quoteLine.Id);
                    }
                }
                else if(oldMap.get(quoteLine.Id).Pricing_Status_Nm__c != quoteLine.Pricing_Status_Nm__c && quoteLine.Pricing_New_Change_Request_cb__c == false &&
                   quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview && !notEligibleForPricing) {
                    quoteLineIdsForAI.add(quoteLine.Id);
                }
            }
            
            // Call AI Integration if we have quote lines to process
            if(!quoteLineIdsForAI.isEmpty()) {
                // Set the flag to prevent recursion
                hasAIIntegrationRun = true;
                
                system.debug('Inside populateJSON calling method');
                Pricing_Application_Agent_AI_Integration.populateJSON(quoteLineIdsForAI, new Map<String,Integer>());
            }
            
        } catch(Exception e) {
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Core_Message__c = 'Error in handleAIIntegrationForPricing method', Core_Details__c = e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString(), Core_Origin__c='handleAIIntegrationForPricing', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'IQR');
            insert logEntry;
        }
    }
}