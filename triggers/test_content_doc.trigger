trigger test_content_doc on ContentDocument (before Delete) {
//List<ContentDocumentLink> contentdocumentlinks = new List<ContentDocumentLink>();
   /* Id quoteId;
    List<Id> contDocLinkId = new List<Id>();
    for(ContentDocument cd : (List<ContentDocument>)Trigger.old){
            contDocLinkId.add(cd.Id);
        //cd.addError('CANNOT DELETE THIS TOPIC'+cd.Id+contDocLinkId);
        }
    system.debug('contDocLinkId:11'+contDocLinkId);
   List<ContentDocumentLink> contentdocumentlinks = [select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where ContentDocumentId In: contDocLinkId];
    system.debug('content:'+contentdocumentlinks);
    //Pricing_TrackAttachmentDeletionHandler.conentDocLinkDtls(contentdocumentlinks);*/
}