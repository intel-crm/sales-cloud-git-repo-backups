/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Util 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/6/2017               Common utility methods for all the rest apis
*****************************************************************************************************************************************/
public class Core_RestAPI_Util {
    
    public static final String LOG_ERROR_SWITCH_ON = 'ON';
    public static final String DEFAULT_VALUE = 'Default';
    public static final RestRequest requestObj = RestContext.request;
    
    
    //For setting the exception code and error message by the exception type
   /* public static void processException(Exception exp, Core_RestAPI_Response response, String sObjectName, DateTime entryTime){
        try{
            if(response == null)
                response = new Core_RestAPI_Response();
            response.isSuccess = false;
            response.errorContent = new Core_RestAPI_ErrorContent();
            //if(LABEL.Core_RestAPI_Exception_Switch == LOG_ERROR_SWITCH_ON){
                Map<String , Core_RestAPI_Response_Codes__c> mType_ExceptionInfo = Core_RestAPI_Response_Codes__c.getAll();
                
                Core_RestAPI_Response_Codes__c objExpName = null;
                if(exp != null && mType_ExceptionInfo.containsKey(exp.getTypeName())){
                    
                    objExpName = mType_ExceptionInfo.get(exp.getTypeName());
                }else{
                    
                    objExpName = mType_ExceptionInfo.get(DEFAULT_VALUE);
                }
                response.Code= objExpName.Core_Http_Status_Code__c;
                response.errorContent.errorMessage = objExpName.Core_Message__c ;
                response.errorContent.traceId = Core_RestAPI_LoggingUtil.logError(entryTime, sObjectName, exp, response);
            //}
        }catch(Exception e){
            System.debug(LoggingLevel.Error, e.getMessage());
        }
    }
    
   //For setting the exception code and error message by the Https code
    public static void processException(String expCode, Core_RestAPI_Response response, String sObjectName, DateTime entryTime){
    
        try{ 
            if(response == null)
                response = new Core_RestAPI_Response();
            response.isSuccess = false;
            response.errorContent = new Core_RestAPI_ErrorContent();
            
           // if(LABEL.Core_RestAPI_Exception_Switch == LOG_ERROR_SWITCH_ON){
                Map<String , Core_RestAPI_Response_Codes__c> mType_ExceptionInfo = Core_RestAPI_Response_Codes__c.getAll();
                Map<String , Core_RestAPI_Response_Codes__c> mCode_ExceptionInfo = new Map<String , Core_RestAPI_Response_Codes__c>();
                
                for(Core_RestAPI_Response_Codes__c objResCode : mType_ExceptionInfo.values()){
                    mCode_ExceptionInfo.put(objResCode.Core_Http_Status_Code__c, objResCode);
                } 
                
                Core_RestAPI_Response_Codes__c objExpName = null;
                if(String.isNotBlank(expCode)  && mCode_ExceptionInfo.containsKey(expCode) ){
                    
                    objExpName = mCode_ExceptionInfo.get(expCode);        
                }else{
                    
                    objExpName = mType_ExceptionInfo.get(DEFAULT_VALUE);
                }
                response.Code= objExpName.Core_Http_Status_Code__c;
                response.errorContent.errorMessage = objExpName.Core_Message__c ;
                response.errorContent.traceId = Core_RestAPI_LoggingUtil.logError(entryTime, sObjectName, expCode, response);
            //}
        }catch(Exception e){
            System.debug(LoggingLevel.Error, e.getMessage());
        }
    }*/
    
    //Call This API for all POST/PUT/DELETE API's
    public static void processException(Exception exp, String expCode, Core_RestAPI_Response response, String sObjectName, DateTime entryTime, Core_RestAPI_Request request){
       
        String requestBody = Json.serialize(request);
        System.debug('  >>>>>> '+requestBody);
        try{
            Map<String , Core_RestAPI_Response_Codes__c> mType_ExceptionInfo = Core_RestAPI_Response_Codes__c.getAll();
            System.debug(' >>>> mType_ExceptionInfo'+mType_ExceptionInfo);
            
            Map<String , Core_RestAPI_Response_Codes__c> mCode_ExceptionInfo = new Map<String , Core_RestAPI_Response_Codes__c>();
            
            for(Core_RestAPI_Response_Codes__c objResCode : mType_ExceptionInfo.values()){
                mCode_ExceptionInfo.put(objResCode.Core_Code__c , objResCode);
            } 
           // System.debug(' >>>> mCode_ExceptionInfo '+mCode_ExceptionInfo +' >>>> expCode'+expCode+' >>>> exp'+exp);
            Core_RestAPI_Response_Codes__c objExpName = null;
            if(String.isNotBlank(expCode)  && mCode_ExceptionInfo.containsKey(expCode) ){
                objExpName = mCode_ExceptionInfo.get(expCode);        
            }else if(exp != null && mType_ExceptionInfo.containsKey(exp.getTypeName())){
                objExpName = mType_ExceptionInfo.get(exp.getTypeName());
            }else{
                objExpName = mType_ExceptionInfo.get(DEFAULT_VALUE);
            }
            
            if(response == null)
                response = new Core_RestAPI_Response();
            response.isSuccess = false;
            response.errorContent = new Core_RestAPI_ErrorContent();
            response.Code = objExpName.Core_Code__c ;
            response.errorContent.errorMessage = objExpName.Core_Message__c ;           
            response.errorContent.traceId = Core_RestAPI_LoggingUtil.logError(entryTime, sObjectName, expCode, exp, response,requestBody);
            //Set the Http status code
            RestContext.response.statusCode = Integer.valueOf(objExpName.Core_Http_Status_Code__c);
            
            
        }catch(Exception e){
            System.debug(LoggingLevel.Error, e.getMessage());
        }
    }
    
    //For setting the exception code and error message by the Https code and exception type
    //Call This Method for all GET Request API's
    public static void processException(Exception exp, String expCode, Core_RestAPI_Response response, String sObjectName, DateTime entryTime){
        try{

            Map<String , Core_RestAPI_Response_Codes__c> mType_ExceptionInfo = Core_RestAPI_Response_Codes__c.getAll();
            System.debug(' >>>> mType_ExceptionInfo'+mType_ExceptionInfo);
            
            Map<String , Core_RestAPI_Response_Codes__c> mCode_ExceptionInfo = new Map<String , Core_RestAPI_Response_Codes__c>();
            
            for(Core_RestAPI_Response_Codes__c objResCode : mType_ExceptionInfo.values()){
                mCode_ExceptionInfo.put(objResCode.Core_Code__c , objResCode);
            } 
             System.debug(' >>>> mCode_ExceptionInfo '+mCode_ExceptionInfo +' >>>> expCode'+expCode+' >>>> exp'+exp);
            Core_RestAPI_Response_Codes__c objExpName = null;
            if(String.isNotBlank(expCode)  && mCode_ExceptionInfo.containsKey(expCode) ){
                objExpName = mCode_ExceptionInfo.get(expCode);        
            }else if(exp != null && mType_ExceptionInfo.containsKey(exp.getTypeName())){
                objExpName = mType_ExceptionInfo.get(exp.getTypeName());
            }else{
                objExpName = mType_ExceptionInfo.get(DEFAULT_VALUE);
            }
            
            if(response == null)
                response = new Core_RestAPI_Response();
            response.isSuccess = false;
            response.errorContent = new Core_RestAPI_ErrorContent();
            
            response.Code = objExpName.Core_Code__c ;
            response.errorContent.errorMessage = objExpName.Core_Message__c ;           
            response.errorContent.traceId = Core_RestAPI_LoggingUtil.logError(entryTime, sObjectName, expCode, exp, response);
            
            //Set the Http status code
            RestContext.response.statusCode = Integer.valueOf(objExpName.Core_Http_Status_Code__c);
           
        }catch(Exception e){
            System.debug(LoggingLevel.Error, e.getMessage());
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
            System.debug(LoggingLevel.Error, e.getMessage());
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
            System.debug(LoggingLevel.Error, e.getMessage());
        }
        return input;
    }


    
   //Return the individual param from available URI parameters 
    public static String getRequestParam(String key){
        String paramValue = '';
        try{
            Map<String, String> params = RestContext.request.params;
            System.debug(' getRequestParam params '+params+' Key '+key);
            paramValue = params.get(key);
        }catch(Exception e){
            System.debug(LoggingLevel.Error, e.getMessage());
        }
        System.debug(' getRequestParam returning param value '+paramValue);
        return paramValue;
    }
    
    //Validate passed query parameters are allowed for the api
    public static Boolean isRequestParamValid(Map<String, String> allowedURIParams){
        Boolean isValid = true;
        Map<String, String> params = RestContext.request.params;
        System.debug('  isRequestParamValid  params '+params + ' \n allowedURIParams '+allowedURIParams);
        for(String paramKey :  params.keySet()){
            String passedParamValue = allowedURIParams.get(paramKey);
            String allowedParamValue = params.get(paramKey);
            System.debug('  isRequestParamValid  passedParamValue :'+passedParamValue+'  allowedParamValue:'+allowedParamValue);
            if(!allowedParamValue.equalsIgnoreCase(passedParamValue)){
                isValid = false;
                break;
            }
        }
        System.debug('  isRequestParamValid  isValid '+isValid);
        return isValid;
    }
    
    //throw the invalid uri custom exception  
    
    public static Boolean  isRequestURIValid(String expectedUri){
        Boolean isValidUri = true;
        String[] expected = expectedUri.split('/');
        String[] actual = RestContext.request.requestUri.split('/');
        System.debug(' Expected : '+expected+' Actual '+actual);
        if(expected.size() != actual.size() )
            isValidUri = false;
        return isValidUri;
    }
    
   
    public static Boolean isCaseNumberValid(String caseNumber){
        Boolean isCaseValid = true;
        if(String.isBlank(caseNumber) ||  !caseNumber.isNumeric()){
            isCaseValid = false;
        }
        System.debug(' Is Case valid ? '+isCaseValid);
        return isCaseValid;
    }

    public static Boolean isMaxLengthExceeded(String value, Integer maxLength){
        Boolean isMaxLengthExceeded = false;
        if(String.isNotBlank(value) && value.length() > maxLength){
            isMaxLengthExceeded = true;
        }
        System.debug(' Value '+value+' isMaxLengthExceeded: '+isMaxLengthExceeded);
        return isMaxLengthExceeded;
    }    
    
    public static Boolean isProductIdValid(String productId){
        Boolean isProductValid = false;
          if(productId.length() != 18 || (!productId.isAlphanumeric())){
            isProductValid = true;
        }
        System.debug(' productId'+productId+' isProductValid : '+isProductValid );
        return isProductValid;
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
}

//INFO : HTTP Status codes
//https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest_methods.htm
//http://blog.restcase.com/5-basic-rest-api-design-guidelines/