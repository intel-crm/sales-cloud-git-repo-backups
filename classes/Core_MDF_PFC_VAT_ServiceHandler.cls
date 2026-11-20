/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_VAT_ServiceHandler 
* Version     : 1.0 
* Created Date: 08-10-2018
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sridhar       08-10-2018          Created for handling the functionalities of VAT validations
*****************************************************************************************************************************************/

public with sharing class Core_MDF_PFC_VAT_ServiceHandler {

    public static Id paymentDocumentRecordTypeId;
    public static Id submitForApprovalRecordTypeId;
    private static Map<Id,Integer> vatIdNoOfFiles = new Map<Id,Integer>();
    private static String IPAPropRevReqStatus= Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_ProposalRevisionReqStatus');
    private static String caseStatusPendingDoc=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Case_Status_Pending_Document');
    private static String caseStatusUnderReview= Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Case_Status_Under_Review');
    private static String statusApproved=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Approved');
    //private static String dummyAcctOwnerId=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Dummy_Account_Owner_Id');
      static{
        // Schema.DescribeSObjectResult recordType = Core_MDF_Claim_VAT_Info__c.SObjectType.getDescribe();
        // List<Schema.RecordTypeInfo> recordTypeList = recordType.getRecordTypeInfos();
        // Map<string,Id> recTypeIdMap = new Map<string,Id>();
        // for(Schema.RecordTypeInfo rt:recordTypeList){
        //     recTypeIdMap.put(rt.getDeveloperName(),rt.getRecordTypeId());
        // }
  
  //ATHR fixes - RP
  Map<Id, Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Core_MDF_Claim_VAT_Info__c.getRecordTypeInfosById();
  Map<String, Id> recTypeIdMap = new Map<String, Id>();
  for (Schema.RecordTypeInfo rt : rtMapById.values()) {
    recTypeIdMap.put(rt.getDeveloperName(), rt.getRecordTypeId());
  }
        paymentDocumentRecordTypeId = recTypeIdMap.get('Core_MDF_Payment_Document');
        submitForApprovalRecordTypeId = recTypeIdMap.get('Core_MDF_Submit_for_Approval');
    }
/****************************************************************************************************************************************
    Method Name:                                             validateVATInvoiceandFiles
    @return  :                                               null
    @parameters:                                             VAT Info newList, VAT Info oldMap,
    Description:                                             Validates if the file is uploaded & tax invoice number is populated on payment document record before submitting for approval
    Added By:                                                
    Changes Made:                                            To validate & make Tax invoice no as optional based on Legal Entity. 
    Modified By :                                            Accenture- TS, Modified Date:21-JAN-2021
*****************************************************************************************************************************************/ 
    public static void validateVATInvoiceandFiles(List<Core_MDF_Claim_VAT_Info__c> newVATList, Map<Id,Core_MDF_Claim_VAT_Info__c> oldMap){
        List<Core_MDF_Claim_VAT_Info__c> pfcVAT = new List<Core_MDF_Claim_VAT_Info__c>();
        Map<Id,Core_MDF_Claim_VAT_Info__c> pfcOldVAT = new Map<Id,Core_MDF_Claim_VAT_Info__c>();
        map<Id, Boolean> recIdDocIdMap = new map<Id, Boolean>();
        List<Id> vatinfoIds = new List<Id>();
        Map<Id, Boolean> vatinfoLETaxInvoiceMap = new Map<Id, Boolean>();
        Map<String,Boolean> mapOfLegalEntites = new Map<String,Boolean>();
        Set<String> setOfLegalEntities = new Set<String>();
        try {


            pfcVAT = (List<Core_MDF_Claim_VAT_Info__c>) newVATList ;            
            //pfcOldVAT = (Map<Id,Core_MDF_Claim_VAT_Info__c>) oldVATMap;                
            
            // build the record id list to get the files associated
            for (Core_MDF_Claim_VAT_Info__c vatInfoRec : pfcVAT){
                vatinfoIds.add(vatInfoRec.Id);
            }
            
            // Read the files associated
            if (vatinfoIds.size() > 0){
                recIdDocIdMap = getFilesAttached(vatinfoIds);
            }
            //Retrieve record from custom metadata with Legal Entity values - IPA_650
            for(Core_MDF_CCP_VAT_Config__mdt vatConfig : [Select id,label,DeveloperName,Core_MDF_Program__c,Core_MDF_Legal_Entity__c from Core_MDF_CCP_VAT_Config__mdt where Core_MDF_Invoice_Number_Optional__c=true]){
                mapOfLegalEntites.put(vatConfig.Core_MDF_Legal_Entity__c+'-'+vatConfig.Core_MDF_Program__c,true);
            }
            // Prepare a map of Payment Document Id and Claim's country
            for(Core_MDF_Claim_VAT_Info__c vatinfo : [SELECT Id, Core_MDF_Claim_Id__r.Core_MDF_Country_Location_nm__c,Core_MDF_Claim_Id__r.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Core_MDF_Claim_Id__r.Core_MDF_Program__c                                                       
                                                      FROM Core_MDF_Claim_VAT_Info__c WHERE Id IN:vatinfoIds LIMIT 50000])
            {
                if(mapOfLegalEntites.containsKey(vatinfo.Core_MDF_Claim_Id__r.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c+'-'+vatinfo.Core_MDF_Claim_Id__r.Core_MDF_Program__c)){
                    vatinfoLETaxInvoiceMap.put(vatinfo.Id,true);
                }
                else{
                    vatinfoLETaxInvoiceMap.put(vatinfo.Id,false);
                }
            }
            
            // Validate the invoice number and file are having values while submitting for approval
            // Invoice number is not mandatory for IPA - JAPAN
            for(Core_MDF_Claim_VAT_Info__c vatinfo : pfcVAT){
                
                
                //string previousStatus = pfcOldVAT.get(vatinfo.id).Core_MDF_Status_Txt__c;
                Boolean fileAttached =  recIdDocIdMap.get(vatinfo.Id) == null ? false : recIdDocIdMap.get(vatinfo.Id);
                
                Boolean hasClaimSubAccess = (FeatureManagement.checkPermission('Core_MDF_CCP_Claim_Submitter')|| 
                                     FeatureManagement.checkPermission('Core_MDF_IPAClaimSubmitter') || 
                                     FeatureManagement.checkPermission('Core_MDF_RetailClaimSubmitter') || FeatureManagement.checkPermission('Core_MDF_CCP_External_Co_GTM_Claim_Submitter')) ? true : false;
                
                String oldStatus = oldMap.get(vatinfo.Id).Core_MDF_Status_Txt__c;
                
                if ((oldStatus == IPAPropRevReqStatus || oldStatus == caseStatusPendingDoc) && vatinfo.Core_MDF_Status_Txt__c == caseStatusUnderReview
                     && ((String.isBlank(vatinfo.Core_MDF_VAT_Invoice_Number_Txt__c) && vatinfoLETaxInvoiceMap.containsKey(vatinfo.Id) && !vatinfoLETaxInvoiceMap.get(vatinfo.Id)) || !fileAttached || !hasClaimSubAccess))
                {
                    if(!hasClaimSubAccess){
                        vatinfo.addError(Label.Core_MDF_Manual_Audit_Access_Error);//Display Error message if the user is not a claim submitter "You do not have sufficient permissions to perform this action."
                    }
                    else if(vatinfoLETaxInvoiceMap.containsKey(vatinfo.Id) && vatinfoLETaxInvoiceMap.get(vatinfo.Id)){ //Check if Legal Entity is 650
                        vatinfo.addError(Label.Core_MDF_Payment_Doc_File_ErrorMsg); //Display error message "Payment document is mandatory"
                    }else{
                        vatinfo.addError(Label.Core_MDF_Claim_VAT_Invoice_File_ErrorMsg); //Display error message "Tax Invoice Number and Payment document is mandatory"
                    }
                    break;
                }
                else if (oldStatus == caseStatusUnderReview && vatinfo.Core_MDF_Status_Txt__c == statusApproved && string.isBlank(vatinfo.Core_MDF_Approved_File_Id__c)) {

                    vatinfo.addError(Label.Core_MDF_select_payment_doc);
                    break;
                }   
                else if (oldStatus == caseStatusUnderReview && vatinfo.Core_MDF_Status_Txt__c == statusApproved && string.isBlank(vatinfo.Core_MDF_VAT_Invoice_Number_Txt__c)){
                    vatinfo.addError(Label.Core_MDF_VAT_Invoice_No); //Display error message "Tax Invoice Number is mandatory"
                    break;
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new DMLException('Exception Occured:::'+e);}

    }

/****************************************************************************************************************************************
    Method Name:                                             getFilesAttached
    @return  :                                               return map<id,boolean>.
    @parameters:                                             list of ids
    Description:                                             returns true for each ids if the file is associated
    Added By:                                                Sridhar S -  10/12/2020
*****************************************************************************************************************************************/
    public static map<Id, Boolean> getFilesAttached (list<Id> lstvatIds) {

        map<Id, Boolean> mapCntIdParentId = new map<Id, Boolean>();
        string defaultOwner =Label.Core_MDF_Dummy_Account_Owner_Id ;
        vatIdNoOfFiles = new Map<Id,Integer>(); 

        for(ContentDocumentLink cntLink : [Select Id, LinkedEntityId, ContentDocumentId From ContentDocumentLink Where LinkedEntityId IN :lstvatIds and ContentDocument.OwnerId !=: defaultOwner]) {

            if (!mapCntIdParentId.containsKey(cntLink.LinkedEntityId)){
                mapCntIdParentId.put(cntLink.LinkedEntityId, true);
            }

            if (!vatIdNoOfFiles.containsKey(cntLink.LinkedEntityId)){
                vatIdNoOfFiles.put(cntLink.LinkedEntityId, 1);
            }
            else{
                Integer totalFiles = (vatIdNoOfFiles.get(cntLink.LinkedEntityId)) + 1;
                vatIdNoOfFiles.put(cntLink.LinkedEntityId,totalFiles);
            }

        }

      
        return mapCntIdParentId ;
    }
/****************************************************************************************************************************************
    Method Name:                                             updateRecordTypeOnVAT
    @return  :                                               return null.
    @parameters:                                             VAT Info newList, VAT Info oldMap, boolean isInsert and boolean isUpdate
    Description:                                             updates the RecordType Id on Before Insert and Before Update
    Added By:                                                Accenture – Harika P -  11/19/2020
*****************************************************************************************************************************************/        
    public static void updateRecordTypeOnVAT(List<Core_MDF_Claim_VAT_Info__c> newVATList, Map<Id,Core_MDF_Claim_VAT_Info__c> oldVATMap, 
                                             boolean isInsert, boolean isUpdate)
    {
        try{
            for(Core_MDF_Claim_VAT_Info__c vatinfo : newVATList){
                // On insert of VAT record, RecordType Id will be populated
                if(isInsert)
                {
                    //Updating RecordType to 'Submit for Approval'
                    vatinfo.RecordTypeId = submitForApprovalRecordTypeId;
                    
                }
                // On update of VAT record, calling updateRecordTypeOnBeforeUpdate
                if(isUpdate)
                {
                    updateRecordTypeOnBeforeUpdate(vatinfo,oldVATMap);
                   
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }

/****************************************************************************************************************************************
    Method Name:                                             updateRecordTypeOnBeforeUpdate
    @return  :                                               return null.
    @parameters:                                             VAT Info newList, VAT Info oldMap, boolean isInsert and boolean isUpdate
    Description:                                             updates the RecordType Id on Before Update based on record status
    Added By:                                                Accenture – Harika P -  11/19/2020
*****************************************************************************************************************************************/     
    public static void updateRecordTypeOnBeforeUpdate(Core_MDF_Claim_VAT_Info__c vatinfo, Map<Id,Core_MDF_Claim_VAT_Info__c> oldVATMap){
        //this is to update record type if status is changing to Revision Required/ Pending Documents 
        if(vatinfo.Core_MDF_Status_Txt__c != oldVATMap.get(vatinfo.Id).Core_MDF_Status_Txt__c &&
           (vatinfo.Core_MDF_Status_Txt__c == IPAPropRevReqStatus || vatinfo.Core_MDF_Status_Txt__c == caseStatusPendingDoc))
        {   
            //Updating RecordType to 'Submit for Approval'
            vatinfo.RecordTypeId = submitForApprovalRecordTypeId;
            
        }
        //this is to update record type to 'Payment Document' if status is not equal to Revision Required/ Pending Documents
        if(vatinfo.Core_MDF_Status_Txt__c != oldVATMap.get(vatinfo.Id).Core_MDF_Status_Txt__c &&
           vatinfo.Core_MDF_Status_Txt__c != IPAPropRevReqStatus && vatinfo.Core_MDF_Status_Txt__c != caseStatusPendingDoc)
        {
            ////Update Recordtype to 'Payment Document' 
            vatinfo.RecordTypeId = paymentDocumentRecordTypeId;
           
        }
    }

/****************************************************************************************************************************************
    Method Name:                                             updateDateFieldsOnVAT
    @return  :                                               return null.
    @parameters:                                             VAT Info newList, VAT Info oldMap, boolean isInsert and boolean isUpdate
    Description:                                             updates the document requested date, first reminder and second reminder dates
    Added By:                                                Accenture – Harika P -  10/14/2020
*****************************************************************************************************************************************/        
    public static void updateDateFieldsOnVAT(List<Core_MDF_Claim_VAT_Info__c> newVATList, Map<Id,Core_MDF_Claim_VAT_Info__c> oldVATMap, 
                                             boolean isInsert, boolean isUpdate)
    {
        try{
            for(Core_MDF_Claim_VAT_Info__c vatinfo : newVATList){
                // On insert of VAT record, claim submitter and RSM reminder notification date will be populated
                if(isInsert)
                {
                    vatinfo.Core_MDF_ClaimSubmitterReminder_Dtm__c = addBusinessDays(system.today(),3);
                    vatinfo.Core_MDF_RSMReminderDate_Dtm__c = addBusinessDays(system.today(),5);
                }
                // On update of VAT record, call updateFieldsOnBeforeUpdate method for field updates
                if(isUpdate)
                {
                    
                    updateFieldsOnBeforeUpdate(vatinfo,oldVATMap);
                }                      
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }

/****************************************************************************************************************************************
    Method Name:                                             updateFieldsOnBeforeUpdate
    @return  :                                               return null.
    @parameters:                                             VAT Info record, VAT Info oldMapdate
    Description:                                             updates the date and checkbox fields based on the criteria
    Added By:                                                Accenture – Harika P -  10/27/2020
*****************************************************************************************************************************************/    
    public static void updateFieldsOnBeforeUpdate(Core_MDF_Claim_VAT_Info__c vatinfo, Map<Id,Core_MDF_Claim_VAT_Info__c> oldVATMap){
        
        //this is to update next reminder notification date to send email to RSM after every 5 days for submission of VAT record
        ///Core_MDF_RSMRemNotificationSent_Ind__c it will be made true from flow after sending notification, and from this trigger logic 
        //it will be made false and will never be true on any record as this trigger will always make it false. But it can be tracked from in history
         if((vatinfo.Core_MDF_Status_Txt__c == caseStatusPendingDoc || vatinfo.Core_MDF_Status_Txt__c == IPAPropRevReqStatus)
           && vatinfo.Core_MDF_RSMRemNotificationSent_Ind__c != oldVATMap.get(vatinfo.Id).Core_MDF_RSMRemNotificationSent_Ind__c && 
           vatinfo.Core_MDF_RSMRemNotificationSent_Ind__c)
        {
            vatinfo.Core_MDF_RSMReminderDate_Dtm__c = addBusinessDays(system.today(),5);
            vatinfo.Core_MDF_RSMRemNotificationSent_Ind__c = FALSE;
        }
        
        //this is to update 3 days and 5 days reminder date fields if status is changing from Under Review to Revision Required/ Pending Documents 
        //when  payment admin is rejecting VAT record
        //Call updatesOnRevisionRequired method for field updates
        if(vatinfo.Core_MDF_Status_Txt__c != oldVATMap.get(vatinfo.Id).Core_MDF_Status_Txt__c &&
           (vatinfo.Core_MDF_Status_Txt__c == IPAPropRevReqStatus || vatinfo.Core_MDF_Status_Txt__c == caseStatusPendingDoc))        {   
            updatesOnRevRequiredOrPendingDocs(vatinfo);
        }
        
        //updating reminder notification date for payment admin when VAT record is getting into approval process 
        //and notification is sent to payment admin in approval process                
        if(vatinfo.Core_MDF_Status_Txt__c != oldVATMap.get(vatinfo.Id).Core_MDF_Status_Txt__c &&
           vatinfo.Core_MDF_Status_Txt__c == caseStatusUnderReview)
        {
            vatinfo.Core_MDF_Payment_Admin_Reminder_Date_Dtm__c = addBusinessDays(system.today(),2);
        }
        
        //updating the next reminder date for payment admin notification and making the flag as false to send next reminder
        //after sending reminder notification and making the flag as true
        if(vatinfo.Core_MDF_Status_Txt__c == caseStatusUnderReview && vatinfo.Core_MDF_Payment_Admin_Reminder_Sent_Ind__c != 
           oldVATMap.get(vatinfo.Id).Core_MDF_Payment_Admin_Reminder_Sent_Ind__c && 
           vatinfo.Core_MDF_Payment_Admin_Reminder_Sent_Ind__c)
        {
            vatinfo.Core_MDF_Payment_Admin_Reminder_Date_Dtm__c = addBusinessDays(system.today(),2);
            vatinfo.Core_MDF_Payment_Admin_Reminder_Sent_Ind__c = FALSE;
        }
    }

/****************************************************************************************************************************************
    Method Name:                                             updatesOnRevisionRequired
    @return  :                                               return null.
    @parameters:                                             VAT Info record
    Description:                                             updates the date and checkbox fields based on the criteria
    Added By:                                                Accenture – Harika P -  10/27/2020
*****************************************************************************************************************************************/    
    public static void updatesOnRevRequiredOrPendingDocs(Core_MDF_Claim_VAT_Info__c vatinfo){
        
        //Updating reminder date field.
        //when VAT record is rejected, reminder notificaiton will be sent to claim owner and RSMs.
        vatinfo.Core_MDF_ClaimSubmitterReminder_Dtm__c = addBusinessDays(system.today(),3);
        vatinfo.Core_MDF_RSMReminderDate_Dtm__c = addBusinessDays(system.today(),5);
        
        //If reminder notification was sent to claim owner when its status was Pending documents, below flag was made as true.
        //If it is true thn we need to update it to false to send notification again in Revision Required
        if(vatinfo.Core_MDF_ClaimSubRemNotificationSent_Ind__c)
        {
            vatinfo.Core_MDF_ClaimSubRemNotificationSent_Ind__c = FALSE;
        }
    }                       

/****************************************************************************************************************************************
    Method Name:                                             isWeekendDay
    @return  :                                               return Boolean.
    @parameters:                                             Date
    Description:                                             returns true if the day is weekend
    Added By:                                                Accenture – Harika P -  10/14/2020
*****************************************************************************************************************************************/
    public static Boolean isWeekendDay(Date inputDate){
        Boolean result = false;        
        Datetime dt = (DateTime)inputDate;
        String dayOfWeek = dt.format('EEEE',UserInfo.getLocale()); 
        result = (dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') ? true : false;
        return result;
    }    

/****************************************************************************************************************************************
    Method Name:                                             addBusinessDays
    @return  :                                               return Date.
    @parameters:                                             Date, Integer
    Description:                                             returns business days based on the input parameters
    Added By:                                                Accenture – Harika P -  10/14/2020
*****************************************************************************************************************************************/    
    public static Date addBusinessDays(Date startDate, Integer businessDaysToAdd){ 
        Date finalDate = startDate;
        Integer daysToAdd = 1;
        while(businessDaysToAdd != 0)
        {
            finalDate = finalDate.AddDays(daysToAdd);
            // check finalDate is weekday or weekend
            if (!isWeekendDay(finalDate))
            {
                businessDaysToAdd -= daysToAdd;
            }
        }
        return finalDate;
    }
   /****************************************************************************************************************************************
    Method Name:                                             removeVATFromApprovalQueue
    @return  :                                               return Boolean.
    @parameters:                                             Core_MDF_Claim_VAT_Info__c
    Description:                                             remove the VAT record from approval requests
    Added By:                                                Sridhar – 11/03/2020
*****************************************************************************************************************************************/    
   @InvocableMethod(label='Remove VAT Record From Approval' description='Call this method to remove the Claim VAT record from approval queue')
   public static void removeVATFromApprovalQueue(List<Core_MDF_Claim_VAT_Info__c> vatRecords){ 
        
    List<ID> vatIDs = new List<ID>();
        
    try{
        if (vatRecords != null && vatRecords.size() > 0){

            for(Core_MDF_Claim_VAT_Info__c vatRecord : vatRecords ){
                vatIDs.add(vatRecord.Id);
            }
            Core_MDF_VAT_ApprovalQueueRemoval.removeRecordsFromApprovalQueue(vatIDs);
        }
    }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    
   }

 /******************************************************************************************************************************************************************
    Method Name:                                             vatFileNameChangeAndValidations
    @return  :                                               return void.
    @parameters:                                             List<ContentDocumentLink>
    Description:                                             Verify the function call is made due to VAT Info object and call respective functions
    Added By:                                                Sridhar – 11/13/2020
 ********************************************************************************************************************************************************************/

   public static void vatFileNameChangeAndValidations(List<ContentDocumentLink> newContentFiles)
   {

    String objectName = 'Core_MDF_Claim_VAT_Info__c';
    List<Id> vatRecordId = new List<Id>();
    List<Id> contentDocIDs = new List<Id>();
    List<ContentDocumentLink> newValidContentDocs = new List<ContentDocumentLink>();
    string sObjectName = '';

    try{

        // Collect the contentdocid and var record ids
        for(ContentDocumentLink contentDocumentLink : newContentFiles){

            Id objectRecordId = contentDocumentLink.LinkedEntityId;
            if(String.valueOf(objectRecordId)!=null && String.valueOf(objectRecordId)!=''){
                //Getting object api name by Id
                sObjectName = String.valueOf(objectRecordId.getSObjectType());
            }
            // Verify the object is VAT Info Object and collect the record Ids
            if(sObjectName!=null && objectName.contains(sObjectName)){
                contentDocIDs.add(contentDocumentLink.ContentDocumentId);
                vatRecordId.add(contentDocumentLink.LinkedEntityId);
                newValidContentDocs.add(contentDocumentLink);
            } 
            
        }

        // If VAT Info object related trigger the initiate the process
        if (newValidContentDocs.size() > 0){

            // method call for file upload validation to restrict other than pending doc and revision required status
            contentDocIDs = validateFileUploadIsAllowed(vatRecordId,newValidContentDocs);
            validateFileSizeAndExtension(contentDocIDs,newContentFiles);

            // Retrieve only valid content document IDs and call the below method to rename the file name
            if (contentDocIDs != null && contentDocIDs.size() > 0){
                updateVATFileName(contentDocIDs);
            }
        }
        
    }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}

   }

 /******************************************************************************************************************************************************************
    Method Name:                                             validateFileUploadIsAllowed
    @return  :                                               return List<Id>.
    @parameters:                                             List<Id> vatRecordId,List<ContentDocumentLink> newContentFiles
    Description:                                             Validate the file upload validity
    Added By:                                                Sridhar – 11/13/2020
 ********************************************************************************************************************************************************************/
    private static List<Id> validateFileUploadIsAllowed(List<Id> vatRecordId,List<ContentDocumentLink> newContentFiles)
    {
        List<Id> validContentDocIDs = new List<Id>();
        
        Map<ID,Core_MDF_Claim_VAT_Info__c> vatRecordsMap = new Map<ID, Core_MDF_Claim_VAT_Info__c>([select id, Core_MDF_Status_Txt__c,Core_MDF_Claim_Id__r.Core_MDF_Proposal_Based_Ind__c,Core_MDF_Claim_Id__r.RecordType.DeveloperName, Core_MDF_Claim_Id__r.Core_MDF_Program__c from Core_MDF_Claim_VAT_Info__c where id IN:vatRecordId]);
        
        User currentUser = [SELECT IsPortalEnabled,Profile.PermissionsModifyAllData FROM User where id =: UserInfo.getUserId() and IsActive = true];
        
        Boolean hasPayAdminAccess = (FeatureManagement.checkPermission('Core_MDF_CCP_Internal_RMF_Payment_Admin')|| 
                                     FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Payment_Admin') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Payment_Adm')) ? true : false;
        
        Boolean hasClaimSubAccess = (FeatureManagement.checkPermission('Core_MDF_CCP_Claim_Submitter')|| 
                                     FeatureManagement.checkPermission('Core_MDF_IPAClaimSubmitter') || 
                                     FeatureManagement.checkPermission('Core_MDF_RetailClaimSubmitter') || FeatureManagement.checkPermission('Core_MDF_CCP_External_Co_GTM_Claim_Submitter')) ? true : false;
        Boolean isAdminUser = false;
        
        if (currentUser != null){
            isAdminUser = currentUser.Profile == null ? false : currentUser.Profile.PermissionsModifyAllData;
        }
        
        // Get total files attached for the given VAT records
        getFilesAttached(vatRecordId);
        Boolean isProposalBasedCustomPSAssigned = FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Proposal_Based_User');
        Boolean isAccountBasedCustomPSAssigned = FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Account_Based_User');
        for(ContentDocumentLink contentDocumentLink : newContentFiles){
            
            Id objectRecordId = contentDocumentLink.LinkedEntityId;
            Core_MDF_Claim_VAT_Info__c vatDoc = vatRecordsMap.get(objectRecordId);
            if(vatDoc != null && vatDoc.Core_MDF_Claim_Id__r.Core_MDF_Program__c == Label.Core_MDF_IPA_Program_Name) {
                hasClaimSubAccess = (hasClaimSubAccess && 
                (
                (vatDoc.Core_MDF_Claim_Id__r.RecordType.DeveloperName == Label.Core_MDF_IPA_AccountBased_RecType_DevName && isAccountBasedCustomPSAssigned && !vatDoc.Core_MDF_Claim_Id__r.Core_MDF_Proposal_Based_Ind__c)
                || (vatDoc.Core_MDF_Claim_Id__r.RecordType.DeveloperName == Label.Core_MDF_IPA_RecordType && isProposalBasedCustomPSAssigned && vatDoc.Core_MDF_Claim_Id__r.Core_MDF_Proposal_Based_Ind__c)
                )) ? true : false;
            }

            string vatRecordStatus = vatRecordsMap.get(objectRecordId) == null ? '' : vatRecordsMap.get(objectRecordId).Core_MDF_Status_Txt__c ;
            
            // If more than one file associated then throw the error
            if (vatIdNoOfFiles != null && vatIdNoOfFiles.size() > 0 && vatIdNoOfFiles.containsKey(objectRecordId) && vatIdNoOfFiles.get(objectRecordId) > 0){
                contentDocumentLink.addError('User cant upload multiple files');
            }
            
            if ((hasPayAdminAccess && (vatRecordStatus == IPAPropRevReqStatus || vatRecordStatus == caseStatusPendingDoc || vatRecordStatus == 'Under Review' || vatRecordStatus == 'Approved'))
                || (isAdminUser || (currentUser.IsPortalEnabled && hasClaimSubAccess && (vatRecordStatus == caseStatusPendingDoc || vatRecordStatus == IPAPropRevReqStatus))))
            {
                validContentDocIDs.add(contentDocumentLink.ContentDocumentId);
            }
            else{
                contentDocumentLink.addError(System.Label.Core_ContentFileUploadErrorMsg);
            }
            
        }
        
        return validContentDocIDs;
    }

   /******************************************************************************************************************************************************************
    Method Name:                                             validateFileSizeAndExtension
    @return  :                                               return List<Id>.
    @parameters:                                             List<Id> vatRecordId,List<ContentDocumentLink> newContentFiles
    Description:                                             Validate the file upload validity
    Added By:                                                Sridhar – 11/13/2020
    Changes Made:                                            Added logic to validate file format and restrict it to pdf format before uploading it
    Modified By :                                            Tejasree - 20-JAN-2021
 ********************************************************************************************************************************************************************/

   private static void validateFileSizeAndExtension(List<Id> contentDocIDs, List<ContentDocumentLink> newContentFiles){

        Map<Id,Integer> contentIdAndSize = new Map<Id,Integer>();
        Map<Id,String> contentIdAndfileExtension = new Map<Id,String>(); //Created a map with key as contentID & value as fileExtension 
        List<String> fileExtensions = new List<String>();
        Set<String> setOfExtensions = new Set<String>();
        //Getting payment document record values from Configuration custom setting
        Core_MDF_Configuration__c  paymentDoc = Core_MDF_Configuration__c.getValues('PAYMENT_DOC_ALLOWED_FILE_EXTENSIONS');
        if(paymentDoc.Core_MDF_Value__c!=null && paymentDoc.Core_MDF_Value__c.length()>0){
            fileExtensions = paymentDoc.Core_MDF_Value__c.toLowerCase().split(';'); 
        }
        if(fileExtensions!=null & fileExtensions.size()>0){
            setOfExtensions.addAll(fileExtensions); //Add all list of fileExtensions to set
        }
        // Update the file size & file extension for each document in map
        for (ContentDocument contentDoc : [select ID,FileExtension,ContentSize from ContentDocument where ID IN:contentDocIDs]){

            contentIdAndSize.put(contentDoc.ID, contentDoc.ContentSize);
            contentIdAndfileExtension.put(contentDoc.ID,contentDoc.FileExtension);
        }
        // Validate the filesize & file extension for available content documents and throw the error
        for (ContentDocumentLink docLink : newContentFiles){

            Integer fileSize = contentIdAndSize.get(docLink.ContentDocumentId);
            String fileExt = contentIdAndfileExtension.get(docLink.ContentDocumentId);
            
            if (fileSize != null && fileSize >  Integer.valueOf(Label.Core_MDF_VAT_File_Size)){
                docLink.addError('File size should not be more than 5MB.'); // Bydefault system error has thrown by system so not required to add label.
            }
            if((fileExt == null)||(fileExt!=null && !setOfExtensions.isEmpty() && !setOfExtensions.contains(fileExt.toLowerCase()))){ //Check if custom setting record value equals file extension field from content Document
                docLink.addError('File extension is not supported');  // Bydefault system error has thrown by system so not required to add label.
        }
        }

   }

   /******************************************************************************************************************************************************************
    Method Name:                                             updateVATFileName
    @return  :                                               return void
    @parameters:                                             List<Id> contentDocIDs
    Description:                                             Rename the files with date and time stamp
    Added By:                                                Sridhar – 11/13/2020
 ********************************************************************************************************************************************************************/
   private static void updateVATFileName(List<Id> contentDocIDs){

        // Query the list of content documents which are not owned by FLAO user
        List<ContentDocument> contentDocuments = [select id, Title, OwnerId from ContentDocument where id IN:contentDocIDs and OwnerId !=:Label.Core_MDF_Dummy_Account_Owner_Id];

        // validate the duplicate file names and update if any duplicate found
        if (contentDocuments != null && contentDocuments.size() > 0){

            List<ContentDocument> documentToBeUpdated = new List<ContentDocument>();
            for (ContentDocument contentFile : contentDocuments){
                DateTime currentDateTime = Datetime.Now();
                contentFile.Title += '_' + currentDateTime.formatGMT('MMddyyyyHH:mm:ss');     
                documentToBeUpdated.add(contentFile);
            }    

            if (documentToBeUpdated.size()> 0){
                Database.update(documentToBeUpdated);
            }

        }

   }
 
    public static void releaseClaimWhenVatisCancelled(List<Core_MDF_Claim_VAT_Info__c> vatInfoList,Map<Id,Core_MDF_Claim_VAT_Info__c> oldVatMap,Map<Id,Core_MDF_Claim_VAT_Info__c> newVatMap)
    {
        Set<Id> claimIdsToRelease = new Set<Id>();
        for(Core_MDF_Claim_VAT_Info__c vatInfo : vatInfoList)
        {
            if(oldVatMap.get(vatInfo.ID).Core_MDF_Status_Txt__c!=newVatMap.get(vatInfo.ID).Core_MDF_Status_Txt__c 
               && newVatMap.get(vatInfo.ID).Core_MDF_Status_Txt__c.equals(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Cancelled')))
            {

                //Roshan - added subclaim check
                if (vatInfo.Core_MDF_Sub_Claim_Id__c != NULL) {
                    claimIdsToRelease.add(vatInfo.Core_MDF_Sub_Claim_Id__c);
                } else {
                    claimIdsToRelease.add(vatInfo.Core_MDF_Claim_Id__c);
                }
                
            }
        }
        if(claimIdsToRelease!=null && claimIdsToRelease.size()>0)
        {
            
            List<PartnerFundClaim> claimsToBeReleased = [Select Core_MDF_ESD_Hold__c,Core_MDF_Audit_Hold__c, Core_MDF_Payment_Hold_ind__c, Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c,
                                                         Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c, Core_MDF_Status__c, Core_MDF_Claim_Previous_Status__c, Core_MDF_Bank_Doc_Hold_Ind__c, Core_MDF_Document_Hold_Ind__c,
                                                         Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c,Core_MDF_Has_Sub_Claims_Ind__c
                                                        From PartnerFundClaim 
                                                        Where Id In :claimIdsToRelease and Core_MDF_VAT_Hold_Ind__c = true and Core_MDF_Status__c=:Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold')];
            
            Core_MDF_Claim_Utility.releaseHold(claimsToBeReleased, new List<String>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_VAT_Hold')});
        }
    }
    
    /**************************************************************************************************************************************************************************************************************
    Method Name:                                             clearApprovedPaymentFieldsOnRevReq
    @return  :                                               return null.
    @parameters:                                             VAT Info record, VAT Info oldMap
    Description:                                             Removing the Approved Payment Document and Approved File ID Whenever the Status is changed to Revision Required,Pending Document,Cancelled and Denied
    Added By:                                                Accenture – Bishal S -  12/08/2020
*******************************************************************************************************************************************************************************************************************/    
    
    public static void clearApprovedPaymentFieldsOnRevReq(List<Core_MDF_Claim_VAT_Info__c> vatInfoList,Map<Id,Core_MDF_Claim_VAT_Info__c> oldVatMap){
 
    List<String> clearApprovedPaymentDocument = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Clear_Payment_Document_Status');
 
     for(Core_MDF_Claim_VAT_Info__c vatInfo : vatInfoList)
     {   
         //This is to Update the Approved Payment Document and Approved File Id when status is changed to Revision Required,Pending Document,Cancelled and Denied
        if((vatInfo.Core_MDF_Status_Txt__c != oldVATMap.get(vatInfo.Id).Core_MDF_Status_Txt__c) && (clearApprovedPaymentDocument != null && clearApprovedPaymentDocument.contains(vatInfo.Core_MDF_Status_Txt__c)))
        {   
            vatInfo.Core_MDF_Approved_File_Name_Txt__c = '';
            vatinfo.Core_MDF_Approved_File_Id__c = '';
         }
     }
  }

}