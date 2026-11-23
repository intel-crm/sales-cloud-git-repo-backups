trigger ContentVersionTrigger on ContentVersion (after insert) {
    // Call the handler Class
    ContentVersionTriggerHandler.createPublicLinkForFile(Trigger.New, Trigger.newMap);
}