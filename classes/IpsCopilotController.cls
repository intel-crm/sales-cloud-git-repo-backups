public with sharing class IpsCopilotController {
    @AuraEnabled(cacheable=true)
    public static String getSessionId() {
        // Returns a valid session ID that can be used to make REST API and MCP calls
        return UserInfo.getSessionId();
    }
}