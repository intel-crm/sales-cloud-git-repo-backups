public class CRM_Account_Pulse_Integration {
       
    public static Map<String,Object> getAccountPulse(List<Id> execIds) {
        Map<String,Object> summaryMap = new Map<String,Object>();
        
        try {
            List<Executive_Meeting_Brief__c> execMeetingBriefList = [SELECT Id, Account__c FROM Executive_Meeting_Brief__c WHERE Id IN:execIds];        
            String userId = UserInfo.getUserName();
            PageReference newPage = Page.GetSessionIdPage;
            String content = newPage.getContent().toString();              
            String sid = content.substringBetween('<SessionId>', '</SessionId>'); 
            
            for(Executive_Meeting_Brief__c execRec : execMeetingBriefList){
                String token = getAuthToken(userId,sid);
                if (String.isNotBlank(token)) {
                    // Pass the exec ID to getSummary method
                    Map<String,Object> getSummaryResponse = getSummary(execRec.Id, execRec.Account__c, token);
                    if (getSummaryResponse != null && !getSummaryResponse.isEmpty()) {
                        summaryMap.putAll(getSummaryResponse);
                    }
                }
                else{
                    summaryMap.put(execRec.Id,null);
                }
            }
            
        } catch (Exception e) {
            system.debug('Exception in getAccountPulseSummary: ' + e.getMessage());
        }
        
        return summaryMap;
    }
    
    public static String getAuthToken(String userId,String sessionToken) {       
        String endpoint = Core_CRM_Utility.getCRMLabel('CRM_EMB_Account_Pulse_Auth');
        String username = userId.contains('@') ? userId.split('@')[0] : userId;
        
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('user_id', username);
        requestBody.put('sid', sessionToken);
        requestBody.put('app', 'pulse');
        
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
        
            if (res.getStatusCode() != 200) {
                return null;
            }
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Integer statusCode = (Integer) response.get('statusCode');
            
            if (statusCode != 200) {
                return null;
            }
            
            Map<String, Object> body = (Map<String, Object>) response.get('body');
            return (String) body?.get('token');
            
        } catch (Exception e) {
            return null;
        }
    }
    
    // Updated getSummary method to return Map<String,String>
    public static Map<String,Object> getSummary(String execId, String accountId, String token) {
        Map<String,Object> resultMap = new Map<String,Object>();
        String endpoint = Core_CRM_Utility.getCRMLabel('CRM_EMB_Account_Pulse_Endpoint');
        List<Core_CDB_Integration_Log__c> cdbLogList = new List<Core_CDB_Integration_Log__c>();
        
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('app', 'pulse');
        requestBody.put('action', 'get_curr_summary');
        requestBody.put('account_id', accountId);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-access-token', token);
        req.setBody(JSON.serialize(requestBody));
        req.setTimeout(60000);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() != 200) {
            resultMap.put(execId, null);
            return resultMap; // Return empty map
        }
        
        // Parse the JSON response
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> body = (Map<String, Object>) response.get('body');
        
        if (body != null) {
            Object summaryObj = body.get('summary');
            if (summaryObj != null) {
                // Store the summary as JSON string
                resultMap.put(execId, summaryObj);
            } else {
                // No summary found - store empty string
                resultMap.put(execId,null);
            }
        }
        Boolean isSuccess = (res != null && (res.getStatus() == 'SUCCESS' || res.getStatus() == 'OK')) ? true : false;
        // Create log record
        Core_CDB_Integration_Log__c logRec = new Core_CDB_Integration_Log__c();
        logRec.Core_Integration_Type__c = 'Account Pulse Executive Meeting Brief';
        logRec.Core_Record_Id__c = execId;
        logRec.Core_Log_Status_Nm__c = isSuccess ? 'Successful' : 'Failed';
        logRec.Core_Status_Code__c = (res != null) ? String.valueOf(res.getStatusCode()) : '';
        logRec.Core_Status_Message__c = (res != null) ? res.getStatus() : '';
        logrec.Core_Integration_Direction_Nm__c ='Outbound';
        cdbLogList.add(logRec);
        
        if(!cdbLogList.isEmpty()){
            Database.UpsertResult[] upsertResultList = Database.upsert(cdbLogList,Core_CDB_Integration_Log__c.Core_Record_Id__c, false);
            
        }
        
        return resultMap;
    }
}