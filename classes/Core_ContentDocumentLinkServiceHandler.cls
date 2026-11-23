/****************************************************************************************************************************************
* Class Name  : Core_ContentDocuemntLinkServiceHandler 
* Version     : 1.0 
* Created Date: 07-15-2019
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AD    07-15-2019       Service handler Class for upload content files
*****************************************************************************************************************************************/
public without sharing class Core_ContentDocumentLinkServiceHandler {
    
    Public static List<string> eligibleObjectForPrivateNotes = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Object_Eligible_ForPrivate_Note').split(';');
    //Map of ContentDocumentLink to EntityMap Name(SobjectName)
    Public Static Map<Id,String> conDocLinkToEntityNameMap = new Map<Id,String>();
    
    public static void fileUploadProcessOnBeforeInsert(List<ContentDocumentLink> newContentFiles){
        //This object type check is to invoke restrictOnUploadPaymentFile only for payment run
        //Label.Core_ObjectCodeForRestrictUploadFiles - Core_MDF_Payment_Run__c
        List<ContentDocumentLink> paymentRunContentFilesList = new List<ContentDocumentLink>();
        for(ContentDocumentLink contentdocLink:newContentFiles){
            if(!String.isEmpty(String.valueOf(contentdocLink.LinkedEntityId))){
                conDocLinkToEntityNameMap.put(contentdocLink.id,contentdocLink.LinkedEntityId.getSObjectType().getDescribe().getName());
            }
            
            if(conDocLinkToEntityNameMap.containskey(contentdocLink.id)){
                if(conDocLinkToEntityNameMap.get(contentdocLink.id).Equals(Label.Core_ObjectCodeForRestrictUploadFiles)){
                paymentRunContentFilesList.add(contentdocLink);
                }
            }  
                
        }
        System.debug('paymentRunContentFilesList'+paymentRunContentFilesList);

        if(paymentRunContentFilesList.size() > 0 && paymentRunContentFilesList != null) {
            Core_MDF_PaymentUtility.restrictOnUploadPaymentFile(paymentRunContentFilesList);
        }
        
    }

    public static void vatFileNameChangeAndValidations(List<ContentDocumentLink> newContentFiles){
        //Invoke function to restrict payment file upload manually
        Core_MDF_PFC_VAT_ServiceHandler.vatFileNameChangeAndValidations(newContentFiles);   
        
    }
    
/****************************************************************************************************************************************
        Method Name:                                             updateSharingPrivacyForNotes
        @parameters:                                             List<ContentVersion> 
        Description:                                             To update the sharingPrivacy on Notes as 'P'(Private) for PartnerFundRequest & PartnerFundClaim
        Added By & Date:                                         Mohit & Date : 31/May/2024
*****************************************************************************************************************************************/     
public static void updateSharingPrivacyForNotes(List<ContentDocumentLink> newContentFiles){
        List<Id> conDocId = new List<Id>();
        List<ContentVersion> conVerToBeUpdated = new List<ContentVersion>();
        
    try{
        //Getting contentDocumentId from contentdocumentlink for eligibale objects based on EntityId
        for(ContentDocumentLink cd1 : newContentFiles){
           if(eligibleObjectForPrivateNotes.contains((!conDocLinkToEntityNameMap.isEmpty() && conDocLinkToEntityNameMap.containskey(cd1.id)) ? conDocLinkToEntityNameMap.get(cd1.id) : cd1.LinkedEntityId.getSObjectType().getDescribe().getName())){
            
                conDocId.add(cd1.ContentDocumentId);
           } 
                
            
        }
        //Updating contentVersion sharing privacy to Private('P') for the Notes
        if(conDocId!=null && conDocId.size()>0){
           List<ContentVersion> contentVer = [Select Id, ContentDocumentId, FileType, SharingPrivacy FROM ContentVersion where ContentDocumentId IN: conDocId];
            System.debug('Content Version Record-->'+contentVer);
            for(ContentVersion conVersion : contentVer){
                if(conVersion.FileType == 'SNOTE'){
                	conVersion.SharingPrivacy = 'P';
                    conVerToBeUpdated.add(conVersion);
                }
            }
            update conVerToBeUpdated;
        }
        
    }
    catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
    }
        
    }
}