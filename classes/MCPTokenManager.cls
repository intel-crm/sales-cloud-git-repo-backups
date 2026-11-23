public with sharing class MCPTokenManager {
    
    // ── Constants ─────────────────────────────────────────────────
    private static final String TOKEN_URL     = 
        'https://apisx-dev.intel.com/v1/auth/pkce/token';
    private static final String CLIENT_ID     = 
        '7ae3efb8-1f4c-4a94-82ab-8b476f9dab57';
    private static final String CLIENT_SECRET = 
        'rYU8Q~NovFNiLard71.CanjOH~lwRPJl6s-lSb3u';
    private static final String REDIRECT_URI  = 
        'https://test.salesforce.com/services/oauth2/callback';
        
    // ── Cache Keys ────────────────────────────────────────────────
    private static final String CACHE_PARTITION = 
        'local.MCPTokenCache';
    private static final String ACCESS_TOKEN_KEY  = 
        'MCPAccessToken';
    private static final String REFRESH_TOKEN_KEY = 
        'MCPRefreshToken';
    private static final String TOKEN_EXPIRY_KEY  = 
        'MCPTokenExpiry';

    // ─── Main Method - Get Valid Token ────────────────────────────
    public static String getValidToken() {
        
        System.debug('=== MCPTokenManager.getValidToken() ===');
        
        // ── Step 1: Check Platform Cache ──────────────────────────
        String cachedToken = getTokenFromCache();
        
        if (String.isNotBlank(cachedToken)) {
            System.debug('✅ Valid token found in cache');
            return cachedToken;
        }
        
        System.debug('❌ No valid token in cache');
        
        // ── Step 2: Try Refresh Token ─────────────────────────────
        String refreshToken = getRefreshTokenFromCache();
        
        if (String.isNotBlank(refreshToken)) {
            System.debug('🔄 Trying refresh token...');
            try {
                String newToken = refreshAccessToken(refreshToken);
                if (String.isNotBlank(newToken)) {
                    System.debug('✅ Token refreshed successfully');
                    return newToken;
                }
            } catch (Exception e) {
                System.debug('❌ Refresh failed: ' + e.getMessage());
            }
        }
        
        // ── Step 3: Get New Token via Named Credential ────────────
        System.debug('🔑 Getting new token via Named Credential...');
        return getNewTokenViaNamedCredential();
    }

    // ─── Get Token From Platform Cache ───────────────────────────
    private static String getTokenFromCache() {
        try {
            Cache.OrgPartition partition = 
                Cache.Org.getPartition(CACHE_PARTITION);
            
            // Check expiry first
            Long expiryTime = (Long) partition.get(TOKEN_EXPIRY_KEY);
            
            if (expiryTime != null) {
                Long currentTime = DateTime.now().getTime() / 1000;
                Long bufferTime  = currentTime + 300; // 5 min buffer
                
                System.debug('Token expiry  : ' + expiryTime);
                System.debug('Current time  : ' + currentTime);
                System.debug('Buffer time   : ' + bufferTime);
                
                if (expiryTime > bufferTime) {
                    // Token still valid
                    return (String) partition.get(ACCESS_TOKEN_KEY);
                } else {
                    System.debug('Token expired or expiring soon');
                    return null;
                }
            }
            
            return null;
            
        } catch (Exception e) {
            System.debug('Cache read error: ' + e.getMessage());
            return null;
        }
    }

    // ─── Get Refresh Token From Cache ─────────────────────────────
    private static String getRefreshTokenFromCache() {
        try {
            Cache.OrgPartition partition = 
                Cache.Org.getPartition(CACHE_PARTITION);
            return (String) partition.get(REFRESH_TOKEN_KEY);
        } catch (Exception e) {
            System.debug('Refresh token cache error: ' + e.getMessage());
            return null;
        }
    }

    // ─── Store Tokens in Cache ────────────────────────────────────
    public static void storeTokensInCache(
        String accessToken,
        String refreshToken,
        Integer expiresIn
    ) {
        try {
            Cache.OrgPartition partition = 
                Cache.Org.getPartition(CACHE_PARTITION);
            
            Long expiryTime = 
                (DateTime.now().getTime() / 1000) + expiresIn;
            
            // Store with TTL slightly less than actual expiry
            Integer cacheTTL = expiresIn - 60;
            
            partition.put(
                ACCESS_TOKEN_KEY, 
                accessToken, 
                cacheTTL
            );
            
            partition.put(
                TOKEN_EXPIRY_KEY, 
                expiryTime, 
                cacheTTL
            );
            
            if (String.isNotBlank(refreshToken)) {
                // Refresh token lives longer - 24 hours
                partition.put(
                    REFRESH_TOKEN_KEY, 
                    refreshToken, 
                    86400
                );
            }
            
            System.debug('✅ Tokens stored in cache');
            System.debug('Expires in: ' + expiresIn + ' seconds');
            
        } catch (Exception e) {
            System.debug('Cache write error: ' + e.getMessage());
        }
    }

    // ─── Refresh Access Token ─────────────────────────────────────
    public static String refreshAccessToken(String refreshToken) {
        
        System.debug('=== Refreshing Access Token ===');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_URL);
        req.setMethod('POST');
        req.setHeader(
            'Content-Type', 
            'application/x-www-form-urlencoded'
        );
        req.setTimeout(30000);
        
        String body = 
            'grant_type=refresh_token' +
            '&refresh_token=' + 
            EncodingUtil.urlEncode(refreshToken, 'UTF-8') +
            '&client_id=' + 
            EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8') +
            '&client_secret=' + 
            EncodingUtil.urlEncode(CLIENT_SECRET, 'UTF-8');
        
        System.debug('Refresh Request Body: ' + body);
        
        req.setBody(body);
        
        Http http        = new Http();
        HttpResponse res = http.send(req);
        
        System.debug('Refresh Status: ' + res.getStatusCode());
        System.debug('Refresh Body  : ' + res.getBody());
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> tokenResp = 
                (Map<String, Object>) 
                JSON.deserializeUntyped(res.getBody());
            
            String newAccessToken  = 
                (String)  tokenResp.get('access_token');
            String newRefreshToken = 
                (String)  tokenResp.get('refresh_token');
            Integer expiresIn      = 
                (Integer) tokenResp.get('expires_in');
            
            // Store new tokens
            storeTokensInCache(
                newAccessToken,
                newRefreshToken != null ? 
                    newRefreshToken : refreshToken,
                expiresIn != null ? expiresIn : 3600
            );
            
            return newAccessToken;
            
        } else {
            throw new TokenException(
                'Refresh failed: ' + res.getStatusCode() + 
                ' ' + res.getBody()
            );
        }
    }

    // ─── Get New Token via Named Credential ───────────────────────
    // Named Credential handles Browser Flow OAuth
    // Token is auto managed by Salesforce
    private static String getNewTokenViaNamedCredential() {
        try {
            // Make a test callout via Named Credential
            // This triggers OAuth flow if not authenticated
            HttpRequest req = new HttpRequest();
            req.setEndpoint(
                'callout:Core_MDF_MCP_Contract_API' +
                '/contract-foundation/v1/mcp'
            );
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(30000);
            
            // Minimal MCP payload just to get token
            req.setBody('{"jsonrpc":"2.0","id":0,' +
                        '"method":"initialize",' +
                        '"params":{"protocolVersion":"2024-11-05",' +
                        '"capabilities":{},' +
                        '"clientInfo":{"name":"SF","version":"1.0"}}}');
            
            Http http        = new Http();
            HttpResponse res = http.send(req);
            
            System.debug('NC Response: ' + res.getStatusCode());
            
            // Named Credential token is managed internally
            // Return success indicator
            if (res.getStatusCode() == 200) {
                return 'NC_MANAGED'; // Token managed by Named Credential
            } else {
                throw new TokenException(
                    'Named Credential auth failed: ' + 
                    res.getStatusCode()
                );
            }
            
        } catch (Exception e) {
            throw new TokenException(
                'Token acquisition failed: ' + e.getMessage()
            );
        }
    }

    // ─── Clear Cache ──────────────────────────────────────────────
    public static void clearTokenCache() {
        try {
            Cache.OrgPartition partition = 
                Cache.Org.getPartition(CACHE_PARTITION);
            partition.remove(ACCESS_TOKEN_KEY);
            partition.remove(REFRESH_TOKEN_KEY);
            partition.remove(TOKEN_EXPIRY_KEY);
            System.debug('✅ Token cache cleared');
        } catch (Exception e) {
            System.debug('Cache clear error: ' + e.getMessage());
        }
    }
    
    public class TokenException extends Exception {}
}