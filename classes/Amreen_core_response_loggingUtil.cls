//Read ON/OFF flags from custom settings or Labels
public class Amreen_core_response_loggingUtil {
    public static final RestRequest requestObj = RestContext.request;
    
    public static String log(DateTime currTime, String APIname){
        System.debug('currentTime-->'+currTime+'RestApiNAme===>'+APIname);
        Core_Log_Entry__c log = new Core_Log_Entry__c();
        try{
            System.debug('in the log method');
            System.debug('requestObj--->'+requestObj);
            String contactId = [SELECT ContactId FROM User Where Id=: Userinfo.getUserId()].ContactId;
            log.Core_Message__c = APIname;
            log.Core_Origin__c = LABEL.Core_App_Logging_Origin;
            log.Core_When__c = currTime;
            log.Core_Severity__c = LABEL.Core_App_Logging_Tracked_Severities;
            log.Core_Project__c = LABEL.Core_App_Logging_Origin;
            System.debug('contactId-->'+contactId);
            log.Core_Contact__c = contactId;
            log.Core_Tags__c = '200';
            insert log;
            System.debug('inserted log');
            //Logic & insert log object and return the id
            //TODO read the reqeust attributes from 'requestObj' and insert
        }catch(Exception e){
            
        }
        return log.Id;
    }
    
    //TODO Parse response and fetch the error Content  and log
    public static String log(Core_RestAPI_Response response){
        System.debug('response--->'+response);
        Core_Log_Entry__c log = new Core_Log_Entry__c();
        try{
            //Logic & insert log object and return the id
            //TODO Read the request and populate to log entry
            //TODO Readd the response and populate to log entry
            //TODO Insert
            //TODO set the traceid = log.Id
            //Tags add the status code
        }catch(Exception e){
            
        }
        //response.ErrorContent.referenceId = log.id
        //SET the referenceID
        return log.Id;
    }

}