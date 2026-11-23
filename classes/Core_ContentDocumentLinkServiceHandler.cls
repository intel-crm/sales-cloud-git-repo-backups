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
        //Invoke function to restrict payment file upload manually
        Core_MDF_PaymentUtility.restrictOnUploadPaymentFile(newContentFiles);       
    }
 }