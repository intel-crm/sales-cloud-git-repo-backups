public with sharing class Core_IPS_BES_JSONTriggerHandler { 
   @InvocableMethod 
    public static void getJson(List<Id> recordIdList){
        List<Id> caseRecordList = new List<Id>();
        List<Id> commentRecordList = new List<Id>();
        List<Id> attachmentRecordList = new List<Id>();
        List<Id> caseIdList = new List<Id>();
        List<Id> commentIdList = new List<Id>();
        List<Id> attachmentIdList = new List<Id>();
        List<Attachment> attList = new List<Attachment>();
        Map<Id,Id> casetoAttId = new Map<Id,Id>(); //06-09-23
        List<Core_IPS_BES_Error_Log__c> errorLogList =new List<Core_IPS_BES_Error_Log__c>();
        Map<String,Core_IPS_BES_Outbound_Message__c> outboundRecsMap = new Map<String,Core_IPS_BES_Outbound_Message__c>();
        Set<String> messageTypeSet = new Set<String>();
        List<case> caseList = new List<case>();
        Transient Map<String, List<String>> finalJSONData = new Map<String, List<String>>();
        Map<String,Core_IPS_BES_ApigeeIntegration.MessageStatus> status = new Map<String, Core_IPS_BES_ApigeeIntegration.MessageStatus>();
        
        
        if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isQueryable()){
            List<Core_IPS_BES_Outbound_Message__c> outboundRecords = [SELECT Id, Name, Core_IPS_Case_ID__c,Comment_Id__c,Core_IPS_Attachment_ID__c,Status__c FROM Core_IPS_BES_Outbound_Message__c WHERE Id IN:recordIdList ORDER BY CreatedDate DESC];  
            
            
            for(Core_IPS_BES_Outbound_Message__c obRecord : outboundRecords){
                if(!String.isBlank(obRecord.Core_IPS_Case_ID__c) && String.isBlank(obRecord.Comment_Id__c) && String.isBlank(obRecord.Core_IPS_Attachment_ID__c)){
                    caseidList.add(obRecord.Core_IPS_Case_ID__c);
                    caseRecordList.add(obRecord.Id);
                }
                if(!String.isBlank(obRecord.Comment_Id__c)){
                    commentIdList.add(obRecord.Comment_Id__c);
                    commentRecordList.add(obRecord.Id);
                }
                if(!String.isBlank(obRecord.Core_IPS_Attachment_ID__c)){
                    attachmentIdList.add(obRecord.Core_IPS_Attachment_ID__c);
                    attachmentRecordList.add(obRecord.Id);
					casetoAttId.put(obRecord.Core_IPS_Attachment_ID__c,obRecord.Core_IPS_Case_ID__c); //06-09-23                   
                }
                outboundRecsMap.put(obRecord.Name,obRecord);
            }
            
            
        } 
        if(attachmentIdList.size()>0) {
            messageTypeSet.add('Attachment'); 
        }
        if(commentIdList.size()> 0) {
            messageTypeSet.add('Comment');
        } 
        if(caseidList.size() > 0) {
            messageTypeSet.add('Case');
        } 
        if(messageTypeSet.contains('Case')){
            Transient Map<String, JSONGenerator> systemJSONMap = Core_IPS_BES_Generate_BackendJSON.generateBackendJSOn(caseRecordList,'Case');
            Transient Map<String, JSONGenerator> caseJSONMap = Core_IPS_BES_Generate_CaseJSON.getJsonForCaseObject(caseidList);
            Transient Map<String,Object> SystemMap;
            for(String caseId : caseJSONMap.keySet()){
                try{
                    SystemMap = (Map<String,Object>) JSON.deserializeUntyped(systemJSONMap.get(caseId + 'Case').getAsString());
                    Transient JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeFieldName(Label.Core_IPS_system_details);
                    gen.writeObject(SystemMap);
                    if(SystemMap.get('action_type') != 'Depromote'){
                    gen.writeFieldName(Label.Core_IPS_issue_information);
                        if(limits.getHeapSize() > 6000000){
                            throw new stringException('Heap size reached....');
                        } else {
                            //System.debug('===Do Not Remove This Debug Log, It is used to handle the APEX HEAP SIZE LIMIT EXCEPTION==='+caseJSONMap.get(caseId).getAsString());
                            gen.writeObject(JSON.deserializeUntyped(caseJSONMap.get(caseId).getAsString()));
                            // Added by Pavani for getting the transformed values of HSD status and reason from the JSON and updating those value for the DCG case  TWC745-5487 - 26/02/2024
                            Map<String, Object> jsonMapCase = (Map<String,Object>) JSON.deserializeUntyped(caseJSONMap.get(caseId).getAsString());
                            if (jsonMapCase.containsKey('hsd_reason')) {
                                Case cs = new Case();
                                cs.Id = caseId;
                             if (Schema.sObjectType.Case.fields.HSD_Mirror_Status__c.isUpdateable()) {    
                                cs.HSD_Mirror_Status__c = 'open';
                             }
                             if (Schema.sObjectType.Case.fields.HSD_Mirror_Reason__c.isUpdateable()) {    
                                cs.HSD_Mirror_Reason__c = (String) jsonMapCase.get('hsd_reason');
                             }
                                caseList.add(cs);
                              
                            }
                            jsonMapCase.clear();
                            // End by Pavani - TWC745-5487 - 26/02/2024
                           
                        } 
                    }else{
                        
                    }
                    gen.writeEndObject();
                    gen.WriteEndArray();
                    finalJSONData.put(caseId+caseId, new List<String> {gen.getAsString()});
                } catch(Exception e) {
                   // System.debug('This is in the catch block');
                    Core_IPS_BES_LogEntry_Utility.insertLog(e,outboundRecsMap.get((String)systemMap.get(Label.Core_IPS_message_id)),null,null,caseId);
                } finally {
                    //System.debug('inside the finally block');
                }
            }
            
        }
        //}
        //===============================================================================================
        //for case attachment details
        
        Transient Map<String, Map<String,JSONGenerator>> attachmentJSONMap = new Map<String, Map<String,JSONGenerator>>();
        Map<String,String> allAttachmentStr = new Map<String,String>();
        //Map<String,String> att2CaseId = new Map<String,String>();
        String str = '';
        List<Core_IPS_Case_Attachments__c> atts = new List<Core_IPS_Case_Attachments__c>();
        if(messageTypeSet.contains('Attachment')) {
            String caseId='';
            Map<String,Object> SystemMap;
            try{
                Transient Map<String, JSONGenerator> systemJSONMap = Core_IPS_BES_Generate_BackendJSON.generateBackendJSOn(attachmentRecordList,'Attachment');
                attachmentJSONMap = Core_IPS_BES_Gen_CaseAttachmentsJSON.getJsonForCaseAttachmentObject(attachmentIdList);
                allAttachmentStr = Core_IPS_BES_Gen_CaseAttachmentsJSON.getAllAttachmentUrls();
                              for(String attId:systemJSONMap.keySet()){
                    String caseRec=(String)casetoAttId.get((Id) attId.substring(0,18));
                    caseId = caseRec + attId.substring(0,18);
                    Map<String,JSONGenerator> attRecd = attachmentJSONMap.get(caseRec);
                JSONgenerator gen = JSON.createGenerator(true);
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeFieldName(Label.Core_IPS_system_details);
                gen.writeObject(JSON.deserializeUntyped(systemJSONMap.get(attId).getAsString()));
                gen.writeFieldName(Label.Core_IPS_Attachments);
                gen.writeStartArray();
                if(attRecd!=null){
                	for(String attIdRec : attRecd.keySet()){
                    	gen.writeObject(JSON.deserializeUntyped(attRecd.get(attIdRec).getAsString()));
                	}
                }
                gen.writeEndArray();
                if(allAttachmentStr!=null && allAttachmentStr.containsKey(caseRec) ){
                    gen.writeStringField('ext_attach_url', allAttachmentStr.get(caseRec));
                } else {
                    gen.writeNullField('ext_attach_url');   
                }
                gen.writeEndObject();
                gen.writeEndArray();
                //finalJSONData.put(caseId.substring(0,18),new List<String>{gen.getAsString()});
                
                if(finalJSONData.get(caseId)!= null) {
                        finalJSONData.get(caseId).add(gen.getAsString());
                } else {
                        finalJSONData.put(caseId,new List<String>{gen.getAsString()}); 
                }
                }
            } catch(Exception e) {
                //System.debug('Exception occu '+e.getMessage());
                //System.debug('reason '+e.getStackTraceString());
                Core_IPS_BES_LogEntry_Utility.insertLog(e,outboundRecsMap.get((String)systemMap.get(Label.Core_IPS_message_id)),null,null,caseId);
            }
        }
        
        //=============================================================================================
        /*for case comment details*/
        //exceptionList = new List<Core_IPS_BES_Error_Log__c>();
        Transient Map<string, JSONGenerator> commentJSONMap = new Map<string, JSONGenerator>();
        if(messageTypeSet.contains('Comment')){
            Transient Map<String, JSONGenerator> systemJSONMap = Core_IPS_BES_Generate_BackendJSON.generateBackendJSOn(commentRecordList,'Comment');
            commentJSONMap = Core_IPS_BES_Generate_CaseCommentsJSON.getJsonForCommentObject(commentIdList);
            Map<String,Object> SystemMap;
            for(String caseId : commentJSONMap.keySet()){
                try{
                    SystemMap = (Map<String,Object>) JSON.deserializeUntyped(systemJSONMap.get(caseId?.substring(18,36)+'Comment')?.getAsString());
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartArray();
                    gen.writeStartObject();
                    gen.writeFieldName(Label.Core_IPS_system_details);
                    gen.writeObject(JSON.deserializeUntyped(systemJSONMap.get(caseId.substring(18,36)+'Comment').getAsString()));
                    gen.writeFieldName(Label.IPS_Core_comments);
                    gen.writeObject(JSON.deserializeUntyped(commentJSONMap.get(caseId).getAsString()));
                    gen.writeEndObject();
                    gen.WriteEndArray();
                    if(finalJSONData.get(caseId)!= null) {
                        finalJSONData.get(caseId).add(gen.getAsString());
                    } else {
                        finalJSONData.put(caseId,new List<String>{gen.getAsString()}); 
                    }
                    //finalList.add((Map<String,String>)finalJSONData);
                }catch(Exception e){
                    //System.debug(e.getMessage()+'-'+e.getLineNumber());
                    Core_IPS_BES_LogEntry_Utility.insertLog(e,outboundRecsMap.get((String)systemMap.get(Label.Core_IPS_message_id)),null,null,caseId);
                }
            }



        }
        
			for(String key: finalJSONData.keySet()){
            for(String jsonStr: finalJSONData.get(key)){
                Core_IPS_BES_ApigeeIntegration.MessageStatus messagestatus = Core_IPS_BES_ApigeeIntegration.sendJSONBody(jsonStr);
                status.put(key, messagestatus);
            }
           
        } 
        
        //if(Case.SObjectType.getDescribe().isUpdateable()){
        //  if(messageType!='Comment'){
        database.update(caseList, true);
        //   }
        
        //}
        
        
        List<Core_IPS_BES_Outbound_Message__c> besOutBoundList = new List<Core_IPS_BES_Outbound_Message__c>();
        /* Tejaswini : Added Status__c to queried fields as part of fix for TWC745-6976 */
		String queryString = 'Select Id,Status__c, Core_IPS_Case_ID__c,Core_IPS_BES_Message_Type__c,Comment_Id__c,Core_IPS_Attachment_ID__c,core_IPS_Outbound_Message_ID__c,(select id from BES_Error_Logs__r) from Core_IPS_BES_Outbound_Message__c where ID IN :recordIdList order by CreatedDate desc';
        //if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isQueryable()){
            besOutBoundList = Database.query(queryString);
        //}
        
       // Integer counter =0;
        //if(besOutBoundList.size()>0) {
        Map<String,Core_IPS_BES_Outbound_Message__c> outboundMap = new Map<String,Core_IPS_BES_Outbound_Message__c>();
        if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isQueryable()){
            for(Core_IPS_BES_Outbound_Message__c rec : besOutBoundList){
                if(!String.isBlank(rec.Comment_Id__c)){
                    outboundMap.put(rec.Core_IPS_Case_ID__c+rec.Comment_Id__c, rec);
                }
                if(!String.isBlank(rec.Core_IPS_Attachment_ID__c)){
                    outboundMap.put(rec.Core_IPS_Case_ID__c+rec.Core_IPS_Attachment_ID__c, rec);
                }
                if(!String.isBlank(rec.Core_IPS_Case_ID__c) && String.isBlank(rec.Comment_Id__c) && String.isBlank(rec.Core_IPS_Attachment_ID__c)){
                    outboundMap.put(rec.Core_IPS_Case_ID__c+rec.Core_IPS_Case_ID__c, rec);
                }
            }
        }
        
        for(String caseId: finalJSONData.keySet()) {
            for(String jsonS: finalJSONData.get(caseId)){
                Core_IPS_BES_ApigeeIntegration.MessageStatus messageStatus = status.get(caseId);
                outboundMap.get(caseId).core_IPS_Outbound_Message_ID__c = '123';
                outboundMap.get(caseId).Core_IPS_Case_ID__c = caseId.substring(0,18);
                		/* Tejaswini : Added outboundMap.get(caseId).status__c != 'IPass Success' condition as part of fix for TWC745-6976 */
						if(outboundMap.get(caseId).status__c != 'IPass Success'){
                outboundMap.get(caseId).status__c = (messageStatus!= null)?messageStatus.message:'';
						}
                Attachment att = new Attachment();
                if (Schema.sObjectType.Attachment.fields.Body.isCreateable()) {
                	att.Body=Blob.valueOf(jsonS);
                }
                if (Schema.sObjectType.Attachment.fields.Name.isCreateable()) {
                	att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
                }
                if (Schema.sObjectType.Attachment.fields.parentId.isCreateable()) {
                	att.parentId = outboundMap.get(caseId).id;
                }
                attList.add(att);
                if(messageStatus!=null && (messageStatus.message == 'Apigee Failed' || messageStatus.message == 'IPass Failed')){
                    Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c();
                    if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Outbound_Message_Id__c.isCreateable()) {
                    	errorLog.Core_IPS_Outbound_Message_Id__c = outboundMap.get(caseId).id;
                    }
                    if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Error_Code__c.isCreateable()) {
                    	errorLog.Core_IPS_Error_Code__c = messageStatus.code;
                    }
                    if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Error_Description__c.isCreateable()) {
                    	errorLog.Core_IPS_Error_Description__c = messageStatus.body;
                    }
                    if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Status__c.isCreateable()) {
                    	errorLog.Core_IPS_Status__c = messageStatus.status;
                    }
                    if (Schema.sObjectType.Core_IPS_BES_Error_Log__c.fields.Core_IPS_Retry_Count__c.isCreateable()) {
                    	errorLog.Core_IPS_Retry_Count__c = outboundMap.get(caseId).BES_Error_Logs__r.size();
                    }
                    errorLogList.add(errorLog);
                }
            }
        }
        
        if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isUpdateable()||Attachment.SObjectType.getDescribe().isCreateable() || Core_IPS_BES_Error_Log__c.SObjectType.getDescribe().isCreateable()){
            
            if(besOutBoundList.size()>0){
                update besOutBoundList;
            } 
            
            
            if(attList.size()>0){
                insert attList; 
            }
            if(errorLogList.size()>0){
                insert errorLogList;
            }
        }
    } 
}