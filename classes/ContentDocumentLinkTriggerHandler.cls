public class ContentDocumentLinkTriggerHandler extends TriggerHandler{
	public override void afterInsert() {
        ContentlinkBusinessLogic.afterInsertUpdateOperations((List<ContentDocumentLink>)Trigger.new,(Map<Id,ContentDocumentLink>)Trigger.oldMap,Trigger.isInsert);
    }
    public override void afterUpdate() {
        ContentlinkBusinessLogic.afterInsertUpdateOperations((List<ContentDocumentLink>)Trigger.new,(Map<Id,ContentDocumentLink>)Trigger.oldMap,Trigger.isInsert);
    }
    
}