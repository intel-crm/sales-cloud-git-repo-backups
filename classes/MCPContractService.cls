public with sharing class MCPContractService {
    
    private static final String NAMED_CREDENTIAL = 'callout:Core_MDF_MCP_Contract_API';
    private static final String BASE_PATH        = '/contract-foundation/v1/mcp';
    private static final String SESSION_HEADER   = 'mcp-session-id';
    
    // Auth Provider endpoints
    private static final String AUTH_URL         = 'https://apisx-dev.intel.com/v1/auth/pkce/authorize';
    private static final String TOKEN_URL        = 'https://apisx-dev.intel.com/v1/auth/pkce/token';
    private static final String CLIENT_ID        = '7ae3efb8-1f4c-4a94-82ab-8b476f9dab57'; // from postman
    
    // ─────────────────────────────────────────
    // Generate PKCE Values
    // ─────────────────────────────────────────
    public static Map<String, String> generatePKCE() {
        // Step 1: Generate code_verifier (random 43-128 chars)
        String codeVerifier = generateCodeVerifier();
        
        // Step 2: Generate code_challenge (SHA-256 of verifier)
        String codeChallenge = generateCodeChallenge(codeVerifier);
        
        // Step 3: Generate state (CSRF protection)
        String state = generateState();
        
        Map<String, String> pkce = new Map<String, String>();
        pkce.put('codeVerifier',  codeVerifier);
        pkce.put('codeChallenge', codeChallenge);
        pkce.put('state',         state);
        
        System.debug('PKCE Generated: ' + pkce);
        return pkce;
    }
    
    // ─────────────────────────────────────────
    // Build Auth URL with PKCE
    // Returns URL for LWC to redirect to
    // ─────────────────────────────────────────
    public static String buildAuthUrl(
        String codeChallenge, 
        String state
    ) {
        String callbackUrl = URL.getOrgDomainUrl().toExternalForm()
                           + '/services/authcallback/Core_MDF_Contract_Retriever_MCP';
        
        String authUrl = AUTH_URL
            + '?response_type=code'
            + '&client_id='             + EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8')
            + '&redirect_uri='          + EncodingUtil.urlEncode(callbackUrl, 'UTF-8')
            + '&code_challenge='        + codeChallenge
            + '&code_challenge_method=S256'
            + '&state='                 + state;
        
        System.debug('Auth URL: ' + authUrl);
        return authUrl;
    }
    
    // ─────────────────────────────────────────
    // Exchange Code for Token
    // Called after user authenticates
    // ─────────────────────────────────────────
    public static Map<String, String> exchangeCodeForToken(
        String authCode,
        String codeVerifier
    ) {
        String callbackUrl = URL.getOrgDomainUrl().toExternalForm()
                           + '/services/authcallback/Core_MDF_Contract_Retriever_MCP';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(30000);
        
        String body = 'grant_type=authorization_code'
            + '&code='          + EncodingUtil.urlEncode(authCode,    'UTF-8')
            + '&redirect_uri='  + EncodingUtil.urlEncode(callbackUrl, 'UTF-8')
            + '&client_id='     + EncodingUtil.urlEncode(CLIENT_ID,   'UTF-8')
            + '&code_verifier=' + EncodingUtil.urlEncode(codeVerifier,'UTF-8');
        
        req.setBody(body);
        
        Http         http = new Http();
        HttpResponse res  = http.send(req);
        
        System.debug('Token Exchange Status: ' + res.getStatusCode());
        System.debug('Token Exchange Body: '   + res.getBody());
        
        Map<String, String> tokenResult = new Map<String, String>();
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> tokenData = 
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            tokenResult.put('access_token',  
                (String) tokenData.get('access_token'));
            tokenResult.put('refresh_token', 
                (String) tokenData.get('refresh_token'));
            tokenResult.put('expires_in',    
                String.valueOf(tokenData.get('expires_in')));
            tokenResult.put('success', 'true');
            
        } else {
            tokenResult.put('success', 'false');
            tokenResult.put('error',   res.getBody());
        }
        
        return tokenResult;
    }
    
    // ─────────────────────────────────────────
    // Refresh Token Silently
    // ─────────────────────────────────────────
    public static Map<String, String> refreshToken(String refreshToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(30000);
        
        String body = 'grant_type=refresh_token'
            + '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, 'UTF-8')
            + '&client_id='     + EncodingUtil.urlEncode(CLIENT_ID,    'UTF-8');
        
        req.setBody(body);
        
        Http         http = new Http();
        HttpResponse res  = http.send(req);
        
        System.debug('Refresh Status: ' + res.getStatusCode());
        System.debug('Refresh Body: '   + res.getBody());
        
        Map<String, String> result = new Map<String, String>();
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> tokenData = 
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            result.put('access_token',  
                (String) tokenData.get('access_token'));
            result.put('refresh_token', 
                (String) tokenData.get('refresh_token'));
            result.put('success', 'true');
            
        } else {
            result.put('success', 'false');
            result.put('error',   res.getBody());
        }
        
        return result;
    }
    
    // ─────────────────────────────────────────
    // Initialize Session WITH Token
    // ─────────────────────────────────────────
    public static MCPResponse initializeSessionWithToken(String accessToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + BASE_PATH);
        req.setMethod('POST');
        req.setHeader('Content-Type',  'application/json');
        req.setHeader('Accept',        'application/json, text/event-stream');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setTimeout(120000);
        
        req.setBody(JSON.serialize(new Map<String, Object>{
            'jsonrpc' => '2.0',
            'id'      => 1,
            'method'  => 'initialize',
            'params'  => new Map<String, Object>{
                'protocolVersion' => '2025-06-18',
                'capabilities'    => new Map<String, Object>(),
                'clientInfo'      => new Map<String, Object>{
                    'name'    => 'Salesforce',
                    'version' => '1.0'
                }
            }
        }));
        
        Http         http   = new Http();
        HttpResponse res    = http.send(req);
        
        MCPResponse mcpRes  = new MCPResponse();
        mcpRes.statusCode   = res.getStatusCode();
        mcpRes.body         = res.getBody();
        mcpRes.isSuccess    = (res.getStatusCode() >= 200 && 
                               res.getStatusCode() < 300);
        mcpRes.sessionId    = res.getHeader(SESSION_HEADER);
        
        if (!mcpRes.isSuccess) {
            mcpRes.errorMessage = 'HTTP ' + res.getStatusCode() 
                                + ': '    + res.getBody();
        }
        
        return mcpRes;
    }

    // ─────────────────────────────────────────
    // PKCE Helpers
    // ─────────────────────────────────────────
    private static String generateCodeVerifier() {
        Blob randomBytes = Crypto.generateAesKey(256);
        String verifier  = EncodingUtil.base64Encode(randomBytes)
            .replace('+', '-')
            .replace('/', '_')
            .replace('=', '')
            .substring(0, 43);
        return verifier;
    }
    
    private static String generateCodeChallenge(String verifier) {
        Blob verifierBlob = Blob.valueOf(verifier);
        Blob hashBlob     = Crypto.generateDigest('SHA-256', verifierBlob);
        String challenge  = EncodingUtil.base64Encode(hashBlob)
            .replace('+', '-')
            .replace('/', '_')
            .replace('=', '');
        return challenge;
    }
    
    private static String generateState() {
        return EncodingUtil.base64Encode(
            Crypto.generateAesKey(128)
        ).substring(0, 16);
    }
    
    // ─────────────────────────────────────────
    // Existing methods remain same...
    // ─────────────────────────────────────────
    public static MCPResponse initializeSession() {
        HttpRequest req = buildRequest('');
        req.setBody(JSON.serialize(new Map<String, Object>{
            'jsonrpc' => '2.0',
            'id'      => 1,
            'method'  => 'initialize',
            'params'  => new Map<String, Object>{
                'protocolVersion' => '',
                'capabilities'    => new Map<String, Object>(),
                'clientInfo'      => new Map<String, Object>{
                    'name'    => 'Salesforce',
                    'version' => '1.0'
                }
            }
        }));
        
        Http         http   = new Http();
        HttpResponse res    = http.send(req);
        
        MCPResponse mcpRes  = new MCPResponse();
        mcpRes.statusCode   = res.getStatusCode();
        mcpRes.body         = res.getBody();
        mcpRes.isSuccess    = (res.getStatusCode() >= 200 && 
                               res.getStatusCode() < 300);
        mcpRes.sessionId    = res.getHeader(SESSION_HEADER);
        
        if (mcpRes.statusCode == 401) {
            mcpRes.requiresAuth = true;
            mcpRes.isSuccess    = false;
            mcpRes.errorMessage = 'Authentication required';
        }
        
        if (!mcpRes.isSuccess && !mcpRes.requiresAuth) {
            mcpRes.errorMessage = 'HTTP ' + res.getStatusCode() 
                                + ': '    + res.getBody();
        }
        
        return mcpRes;
    }

    private static HttpRequest buildRequest(String sessionId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + BASE_PATH);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept',       'application/json, text/event-stream');
        req.setTimeout(120000);
        
        if (String.isNotBlank(sessionId)) {
            req.setHeader(SESSION_HEADER, sessionId);
        }
        
        return req;
    }
    
    private static MCPResponse sendRequest(HttpRequest req) {
        MCPResponse mcpRes = new MCPResponse();
        try {
            Http         http = new Http();
            HttpResponse res  = http.send(req);
            
            mcpRes.statusCode  = res.getStatusCode();
            mcpRes.body        = res.getBody();
            mcpRes.contentType = res.getHeader('Content-Type');
            mcpRes.isSuccess   = (res.getStatusCode() >= 200 && 
                                  res.getStatusCode() < 300);
            
            String newSessionId = res.getHeader(SESSION_HEADER);
            if (String.isNotBlank(newSessionId)) {
                mcpRes.sessionId = newSessionId;
            }
            
            if (!mcpRes.isSuccess) {
                mcpRes.requiresAuth = res.getStatusCode() == 401;
                mcpRes.errorMessage = mcpRes.requiresAuth
                    ? 'Authentication required'
                    : 'HTTP ' + res.getStatusCode() + ': ' + res.getBody();
            }
        } catch (Exception e) {
            mcpRes.isSuccess    = false;
            mcpRes.errorMessage = e.getMessage();
        }
        return mcpRes;
    }
    
    public static MCPResponse sendInitializedNotification(String sessionId) {
        HttpRequest req = buildRequest(sessionId);
        req.setBody(JSON.serialize(new Map<String, Object>{
            'jsonrpc' => '2.0',
            'method'  => 'notifications/initialized',
            'params'  => new Map<String, Object>()
        }));
        return sendRequest(req);
    }
    
    public static MCPResponse listTools(String sessionId) {
        HttpRequest req = buildRequest(sessionId);
        req.setBody(JSON.serialize(new Map<String, Object>{
            'jsonrpc' => '2.0',
            'id'      => 2,
            'method'  => 'tools/list',
            'params'  => new Map<String, Object>()
        }));
        return sendRequest(req);
    }
    
    public static MCPResponse callContractMetadata(
        String  sessionId,
        Integer contractNumber,
        Integer orderNumber
    ) {
        HttpRequest req = buildRequest(sessionId);
        req.setBody(JSON.serialize(new Map<String, Object>{
            'jsonrpc' => '2.0',
            'id'      => 3,
            'method'  => 'tools/call',
            'params'  => new Map<String, Object>{
                'name'      => 'get_contract_attributes',
                'arguments' => new Map<String, Object>{
                    'contract_number' => contractNumber,
                    'order_number'    => orderNumber
                }
            }
        }));
        
        Http         http   = new Http();
        HttpResponse res    = http.send(req);
        
        MCPResponse mcpRes  = new MCPResponse();
        mcpRes.statusCode   = res.getStatusCode();
        mcpRes.body         = res.getBody();
        mcpRes.isSuccess    = (res.getStatusCode() >= 200 && 
                               res.getStatusCode() < 300);
        mcpRes.contentType  = res.getHeader('Content-Type');
        mcpRes.sessionId    = res.getHeader(SESSION_HEADER);
        
        if (!mcpRes.isSuccess) {
            mcpRes.requiresAuth = res.getStatusCode() == 401;
            mcpRes.errorMessage = mcpRes.requiresAuth
                ? 'Authentication required'
                : 'HTTP ' + res.getStatusCode() + ': ' + res.getBody();
        }
        
        return mcpRes;
    }

    // ─────────────────────────────────────────
    // WRAPPER CLASS
    // ─────────────────────────────────────────
    public class MCPResponse {
        public Integer statusCode   { get; set; }
        public String  body         { get; set; }
        public String  sessionId    { get; set; }
        public String  contentType  { get; set; }
        public Boolean isSuccess    { get; set; }
        public String  errorMessage { get; set; }
        public Boolean requiresAuth { get; set; }
        
        public MCPResponse() {
            this.isSuccess    = false;
            this.requiresAuth = false;
        }
    }
}