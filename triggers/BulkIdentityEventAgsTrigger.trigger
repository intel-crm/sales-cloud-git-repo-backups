trigger BulkIdentityEventAgsTrigger on BulkIdentityAgs__e (after insert) {
    Core_BulkContact_Platform_Event_Handler.handleAfterInsertAgs(Trigger.new);
}