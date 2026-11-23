trigger contentDocumentLinkTrigger on ContentDocumentLink (after insert,after update,after delete) {
   new ContentDocumentLinkTriggerHandler().run();
}