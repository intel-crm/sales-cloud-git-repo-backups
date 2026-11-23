public without sharing class Core_IPS_BES_Gen_CaseAttachmentsJSON {
    public static Map<String,String> allAttachmentUrls = new Map<String,String>();
   // public static Map<String,String> dateUtilMap = new Map<String, String>();
   // public static Map<String,String>  fileNameMap = new Map<String, String>();
    public static Map<String,List<String>> allCaseAttachments = new Map<String,List<String>>(); // June 4th 2024
    public static Map<String,sObject> attachmentRecord = new Map<String, sObject>(); // June 4th 2024
    public static Map<String, Map<String,JSONGenerator>> getJsonForCaseAttachmentObject(List<Id> attachmentIdList) {
        
        String sObjectFields = '';
        String objName ='Core_IPS_Case_Attachments__c';
        Map<String,String> cafieldMap = new Map<String, String>();
        Map<String, Map<String,JSONGenerator>> genMap = new Map<String, Map<String,JSONGenerator>>();// June 4th 2024
        String jsonData = '';
        List<sObject> sObjListTest = new List<sObject>();
        List<Core_IPS_Case_Attachments__c> attachmentList = new List<Core_IPS_Case_Attachments__c>();
        List<String> getAttachmentCaseIds = new List<String>();
        try{
            if(IPS_Case_Attachment_Fields__c.SObjectType.getDescribe().isQueryable()){
                if(attachmentIdList.size()>0){ 
                    List<IPS_Case_Attachment_Fields__c> attachmentCustomSettings =[Select Id, Object_Name__c, Attachment_Field_Type__c, Attachment_Field_API_Name__c, JSON_Field_Name__c from IPS_Case_Attachment_Fields__c order by name DESC ];
                    for(IPS_Case_Attachment_Fields__c ca : attachmentCustomSettings){                   
                        cafieldMap.put(ca.Attachment_Field_API_Name__c, ca.JSON_Field_Name__c); 
                    }
                }
            }
            sObjectFields = String.join(new List<String>(cafieldMap.keySet()),',');
            if(Core_IPS_Case_Attachments__c.SObjectType.getDescribe().isAccessible()){
            attachmentList = [SELECT Core_Case__c FROM Core_IPS_Case_Attachments__c WHERE Id IN: attachmentIdList ALL ROWS];
            }
            for(Core_IPS_Case_Attachments__c attachment :attachmentList){
                     getAttachmentCaseIds.add(attachment.Core_Case__c);
            }
            
            if(Core_IPS_Case_Attachments__c.SObjectType.getDescribe().isAccessible()){
            sObjListTest = [SELECT Id,Name,Core_IPS_Attachment_Visibility__c,Core_IPS_BackendId__c,Core_IPS_BES_BackendType__c,Core_File_Description__c,Core_File_Name__c,Core_File_URL__c,Core_IPS_Uploaded_By_Email__c,Core_IPS_Uploaded_By_Name__c,Core_Case__c,Core_Upload_Status__c,createddate FROM Core_IPS_Case_Attachments__c WHERE Core_Case__c IN : getAttachmentCaseIds and Core_Upload_Status__c='Complete' ];
            }
            
            for(sObject sobj: sObjListTest) {
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();  
                String idVal;
                String url;
                String name;
                String createDate;
                String fileName;
                for(String field: cafieldMap.keySet()){  
                    if(sobj.get(field) != null && String.ValueOf(sobj.get(field))!=null && String.isNotBlank(String.ValueOf(sobj.get(field)))){
                        if(field.equalsIgnoreCase('Core_File_URL__c')){
                            url = Core_IPS_Attachment_Utility.setURL(String.ValueOf(sobj.get(field)), String.ValueOf((sobj.get('Core_IPS_BES_BackendType__c'))==null ? '':sobj.get('Core_IPS_BES_BackendType__c')+'/'),String.valueof(sobj.get('Core_IPS_BackendId__c')));
                            gen.writeStringField( cafieldMap.get(field) , url);
                        } else if(field.equalsIgnoreCase('Id')){
                            idVal = String.valueOf(sobj.get(field));
                        } else {
                            gen.writeStringField(cafieldMap.get(field), String.ValueOf(sobj.get(field)));
                        }
                        if(field.equalsIgnoreCase('createdDate')){
                            createDate = String.valueOf(sobj.get(field));
                        }
                        if(field.equalsIgnoreCase('Core_File_Name__c')){
                            fileName = String.valueOf(sObj.get('Core_File_Name__c'));
                        }
                    } else {
                        gen.writeStringField(cafieldMap.get(field), '');
                    } 
                }
                gen.writeEndObject(); 
                jsonData += gen.getAsString()+',';               
                if(!genMap.containsKey(String.valueOf(sObj.get('Core_Case__c')))){
                    Map<String,JSONGenerator> genData = new Map<String,JSONGenerator>();
                    genData.put(idVal, gen);
                    genMap.put(String.valueOf(sObj.get('Core_Case__c')),genData);
                }else{
                    Map<String,JSONGenerator> genData = genMap.get(String.valueOf(sObj.get('Core_Case__c')));
                    genData.put(idVal, gen);
                    genMap.put(String.valueOf(sObj.get('Core_Case__c')),genData);
                }             
               // genMap.put(String.ValueOf(sObj.get('Name')), gen);
                allAttachmentUrls.put(idVal, url);
               // fileNameMap.put(idVal, fileName);
               // dateUtilMap.put(idVal, createDate);
                if(!allCaseAttachments.containsKey(String.valueOf(sObj.get('Core_Case__c')))){
                    List<String> attList = new List<String>();
                    attList.add(idVal);
                    allCaseAttachments.put(String.valueOf(sObj.get('Core_Case__c')),attList);
                }else{
                    List<String> attList = allCaseAttachments.get(String.valueOf(sObj.get('Core_Case__c')));
                    attList.add(idVal);
                    allCaseAttachments.put(String.valueOf(sObj.get('Core_Case__c')),attList);
                }
                attachmentRecord.put(idVal,sobj);
            }
        } catch(Exception e) {
            Core_IPS_BES_LogEntry_Utility.insertLog(e,null,null,null,String.join(attachmentIdList,','));
        }
        return genMap;
    }
    
    public static Map<String,String> getAllAttachmentUrls() {
        try{
            Map<String,List<String>> caseAttRecs = allCaseAttachments;
            List<Object> parameters1 = new List<Object> {'<?xml version=\"1.0\" ?><dict>','</dict>'};
            List<Object> parameters2 = new List<Object> {'<a href="','" target=\"_blank\">','</a>'};
            Map<String,String> finalAttachStr = new Map<String,String>();
            for(String att : caseAttRecs.keySet()){
                List<String> attachRec = caseAttRecs.get(att);
                    if(attachRec!= null ){
            String tempStr = '';
            String urlStr = '';
            String finalStr = '';
            List<String> urlsList = new List<String>();
                        for(String str : attachRec){
                            if(allAttachmentUrls.containsKey(str)){
                                String URL = allAttachmentUrls.get(str);
                URL = URL.replace('IPS_SFT','HSDES_SFT');
                                String fileName = '['+String.valueOf(attachmentRecord.get(str).get('createdDate'))+'] '+String.valueOf(attachmentRecord.get(str).get('Core_File_Name__c'));
                                tempStr ='{0}'+allAttachmentUrls.get(str)+'{1}'+fileName+'{2}';
                urlStr = String.format(tempStr, parameters2);
                urlsList.add(urlStr);
            }
                        }    
            tempStr='';
            for(String str: urlsList){
                tempStr += str;
            }
            finalStr = String.format('{0}'+tempStr+'{1}', parameters1);
            finalStr = finalStr.replace(Label.Core_IPS_Attachment_Replace_Link, Label.Core_IPS_BES_Attachment_Download_URL);
                        finalAttachStr.put(att,finalStr);
                    }
            }
            
            return finalAttachStr;
        } catch(Exception e) {
            
        }
        return null;
    }
}