@isTest
public class Core_IPS_BES_ExceptionHandler_Test {
    public static TestMethod void exceptionTesting(){
        List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
         outboundObject.add(new Core_IPS_BES_Outbound_Message__c(core_IPS_Outbound_Message_ID__c = '123'
                                                                 ));
         insert outboundObject;
        List<Core_IPS_BES_Outbound_Message__c> obList = [SELECT ID,Name from Core_IPS_BES_Outbound_Message__c];
        try{
        RestRequest req = new RestRequest(); 
        req.requestURI = '/services/apexrest/IPS_BES_ExceptionHandler/';
        req.httpMethod = 'POST';
        String JsonString = '{"error_response":{"message_id":"'+obList[0].Name+'","message_type":"Case","Error":"org.mule.api.MuleRuntimeException: org.mule.module.http.internal.request.ResponseValidatorException: Response code 400 mapped as failure."}}';
        req.requestBody =Blob.valueOf(jsonString);
        RestContext.request = req;
        Core_IPS_BES_ExceptionHandler.postError();
        }catch(Exception e){
        }
        List<Core_IPS_BES_Error_Log__c> errorLog = [Select id from Core_IPS_BES_Error_Log__c];
        System.assert(errorLog.size()>0);
        
    }
    
}