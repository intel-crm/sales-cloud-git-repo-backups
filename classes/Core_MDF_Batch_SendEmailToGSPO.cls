/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_SendEmailToGSPO 
* Version     : 1.0 
* Created Date: 10-Nov-2020
* Modification Log :
* Developer            		Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Pranav       10-NOV-2020         Used to Send Email To GSPO With File Attachment For Individual Vat Claims of Payment Run
*****************************************************************************************************************************************/

public without sharing class Core_MDF_Batch_SendEmailToGSPO implements Database.Batchable<sObject>
{
    // List of Vat Claims to process for Vat Infos
    List<PartnerFundClaim> vatClaimList = new List<PartnerFundClaim>();
    // Map of Content Document Id and Vat Information Record
    Map<String, Core_MDF_Claim_VAT_Info__c> contentDocIdToVatInfoMap = new Map<String, Core_MDF_Claim_VAT_Info__c>();
    // List of Content Versions
    List<ContentVersion> contentVersionList = new List<ContentVersion>();
    // Payment Run record Id
   // Id pRunRecordId ;
    Set<Id> pRunRecordIdSet = new Set<Id>();
    // Payment Run Record
    Core_MDF_Payment_Run__c pRunRecord;
    
    // Constructor to initialise List of Incoming Vat Claims and Payment Run Record Id
    public Core_MDF_Batch_SendEmailToGSPO(List<PartnerFundClaim> vatClaimList)
    {
        if(vatClaimList != NULL){
			this.vatClaimList = vatClaimList; 
            for(PartnerFundClaim vatPfc : this.vatClaimList){
                pRunRecordIdSet.add(vatPfc.Core_MDF_Payment_Id__r.Core_MDF_Payment_Run_Id__c);
            }
        	//pRunRecordId = vatClaimList[0].Core_MDF_Payment_Id__r.Core_MDF_Payment_Run_Id__c;
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {   
    String query = 'Select Id, Core_MDF_Approved_File_Id__c,Core_MDF_Claim_Id__r.Title from Core_MDF_Claim_VAT_Info__c where (Core_MDF_Claim_Id__c IN : vatClaimList OR Core_MDF_Sub_Claim_Id__c IN :vatClaimList)';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Core_MDF_Claim_VAT_Info__c> vatInfosList)
    {
        try{
            // Prepare Map of Content Document and Vat Information Record
            for(Core_MDF_Claim_VAT_Info__c vatInfos : vatInfosList){
                if(vatInfos.Core_MDF_Approved_File_Id__c != NULL){
                    // Content Document Id is populated in vat information field Core_MDF_Approved_File_Id__c
                    contentDocIdToVatInfoMap.put(vatInfos.Core_MDF_Approved_File_Id__c, vatInfos);
                }
            }
              
            // Querying Content Version for List of Content Document Ids
            contentVersionList = [SELECT Id,title, PathOnClient, FileType, versiondata, ContentDocumentId FROM contentversion WHERE ContentDocumentId IN :contentDocIdToVatInfoMap.keySet()];
         
            // Initialise Email Wrapper List
            List<Core_MDF_GenericClassToSendMail.MailParams> gspoEmailWrapperList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
           
            for(ContentVersion cversion : contentVersionList)
            {
                Core_MDF_GenericClassToSendMail.MailParams gspoEmailWrapper = new Core_MDF_GenericClassToSendMail.MailParams();
                 Core_MDF_SendEmailAttachment emailAttachment = new Core_MDF_SendEmailAttachment();
                 Core_MDF_SendEmailAttachment[] emailAttachmentList = new Core_MDF_SendEmailAttachment[]{};
                // Update Email Wrapper Attributes
                gspoEmailWrapper.emailIds = system.label.Core_MDF_GSPOEmailAddress;
                gspoEmailWrapper.recordId = contentDocIdToVatInfoMap.get(String.valueOf(cversion.ContentDocumentId)).Id;
                gspoEmailWrapper.templateName = 'Core_MDF_VatNotificationForGSPO';
                if(cversion.versiondata != NULL && cversion.PathOnClient != null){
                    //Versiondata stores the content or body of the Content Version
                	emailAttachment.blobData = cversion.versiondata;
                    //PathOnClient stores the filename of the uploaded Content Document
                    emailAttachment.fileName = cversion.PathOnClient;
                }
                emailAttachmentList.add(emailAttachment);
                gspoEmailWrapper.emailAttachment = emailAttachmentList;
                // Add Wrapper in gspoEmailWrapperList
                gspoEmailWrapperList.add(gspoEmailWrapper);
            }
            // Generic Method to Send Emails
            if(gspoEmailWrapperList != NULL && gspoEmailWrapperList.size()>0){
            	Core_MDF_GenericClassToSendMail.sendEmailMethod(gspoEmailWrapperList);
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    public void finish(Database.BatchableContext bc)
    {
        // Call Method to Update Notification Sent Date Time on Payment Run record
        updateNotificationSentDt();
    }
    
    /****************************************************************************************************** 
     Method Name:        updateNotificationSentDt
     @return  :          
     @parameters:        
     Description:        This Function updates GSPO Notification Sent Date time field on Payment Run Record
     Added By:           Pranav - Accenture - 11/11/2020 
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    public void updateNotificationSentDt(){
        try{                        
            // Update Notification Sent Date on Payment Run record
            pRunRecord = [Select Id, Core_MDF_GSPO_Notification_Sent_On_Dtm__c from Core_MDF_Payment_Run__c Where ID IN : pRunRecordIdSet];
            pRunRecord.Core_MDF_GSPO_Notification_Sent_On_Dtm__c = System.now();
            if(pRunRecord != NULL){
                // Update Payment Run
                Database.update(pRunRecord);
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
}