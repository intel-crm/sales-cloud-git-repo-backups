public with sharing class PRM_ServiceNowUtility {
    
    public static Final String ORIGIN  = 'PRM_ServiceNowUtility';
    public static Final String SEVERITY  = 'Info';
    public static Final String PROJECT  = 'IPA';   
    public static final String LOG_ENTRY_SCOPE    = 'PRM_ServiceNowUtility';       
    public static final String LOG_ENTRY_SEVERITY = 'Error';   

    public static void createServiceNowCase(List<ServiceNow_Case__c> serviceNowCases)
    {
      String jsonbody = constructJSON(serviceNowCases);
      list<Id> snIds = new list<Id>();
      for(ServiceNow_Case__c snCase:serviceNowCases){
        snIds.add(snCase.id);
      }
      PRM_ServiceNowUtility.ITSMCallout(jsonbody,snIDs);
    }
    @future(callout=true)
    public static void ITSMCallout(String requestBody,list<Id> serviceNowIds){
      //system.debug('future method called'+requestBody+''+serviceNowIds);
      try{  
          PRM_Integration__mdt apiDetails; 
          Id recordId = serviceNowIds[0];
          apiDetails = [Select Id, API_Key__c,scope__c, EndPointURL__c, Password__c, Username__c from PRM_Integration__mdt where MasterLabel='ServiceNow' limit 1];  
          if(apiDetails!=null){
          PRM_Token_Model SNtoken = getToken(apiDetails);
          string token = SNtoken.access_token;
          Http http = new Http();
          HttpRequest req = new HttpRequest();
          HttpResponse response = new HttpResponse();
          req.setHeader(PRM_IPA_Constants.Authorization, PRM_IPA_Constants.Bearer +token);
          req.setHeader('Content-Type','application/json');
          req.setEndpoint(apiDetails.EndPointURL__c);
          req.setMethod('POST');
          req.setBody(requestBody);
            
          response = http.send(req);
          Map<String, Object> reqMap =   (Map<String, Object>) JSON.deserializeUntyped(response.getbody());
          //system.debug('cas'+reqMap);
          Map<String,Object> inc =( Map<String,Object> ) reqMap.get('result');
          String incNumber = (String) inc.get('number');
          String sys_id = (String) inc.get('sys_id');

          //callout to the Attachment API
          list<ContentDocumentLink> docLink = [select id from ContentDocumentLink where linkedEntityId =: recordId];
          if(response.getStatusCode() == 201 && docLink.size()>0 ){
            PRM_ServiceNowUtility.createAttachment(sys_id,serviceNowIds,token);
          }
          
          PRM_ServiceNowUtility.updateSNRecords(incNumber,serviceNowIds);
          //System.debug('@@@number'+incNumber);
          //system.debug('http Resp status::'+response.getStatusCode());
          //system.debug('http Resp body::'+response.getBody()); 
          }

    }
      catch(Exception e){
        Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage().abbreviate(254), Core_Origin__c = 'Incident Creation-IssueBox', Core_Severity__c = 'Medium', Core_When__c = System.Now(), Core_Project__c = 'IPA', Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
        insert ExcepLog;
      } 
    }


public static void updateSNRecords(String incNum,list<id> snIDs){
        ServiceNow_Case__c snCase= [select id,Incident_Number__c from ServiceNow_Case__c where ID=:snIds[0]];
        snCase.Incident_Number__c = incNum;
        update snCase;
}   

public static void createAttachment(String sysId,list<Id> snIds,String token){
        Id recordId = snIds[0];
        integer i=0;
        set<Id> docIds = new set<id>();
        List<ContentDocumentLink> docLink = [select id,ContentDocumentId from contentDocumentLink where linkedEntityId =:recordId];
         for(ContentDocumentLink conDoc : docLink){
          docIds.add(conDoc.ContentDocumentId);
         }
        List<ContentVersion> conVer = [SELECT Id,VersionData,title,fileType from ContentVersion Where ContentDocumentId in :docIds];
        for(ContentVersion ver: conVer){
        if(i<6){
        PRM_Content_Type_Mapping__mdt mapContentType = PRM_Content_Type_Mapping__mdt.getInstance(ver.fileType);
        String conType = mapContentType!=null ? mapContentType.Content_Type__c : null;
        String fileName = ver.title.replaceAll('\\s+', '');
        String encodedStringfileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
        String endPoint = System.Label.Attachment_API+'table_sys_id='+sysId+'&file_name='+ encodedStringfileName;
        //system.debug(endPoint);
        HttpRequest httpReq = new  HttpRequest();
        httpReq.setEndpoint(endPoint);
        httpReq.setMethod( 'POST' );
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('Content-Type', conType);
        httpReq.setHeader(PRM_IPA_Constants.Authorization, PRM_IPA_Constants.Bearer +token);
        httpReq.setBodyAsBlob(ver.VersionData);
        Http http = new Http();
        HTTPResponse reslt1 = http.send(httpReq);
        i++;
        //system.debug('http Resp status::'+reslt1.getStatusCode());
        //system.debug('http Resp body::'+reslt1.getBody()); 
        }
        }
}

public static PRM_Token_Model getToken(PRM_Integration__mdt agsAPIDetails) {
        PRM_Token_Model token = new PRM_Token_Model();
        try {
            HttpRequest httpReq = new  HttpRequest();
            httpReq.setEndpoint(agsAPIDetails.API_Key__c);
            httpReq.setMethod( 'POST' );
            httpReq.setHeader('content-type', 'application/x-www-form-urlencoded');            
            //string gType = EncodingUtil.urlEncode('client_credentials','UTF-8');
            String payLoad = 'grant_type=client_credentials&client_id=' + EncodingUtil.urlEncode(agsAPIDetails.Username__c,'UTF-8') +'&client_secret=' + EncodingUtil.urlEncode(agsAPIDetails.Password__c, 'UTF-8')+'&scope='+agsAPIDetails.scope__c;
            //system.debug('payload- '+payload);       
            httpReq.setBody(payLoad);
            HttpResponse response = new Http().send(httpReq);
            if(response.getStatusCode() == 200 ) {
                //system.debug('Response ===>'+EncodingUtil.urlDecode(response.getBody(), 'UTF-8'));
                token = PRM_Token_Model.parse(response.getBody());
               // Cache.Org.put('local.PRMIPAPartition.APIGEEaccesstoken',token.access_token, Integer.valueOf(Label.APIGEETokenExpiryTime),Cache.Visibility.ALL, true);
            }
        } 
        catch(Exception ex)
        {
      Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', ex.getMessage() ,'' ,'PRM_ServiceNowUtility' ,'' ,ex);    
        }
        return token;
        }   
public static String constructJSON(List<ServiceNow_Case__c> serviceNowCases)
{
    List<SNWrapper> JSONrequest = new List<SNWrapper>();
    SNWrapper wrapperJSONReq = new SNWrapper();
    String JSONstr='';
    ServiceNow_Field_Mapping__mdt mapProgramType = ServiceNow_Field_Mapping__mdt.getInstance(serviceNowCases[0].Program__c);
    for(ServiceNow_Case__c scn:serviceNowCases){
        wrapperJSONReq.urgency=scn.Urgency__c;
        wrapperJSONReq.short_description=scn.Title__c;
        wrapperJSONReq.business_service = mapProgramType.business_service__c;//'Seller Experience';
        wrapperJSONReq.caller_id = UserInfo.getUserEmail();
        wrapperJSONReq.cmdb_ci = mapProgramType.cmdb_ci__c;//'Cloud CRM - Sales Pipeline';
        wrapperJSONReq.contact_type = 'Self-service';
        wrapperJSONReq.service_offering = mapProgramType.service_offering__c;//'Partner Selling - Digital Portal Exp';
        wrapperJSONReq.assignment_group = mapProgramType.assignment_group__c;//'ESD Customer and Sales L1';
        wrapperJSONReq.description = scn.Description__c;
        //wrapperJSONReq.SNtype = scn.Type__c;

        JSONrequest.add(wrapperJSONReq);
    }
    JSONstr = JSON.serialize(JSONrequest);
    return JSONstr;

}

public class SNWrapper{
    public String short_description;
    public String urgency;
    //public string SNtype;
    public String caller_id;
    public string business_service;
    public string service_offering;
    public string cmdb_ci;
    public string contact_type;
    public string assignment_group;
    public string description;

    public SNWrapper(){
    }
}

}