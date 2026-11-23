public class Pricing_TrackAttachmentDeletionHandler {
    
    public static void conentDocLinkDtls(List<ContentDocument> oldContentLList){
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> contDocLinkId = new Set<Id>();
        Map<Id,String> quoteIdToConDocTitle  = new Map<Id,String>();
        String deletionLog;
        for(ContentDocument cd : oldContentLList){
            contDocLinkId.add(cd.Id);
            //cd.addError('CANNOT DELETE THIS TOPIC'+cd.Id+contDocLinkId);
        }
        List<ContentDocumentLink> contentdocumentlinks = [select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where ContentDocumentId In: contDocLinkId];
        
        for (ContentDocumentLink link : contentdocumentlinks) {
            
            if(link.LinkedEntityId.getSObjectType() == SBQQ__Quote__c.SObjectType){
                //link.addError('CANNOT DELETE THIS TOPIC');
                deletionLog = UserInfo.getName();
                quoteIds.add(link.LinkedEntityId); 
            }
        }
        
        if (quoteIds.size() > 0) {
            for(ContentDocumentLink contentDocLink : [Select Id,LinkedEntityId,ContentDocumentId,ContentDocument.Title from ContentDocumentLink where LinkedEntityId=:quoteIds]){
                quoteIdToConDocTitle.put(contentDocLink.LinkedEntityId,contentDocLink.ContentDocument.Title); 
            }           
        }
        
        if(quoteIdToConDocTitle.size()>0){
            addDeletedLog(quoteIdToConDocTitle);
        }
    }
    public static void addDeletedLog(Map<Id,String> quoteIdToConDocTitle) {
        SBQQ__Quote__c quotes = [select id,Pricing_Deleted_Attachment__c from SBQQ__Quote__c where id =: quoteIdToConDocTitle.keyset() and Pricing_Quote_Program_Nm__c = 'Tender'];
        if(quotes.Pricing_Deleted_Attachment__c != '' && quotes.Pricing_Deleted_Attachment__c != null){
            quotes.Pricing_Deleted_Attachment__c = quotes.Pricing_Deleted_Attachment__c + quoteIdToConDocTitle.get(quotes.Id) +', userName: ' +UserInfo.getUserEmail();
        }else{
            quotes.Pricing_Deleted_Attachment__c =  'File Name: '+quoteIdToConDocTitle.get(quotes.Id)+', userName: ' +UserInfo.getUserEmail();  
        }//Pricing_Deleted_Attachment_Log__c
        system.debug('quotes:'+quotes);
        
        //log text area
        //next line
        update quotes;
    }
    
}