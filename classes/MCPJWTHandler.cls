public with sharing class MCPJWTHandler {
    
    // ─── JWT Configuration ────────────────────────────────────────
    private static final String CLIENT_ID    = 
        '7ae3efb8-1f4c-4a94-82ab-8b476f9dab57';                    // From Auth Provider
    private static final String TOKEN_URL    = 
        'https://apisx-dev.intel.com/v1/auth/pkce/token'; // Token Endpoint
    private static final String AUDIENCE     = 
        'https://apisx-dev.intel.com/v1/auth/pkce/token'; // aud claim
    private static final String CERT_NAME    = 
        'RMF_MCP_JWT_Cert';                  // Certificate API Name
    private static final String MCP_BASE_URL = 
        'https://apisx-dev.intel.io';
    private static final String MCP_ENDPOINT = 
        '/contract-foundation/v1/mcp';

    // ─── Build JWT Token Manually ─────────────────────────────────
    public static String generateJWT() {
        
        // ── JWT Header ────────────────────────────────────────────
        Map<String, Object> header = new Map<String, Object>{
            'alg' => 'RS256',   // RSA SHA256
            'typ' => 'JWT'
        };
        
        // ── JWT Payload / Claims ──────────────────────────────────
        Long issuedAt  = DateTime.now().getTime() / 1000;
        Long expiresAt = issuedAt + 3600; // 1 hour
        
        Map<String, Object> claims = new Map<String, Object>{
            'iss'   => CLIENT_ID,                    // issuer
            'sub'   => UserInfo.getUserName(),        // subject = current user
            'aud'   => AUDIENCE,                     // audience
            'iat'   => issuedAt,                     // issued at
            'exp'   => expiresAt,                    // expiry
            'email' => UserInfo.getUserEmail()        // optional
        };
        
        System.debug('JWT Claims: ' + JSON.serialize(claims));
        
        // ── Encode Header ─────────────────────────────────────────
        String headerEncoded = base64URLEncode(
            Blob.valueOf(JSON.serialize(header))
        );
        
        // ── Encode Payload ────────────────────────────────────────
        String payloadEncoded = base64URLEncode(
            Blob.valueOf(JSON.serialize(claims))
        );
        
        // ── Create Signing Input ──────────────────────────────────
        String signingInput = headerEncoded + '.' + payloadEncoded;
        
        // ── Sign with Certificate ─────────────────────────────────
        Blob signature = Crypto.signWithCertificate(
            'RSA-SHA256',
            Blob.valueOf(signingInput),
            CERT_NAME
        );
        
        // ── Encode Signature ──────────────────────────────────────
        String signatureEncoded = base64URLEncode(signature);
        
        // ── Final JWT ─────────────────────────────────────────────
        String jwt = signingInput + '.' + signatureEncoded;
        
        System.debug('Generated JWT: ' + jwt);
        
        return jwt;
    }
    
    // ─── Exchange JWT for Access Token ────────────────────────────
    public static String getAccessToken() {
        
        String jwt = generateJWT();
        
        // ── Build Token Request ───────────────────────────────────
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 
                      'application/x-www-form-urlencoded');
        req.setTimeout(30000);
        
        // ── JWT Bearer Grant Type ─────────────────────────────────
        String body = 
            'grant_type=' + 
            EncodingUtil.urlEncode(
                'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'UTF-8'
            ) +
            '&assertion=' + 
            EncodingUtil.urlEncode(jwt, 'UTF-8');
        
        System.debug('Token Request Body: ' + body);
        
        req.setBody(body);
        
        Http http        = new Http();
        HttpResponse res = http.send(req);
        
        System.debug('Token Response Code: ' + res.getStatusCode());
        System.debug('Token Response Body: ' + res.getBody());
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> tokenResponse = 
                (Map<String, Object>) 
                JSON.deserializeUntyped(res.getBody());
            
            String accessToken = 
                (String) tokenResponse.get('access_token');
            
            System.debug('Access Token received successfully');
            
            return accessToken;
            
        } else {
            throw new JWTException(
                'Token exchange failed. ' +
                'Status: '  + res.getStatusCode() + 
                ' Body: '   + res.getBody()
            );
        }
    }
    
    // ─── Base64 URL Encode ────────────────────────────────────────
    private static String base64URLEncode(Blob input) {
        String base64    = EncodingUtil.base64Encode(input);
        // Convert standard base64 to URL safe base64
        String urlSafe   = base64
            .replace('+', '-')
            .replace('/', '_')
            .replace('=', '');
        return urlSafe;
    }
    
    public class JWTException extends Exception {}
}