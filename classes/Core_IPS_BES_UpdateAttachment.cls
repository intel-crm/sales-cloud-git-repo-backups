/*********************************************
* Name : Core_IPS_BES_UpdateAttachment 
* Author : Chandrashekar Pallikonda
* Description : This class is used to update attachment's status as well as revision number on Case.
*   
************************************************/
public with sharing class Core_IPS_BES_UpdateAttachment {
    public static void setAttachmentStatus(List<String> inboudJSONList){
        Map<string,Object> backendJsonObj;
        //Map<String,String> caseMap = new Map<String,String>(); //Commented as part of Code Refactor TWC745-6459
        List<Core_IPS_Case_Attachments__c> attachmentList = new List<Core_IPS_Case_Attachments__c>();
        //Map<String,String> revisionMap = new Map<String,String>(); //Commented as part of Code Refactor TWC745-6459
       // Map<String,String> sourceDetailsMap = new Map<String,String>();
        Set<String> caseNumberSet = new Set<String>(); //Added as part of Code Refactor TWC745-6459
        try{
             System.debug('Heap Size setAttachmentStatus Entry '+ Limits.getHeapSize());
            for(String inboundJSON: inboudJSONList){
                backendJsonObj = (Map<string,Object>) JSON.deserializeUntyped(inboundJSON); 
                //caseMap.put((String)backendJsonObj.get('target_id'), (String) backendJsonObj.get('source_id'));
                //revisionMap.put((String)backendJsonObj.get('target_id'), (String)backendJsonObj.get('backend_rev'));
               // sourceDetailsMap.put((String)backendJsonObj.get('target_id'), (String)backendJsonObj.get('source_id'));

               //START - Added as part of Code Refactor TWC745-6459
               String caseNumber = (String)backendJsonObj.get('target_id');
               caseNumberSet.add(caseNumber);
               system.debug('COG Issue Validation---- Updateattachmentid before revmap--'+Core_IPS_BES_InboundMessage.revisionMap);
                system.debug('COG Issue Validation---- Updateattachmentid before srcMap--'+Core_IPS_BES_InboundMessage.sourceDetailsMap);
               //if((!Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber)) || (Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber) && (Integer.ValueOf(backendJsonObj.get('backend_rev')) > Integer.ValueOf(Core_IPS_BES_InboundMessage.revisionMap.get(caseNumber))))){
                
                //Added by Pavani for Null check Fix
                if(backendJsonObj.containskey('backend_rev') && String.isNotBlank((String)backendJsonObj.get('backend_rev')) && ((!Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber)) || (Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber) && (Integer.ValueOf(backendJsonObj.get('backend_rev')) > Integer.ValueOf(Core_IPS_BES_InboundMessage.revisionMap.get(caseNumber)))))){
                   Core_IPS_BES_InboundMessage.revisionMap.put(caseNumber, (String)backendJsonObj.get('backend_rev')); 
                }
               //if(!Core_IPS_BES_InboundMessage.sourceDetailsMap.containskey(caseNumber)){ 
               if(backendJsonObj.containskey('source_id') && String.isNotBlank((String)backendJsonObj.get('source_id')) && (!Core_IPS_BES_InboundMessage.sourceDetailsMap.containskey(caseNumber))){
                Core_IPS_BES_InboundMessage.sourceDetailsMap.put(caseNumber, (String)backendJsonObj.get('source_id')); 
               } //END
                
               system.debug('COG Issue Validation---- Updateattachmentid after revmap--'+Core_IPS_BES_InboundMessage.revisionMap);
               system.debug('COG Issue Validation---- Updateattachmentid after srcMap--'+Core_IPS_BES_InboundMessage.sourceDetailsMap);
            }
            System.debug('Heap Size setAttachmentStatus 22 '+ Limits.getHeapSize());
            List<Id> caseIds = new List<Id>();
            List<Case> caseList;
            //addede by chiru
            if(Case.sObjectType.getDescribe().isQueryable()){
            	//caseList = [SELECT Id,CaseNumber FROM CASE WHERE CaseNumber IN: caseMap.keySet()];
                caseList = [SELECT Id,CaseNumber FROM CASE WHERE CaseNumber IN: caseNumberSet]; //START - Added as part of Code Refactor TWC745-6459
            }
            System.debug('Heap Size setAttachmentStatus 27 '+ Limits.getHeapSize());
            if(!caseList.isEmpty()){
             	for(Case cases : caseList){
                	caseIds.add(cases.Id);
            	}   
            }
            if(Core_IPS_Case_Attachments__c.sObjectType.getDescribe().isQueryable()){
            	//List<Core_IPS_Case_Attachments__c> attLi = [SELECT Id, Core_Case__c, Core_Upload_Status__c,Core_IPS_BES_Promote_Status__c FROM Core_IPS_Case_Attachments__c WHERE Core_Case__c IN: caseIds AND Core_Upload_Status__c ='Complete'];
                for(Core_IPS_Case_Attachments__c att: [SELECT Id, Core_Case__c, Core_Upload_Status__c,Core_IPS_BES_Promote_Status__c FROM Core_IPS_Case_Attachments__c WHERE Core_Case__c IN: caseIds AND Core_Upload_Status__c ='Complete']){
                //    if(Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_IPS_BES_Promote_Status__c.isUpdateable()){
                        if(att.Core_IPS_BES_Promote_Status__c != 'Done'){
                         	att.Core_IPS_BES_Promote_Status__c = 'Done';   
                 //       }
                    }
                    attachmentList.add(att);
                }
                System.debug('Heap Size setAttachmentStatus 44 '+ Limits.getHeapSize());
            }
            if(Core_IPS_Case_Attachments__c.SObjectType.getDescribe().isUpdateable() && !attachmentList.isEmpty()){
                update attachmentList;
            }
            attachmentList.clear();
             System.debug('Heap Size setAttachmentStatus 49 '+ Limits.getHeapSize());
            //START - Commented as part of Code Refactor TWC745-6459
            /* if(revisionMap != null){
            	//Core_IPS_BES_InboundMessage.updateRevision(revisionMap,sourceDetailsMap);
            	Core_IPS_BES_InboundMessage.updateRevision(revisionMap,caseMap);

            }
            revisionMap.clear();
            caseMap.clear();--- END*/
          System.debug('Heap Size setAttachmentStatus EXit '+ Limits.getHeapSize());
        } catch(Exception e) {
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join((Iterable<String>)inboudJSONList,','));
        }
    }
}