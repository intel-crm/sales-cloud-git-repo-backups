trigger Core_ContentDocumentTrigger on ContentDocument (after delete, before delete, before update) {
       new Core_ContentDocumentTriggerHandler().run();
}