/***************************************************************************************************
 * Apex Class Name: Core_MDF_ContentVersionRestAPI
 * Test Class: NA
 * Version     : 1.0
 * Created Date: 15th Dec 2025
 * Function    :  REST API to retrieve ContentVersion blob data
 * Modification Log :
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Sham      				15/12/2025               Created
 ****************************************************************************************************/
@RestResource(urlMapping='/ContentVersionRestAPI')
global with sharing class Core_MDF_ContentVersionRestAPI {
    
    /**
     * REST POST method to retrieve ContentVersion data
     * Request body:
     * {
         *   "claimId": "<ClaimId>",
         *   "contentVersionId": "<ContentVersionId>",
         *   "userName": "userName"
     * }
     * Response: Binary stream of the requested file
     */
    @HttpPost
    global static void postContentVersion() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        try {
            // Set default response headers for file download
            response.addHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
            response.addHeader('Pragma', 'no-cache');
            response.addHeader('Expires', '0');
            
            // Parse JSON body
            if (request.requestBody == null) {
                setErrorResponse(response, 400, 'Request body is required');
                return;
            }
            String body = request.requestBody.toString();
            RequestWrapper wrapper;
            try {
                wrapper = (RequestWrapper) JSON.deserialize(body, RequestWrapper.class);
            } catch (Exception ex) {
                setErrorResponse(response, 400, 'Invalid JSON payload');
                return;
            }
            
            // Validate inputs
            if (wrapper == null || String.isBlank(wrapper.claimId)) {
                setErrorResponse(response, 400, 'Claim ID is required');
                return;
            }
            if (String.isBlank(wrapper.contentVersionId)) {
                setErrorResponse(response, 400, 'ContentVersion ID is required');
                return;
            }
            if (String.isBlank(wrapper.userName)) {
                setErrorResponse(response, 400, 'userName is required');
                return;
            }
            
            // Check user access to the claim
            if (!checkClaimAccess(wrapper.claimId,wrapper.userName)) {
                setErrorResponse(response, 403, 'Requested user is not authorized to access the claim Documents');
                return;
            }
            
            handleGetByContentVersionIdWithClaimValidation(wrapper.contentVersionId, wrapper.claimId, response);
            
        } catch (Exception e) {
            setErrorResponse(response, 500, 'Internal Server Error: ' + e.getMessage());
        }
    }
    
    //Retrieve ContentVersion by specific ID with claim validation
    private static void handleGetByContentVersionIdWithClaimValidation(String contentVersionId, String claimId, RestResponse response) {
        try {
            // Check if the requested content version ID exists in the audit documents
            Boolean isValidDocument = false;
            for (Core_MDF_Audit_Document__c auditDoc : [ SELECT Id, Core_MDF_ContentVersion_Id__c 
                                                         FROM Core_MDF_Audit_Document__c 
                                                         WHERE Core_MDF_Claim__c = :claimId ])
            {
                if (auditDoc.Core_MDF_ContentVersion_Id__c == contentVersionId) {
                    isValidDocument = true;
                    break;
                }
            }
            // If the content version is not in the audit documents, return error
            if (!isValidDocument) {
                setErrorResponse(response, 403, 'Requested ContentVersion is not associated with the provided Claim');
                return;
            }
            
            List<ContentVersion> versions = [ SELECT Id, Title, FileExtension, ContentSize, VersionData, ContentDocumentId, CreatedDate, LastModifiedDate, PathOnClient
                                              FROM ContentVersion 
                                              WHERE Id = :contentVersionId
                                              LIMIT 1 ];
            ContentVersion contVesrion = versions.isEmpty() ? null : versions[0];
            
            // Check if ContentVersion exists
            if (contVesrion == null) {
                setErrorResponse(response, 404, 'ContentVersion not found');
                return;
            }
            
            setBlobResponse(response, contVesrion);
            
        } catch (Exception e) {
            setErrorResponse(response, 500, 'Error processing request: ' + e.getMessage());
        }
    }
    
    //Check if user has access to the specified claim
    private static Boolean checkClaimAccess(String claimId, String userName) {
        // Find user by username
        userName = userName + '%';
        List<User> usrID = [SELECT Id FROM User WHERE UserName LIKE :userName AND IsActive = true LIMIT 1];
        if (usrID.isEmpty()) {
            return false;
        }
        Id requestedUserId = usrID[0].Id;
        // Get group IDs from PartnerFundClaimShare
        Set<Id> groupId = new Set<Id>();
        for (PartnerFundClaimShare pfc : [
            SELECT UserOrGroupId, ParentId 
            FROM PartnerFundClaimShare 
            WHERE ParentId = :claimId
        ]) {
            groupId.add(pfc.UserOrGroupId);
        }
        
        // Check if user has access through groups
        Boolean claimAccess = false;
        if (!groupId.isEmpty()) {
            List<GroupMember> usersListWithGroupAccess = [
                SELECT Id, UserOrGroupId 
                FROM GroupMember 
                WHERE GroupId IN :groupId AND UserOrGroupId = :requestedUserId
                LIMIT 1
            ];
            if (!usersListWithGroupAccess.isEmpty()) {
                claimAccess = true;
            }
        }
        
        return claimAccess;
    }
    
    //Set successful blob response
    private static void setBlobResponse(RestResponse response, ContentVersion contVesrion) {
        response.statusCode = 200;
        
        // Set appropriate content type based on file extension
        String contentType = getContentType(contVesrion.FileExtension);
       // response.addHeader('Content-Type', contentType);
        response.addHeader('Content-Type', 'application/octetstream');
        // Set content disposition for file download
        String filename = String.isNotBlank(contVesrion.PathOnClient) ? contVesrion.PathOnClient : contVesrion.Title + '.' + contVesrion.FileExtension;
        response.addHeader('Content-Disposition', 'attachment; filename="' + filename + '"');
        
        // Set the blob data as response body
        response.responseBody = contVesrion.VersionData;
        
        // Add custom headers with metadata
        response.addHeader('X-ContentVersion-Id', contVesrion.Id);
        response.addHeader('X-ContentDocument-Id', contVesrion.ContentDocumentId);
        response.addHeader('X-File-Title', contVesrion.Title);
        response.addHeader('X-File-Extension', contVesrion.FileExtension != null ? contVesrion.FileExtension : '');
    }
    
    //Set error response
    private static void setErrorResponse(RestResponse response, Integer statusCode, String message) {
        response.statusCode = statusCode;
        response.addHeader('Content-Type', 'application/json');
        
        Map<String, Object> errorResponse = new Map<String, Object>{
            'error' => true,
            'message' => message,
            'statusCode' => statusCode,
            'timestamp' => DateTime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
        };
        
        response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
    }
    
    
    //Get appropriate MIME type based on file extension
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
        return mimeTypes.containsKey(lowerExtension) ? mimeTypes.get(lowerExtension) : 'application/octet-stream';
    }
    
    //wrapper for POST request body
    public class RequestWrapper {
        public String claimId;
        public String contentVersionId;
        public String userName;
    }
}