/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_LoggingUtil 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/6/2017               Logging Util for logging the transactions & error logs
*****************************************************************************************************************************************/
public class Core_RestAPI_LoggingUtil {
    
    public static final RestRequest requestObj = RestContext.request;
    
    public static final List<User> userInfoIds = [SELECT UserName,ContactId,AccountId,Id FROM User Where Id=: Userinfo.getUserId() LIMIT 1];
    private static Core_Log_Entry__c errorLog = new Core_Log_Entry__c();
    
    //Creating transaction record for every response of API
    public static String logTransaction(DateTime currTime, Core_RestAPI_Response response){
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
            System.debug(System.LoggingLevel.ERROR, Core_RestAPI_Util.getExceptionAsString(e));
            //TODO email notfication in future
        }
        return transLog.Id; 
    }
    
    //Get the final apiName
    public static String getAPIName(String API_URI){
        
        List<Core_RestAPI_Name__c> lstAPINames = [select name , Sub_URI__c , Search_URI__c, API_Order__c from Core_RestAPI_Name__c ORDER BY API_Order__c asc];
        system.debug('lstAPINames ===>> '+lstAPINames);
        String finalApiName ='';
        system.debug('API_URI ==>> '+API_URI);
      
        for(Core_RestAPI_Name__c cstng : lstAPINames){           
            if(API_URI.contains(cstng.Search_URI__c)){
                system.debug('inside if  str1.Search_URI__c ===>> '+cstng.Search_URI__c);
                if(cstng.Sub_URI__c != null && API_URI.contains(cstng.Sub_URI__c) ){
                    system.debug('inside second if str1.Exclude_URI__c ===>> '+cstng.Sub_URI__c);
                    finalApiName = cstng.name;
                    break;
                }else if(cstng.Sub_URI__c == null){
                    system.debug('else  block ');
                    finalApiName = cstng.name;
                    break;
                }
            }
        }    
        System.debug(' Final api name '+finalApiName);
        return finalApiName ;
    }
    
        //Creating transaction record for every response of API with API name as parameter
    public static String logTransaction(DateTime currTime, Core_RestAPI_Response response, String APIName){
        Core_RestAPI_Transaction_Entry__c transLog = new Core_RestAPI_Transaction_Entry__c();
        try{
            
            if(LABEL.Core_RestAPI_Transaction_Switch == 'ON'){
                if(requestObj != null){
                    transLog.Core_Account__c = userInfoIds[0].AccountId;
                    transLog.Core_Contact__c = userInfoIds[0].ContactId;
                    //  transLog.Core_API_Name__c= String.ValueOf(requestObj.requestURI).abbreviate(200);
                    transLog.Core_API_Name__c = APIName;
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
            System.debug(System.LoggingLevel.ERROR, Core_RestAPI_Util.getExceptionAsString(e));
            //TODO email notfication in future
        }
        return transLog.Id; 
    }
    //Not using the below two methods
    //for Logging Exception
    //Creating log entries record passing exception
    /* public static String logError(DateTime currTime, String apiName, Exception excp, Core_RestAPI_Response response){
Core_Log_Entry__c log = new Core_Log_Entry__c();
try{           
log.Core_Message__c = String.ValueOf(requestObj.requestURI).abbreviate(255);
log.Core_Origin__c = LABEL.Core_RestAPI_Log_Origin;
log.Core_When__c = currTime;
log.Core_Severity__c = LABEL.Core_RestAPI_Error_Severity;
log.Core_Project__c = LABEL.Core_RestAPI_Log_Origin;
log.Core_Tags__c=userInfoIds[0].ContactId+';'+response.Code;
log.Core_Details__c = Core_RestAPI_Util.getExceptionAsString(excp)+' ; Request : '+'requestObj.requestBody != null ? JSON.serialize(requestObj.requestBody.toString()) : '+' ;Response : '+JSON.serializePretty(response)+ '; Time :' + System.now();
insert log;
errorLog  = [Select Name FROM Core_Log_Entry__c where Id =:log.id];
}catch(Exception e){
System.debug(System.LoggingLevel.ERROR, Core_RestAPI_Util.getExceptionAsString(e));
}
return errorLog.Name;
}

// Creating log entries record passing exception code
public static String logError(DateTime currTime, String apiName, String expCode, Core_RestAPI_Response response){

Core_Log_Entry__c log = new Core_Log_Entry__c();
try{

log.Core_Message__c = String.ValueOf(requestObj.requestURI).abbreviate(255);
log.Core_Origin__c = LABEL.Core_RestAPI_Log_Origin;
log.Core_When__c = currTime;
log.Core_Severity__c = LABEL.Core_RestAPI_Error_Severity;
log.Core_Project__c = LABEL.Core_RestAPI_Log_Origin;
log.Core_Tags__c=userInfoIds[0].ContactId+';'+expCode;
log.Core_Details__c = expCode+' ; Request : '+( requestObj.requestBody != null ? JSON.serialize(requestObj) : '' )+' ;Response : '+( response != null ? JSON.serialize(response) : '')+ '; Time : ' +System.now();
insert log;
errorLog = [Select Name FROM Core_Log_Entry__c where Id =:log.id];

}catch(Exception e){
System.debug(System.LoggingLevel.ERROR, Core_RestAPI_Util.getExceptionAsString(e));
}
return errorLog.Name;
}*/
    
    //Creating log entries passing exception and code as the parameter
    public static String logError(DateTime currTime, String apiName, String expCode, Exception excp, Core_RestAPI_Response response){
        Core_Log_Entry__c log = new Core_Log_Entry__c();
        try{
            log.Core_Message__c = String.ValueOf(requestObj.requestURI).abbreviate(255);
            log.Core_Origin__c = LABEL.Core_RestAPI_Log_Origin;
            log.Core_When__c = currTime;
            system.debug('currTime==>> '+currTime);
            system.debug('log.Core_When__c==>> '+log.Core_When__c);
            log.Core_Severity__c = LABEL.Core_RestAPI_Error_Severity;
            log.Core_Project__c = LABEL.Core_RestAPI_Log_Origin;
            log.Core_Tags__c=userInfoIds[0].ContactId+';'+response.Code;
            log.Core_Details__c = String.ValueOf(getDetails(expCode, excp, response,null)).abbreviate(32768);
            insert log;
            errorLog = [Select Name FROM Core_Log_Entry__c where Id =:log.id];
        }catch(Exception e){
            System.debug(System.LoggingLevel.ERROR, Core_RestAPI_Util.getExceptionAsString(e));
        }
        return errorLog.Name; 
    }
    
    //Create log entries of error  for POST/PUT operations passing request in the parameters
    public static String logError(DateTime currTime, String apiName, String expCode, Exception excp, Core_RestAPI_Response response,String request){
        Core_Log_Entry__c log = new Core_Log_Entry__c();
        System.debug('Called LogError method'+request);
        try{
            log.Core_Message__c = String.ValueOf(requestObj.requestURI).abbreviate(255);
            log.Core_Origin__c = LABEL.Core_RestAPI_Log_Origin;
            log.Core_When__c = currTime;
            system.debug('currTime==>> '+currTime);
            system.debug('log.Core_When__c==>> '+log.Core_When__c);
            log.Core_Severity__c = LABEL.Core_RestAPI_Error_Severity;
            log.Core_Project__c = LABEL.Core_RestAPI_Log_Origin;
            log.Core_Tags__c=userInfoIds[0].ContactId+';'+response.Code;
            log.Core_Details__c = String.ValueOf(getDetails(expCode, excp, response,request)).abbreviate(32768);
            insert log;
            errorLog = [Select Name FROM Core_Log_Entry__c where Id =:log.id];
        }catch(Exception e){
            System.debug(System.LoggingLevel.ERROR, Core_RestAPI_Util.getExceptionAsString(e));
        }
        return errorLog.Name;
    }
    
    private static String getDetails(String expCode, Exception excp, Core_RestAPI_Response response,String requestBody){
        
        return '\n Api Code '+expCode +';'+ 
            '   \n Request : '+ requestBody+';'+
            '   \n Response : '+ ( response != null ? JSON.serializePretty(response) : '')+';'+
            '   \n Time : ' + System.now() +';'+
            '   \n Exception :[ '+ Core_RestAPI_Util.getExceptionAsString(excp)+']';
    }
    
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