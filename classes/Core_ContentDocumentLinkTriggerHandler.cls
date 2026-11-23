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
    public override void beforeInsert() {
        if (isActive('Core_MDF_RestrictPayFileUpldBeforeInsert')) {
            Core_ContentDocumentLinkServiceHandler.fileUploadProcessOnBeforeInsert((List<ContentDocumentLink>) Trigger.NEW);
        }
    }
    public override void afterInsert() {
        if(isActive('PSG_ValidateCDLAfterInsert')){
            PSG_ContentDocLinkBusinessLogic.afterInsertUpdateOperations((List<ContentDocumentLink>)Trigger.new,(Map<Id,ContentDocumentLink>)Trigger.oldMap,Trigger.isInsert);
        }
        if(isActive('Core_AccountPlanAttachmentCount')){
            Core_AccountPlanFiles.AccountPlanContentDocumentLink(Trigger.New,null,true);
        }	
    }
    
    public override void afterDelete() {
        if(isActive('Core_AccountPlanAttachmentCount')){
            Core_AccountPlanFiles.AccountPlanContentDocumentLink(null,Trigger.Old,false);
        }
    }
}