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
        PRM_Account_Contact_Profiles_Model.Profiles response;
        DateTime reqTime = System.now();
        String inputvalue;
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
            String UNIFIEDID= 'UNIFIEDID';// TWC729-6955 : CIM Prime EOL –  Get Profile API - CIM EOL Activities
            String EMAILID = 'EMAILID';
            String ENTERPRISEID = 'ENTERPRISEID';
            String LOGINID = 'LOGINID';
            String ERPM_ACCOUNT_NUMBER = 'ERPMACCOUNTNUMBER';
            
            //wechat changes
            String WECHATID = 'WECHATUNIONID';
            
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                RestContext.request.requestBody.toString()
            );
            //system.debug('params ===>'+params);
            Map<String, Object> KeyInput = (Map<String, Object>)params.get('KeyInput');
            String attributeString  = (params.containsKey('Attribute'))?((String) params.get('Attribute')).trim().toUpperCase():null;
            List<String> atrributeList =new List<String>();
            if(attributeString!=null){
                 atrributeList=attributeString.split(',');
            }
           
            
            

            String inputfield = (KeyInput.containsKey('InputField'))?((!String.isEmpty((String) KeyInput.get('InputField')))? String.escapeSingleQuotes(((String) KeyInput.get('InputField'))).trim().toUpperCase():null):null;
            inputvalue = (KeyInput.containsKey('InputValue'))?((!String.isEmpty((String) KeyInput.get('InputValue')))? String.escapeSingleQuotes(((String) KeyInput.get('InputValue'))).trim():null):null;
            String addtlInputField = (KeyInput.containsKey('AdditionalInputField'))?((!String.isEmpty((String) KeyInput.get('AdditionalInputField')))?((String) KeyInput.get('AdditionalInputField')).trim().toUpperCase():null):null;
            String addtlInputValue = (KeyInput.containsKey('AdditionalInputValue'))?((!String.isEmpty((String) KeyInput.get('AdditionalInputValue')))?((String) KeyInput.get('AdditionalInputValue')).trim():null):null;
            Map<String, String> reqInputMap = new Map<String, String>{EMAILID => null,LOGINID => null, ENTERPRISEID => null, WECHATID => null, CONTACTID => null, ACCOUNTID => null, CIMID => null,UNIFIEDID => null, REQUESTID => null}; //Added UNIFIEDIS TWC729-6955 : CIM Prime EOL –  Get Profile API - CIM EOL Activities
            reqInputMap.put(inputfield, inputvalue);
            Boolean checksysAcc= false;
            PRM_Account_Contact_Profiles_Utility.isProgBased = (KeyInput.containsKey('IsProgramBased'))? (((String)KeyInput.get('IsProgramBased') == 'true') ? true : (((String)KeyInput.get('IsProgramBased') == 'false') ? false : null)) : null;
            PRM_Account_Contact_Profiles_Utility.inpValue = (KeyInput.containsKey('Name'))?((!String.isEmpty((String) KeyInput.get('Name')))? String.escapeSingleQuotes(((String) KeyInput.get('Name'))).trim():null):null;
            PRM_Account_Contact_Profiles_Utility.countryValue = (KeyInput.containsKey('Country'))?((!String.isEmpty((String) KeyInput.get('Country')))? String.escapeSingleQuotes(((String) KeyInput.get('Country'))).trim():null):null;
            //(KeyInput.containsKey('InputValue'))?((String) KeyInput.get('InputValue')).trim():null;
            system.debug('attribute ==>'+attributeString);
            system.debug('isProgBased ==>'+PRM_Account_Contact_Profiles_Utility.isProgBased);
            system.debug('value ==>'+PRM_Account_Contact_Profiles_Utility.inpValue);
            system.debug('inputvalue-'+atrributeList);
            //String whereClause = '';
            String error='';
            
            if(String.isEmpty(inputvalue) || String.isEmpty(inputfield)){
                error = error +'Bad request. No input field/input value passed\n';
                return PRM_Account_Contact_Profiles_Utility.generateError(error);
            }
            List<PRM_Account_Contact_Profiles_Model.Profiles> responseList = new List<PRM_Account_Contact_Profiles_Model.Profiles>();
            if(attributeString!=null){
                for(String attribute :atrributeList){
                SWITCH on attribute {
                WHEN 'PERSONACCOUNT', 'BUSINESSPERSON' {
                    if(inputfield == CONTACTID ){                       
                        if(Id.valueOf(inputvalue).getSObjectType() != Contact.SobjectType ){
                            error = error + 'Input value is a not valid Contact Id\n'; 
                            //return PRM_Account_Contact_Profiles_Utility.generateError(error);
                        }else{                           
                            if(attribute == BUSINESSPERSON){
                                responseList.add(PRM_Account_Contact_Profiles_Utility.GetPersonBasicProfile(inputfield,inputValue));
                                createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                                //return response;
                                //return PRM_Account_Contact_Profiles_Utility.GetPersonBasicProfile(inputValue); 
                            }else{
                                responseList.add(PRM_Account_Contact_Profiles_Utility.GetPersonAccount(inputfield,inputValue));
                                 createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                               // return response;
                                //return PRM_Account_Contact_Profiles_Utility.GetPersonAccount(inputValue); 
                            }
                        }
                        
                    }else if(inputfield==EMAILID || inputfield==ENTERPRISEID || inputfield==LOGINID || inputfield == WECHATID){                  
                        if(attribute == BUSINESSPERSON){
                            responseList.add(PRM_Account_Contact_Profiles_Utility.GetPersonBasicProfile(inputfield,inputValue));
                             createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                            //return response;
                            //return PRM_Account_Contact_Profiles_Utility.GetPersonBasicProfile(inputValue); 
                        }else{
                            responseList.add(PRM_Account_Contact_Profiles_Utility.GetPersonAccount(inputfield,inputValue));
                             createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                            //return response;
                            //return PRM_Account_Contact_Profiles_Utility.GetPersonAccount(inputValue); 
                        }
                    }else{
                        error = error + 'Input value is not a valid ContactID/EMAILID/ENTERPRISEID/LOGINID\n';  
                        //return PRM_Account_Contact_Profiles_Utility.generateError(error); 
                    }
                }//End of WHEN
                When 'ACCOUNTPROFILE' {
                    if(inputfield != ACCOUNTID && inputfield!= CIMID && inputfield!=UNIFIEDID){ // TWC729-6955 : CIM Prime EOL –  Get Profile API - CIM EOL Activities
                        error = error + 'Input field should be a valid AccountId/CIMID/UNIFIEDID\n';
                        //return PRM_Account_Contact_Profiles_Utility.generateError(error);
                    }else{                        
                        if(inputfield == ACCOUNTID && Id.valueOf(inputvalue).getSObjectType() != Account.SobjectType ){
                            error = error + 'Input value is not a valid Account Id\n'; 
                            //return PRM_Account_Contact_Profiles_Utility.generateError(error);
                        }else if(!String.isEmpty(addtlInputField) && addtlInputField != ERPM_ACCOUNT_NUMBER ){
                            error = error + 'Additional Input field should be ERPMACCOUNTNUMBER\n'; 
                            return PRM_Account_Contact_Profiles_Utility.generateError(error);
                        }else{ 
                            responseList.add(PRM_Account_Contact_Profiles_Utility.GetAccountProfile(inputfield, inputvalue, addtlInputValue));
                             createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                            //return response;
                            //return PRM_Account_Contact_Profiles_Utility.GetAccountProfile(inputfield, inputvalue, addtlInputValue);
                        }                       
                    }//End of ELSE
                }// End of WHEN
                When 'ACCOUNTREQUEST','REGREQUESTPROFILE' {
                    if(inputfield == REQUESTID){                  
                        if(Id.valueOf(inputvalue).getSObjectType() != PRM_Registration_Request__c.SobjectType ){
                            error = error + 'Input value is not a valid Request Id\n'; 
                           // return PRM_Account_Contact_Profiles_Utility.generateError(error);
                        }else{
                            if(attribute == ACCOUNTREQUEST){
                                responseList.add(PRM_Account_Contact_Profiles_Utility.GetAccountRequestDetails(inputfield,inputValue));
                                 createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                               // return response;
                                //return PRM_Account_Contact_Profiles_Utility.GetAccountRequestDetails(inputValue);  
                            }else{
                                responseList.add(PRM_Account_Contact_Profiles_Utility.GetRegistrationRequestProfile(inputfield,inputValue));
                                createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                               // return response;
                                //return PRM_Account_Contact_Profiles_Utility.GetRegistrationRequestProfile(inputValue); 
                            }                            
                        }                        
                    }else if(inputfield == EMAILID || inputfield == ENTERPRISEID || inputfield == LOGINID || inputfield == WECHATID){
                        if(attribute == ACCOUNTREQUEST){
                            responseList.add(PRM_Account_Contact_Profiles_Utility.GetAccountRequestDetails(inputfield,inputValue));
                             createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                            //return response;
                            //return PRM_Account_Contact_Profiles_Utility.GetAccountRequestDetails(inputValue);  
                        }else{
                            responseList.add(PRM_Account_Contact_Profiles_Utility.GetRegistrationRequestProfile(inputfield,inputValue));
                            createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                            //return response;
                            //return PRM_Account_Contact_Profiles_Utility.GetRegistrationRequestProfile(inputValue);  
                        }   
                    }else{
                        error = error + 'Input value is not a valid RequestId/EMAILID/ENTERPRISEID/LOGINID/WECHATID\n';  
                       // return PRM_Account_Contact_Profiles_Utility.generateError(error); 
                    }               
                }// End of WHEN     
                WHEN 'ONEPARTNERIDGROUPMEMBERS' {
                    if(inputfield != ACCOUNTID && inputfield != CIMID && inputfield!=UNIFIEDID){
                        error = error + 'Input should be a valid Account Id/CIMID/UNIFIEDID\n';
                       // return PRM_Account_Contact_Profiles_Utility.generateError(error);
                    }else{
                        if(inputfield == ACCOUNTID){                            
                            if(Id.valueOf(inputvalue).getSObjectType() != Account.SobjectType ){
                                error = error + 'Input value is a not valid Account Id\n'; 
                                //return PRM_Account_Contact_Profiles_Utility.generateError(error);
                            }else{
                               responseList.add(PRM_Account_Contact_Profiles_Utility.GetOnePartnerIDGroupMembers(inputfield,inputvalue));
                                 createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                                return response;
                                //return PRM_Account_Contact_Profiles_Utility.GetOnePartnerIDGroupMembers(inputfield,inputvalue);
                            }                            
                        }else{
                             responseList.add(PRM_Account_Contact_Profiles_Utility.GetOnePartnerIDGroupMembers(inputfield,inputvalue));
                             createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                            return response;
                            //return PRM_Account_Contact_Profiles_Utility.GetOnePartnerIDGroupMembers(inputfield,inputvalue);
                        }
                        
                    }//End of ELSE
                }// End of WHEN 
                WHEN 'ACCOUNTRESULT' {
                    if(inputfield != CIMID && inputfield != UNIFIEDID){// Added UNIFIEDID TWC729-6955 : CIM Prime EOL –  Get Profile API - CIM EOL Activities
                         error = error + 'Input value is not a valid CIMID/UNIFIEDID\n';  // TWC729-6955 : CIM Prime EOL –  Get Profile API - CIM EOL Activities
                         //return PRM_Account_Contact_Profiles_Utility.generateAccountResultError(error);                                         
                    }else {  
                         responseList.add(PRM_Account_Contact_Profiles_Utility.GetAccountResults(inputValue, addtlInputValue));
                         createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                        //return response;
                         //return PRM_Account_Contact_Profiles_Utility.GetAccountResults(inputValue, addtlInputValue);                           
                    }               
                }// End of WHEN
                WHEN 'CONTACTCMFGROUP' {
                    if(inputfield !=EMAILID && inputfield != ENTERPRISEID){
                        error = error + 'Input should be a valid EmailId/EnterpriseId\n';
                        //return PRM_Account_Contact_Profiles_Utility.generateError(error);
                   }else {  
                        if(inputfield == EMAILID || inputfield == ENTERPRISEID){
                           
                            
                              responseList.add(PRM_Account_Contact_Profiles_Utility.getCMfDetails(inputValue, inputfield));
                               createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                        }
                       
                       
                        
                                                   
                    }    
                    //return response;
                }
               
                   
               
                When else {
                    error = error + 'Attribute is not a valid one!\n';
                    //return PRM_Account_Contact_Profiles_Utility.generateError(error);
                }
                }
                }
                }
            //ENd of SWITCH    
            else{
                 if(!(inputfield == EMAILID || inputfield == ENTERPRISEID || inputfield == LOGINID || inputfield == WECHATID)){
                          error = error + 'Input value is not a valid EMAILID/ENTERPRISEID/LOGINID\n';  
                         //return PRM_Account_Contact_Profiles_Utility.generateError(error);                                         
                    }else{
                         responseList.add(PRM_Account_Contact_Profiles_Utility.GetRegRequestAccountProfile(inputfield,inputValue));
                         createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '/*+response.ResponseTimeMS*/, null, LOG_ENTRY_INFO,inputvalue );
                       // return response;    
                        //return PRM_Account_Contact_Profiles_Utility.GetRegRequestAccountProfile(inputValue, inputfield);
                        //return PRM_Account_Contact_Profiles_Utility.GetRegRequestAccountProfiles(inputValue);                           
                    }               
            } 
            
            
            
            PRM_Account_Contact_Profiles_Model.Profiles returnResponse =new PRM_Account_Contact_Profiles_Model.Profiles();
            if( error!=null && error!='' ){
               PRM_Account_Contact_Profiles_Model.Profiles errorResponse = PRM_Account_Contact_Profiles_Utility.generateError(error);
                returnResponse.ErrorMsg=errorResponse.ErrorMsg;
            }
            long tempResponsetime=0;
            for(PRM_Account_Contact_Profiles_Model.Profiles resp :responseList){
                System.debug('In for Loop'+resp);
                if(resp.ResponseTimeMS!=null){
                     tempResponsetime +=resp.ResponseTimeMS;
                }
                
               
                if(resp.RegistrationRequestProfile !=null){
                    returnResponse.RegistrationRequestProfile = resp.RegistrationRequestProfile;
                }
                if(resp.AccountRequest !=null){
                   returnResponse.AccountRequest = resp.AccountRequest;
                }
                if(resp.AccountProfile!=null){
                   returnResponse.AccountProfile = resp.AccountProfile;
                }
                if(resp.ContactAccount!=null){
                   returnResponse.ContactAccount = resp.ContactAccount;
                }
                if(resp.ContactBasicProfile!=null){
                   returnResponse.ContactBasicProfile = resp.ContactBasicProfile;
                }
                if(resp.OnePartnerIDGroupMembers!=null){
                   returnResponse.OnePartnerIDGroupMembers = resp.OnePartnerIDGroupMembers;
                }
                if(resp.AccountResults!=null){
                   returnResponse.AccountResults = resp.AccountResults;
                }
                if(resp.ExceptionDetails!=null){
                   returnResponse.ExceptionDetails = resp.ExceptionDetails;
                }
                /*else if(resp.ResponseTimeMS!=null){
                   //returnResponse.ResponseTimeMS = resp.ResponseTimeMS + returnResponse.ResponseTimeMS;
                }*/
                if(resp.SystemAccount!=null){
                   returnResponse.SystemAccount = resp.SystemAccount;
                }
                if(resp.ContactGroupResults!=null){
                    System.debug('in264');
                   returnResponse.ContactGroupResults = resp.ContactGroupResults;
                }
                if(resp.SearchResults!=null){
                    System.debug('in264');
                   returnResponse.SearchResults = resp.SearchResults;
                }
                
                
                
                    
            }
            returnResponse.ResponseTimeMS = tempResponsetime;
           
            return returnResponse;
            
           
            
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
        finally {
          /* PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
           Integer fieldLength=Schema.SObjectType.PRM_Integration_Log__c.fields.PRM_Response_Payload__c.getLength();
           logEntryUtility.addLogEntry(JSON.serialize(response),fieldLength);
           for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){ */
             PRM_IPA_Utility.createIntegrationLog(inputvalue,PRM_IPA_Constants.CALLOUT_TYPE_INBOUND ,PRM_IPA_Constants.MODULE_SELF_REGISTRATION,RestContext.request.requestBody.toString(),'GetProfile API Called',null,PRM_IPA_Constants.SYSTEM_NAME_AEM,'PRM_Account_Contact_Profiles', reqTime,System.now());   
         //  }       
        
            /*PRM_IPA_Utility.createIntegrationLog(inputvalue ,PRM_IPA_Constants.CALLOUT_TYPE_INBOUND ,PRM_IPA_Constants.MODULE_SELF_REGISTRATION ,RestContext.request.requestBody.toString() ,JSON.serialize(response) ,null , PRM_IPA_Constants.SYSTEM_NAME_AEM,'PRM_Account_Contact_Profiles');*/
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