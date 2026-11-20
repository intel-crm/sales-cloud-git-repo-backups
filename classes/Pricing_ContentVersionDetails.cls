/********************************************************************************************************************
 * Class Name            : Pricing_ContentVersionDetails
 * Version               : 1.0
 * Created Date          :04-07-2026
 * Modification Log      :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 * Sinduja                04-07-2026        REST API to retrieve ContentVersion download URL
 ******************************************************************************************************************************************************/
@RestResource(urlMapping='/quote/cdb/pricingContentVersionDetails')
global with sharing class Pricing_ContentVersionDetails {
    
    // Error Codes
    private static final String ERROR01 = 'ERROR01'; // Request body is required
    private static final String ERROR02 = 'ERROR02'; // Invalid JSON payload
    private static final String ERROR03 = 'ERROR03'; // Record Id is required
    private static final String ERROR04 = 'ERROR04'; // ContentDocument IDs are required
    private static final String ERROR05 = 'ERROR05'; // userName is required
    private static final String ERROR06 = 'ERROR06'; // User not authorized to access quote documents
    private static final String ERROR07 = 'ERROR07'; // No documents found for the provided contentDocumentIds
    private static final String ERROR08 = 'ERROR08'; // Internal Server Error
    
    /*****************************************************************************************************************************************
    Method Name             :getContentVersionDownloadUrl
    Description             :Main REST endpoint to retrieve ContentVersion download URLs for specified app files.
    @Added By               :Sinduja - Pricing_ContentVersionDownloadUrlAPI
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    @HttpPost
    global static void getContentVersionDownloadUrl() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        try {
            // Set default response headers
            response.addHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
            response.addHeader('Pragma', 'no-cache');
            response.addHeader('Expires', '0');
            
            // Parse JSON body
            if (request.requestBody == null) {
                setErrorResponse(response, ERROR01);
                return;
            }
            String body = request.requestBody.toString();
            RequestWrapper wrapper;
            try {
                wrapper = (RequestWrapper) JSON.deserialize(body, RequestWrapper.class);
            } catch (Exception ex) {
                setErrorResponse(response, ERROR02);
                return;
            }
            
            // Validate inputs
            if (wrapper == null || String.isBlank(wrapper.quoteId)) {
                setErrorResponse(response, ERROR03);
                return;
            }
            if (wrapper.contentDocumentIds == null || wrapper.contentDocumentIds.isEmpty()) {
                setErrorResponse(response, ERROR04);
                return;
            }
            if (String.isBlank(wrapper.userName)) {
                setErrorResponse(response, ERROR05);
                return;
            }
            
            // Check user access to the quote
            if (!checkRecordAccess(wrapper.quoteId, wrapper.userName)) {
                setErrorResponse(response, ERROR06);
                return;
            }
            
            // Build response map { contentDocumentId : ResponseWrapper (url,title) or "Document not found" }
            Map<String, Object> resultMap = getContentDocumentIdToInfoMap(wrapper.contentDocumentIds, wrapper.quoteId);
            
            // Determine if at least one valid URL exists
            Boolean hasAnySuccess = false;
            for (String keyId : resultMap.keySet()) {
                Object val = resultMap.get(keyId);
                if (val instanceof ResponseWrapper) {
                    ResponseWrapper responseWrap = (ResponseWrapper) val;
                    if (responseWrap != null && !String.isBlank(responseWrap.url) && responseWrap.url.startsWith('http')) {
                        hasAnySuccess = true;
                        break;
                    }
                }
            }
            
            if (hasAnySuccess) {
                setFilesMapResponse(response, resultMap);
            } else {
                // none valid
                setErrorResponse(response, ERROR07);
            }
        } catch (Exception exp) {
            setErrorResponse(response, ERROR08);
            Core_MDF_CCP_UtilityClass.logError(exp);
        }
    }
    
    /*****************************************************************************************************************************************
    Method Name             :getContentDocumentIdToInfoMap
    Description:            :Retrieves download URLs and Title for specified Content Document IDs within a quote.
    @Added By:              :Sinduja - 04-07-2026
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    private static Map<String, Object> getContentDocumentIdToInfoMap(List<String> contentDocumentIds, String quoteId) {
        String domain = Url.getOrgDomainUrl().toExternalForm();
        if (domain.endsWith('/')) {
            domain = domain.substring(0, domain.length() - 1);
        }
        
        // Prepare defaults as "Document not found" for each requested id
        Map<String, Object> filesMap = new Map<String, Object>();
        for (String fileId : contentDocumentIds) {
            filesMap.put(fileId, 'Document not found');
        }
        System.debug('INSIDE APEX contentDocumentIds '+contentDocumentIds);
        System.debug('INSIDE APEX recId '+quoteId);
        List<ContentDocumentLink> cdLinkRecList=[SELECT Id,LinkedEntityId,ContentDocumentId,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds];
        system.debug('INSIDE APEX QUERY '+cdLinkRecList);
         // Bulk query for all requested content document ids within the quote and process in single loop
        for (ContentDocumentLink cdLinkRec: [
            SELECT Id,LinkedEntityId,ContentDocumentId,
                ContentDocument.LatestPublishedVersionId,
                ContentDocument.LatestPublishedVersion.FileExtension,
                ContentDocument.Title            
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :quoteId
            AND ContentDocumentId IN :contentDocumentIds
        ]) {
            system.debug('INSIDE APEX FOR LOOP:'+cdLinkRec);
            // If we have a valid document ID and non-blank ContentVersion Id, create download URL with title
            if (cdLinkRec.ContentDocument.LatestPublishedVersionId != null && !String.isBlank(cdLinkRec.ContentDocument.LatestPublishedVersionId)) {
                ResponseWrapper responseWrap = new ResponseWrapper();
                responseWrap.url = domain + '/services/data/v62.0/sobjects/ContentVersion/' + cdLinkRec.ContentDocument.LatestPublishedVersionId +'/VersionData';
                responseWrap.title = cdLinkRec.ContentDocument.Title+'.'+cdLinkRec.ContentDocument.LatestPublishedVersion.FileExtension;
                //responseWrap.title = cdLinkRec.ContentDocument.Title;
                filesMap.put(cdLinkRec.ContentDocumentId, responseWrap);
            }
        }
        
        return filesMap;
    }
    
    /*****************************************************************************************************************************************
    Method Name          :checkRecordAccess
    Description          :Checks if a user has read access to a specific quote using UserRecordAccess.
    @Added By            :Sinduja - 04-07-2026
    Modified By         Date:       Changes:
         ******************************************************************************************************************************************/
    //Check if user has access to the specified quote using UserRecordAccess
    private static Boolean checkRecordAccess(String quoteId, String userName) {
        String usernameLike = userName + '%';
        List<User> users = [SELECT Id FROM User WHERE UserName LIKE :usernameLike AND IsActive = true LIMIT 1  ];
        
        if (users.isEmpty()) {
            return false;
        }
        Id requestedUserId = users[0].Id;
        
        // Check access using UserRecordAccess
        List<UserRecordAccess> accessList = [
            SELECT recordId, HasReadAccess
            FROM UserRecordAccess
            WHERE UserId = :requestedUserId
            AND recordId = :quoteId
            LIMIT 1
        ];
        
        if (accessList.isEmpty()) {
            return false;
        }
        return accessList[0].HasReadAccess;
    }
    
    /*****************************************************************************************************************************************
    Method Name            :setFilesMapResponse
    Description            :Sets the HTTP response with a JSON object containing file IDs and their download URLs.
    @Added By              :Sinduja - 04-07-2026
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    private static void setFilesMapResponse(RestResponse response, Map<String, Object> filesMap) {
        response.statusCode = 200;
        response.addHeader('Content-Type', 'application/json');
        
        response.responseBody = Blob.valueOf(JSON.serialize(filesMap));
    }
    
    /*****************************************************************************************************************************************
    Method Name         :getErrorDetails
    Description         :Retrieves error details for a given error code including status code and message.
    @Added By           :Sinduja - 04-07-2026
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    private static Map<String, Object> getErrorDetails(String errorCode) {
        Map<String, Object> errorDetails = new Map<String, Object>();
        
        switch on errorCode {
            when 'ERROR01' {
                errorDetails.put('statusCode', 400);
                errorDetails.put('message', 'Request body is required');
            }
            when 'ERROR02' {
                errorDetails.put('statusCode', 400);
                errorDetails.put('message', 'Invalid JSON payload');
            }
            when 'ERROR03' {
                errorDetails.put('statusCode', 400);
                errorDetails.put('message', 'Quote ID is required');
            }
            when 'ERROR04' {
                errorDetails.put('statusCode', 400);
                errorDetails.put('message', 'ContentDocument IDs are required');
            }
            when 'ERROR05' {
                errorDetails.put('statusCode', 400);
                errorDetails.put('message', 'userName is required');
            }
            when 'ERROR06' {
                errorDetails.put('statusCode', 403);
                errorDetails.put('message', 'User not authorized to access quote documents');
            }
            when 'ERROR07' {
                // None valid found case
                errorDetails.put('statusCode', 404);
                errorDetails.put('message', 'No documents found for the provided contentDocumentIds');
            }
            when 'ERROR08' {
                errorDetails.put('statusCode', 500);
                errorDetails.put('message', 'Internal Server Error');
            }
            when else {
                errorDetails.put('statusCode', 500);
                errorDetails.put('message', 'Unknown error occurred');
            }
        }
        
        return errorDetails;
    }
    
    /*****************************************************************************************************************************************
    Method Name        :setErrorResponse
    Description        :Sets the HTTP response with an error message and appropriate status code based on the error code.
    @Added By          :Sinduja - 04-07-2026 
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    //Set error response
    private static void setErrorResponse(RestResponse response, String errorCode) {
        Map<String, Object> errorDetails = getErrorDetails(errorCode);
        Integer statusCode = (Integer) errorDetails.get('statusCode');
        String message = (String) errorDetails.get('message');
        
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
    
    //wrapper for POST request body
    public class RequestWrapper {
        public String quoteId;//Quote Id
        public List<String> contentDocumentIds;
        public String userName;
    }
    public class ResponseWrapper {
        public String url;
        public String title;
    }

}