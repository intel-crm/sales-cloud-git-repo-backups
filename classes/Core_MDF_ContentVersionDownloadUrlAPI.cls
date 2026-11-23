/********************************************************************************************************************
 * Class Name            : Core_MDF_ContentVersionDownloadUrlAPI
 * Version               : 1.0
 * Created Date          : 12-19-2025
 * Modification Log      :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 * Sham                12-19-2025        REST API to retrieve ContentVersion download URL
 ******************************************************************************************************************************************************/
@RestResource(urlMapping='/mdf/cdb/contentVersionDownloadUrlAPI')
global with sharing class Core_MDF_ContentVersionDownloadUrlAPI {
    
    // Error Codes
    private static final String ERROR01 = 'ERROR01'; // Request body is required
    private static final String ERROR02 = 'ERROR02'; // Invalid JSON payload
    private static final String ERROR03 = 'ERROR03'; // Record Id is required
    private static final String ERROR04 = 'ERROR04'; // AppFile IDs are required
    private static final String ERROR05 = 'ERROR05'; // userName is required
    private static final String ERROR06 = 'ERROR06'; // User not authorized to access claim documents
    private static final String ERROR07 = 'ERROR07'; // No documents found for the provided appFileIds
    private static final String ERROR08 = 'ERROR08'; // Internal Server Error
    
    /*****************************************************************************************************************************************
    Method Name             :getContentVersionDownloadUrl
    Description             :Main REST endpoint to retrieve ContentVersion download URLs for specified app files.
    @Added By               :Sham - 12-19-2025
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
            // Audit changes passing recordId instead of claimId
            if (wrapper == null || String.isBlank(wrapper.recordId)) {
                setErrorResponse(response, ERROR03);
                return;
            }
            if (wrapper.appFileIds == null || wrapper.appFileIds.isEmpty()) {
                setErrorResponse(response, ERROR04);
                return;
            }
            if (String.isBlank(wrapper.userName)) {
                setErrorResponse(response, ERROR05);
                return;
            }
            
            // Check user access to the claim
            //Audit changes passing recordId instead of claimId
            if (!checkRecordAccess(wrapper.recordId, wrapper.userName)) {
                setErrorResponse(response, ERROR06);
                return;
            }
            
            // Build response map { appFileId : ResponseWrapper (url,title) or "Document not found" }
            //Audit changes passing recordId instead of claimId
            Map<String, Object> resultMap = getAppFileIdToInfoMap(wrapper.appFileIds, wrapper.recordId);
            
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
    Method Name             :getAppFileIdToInfoMap
    Description:            :Retrieves download URLs and Title for specified app file IDs within a claim.
    @Added By:              :Sham - 12-19-2025
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    private static Map<String, Object> getAppFileIdToInfoMap(List<String> appFileIds, String recordId) {
        String domain = Url.getSalesforceBaseUrl().toExternalForm();
        if (domain.endsWith('/')) {
            domain = domain.substring(0, domain.length() - 1);
        }
        
        // Prepare defaults as "Document not found" for each requested id
        Map<String, Object> filesMap = new Map<String, Object>();
        for (String fileId : appFileIds) {
            filesMap.put(fileId, 'Document not found');
        }
        System.debug('print appFileIds '+appFileIds);
         // Bulk query for all requested appFileIds within the claim and process in single loop
        // Audit change included Core_MDF_Audit__c in query 
        for (Core_MDF_Audit_Document__c auditDoc : [
            SELECT Core_MDF_Old_Document_Id__c, Core_MDF_ContentVersion_Id__c, Core_MDF_Document_Title__c
            FROM Core_MDF_Audit_Document__c
            WHERE (Core_MDF_Claim__c = :recordId OR Core_MDF_Audit__c= :recordId)
            AND Core_MDF_Old_Document_Id__c IN :appFileIds
            AND Core_MDF_SFT_File_Download_Ind__c = false
        ]) {
            // If we have a valid document ID and non-blank ContentVersion Id, create download URL with title
            if (auditDoc.Core_MDF_Old_Document_Id__c != null && !String.isBlank(auditDoc.Core_MDF_ContentVersion_Id__c)) {
                ResponseWrapper responseWrap = new ResponseWrapper();
                responseWrap.url = domain + '/services/data/v62.0/sobjects/ContentVersion/' + auditDoc.Core_MDF_ContentVersion_Id__c +'/VersionData';
                responseWrap.title = auditDoc.Core_MDF_Document_Title__c;
                filesMap.put(auditDoc.Core_MDF_Old_Document_Id__c, responseWrap);
            }
        }
        
        return filesMap;
    }
    
    /*****************************************************************************************************************************************
    Method Name          :checkRecordAccess
    Description          :Checks if a user has read access to a specific claim or case using UserRecordAccess.
    @Added By            :Sham - 12-19-2025
    Modified By         Date:       Changes:
         ******************************************************************************************************************************************/
    //Check if user has access to the specified claim using UserRecordAccess
    private static Boolean checkRecordAccess(String claimId, String userName) {
        String usernameLike = userName + '%';
        List<User> users = [SELECT Id FROM User WHERE UserName LIKE :usernameLike AND IsActive = true LIMIT 1  ];
        
        if (users.isEmpty()) {
            return false;
        }
        Id requestedUserId = users[0].Id;
        
        // Check access using UserRecordAccess
        List<UserRecordAccess> accessList = [
            SELECT RecordId, HasReadAccess
            FROM UserRecordAccess
            WHERE UserId = :requestedUserId
            AND RecordId = :claimId
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
    @Added By              :Sham - 12-19-2025
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
    @Added By           :Sham - 12-19-2025
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
                errorDetails.put('message', 'Claim ID / Case ID is required');
            }
            when 'ERROR04' {
                errorDetails.put('statusCode', 400);
                errorDetails.put('message', 'AppFile IDs are required');
            }
            when 'ERROR05' {
                errorDetails.put('statusCode', 400);
                errorDetails.put('message', 'userName is required');
            }
            when 'ERROR06' {
                errorDetails.put('statusCode', 403);
                errorDetails.put('message', 'User not authorized to access claim documents');
            }
            when 'ERROR07' {
                // None valid found case
                errorDetails.put('statusCode', 404);
                errorDetails.put('message', 'No documents found for the provided appFileIds');
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
    @Added By          :Sham - 12-19-2025
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
        public String recordId;//Audit changes
        public List<String> appFileIds;
        public String userName;
    }

    public class ResponseWrapper {
        public String url;
        public String title;
    }

}