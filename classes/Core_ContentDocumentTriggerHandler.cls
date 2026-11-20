/****************************************************************************************************************************************
* Class Name  : Core_ContentDocumentTriggerHandler 
* Version     : 1.0 
* Created Date: 14-06-2023
* Modification Log :
* Developer            		  Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hira(Accenture - Unicorn)   14-06-2023         Trigger Handler Class for files
Aravind                       01-08-2024         Added method preventDeletionForPartners
*****************************************************************************************************************************************/
public class Core_ContentDocumentTriggerHandler extends TriggerHandler{
	/*if(Trigger.isBefore && Trigger.isDelete){
         Core_RestrictDeleteNotes.restrictDeleteOppNotes(trigger.old);
     }*/ 
    public override void afterDelete() {
        if(isActive('Core_AccountPlanAttachmentCount')){
       		Core_AccountPlanFiles.AccountPlanContentDocument(Trigger.Old);
        }
    }

    public override void beforeDelete() {
        PCC_ContentDocumentHelper.preventDeletionForPartners(trigger.old);
    }

    public override void beforeUpdate() {
        PCC_ContentDocumentHelper.preventDeletionForPartners(trigger.new);
    }
}