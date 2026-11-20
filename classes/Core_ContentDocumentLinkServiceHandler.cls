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
    public static void fileUploadProcessOnBeforeInsert(List<ContentDocumentLink> newContentFiles){
        //This object type check is to invoke restrictOnUploadPaymentFile only for payment run
        //Label.Core_ObjectCodeForRestrictUploadFiles - Core_MDF_Payment_Run__c
        List<ContentDocumentLink> paymentRunContentFilesList = new List<ContentDocumentLink>();
        for(ContentDocumentLink contentdocLink:newContentFiles){
            if(!String.isEmpty(String.valueOf(contentdocLink.LinkedEntityId)) && 
                contentdocLink.LinkedEntityId.getSObjectType().getDescribe().getName() == Label.Core_ObjectCodeForRestrictUploadFiles) {
                paymentRunContentFilesList.add(contentdocLink);
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
}