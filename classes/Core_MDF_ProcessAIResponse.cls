@RestResource(urlMapping='/aiResponseFromCDB')
global without sharing class Core_MDF_ProcessAIResponse {
    @HttpGet
    global static String fetchBase64DocumentVersionData() {
        try{
            RestRequest req = RestContext.request;
            
            // Get claimId and contentVersionId from headers
            String claimId = req.headers.get('claimId');
            String contentVersionId = req.headers.get('contentVersionId');
            
            // Validate claimId
            if (String.isBlank(claimId)) {
                RestContext.response.statusCode = 400;
                throw new AuraHandledException('Missing Claim Id in the request headers');
            }
            
            // Validate contentVersionId
            if (String.isBlank(contentVersionId)) {
                RestContext.response.statusCode = 400;
                throw new AuraHandledException('Missing Content Version Id in the request headers');
            }
            
            // Validate the ContentVersion belongs to the claim's audit documents
            Set<String> auditDocumentIds = new Set<String>();
            Map<Id, Id> contentDocIdToClaimId = new Map<Id,Id>();
            for(Core_MDF_Audit_Document__c audDoc: [
                SELECT Core_MDF_Document_Id__c, Core_MDF_Claim__c 
                FROM Core_MDF_Audit_Document__c 
                WHERE Core_MDF_Claim__c =: claimId
            ]){
                auditDocumentIds.add(audDoc.Core_MDF_Document_Id__c);
                contentDocIdToClaimId.put(audDoc.Core_MDF_Document_Id__c, audDoc.Core_MDF_Claim__c);
            }
            
            // Query the single ContentVersion with fields needed for headers
            ContentVersion cv = [
                SELECT Id, ContentDocumentId, VersionData, Title, FileExtension, ContentSize, PathOnClient
                FROM ContentVersion
                WHERE Id = :contentVersionId
                LIMIT 1
            ];
            
            // Check if ContentVersion exists
            if (cv == null) {
                RestContext.response.statusCode = 404;
                RestContext.response.addHeader('Content-Type', 'application/json');
                Map<String, Object> err = new Map<String, Object>{
                    'error' => 'ContentVersion not found',
                    'contentVersionId' => contentVersionId,
                    'claimId' => claimId,
                    'timestamp' => DateTime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
                };
                System.debug(LoggingLevel.WARN, 'Core_MDF_ProcessAIResponse ContentVersion not found for CV: ' + contentVersionId);
                return JSON.serialize(err);
            }
            
            // Ensure the requested version is among audit documents of the claim
            if (!auditDocumentIds.contains(cv.ContentDocumentId)) {
                RestContext.response.statusCode = 403;
                throw new AuraHandledException('Requested ContentVersion is not associated with the provided Claim');
            }
            
            // Prepare filename using PathOnClient when available (like ContentVersionRestAPI)
            String filename = String.isNotBlank(cv.PathOnClient) ? cv.PathOnClient : cv.Title + '.' + cv.FileExtension;
            
            // Diagnostic: if VersionData is empty or null, return JSON error instead of streaming
            Integer sizeBytes = (cv.VersionData == null) ? 0 : cv.VersionData.size();
            if (sizeBytes == 0) {
                RestContext.response.statusCode = 403;
                RestContext.response.addHeader('Content-Type', 'application/json');
                Map<String, Object> err = new Map<String, Object>{
                    'error' => 'VersionData not accessible for this user or empty file.',
                    'hint' => 'Verify ContentDocumentLink sharing/visibility and user access to the linked record/library.',
                    'contentVersionId' => cv.Id,
                    'contentDocumentId' => cv.ContentDocumentId,
                    'claimId' => claimId,
                    'timestamp' => DateTime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
                };
                System.debug(LoggingLevel.WARN, 'Core_MDF_ProcessAIResponse VersionData size is 0 for CV: ' + cv.Id + ', CD: ' + cv.ContentDocumentId);
                return JSON.serialize(err);
            }
            
            // Set response headers for binary streaming (fix for client-side issues)
            // Set appropriate content type based on file extension
            String contentType = getContentType(cv.FileExtension);
            RestContext.response.addHeader('Content-Type', contentType);
            
            // Set cache headers
            RestContext.response.addHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
            RestContext.response.addHeader('Pragma', 'no-cache');
            RestContext.response.addHeader('Expires', '0');
            
            // Set content disposition header
            RestContext.response.addHeader('Content-Disposition', 'attachment; filename="' + filename + '"');
            
            // Add debugging headers with metadata
            RestContext.response.addHeader('X-ContentVersion-Id', cv.Id);
            RestContext.response.addHeader('X-ContentDocument-Id', cv.ContentDocumentId);
            RestContext.response.addHeader('X-File-Title', cv.Title);
            RestContext.response.addHeader('X-File-Extension', cv.FileExtension != null ? cv.FileExtension : '');
            RestContext.response.addHeader('X-File-Size', String.valueOf(cv.ContentSize));
            
            // Temporary debug header to verify server-side byte count
            RestContext.response.addHeader('X-Server-Size', String.valueOf(sizeBytes));
            RestContext.response.responseBody = cv.VersionData;
            
            // Log the size of payload (bytes)
            System.debug(LoggingLevel.INFO, 'Core_MDF_ProcessAIResponse streaming bytes: ' + sizeBytes + ' filename: ' + filename);
            
            // Return null to indicate body has been written
            return null;
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            // Return JSON error for exceptions to avoid browser confusion
            RestContext.response.statusCode = 500;
            RestContext.response.addHeader('Content-Type', 'application/json');
            Map<String, Object> err = new Map<String, Object>{
                'error' => 'Internal server error occurred',
                'message' => e.getMessage()
            };
            System.debug(LoggingLevel.ERROR, 'Core_MDF_ProcessAIResponse Exception: ' + e.getMessage());
            return JSON.serialize(err);
        }
    }
    
    /**
     * Get appropriate MIME type based on file extension
     */
    private static String getContentType(String fileExtension) {
        if (String.isBlank(fileExtension)) {
            return 'application/octet-stream';
        }
        
        Map<String, String> mimeTypes = new Map<String, String>{
            'pdf' => 'application/pdf',
            'doc' => 'application/msword',
            'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'xls' => 'application/vnd.ms-excel',
            'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'ppt' => 'application/vnd.ms-powerpoint',
            'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
            'txt' => 'text/plain',
            'csv' => 'text/csv',
            'json' => 'application/json',
            'xml' => 'application/xml',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png' => 'image/png',
            'gif' => 'image/gif',
            'bmp' => 'image/bmp',
            'zip' => 'application/zip',
            'rar' => 'application/x-rar-compressed',
            'mp4' => 'video/mp4',
            'avi' => 'video/x-msvideo',
            'mp3' => 'audio/mpeg',
            'wav' => 'audio/wav'
        };
        
        String lowerExtension = fileExtension.toLowerCase();
        return mimeTypes.containsKey(lowerExtension) ? 
               mimeTypes.get(lowerExtension) : 
               'application/octet-stream';
    }

    
}