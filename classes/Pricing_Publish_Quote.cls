/**
* @description       : 
* @author            : Accenture
* @group             : 
* @last modified on  : 11-10-2026
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_Publish_Quote { 
    public static Id userProfile {get;set;}
    public static Id userId {get;set;}
    public static String quoteId {get; set;}
    public static String status {get;set;}
    public static String messageResult {get;set;}
    public static Boolean user_has_permission {get;set;}
    public static Boolean renderSuccess {get;set;}
    public static Boolean isOnload {get;set;}
    public static Map<Id,Set<Id>> quoteIdsQTMIdsMap = new Map<Id,Set<Id>>();
    public static Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
    public static Id svdQLISubmittedRT = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Submitted);
    public static Id standardQLISubmittedRT = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
    public static Map<String,String> quoteCreationAllowed = new Map<String,String>();
    public static Boolean isApproveWithoutApprovalRec = false;

    // USED TO INSTANTIATE THE VARIABLES ON LOAD
    public Pricing_Publish_Quote() {
        quoteId = ApexPages.currentPage().getParameters().get('id');
        status = ApexPages.currentPage().getParameters().get('status');
    }
    
    // WRAPPER CLASS TO PASS THE CORRECT VALUES TO THE Pricing_Publish_Quote LIGHTNING COMPONENT
    public class globalVariables {
        @AuraEnabled public Set<String> messageNotification {get;set;}
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public Boolean isOnLoad {get;set;}
        @AuraEnabled public Boolean hasPermission {get;set;}
    }
    
    // MAIN METHOD THAT HANDLES ALL THE LOGIC FOR QUOTE/QUOTE LINE SUBMISSION
    @AuraEnabled
    public static globalVariables PublishTenderQuote(String recId) {
        renderSuccess = true;
        user_has_permission = false;
        isOnload = true;
        // VARIABLE USED TO GET USER PROFILE ID
        userProfile = Userinfo.getProfileId();
        // VARIABLE USED TO GET USER ID
        userId = UserInfo.getUserId();
        String quoteId;
        String OemSubmissionErrorMesssage;
        String retMsg = null;
        boolean isOEMSubmitted = false;
        Set<Id> quoteLineIds = new Set<Id>();
        Map<String,String> errorMap = new Map<String,String>();
        List<SBQQ__QuoteLine__c> quoteLineToUpdate = new List<SBQQ__QuoteLine__c> ();
        Map<Id,Set<Id>> quoteIdQTMIdMap = new Map<Id,Set<Id>>();
        List<SBQQ__QuoteLine__c> lstQuoteLine = new List<SBQQ__QuoteLine__c>();
        String recordId = recId.split(';')[0];
        String objectName = ((id)recordId).getSObjectType().getDescribe().getName();
        lstQuoteLine = recId.contains(';')?[SELECT Id, Name ,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,Pricing_Is_Sanctioned__c,SBQQ__Quote__r.Pricing_Overall_Quote_Quantity_CPU__c,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__r.SBQQ__Account__c,
                                            Pricing_Intel_Discount_Pct__c ,Pricing_OEM_Discount_Pct__c ,Pricing_End_Date_dt__c,SBQQ__Quote__c,Pricing_Original_Submitted_By_Id__c,Pricing_Original_Submitted_Date_dt__c,Pricing_Competetor_Product__r.Pricing_Active_cb__c,
                                            SBQQ__Quote__r.Pricing_Overall_Quote_Quantity__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,(SELECT Id,Name,Pricing_Quote_Line__c FROM Performance_Metrics__r)
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE id IN :recId.split(';')]:(objectName == 'SBQQ__Quote__c')?[SELECT Id, Name ,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,SBQQ__Quote__c,Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__r.SBQQ__Account__c,
                                                                                                             Pricing_Intel_Discount_Pct__c ,Pricing_OEM_Discount_Pct__c ,Pricing_End_Date_dt__c,Pricing_Original_Submitted_By_Id__c,Pricing_Original_Submitted_Date_dt__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,Pricing_Competetor_Product__r.Pricing_Active_cb__c,
                                                                                                             Pricing_OEM_Standard_Unit_Price_Amt__c,Pricing_Req_Discounted_Unit_Price__c,Pricing_Additional_OEM_Discount_Amt__c,Pricing_Is_Sanctioned__c,SBQQ__Quote__r.Pricing_Overall_Quote_Quantity_CPU__c,
                                                                                                             SBQQ__Quote__r.Pricing_Overall_Quote_Quantity__c,(SELECT Id,Name,Pricing_Quote_Line__c FROM Performance_Metrics__r)
                                                                                                             FROM SBQQ__QuoteLine__c 
                                                                                                             WHERE SBQQ__Quote__c =: recId]:[SELECT Id, Name ,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,Pricing_Is_Sanctioned__c,SBQQ__Quote__r.Pricing_Overall_Quote_Quantity_CPU__c,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__r.SBQQ__Account__c,
                                                                                                                                               Pricing_Intel_Discount_Pct__c ,Pricing_OEM_Discount_Pct__c ,Pricing_End_Date_dt__c,SBQQ__Quote__c,Pricing_Original_Submitted_By_Id__c,Pricing_Original_Submitted_Date_dt__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,Pricing_Competetor_Product__r.Pricing_Active_cb__c,
                                                                                                                                               SBQQ__Quote__r.Pricing_Overall_Quote_Quantity__c,(SELECT Id,Name,Pricing_Quote_Line__c FROM Performance_Metrics__r)
                                                                                                                                               FROM SBQQ__QuoteLine__c 
                                                                                                                                               WHERE id =: recId];
        quoteId = (recId.contains(';') || objectName == 'SBQQ__QuoteLine__c')?lstQuoteLine[0].SBQQ__Quote__c:recId;
        List<SBQQ__Quote__c> lstQuote = [SELECT Id, Name,Pricing_Bid_Dt__c,Pricing_Intel_Response_Requested_By_Date__c, SBQQ__Status__c,RecordTypeId, RecordType.Name,Pricing_Overall_Quote_Quantity_CPU__c,
                                        Pricing_Intel_Sales_Rep_Email_Txt__c, SBQQ__Account__c, Pricing_Program_Type_Nm__c,Pricing_ShipmentStDate_Dt__c,Pricing_ShipmentEndDate_Dt__c,Pricing_Overall_Quote_Quantity__c 
                                        FROM SBQQ__Quote__c WHERE Id =: quoteId];
        List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Question__c 
                                                FROM Pricing_Comments__c WHERE Pricing_Quote__c =: quoteId 
                                                AND recordtypeid=:commentRecordTypeId];                                         
        List<PermissionSetAssignment> lstcurrentUserPerSet =new List<PermissionSetAssignment>([SELECT Id, PermissionSet.Name, AssigneeId
                                                                                               FROM PermissionSetAssignment
                                                                                               WHERE AssigneeId =: userId]);
        // STORE CURRENT USER'S PERMISSION SETS IN A LIST
        boolean hasAPIPermissionSet = false;
        List<String> apiUserPermissionSets = label.Pricing_IQR_API_UserPermissionSets.split(',');
        List<String> lstPermissionSets = new List<String>();
        for (PermissionSetAssignment psa : lstcurrentUserPerSet) {
            lstPermissionSets.add(psa.PermissionSet.Name);
            if(apiUserPermissionSets.contains(psa.PermissionSet.Name)){
                hasAPIPermissionSet = true;
            }
        }
        globalVariables globalVar = new globalVariables();
        globalVar.messageNotification = new Set<String>();
        SBQQ__Quote__c quoteRec = lstQuote[0];
        Set<Id> quoteIdSet = new Set<Id>();
        Boolean isValidQtmFse = true;
        
        if(lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_TenderPartner) || 
           lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_TenderUser) ||
           lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator) || hasAPIPermissionSet
          ){
              //Perform Quote fields validation before Quote submission
              performQuoteFieldValidations(recId, lstQuoteLine, quoteRec, objectName, lstComment, globalVar);
              quoteCreationAllowed = Pricing_Manage_Small_Volume_Deal.capSizeCheckToCreation(new Set<String>{quoteRec.SBQQ__Account__c},false);
              if(!lstQuoteLine.isEmpty()){
                  for(SBQQ__QuoteLine__c quoteLineRec : lstQuoteLine) {
                      if(quoteLineRec.Pricing_Is_Sanctioned__c == false) {
                          quoteLineIds.add(quoteLineRec.Id);
                          quoteIdSet.add(quoteLineRec.SBQQ__Quote__c);
                      }
                      //Perform Quote Line fields validation before Quote/Quote Line submission
                      performQuoteLineFieldValidations(recId, lstQuoteLine, quoteLineRec, objectName, errorMap, globalVar);
                      if(renderSuccess){
                          // ONLY QUOTES WITH QUOTE LINES CAN BE SUBMITTED WHEN THE QUOTE STATUS IS DRAFT
                          if(quoteRec.SBQQ__Status__c == Label.Pricing_Tender_Quote_Status_Draft || recId == quoteLineRec.Id) {
                              // ONLY EXTERNAL USERS WITH TENDER PARTNER PERMISSION SETS ARE ALLOWED TO SUBMIT A QUOTE
                              if(lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_TenderPartner) ||
                                 lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_PricingTenderPartnerAdministrator) || hasAPIPermissionSet
                                ) {
                                    isOEMSubmitted = true;
                                    quoteLineRec.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview;
                                    //Populate global variable message notification to display the success message
                                    populateSuccessMsg(globalVar, quoteLineRec, quoteLineToUpdate);
                                } else {
                                    if(lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_TenderUser)){
                                        // INTERNAL TENDER USERS ARE ALLOWED TO SUBMIT A QUOTE
                                        quoteLineRec.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
                                        // To populate Sales Rep Approver
                                        quoteLineRec.Pricing_Sales_Rep_Approver__c =  UserInfo.getUserId();
                                        populateSuccessMsg(globalVar, quoteLineRec, quoteLineToUpdate);
                                    }
                                }
                              if(quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                                  quoteLineRec.RecordTypeId = svdQLISubmittedRT;
                              }else{
                                  quoteLineRec.RecordTypeId = standardQLISubmittedRT;
                              }
                              quoteLineRec.Pricing_Ready_for_Review_cb__c = false;
                              //Populate Last Submitted By and Last Submitted Date QLI fields post submission
                              populateQLISubmittedActor(quoteLineRec);
                          }
                          else{
                              //If Quote is Already Submitted display the message
                              messageResult = Label.Pricing_Tender_Quote_Submitted_Message;
                              //Populate global variable message notification to display the error message
                              populateGlobalVarErrorMsg(globalVar);
                          }
                      }
                      
                  }
                  //Validate all FSE from the Quote Team 
                  if(quoteIdSet.size() > 0){
                      quoteIdsQTMIdsMap = quoteIdQTMIdMap = validateQtmFse(quoteIdSet);
                      //If all FSEs are invalid throw the error
                      if(quoteIdQTMIdMap.size() == 0){
                          isValidQtmFse = false;
                          messageResult = Label.Pricing_Tender_Quote_Sales_Rep_Error_Message;
                          populateGlobalVarErrorMsg(globalVar);
                      }
                      
                  }                                                      
              }
              else {
                  // ERROR WHEN A QUOTE SUBMITTED DOES NOT HAVE RELATED QUOTE LINES
                  messageResult = Label.Pricing_Tender_QuoteLine_Mandatory_Submit_Error_Message;
                  populateGlobalVarErrorMsg(globalVar);
              }
              if(!renderSuccess){
                  globalVar.messageNotification.remove('Successfully submitted!');
                  globalVar.messageNotification.addAll(errorMap.values());                   
              } 
          }
        else{
            // ERROR WHEN A USER DOES NOT HAVE THE PERMISSION TO CLICK A BUTTON
            OemSubmissionErrorMesssage = objectName == 'SBQQ__Quote__c' ? Label.Pricing_Tender_Quote_Standard_OEM_Submit_Error_Message : Label.Pricing_Tender_QuoteLine_Standard_OEM_Submit_Error_Message;
            messageResult = (lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_TenderDrafter) || lstPermissionSets.contains(Label.Pricing_Tender_PermissionSets_TenderDrafterLimited)) ? OemSubmissionErrorMesssage :  Label.Pricing_Tender_No_Access_Error_Message;
            //messageResult = Label.Pricing_Tender_No_Access_Error_Message;
            populateGlobalVarErrorMsg(globalVar);
        }            
        // PASS THE VALUES TO THE VARIABLES IN THE WRAPPER CLASS
        if(renderSuccess){
            try{
                if(!quoteLineToUpdate.isEmpty()){
                    SBQQ.TriggerControl.disable();
                    update lstQuoteLine;
                    SBQQ.TriggerControl.enable();
                    //call submit for approval method here
                    if(isOEMSubmitted && isValidQtmFse){
                       if(!System.isBatch() && !System.isFuture()){
                       publishQuoteLinesToMultipleFSEFuture(quoteLineIds);
                       }
                    }                    
                }             
            }
            catch(Exception e){
                Pricing_Tender_Utility.logError(e);
                retMsg = Pricing_Tender_Utility.getExceptionMessage(e);
                globalVar.messageNotification.remove('Successfully submitted!');
                globalVar.messageNotification.add(retMsg);
                globalVar.isSuccess = false;
                return globalVar;
            }
        }
        globalVar.isSuccess = renderSuccess;
        globalVar.isOnLoad = isOnload;
        globalVar.hasPermission = user_has_permission;
        return globalVar;
    }
    
    /**
    * @description Method written to check for Quote Fields validations before Quote submission
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param String recId 
    * @param List<SBQQ__QuoteLine__c> lstQuoteLine 
    * @param SBQQ__Quote__c quoteRec 
    * @param String objectName 
    * @param List<Pricing_Comments__c> lstComment 
    * @param globalVariables globalVar 
    **/
    public static void performQuoteFieldValidations(String recId, List<SBQQ__QuoteLine__c> lstQuoteLine, SBQQ__Quote__c quoteRec, String objectName, List<Pricing_Comments__c> lstComment, globalVariables globalVar){
            if(objectName == 'SBQQ__Quote__c'){
                if(quoteRec.SBQQ__Status__c == Label.Pricing_Tender_Quote_Status_Draft  && (quoteRec.Pricing_Bid_Dt__c <= date.today() + 1)) {                 
                    messageResult = Label.Pricing_Tender_Quote_ProposalDueDate_Submit_Error_Message;
                    populateGlobalVarErrorMsg(globalVar);
                }
                if(quoteRec.SBQQ__Status__c == Label.Pricing_Tender_Quote_Status_Draft  && (quoteRec.Pricing_Intel_Response_Requested_By_Date__c == null)) {                 
                    messageResult = Label.Pricing_Tender_Intel_Response_Date_Blank_Error_Submission;
                    populateGlobalVarErrorMsg(globalVar);
                }
                if(quoteRec.SBQQ__Status__c == Label.Pricing_Tender_Quote_Status_Draft  && (quoteRec.Pricing_Intel_Response_Requested_By_Date__c <= date.today() + 1)) {                 
                    messageResult = Label.Pricing_Tender_Quote_IntelResponseReqDate_Submit_Error_Message;
                    populateGlobalVarErrorMsg(globalVar);
                }
                if(quoteRec.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_Small_Volume_Quote && quoteCommentsValidation(lstComment)){
                    messageResult = Label.Pricing_Tender_Quote_Comment_Submit_Error_Message;
                    populateGlobalVarErrorMsg(globalVar);
                }
                if(quoteRec.SBQQ__Status__c == Label.Pricing_Tender_Quote_Status_Draft  && (quoteRec.Pricing_ShipmentStDate_Dt__c == quoteRec.Pricing_ShipmentEndDate_Dt__c)) {                 
                    messageResult = Label.Pricing_Tender_Quote_StartDate_EndDate_Submit_Error_Message;
                    populateGlobalVarErrorMsg(globalVar);
                }
            }
    }
    
    /**
    * @description Method written to check for Quote Line Fields validations before Quote/Quote Line submission
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param String recId 
    * @param List<SBQQ__QuoteLine__c> lstQuoteLine 
    * @param SBQQ__QuoteLine__c quoteLineRec 
    * @param String objectName 
    * @param Map<String String> errorMap 
    * @param globalVariables globalVar 
    **/
    public static void performQuoteLineFieldValidations(String recId, List<SBQQ__QuoteLine__c> lstQuoteLine, SBQQ__QuoteLine__c quoteLineRec, String objectName, Map<String, String> errorMap, globalVariables globalVar){
            if(quoteLineRec.Performance_Metrics__r.IsEmpty() && (quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine || quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote)){
                messageResult = Label.Pricing_Tender_QuoteLine_Performance_Metric_Submit_Error_Message;
                //Populate Error Map to be used to display the error message
                populateErrorMap(errorMap, quoteLineRec);
            }
            if((quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine || quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote || quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote)&& quoteLineRec.Pricing_Competetor_Product__c != null && !quoteLineRec.Pricing_Competetor_Product__r.Pricing_Active_cb__c){
                messageResult = Label.Pricing_Competitor_Products_Check_Error_Message;
                //Populate Error Map to be used to display the error message
                populateErrorMap(errorMap, quoteLineRec);
            }
            if(objectName == 'SBQQ__Quote__c' && (((quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine) && (quoteLineRec.Pricing_OEM_Standard_Unit_Price_Amt__c == null || quoteLineRec.Pricing_Req_Discounted_Unit_Price__c == null || quoteLineRec.Pricing_Additional_OEM_Discount_Amt__c == null))
                                                           || ((quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_PMem_Quote) && (quoteLineRec.Pricing_OEM_Standard_Unit_Price_Amt__c == null || quoteLineRec.Pricing_Req_Discounted_Unit_Price__c == null))
                                                           || quoteLineRec.Pricing_Req_Discounted_Unit_Price__c == null)){
                                                               messageResult = quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine ? Label.Pricing_Mandatory_Submission_Fields_Error_Message
                                                                   : (quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_PMem_Quote) ? Label.Pricing_Mandatory_Submission_Fields_Error_Message_Client 
                                                                       : Label.Pricing_Mandatory_Submission_Fields_Error_Message_DPG;
                                                               populateErrorMap(errorMap, quoteLineRec);
                                                           }
            if(quoteLineRec.Pricing_End_Date_dt__c < date.today()){
                //Prevent user from submitting if End date is in past
                messageResult = Label.Pricing_Tender_QuoteLine_End_Date_Submit_Error_Message;
                populateErrorMap(errorMap, quoteLineRec);                
            }                 
            if((quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine || quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_DataCenter_GPU) && (quoteLineRec.Pricing_Intel_Discount_Pct__c > 100 ||
                                                                                                      quoteLineRec.Pricing_Intel_Discount_Pct__c < 0)){  
                                                                                                          //Prevent user from setting intel discount less than 0 or greater than 100
                                                                                                          messageResult = Label.Pricing_Tender_QuoteLine_INTEL_Discount_Submit_Error_Message;
                                                                                                          populateErrorMap(errorMap, quoteLineRec);
                                                                                                      }
            if(quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine && (quoteLineRec.Pricing_OEM_Discount_Pct__c > 100 ||
                                                                                                      quoteLineRec.Pricing_OEM_Discount_Pct__c < 0)){
                                                                                                          //prevent user from setting oem discount less than 0 or greater than 100
                                                                                                          messageResult = Label.Pricing_Tender_QuoteLine_OEM_Discount_Submit_Error_Message;
                                                                                                          populateErrorMap(errorMap, quoteLineRec);
                                                                                                      }
            //Allow submission of quotelines only if overall quantity is between 50 and 250
        if(quoteLineRec.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote && (quoteLineRec.SBQQ__Quote__r.Pricing_Overall_Quote_Quantity__c < Integer.valueOf(Label.Pricing_Overall_Quantity_Min) || quoteLineRec.SBQQ__Quote__r.Pricing_Overall_Quote_Quantity__c > Integer.valueOf(Label.Pricing_Overall_Quantity_Max))){
                String quantityError = Label.Pricing_SVD_Quote_Quantity_Submission_Error;
                messageResult = quantityError.replace('{{QuoteQuantity}}',String.valueOf(quoteLineRec.SBQQ__Quote__r.Pricing_Overall_Quote_Quantity__c));
                populateGlobalVarErrorMsg(globalVar);
            }
            if(lstQuoteLine[0].Pricing_Original_Submitted_Date_dt__c == null && lstQuoteLine[0].SBQQ__Quote__r.SBQQ__Status__c == Label.Pricing_Tender_Quote_Status_Draft){
                QuoteBusinessLogic.isQuotFirstSubmission = true;
            }
            //on Quote First submission if overall qty is less than min qty then if quota got completed will not allow quote submission and throw error.
            if(lstQuoteLine[0].Pricing_Original_Submitted_Date_dt__c == null && lstQuoteLine[0].SBQQ__Quote__r.SBQQ__Status__c == Label.Pricing_Tender_Quote_Status_Draft && ((quoteLineRec.SBQQ__Quote__r.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote && quoteLineRec.SBQQ__Quote__r.Pricing_Overall_Quote_Quantity_CPU__c != 0 && quoteLineRec.SBQQ__Quote__r.Pricing_Overall_Quote_Quantity_CPU__c < Integer.valueOf(Label.Pricing_DataCenterCPU_Overall_Quantity_Min)) || (quoteLineRec.SBQQ__Quote__r.Pricing_Program_Type_Nm__c == 'Client' && quoteLineRec.SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c != 'Consumer Retail Pull' && quoteLineRec.SBQQ__Quote__r.Pricing_Overall_Quote_Quantity__c < Integer.valueOf(Label.Pricing_Client_Overall_Quantity_Min)))){
                //QuoteBusinessLogic.isVolumeExceptionCheck = true;
                //Map<String,String> quoteCreationAllowed = new Map<String,String>(Pricing_Manage_Small_Volume_Deal.capSizeCheckToCreation(new Set<String>{quoteLineRec.SBQQ__Quote__r.SBQQ__Account__c},false)); 

                if(!quoteCreationAllowed.isEmpty()){
                    QuoteBusinessLogic.isVolumeExceptionCheck = quoteCreationAllowed.containsKey(quoteLineRec.SBQQ__Quote__r.Pricing_Program_Type_Nm__c) ? true : false;
                    if((quoteLineRec.SBQQ__Quote__r.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote || quoteLineRec.SBQQ__Quote__r.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote) && quoteCreationAllowed.containsKey(quoteLineRec.SBQQ__Quote__r.Pricing_Program_Type_Nm__c) && quoteCreationAllowed.get(quoteLineRec.SBQQ__Quote__r.Pricing_Program_Type_Nm__c).split(':')[0] == 'false'){
                        String quantityError = Label.Pricing_QuotaException_Error;
                        messageResult = quoteLineRec.SBQQ__Quote__r.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote ? quantityError.replace('{{QuoteQuantity}}',String.valueOf(quoteLineRec.SBQQ__Quote__r.Pricing_Overall_Quote_Quantity__c)).replace('{{ExceptionQuantity}}',String.valueOf(Label.Pricing_Client_Overall_Quantity_Min)) : quantityError.replace('{{QuoteQuantity}}',String.valueOf(quoteLineRec.SBQQ__Quote__r.Pricing_Overall_Quote_Quantity_CPU__c)).replace('{{ExceptionQuantity}}',String.valueOf(Label.Pricing_DataCenterCPU_Overall_Quantity_Min));
                    populateGlobalVarErrorMsg(globalVar);
                    }
                }
            }  
    }
    
    /**
    * @description Method written to populate the Last Submitted By and Last Submitted Date for a Quote Line after submission
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param SBQQ__QuoteLine__c quoteLineRec 
    **/
    public static void populateQLISubmittedActor(SBQQ__QuoteLine__c quoteLineRec){
        //TPT
        if(quoteLineRec.Pricing_Original_Submitted_By_Id__c == null){
            quoteLineRec.Pricing_Original_Submitted_By_Id__c = UserInfo.getUserId();
        }
        if(quoteLineRec.Pricing_Original_Submitted_Date_dt__c == null){
            quoteLineRec.Pricing_Original_Submitted_Date_dt__c = Datetime.now();
        }
        quoteLineRec.Pricing_Last_Submitted_Date_dt__c = Datetime.now();
        quoteLineRec.Pricing_Last_Submitted_By_Id__c = UserInfo.getUserId();
    }
    
    /**
    * @description Method written to populate the error map used for showing the error message based on the Quote Line fields validation error message
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param Map<String String> errorMap 
    * @param SBQQ__QuoteLine__c quoteLineRec 
    **/
    public static void populateErrorMap(Map<String, String> errorMap, SBQQ__QuoteLine__c quoteLineRec){
        if(!errorMap.containsKey(messageResult)){
            errorMap.put(messageResult,messageResult+': '+quoteLineRec.Pricing_Quote_Line_Number__c );
        }
        else
        {
            errorMap.put(messageResult,errorMap.get(messageResult)+','+quoteLineRec.Pricing_Quote_Line_Number__c    );  
        }
        renderSuccess = false;
    }
    
    /**
    * @description Method written to populate the success message post the submission of Quote/Quote Line
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param globalVariables globalVar 
    * @param SBQQ__QuoteLine__c quoteLineRec 
    * @param List<SBQQ__QuoteLine__c> quoteLineToUpdate 
    **/
    public static void populateSuccessMsg(globalVariables globalVar, SBQQ__QuoteLine__c quoteLineRec, List<SBQQ__QuoteLine__c> quoteLineToUpdate){
        user_has_permission = true; 
        renderSuccess = true;
        messageResult = 'Successfully submitted!';
        globalVar.messageNotification.add(messageResult);
        quoteLineToUpdate.add(quoteLineRec);
    }
    
    /**
    * @description Method written to form and populate the validation error messages post the submission of Quote/Quote Line
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param globalVariables globalVar 
    **/
    public static void populateGlobalVarErrorMsg(globalVariables globalVar){
        renderSuccess = false;
        globalVar.messageNotification.add(messageResult);
    }
    
    /**
    * @description Method written to perform the Quote Comments Validation before submission of Quote/Quote Line
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param List<Pricing_Comments__c> lstComment 
    * @return Boolean 
    **/
    public static Boolean quoteCommentsValidation(List<Pricing_Comments__c> lstComment){
        Boolean isError = false;
        if(lstComment != null && !lstComment.isEmpty()){
            for(Pricing_Comments__c cmnt : lstComment){
                if(cmnt.Pricing_Required_Ind__c && cmnt.Pricing_Answer__c == null){   
                    //prevent user if Answer is not updated                 
                    isError = true;
                }     
            } 
        }
        else {
            isError = false;
        }
        return isError;
    }
    
    /**
    * @description Method written to validate the Sales Rep on the Quote
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param SBQQ__Quote__c quote 
    * @return Boolean 
    **/
    public static Boolean quoteSalesRepValidation(SBQQ__Quote__c quote){
        Boolean isError = false;
        Set<String> oemEmailIds = new Set<String>();
        Map<Id,Set<String>> accountIdToSalesRepEmailMap = new Map<Id,Set<String>>();
        Map<String, PermissionSetAssignment> salesRepAssignment = new Map<String, PermissionSetAssignment>();
        Map<Id,Set<String>> accountToValidEmailMap = new Map<Id,Set<String>>();
        if(quote != null){
            if(!String.isBlank(quote.Pricing_Intel_Sales_Rep_Email_Txt__c)){
                oemEmailIds.add(quote.Pricing_Intel_Sales_Rep_Email_Txt__c);
                if(quote.SBQQ__Account__c != null){
                    if(!accountIdToSalesRepEmailMap.containsKey(quote.SBQQ__Account__c)){
                        accountIdToSalesRepEmailMap.put(quote.SBQQ__Account__c,new Set<String>{quote.Pricing_Intel_Sales_Rep_Email_Txt__c});
                    }
                }
                if(!oemEmailIds.isEmpty()) {              
                    accountToValidEmailMap = QuoteBusinessLogic.getSalesrepMap(oemEmailIds,accountIdToSalesRepEmailMap, salesRepAssignment);
                }
                if(accountToValidEmailMap.containsKey(quote.SBQQ__Account__c) && 
                   accountToValidEmailMap.get(quote.SBQQ__Account__c).contains(quote.Pricing_Intel_Sales_Rep_Email_Txt__c) &&
                   salesRepAssignment.containsKey(quote.Pricing_Intel_Sales_Rep_Email_Txt__c)){
                       isError = false;                      
                   }
                else{
                    isError = true;
                }
            }
            else{
                isError = true;
            }
        }        
        return isError;
    }
    
    /**
* @description Method written to check if draft Quote Lines of a Quote are ready for review before they are submitted to Intel.
* @author Bharath Chandrashekar | 06-29-2022 
* @param sObjectId 
* @return globalVariables 
**/
    @AuraEnabled
    public static globalVariables submitForReview(String sObjectId){
        globalVariables globalVar = new globalVariables();
        globalVar.messageNotification = new Set<String>();
        List<SBQQ__QuoteLine__c> lstQuoteLine = new List<SBQQ__QuoteLine__c>();
        try{            
            lstQuoteLine = [SELECT Id,Name, Pricing_Quote_Line_Number__c, Pricing_Ready_for_Review_cb__c, Pricing_Program_Type_Nm__c, SBQQ__Quote__r.Pricing_Program_Type_Nm__c, (SELECT Id,Name,Pricing_Quote_Line__c FROM Performance_Metrics__r)
                            FROM SBQQ__QuoteLine__c 
                            WHERE SBQQ__Quote__c =: sObjectId AND Pricing_Status_Nm__c =: Label.Pricing_Tender_QuoteLine_Status_Draft
                            AND Pricing_Ready_for_Review_cb__c = false];
            
            List<Pricing_Comments__c> commentsFilled = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c 
                                                        FROM Pricing_Comments__c 
                                                        WHERE Pricing_Quote__c =: sObjectId and recordtypeid=:commentRecordTypeId];
            
            if(lstQuoteLine.size() > 0 && lstQuoteLine != null){
                if(lstQuoteLine[0].SBQQ__Quote__r.Pricing_Program_Type_Nm__c != Label.Pricing_Tender_Small_Volume_Quote && quoteCommentsValidation(commentsFilled)){
                    messageResult = Label.Pricing_Tender_Quote_Comment_Submit_Error_Message;
                    globalVar.messageNotification.add(messageResult);
                    globalVar.isSuccess = false;
                }
                messageResult = null;
                for (SBQQ__QuoteLine__c quoteLine: lstQuoteLine) {
                    quoteLine.Pricing_Ready_for_Review_cb__c = true;
                }
                update lstQuoteLine;
                messageResult = Label.Pricing_Tender_Quote_Ready_For_Review_Success_Message;
                globalVar.messageNotification.add(messageResult);
                globalVar.isSuccess = true;               
            }
            else{
                messageResult = Label.Pricing_Tender_Quote_Already_Reviewed_Message;
                globalVar.messageNotification.add(messageResult);
                globalVar.isSuccess = false;
            }
        }
        catch(Exception e)
        {
            Pricing_Tender_Utility.logError(e);
        }        
        return globalVar;
    }

    @future
    public static void publishQuoteLinesToMultipleFSEFuture(Set<Id> quoteLineIds){
            publishQuoteLinesToMultipleFSE(quoteLineIds);

    }
    
    /**
    * @description Method written to validate all the Quote Team FSE's and to call the Approval process
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param Set<Id> quoteLineIds 
    **/
    public static void publishQuoteLinesToMultipleFSE(Set<Id> quoteLineIds){
        Set<Id> quoteIds = new Set<Id>();
        List<Id> quoteIdlst = new List<Id>();
        try{
            if(quoteLineIds.size() > 0){
                List<SBQQ__QuoteLine__c> qliIds = new List<SBQQ__QuoteLine__c>();
                Map<Id,Id> quoteLinesQuoteIdMap = new Map<Id,Id>();
                Map<Id,Set<Id>> quoteQTMMap = new Map<Id,Set<Id>>();
                for(SBQQ__QuoteLine__c qli:[SELECT id,SBQQ__Quote__c,RecordType.Name,Pricing_Status_Nm__c 
                                            FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds]){
                                                quoteIds.add(qli.SBQQ__Quote__c);
                                                qliIds.add(qli);
                                                quoteLinesQuoteIdMap.put(qli.id, qli.SBQQ__Quote__c);
                                            }
                quoteQTMMap = quoteIdsQTMIdsMap.isEmpty()?validateQtmFse(quoteIds):quoteIdsQTMIdsMap;
                    if(quoteIds.size() > 0 && quoteQTMMap.size() > 0){
                        //Create the Approval Records only for valid FSE
                        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
                        for(Id quoteLineId : quoteLinesQuoteIdMap.keySet()){
                            if(quoteQTMMap.containsKey(quoteLinesQuoteIdMap.get(quoteLineId))){
                                for(Id salesRepId : quoteQTMMap.get(quoteLinesQuoteIdMap.get(quoteLineId))){
                                    //Class to submit a record for approval.
                                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                                    //Sets the comments to be added to the approval request
                                    approvalRequest.setComments('Submitting QuoteLine for approval.');
                                    //Sets the ID of the record to be submitted for approval. For example, it can specify
                                    // an account, contact, or custom object record.
                                    approvalRequest.setObjectId(quoteLineId);
                                    approvalRequest.setProcessDefinitionNameOrId('Pricing_Tender_Approval_Process');
                                    approvalRequest.setSkipEntryCriteria(true);
                                    //If the next step in your approval process is another Apex approval process, you specify
                                    // exactly one user ID as the next approver. If not, you cannot specify a user ID and this
                                    // method must be null
                                    approvalRequest.setNextApproverIds(new List<Id>{salesRepId});
                                    approvalRequestList.add(approvalRequest);
                                }
                            }
                        }//End of Quote Line Id For Loop
                        if(approvalRequestList.size() > 0 ){
                            SBQQ.TriggerControl.disable();
                            Approval.process(approvalRequestList);
                            //unlocking the locked quotelines from approval process
                            Approval.Unlock(qliIds, true);
                            // if(TriggerHandler.isActive('Send_Approval_Email_Notification_To_Bot')){
                            //     sendApprovalEmail(quoteLinesQuoteIdMap.keySet(),Label.Pricing_QuoteLineApprovalInitial_Notification);
                            // }
                        }
                    }
                    
            }
        } 
        catch(Exception e){
            SBQQ.TriggerControl.enable();
            //creating log entry with QuoteIds and retrying once.
            quoteIdlst.addAll(quoteIds);
            String exceptionRecordId = String.join(quoteIdlst, ',');
            Pricing_Tender_Utility.logErrorinLogObject(Pricing_Tender_Utility.getErrorDetails(e), e.getStackTraceString().substringBefore(':'),exceptionRecordId);
        }
        finally{
            SBQQ.TriggerControl.enable();
        } 
    }
    
    /**
    * @description Method written to invoke the Approval process to Approve or Reject Quote Line
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param Set<Id> sObjectIds 
    * @param String action 
    * @param String actionComments 
    **/
    public static void approveOrRejectQLI(Set<Id> sObjectIds, String action, String actionComments) {
       try{
            List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
            List<ProcessInstanceWorkitem> pwItemList = new List<ProcessInstanceWorkitem>();
            Map<Id,List<ProcessInstanceWorkitem>> qliPWItemMap = getProcessInstanceWorkItems(sObjectIds);
            if(qliPWItemMap.size() > 0){
                for(Id qliId : qliPWItemMap.keySet()){
                    pwItemList.addAll(qliPWItemMap.get(qliId));
                }
                for(ProcessInstanceWorkitem workItem : pwItemList){
                    if(workItem.ActorId == UserInfo.getUserId()){
                        approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, action, actionComments));
                    }
                    else
                    {
                        approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, action, null));
                    }
                }
                if(approvalRequestList.size() > 0){
                    Approval.process(approvalRequestList);
                }
            }else{
                if(isApproveWithoutApprovalRec){
                    List<SBQQ__QuoteLine__C> qlList = new List<SBQQ__QuoteLine__C>([select Id,Pricing_Status_Nm__c from SBQQ__QuoteLine__C where Id  In: sObjectIds]);
                    for(SBQQ__QuoteLine__c ql : qlList){
                        //status check should we add and only qtm user check
                        ql.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;       
                    }
                    SBQQ.TriggerControl.disable();
                    update qlList;
                    SBQQ.TriggerControl.enable();
                    isApproveWithoutApprovalRec = false; 
                }  
            }
        }catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }
    }

    /**
    * @description Method to approve/reject approval records for bulk action
    * @author Sandeep Chamate | 07-16-2023 
    * @param qliIdtoCommentMap - map of quoteline ids to aprroval/rejection comments
    * @param action - Approve/Reject action
    **/
    public static void setFSEActionOnQuoteLine(Map<Id, String> qliIdtoCommentMap, String action) {
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
        Map<Id,List<ProcessInstanceWorkitem>> qliPWItemMap = getProcessInstanceWorkItems(qliIdtoCommentMap.keySet());
        if(qliPWItemMap.size() > 0){
            
            for(Id qliId : qliPWItemMap.keySet()){
                for(ProcessInstanceWorkitem workItem : qliPWItemMap.get(qliId)){
                    if(workItem.ActorId == UserInfo.getUserId()){
                        String actionComments = qliIdtoCommentMap.get(qliId);
                        approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, action, actionComments));
                    }
                    else
                    {
                        approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, action, null));
                    }
                }
            }
            if(approvalRequestList.size() > 0){
                Approval.process(approvalRequestList);
            }
        }
    }
    
    //Future method to Approve/Reject approval records if done from Standard Approval
    @Future
    public static void approveOrRejectQLIFromStdApproval(Set<Id> sObjectIds, String action, String actionComments) { 
        try{
            approveOrRejectQLI(sObjectIds, action, actionComments);
        }catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        } 
    }
    
    //Method to Approve/Reject approval records 
    public static void setFSEActionOnQuoteLine(Set<Id> sObjectIds, String action, String actionComments, boolean isStandard) {
        if(isStandard){
            approveOrRejectQLIFromStdApproval(sObjectIds, action, actionComments);
        }else{
            approveOrRejectQLI(sObjectIds, action, actionComments);
        }
    }
    
    //Helper method get Process Instance Work Items which represents a user’s pending approval request.
    private static Map<Id,List<ProcessInstanceWorkitem>> getProcessInstanceWorkItems(Set<Id> objectIds) {
        Map<Id,List<ProcessInstanceWorkitem>> qliPWItem = new Map<Id,List<ProcessInstanceWorkitem>>();
        for(ProcessInstanceWorkitem witem : [SELECT Id,ActorId,ProcessInstance.TargetObjectId,OriginalActorId,ProcessInstance.Status FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :objectIds AND (ProcessInstance.Status IN ('Pending','Reassigned'))]){
            if(qliPWItem.containsKey(witem.ProcessInstance.TargetObjectId)){
                qliPWItem.get(witem.ProcessInstance.TargetObjectId).add(witem); 
            }else{
                qliPWItem.put(witem.ProcessInstance.TargetObjectId, new List<ProcessInstanceWorkitem>{witem});
            }
        }
        return qliPWItem;
    }
    
    //Helper method to create new Process Work Item Request record to process an approval request after it is submitted.
    private static Approval.ProcessWorkitemRequest createProcessWorkItemRequest(Id approvalStepId, String approvalAction, String commentFromApprover){
        Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
        result.setComments(commentFromApprover);
        result.setAction(approvalAction);
        result.setWorkitemId(approvalStepId);        
        return result;
    }
    
    /**
    * @description Method written to validate the Quote Team FSE's
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param Set<Id> quoteId 
    * @return Map<Id, Set<Id>> 
    **/
    public static Map<Id,Set<Id>> validateQtmFse(Set<Id> quoteId) {
        Map<Id,Set<Id>> quoteQTMMemberIdMap = new Map<Id,Set<Id>>();
        try{
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> allFSEIdSet = new Set<Id>();
            Map<Id,Set<Id>> accIdFseUserIdMap = new Map<Id,Set<Id>>();
            //Map<Id,Set<Id>> quoteQTMMemberIdMap = new Map<Id,Set<Id>>();
            Set<Id> fseWithPSSet = new Set<Id>();
            List<Pricing_Quote_Team__c> quoteTeamList = new List<Pricing_Quote_Team__c>();
            if(quoteId.size()>0){
                //All the Quote Team members having FSE Role
                quoteTeamList = [SELECT id,Pricing_Quote_Id__c, Pricing_Quote_Id__r.SBQQ__Account__c, Pricing_Quote_Team_Member_Id__c 
                                 FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c IN :quoteId 
                                 AND Pricing_Quote_Team_Member_Id__r.IsActive=True AND Pricing_Grant_Access_Ind__c = True 
                                 AND Pricing_Role_Nm__c=:Label.Pricing_Quote_Team_Role_FSE];
            }
            
            if(quoteTeamList.size() > 0){
                for(Pricing_Quote_Team__c qtm : quoteTeamList){
                    AccIdSet.add(qtm.Pricing_Quote_Id__r.SBQQ__Account__c);
                    allFSEIdSet.add(qtm.Pricing_Quote_Team_Member_Id__c);
                }
            }
            
            if(allFSEIdSet.size() > 0){
                for(PermissionSetAssignment psa :  [SELECT AssigneeId
                                                    FROM PermissionSetAssignment 
                                                    WHERE AssigneeId IN :allFSEIdSet AND Assignee.IsActive = true
                                                    AND PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderUser]){
                
                    fseWithPSSet.add(psa.AssigneeId);
                }    
            }
            
            if(AccIdSet.size() > 0 && fseWithPSSet.size() > 0) {
                for(AccountTeamMember accTeam : [SELECT Id,UserId,AccountId FROM AccountTeamMember WHERE AccountId IN:AccIdSet]) {
                    if(accIdFseUserIdMap.containsKey(accTeam.AccountId)){
                        accIdFseUserIdMap.get(accTeam.AccountId).add(accTeam.UserId);
                    }
                    else{
                        accIdFseUserIdMap.put(accTeam.AccountId, new Set<Id>{accTeam.UserId});
                    }
                }
            }
            
            if(quoteTeamList.size() > 0){
                for(Pricing_Quote_Team__c qtm : quoteTeamList) {
                    //create the map of quote Id and valid quote team FSEs if the Quote Team member is part of Account Team and has FSE Permission set
                        if(accIdFseUserIdMap.containsKey(qtm.Pricing_Quote_Id__r.SBQQ__Account__c) && accIdFseUserIdMap.get(qtm.Pricing_Quote_Id__r.SBQQ__Account__c).contains(qtm.Pricing_Quote_Team_Member_Id__c) && fseWithPSSet.contains(qtm.Pricing_Quote_Team_Member_Id__c)) {
                            if(quoteQTMMemberIdMap.containsKey(qtm.Pricing_Quote_Id__c)){
                                quoteQTMMemberIdMap.get(qtm.Pricing_Quote_Id__c).add(qtm.Pricing_Quote_Team_Member_Id__c);
                            }
                            else{
                                quoteQTMMemberIdMap.put(qtm.Pricing_Quote_Id__c , new Set<Id>{qtm.Pricing_Quote_Team_Member_Id__c});
                            }
                        }
                }
            }
            
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        } 
        return quoteQTMMemberIdMap;
    }
    
    /**
    * @description Method written to publish a platform event for triggering Approval Email Notifications
    * @author Bharath Chandrashekar | 04-19-2023 
    * @param Set<Id> recIds 
    * @param String emailTemplate 
    **/
    public static void sendApprovalEmail(Set<Id> recIds, String emailTemplate){
        List<Pricing_IQR_Event__e> newsEventList = new List<Pricing_IQR_Event__e>();
        List<Id> qliRecIds = new List<Id>();        
        if(recIds.size() > 0){
            qliRecIds.addAll(recIds);
            newsEventList.add(new Pricing_IQR_Event__e(
                Pricing_QuoteLineId_Txt__c = String.join(qliRecIds,','),
                Pricing_EmailTemplate_Nm__c=emailTemplate,
                Pricing_IQR_Action_Nm__c = Label.Pricing_Send_EmailNotificationToBot_Event));
        } 
        if(newsEventList.size() > 0){               
            // Call method to publish events.
            List<Database.SaveResult> results = EventBus.publish(newsEventList);
        } 
    }

    /**
    * @description return if svd metadata is active then false else true
    * @author Vrushabh Uprikar | 01-07-2025 
    * @return Boolean 
    **/
    @AuraEnabled(cacheable=true)
    public static Boolean getSVDQuoteActiveStatus() {
        return Pricing_Manage_Small_Volume_Deal.getSVDQuoteActiveStatus();
    }

    /**
    * @description 
    * @author Vrushabh Uprikar | 01-07-2025 
    * @param recordId 
    * @return SBQQ__Quote__c 
    **/
    @AuraEnabled(cacheable=true)
    public static SBQQ__Quote__c getQuoteDetails(Id recordId) {        
        return Pricing_QuoteCloneController.getQuoteDetails(recordId);
    }
}