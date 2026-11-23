/*********************************************
* Name : Core_IPS_CaseAttachmentloader 
* Author : Ranjini J N
* Date Created : 11/10/2020
* Description : 
* Version Updates : 
*   
************************************************/
@RestResource(urlMapping='/Core_IPS_CaseAttachmentloader/*')
global with sharing class Core_IPS_CaseAttachmentloader {
    @HttpPost
    global static String postError(){
        RestRequest req = RestContext.request;
        System.debug('req=='+req);
        Blob body = req.requestBody;
        String response = body.toString();
        System.debug('response-'+response);
        if(response != null){
             Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
                if(responseMap.containsKey('case_id')){
                     String caseId = (responseMap!=null) ? (String) responseMap.get('case_id') : null;
                     String attachmentType = (responseMap!=null) ? (String) responseMap.get('attachment_type') : null;
                     //getAllAttachments(new List<Id>{caseId});
                    // prepareURLforAttachment(caseId,attachmentType);
                    return JSON.serialize(prepareURLforAttachment(caseId,attachmentType));
                }
        }
        return null;
    }
  

    public class getFileDetails{
        public getFileDetails(id fileid,String fileName,String fileDescription,String uploadStatus){
            this.fileid = fileid;
            this.fileName = fileName;
            this.fileDescription = fileDescription;
            this.uploadStatus = uploadStatus;
        }
        public id fileid ;
        public String fileName ;
        public String fileDescription;
        public String uploadStatus;
    }
    
      public static Map<ID,List<String>> getAllAttachments(List<Id> CaseIDs){
        List<Core_IPS_Case_Attachments__c> allrelatedAttachmnets =[SELECT Id,  Name, Core_Case__c,Core_File_Name__c,  Core_File_URL__c,  Core_IPS_Attachment_Visibility__c, Core_IPS_Attachment_Source__c FROM Core_IPS_Case_Attachments__c where Core_Case__c IN :CaseIDs];
        Map<ID,List<String>> caseAttachmentMap = new Map<ID,List<String>>();
        for(Core_IPS_Case_Attachments__c attach: allrelatedAttachmnets){
            if(caseAttachmentMap.get((Id)attach.Core_Case__c)==null){
                caseAttachmentMap.put(attach.Core_Case__c, new List<String>{attach.Core_File_URL__c});
            }else{
                caseAttachmentMap.get((Id)attach.Core_Case__c).add(attach.Core_File_URL__c);
            }
        }
       // System.debug('caseAttachmentMap::'+caseAttachmentMap);
        return caseAttachmentMap;
    }
    
    public static Map<Id,String> prepareURLforAttachment(Id caseId, String attachmentType){
        Map<Id,String> caseurlMap = new Map<Id,String>();
        Map < String, String > mapJsonList = new Map < String, String >();
        if(attachmentType == 'PRIVATE_TO_INTEL'){
            mapJsonList.put('visibility', Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c);
        }
        if(attachmentType == 'PUBLIC_TO_CUSTOMERS'){
            mapJsonList.put('visibility', Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);
        }
        if(attachmentType == 'PRIVATE_TO_PARTNERS'){
            mapJsonList.put('visibility', Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c);
        }
        
        String jsonString = JSON.serialize(mapJsonList);
        jsonString = EncodingUtil.urlEncode(jsonString, 'UTF-8');
        string URL = System.Label.Core_IPS_File_SCFT_URL + '?caseId=' + caseId + '&extended=' + jsonString;   
        caseurlMap.put(caseId, URL);
        return caseurlMap;
    }
    
}