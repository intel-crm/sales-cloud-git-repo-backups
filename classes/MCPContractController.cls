public with sharing class MCPContractController {
    private static final String EXTERNAL_CREDENTIAL = 'Core_MDF_Contract_Retriever_API';

    @AuraEnabled
    public static String getAuthenticationUrl(String returnPath) {
        if (String.isBlank(returnPath) || !returnPath.startsWith('/lightning/') ||
            returnPath.contains('\\') || returnPath.contains('\n') || returnPath.contains('\r')) {
            throw new AuraHandledException('Invalid return path');
        }

        ConnectApi.OAuthCredentialAuthUrlInput input = new ConnectApi.OAuthCredentialAuthUrlInput();
        input.externalCredential = EXTERNAL_CREDENTIAL;
        input.principalType = ConnectApi.CredentialPrincipalType.PerUserPrincipal;
        input.returnUrl = returnPath;
        return ConnectApi.NamedCredentials.getOAuthCredentialAuthUrl(input).authenticationUrl.unescapeHtml4();
    }
    
    // ─────────────────────────────────────────
    // Initialize Session
    // ─────────────────────────────────────────
    @AuraEnabled
    public static Map<String, Object> initializeMCPSession() {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Step 1: Initialize
            MCPContractService.MCPResponse initRes = 
                MCPContractService.initializeSession();
            
            if (!initRes.isSuccess) {
                result.put('success', false);
                result.put('error',   initRes.errorMessage);
                result.put('requiresAuth', initRes.requiresAuth);
                return result;
            }
            
            String sessionId = initRes.sessionId;
            System.debug('Controller SessionId: ' + sessionId);
            
            // Step 2: Send Notification
            if (String.isNotBlank(sessionId)) {
                MCPContractService.MCPResponse notifRes = 
                    MCPContractService.sendInitializedNotification(sessionId);
                System.debug('Notification Status: ' + notifRes.statusCode);
                if (notifRes.requiresAuth) {
                    result.put('success', false);
                    result.put('error', notifRes.errorMessage);
                    result.put('requiresAuth', true);
                    return result;
                }
            }
            
            result.put('success',      true);
            result.put('sessionId',    sessionId);
            result.put('responseBody', initRes.body);
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error',   e.getMessage());
        }
        
        return result;
    }
    
    // ─────────────────────────────────────────
    // Get Available Tools
    // ─────────────────────────────────────────
    @AuraEnabled
    public static Map<String, Object> getAvailableTools(String sessionId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            System.debug('getAvailableTools SessionId: ' + sessionId);
            
            MCPContractService.MCPResponse res = 
                MCPContractService.listTools(sessionId);
            
            System.debug('Tools Success: ' + res.isSuccess);
            System.debug('Tools Body: '    + res.body);
            
            result.put('success', res.isSuccess);
            result.put('body',    res.body);
            result.put('requiresAuth', res.requiresAuth);
            
            if (!res.isSuccess) {
                result.put('error', res.errorMessage);
            }
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error',   e.getMessage());
        }
        
        return result;
    }
    
    // ─────────────────────────────────────────
    // Call Contract Metadata Tool
    // ─────────────────────────────────────────
    @AuraEnabled
    public static Map<String, Object> getContractMetadata(
        String  sessionId,
        Integer contractNumber,
        Integer orderNumber
    ) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            System.debug('getContractMetadata - SessionId: '      + sessionId);
            System.debug('getContractMetadata - ContractNumber: ' + contractNumber);
            System.debug('getContractMetadata - OrderNumber: '    + orderNumber);
            
            MCPContractService.MCPResponse res = 
                MCPContractService.callContractMetadata(
                    sessionId, 
                    contractNumber, 
                    orderNumber
                );
            
            result.put('success',     res.isSuccess);
            result.put('body',        res.body);
            result.put('contentType', res.contentType);
            result.put('sessionId',   res.sessionId);
            result.put('requiresAuth', res.requiresAuth);
            
            if (!res.isSuccess) {
                result.put('error', res.errorMessage);
            }
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error',   e.getMessage());
        }
        
        return result;
    }
    
    // ─────────────────────────────────────────
    // Full Flow: Init + List Tools + Call Tool
    // ─────────────────────────────────────────
    @AuraEnabled
    public static Map<String, Object> executeFullContractFlow(
        Integer contractNumber,
        Integer orderNumber
    ) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Step 1: Initialize
            MCPContractService.MCPResponse initRes = 
                MCPContractService.initializeSession();
            
            if (!initRes.isSuccess) {
                result.put('success', false);
                result.put('error',   initRes.errorMessage);
                result.put('requiresAuth', initRes.requiresAuth);
                return result;
            }
            
            String sessionId = initRes.sessionId;
            System.debug('Full Flow SessionId: ' + sessionId);
            
            // Step 2: Notification
            if (String.isNotBlank(sessionId)) {
                MCPContractService.MCPResponse notifRes = MCPContractService.sendInitializedNotification(sessionId);
                if (notifRes.requiresAuth) {
                    result.put('success', false);
                    result.put('error', notifRes.errorMessage);
                    result.put('requiresAuth', true);
                    return result;
                }
            }
            
            // Step 3: Call Tool
            MCPContractService.MCPResponse toolRes = 
                MCPContractService.callContractMetadata(
                    sessionId, 
                    contractNumber, 
                    orderNumber
                );
            
            result.put('success',        toolRes.isSuccess);
            result.put('body',           toolRes.body);
            result.put('contentType',    toolRes.contentType);
            result.put('sessionId',      sessionId);
            result.put('statusCode',     toolRes.statusCode);
            result.put('requiresAuth',   toolRes.requiresAuth);
            
            if (!toolRes.isSuccess) {
                result.put('error', toolRes.errorMessage);
            }
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error',   e.getMessage());
        }
        
        return result;
    }
}