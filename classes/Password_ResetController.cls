public without sharing class Password_ResetController {
    
    @AuraEnabled()
    public static string sendEmail(String inputRequest) {
        string result = '';
        try{
            if(string.isNotEmpty(inputRequest)) {              
                string encrypedEmail = EncryptDecryptHelper.EncryptData(inputRequest);  
                string request = inputRequest;                
                List<Contact> contacts = [SELECT Id,Core_Preferred_Language__c,Email,Core_IPA_PartnerRole__c, AccountId, MailingCountryCode, Account.Name ,Account.AccountNumber FROM Contact WHERE Email =: request OR Core_Login_Id__c =: request OR Core_Enterprise_Id__c =: request LIMIT 1];
                if(contacts !=null && contacts.size() > 0){                                                                     
                    result = POC_AGS_CallbackHandler.sendEmailToContact(contacts[0], encrypedEmail,null, true)[1];
                }                
                //system.debug('GetPasswordResetToken ---> Bearer Token :--- > ' + brearerToken);
                system.debug('sendEmail ---> Resut :--- > ' + result);
            }
        }catch(exception ex){ 
            System.debug('ex '+ ex.getMessage());
            return '';
        }
        return result;
    }
    
    @AuraEnabled()
    public static string EncryptEmail(String email) {
        string result = '';       
        if(string.isNotEmpty(email)) {           
            result = EncryptDecryptHelper.EncryptData(email);            
        }
        system.debug('----- EncryptEmail email id-------> ' + result );
        return result;
    }
    
    @AuraEnabled()
    public static string GetPasswordResetToken(String encrypedInput) {
        string result = '';
        system.debug('------ encrypedInput---------> ' + encrypedInput );
        if(string.isNotEmpty(encrypedInput)) {           
            result = GetPasswordToken(EncryptDecryptHelper.DecryptData(encrypedInput));
        }
        system.debug('------- Password Reset Token---------> ' + result);
        return result;
    }        
    
    Public static string GetBearerToken(){
        string result = ''; 
        try{            
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setTimeout(120000);
            // Specify the required user name and password to access the endpoint             
            request.setHeader('Content-Type','application/x-www-form-urlencoded');
            request.setEndpoint('https://apis-sandbox.intel.com/v1/auth/token');                                                                                               
            request.setBody('grant_type=client_credentials' + '&client_id=' + EncodingUtil.urlEncode('95f0c6ed-833d-4276-bc8b-2b9e034abf08','UTF-8') + '&client_secret=' + EncodingUtil.urlEncode('RRRA42aG7a7UDe6bi-..MX1KfhH.0E.~n.', 'UTF-8') + '&scope=');                                                                   
            //request.setBody('client_credentials&client_id=95f0c6ed-833d-4276-bc8b-2b9e034abf08&client_secret=RRRA42aG7a7UDe6bi-..MX1KfhH.0E.~n.');
            System.HttpResponse response = new Http().send(request);
            System.debug(response.getBody());  
            if (response.getStatusCode() == 200) {
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, String> values = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);                 
                result = values.get('access_token');
                system.debug('Authorization from response --> '+result);                                             
            }
            
        }catch(exception e){
            System.debug('exception Silam --- ' + e);
        }
        return result;
    }
    
    Public static string GetPasswordToken(string loginId){
        string token = ''; 
        string PasswordResetToken = '';  
        system.debug('GetPasswordToken Start');
        
        try{   
            if(string.isNotBlank(loginId)){
                HttpRequest request = new HttpRequest();
                request.setMethod('POST');
                request.setTimeout(120000);
                // Specify the required user name and password to access the endpoint             
                request.setHeader('Content-Type','application/x-www-form-urlencoded');
                request.setEndpoint('https://apis-sandbox.intel.com/v1/auth/token');                                                                                               
                request.setBody('grant_type=client_credentials' + '&client_id=' + EncodingUtil.urlEncode('95f0c6ed-833d-4276-bc8b-2b9e034abf08','UTF-8') + '&client_secret=' + EncodingUtil.urlEncode('RRRA42aG7a7UDe6bi-..MX1KfhH.0E.~n.', 'UTF-8') + '&scope=');                                                                   
                //request.setBody('client_credentials&client_id=95f0c6ed-833d-4276-bc8b-2b9e034abf08&client_secret=RRRA42aG7a7UDe6bi-..MX1KfhH.0E.~n.');
                System.HttpResponse response = new Http().send(request);
                System.debug(response.getBody());  
                if (response.getStatusCode() == 200) {
                    // Deserialize the JSON string into collections of primitive data types.
                    Map<String, String> values = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);                 
                    token = values.get('access_token');
                    system.debug('Authorization from response Token --> '+token);                                             
                }
                
                
                //String payLoad = string.isNotBlank(loginId) ? loginId : 'auto_mknga_csp@mailinator.com'; 
                //String payLoad = 'auto_mknga_csp@mailinator.com';
                request = new HttpRequest();           
                request.setEndpoint('https://apis-stage.intel.com/m2r/Identity/v1/password-reset/tokens');
                request.setMethod('POST');
                request.setTimeout(120000);
                // Specify the required user name and password to access the endpoint           
                request.setHeader('Content-Type','application/json');                
                request.setHeader('Authorization','Bearer ' + EncodingUtil.urlEncode(token,'UTF-8'));            
                system.debug('Before Getting the response from Password Reset Token method  --> '+token);
                request.setBody(constructInputJSON(loginId));
                System.HttpResponse response1 = new System.Http().send(request);
                system.debug(response1.getBody());  
                if (response1.getStatusCode() == 200 || response1.getStatusCode() == 201) {                
                    // Deserialize the JSON string into collections of primitive data types.
                    //Map<String, string> results = (Map<String, string>) JSON.deserializeUntyped(response.getBody());
                    PasswordResetTokenWrapper passTokenObj = (PasswordResetTokenWrapper)JSON.deserialize(response1.getBody(), PasswordResetTokenWrapper.class);
                    system.debug('PasswordResetTokenWrapper from response --> '+ passTokenObj);
                    PasswordResetToken = passTokenObj.passwordResetToken;
                    system.debug('PasswordResetToken from response --> '+PasswordResetToken);                
                } 
            }
            else{
                System.debug('Login Id is empty! --- ');
            }
        }catch(exception e){
            System.debug('exception Silam --- ' + e);
        }        
        return PasswordResetToken;
    }
    
    private static String constructInputJSON(string loginId) {
        system.JSONGenerator jg = JSON.createGenerator(false);  
        jg.writeStartObject();                            
        jg.writeStringField('loginId', loginId);       
        jg.writeEndObject();
        system.debug('JSON ==>'+jg.getAsString());
        return jg.getAsString();
    }
    
    public class PasswordResetTokenWrapper{
        public string loginId {get;set;}
        public string passwordResetToken {get;set;}
        public boolean isInternal {get;set;}       
    }
}