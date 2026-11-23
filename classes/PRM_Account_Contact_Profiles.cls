@SuppressWarnings('PMD')
@RestResource(urlMapping='/GetProfile/*')
global class PRM_Account_Contact_Profiles {
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'GetProfile API';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_Account_Contact_Profiles class';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    
    @HttpPost
    global static PRM_Account_Contact_Profiles_Model.Profiles GetProfiles(){
        try{
            PRM_Account_Contact_Profiles_Utility.startTime = system.now().getTime();
            String PERSONBASICPROFILE = 'PERSONBASICPROFILE';
            String PERSONACCOUNT = 'PERSONACCOUNT';
            String ACCOUNTPROFILE = 'ACCOUNTPROFILE';
            String BUSINESSPERSON = 'BUSINESSPERSON';
            String REGREQUESTPROFILE = 'REGREQUESTPROFILE';
            String ACCOUNTREQUEST = 'ACCOUNTREQUEST';
            String CONTACTID = 'CONTACTID';
            String ACCOUNTID = 'ACCOUNTID';
            String REQUESTID = 'REQUESTID';
            String CIMID = 'CIMID';
            String EMAILID = 'EMAILID';
            String ENTERPRISEID = 'ENTERPRISEID';
            String LOGINID = 'LOGINID';
            String ERPM_ACCOUNT_NUMBER = 'ERPMACCOUNTNUMBER';
            
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                RestContext.request.requestBody.toString()
            );
            //system.debug('params ===>'+params);
            Map<String, Object> KeyInput = (Map<String, Object>)params.get('KeyInput');
            String attribute  = (params.containsKey('Attribute'))?((String) params.get('Attribute')).trim().toUpperCase():null;
            String inputfield = (KeyInput.containsKey('InputField'))?((!String.isEmpty((String) KeyInput.get('InputField')))?((String) KeyInput.get('InputField')).trim().toUpperCase():null):null;
            String inputvalue = (KeyInput.containsKey('InputValue'))?((!String.isEmpty((String) KeyInput.get('InputValue')))?((String) KeyInput.get('InputValue')).trim():null):null;
            String addtlInputField = (KeyInput.containsKey('AdditionalInputField'))?((!String.isEmpty((String) KeyInput.get('AdditionalInputField')))?((String) KeyInput.get('AdditionalInputField')).trim().toUpperCase():null):null;
            String addtlInputValue = (KeyInput.containsKey('AdditionalInputValue'))?((!String.isEmpty((String) KeyInput.get('AdditionalInputValue')))?((String) KeyInput.get('AdditionalInputValue')).trim():null):null;
            //(KeyInput.containsKey('InputValue'))?((String) KeyInput.get('InputValue')).trim():null;
            system.debug('addtlInputField ==>'+addtlInputField);
            system.debug('addtlInputField ==>'+addtlInputValue);
            
            //String whereClause = '';
            String error = '';
            
            if(String.isEmpty(inputvalue) || String.isEmpty(inputfield)){
                error = 'Bad request. No input field/input value passed';
                return PRM_Account_Contact_Profiles_Utility.generateError(error);
            }
            SWITCH on attribute {
                WHEN 'PERSONACCOUNT', 'BUSINESSPERSON' {
                    if(inputfield == CONTACTID ){                       
                        if(Id.valueOf(inputvalue).getSObjectType() != Contact.SobjectType ){
                            error = 'Input value is a not valid Contact Id'; 
                            return PRM_Account_Contact_Profiles_Utility.generateError(error);
                        }else{                           
                            if(attribute == BUSINESSPERSON){
                                return PRM_Account_Contact_Profiles_Utility.GetPersonBasicProfile(inputValue); 
                            }else{
                                return PRM_Account_Contact_Profiles_Utility.GetPersonAccount(inputValue); 
                            }
                        }
                        
                    }else if(inputfield==EMAILID || inputfield==ENTERPRISEID || inputfield==LOGINID){                  
                        if(attribute == BUSINESSPERSON){
                            return PRM_Account_Contact_Profiles_Utility.GetPersonBasicProfile(inputValue); 
                        }else{
                            return PRM_Account_Contact_Profiles_Utility.GetPersonAccount(inputValue); 
                        }
                    }else{
                        error = 'Input value is not a valid ContactID/EMAILID/ENTERPRISEID/LOGINID';  
                        return PRM_Account_Contact_Profiles_Utility.generateError(error); 
                    }
                }//End of WHEN
                When 'ACCOUNTPROFILE' {
                    if(inputfield != ACCOUNTID && inputfield!= CIMID){
                        error = 'Input field should be a valid AccountId/CIMID';
                        return PRM_Account_Contact_Profiles_Utility.generateError(error);
                    }else{                        
                        if(inputfield == ACCOUNTID && Id.valueOf(inputvalue).getSObjectType() != Account.SobjectType ){
                            error = 'Input value is not a valid Account Id'; 
                            return PRM_Account_Contact_Profiles_Utility.generateError(error);
                        }else if(!String.isEmpty(addtlInputField) && addtlInputField != ERPM_ACCOUNT_NUMBER ){
                            error = 'Additional Input field should be ERPMACCOUNTNUMBER'; 
                            return PRM_Account_Contact_Profiles_Utility.generateError(error);
                        }else{                           
                            return PRM_Account_Contact_Profiles_Utility.GetAccountProfile(inputfield, inputvalue, addtlInputValue);
                        }                       
                    }//End of ELSE
                }// End of WHEN
                When 'ACCOUNTREQUEST','REGREQUESTPROFILE' {
                    if(inputfield == REQUESTID){                  
                        if(Id.valueOf(inputvalue).getSObjectType() != PRM_Registration_Request__c.SobjectType ){
                            error = 'Input value is not a valid Request Id'; 
                            return PRM_Account_Contact_Profiles_Utility.generateError(error);
                        }else{
                            if(attribute == ACCOUNTREQUEST){
                                return PRM_Account_Contact_Profiles_Utility.GetAccountRequestDetails(inputValue);  
                            }else{
                                return PRM_Account_Contact_Profiles_Utility.GetRegistrationRequestProfile(inputValue); 
                            }                            
                        }                        
                    }else if(inputfield == EMAILID || inputfield == ENTERPRISEID || inputfield == LOGINID){
                        if(attribute == ACCOUNTREQUEST){
                            return PRM_Account_Contact_Profiles_Utility.GetAccountRequestDetails(inputValue);  
                        }else{
                            return PRM_Account_Contact_Profiles_Utility.GetRegistrationRequestProfile(inputValue);  
                        }   
                    }else{
                        error = 'Input value is not a valid RequestId/EMAILID/ENTERPRISEID/LOGINID';  
                        return PRM_Account_Contact_Profiles_Utility.generateError(error); 
                    }               
                }// End of WHEN     
                WHEN 'ONEPARTNERIDGROUPMEMBERS' {
                    if(inputfield != ACCOUNTID && inputfield != CIMID){
                        error = 'Input should be a valid Account Id/CIMID';
                        return PRM_Account_Contact_Profiles_Utility.generateError(error);
                    }else{
                        if(inputfield == ACCOUNTID){                            
                            if(Id.valueOf(inputvalue).getSObjectType() != Account.SobjectType ){
                                error = 'Input value is a not valid Account Id'; 
                                return PRM_Account_Contact_Profiles_Utility.generateError(error);
                            }else{                           
                                return PRM_Account_Contact_Profiles_Utility.GetOnePartnerIDGroupMembers(inputfield,inputvalue);
                            }                            
                        }else{
                            return PRM_Account_Contact_Profiles_Utility.GetOnePartnerIDGroupMembers(inputfield,inputvalue);
                        }
                        
                    }//End of ELSE
                }// End of WHEN 
                WHEN 'ACCOUNTRESULT' {
                    if(inputfield != CIMID){
                         error = 'Input value is not a valid CIMID';  
                         return PRM_Account_Contact_Profiles_Utility.generateAccountResultError(error);                                         
                    }else {                      
                         return PRM_Account_Contact_Profiles_Utility.GetAccountResults(inputValue, addtlInputValue);                           
                    }               
                }// End of WHEN  
                WHEN null {
                    if(!(inputfield == EMAILID || inputfield == ENTERPRISEID || inputfield == LOGINID)){
                          error = 'Input value is not a valid EMAILID/ENTERPRISEID/LOGINID';  
                         return PRM_Account_Contact_Profiles_Utility.generateError(error);                                         
                    }else {                      
                         return PRM_Account_Contact_Profiles_Utility.GetRegRequestAccountProfile(inputValue);
                         //return PRM_Account_Contact_Profiles_Utility.GetRegRequestAccountProfiles(inputValue);                           
                    }               
                }// End of WHEN  
                When else {
                    error = 'Attribute is not a valid one!';
                    return PRM_Account_Contact_Profiles_Utility.generateError(error);
                }
            }//ENd of SWITCH     
            
        }catch(Exception ex){           
            
            CustomException custEx = new CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();
            
            createLogEntry('Error in GetProfile API', custEx, LOG_ENTRY_ERROR, RestContext.request.requestBody.toString());  
            return PRM_Account_Contact_Profiles_Utility.generateException(ex);
        }
    }
    private static void createLogEntry(String Msg, CustomException ex, String Severity, String params){
        try{         
            //String strTags = '';
            String strDetailsAndEx = '';
            Id recordId = null;
            
            if( ex != null ) {
                strDetailsAndEx += 'Message: ' + ex.Message + '\n';
                strDetailsAndEx += 'Cause: ' + ex.Cause + '\n';
                strDetailsAndEx += 'Line Number: ' + ex.LineNumber + '\n';
                strDetailsAndEx += 'Stack Trace: ' + ex.StackTraceString + '\n';
                strDetailsAndEx += 'Type Name: ' + ex.TypeName + '\n';
            }
            Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                //Name = strLogEntryName, // From Service Cloud
                Core_Origin__c = LOG_ENTRY_ORIGIN,
                Core_Project__c = LOG_ENTRY_PROJECT,
                Core_Scope__c = LOG_ENTRY_SCOPE,
                Core_Severity__c = Severity,
                Core_Message__c = Msg,
                Core_When__c = system.now(),
                //Core_Status__c = Label.ICS_App_Logging_Default_Status, // From Service Cloud
                //Core_Invocation_ID__c = strInvocationID, // From Service Cloud
                Core_Details__c = strDetailsAndEx,
                Core_sObjectId__c = null,
                Core_sObjectType__c = null,
                Core_Tags__c = params
            );
            insert objCLE;
            //system.debug('Log Entry Id ==>'+objCLE.Id);
        }catch(Exception e){
            system.debug('Error Cause ==>Log Entry -->'+ e.getCause());
            system.debug('Error Message==>Log Entry -->'+ e.getMessage());
            //system.debug('Error Message==>Log Entry -->'+ ex.ge);
        }
        
    }
    private class CustomException extends Exception {
        public String message {set;get;}
        public Exception cause {set;get;}
        public Integer lineNumber {set;get;}
        public String stackTraceString {set;get;}
        public String typeName {set;get;}
    }
    
}