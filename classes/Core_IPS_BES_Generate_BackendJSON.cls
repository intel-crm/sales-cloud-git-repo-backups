public with sharing class Core_IPS_BES_Generate_BackendJSON {
    public static Map<String, JSONGenerator> generateBackendJSOn(List<Id> recordIdList, String messageType){
    Map<String, JSONGenerator> genMap = new Map<String, JSONGenerator>();
    Map<String, Core_IPS_BES_Outbound_Message__c> outBoundMap = new Map<String, Core_IPS_BES_Outbound_Message__c>();
    Map<String, Core_IPS_BES_Outbound_Message__c> outBoundNameMap = new Map<String, Core_IPS_BES_Outbound_Message__c>();
    Map<Id, Case> caseMap;
    List<String> caseIdList = new List<string>();
    try{
        String jsonData = '';
        if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isQueryable()){
            List<Core_IPS_BES_Outbound_Message__c> sObjList = [Select Id, Core_IPS_Case_ID__c,Name,Comment_Id__c,Core_IPS_Attachment_ID__c,Core_IPS_BES_Depromote_Id__c,Core_IPS_Old_Backend_String__c  from Core_IPS_BES_Outbound_Message__c where id IN : recordIdList];
            for(Core_IPS_BES_Outbound_Message__c outBoundMsg: sObjList){
                if(messageType == 'Comment' && outBoundMsg !=null && (outBoundMsg.Comment_Id__c != null ||outBoundMsg.Comment_Id__c !='')&&(outBoundMsg.Core_IPS_Attachment_ID__c == null ||outBoundMsg.Core_IPS_Attachment_ID__c =='' )){
                 	outBoundMap.put(outBoundMsg.Core_IPS_Case_ID__c+outBoundMsg.Comment_Id__c, outBoundMsg);   
                } else if(messageType == 'Attachment' && (outBoundMsg.Comment_Id__c == null ||outBoundMsg.Comment_Id__c =='')&&(outBoundMsg.Core_IPS_Attachment_ID__c != null ||outBoundMsg.Core_IPS_Attachment_ID__c !='' )){
                    outBoundMap.put(outBoundMsg.Core_IPS_Case_ID__c+outBoundMsg.Core_IPS_Attachment_ID__c, outBoundMsg);   
                } else if(messageType == 'Case' && (outBoundMsg.Comment_Id__c == null ||outBoundMsg.Comment_Id__c =='')&&(outBoundMsg.Core_IPS_Attachment_ID__c == null ||outBoundMsg.Core_IPS_Attachment_ID__c =='' )) {
                    outBoundMap.put(outBoundMsg.Core_IPS_Case_ID__c, outBoundMsg);  
                    
                }
                if(outBoundMsg.Core_IPS_Case_ID__c !=null || outBoundMsg.Core_IPS_Case_ID__c !=''){
                    caseIdList.add(outBoundMsg.Core_IPS_Case_ID__c);
                }
                
                if(outBoundMsg.Comment_Id__c != null){
                    outBoundNameMap.put(outBoundMsg.Comment_Id__c + 'Comment' , outBoundMsg);
                }
                if(outBoundMsg.Core_IPS_Attachment_ID__c != null){
                    outBoundNameMap.put(outBoundMsg.Core_IPS_Attachment_ID__c + 'Attachment', outBoundMsg);
                }
                if(outBoundMsg.Core_IPS_Case_ID__c != null && outBoundMsg.Comment_Id__c == null && outBoundMsg.Core_IPS_Attachment_ID__c == null){
                    outBoundNameMap.put(outBoundMsg.Core_IPS_Case_ID__c + 'Case', outBoundMsg);
                }
            } 
            Set<String> casesIds = outBoundMap.keySet();
            if(messageType == 'Case'){
            	caseMap = new Map<Id, Case>([Select Id,CaseNumber,Core_IPS_BackendID__c,Core_IPS_New_Backend_System__r.Core_IPS_Target_System__c from case where Id IN: outBoundMap.keyset()]);
            } else {
            	caseMap = new Map<Id, Case>([Select Id,CaseNumber,Core_IPS_BackendID__c,Core_IPS_New_Backend_System__r.Core_IPS_Target_System__c from case where Id IN: caseIdList]);
            }
            for(String csId: outBoundMap.keySet()){
                JSONGenerator gen = JSON.createGenerator(true);       
                gen.writeStartObject();
                if(messageType != 'Case'){
                    gen.writeStringField(Label.Core_IPS_message_id,  outBoundNameMap.get(csId.substring(18,36)+messageType).Name);
                } else {
                    gen.writeStringField(Label.Core_IPS_message_id,  outBoundNameMap.get(csId+messageType).Name);
                }
                gen.writeStringField(Label.Core_IPS_message_type, messageType);
                gen.writeStringField(Label.Core_IPS_source_system, 'IPS');
                if(messageType != 'Case'){
                    if(!String.isBlank(outBoundNameMap.get(csId.substring(18,36)+messageType).Core_IPS_BES_Depromote_Id__c) ){
                    	gen.writeStringField(Label.Core_IPS_target_system, outBoundNameMap.get(csId.substring(18,36)+messageType).Core_IPS_Old_Backend_String__c);
                    }else{
                      	gen.writeStringField(Label.Core_IPS_target_system, caseMap.get(csId.substring(0,18)).Core_IPS_New_Backend_System__r.Core_IPS_Target_System__c != null ? caseMap.get(csId.substring(0,18)).Core_IPS_New_Backend_System__r.Core_IPS_Target_System__c : '');  
                    }
                } else{
                    if(!String.isBlank(outBoundNameMap.get(csId.substring(0,18)+messageType).Core_IPS_BES_Depromote_Id__c) ){
                    	gen.writeStringField(Label.Core_IPS_target_system, outBoundNameMap.get(csId+messageType).Core_IPS_Old_Backend_String__c);
                    }else{
                      	gen.writeStringField(Label.Core_IPS_target_system, caseMap.get(csId).Core_IPS_New_Backend_System__r.Core_IPS_Target_System__c != null ? caseMap.get(csId).Core_IPS_New_Backend_System__r.Core_IPS_Target_System__c : '');  
                    }
                }
                if(messageType != 'Case'){
                    gen.writeStringField(Label.Core_IPS_source_id, caseMap.get(csId.substring(0,18)).CaseNumber);
                } else {
                    gen.writeStringField(Label.Core_IPS_source_id, caseMap.get(csId).CaseNumber);
                }
                if(messageType != 'Case'){
                    if(!String.isBlank(outBoundNameMap.get(csId.substring(18,36)+messageType).Core_IPS_BES_Depromote_Id__c) ){
                    	gen.writeStringField(Label.Core_IPS_target_id, outBoundNameMap.get(csId.substring(18,36)+messageType).Core_IPS_BES_Depromote_Id__c);
                    }else{
                    gen.writeStringField(Label.Core_IPS_target_id, caseMap.get(csId.substring(0,18)).Core_IPS_BackendID__c != null ? caseMap.get(csId.substring(0,18)).Core_IPS_BackendID__c : '');   
                    }                
                    } else {
                    if(!String.isBlank(outBoundNameMap.get(csId.substring(0,18)+messageType).Core_IPS_BES_Depromote_Id__c) ){
                        gen.writeStringField(Label.Core_IPS_target_id, outBoundNameMap.get(csId.substring(0,18)+messageType).Core_IPS_BES_Depromote_Id__c); 
                    }else{
                        gen.writeStringField(Label.Core_IPS_target_id, caseMap.get(csId).Core_IPS_BackendID__c != null ? caseMap.get(csId).Core_IPS_BackendID__c : ''); 
                    }
                }
                if(messageType == 'Case'){
                    if(!String.isBlank(caseMap.get(csId).Core_IPS_BackendID__c) && String.isBlank(outBoundNameMap.get(csId+messageType).Core_IPS_BES_Depromote_Id__c)) {
                        gen.writeStringField(Label.Core_IPS_action_type, 'Update'); 
                    } else {
                        if(!String.isBlank(outBoundNameMap.get(csId+messageType).Core_IPS_BES_Depromote_Id__c) ){
                            gen.writeStringField(Label.Core_IPS_action_type, 'Depromote');
                        }else{
                             gen.writeStringField(Label.Core_IPS_action_type, 'Promote');
                        }
                    }
                } else {
                    gen.writeStringField(Label.Core_IPS_action_type, 'Promote'); 
                }
              
                gen.writeEndObject();
                jsonData = gen.getAsString();
                if(messageType != 'Case'){
                    genMap.put(csId.substring(18,36) + messageType, gen);   
                } else {
                 	genMap.put(csId + messageType, gen);   
                }
            }
        }
	} catch(Exception e){
    	//Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, null);//String.join((Iterable<String>)caseMap.keySet(),','
    }
        return genMap;  
    }
}