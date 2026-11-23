public with sharing class Core_IPS_BES_UpdateCommentID {
    public static void setCommentId(List<String> inboudJSONList){
        Map<String,String> commentMap = new Map<String,String>();
        Map<String,String> outboundMap = new Map<String,String>();
        Map<string,Object> backendJsonObj;
        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        List<String> outboundMessageList = new List<String>();
        //START - Commented as part of Code Refactor TWC745-6459
        /*Map<String,String> sourceDetailsMap = new Map<String,String>();
        Map<String,String> revisionMap = new Map<String,String>(); --- END*/
        //backendJsonObj = caseJSON.
        try{
           
            for(String inboundJSON: inboudJSONList){
                backendJsonObj = (Map<string,Object>) JSON.deserializeUntyped(inboundJSON); 
                
                commentMap.put((String)backendJsonObj.get('message_id'), (String) backendJsonObj.get('message_type_id'));  
                //revisionMap.put((String)backendJsonObj.get('target_id'), (String)backendJsonObj.get('backend_rev'));
                //sourceDetailsMap.put((String)backendJsonObj.get('target_id'), (String)backendJsonObj.get('source_id'));
                //START - Added as part of Code Refactor TWC745-6459
                String caseNumber = (String)backendJsonObj.get('target_id');
                //if((!Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber)) || (Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber) && (Integer.ValueOf(backendJsonObj.get('backend_rev')) > Integer.ValueOf(Core_IPS_BES_InboundMessage.revisionMap.get(caseNumber))))){
                
                //Added by Pavani for Null check Fix
                if(backendJsonObj.containskey('backend_rev') && String.isNotBlank((String)backendJsonObj.get('backend_rev')) && ((!Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber)) || (Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber) && (Integer.ValueOf(backendJsonObj.get('backend_rev')) > Integer.ValueOf(Core_IPS_BES_InboundMessage.revisionMap.get(caseNumber)))))){
                    Core_IPS_BES_InboundMessage.revisionMap.put(caseNumber, (String)backendJsonObj.get('backend_rev'));  
                }
                //if(!Core_IPS_BES_InboundMessage.sourceDetailsMap.containskey(caseNumber)){ 
                if(backendJsonObj.containskey('source_id') && String.isNotBlank((String)backendJsonObj.get('source_id')) && (!Core_IPS_BES_InboundMessage.sourceDetailsMap.containskey(caseNumber))){ 
                    Core_IPS_BES_InboundMessage.sourceDetailsMap.put(caseNumber, (String)backendJsonObj.get('source_id'));  
                }
                
            }
            if(Core_IPS_BES_Outbound_Message__c.SObjectType.getDescribe().isQueryable()){
                List<Core_IPS_BES_Outbound_Message__c> outboundMessagelst= [SELECT ID,Name,Comment_Id__c from Core_IPS_BES_Outbound_Message__c
                                                                            WHERE Name IN: commentMap.keySet() AND Comment_Id__c !=''];
                for(Core_IPS_BES_Outbound_Message__c outboundMsg: outboundMessagelst){
                    Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c(Id= outboundMsg.Comment_Id__c, 
                                                                                          Core_IPS_BES_ExtCommentID__c = commentMap.get(outboundMsg.Name));
                    commentList.add(caseComment);
                    
                }
            }
            
            
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isUpdateable()){
                if(commentList.size()>0){
                    update commentList;
                }
            }
            //START - Commented as part of Code Refactor TWC745-6459   
            /*if(revisionMap != null){
            	Core_IPS_BES_InboundMessage.updateRevision(revisionMap,sourceDetailsMap);
            }
            revisionMap.clear();
            sourceDetailsMap.clear();-- END*/
        }catch(exception e){
             Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join((Iterable<String>)inboudJSONList,','));   

            
        }
    }
 
    
}