public with sharing class Core_IPS_BES_JSONTriggerHandler {
    //Public Static List<case> caseList = new List<case>();
    public class CustomException extends Exception {} //TWC745-7219 Changes made as part of outbound flow heap size issue
    @InvocableMethod 
    public static void getJson(List<Id> recordIdList){
        System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 1: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
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
        System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 2: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
        try{
            //START - TWC745-7219 Changes made as part of outbound flow heap size issue
            if(recordIdList!=null && !recordIdList.isEmpty() && recordIdList.size()>10){
                for(Integer i=0; i<recordIdList.size();i += 10){
                    List<Id> chunkRecordIdList = new List<Id>();
                    for (Integer j = i; j < i+10 && j < recordIdList.size(); j++) {
                        chunkRecordIdList.add(recordIdList[j]);
                    }
                    //List<Id> chunkRecordIdList = recordIdList.subList(i, Math.min(i + 10, recordIdList.size()));
                    if(chunkRecordIdList!=null && !chunkRecordIdList.isEmpty() && chunkRecordIdList.size()>0 && !(Limits.getQueueableJobs()>Limits.getLimitQueueableJobs())){
                        System.enqueueJob(new Core_IPS_BES_ChunkDataProcessorQueueable(chunkRecordIdList));
                    }else if(Limits.getQueueableJobs()> Limits.getLimitQueueableJobs()){
                        throw new CustomException(Label.Core_IPS_BES_LimitExceedMessage);
                    }
                }  //END
            }else{
                if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isQueryable()){
                    List<Core_IPS_BES_Outbound_Message__c> outboundRecords = [SELECT Id, Name, Core_IPS_Case_ID__c,Comment_Id__c,Core_IPS_Attachment_ID__c,Status__c FROM Core_IPS_BES_Outbound_Message__c WHERE Id IN:recordIdList ORDER BY CreatedDate DESC];  
                    
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 3: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
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
                    outboundRecords.clear(); //TWC745-7219 Changes made as part of outbound flow heap size issue
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 4: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    
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
                System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 5: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                if(messageTypeSet.contains('Case')){
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 6: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    Transient Map<String, JSONGenerator> systemJSONMap = Core_IPS_BES_Generate_BackendJSON.generateBackendJSOn(caseRecordList,'Case');
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 7: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    //checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                    Transient Map<String, JSONGenerator> caseJSONMap = Core_IPS_BES_Generate_CaseJSON.getJsonForCaseObject(caseidList);
                    System.debug('Json trigger Handler 111111>>>>>'+caseJSONMap.keySet());
                    checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 8: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    Transient Map<String,Object> SystemMap;
                    for(String caseId : caseJSONMap.keySet()){
                        try{
                            SystemMap = (Map<String,Object>) JSON.deserializeUntyped(systemJSONMap.get(caseId + 'Case').getAsString());
                            System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 9: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
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
                                    checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                                    gen.writeObject(JSON.deserializeUntyped(caseJSONMap.get(caseId).getAsString()));
                                    // Added by Pavani for getting the transformed values of HSD status and reason from the JSON and updating those value for the DCG case  TWC745-5487 - 26/02/2024
                                    System.debug('Json trigger Handler 22222222>>>>>'+caseJSONMap);
                                    Map<String, Object> jsonMapCase = (Map<String,Object>) JSON.deserializeUntyped(caseJSONMap.get(caseId).getAsString());
                                    System.debug('Json trigger Handler 333333>>>>>'+jsonMapCase);
                                    System.debug('Json trigger Handler 444444>>>>>'+jsonMapCase.keySet());
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
                                    System.debug('Json trigger Handler 55555555>>>>>'+jsonMapCase);
                                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 10: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                                    jsonMapCase.clear();
                                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 11: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                                    // End by Pavani - TWC745-5487 - 26/02/2024
                                } 
                            }else{
                                
                            }
                            gen.writeEndObject();
                            gen.WriteEndArray();
                            checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                            System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 12: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                            finalJSONData.put(caseId+caseId, new List<String> {gen.getAsString()});
                            System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 13: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                            checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                        } catch(Exception e) {
                            // System.debug('This is in the catch block');
                            Core_IPS_BES_LogEntry_Utility.insertLog(e,outboundRecsMap.get((String)systemMap.get(Label.Core_IPS_message_id)),null,null,caseId);
                        } finally {
                            //System.debug('inside the finally block');
                        }
                    }
                    // added dml here by chiru
                    if(caseList != null && caseList.size()>0){
                        //  database.update(caseList, true);
                    }
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 14: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    systemJSONMap.clear();
                    caseJSONMap.clear();
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 15: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                }
                //}
                //===============================================================================================
                //for case attachment details
                
                Transient Map<String, Map<String,JSONGenerator>> attachmentJSONMap = new Map<String, Map<String,JSONGenerator>>();
                Map<String,String> allAttachmentStr = new Map<String,String>();
                //Map<String,String> att2CaseId = new Map<String,String>(); //START - TWC745-7219 Commented as part of outbound flow heap size issue
                //String str = ''; // END
                //List<Core_IPS_Case_Attachments__c> atts = new List<Core_IPS_Case_Attachments__c>();
                if(messageTypeSet.contains('Attachment')) {
                    String caseId='';
                    Map<String,Object> SystemMap;  
                    try{
                        System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 16: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                        Transient Map<String, JSONGenerator> systemJSONMap = Core_IPS_BES_Generate_BackendJSON.generateBackendJSOn(attachmentRecordList,'Attachment');
                        System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 17: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                        attachmentJSONMap = Core_IPS_BES_Gen_CaseAttachmentsJSON.getJsonForCaseAttachmentObject(attachmentIdList);
                        System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 18: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                        allAttachmentStr = Core_IPS_BES_Gen_CaseAttachmentsJSON.getAllAttachmentUrls();
                        System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 19: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
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
                        System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 20: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                        systemJSONMap.clear();
                        attachmentJSONMap.clear();
                        allAttachmentStr.clear(); //TWC745-7219 Changes made as part of outbound flow heap size issue
                        System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 21: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
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
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 22: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    Transient Map<String, JSONGenerator> systemJSONMap = Core_IPS_BES_Generate_BackendJSON.generateBackendJSOn(commentRecordList,'Comment');
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 23: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                    commentJSONMap = Core_IPS_BES_Generate_CaseCommentsJSON.getJsonForCommentObject(commentIdList);
                    checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 24: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
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
                            System.debug('get Heap size'+Limits.getHeapSize());
                            checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                            gen.writeObject(JSON.deserializeUntyped(commentJSONMap.get(caseId).getAsString()));
                            checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                            gen.writeEndObject();
                            gen.WriteEndArray();
                            checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                            if(finalJSONData.get(caseId)!= null) {  
                                finalJSONData.get(caseId).add(gen.getAsString());
                            } else {
                                finalJSONData.put(caseId,new List<String>{gen.getAsString()}); 
                            }
                            checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                            //finalList.add((Map<String,String>)finalJSONData);
                        }catch(Exception e){
                            //System.debug(e.getMessage()+'-'+e.getLineNumber());
                            Core_IPS_BES_LogEntry_Utility.insertLog(e,outboundRecsMap.get((String)systemMap.get(Label.Core_IPS_message_id)),null,null,caseId);
                        }
                    }
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 25: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    systemJSONMap.clear();
                    commentJSONMap.clear();
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 26: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                }
                System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 27: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                for(String key: finalJSONData.keySet()){
                    for(String jsonStr: finalJSONData.get(key)){
                        Core_IPS_BES_ApigeeIntegration.MessageStatus messagestatus = Core_IPS_BES_ApigeeIntegration.sendJSONBody(jsonStr);
                        System.debug('messagestatus>>>>>'+messagestatus);
                        status.put(key, messagestatus);
                    }
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 28: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                } 
                
                //if(Case.SObjectType.getDescribe().isUpdateable()){
                //  if(messageType!='Comment'){
                
                //  commented by chiru
                System.debug('case listr value>>>>>'+caseList);
                database.update(caseList, true);
                //performCaseDML();
                
                
                //   }
                
                //}
                
                
                List<Core_IPS_BES_Outbound_Message__c> besOutBoundList = new List<Core_IPS_BES_Outbound_Message__c>();
                /* Tejaswini : Added Status__c to queried fields as part of fix for TWC745-6976 */
                /* Start ---- Tushar ----Added isQueryable part of venuability*/
                String queryString = 'Select Id,Status__c, Core_IPS_Case_ID__c,Core_IPS_BES_Message_Type__c,Comment_Id__c,Core_IPS_Attachment_ID__c,core_IPS_Outbound_Message_ID__c,(select id from BES_Error_Logs__r) from Core_IPS_BES_Outbound_Message__c where ID IN :recordIdList order by CreatedDate desc';
                // Added by tushar for venuability
                if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isQueryable()){
                    besOutBoundList = Database.query(queryString);
                }
                /* END ---- Tushar ----Added isQueryable part of venuability*/
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
                System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 29: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                for(String caseId: finalJSONData.keySet()) {
                    checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                    for(String jsonS: finalJSONData.get(caseId)){
                        checkHeapLimit(recordIdList); //TWC745-7219 Changes made as part of outbound flow heap size issue
                        Core_IPS_BES_ApigeeIntegration.MessageStatus messageStatus = status.get(caseId);
                        /*tushar---- remove as part of venuability changes */
                        outboundMap.get(caseId).core_IPS_Outbound_Message_ID__c = System.Label.Core_IPS_Outbound_Message_ID;
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
                System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 30: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                outboundMap.clear(); //START - TWC745-7219 Changes made as part of outbound flow heap size issue
                finalJSONData.clear();
                status.clear();//END
                System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 31: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isUpdateable()||Attachment.SObjectType.getDescribe().isCreateable() || Core_IPS_BES_Error_Log__c.SObjectType.getDescribe().isCreateable()){
                    
                    if(besOutBoundList.size()>0){
                        update besOutBoundList;
                    } 
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 32: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    besOutBoundList.clear(); //TWC745-7219 Changes made as part of outbound flow heap size issue
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 33: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    
                    if(attList.size()>0){
                        insert attList; 
                    }
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 34: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    attList.clear(); //TWC745-7219 Changes made as part of outbound flow heap size issue
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 35: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    
                    if(errorLogList.size()>0){
                        insert errorLogList;
                    }
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 36: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                    errorLogList.clear(); //TWC745-7219 Changes made as part of outbound flow heap size issue
                    System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 37: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                }
                System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 38: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
            }
        }catch(Exception e){
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join(recordIdList,','));
        }
    } 
    /***************************************************************************************************
Created Date: 29 Nov 2024
Method Name : checkHeapLimit
Description: This method is used to check the heap size limit in sync/async mode.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavani                    11/29/2024              Created  TWC745-7219
****************************************************************************************************/  
    public static void checkHeapLimit(List<Id> outboundIdList){
        System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 40: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
        Boolean asyncMode = (System.isQueueable() || System.isBatch()) ? true : false;
        if(Limits.getHeapSize()>= Limits.getLimitHeapSize() || (!asyncMode && Limits.getHeapSize() > 5500000) || (asyncMode && Limits.getHeapSize() > 11500000)){
            System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 41: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
            if(System.isQueueable()){
                System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 42: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                throw new CustomException(Label.Core_IPS_BES_LimitExceedMessage + ' Heap Size : ' + Limits.getHeapSize());
            }
            else{
                System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 43: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
                System.enqueueJob(new Core_IPS_BES_ChunkDataProcessorQueueable(outboundIdList));
            }
            System.debug('BES IPS-HSD Core_IPS_BES_JSONTriggerHandler 44: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
            throw new CustomException(Label.Core_IPS_BES_LimitExceedWarningMessage + 'Heap Size - ' + Limits.getHeapSize());
        }
    }
    
    public static void getJsonInvockable(List<Id> recordIdList){
        List<Id> OutbondMessageRecordIdList = new List<Id>();
        System.debug('getJsonInvockable');
        if(recordIdList.size() == 0 || recordIdList == null || recordIdList.isEmpty() ){
            return ;   
        }
        List<Core_IPS_BES_Error_Log__c> errorLogList =  [SELECT Id, Core_IPS_Schedule_Time__c,Core_IPS_Outbound_Message_Id__r.Id,Core_IPS_Outbound_Message_Id__c FROM Core_IPS_BES_Error_Log__c Where Id =:recordIdList[0]]; 
        if (errorLogList[0].Core_IPS_Schedule_Time__c == null) {
            return;
        }
        if(errorLogList!=null && errorLogList[0].Core_IPS_Outbound_Message_Id__c!=null){
        OutbondMessageRecordIdList.add(errorLogList[0].Core_IPS_Outbound_Message_Id__r.Id);
        }
        // Add 1 hour to the schedule time
        Datetime scheduledTime = errorLogList[0].Core_IPS_Schedule_Time__c.addHours(1);
        
        // Build the cron expression
        String cronExp = Core_IPS_BES_Invoke_HeapSize_Batch.buildCronExpression(scheduledTime);
        
        // Schedule the batch
        String jobName = 'getJson' + DateTime.now().getTime();
        Core_IPS_BES_JsonFetchScheduler obj = new Core_IPS_BES_JsonFetchScheduler(OutbondMessageRecordIdList);
        System.debug('jobName getJsonInvockable'+jobName);
        System.debug('cronExp getJsonInvockable'+cronExp);
        System.schedule( jobName,cronExp,obj);
        System.debug('schedule Callled getJsonInvockable');
    }
}