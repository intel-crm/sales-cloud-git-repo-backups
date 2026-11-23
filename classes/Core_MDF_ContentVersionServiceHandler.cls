/****************************************************************************************************************************************
* Class Name  : Core_MDF_ContentVersionServiceHandler 
* Version     : 1.0 
* Created Date: 29-JAN-2021
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - TS    29-JAN-2021       Service handler Class for upload content version files
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ContentVersionServiceHandler {
    Public static List<string> eligibleObjectForPrivateNotes = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Object_Eligible_ForPrivate_Note').split(';');
    /****************************************************************************************************************************************
        Method Name:                                             validateVATFileSizeAndExtension
        @return  :                                               return null.
        @parameters:                                             List<ContentVersion> 
        Description:                                             To restrict file size and format on uploading new content version for Payment Document records
        Added By & Date:                                         Tejasree & Date : 29-JAN-2021
    *****************************************************************************************************************************************/ 
        public static void validateVATFileSizeAndExtension(List<ContentVersion> newContentVersionFiles){
        Set<Id> contentDocIds = new Set<Id>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        List<String> fileExtensions = new List<String>();
        Set<String> setOfExtensions = new Set<String>();
        String sObjectName='';
        String objectName = 'Core_MDF_Claim_VAT_Info__c';
        
        Map<Id,ContentDocumentLink> contentDocIdToContentDocLink = new Map<Id,ContentDocumentLink>();
        for(ContentVersion contVer: newContentVersionFiles){
            System.debug('SharingConetent-->'+contVer.SharingPrivacy);
            if(contVer.ContentDocumentId!=null){
                contentDocIds.add(contVer.ContentDocumentId); //Add contentDocument Ids to set
                contentVersionList.add(contVer); //Add contentVersion to List
            }
        }
            if(contentDocIds!=null && contentDocIds.size()>0){
            //Iterate ContentDocumentLink and create a map with key as ContentDocumentId & value as ContentDocumentLink object
            for(ContentDocumentLink cntLink : [Select Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileExtension,ContentDocument.ContentSize From ContentDocumentLink Where ContentDocumentId IN:contentDocIds limit 5000]){
                System.debug('enteredAfterFor-->');
                Id objectRecordId = cntLink.LinkedEntityId;
                if(String.valueOf(objectRecordId)!=null && String.valueOf(objectRecordId)!=''){
                    //Getting object api name by Id
                    sObjectName = String.valueOf(objectRecordId.getSObjectType());
                    System.debug('objectName-->'+sObjectName);
                }
                //Check if LinkedEntityValueId is of Payment Document record Id
                if(sObjectName!=null && objectName.equalsIgnoreCase(sObjectName)){
                   contentDocIdToContentDocLink.put(cntLink.ContentDocumentId,cntLink); 
                }
                }
            }
            
            if(contentVersionList!=null && contentDocIdToContentDocLink!=null && contentVersionList.size()>0 && contentDocIdToContentDocLink.size()>0){
                //Getting payment document record values from Configuration custom setting
                Core_MDF_Configuration__c  paymentDoc = Core_MDF_Configuration__c.getValues('PAYMENT_DOC_ALLOWED_FILE_EXTENSIONS');
                if(paymentDoc.Core_MDF_Value__c!=null && paymentDoc.Core_MDF_Value__c.length()>0){
                    fileExtensions = paymentDoc.Core_MDF_Value__c.toLowerCase().split(';'); 
                }
                if(fileExtensions!=null & fileExtensions.size()>0){
                    setOfExtensions.addAll(fileExtensions); //Add all list of fileExtensions to set
                }
                //Validate file size & file extension for available content Documents and throw an error
                for(ContentVersion contVer :contentVersionList){
                    String fileExt = contentDocIdToContentDocLink.get(contVer.ContentDocumentId).ContentDocument.FileExtension;
                    Integer fileSize = contentDocIdToContentDocLink.get(contVer.ContentDocumentId).ContentDocument.ContentSize;
                    if (fileSize != null && fileSize >  Integer.valueOf(Label.Core_MDF_VAT_File_Size)){
                        contVer.addError(Label.Core_MDF_RestrictVatSize); //File size should not be more than 4MB.
                    }
                    if((fileExt == null)||(fileExt!=null && !setOfExtensions.isEmpty() && !setOfExtensions.contains(fileExt.toLowerCase()))){ //Check if custom setting record value equals file extension field from content Document
                        contVer.addError(Label.Core_MDF_RestrictVatFile);  //This file type is not supported, please upload PDF files.
                    }
                }
            }
    
               
        }

/****************************************************************************************************************************************
        Method Name:                                             updateSharingPrivacyForNotes
        @parameters:                                             List<ContentVersion> 
        Description:                                             To update the sharingPrivacy on Notes as 'P'(Private) for PartnerFundRequest & PartnerFundClaim
        Added By & Date:                                         Mohit & Date : 24/May/2024
*****************************************************************************************************************************************/     
public static void updateSharingPrivacyForNotes(List<ContentVersion> newContentVersionFiles){
        Set<Id> contentDocIds = new Set<Id>();
        Set<Id> conVerToBeUpdated = new Set<Id>();
         
    try{
        //check if Notes have privacy as 'Private' if not collect contentdocumentid to update content version
        for(ContentVersion contVer: newContentVersionFiles){
            if(contVer.ContentDocumentId!=null && contVer.SharingPrivacy != 'P' && contVer.FileType == 'SNOTE'){
                contentDocIds.add(contVer.ContentDocumentId); //Add contentDocument Ids to set
                //contentVersionList.add(contVer); //Add contentVersion to List
            }
        }  
        //Based on contentDocumentID check if the associated LinkedEntityId as PartnerFundRequest or PartnerFundClaim
        if(contentDocIds!=null && contentDocIds.size()>0){
            for(ContentDocumentLink cntLink : [Select Id, LinkedEntityId,ContentDocumentId From ContentDocumentLink Where ContentDocumentId IN:contentDocIds]){
                if(!String.isEmpty(String.valueOf(cntLink.LinkedEntityId)) && eligibleObjectForPrivateNotes.contains(cntLink.LinkedEntityId.getSObjectType().getDescribe().getName()) ){
                         conVerToBeUpdated.add(cntLink.ContentDocumentId);                     
                }
            }
        }
        //Update contentVersion privacy as 'Private' for Notes
        if(conVerToBeUpdated!=null && conVerToBeUpdated.size()>0){
            for(ContentVersion contVer: newContentVersionFiles){      
                    if(conVerToBeUpdated.contains(contVer.ContentDocumentId) && contVer.FileType == 'SNOTE'){
                    contVer.SharingPrivacy = 'P';
                   }
            }
        }
    }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
    }
        
    }
}