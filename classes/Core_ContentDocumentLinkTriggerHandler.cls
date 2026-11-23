/****************************************************************************************************************************************
* Class Name  : Core_ContentDocuemntLinkTriggerHandler 
* Version     : 1.0 
* Created Date: 07-15-2019
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AD    07-15-2019       Trigger Handler Class for upload content files
*****************************************************************************************************************************************/
public class Core_ContentDocumentLinkTriggerHandler extends TriggerHandler {
    /**
* @description : Method to execute the actions in before insert context of Core_ContentDocumentLinkTriggerHandler
*/
    public override void beforeInsert() {
        //Metadata function switch - isActive
        if (isActive('Core_MDF_RestrictPayFileUpldBeforeInsert')) {
            //Invoke service handler function on before insert
            Core_ContentDocumentLinkServiceHandler.fileUploadProcessOnBeforeInsert((List<ContentDocumentLink>) Trigger.NEW);
        }

         if (isActive('Core_MDF_RestrictVATFileUpldBeforeInsert')){
            //Invoke service handler function on before insert
            Core_ContentDocumentLinkServiceHandler.vatFileNameChangeAndValidations((List<ContentDocumentLink>) Trigger.NEW);
        }
        //Method to make notes sharing to private
        /*if (isActive('Core_MDF_UpdateNotesPrivacyToPrivate')){
            Core_ContentDocumentLinkServiceHandler.updateSharingPrivacyForNotes((List<ContentDocumentLink>) Trigger.NEW);
        }*/
        
    }
    
    public override void afterInsert(){
         if (!isActive('Core_MDF_ByPassUpdatingNotesPrivacy') && !isActive('Core_MDF_ByPassNotesUpdatesToPrivate')){
            Core_ContentDocumentLinkServiceHandler.updateSharingPrivacyForNotes((List<ContentDocumentLink>) Trigger.NEW);
        }
    }

}