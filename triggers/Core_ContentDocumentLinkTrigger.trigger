/****************************************************************************************************************************************
* Trigger Name      : Core_ContentDocumentLinkTrigger
* Version           : 1.0 
* Created Date      : 07-15-2019
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AD       07-15-2019        Trigger on Content document link object
*****************************************************************************************************************************************/
trigger Core_ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert) {
    // Invoke handler methods
    Core_ContentDocumentLinkTriggerHandler contentDocumentLinkTriggerHandler = new Core_ContentDocumentLinkTriggerHandler();
    contentDocumentLinkTriggerHandler.run();
}