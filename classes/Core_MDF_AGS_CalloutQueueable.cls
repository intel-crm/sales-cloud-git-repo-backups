/*****************************************************************************************************
Class Name          :    Core_MDF_AGS_CalloutQueueable
Test Class Name     :    Core_MDF_AGS_CalloutQueueable_Test
Description         :    Queueable callout worker that submits AGS user-creation and role-access
                         requests for IUPGM staging records, then persists AGS request ids/statuses.
Created By          :    Ramapriya
******************************************************************************************************/
public class Core_MDF_AGS_CalloutQueueable implements Queueable, Database.AllowsCallouts {

    public enum CalloutType {
        USER_CREATION,
        PERMISSION_SET_REQUEST
    }

    private static final String ENDPOINT =
        'callout:Core_mdf_CCP_Named_Creds_role/m2r/ags/v1/roles';

    // Status polling endpoint. AGS requires the short human-readable request
    // "name" (e.g. 0004267963) as a query param, not the internal "id" GUID.
    private static final String STATUS_ENDPOINT =
        'callout:Core_mdf_CCP_Named_Creds_role/m2r/ags/v1/status';

    private Set<Id>    stagingIds;
    private CalloutType calloutType;
    private OAuthConfig config;
    private String      cachedAccessToken;
    private DateTime    tokenExpiryTime;
    /******************************************************************************************************
    Method Name:        OAuthConfig
    Description:        Holds OAuth metadata values used to obtain access tokens for AGS callouts.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Represents the OAuth configuration used when calling the AGS token endpoint. */
    public class OAuthConfig {
        public String  grantType             { get; set; }
        public String  accessTokenUrl        { get; set; }
        public String  clientId              { get; set; }
        public String  clientSecret          { get; set; }
        public String  scope                 { get; set; }
        public String  clientAuthentication  { get; set; }
        public String  tokenName             { get; set; }
        public Integer timeout               { get; set; }
        // Resource endpoints for configs that call something other than the
        // AGS role-assignment/status endpoints hardcoded as ENDPOINT/STATUS_ENDPOINT
        // below (e.g. the IDS_OAuth_Config entry used by fetchUserAccessFromIds()).
        // Unused by the default AGS_OAuth_Config entry today.
        public String  getEndpointPath       { get; set; }
        public String  postEndpointPath      { get; set; }

        public OAuthConfig(String configName) {
            Core_MDF_AGS_OAuth_Configuration__mdt cfg =
                getOAuthConfiguration(configName);
            if (cfg == null) {
                throw new ConfigurationException(
                    'OAuth configuration not found: ' + configName);
            }
            this.grantType            = cfg.Grant_Type__c;
            this.clientAuthentication = cfg.Client_Authentication__c;
            this.clientId             = cfg.Client_Id__c;
            this.clientSecret         = cfg.Client_Secret__c;
            this.accessTokenUrl       = cfg.Access_Token_Url__c;
            this.scope                = cfg.Scope__c;
            this.tokenName            = cfg.Token_Name__c;
            this.timeout              = cfg.Timeout__c != null
                                        ? Integer.valueOf(cfg.Timeout__c) : 60000;
            this.getEndpointPath      = cfg.Get_Endpoint_Path__c;
            this.postEndpointPath     = cfg.Post_Endpoint_Path__c;
        }

        public OAuthConfig() { this('AGS_OAuth_Config'); }
    }
	 /******************************************************************************************************
    Method Name:        getOAuthConfiguration
    Description:        Reads OAuth configuration from Core_MDF_AGS_OAuth_Configuration__mdt by developer name.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Loads the named OAuth configuration metadata record. */
    private static Core_MDF_AGS_OAuth_Configuration__mdt getOAuthConfiguration(
        String configName
    ) {
        try {
            return [
                SELECT Grant_Type__c, Client_Authentication__c, Client_Id__c,
                       Client_Secret__c, Access_Token_Url__c, Scope__c,
                       Token_Name__c, Timeout__c, Get_Endpoint_Path__c,
                       Post_Endpoint_Path__c
                FROM Core_MDF_AGS_OAuth_Configuration__mdt
                WHERE DeveloperName = :configName
                LIMIT 1
            ];
        } catch (QueryException e) {
            System.debug('OAuth config not found: ' + configName);
            return null;
        }
    }
 /******************************************************************************************************
    Method Name:        TokenResponse
    Description:        Represents OAuth token endpoint response fields and exposes success evaluation.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Minimal token payload returned by the AGS token endpoint. */
    public class TokenResponse {
        public String  access_token      { get; set; }
        public String  token_type        { get; set; }
        public Integer expires_in        { get; set; }
        public String  scope             { get; set; }
        public String  error             { get; set; }
        public String  error_description { get; set; }
        public Boolean isSuccess() {
            return String.isNotBlank(access_token) && String.isBlank(error);
        }
    }
 
 /******************************************************************************************************
    Method Name:        AgsStatusResult
    Description:        Represents the outcome of a GET call to AGS's status endpoint (approval/provisioning state).
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Wraps the result of polling AGS for the current approval/provisioning status of a request. */
    public class AgsStatusResult {
        public Boolean success;
        public String  approvalStatus;
        public String  provisioningStatus;
        public String  rawBody;
        public String  error;
    }

    public class ConfigurationException extends Exception {}

    /*
    ================================================================
    CONSTRUCTORS
    ================================================================
    */
    // Preferred constructor. The request type is derived per-record from
    // Core_MDF_AGS_Request_Type__c, so a single job can mix user creation
    // and permission set requests (keeps us within the Queueable child limit).
    /** Creates a queueable that will infer the request type from each staging record. */
    public Core_MDF_AGS_CalloutQueueable(Set<Id> stagingIds) {
        this.stagingIds  = stagingIds;
        this.calloutType = null;
        this.config      = new OAuthConfig();
    }

    /** Creates a queueable with an explicit default AGS callout type. */
    public Core_MDF_AGS_CalloutQueueable(
        Set<Id> stagingIds,
        CalloutType calloutType
    ) {
        this.stagingIds  = stagingIds;
        this.calloutType = calloutType;
        this.config      = new OAuthConfig();
    }

    /** Creates a queueable with a caller-specified OAuth configuration name. */
    public Core_MDF_AGS_CalloutQueueable(
        Set<Id> stagingIds,
        CalloutType calloutType,
        String configName
    ) {
        this.stagingIds  = stagingIds;
        this.calloutType = calloutType;
        this.config      = new OAuthConfig(configName);
    }

    /**
     * Creates a lightweight instance for ad-hoc, non-staging callouts (e.g. IDS
     * "copy user access" lookups) that only need token handling + get()/post(),
     * never System.enqueueJob()'d, and never touch Core_MDF_IUPGM_Request_Staging__c.
     * Kept in this same class per request, rather than a separate IDS class,
     * since it reuses 100% of the existing OAuth/token/get/post plumbing.
     */
    public Core_MDF_AGS_CalloutQueueable(String configName) {
        this.stagingIds  = null;
        this.calloutType = null;
        this.config      = new OAuthConfig(configName);
    }
    /******************************************************************************************************
    Method Name:        execute
    Description:         Queries all target records once and dispatches per-record based on  Core_MDF_AGS_Request_Type__c (falls back to the constructor type).
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Executes AGS callouts for the requested staging ids and persists the results. */
    public void execute(QueueableContext ctx) {
        
        String baseSelectClause = 'SELECT Id, Core_MDF_IUPGM_User__c, '
            + 'Core_MDF_AGS_Request_Type__c, Core_MDF_AGS_Role_Name__c, '
            + 'Core_MDF_IUPGM_Role_nm__c, Core_MDF_IUPGM_User__r.FederationIdentifier, '
            + 'Core_MDF_Error_Message_txt__c';
        String optionalSelectClause = ', Core_MDF_AGS_Role_Comments__c'
            + ', Core_MDF_New_User_Name__c'
            + ', Core_MDF_New_User_Email__c'
            + ', Core_MDF_New_User_Federation_Id__c';
        List<Core_MDF_IUPGM_Request_Staging__c> records;
        try {
            records = Database.query(
                baseSelectClause + optionalSelectClause
                + ' FROM Core_MDF_IUPGM_Request_Staging__c WHERE Id IN :stagingIds'
            );
        } catch (QueryException qe) {
            records = Database.query(
                baseSelectClause
                + ' FROM Core_MDF_IUPGM_Request_Staging__c WHERE Id IN :stagingIds'
            );
        }

        // Bug fix: loadEnterpriseIdByUser() used to run unguarded here. A single
        // transient failure in it (e.g. a schema/describe hiccup right after a
        // field is created, or any other QueryException) threw all the way out
        // of execute(), aborting the ENTIRE job before any staging record could
        // be updated. The AsyncApexJob then shows "Failed" while every staging
        // record is silently left in its prior "Pending"/optimistic state with
        // no error message, looking stuck rather than failed. resolveEnterpriseId()
        // already has a per-record fallback chain (FederationIdentifier from the
        // relationship query, then new-user metadata), so on failure here we
        // degrade to an empty map and let each record fall back individually
        // instead of losing the whole batch.
        Map<Id, String> enterpriseIdByUser;
        try {
            enterpriseIdByUser = loadEnterpriseIdByUser(records);
        } catch (Exception e) {
            System.debug('loadEnterpriseIdByUser failed, falling back per-record: '
                + e.getMessage());
            enterpriseIdByUser = new Map<Id, String>();
        }

        List<Core_MDF_IUPGM_Request_Staging__c> toUpdate =
            new List<Core_MDF_IUPGM_Request_Staging__c>();

        for (Core_MDF_IUPGM_Request_Staging__c rec : records) {
            String reqType = String.isNotBlank(rec.Core_MDF_AGS_Request_Type__c)
                ? rec.Core_MDF_AGS_Request_Type__c
                : (calloutType != null ? calloutType.name() : null);
            
            try {
                if (reqType == 'CREATE_USER' || reqType == 'USER_CREATION') {
                    toUpdate.add(doUserCreation(
                        rec,
                        enterpriseIdByUser.get(rec.Core_MDF_IUPGM_User__c)
                    ));
                } else if (reqType == 'PERMISSION_SET_REQUEST') {
                    toUpdate.add(doPermissionSetRequest(
                        rec,
                        enterpriseIdByUser.get(rec.Core_MDF_IUPGM_User__c)
                    ));
                } else {
                    // Bug fix: an unrecognized request type used to just log a
                    // debug line and skip the record entirely, with no update
                    // applied. The record would then sit in whatever pending
                    // status it already had forever, with no error message and
                    // no visibility for an admin/user that anything went wrong.
                    // Surface it as an Error instead so it's actionable.
                    
                    toUpdate.add(createErrorUpdate(rec.Id,
                        'Unknown AGS request type [' + reqType + ']. '
                        + 'Expected CREATE_USER/USER_CREATION or PERMISSION_SET_REQUEST.'));
                }
            } catch (Exception e) {
                System.debug('AGS callout exception: ' + e.getMessage());
                toUpdate.add(createErrorUpdate(rec.Id,
                    'AGS callout exception: ' + e.getMessage()));
            }
        }

        if (!toUpdate.isEmpty()) update toUpdate;
       
    }

   /******************************************************************************************************
    Method Name:        doUserCreation
    Description:        Resolves federation id and submits an AGS user-account creation request for one staging record.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Performs the AGS user-creation callout for a single staging record. */
    private Core_MDF_IUPGM_Request_Staging__c doUserCreation(
        Core_MDF_IUPGM_Request_Staging__c rec,
        String resolvedEnterpriseId
    ) {
        String federationId = resolveEnterpriseId(rec, resolvedEnterpriseId);
        if (String.isBlank(federationId)) {
            return createErrorUpdate(rec.Id,
                'Missing federation ID for AGS user creation. '
                + 'Please provide federation ID in the request confirmation.');
        }
        

        List<String> createUserRoles = new List<String>(
            splitToSet(rec.Core_MDF_AGS_Role_Name__c)
        );
        if (createUserRoles.isEmpty()) {
            createUserRoles.add(
                Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL
            );
        }

        HttpResponse res = post(
            ENDPOINT,
            buildPSRequestBody(
                federationId,
                createUserRoles,
                'Automated Salesforce user creation via IUPGM system.'
            ),
            new Map<String, String>{ 'Content-Type' => 'application/json' }
        );
       
        return processResponse(rec.Id, res, 'AGS user creation');
    }

   /******************************************************************************************************
    Method Name:        doPermissionSetRequest
    Description:        Submits AGS role/permission-set access requests for one staging record using resolved AGS role names.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Performs the AGS permission-set request callout for a single staging record. */
    private Core_MDF_IUPGM_Request_Staging__c doPermissionSetRequest(
        Core_MDF_IUPGM_Request_Staging__c rec,
        String resolvedEnterpriseId
    ) {
        String enterpriseId = String.isNotBlank(resolvedEnterpriseId)
            ? resolvedEnterpriseId
            : resolveEnterpriseId(rec, resolvedEnterpriseId);
        

        // Bug fix: guard against a user record with no FederationIdentifier.
        // AGS requires a valid enterpriseId â€” sending null causes a malformed request.
        if (String.isBlank(enterpriseId)) {
            return createErrorUpdate(rec.Id,
                'Missing federation ID for AGS PS request. '
                + 'Ensure the user record has a FederationIdentifier before raising a permission set request.');
        }

        List<String> agsRoles = new List<String>(
            splitToSet(rec.Core_MDF_AGS_Role_Name__c));
        

        if (agsRoles.isEmpty()) {
            return createErrorUpdate(rec.Id,
                'No AGS role name configured on the request. '
                + 'Cannot raise permission set request.');
        }

        String requestBody = buildPSRequestBody(
            enterpriseId,
            agsRoles,
            Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
                rec,
                'Core_MDF_AGS_Role_Comments__c'
            )
        );
        

        HttpResponse res = post(
            ENDPOINT,
            requestBody,
            new Map<String, String>{ 'Content-Type' => 'application/json' }
        );
       
        return processResponse(rec.Id, res, 'AGS PS request');
    }

  /******************************************************************************************************
    Method Name:        buildPSRequestBody
    Description:        Builds the AGS permission-set request payload with one requestItem per entitlement/role.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Builds the JSON payload for an AGS permission-set request. */
    private String buildPSRequestBody(
        String enterpriseId,
        List<String> entitlementNames
    ) {
        return buildPSRequestBody(
            enterpriseId,
            entitlementNames,
            'Automated IUPGM permission set request via Salesforce chatbot.'
        );
    }

    /** Builds the JSON payload for an AGS permission-set request. */
    private String buildPSRequestBody(
        String enterpriseId,
        List<String> entitlementNames,
        String justification
    ) {
        String resolvedJustification = String.isNotBlank(justification)
            ? justification
            : 'Automated IUPGM permission set request via Salesforce chatbot.';
        List<Object> requestItems = new List<Object>();
        for (String entName : entitlementNames) {
            requestItems.add(new Map<String, Object>{
                'operation'     => 'Add',
                'access'        => new Map<String, Object>{
                    'type'        => 'Role',
                    'displayName' => entName
                },
                'justification' => resolvedJustification
            });
        }
        Map<String, Object> payload = new Map<String, Object>{
            'requestee'    => new Map<String, Object>{
                'enterpriseId' => enterpriseId
            },
            'requestItems' => requestItems
        };
        return JSON.serialize(payload);
    }
/******************************************************************************************************
    Method Name:        buildUserCreationRequestBody
    Description:        Builds the AGS user-creation payload for the supplied enterprise/federation id.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Builds the JSON payload for an AGS user-creation request. */
    private String buildUserCreationRequestBody(String enterpriseId) {
        return JSON.serialize(createBasePayload(
            enterpriseId, 'Add', 'UserAccount', 'SalesforceUser',
            'Automated Salesforce user creation via IUPGM system.'
        ));
    }
/******************************************************************************************************
    Method Name:        createBasePayload
    Description:        Creates a shared AGS payload envelope with requestee, access item, and justification.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Creates the shared request envelope used by AGS callouts. */
    private Map<String, Object> createBasePayload(
        String enterpriseId,
        String operation,
        String accessType,
        String accessName,
        String justification
    ) {
        return new Map<String, Object>{
            'requestee'    => new Map<String, Object>{
                'enterpriseId' => enterpriseId
            },
            'requestItems' => new List<Object>{
                new Map<String, Object>{
                    'operation'     => operation,
                    'access'        => new Map<String, Object>{
                        'type'        => accessType,
                        'displayName' => accessName
                    },
                    'justification' => justification
                }
            }
        };
    }

   /******************************************************************************************************
    Method Name:        processResponse
    Description:        Interprets AGS HTTP responses and maps success/error outcomes to staging field updates.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Maps the AGS HTTP response back into a staging-record update. */
    private Core_MDF_IUPGM_Request_Staging__c processResponse(
        Id recordId,
        HttpResponse res,
        String operation
    ) {
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            String agsRequestId = null;
            Boolean parseFailed = false;
            try {
                Map<String, Object> body =
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                // AGS returns both a long internal "id" (GUID) and a short
                // human-readable "name" (e.g. 0004267963). The status polling
                // endpoint (GET /m2r/ags/v1/status?name=...) requires "name",
                // so prefer it here. Fall back to id/requestId if name is absent.
                if (body.containsKey('name')) {
                    agsRequestId = (String) body.get('name');
                } else if (body.containsKey('requestId')) {
                    agsRequestId = (String) body.get('requestId');
                } else if (body.containsKey('id')) {
                    agsRequestId = (String) body.get('id');
                }
            } catch (Exception e) {
                // Bug fix: a 200/201 with an unparseable body used to be
                // silently treated as "Submitted" with a truncated response
                // body stored as the AGS request id. That id can never be
                // polled successfully later, so the record would look fine
                // but silently get stuck forever. Surface it as an Error
                // instead so it's visible and actionable.
                parseFailed = true;
                System.debug('AGS response JSON parse failed: ' + e.getMessage());
            }
            // Bug fix: also treat a 200/201 response that parsed fine but had
            // no usable request id (or an empty body) as an Error, for the
            // same reason - an empty/blank id can never be polled later.
            if (parseFailed || String.isBlank(agsRequestId)) {
                String errMsg = operation + ' returned HTTP ' + res.getStatusCode()
                    + ' but the response could not be parsed into a usable AGS '
                    + 'request id. Body: ' + res.getBody();
                return new Core_MDF_IUPGM_Request_Staging__c(
                    Id                            = recordId,
                    Core_MDF_Request_Status_nm__c = 'Error',
                    Core_MDF_AGS_Status_nm__c      = 'Error',
                    Core_MDF_Error_Message_txt__c  = errMsg
                );
            }
             return new Core_MDF_IUPGM_Request_Staging__c(
                Id                         = recordId,
                Core_MDF_AGS_Request_Id__c = agsRequestId,
                Core_MDF_AGS_Status_nm__c  = 'Submitted'
            );
        } else {
            String errMsg = operation + ' failed: HTTP '
                + res.getStatusCode() + ' ' + res.getBody();
            
            return new Core_MDF_IUPGM_Request_Staging__c(
                Id                            = recordId,
                Core_MDF_Request_Status_nm__c = 'Error',
                Core_MDF_AGS_Status_nm__c     = 'Error',
                Core_MDF_Error_Message_txt__c = errMsg
            );
        }
    }
/******************************************************************************************************
    Method Name:        createErrorUpdate
    Description:        Builds an Error-status staging update with the provided error message.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Builds a staging update that records a callout error. */
    private Core_MDF_IUPGM_Request_Staging__c createErrorUpdate(
        Id recordId,
        String errorMessage
    ) {
        return new Core_MDF_IUPGM_Request_Staging__c(
            Id                            = recordId,
            Core_MDF_Request_Status_nm__c = 'Error',
            Core_MDF_AGS_Status_nm__c     = 'Error',
            Core_MDF_Error_Message_txt__c = errorMessage
        );
    }
/******************************************************************************************************
    Method Name:        resolveEnterpriseId
    Description:        Resolves enterprise/federation id from user record first, then from encoded new-user metadata.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Resolves the enterprise/federation id used in AGS request payloads. */
    private String resolveEnterpriseId(
        Core_MDF_IUPGM_Request_Staging__c rec,
        String bulkResolvedId
    ) {
        // Prefer the value already resolved in bulk via loadEnterpriseIdByUser(),
        // which safely handles orgs where Core_Federation_ID__c may or may not
        // exist on User. Never touch rec.Core_MDF_IUPGM_User__r.Core_Federation_ID__c
        // directly here â€” that field is not included in the execute() SOQL query
        // and accessing it throws SObjectException in orgs that have the field.
        if (String.isNotBlank(bulkResolvedId)) {
            return bulkResolvedId.trim();
        }
        if (rec.Core_MDF_IUPGM_User__r != null
            && String.isNotBlank(rec.Core_MDF_IUPGM_User__r.FederationIdentifier)) {
            return rec.Core_MDF_IUPGM_User__r.FederationIdentifier.trim();
        }
        Map<String, String> meta = parseNewUserMetadata(rec);
        if (String.isNotBlank(meta.get('fed'))) {
            return meta.get('fed');
        }
        if (String.isNotBlank(meta.get('email'))) {
            return deriveFederationFromEmail(meta.get('email'));
        }
        return null;
    }
/******************************************************************************************************
    Method Name:        parseNewUserMetadata
    Description:        Parses encoded IUPGM_NEW_USER metadata tokens from text into name/email/fed keys.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Reads structured new-user staging fields. */
    private Map<String, String> parseNewUserMetadata(
        Core_MDF_IUPGM_Request_Staging__c rec
    ) {
        String nameVal = Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
            rec,
            'Core_MDF_New_User_Name__c'
        );
        String emailVal = Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
            rec,
            'Core_MDF_New_User_Email__c'
        );
        String fedVal = Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
            rec,
            'Core_MDF_New_User_Federation_Id__c'
        );
        return new Map<String, String>{
            'name' => String.isNotBlank(nameVal) ? nameVal.trim() : null,
            'email' => String.isNotBlank(emailVal) ? emailVal.trim().toLowerCase() : null,
            'fed' => String.isNotBlank(fedVal) ? fedVal.trim() : null
        };
    }
/******************************************************************************************************
    Method Name:        deriveFederationFromEmail
    Description:        Derives federation id from the local-part of an email address.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Derives a federation id from the local part of an email address. */
    private String deriveFederationFromEmail(String email) {
        if (String.isBlank(email) || !email.contains('@')) return null;
        String fed = email.substringBefore('@');
        return String.isNotBlank(fed) ? fed.trim() : null;
    }

    /**
     * Resolves enterprise ids for all users in one bulk query.
     * Uses Core_Federation_ID__c when available in the org, and
     * falls back to FederationIdentifier otherwise.
     */
    private static Map<Id, String> loadEnterpriseIdByUser(
        List<Core_MDF_IUPGM_Request_Staging__c> records
    ) {
        Map<Id, String> result = new Map<Id, String>();
        Set<Id> userIds = new Set<Id>();
        for (Core_MDF_IUPGM_Request_Staging__c rec : records) {
            if (rec.Core_MDF_IUPGM_User__c != null) {
                userIds.add(rec.Core_MDF_IUPGM_User__c);
            }
        }
        if (userIds.isEmpty()) return result;

        Boolean hasCoreFederationField =
            Schema.SObjectType.User.fields.getMap().containsKey('Core_Federation_ID__c');
        String userSoql = hasCoreFederationField
            ? 'SELECT Id, FederationIdentifier, Core_Federation_ID__c FROM User WHERE Id IN :userIds'
            : 'SELECT Id, FederationIdentifier FROM User WHERE Id IN :userIds';

        for (User u : Database.query(userSoql)) {
            String enterpriseId = null;
            if (hasCoreFederationField) {
                Object coreFedVal = u.get('Core_Federation_ID__c');
                if (coreFedVal != null
                    && String.isNotBlank(String.valueOf(coreFedVal))) {
                    enterpriseId = String.valueOf(coreFedVal).trim();
                }
            }
            if (String.isBlank(enterpriseId)
                && String.isNotBlank(u.FederationIdentifier)) {
                enterpriseId = u.FederationIdentifier.trim();
            }
            result.put(u.Id, enterpriseId);
        }
        return result;
    }

    /******************************************************************************************************
    Method Name:        getAccessToken
    Description:        Retrieves and caches OAuth access token; refreshes it when missing or expired.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Retrieves or refreshes the OAuth token used for AGS callouts. */
    public TokenResponse getAccessToken() {
        try {
            System.debug('=== TOKEN RETRIEVAL START ===');
            System.debug('Checking if token is still valid...');
            
            if (isTokenValid()) {
                System.debug('Using cached token (still valid)');
                TokenResponse cached = new TokenResponse();
                cached.access_token = this.cachedAccessToken;
                cached.token_type   = 'Bearer';
                return cached;
            }

            System.debug('Token not cached or expired, fetching new token');
            
            // ISSUE #3 FIX: Validate OAuth configuration before making request
            if (config == null) {
                System.debug('ERROR: config is null!');
                TokenResponse errResp = new TokenResponse();
                errResp.error = 'configuration_error';
                errResp.error_description = 'OAuth configuration not initialized';
                return errResp;
            }
            
            System.debug('Config initialized: ' + config);
            System.debug('Config.clientId: ' + config.clientId);
            String secretLength = String.isBlank(config.clientSecret) ? 'BLANK' : String.valueOf(config.clientSecret.length());
            System.debug('Config.clientSecret length: ' + secretLength);
            System.debug('Config.accessTokenUrl: ' + config.accessTokenUrl);
            System.debug('Config.grantType: ' + config.grantType);
            
            if (String.isBlank(config.clientId)) {
                System.debug('ERROR: clientId is blank!');
                TokenResponse errResp = new TokenResponse();
                errResp.error = 'configuration_error';
                errResp.error_description = 'OAuth Client ID is blank in configuration';
                return errResp;
            }
            
            if (String.isBlank(config.clientSecret)) {
                System.debug('ERROR: clientSecret is blank!');
                TokenResponse errResp = new TokenResponse();
                errResp.error = 'configuration_error';
                errResp.error_description = 'OAuth Client Secret is blank in configuration. '
                    + 'Verify Core_MDF_AGS_OAuth_Configuration__mdt metadata.';
                return errResp;
            }
            
            if (String.isBlank(config.accessTokenUrl)) {
                System.debug('ERROR: accessTokenUrl is blank!');
                TokenResponse errResp = new TokenResponse();
                errResp.error = 'configuration_error';
                errResp.error_description = 'OAuth Access Token URL is blank in configuration';
                return errResp;
            }
            
            System.debug('All config validations passed');

            System.debug('All config validations passed');

            HttpRequest req = new HttpRequest();
            req.setEndpoint(config.accessTokenUrl);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

            String reqBody =
                'grant_type=' + EncodingUtil.urlEncode(config.grantType, 'UTF-8');
            if (String.isNotBlank(config.scope)) {
                reqBody += '&scope=' + EncodingUtil.urlEncode(config.scope, 'UTF-8');
            }

            if (config.clientAuthentication == 'client_secret_basic') {
                String creds = config.clientId + ':' + config.clientSecret;
                req.setHeader('Authorization',
                    'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(creds)));
            } else {
                reqBody += '&client_id='
                    + EncodingUtil.urlEncode(config.clientId, 'UTF-8');
                reqBody += '&client_secret='
                    + EncodingUtil.urlEncode(config.clientSecret, 'UTF-8');
            }

            req.setBody(reqBody);
            req.setTimeout(config.timeout);

            System.debug('=== SENDING TOKEN REQUEST ===');
            System.debug('Token endpoint URL: ' + config.accessTokenUrl);
            System.debug('Request method: POST');
            System.debug('Request body (sanitized): grant_type=' + config.grantType + '&client_id=***&client_secret=***');
            System.debug('Timeout: ' + config.timeout + 'ms');
            
            HttpResponse res = new Http().send(req);
            
            System.debug('=== RECEIVED TOKEN RESPONSE ===');
            System.debug('Response status code: ' + res.getStatusCode());
            System.debug('Response body (first 500 chars): ' + res.getBody().abbreviate(500));
            
            if (String.isBlank(res.getBody())) {
                System.debug('ERROR: Response body is empty!');
                TokenResponse errResp = new TokenResponse();
                errResp.error = 'empty_response';
                errResp.error_description = 'Token endpoint returned empty response (status: ' + res.getStatusCode() + ')';
                return errResp;
            }
            
            System.debug('Attempting to deserialize response JSON...');
            TokenResponse tokenResp;
            try {
                tokenResp = (TokenResponse) JSON.deserialize(
                    res.getBody(), TokenResponse.class);
                System.debug('Deserialization successful');
                System.debug('TokenResponse.error: ' + tokenResp.error);
                System.debug('TokenResponse.error_description: ' + tokenResp.error_description);
                String tokenLength = String.isBlank(tokenResp.access_token) ? 'BLANK' : String.valueOf(tokenResp.access_token.length());
                System.debug('TokenResponse.access_token (length): ' + tokenLength);
            } catch (JSONException je) {
                System.debug('ERROR during JSON deserialization: ' + je.getMessage());
                System.debug('Deserialization stack: ' + je.getStackTraceString());
                TokenResponse errResp = new TokenResponse();
                errResp.error = 'parse_error';
                errResp.error_description = 'Failed to parse token response: ' + je.getMessage();
                return errResp;
            }

            if (tokenResp.isSuccess()) {
                System.debug('Token successfully retrieved. Caching...');
                this.cachedAccessToken = tokenResp.access_token;
                Integer expiresIn = tokenResp.expires_in != null
                    ? tokenResp.expires_in - 60 : 3540;
                this.tokenExpiryTime = DateTime.now().addSeconds(expiresIn);
                System.debug('Token will expire in ' + expiresIn + ' seconds');
            } else {
                // FIX: Ensure error_description is never null for error responses
                if (String.isBlank(tokenResp.error_description)) {
                    tokenResp.error_description = 'Token endpoint returned error [' + tokenResp.error + ']. '
                        + 'No detailed error message was provided by the endpoint.';
                }
                System.debug('Token endpoint returned error: ' + tokenResp.error_description);
            }

            System.debug('=== TOKEN RETRIEVAL END ===');
            return tokenResp;

        } catch (Exception e) {
            System.debug('=== TOKEN RETRIEVAL EXCEPTION ===');
            System.debug('Exception type: ' + e.getTypeName());
            System.debug('Exception message: ' + e.getMessage() 
                + ' | Stack: ' + e.getStackTraceString());
            TokenResponse errResp = new TokenResponse();
            errResp.error             = 'request_failed';
            errResp.error_description = 'Token retrieval failed: ' + e.getMessage();
            return errResp;
        }
    }
    /******************************************************************************************************
    Method Name:        post
    Description:        Sends an authenticated HTTP POST to AGS using the cached/refreshed OAuth token.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Sends an authenticated POST callout to AGS. */
    public HttpResponse post(
        String endpoint,
        String body,
        Map<String, String> headers
    ) {
        TokenResponse tokenResp = getAccessToken();
        if (!tokenResp.isSuccess()) {
            String errorMsg = String.isNotBlank(tokenResp.error_description) 
                ? tokenResp.error_description 
                : 'Token endpoint returned error: ' + tokenResp.error;
            throw new CalloutException(
                'Failed to obtain access token: ' + errorMsg);
        }
        

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + tokenResp.access_token);
        if (headers != null) {
            for (String h : headers.keySet()) req.setHeader(h, headers.get(h));
        }
        if (String.isNotBlank(body)) req.setBody(body);
        req.setTimeout(config.timeout);

        HttpResponse response = new Http().send(req);
        
        return response;
    }
/******************************************************************************************************
    Method Name:        get
    Description:        Sends an authenticated HTTP GET to AGS using the cached/refreshed OAuth token.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Sends an authenticated GET callout to AGS. */
    public HttpResponse get(String endpoint, Map<String, String> headers) {
        TokenResponse tokenResp = getAccessToken();
        if (!tokenResp.isSuccess()) {
            String errorMsg = String.isNotBlank(tokenResp.error_description) 
                ? tokenResp.error_description 
                : 'Token endpoint returned error: ' + tokenResp.error;
            throw new CalloutException(
                'Failed to obtain access token: ' + errorMsg);
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + tokenResp.access_token);
        if (headers != null) {
            for (String h : headers.keySet()) req.setHeader(h, headers.get(h));
        }
        req.setTimeout(config.timeout);
        return new Http().send(req);
    }

    /******************************************************************************************************
    Method Name:        IdsRoleAssignment
    Description:        One deduplicated role currently assigned to a user, as returned by the IDS
                         "identity-role-entitlement-mappings" GET endpoint. CONFIRMED against a real
                         sample response. The raw IDS response contains ONE ROW PER ENTITLEMENT, so a
                         single role with 3 entitlements produces 3 rows sharing the same RoleId -
                         parseIdsRoleAssignments() collapses those down to exactly one IdsRoleAssignment
                         per unique RoleId before returning.
    Added By:           Ramapriya
    *******************************************************************************************************/
    public class IdsRoleAssignment {
        public String roleId;          // IDS "RoleId" - unique per role, used as the dedup key
        public String roleName;        // IDS "RoleSystemNm" (falls back to "RoleDisplayNm") - matches
                                        // the Core_MDF_AGS_Role_Name__c convention already used
                                        // throughout Core_MDF_IUPGM_Rule_Config__mdt
        public String programName;     // not provided by IDS - left null; callers resolve program via
                                        // Core_MDF_IUPGM_RequestAPI.findRuleConfigByAnyRoleName(roleName)
        public String rawJson;         // raw JSON of the first (non-disabled) row seen for this RoleId
    }

    // Static query parameters required by the IDS endpoint - identical in sandbox and production,
    // confirmed against real endpoint URLs for both environments. Only the base host+path (stored in
    // Get_Endpoint_Path__c on the IDS_OAuth_Config metadata record, per environment) and EnterpriseId
    // (per user, resolved dynamically) differ.
    private static final String IDS_FORMAT             = 'JSON';
    private static final String IDS_ROLE_FILTER         = '"RoleId" is not null';
    private static final String IDS_TARGET_APPLICATION  = 'Salesforce-SalesCloud';

    /******************************************************************************************************
    Method Name:        fetchUserAccessFromIds
    Description:        Calls the IDS identity-role-entitlement-mappings GET endpoint for one user (by
                         EnterpriseId/WWID) and returns the deduplicated list of currently assigned roles.
                         Reuses the same OAuth token/get() plumbing as AGS, but against the IDS_OAuth_Config
                         metadata record (separate Client Id/Secret, same
                         Core_MDF_AGS_OAuth_Configuration__mdt type). Throws ConfigurationException - never
                         fabricates data - when IDS is not yet configured, so callers (Copy User Access,
                         List Access) can degrade to a clear "not available yet" message.
                         Get_Endpoint_Path__c is expected to hold ONLY the base URL up to and including
                         "identity-role-entitlement-mappings" (no query string) - e.g.
                         sandbox: https://apis.sandbox.intel.com/security/v1/identitydataservice/identity-role-entitlement-mappings
                         prod:    https://apis.intel.com/security/v1/identitydataservice/identity-role-entitlement-mappings
                         The $format/$filter/TargetApplication/EnterpriseId query string is always
                         appended here in code, since it is identical across environments.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Retrieves one user's current, deduplicated IDS role assignments. Instance must use the IDS config. */
    public List<IdsRoleAssignment> fetchUserAccessFromIds(String enterpriseId) {

        if (String.isBlank(enterpriseId)) {
            throw new ConfigurationException(
                'fetchUserAccessFromIds requires a non-blank enterpriseId/WWID.');
        }
        if (config == null
            || String.isBlank(config.accessTokenUrl)
            || String.isBlank(config.clientId)
            || String.isBlank(config.clientSecret)
            || String.isBlank(config.getEndpointPath)) {
            // IDS application/endpoint not approved & configured yet. Surface a clear, actionable
            // error instead of calling an incomplete/placeholder URL.
            throw new ConfigurationException(
                'IDS integration is not configured yet. Populate Access_Token_URL__c, '
                + 'Client_ID__c, Client_Secret__c and Get_Endpoint_Path__c on the '
                + 'IDS_OAuth_Config Core_MDF_AGS_OAuth_Configuration__mdt record before '
                + 'Copy User Access can call IDS.');
        }

        String baseEndpoint = config.getEndpointPath.contains('?')
            ? config.getEndpointPath.substringBefore('?')
            : config.getEndpointPath;

        String endpoint = baseEndpoint
            + '?$format=' + IDS_FORMAT
            + '&EnterpriseId=' + EncodingUtil.urlEncode(enterpriseId, 'UTF-8')
            + '&$filter=' + EncodingUtil.urlEncode(IDS_ROLE_FILTER, 'UTF-8')
            + '&TargetApplication=' + EncodingUtil.urlEncode(IDS_TARGET_APPLICATION, 'UTF-8');

        HttpResponse res = get(endpoint, new Map<String, String>{
            'Accept' => 'application/json'
        });

        if (res.getStatusCode() != 200) {
            throw new CalloutException(
                'IDS user access lookup failed: HTTP ' + res.getStatusCode()
                + ' ' + res.getBody());
        }

        return parseIdsRoleAssignments(res.getBody());
    }

    /******************************************************************************************************
    Method Name:        parseIdsRoleAssignments
    Description:        Parses the IDS GET response body - {"name":"IdentityRoleEntitlementMapping",
                         "elements":[ {one row per role+entitlement pair, with RoleId/RoleSystemNm/
                         RoleDisplayNm/Disabled fields}, ... ], "links":[...]} - confirmed against a real
                         sample response. Each role appears once per entitlement under it, so this method
                         deduplicates by RoleId (the unique, stable identifier for the role itself) and
                         returns exactly one IdsRoleAssignment per currently-assigned role. Rows whose
                         "Disabled" field is the string "True" are skipped entirely, so a role is only
                         reported as currently assigned if it has at least one active (non-disabled)
                         entitlement row.
    Added By:           Ramapriya
    *******************************************************************************************************/
    @TestVisible
    private List<IdsRoleAssignment> parseIdsRoleAssignments(String responseBody) {
        List<IdsRoleAssignment> results = new List<IdsRoleAssignment>();
        if (String.isBlank(responseBody)) return results;

        Object parsed = JSON.deserializeUntyped(responseBody);
        if (!(parsed instanceof Map<String, Object>)) {
            return results;
        }
        Map<String, Object> root = (Map<String, Object>) parsed;
        Object elementsObj = root.get('elements');
        if (!(elementsObj instanceof List<Object>)) {
            return results;
        }

        // Keyed by RoleId so repeated entitlement rows for the same role collapse into one
        // entry - this is the dedup step called out explicitly: RoleId is unique per role,
        // while a role can have many entitlement rows underneath it.
        Map<String, IdsRoleAssignment> byRoleId = new Map<String, IdsRoleAssignment>();

        for (Object item : (List<Object>) elementsObj) {
            if (!(item instanceof Map<String, Object>)) continue;
            Map<String, Object> m = (Map<String, Object>) item;

            String roleId = (String) m.get('RoleId');
            if (String.isBlank(roleId) || byRoleId.containsKey(roleId)) continue;

            String disabled = (String) m.get('Disabled');
            if (disabled != null && disabled.equalsIgnoreCase('True')) {
                // Skip disabled/revoked entitlement rows - do not report a role as currently
                // assigned based solely on a disabled entry. If a later, active row for the
                // same RoleId appears further down, it will still be picked up normally.
                continue;
            }

            IdsRoleAssignment dto = new IdsRoleAssignment();
            dto.roleId = roleId;
            String roleSystemNm  = (String) m.get('RoleSystemNm');
            String roleDisplayNm = (String) m.get('RoleDisplayNm');
            dto.roleName = String.isNotBlank(roleSystemNm) ? roleSystemNm : roleDisplayNm;
            dto.rawJson = JSON.serialize(item);
            byRoleId.put(roleId, dto);
        }

        results.addAll(byRoleId.values());
        return results;
    }

    /******************************************************************************************************
    Method Name:        checkRequestStatus
    Description:        Polls AGS for the current approval/provisioning status of a previously submitted
                         request, keyed by the short human-readable request "name" (not the internal "id").
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Calls AGS GET /m2r/ags/v1/status?name=... and returns the parsed approval/provisioning status. */
    public AgsStatusResult checkRequestStatus(String agsRequestName) {
        AgsStatusResult result = new AgsStatusResult();
        if (String.isBlank(agsRequestName)) {
            result.success = false;
            result.error   = 'No AGS request name provided.';
            return result;
        }
        try {
            String endpoint = STATUS_ENDPOINT + '?name='
                + EncodingUtil.urlEncode(agsRequestName, 'UTF-8');
            Map<String, String> headers = new Map<String, String>{
                'Accept' => 'application/json'
            };
            HttpResponse res = get(endpoint, headers);
            result.rawBody = res.getBody();

            if (res.getStatusCode() == 200) {
                Map<String, Object> body =
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                result.approvalStatus     = extractStatusField(body, 'approvalStatus');
                result.provisioningStatus = extractStatusField(body, 'provisioningStatus');
                result.success = true;
            } else {
                result.success = false;
                result.error = 'AGS status check failed: HTTP '
                    + res.getStatusCode() + ' ' + res.getBody();
            }
        } catch (Exception e) {
            result.success = false;
            result.error   = 'AGS status check exception: ' + e.getMessage();
        }
        
        return result;
    }
    /******************************************************************************************************
    Method Name:        extractStatusField
    Description:        Reads a status field (e.g. approvalStatus/provisioningStatus) from the AGS status
                         response, preferring the first requestItems entry and falling back to top level.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Extracts a named status value, checking requestItems[0] first then the response root. */
    private String extractStatusField(Map<String, Object> body, String fieldName) {
        if (body == null) return null;

        if (body.get('requestItems') instanceof List<Object>) {
            List<Object> items = (List<Object>) body.get('requestItems');
            if (!items.isEmpty() && items[0] instanceof Map<String, Object>) {
                Map<String, Object> firstItem = (Map<String, Object>) items[0];
                if (firstItem.get(fieldName) != null) {
                    return (String) firstItem.get(fieldName);
                }
            }
        }
        return body.get(fieldName) != null ? (String) body.get(fieldName) : null;
    }
/******************************************************************************************************
    Method Name:        deleteRequest
    Description:        Sends an authenticated HTTP DELETE to AGS using the cached/refreshed OAuth token.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Sends an authenticated DELETE callout to AGS. */
    public HttpResponse deleteRequest(String endpoint, Map<String, String> headers) {
        TokenResponse tokenResp = getAccessToken();
        if (!tokenResp.isSuccess()) {
            throw new CalloutException(
                'Failed to obtain access token: ' + tokenResp.error_description);
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('DELETE');
        req.setHeader('Authorization', 'Bearer ' + tokenResp.access_token);
        if (headers != null) {
            for (String h : headers.keySet()) req.setHeader(h, headers.get(h));
        }
        req.setTimeout(config.timeout);
        return new Http().send(req);
    }

    /** Indicates whether the cached OAuth token is still valid. */
    private Boolean isTokenValid() {
        return String.isNotBlank(this.cachedAccessToken)
            && this.tokenExpiryTime != null
            && this.tokenExpiryTime > DateTime.now();
    }

    /** Clears the cached OAuth token so the next callout re-authenticates. */
    public void clearCachedToken() {
        this.cachedAccessToken = null;
        this.tokenExpiryTime   = null;
    }

    // â”€â”€ Inlined from Core_MDF_IUPGM_Util â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    /** Splits a semicolon-delimited string into a set of trimmed values. */
    private static Set<String> splitToSet(String val) {
        Set<String> result = new Set<String>();
        if (String.isBlank(val)) return result;
        for (String s : val.split(';')) {
            String t = s.trim();
            if (String.isNotBlank(t)) result.add(t);
        }
        return result;
    }

    // â”€â”€ Inlined from Core_MDF_IUPGM_StagingFieldSupport â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    /** Sets a staging field only when it exists in the current org schema. */
    public static void putStagingFieldIfPresent(SObject record, String fieldApiName, Object value) {
        if (record == null || String.isBlank(fieldApiName)) {
            return;
        }
        Schema.SObjectField fieldRef =
            Schema.getGlobalDescribe()
                .get('Core_MDF_IUPGM_Request_Staging__c')
                .getDescribe()
                .fields.getMap()
                .get(fieldApiName);
        if (fieldRef == null || !fieldRef.getDescribe().isCreateable()) {
            return;
        }
        try {
            record.put(fieldApiName, value);
        } catch (SObjectException e) {
            // Optional staging field not available in this org; keep fallback behavior.
        }
    }

    /** Reads a staging field as text only when it exists in the current org schema. */
    public static String getStagingFieldStringIfPresent(SObject record, String fieldApiName) {
        if (record == null || String.isBlank(fieldApiName)) {
            return null;
        }
        Schema.SObjectField fieldRef =
            Schema.getGlobalDescribe()
                .get('Core_MDF_IUPGM_Request_Staging__c')
                .getDescribe()
                .fields.getMap()
                .get(fieldApiName);
        if (fieldRef == null || !fieldRef.getDescribe().isAccessible()) {
            return null;
        }
        try {
            Object value = record.get(fieldApiName);
            return value == null ? null : String.valueOf(value);
        } catch (SObjectException e) {
            return null;
        }
    }
}