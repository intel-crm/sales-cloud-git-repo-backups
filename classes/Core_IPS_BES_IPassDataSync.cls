/*********************************************
* Name : Core_IPS_BES_IPassDataSync 
* Author : Farooq 
* Date Created : 09/09/2021
* Description : This class is called from button Dynamic Sync whenever that button is clicked this class will generate a json of backend system and send to ipaass.
* Test Class : Core_IPS_BES_IPassDataSync_Test
*   
************************************************/
/* Start --- TWC745-422 --- 17-09-21--- JSON Implementation for new backend system*/
global with sharing class  Core_IPS_BES_IPassDataSync {
    
    public static Boolean show{get;set;}
    
    public Core_IPS_BES_IPassDataSync(ApexPages.StandardController controller) {
        Core_IPS_Backend_System2__c backendsystem;
        if(Core_IPS_Backend_System2__c.SObjectType.getDescribe().isQueryable()){
         backendsystem = [Select ID, Name, isDataSync__c From Core_IPS_Backend_System2__c where Id =: ApexPages.currentPage().getParameters().get('id') LIMIT 1];
        }
        if(backendsystem.isDataSync__c == true){
            show = true;
        }
        else{
            show = false;
        }
        
        
    }
     /* This method will be called from clasic when JS Button is clicked. 
* Author : Popcornapps
**/
    webservice Static void syncRecords(Id recordId){
        
        prepareJSONData(recordId); 
        
    }
    public static string jsonData;
    
    /* This method will be called from Lightning when Button is clicked. 
* Author : Popcornapps
**/
    @auraEnabled
    public static string dynamicSyncFromLightning(Id recordId){
    Core_IPS_Backend_System2__c backendsystem;
    if(Core_IPS_Backend_System2__c.SObjectType.getDescribe().isAccessible()){
       backendsystem = [Select Name,isDataSync__c from  Core_IPS_Backend_System2__c where id=: recordId ];
    }
        if(backendsystem.isDataSync__c){
           prepareJSONData(recordId);
    return 'yes';
        }
         return 'no';
    }
    
    
/*************************************************
* Description : Method to Generate JSON
* Author : Sai Krishna Emani
**************************************************/
    public static void prepareJSONData(ID recordId){
        list<Core_IPS_Backend_System2__c> backendsystem = new list<Core_IPS_Backend_System2__c>();
        list<Core_IPS_Backend_Field_Map__c> fieldvalumaplist = new list<Core_IPS_Backend_Field_Map__c>();
        if(Core_IPS_Backend_System2__c.SObjectType.getDescribe().isQueryable()){
             backendsystem = [Select Name,Core_IPS_Deactivated__c,Core_IPS_Backend_System_URL__c,Core_Support_Email__c,Core_IPS_Target_System__c from  Core_IPS_Backend_System2__c where id=: recordId LIMIT 1];}
        if(Core_IPS_Backend_Field_Map__c.SObjectType.getDescribe().isQueryable()){
            fieldvalumaplist = [Select Core_IPS_Direction__c,Core_IPS_Deassociate__c,Core_IPS_UnMapped__c,Core_IPS_Default_Value__c,Support_Update__c,Core_IPS_Deactivated__c, Core_Object_Name__c, Core_IPS_Order__c, Core_IPS_Source_Field__c, Core_IPS_Target_Field__c, (Select  Core_IPS_Source_Value__c, Core_IPS_Target_Value__c,Core_IPS_Deactivated__c,Backend_Field_Mapping_HSD__c from Backend_Value_Mappings_HSD__r) from Core_IPS_Backend_Field_Map__c where Core_IPS_New_Backend_System__r.Id =:recordId ];
            
        }
        
            JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartObject();
            if(!backendsystem.isEmpty()){
                jsonGen.writeStringField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Backend_System_Name__c,backendsystem[0].Name);
                jsonGen.writeBooleanField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Status__c,backendsystem[0].Core_IPS_Deactivated__c);            
                if(backendsystem[0].Core_IPS_Target_System__c != null){
                    jsonGen.writeStringField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Target_System__c,backendsystem[0].Core_IPS_Target_System__c);}
                else{
                    jsonGen.writeNullField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Target_System__c);
                }
                if(backendsystem[0].Core_Support_Email__c!=null){
                    jsonGen.writeStringField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Support_Email__c,backendsystem[0].Core_Support_Email__c);
                }
                else{
                   jsonGen.writeNullField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Support_Email__c);     
                } 
            }
       if(!fieldvalumaplist.isEmpty()){ 
            jsonGen.writeFieldName('Field_Mapping');
            jsonGen.writeStartArray();
            for(Core_IPS_Backend_Field_Map__c c: fieldvalumaplist){
                jsonGen.writeStartObject();  
                if(c.Core_IPS_Source_Field__c != null){
                    
                    jsonGen.writeStringField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Source_Field__c,c.Core_IPS_Source_Field__c);}
                else{
                    jsonGen.writeNullField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Source_Field__c);
                }
                if(c.Core_IPS_Target_Field__c != null){
                    jsonGen.writeStringField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Target_Field__c,c.Core_IPS_Target_Field__c);}
                else{
                    jsonGen.writeNullField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Target_Field__c);
                }
                if(c.Core_IPS_Direction__c != null){
                    jsonGen.writeStringField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Direction__c,c.Core_IPS_Direction__c);}
                else{
                    jsonGen.writeNullField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Direction__c);
                }
                if(c.Core_IPS_Deassociate__c == null){
                    jsonGen.writeBooleanField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Deassociate__c,false);
                    
                }
                else{
                    jsonGen.writeBooleanField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Deassociate__c,c.Core_IPS_Deassociate__c);
                   
                } 
                if(c.Core_IPS_UnMapped__c == null){
                    jsonGen.writeBooleanField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').UnMapped__c,false);}
                else{
                    jsonGen.writeBooleanField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').UnMapped__c,c.Core_IPS_UnMapped__c);
                }
                if(c.Support_Update__c == null){
                    jsonGen.writeBooleanField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Support_Update__c,false);}
                else{
                   jsonGen.writeBooleanField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Support_Update__c,c.Support_Update__c);
                }
                if(c.Core_IPS_Deactivated__c == null){
                    jsonGen.writeBooleanField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Deactivated__c,false); }
                else{
                    jsonGen.writeBooleanField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Deactivated__c,c.Core_IPS_Deactivated__c); 
                }
                if(c.Core_IPS_Default_Value__c != null){
                    jsonGen.writeStringField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Default_Value__c,c.Core_IPS_Default_Value__c);
                }
                else{
                    jsonGen.writeNullField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Default_Value__c);
                }
                if(c.Core_IPS_Order__c != null){
                    jsonGen.writeNumberField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Order__c,c.Core_IPS_Order__c);}
                else{
                    jsonGen.writeNullField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Order__c);
                }
                if(c.Backend_Value_Mappings_HSD__r != null){
                    jsonGen.writeFieldName('Value_Mapping');
                    jsonGen.writeStartArray();
                    for(Core_IPS_Backend_Value_Map__c valueObj :c.Backend_Value_Mappings_HSD__r){
                       jsonGen.writeStartObject(); 
                       jsonGen.writeStringField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Source_Value__c,valueObj.Core_IPS_Source_Value__c);
                       jsonGen.writeStringField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Target_Value__c,valueObj.Core_IPS_Target_Value__c);
                       jsonGen.writeBooleanField(Core_IPS_Backend_System_Custom_Settings__c.getInstance('Core_IPS_New_Backend_System').Deactivated__c,valueObj.Core_IPS_Deactivated__c); 
                       jsonGen.writeEndObject(); 
                    }
                    jsonGen.writeEndArray();
                }
                else{
                    jsonGen.writeNullField('c.Backend_Value_Mappings_HSD__r');
                }
                jsongen.writeEndObject();
            }
            jsonGen.writeEndArray();
            jsonGen.writeEndObject();
            jsonData = jsonGen.getAsString();
           // System.debug('jsonData='+jsonData);
            MessageWrapper messageobj = sendJsonData(jsonData);
            DateTime dt = Datetime.now();
            String dtIST = dt.format('dd-MM-yyyy HH:mm:ss', 'IST');
            //System.debug(messageobj.status);
            Core_IPS_Backend_System2__c backendsys;
           if(Core_IPS_Backend_System2__c.SObjectType.getDescribe().isQueryable()){
               backendsys = [Select ID, Name,Core_IPS_Status__c,Last_Sync__c, isDataSync__c From Core_IPS_Backend_System2__c where Id =:recordId];
           }
               if(messageobj.status == 'Success'){
                   if(Schema.sObjectType.Core_IPS_Backend_System2__c.fields.isDataSync__c.isUpdateable()){
                       backendsys.isDataSync__c = false;
                   }
               if(Schema.sObjectType.Core_IPS_Backend_System2__c.fields.Core_IPS_Status__c.isUpdateable()){
                 backendsys.Core_IPS_Status__c = 'Success At IPASS' ;
               }
               if(Schema.sObjectType.Core_IPS_Backend_System2__c.fields.Last_Sync__c.isUpdateable()){    
                   backendsys.Last_Sync__c = dtIST;
               }
                   update backendsys;
           }
           else if (messageobj.status == 'Failed'){
              if(Schema.sObjectType.Core_IPS_Backend_System2__c.fields.isDataSync__c.isUpdateable()){
                    
               backendsys.isDataSync__c = true;
              }
              if(Schema.sObjectType.Core_IPS_Backend_System2__c.fields.Core_IPS_Status__c.isUpdateable()){
                
                  backendsys.Core_IPS_Status__c = System.Label.Core_IPS_BES_Fail_Message +'  '+dtIST +'  ' +messageobj.message;
              }
              
             update backendsys;
           } 
            
        }
        
    }
    /* End --- TWC745-422 --- 27-09-21--- JSON Implementation for new backend system*/   
    /*
* Description : Helper method to update at IPASS when records  are created or updated with relevant changes.
*               We are Making a call to Apigee for token generation.
*               And after Token availability , making one request to APIGEE to post IPASS with JSON we have. 
* Author : Sai Krishna
**/
    /* Start --- TWC745-626 --- 19-10-21 --- JSON Implementation for new backend system */
    public static MessageWrapper sendJsonData(String jsonBody){
        MessageWrapper messageWrapperObj = new MessageWrapper();
        try {
            //String token = ''; //TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change
            //String ipsBackendSystemName = Core_IPS_System_Credentails_Apigee__c.getInstance('Core_IPS_Backend_System_Integration').Name;
            //String ipsBackendSystemEndPoint = Core_IPS_System_Credentails_Apigee__c.getInstance('Core_IPS_Backend_System_Integration').Core_IPS_EndPointURL__c;
            //token = Core_IPS_APIGEE_Utility.generateAccessToken1(ipsBackendSystemName);
            //if(String.isNotBlank(token)){
                String ipsBackendSystemEndPoint = 'callout:Core_IPS_Backend_System_Integration_DynamicSync'; //TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change
                Http callout = new Http();
                HttpRequest postRequest = new HttpRequest();
                postRequest.setMethod('POST');
                postRequest.setEndpoint(ipsBackendSystemEndPoint);
                postRequest.setHeader('content-type', 'application/json'); 
                System.debug('Hk 220 --> '+jsonBody);              
                //postRequest.setHeader(Label.Core_Apigee_Auth, 'Bearer ' + token);
                postRequest.setBody(jsonBody);
                postRequest.setTimeout(12000);
                System.debug('Hk 223 --> '+postRequest);
                System.debug('Hk 224 --> '+jsonBody);
                System.debug(LoggingLevel.FINEST, ' postRequest BUG ASSIST check : '+postRequest);
                HttpResponse response = callout.send(postRequest); 
                if(response.getStatusCode() == 200){
                    messageWrapperObj.body = response.getBody();
                    messageWrapperObj.errorCode = response.getStatusCode();
                    messageWrapperObj.status = 'Success';
                    Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'info','Dynamic Mapping Json',jsonBody,null,'Backend_System',null);
                   
                } else {
                    messageWrapperObj.body = response.getBody();
                    messageWrapperObj.errorCode = response.getStatusCode();
                    messageWrapperObj.status = 'Failed';
                    String msg=response.getBody();
                    if(response.getBody()?.length()>255){
                        msg = response.getBody()?.subString(0,255);
                    }
                     messageWrapperObj.message = msg;
                   String strDetails= msg;
                   //Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'baddata','Token Generation Failed',strDetails,null,'Backend_System','Cannot make call to Ipass');
                   Core_IPS_BES_LogEntry_Utility.insertLog(messageWrapperObj.errorCode, msg, 'Token Generation Failed');
                }
            //}  else if(String.isBlank(token)) {
                //messageWrapperObj.status = 'Failed';
                //String strDetails= 'Token is empty.';
                //messageWrapperObj.message = strDetails;
                //Core_IPS_BES_LogEntry_Utility.insertLog(messageWrapperObj.errorCode, strDetails, 'Token Generation Failed');
                ////Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'baddata','Token Generation Failed',strDetails,null,'Backend_System','Cannot make call to Ipass');
                
            //} //TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change
            //System.debug('jsonBody'+jsonBody);
           

        } catch(Exception e) { 
            messageWrapperObj.status = 'Failed';
            String strDetails= 'Exception occured in sending data of New backend system ';
            messageWrapperObj.message = strDetails;
            //Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','APIGEE Integration issue',strDetails,null,'Backend_System',null);
            Core_IPS_BES_LogEntry_Utility.insertLog(400, strDetails, 'APIGEE Integration issue');
        }
        
        return messageWrapperObj;
    }
    public class MessageWrapper{
        public String body;
        public Integer errorCode;
        public String status;
        public String message;
        
    }
   
    
    
   /* Start --- TWC745-626 --- 21-10-21 --- JSON Implementation for new backend system */ 
}