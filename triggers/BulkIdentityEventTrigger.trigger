trigger BulkIdentityEventTrigger on BulkIdentity__e (after insert) {
    Core_BulkContact_Platform_Event_Handler.handleAfterInsert(Trigger.new);
}