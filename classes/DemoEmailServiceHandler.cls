global class DemoEmailServiceHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        system.debug('DEMO INSIDE EMAIL SERVICE HANDLER');

        try {
            // Extract record ID from email subject
            String regRequestId = extractRecordId(email.subject);
            
            if (String.isBlank(regRequestId)) {
                System.debug('No valid record ID found in email subject: ' + email.subject);
                result.success = false;
                return result;
            }
            
            system.debug('DEMO Extracted regRequestId: ' + regRequestId);
            
            PRM_Registration_Request__c regRequest = [SELECT Id FROM PRM_Registration_Request__c WHERE Id = :regRequestId LIMIT 1];
            
            // Process attachments as ContentDocuments
            if (email.binaryAttachments != null && !email.binaryAttachments.isEmpty()) {
                system.debug('DEMO INSIDE EMAIL SERVICE regRequest FOUND:'+regRequest);
                
                List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
                
                // Create ContentVersions first
                for (Messaging.InboundEmail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    ContentVersion newContentVersion = new ContentVersion();
                    newContentVersion.Title = bAttachment.fileName;
                    newContentVersion.PathOnClient = bAttachment.fileName;
                    newContentVersion.VersionData = bAttachment.body;
                    newContentVersion.IsMajorVersion = true;
                    contentVersionsToInsert.add(newContentVersion);
                }
                
                if (!contentVersionsToInsert.isEmpty()) {
                    system.debug('DEMO INSIDE insert ContentVersion:'+contentVersionsToInsert);
                    insert contentVersionsToInsert;
                    
                    // Get the ContentDocumentIds from the inserted ContentVersions
                    List<Id> contentVersionIds = new List<Id>();
                    for (ContentVersion cv : contentVersionsToInsert) {
                        contentVersionIds.add(cv.Id);
                    }
                    
                    // Query to get ContentDocumentIds
                    List<ContentVersion> insertedContentVersions = [
                        SELECT Id, ContentDocumentId 
                        FROM ContentVersion 
                        WHERE Id IN :contentVersionIds
                    ];
                    
                    // Create ContentDocumentLinks to associate files with the record
                    List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();
                    for (ContentVersion cv : insertedContentVersions) {
                        ContentDocumentLink newLink = new ContentDocumentLink();
                        newLink.ContentDocumentId = cv.ContentDocumentId;
                        newLink.LinkedEntityId = regRequest.Id;
                        newLink.ShareType = 'V'; // Viewer permission
                        newLink.Visibility = 'AllUsers'; // Visible to all users who can access the record
                        contentDocumentLinksToInsert.add(newLink);
                    }
                    
                    if (!contentDocumentLinksToInsert.isEmpty()) {
                        system.debug('DEMO INSIDE insert ContentDocumentLink:'+contentDocumentLinksToInsert);
                        insert contentDocumentLinksToInsert;
                    }
                }
            }

            result.success = true;
            system.debug('DEMO CONTENT DOCUMENTS INSERTED');
        } catch (Exception e) {
            System.debug('Error in Email Service: ' + e.getMessage());
            result.success = false;
        }

        return result;
    }
    
    // Helper method to extract record ID from email subject
    public static String extractRecordId(String subject) {
        if (String.isBlank(subject)) return null;
        Matcher m = Pattern.compile('[a-zA-Z0-9]{15,18}').matcher(subject);
        while (m.find()) {
            try { return Id.valueOf(m.group()); } catch (Exception e) { continue; }
        }
        return null;
    }
}