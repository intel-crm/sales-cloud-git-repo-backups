/****************************************************************************************************************************************
* Class Name  : Core_SalesCRM_RestAPI_Util 
* Version     : 1.0 
* Created Date: 29/08/2023
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Biswa				      29/08/2023             To create structure of all the responses
*****************************************************************************************************************************************/
public without sharing class Core_SalesCRM_RestAPI_Util {
    public static final String LOG_ERROR_SWITCH_ON = 'ON';
    public static final String DEFAULT_VALUE = 'Default';
    public static final RestRequest requestObj = RestContext.request;
    public static Core_RestAPI_OpportunitiesUtility.OpportunityErrorMsg oppErrMsgs {set; get;}
    public static final List<User> userInfoIds = [SELECT UserName,ContactId,AccountId,Id FROM User Where Id=: Userinfo.getUserId() LIMIT 1];
    private static Core_Log_Entry__c errorLog = new Core_Log_Entry__c();
    
    //Call This API for all POST/PUT/DELETE API's
    public static void processException(Exception exp, String expCode, Core_SalesCRM_RestAPI_Response response, String sObjectName, DateTime entryTime, Core_RestAPI_Request request){
        
        String requestBody = Json.serialize(request);
        
        try{
            Map<String , Core_RestAPI_Response_Codes__c> mType_ExceptionInfo = Core_RestAPI_Response_Codes__c.getAll();
           
            
            Map<String , Core_RestAPI_Response_Codes__c> mCode_ExceptionInfo = new Map<String , Core_RestAPI_Response_Codes__c>();
            
            for(Core_RestAPI_Response_Codes__c objResCode : mType_ExceptionInfo.values()){
                mCode_ExceptionInfo.put(objResCode.Core_Code__c , objResCode);
            } 
            
            Core_RestAPI_Response_Codes__c objExpName = null;
            if(String.isNotBlank(expCode)  && mCode_ExceptionInfo.containsKey(expCode) ){
                objExpName = mCode_ExceptionInfo.get(expCode);        
            }else if(exp != null && mType_ExceptionInfo.containsKey(exp.getTypeName())){
                objExpName = mType_ExceptionInfo.get(exp.getTypeName());
            }else{
                objExpName = mType_ExceptionInfo.get(DEFAULT_VALUE);
            }
            
            if(response == null){
                response = new Core_SalesCRM_RestAPI_Response();
            }
            //response.successContent = null;
            response.isSuccess = false;
            response.errorContent = new Core_SalesCRM_RestAPI_ErrorContent();
            response.Code = objExpName.Core_Code__c ;
            response.errorContent.errorMessage = objExpName.Core_Message__c ;           
            response.errorContent.traceId = logError(entryTime, sObjectName, expCode, exp, response,requestBody);
            //Set the Http status code
            RestContext.response.statusCode = Integer.valueOf(objExpName.Core_Http_Status_Code__c);
            
            
        }catch(Exception e){
           PMP_Utility.logError(e, 'Core_SalesCRM_RestAPI_Util.processException');
        }
    }
    
    //For setting the exception code and error message by the Https code and exception type
    //Call This Method for all GET Request API's
    public static void processException(Exception exp, String expCode, Core_SalesCRM_RestAPI_Response response, String sObjectName, DateTime entryTime){
        try{
            
            Map<String , Core_RestAPI_Response_Codes__c> mType_ExceptionInfo = Core_RestAPI_Response_Codes__c.getAll();
            
            
            Map<String , Core_RestAPI_Response_Codes__c> mCode_ExceptionInfo = new Map<String , Core_RestAPI_Response_Codes__c>();
            
            for(Core_RestAPI_Response_Codes__c objResCode : mType_ExceptionInfo.values()){
                mCode_ExceptionInfo.put(objResCode.Core_Code__c , objResCode);
            } 
            
            Core_RestAPI_Response_Codes__c objExpName = null;
            if(String.isNotBlank(expCode)  && mCode_ExceptionInfo.containsKey(expCode) ){
                objExpName = mCode_ExceptionInfo.get(expCode);        
            }else if(exp != null && mType_ExceptionInfo.containsKey(exp.getTypeName())){
                objExpName = mType_ExceptionInfo.get(exp.getTypeName());
            }else{
                objExpName = mType_ExceptionInfo.get(DEFAULT_VALUE);
            }
            
            if(response == null)
            {
                response = new Core_SalesCRM_RestAPI_Response();
            }
            //response.successContent = null;
            response.isSuccess = false;
            response.errorContent = new Core_SalesCRM_RestAPI_ErrorContent();
            
            response.Code = objExpName.Core_Code__c ;
            response.errorContent.errorMessage = objExpName.Core_Message__c ;
            response.errorContent.opportunityValidationErrors = oppErrMsgs ;
            response.errorContent.traceId = logError(entryTime, sObjectName, expCode, exp, response);            
            
            //Set the Http status code
            
            RestContext.response.statusCode = Integer.valueOf(objExpName.Core_Http_Status_Code__c);
        }catch(Exception e){
           PMP_Utility.logError(e, 'Core_SalesCRM_RestAPI_Util.processException');
        }
    }
    
    
    //NOTE : Future enhancement for conditions
    public static String getCondition(String sObjectFieldName,String value){
        String condition =sObjectFieldName+' = '+value;
        return condition;
    }
    
    // uri = '/v1.0/cases/12341234';getParamFromURI getConditionFromURI
    public static String getConditionWithURIParam(String sObjectFieldName, Integer requestURIIndex){
        String condition = '';
        try{
            String uri = RestContext.request.requestURI;
            List<String> params = uri.split('/');
            
            condition = sObjectFieldName+' = \''+params[requestURIIndex]+'\'';    
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_SalesCRM_RestAPI_Util.getConditionWithURIParam');
        }
        return condition;
    }
    
    // uri = '/v1.0/cases/12341234';getParamFromURI getConditionFromURI
    public static String getInputFromURIParam(Integer requestURIIndex){
        String input = '';
        try{
            String uri = RestContext.request.requestURI;
            List<String> params = uri.split('/');
            input = params[requestURIIndex];    
        }catch(Exception e){
           PMP_Utility.logError(e, 'Core_SalesCRM_RestAPI_Util.getInputFromURIParam');
        }
        return input;
    }
    
    
    
    //Return the individual param from available URI parameters 
    public static String getRequestParam(String key){
        String paramValue = '';
        try{
            Map<String, String> params = RestContext.request.params;
           
            paramValue = params.get(key);
        }catch(Exception e){
           PMP_Utility.logError(e, 'Core_SalesCRM_RestAPI_Util.getRequestParam');
        }
        
        return paramValue;
    }
    
    //Validate passed query parameters are allowed for the api
    public static Boolean isRequestParamValid(Map<String, String> allowedURIParams){
        Boolean isValid = true;
        Map<String, String> params = RestContext.request.params;
        
        for(String paramKey :  params.keySet()){
            String passedParamValue = allowedURIParams.get(paramKey);
            String allowedParamValue = params.get(paramKey);
            
            if(!allowedParamValue.equalsIgnoreCase(passedParamValue)){
                isValid = false;
                break;
            }
        }
        
        return isValid;
    }
    
    //throw the invalid uri custom exception  
    
    public static Boolean  isRequestURIValid(String expectedUri){
        Boolean isValidUri = true;
        String[] expected = expectedUri.split('/');
        String[] actual = RestContext.request.requestUri.split('/');
        
        if(expected.size() != actual.size() )
            isValidUri = false;
        return isValidUri;
    }
    
    public static Boolean isMaxLengthExceeded(String value, Integer maxLength){
        Boolean isMaxLengthExceeded = false;
        if(String.isNotBlank(value) && value.length() > maxLength){
            isMaxLengthExceeded = true;
        }
        
        return isMaxLengthExceeded;
    }    
    
    //Get the Exception as String sdfg
    public static String getExceptionAsString(Exception ex){
        String strDetailsAndEx = 'Message: ' ;
        if(ex != null){
            strDetailsAndEx =+ ex.getMessage() + '\n';
            strDetailsAndEx += 'Cause: ' + ex.getCause() + '\n';
            strDetailsAndEx += 'Line Number: ' + ex.getLineNumber() + '\n';
            strDetailsAndEx += 'Stack Trace: ' + ex.getStackTraceString() + '\n';
            strDetailsAndEx += 'Type Name: ' + ex.getTypeName() + '\n';
        }
        return strDetailsAndEx;
    }
   	
    //Creating transaction record for every response of API
    public static String logTransaction(DateTime currTime, Core_SalesCRM_RestAPI_Response response){
        Core_RestAPI_Transaction_Entry__c transLog = new Core_RestAPI_Transaction_Entry__c();
        try{
            
            if(LABEL.Core_RestAPI_Transaction_Switch == 'ON'){
                if(requestObj != null){
                    transLog.Core_Account__c = userInfoIds[0].AccountId;
                    transLog.Core_Contact__c = userInfoIds[0].ContactId;
                    transLog.Core_API_Name__c = getAPIName(requestObj.requestURI);
                    transLog.Core_API__c= String.ValueOf(requestObj.requestURI).abbreviate(200);
                    transLog.Core_API_Version__c= String.ValueOf(Core_RestAPI_Util.getInputFromURIParam(1)).abbreviate(200);
                    transLog.Core_http_Method__c=requestObj.httpMethod;
                    transLog.Core_Details__c = JSON.serialize(requestObj).abbreviate(32768);
                    transLog.Core_Error_Id__c= errorLog.Id;
                    transLog.Core_Remote_address__c= String.ValueOf(requestObj.remoteAddress).abbreviate(255);
                    transLog.Core_Request_Body__c =JSON.serialize(requestObj.requestBody).abbreviate(255);
                    transLog.Core_Host__c = String.valueOf(requestObj.headers.get('Host')).abbreviate(255);
                    transLog.Core_Exit_Time__c = System.now();
                    transLog.Core_User__c= userInfoIds[0].Id;
                    transLog.Core_User_Agent__c = requestObj.headers.get('User-Agent');
                    transLog.Core_Status_Code__c = response.code;
                    transLog.Core_Params__c = JSON.serialize(requestObj.params);
                    transLog.Core_Origin__c = LABEL.Core_RestAPI_Log_Origin;
                    transLog.Core_Entry_Time__c= currTime;
                    transLog.Core_Duration__c = System.now().getTime() - currTime.getTime();
                    //Based on response set the transaction record severity 
                    if(response.isSuccess == true){
                        response.errorContent= null;
                        transLog.Core_Severity__c = LABEL.Core_RestAPI_Info_Severity;
                    }else{
                        transLog.Core_Severity__c = LABEL.Core_RestAPI_Error_Severity;
                    }
                    insert transLog;
                    
                }
            }
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_SalesCRM_RestAPI_Util.logTransaction');
            //TODO email notfication in future
        }
        return transLog.Id; 
    }
    
    //Get the final apiName
    public static String getAPIName(String API_URI){
        
        List<Core_RestAPI_Name__c> lstAPINames = [select name , Sub_URI__c , Search_URI__c, API_Order__c from Core_RestAPI_Name__c ORDER BY API_Order__c asc];
       
        String finalApiName ='';
        
      
        for(Core_RestAPI_Name__c cstng : lstAPINames){           
            if(API_URI.contains(cstng.Search_URI__c)){
                
                if(cstng.Sub_URI__c != null && API_URI.contains(cstng.Sub_URI__c) ){
                   
                    finalApiName = cstng.name;
                    break;
                }else if(cstng.Sub_URI__c == null){
                    
                    finalApiName = cstng.name;
                    break;
                }
            }
        }    
        
        return finalApiName ;
    }
    
    //Creating log entries passing exception and code as the parameter
    public static String logError(DateTime currTime, String apiName, String expCode, Exception excp, Core_SalesCRM_RestAPI_Response response){
        Core_Log_Entry__c log = new Core_Log_Entry__c();
        try{
            log.Core_Message__c = String.ValueOf(requestObj.requestURI).abbreviate(255);
            log.Core_Origin__c = LABEL.Core_RestAPI_Log_Origin;
            log.Core_When__c = currTime;
            
            log.Core_Severity__c = LABEL.Core_RestAPI_Error_Severity;
            log.Core_Project__c = LABEL.Core_RestAPI_Log_Origin;
            log.Core_Tags__c=userInfoIds[0].ContactId+';'+response.Code;
            log.Core_Details__c = String.ValueOf(getDetails(expCode, excp, response,null)).abbreviate(32768);
            insert log;
            errorLog = [Select Name FROM Core_Log_Entry__c where Id =:log.id];
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_SalesCRM_RestAPI_Util.logError');
        }
        return errorLog.Name; 
    }
    
    //Create log entries of error  for POST/PUT operations passing request in the parameters
    public static String logError(DateTime currTime, String apiName, String expCode, Exception excp, Core_SalesCRM_RestAPI_Response response,String request){
        Core_Log_Entry__c log = new Core_Log_Entry__c();
       
        try{
            log.Core_Message__c = String.ValueOf(requestObj.requestURI).abbreviate(255);
            log.Core_Origin__c = LABEL.Core_RestAPI_Log_Origin;
            log.Core_When__c = currTime;
            
            log.Core_Severity__c = LABEL.Core_RestAPI_Error_Severity;
            log.Core_Project__c = LABEL.Core_RestAPI_Log_Origin;
            log.Core_Tags__c=userInfoIds[0].ContactId+';'+response.Code;
            log.Core_Details__c = String.ValueOf(getDetails(expCode, excp, response,request)).abbreviate(32768);
            insert log;
            errorLog = [Select Name FROM Core_Log_Entry__c where Id =:log.id];
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_SalesCRM_RestAPI_Util.logError');
        }
        return errorLog.Name;
    }
    
    private static String getDetails(String expCode, Exception excp, Core_SalesCRM_RestAPI_Response response,String requestBody){
        
        return '\n Api Code '+expCode +';'+ 
            '   \n Request : '+ requestBody+';'+
            '   \n Response : '+ ( response != null ? JSON.serializePretty(response) : '')+';'+
            '   \n Time : ' + System.now() +';'+
            '   \n Exception :[ '+ Core_RestAPI_Util.getExceptionAsString(excp)+']';
    }
    
    /*
    200 OK
    201 CREATED
    202 ACCEPTED
    204 NO_CONTENT
    206 PARTIAL_CONTENT
    300 MULTIPLE_CHOICES
    301 MOVED_PERMANENTLY
    302 FOUND
    304 NOT_MODIFIED
    400 BAD_REQUEST
    401 UNAUTHORIZED
    403 FORBIDDEN
    404 NOT_FOUND
    405 METHOD_NOT_ALLOWED
    406 NOT_ACCEPTABLE
    409 CONFLICT
    410 GONE
    412 PRECONDITION_FAILED
    413 REQUEST_ENTITY_TOO_LARGE
    414 REQUEST_URI_TOO_LARGE
    415 UNSUPPORTED_MEDIA_TYPE
    417 EXPECTATION_FAILED
    500 INTERNAL_SERVER_ERROR
    503 SERVER_UNAVAILABLE
    */
}