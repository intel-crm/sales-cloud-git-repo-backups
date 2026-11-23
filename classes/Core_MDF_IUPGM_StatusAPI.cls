/*****************************************************************************************************
Class Name          :    Core_MDF_IUPGM_StatusAPI
Test Class Name     :    Core_MDF_IUPGM_StatusAPI_Test
Description         :    REST endpoint that exposes the current processing status for an IUPGM
                          staging request and formats the response for chatbot consumption.
Created By          :    Ramapriya
******************************************************************************************************/
@RestResource(urlMapping='/access/fetchstatus')
global without sharing class Core_MDF_IUPGM_StatusAPI {

    private static final Map<String, Map<String, String>> STATUS_LABELS_BY_TYPE = 
        new Map<String, Map<String, String>>{
            'GRANT' => new Map<String, String>{
                'New' => 'Request Received',
                'AGS_User_Creation_Pending' => 'Creating Salesforce User',
                'AGS_PS_Pending' => 'Awaiting AGS Approval',
                'Completed' => 'Access Granted',
                'Validation_Failed' => 'Validation Failed',
                'External_User_Blocked' => 'Request Blocked',
                'AGS_Rejected' => 'AGS Request Rejected',
                'Error' => 'Processing Error'
            },
            'REVOKE' => new Map<String, String>{
                'New' => 'Request Received',
                'AGS_User_Creation_Pending' => 'Deactivating Access',
                'AGS_PS_Pending' => 'Deactivating Access',
                'Completed' => 'Access Removed',
                'Validation_Failed' => 'Validation Failed',
                'External_User_Blocked' => 'Request Blocked',
                'AGS_Rejected' => 'Processing Failed',
                'Error' => 'Processing Error'
            }
        };

    private static final Map<String, String> STATUS_LABELS = new Map<String, String>{
       'New' => 'Request Received',
       'AGS_User_Creation_Pending' => 'Creating Salesforce User',
       'AGS_PS_Pending' => 'Awaiting AGS Approval',
       'Completed' => 'Access Granted',
       'Validation_Failed' => 'Validation Failed',
       'External_User_Blocked' => 'Request Blocked',
       'AGS_Rejected' => 'AGS Request Rejected',
       'Error' => 'Processing Error'
    };
/** Returns the current status for the request number supplied in the REST query string. */
    @HttpGet
    global static String getStatus() {

        RestRequest  req = RestContext.request;
        RestResponse res = RestContext.response;

        Long    startMs      = System.currentTimeMillis();
        String  logResponse  = null;
        Id      logUserId    = null;
        String  logProgram   = null;
        String  logRole      = null;
        String  logError     = null;

        try {

            String requestNumber = req.params.get('requestNumber');
            System.debug('Status check for: ' + requestNumber);

            if (String.isBlank(requestNumber)) {
                res.statusCode = 400;
                return JSON.serialize(new Map<String, Object>{
                    'success' => false,
                    'message' => 'requestNumber parameter is required. '
                        + 'Example: ?requestNumber=REQ-0042'
                });
            }

            List<Core_MDF_IUPGM_Request_Staging__c> records = [
                SELECT  Id,
                        Name,
                        Core_MDF_IUPGM_User__r.Name,
                        Core_MDF_IUPGM_User__r.Email,
                        Core_MDF_IUPGM_Role_nm__c,
                        Core_MDF_IUPGM_Program__c,
                        Core_MDF_Request_Status_nm__c,
                        Core_MDF_Request_Type_nm__c,
                        Core_MDF_Action_nm__c,
                        Core_MDF_AGS_Status_nm__c,
                        Core_MDF_AGS_Request_Type__c,
                        Core_MDF_AGS_Request_Id__c,
                        Core_MDF_Error_Message_txt__c,
                        Core_MDF_Is_IUPGM_Processed__c,
                        CreatedDate,
                        LastModifiedDate
                FROM Core_MDF_IUPGM_Request_Staging__c
                WHERE Name = :requestNumber
                LIMIT 1
            ];

            if (records.isEmpty()) {
                res.statusCode = 404;
                return JSON.serialize(new Map<String, Object>{
                    'success' => false,
                    'message' => 'Request [' + requestNumber + '] not found. '
                        + 'Please check the request number and try again.'
                });
            }

            Core_MDF_IUPGM_Request_Staging__c record = records[0];
            String currentStatus = record.Core_MDF_Request_Status_nm__c;

            // Capture for logging
            logUserId  = record.Core_MDF_IUPGM_User__c;
            logProgram = record.Core_MDF_IUPGM_Program__c;
            logRole    = record.Core_MDF_IUPGM_Role_nm__c;

            // Resolve human-readable Role Label from MDT using permission set name
            String psName = record.Core_MDF_IUPGM_Role_nm__c;
            String roleLabel = psName; // default to API name if not found
            if (String.isNotBlank(psName)) {
                List<Core_MDF_IUPGM_Rule_Config__mdt> mdtRows = [
                    SELECT Core_MDF_Role_Label__c
                    FROM   Core_MDF_IUPGM_Rule_Config__mdt
                    WHERE  Core_MDF_Permission_Set_Name__c = :psName
                    LIMIT  1
                ];
                if (!mdtRows.isEmpty() && String.isNotBlank(mdtRows[0].Core_MDF_Role_Label__c)) {
                    roleLabel = mdtRows[0].Core_MDF_Role_Label__c;
                }
            }

            // Build human-readable message for chatbot to relay to user
            String humanMessage = buildHumanMessage(
                currentStatus,
                record.Core_MDF_Request_Type_nm__c,
                record.Core_MDF_AGS_Status_nm__c,
                record.Core_MDF_AGS_Request_Type__c,
                record.Core_MDF_Error_Message_txt__c,
                record.Core_MDF_IUPGM_User__r.Name
            );

            // Build full response (internal data)
            Map<String, Object> fullResponse = new Map<String, Object>{
                'success'           => true,
                'requestNumber'     => record.Name,
                'userName'          => record.Core_MDF_IUPGM_User__r.Name,
                'requestType'       => record.Core_MDF_Request_Type_nm__c,
                'action'            => record.Core_MDF_Action_nm__c,
                'userEmail'         => record.Core_MDF_IUPGM_User__r.Email,
                'role'              => roleLabel,
                'program'           => record.Core_MDF_IUPGM_Program__c,
                'status'            => currentStatus,
                'isCompleted'       => record.Core_MDF_Is_IUPGM_Processed__c,
                'agsStatus'         => record.Core_MDF_AGS_Status_nm__c,
                'agsRequestId'      => record.Core_MDF_AGS_Request_Id__c,
                'errorMessage'      => record.Core_MDF_Error_Message_txt__c,
                'submittedOn'       => record.CreatedDate,
                'lastUpdated'       => record.LastModifiedDate,
                'statusDescription' => humanMessage
            };

            // Format for chatbot UI display (controlled fields)
            Map<String, Object> uiResponse = formatForUI(fullResponse);

            res.statusCode = 200;
            logResponse = JSON.serialize(uiResponse);
            return logResponse;

        } catch (Exception e) {
            System.debug('STATUS API ERROR: ' + e.getMessage());
            res.statusCode = 500;
            logError = e.getMessage();
            String friendlyMsg = Core_MDF_IUPGMReqStaging_ServiceHandler.humanizeError(e.getMessage(), 'the requested user');
            logResponse = JSON.serialize(new Map<String, Object>{
                'success' => false,
                'message' => friendlyMsg
            });
            return logResponse;
        } finally {
            Core_MDF_IUPGMReqStaging_ServiceHandler.logChatbotCall(
                '/access/fetchstatus',
                req.params.get('requestNumber'),
                logResponse,
                res.statusCode,
                logUserId,
                logProgram,
                logRole,
                null,
                System.currentTimeMillis() - startMs,
                logError
            );
        }
    }

   /******************************************************************************************************
    Method Name:        buildHumanMessage
    Description:        Builds a user-facing status description from the internal staging and AGS state.
                        Differentiates between GRANT and REVOKE request types.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    private static String buildHumanMessage(
        String status,
        String requestType,
        String agsStatus,
        String agsType,
        String errorMessage,
        String userName
    ) {
        String name = String.isNotBlank(userName) ? userName : 'The user';
        Boolean isRevoke = 'REVOKE'.equalsIgnoreCase(requestType);

        if (status == 'New') {
            return 'The request has been received and is queued for processing.';

        } else if (status == 'AGS_User_Creation_Pending') {
            if (isRevoke) {
                return 'The access deactivation is being processed. '
                    + 'You will receive an email notification once the access has been removed.';
            }
            return name + ' does not yet have a Salesforce account. '
                + 'An AGS request has been submitted to create the user account. '
                + 'You will receive an email notification once the user is created.';

        } else if (status == Core_MDF_CCP_ConstantClass.IUPGM_STATUS_AGS_PS_PENDING) {
            if (isRevoke) {
                return 'The access deactivation is being processed. '
                    + 'You will receive an email notification once the access has been removed.';
            }
            return name + ' does not yet have the required system access '
                + 'for this role. An AGS request has been submitted to assign '
                + 'the necessary permissions. '
                + 'You will receive an email notification once the access is granted.';

        } else if (status == Core_MDF_CCP_ConstantClass.IUPGM_STATUS_EXTERNAL_USER_BLOCKED) {
            return 'This request cannot be processed. '
                + name + ' has an external/partner profile, '
                + 'and IUPGM access is only available for internal Intel users. '
                + 'Please submit a new request for an internal user.';

        } else if (status == Core_MDF_CCP_ConstantClass.IUPGM_STATUS_VALIDATION_FAILED) {
            return 'The request could not be processed due to a validation error: '
                + (String.isNotBlank(errorMessage)
                   ? Core_MDF_IUPGMReqStaging_ServiceHandler.humanizeError(errorMessage, name)
                   : 'Invalid input data.');

        } else if (status == Core_MDF_CCP_ConstantClass.IUPGM_STATUS_COMPLETED) {
            if (isRevoke) {
                return 'The access removal request for ' + name + ' has been completed successfully. '
                    + 'All IUPGM records have been deactivated. '
                    + name + ' no longer has the requested access.';
            }
            return 'The access request for ' + name + ' has been completed successfully. '
                + 'The IUPGM record has been created or updated. '
                + name + ' should now have the requested access.';

        } else if (status == Core_MDF_CCP_ConstantClass.IUPGM_STATUS_AGS_REJECTED) {
            if (isRevoke) {
                return 'The access removal request for ' + name + ' could not be completed. '
                    + (String.isNotBlank(errorMessage)
                       ? Core_MDF_IUPGMReqStaging_ServiceHandler.humanizeError(errorMessage, name) + ' '
                       : '')
                    + 'Please contact your administrator with the request number.';
            }
            return 'The AGS access request for ' + name + ' was rejected. '
                + (String.isNotBlank(errorMessage)
                   ? Core_MDF_IUPGMReqStaging_ServiceHandler.humanizeError(errorMessage, name) + ' '
                   : '')
                + 'Please contact your administrator with the request number.';

        } else if (status == Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR) {
            return (String.isNotBlank(errorMessage)
                    ? Core_MDF_IUPGMReqStaging_ServiceHandler.humanizeError(errorMessage, name)
                    : 'An error occurred while processing this request.')
                + ' Please contact your administrator with the request number.';

        } else {
            return 'Current status: ' + status.replace('_', ' ') + '. '
                + 'Processing is in progress.';
        }
    }
 /******************************************************************************************************
    Method Name:        formatForUI
    Description:        Filters the internal payload down to the fields approved for UI display.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    
    private static Map<String, Object> formatForUI(Map<String, Object> fullResponse) {
        Map<String, Object> uiResponse = new Map<String, Object>();

        // Only include approved fields for UI
        uiResponse.put('requestNumber', fullResponse.get('requestNumber'));
        uiResponse.put('userName', fullResponse.get('userName'));
        uiResponse.put('roleRequested', fullResponse.get('role'));
        uiResponse.put('program', fullResponse.get('program'));

        // Format status with user-friendly label based on request type
        String rawStatus = (String) fullResponse.get('status');
        String requestType = (String) fullResponse.get('requestType');
        String statusLabel = rawStatus;
        
        if (String.isNotBlank(requestType) && STATUS_LABELS_BY_TYPE.containsKey(requestType)) {
            Map<String, String> typeLabels = STATUS_LABELS_BY_TYPE.get(requestType);
            statusLabel = typeLabels.containsKey(rawStatus)
                ? typeLabels.get(rawStatus)
                : rawStatus.replace('_', ' ');
        } else {
            statusLabel = STATUS_LABELS.containsKey(rawStatus)
                ? STATUS_LABELS.get(rawStatus)
                : rawStatus.replace('_', ' ');
        }
        uiResponse.put('statusLabel', statusLabel);

        // Format submitted date to user-friendly format
        String submittedTimestamp = String.valueOf(fullResponse.get('submittedOn'));
        uiResponse.put('submittedOn', formatDateTime(submittedTimestamp));

        // Include context-aware message
        uiResponse.put('statusDescription', fullResponse.get('statusDescription'));

        // Additive fields: expose request type, action, AGS request id, and error detail to UI
        uiResponse.put('requestType', fullResponse.get('requestType'));
        uiResponse.put('action', fullResponse.get('action'));
        uiResponse.put('agsRequestId', fullResponse.get('agsRequestId'));
        uiResponse.put('errorMessage', fullResponse.get('errorMessage'));

        return uiResponse;
    }

   /******************************************************************************************************
    Method Name:        formatDateTime
    Description:        Formats the timestamp for display and preserves the original value on parse failure.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    private static String formatDateTime(String isoTimestamp) {
        if (String.isBlank(isoTimestamp)) {
            return 'N/A';
        }

        try {
            DateTime dt = (DateTime) JSON.deserialize('"' + isoTimestamp + '"', DateTime.class);
            return dt.format('MMMM d, yyyy, h:mm a');
        } catch (Exception e) {
            return isoTimestamp;
        }
    }

 /******************************************************************************************************
    Method Name:        resolveOption
    Description:        Resolves a chatbot option by number, exact text, or partial text match.
    Added By:           Ramapriya
    *******************************************************************************************************/   
    
    private static String resolveOption(
        String userInput,
        List<String> validOptions
    ) {
        if (String.isBlank(userInput) || validOptions == null || validOptions.isEmpty()) {
            throw new IllegalArgumentException('Invalid input or options list.');
        }

        userInput = userInput.trim();

        // Try numeric resolution first (1-based indexing)
        if (userInput.isNumeric()) {
            try {
                Integer idx = Integer.valueOf(userInput) - 1;
                if (idx >= 0 && idx < validOptions.size()) {
                    return validOptions[idx];
                }
            } catch (Exception e) {
                // Fall through to text matching
            }
        }

        // Try exact match (case-insensitive)
        String inputLower = userInput.toLowerCase();
        for (String opt : validOptions) {
            if (opt.toLowerCase() == inputLower) {
                return opt;
            }
        }

        // Try partial match if no exact match found
        for (String opt : validOptions) {
            if (opt.toLowerCase().contains(inputLower)
                || inputLower.contains(opt.toLowerCase())) {
                return opt;
            }
        }

        // No match found
        throw new IllegalArgumentException(
            'Invalid selection [' + userInput + ']. '
            + 'Valid options: ' + String.join(validOptions, ', ')
        );
    }
}