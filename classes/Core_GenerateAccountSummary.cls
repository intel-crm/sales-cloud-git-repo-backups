public class Core_GenerateAccountSummary {
    
    @AuraEnabled(cacheable=true) 
    public static CustomSettingUserDetails getCustomSettingsUserWWID(){
        User userRec = [SELECT Id, Name, Core_WWID__c FROM User WHERE Id=:System.UserInfo.getUserId() LIMIT 1];
        CustomSettingUserDetails getDetails = new CustomSettingUserDetails();
        getDetails.customSetting = Core_CRM_Utility.getCRMLabel('Core_AccountPulse_IconPath');   
        getDetails.userWWID = userRec.Core_WWID__c;                    
        return  getDetails;
    }
    public class CustomSettingUserDetails{
        @AuraEnabled
        public String customSetting;
        @AuraEnabled
        public String userWWID;
    }
   
    @AuraEnabled(cacheable=true)
    public static Boolean makePostRequest(String recordId, String userId, String action, String userWWID) {
        system.debug('Core_GenerateAccountSummary class entry');
      	Boolean showValue = false;
        Core_GenerateAccountSummaryJson Top3;
        
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        Core_CRM_Labels__c apiSwitch = Core_CRM_Labels__c.getValues('Account_API_switch');
        Core_System_Credentials__c endPointURL = Core_System_Credentials__c.getValues('GenerateAccountSummaryAPIEndpoint');
               
        Map<String, Object> payload = new Map<String, Object>();
        System.debug('###'+userWWID);
        payload.put('account_id', recordId);
        payload.put('user_id', userWWID);
        payload.put('action', action);
        payload.put('user_sfid ', userId);
        
        // Create an HTTPRequest object
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPointURL.Core_End_Point_URL__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        
        // Serialize the payload to JSON format
        String requestBody = JSON.serialize(payload);
        
        request.setBody(requestBody);
               
        Http http = new Http();
        
        try {
            if(apiSwitch!= Null && apiSwitch.Value__c == 'true'){
                HttpResponse response = http.send(request);
                                
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                system.debug('respone Body'+responseBody);
                Top3 = Core_GenerateAccountSummaryJson.parse(responseBody);
                showValue = Top3.body.show;
                } }
        } catch (Exception e) {
           logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = e.getMessage(), Core_Origin__c='Core_GenerateAccountSummary.makePostRequest', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                    insert logEntries;
                }}
        }
        system.debug('showvalue'+showvalue);
        system.debug('Core_GenerateAccountSummary class exit');
       return showValue;
    }
}