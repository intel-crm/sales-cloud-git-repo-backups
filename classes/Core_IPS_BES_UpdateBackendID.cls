/********************************************* 
* Name : Core_IPS_BES_UpdateBackendID 
* Author : Farooq Ahmed
* Date Created : 18/08/2020
* Description : This class updates the backend id.
* Version Updates : 
*   
************************************************/
public with sharing class Core_IPS_BES_UpdateBackendID {
    //addede by as part of code refactor
    public static List<case> caseList = new List<case>();
    public static void setJson(List<String> inboudJSONList){
        Map<String,String> caseMap = new Map<String,String>();
        Map<string,Object> backendJsonObj;
        //List<case> caseList = new List<case>(); //commented  as part of code refactor
        //backendJsonObj = caseJSON.
        //START - Commented as part of Code Refactor TWC745-6459
       /* Map<String,String> revisionMap = new Map<String,String>();
        Map<String,String> sourceDetailsMap = new Map<String,String>(); - END*/ 
        try{
            for(String inboundJSON: inboudJSONList){
                backendJsonObj = (Map<string,Object>) JSON.deserializeUntyped(inboundJSON); 
                caseMap.put((String)backendJsonObj.get('target_id'), (String) backendJsonObj.get('source_id'));  
                //revisionMap.put((String)backendJsonObj.get('target_id'), (String)backendJsonObj.get('backend_rev'));
                //sourceDetailsMap.put((String)backendJsonObj.get('target_id'), (String)backendJsonObj.get('source_id')); 
                //START - Added as part of Code Refactor TWC745-6459
                String caseNumber = (String)backendJsonObj.get('target_id');
                
                //if((!Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber)) || (Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber) && (Integer.ValueOf(backendJsonObj.get('backend_rev')) > Integer.ValueOf(Core_IPS_BES_InboundMessage.revisionMap.get(caseNumber))))){
                       
                //Added by Pavani for Null check Fix
                if(backendJsonObj.containskey('backend_rev') && String.isNotBlank((String)backendJsonObj.get('backend_rev')) && ((!Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber)) || (Core_IPS_BES_InboundMessage.revisionMap.containskey(caseNumber) && (Integer.ValueOf(backendJsonObj.get('backend_rev')) > Integer.ValueOf(Core_IPS_BES_InboundMessage.revisionMap.get(caseNumber)))))){        
                    Core_IPS_BES_InboundMessage.revisionMap.put(caseNumber, (String)backendJsonObj.get('backend_rev'));  }
                //if(!Core_IPS_BES_InboundMessage.sourceDetailsMap.containskey(caseNumber)){ 
                if(backendJsonObj.containskey('source_id') && String.isNotBlank((String)backendJsonObj.get('source_id')) && (!Core_IPS_BES_InboundMessage.sourceDetailsMap.containskey(caseNumber))){     
                    Core_IPS_BES_InboundMessage.sourceDetailsMap.put(caseNumber, (String)backendJsonObj.get('source_id'));  }
               
            }
           
            if (Case.SObjectType.getDescribe().isQueryable()) {
                for(Case cs: [SELECT ID, casenumber,Core_IPS_New_Backend_System__c, Core_IPS_BackendID__c  FROM case WHERE caseNumber IN : caseMap.keySet()]){
                     
                    /*US1038991 - 09/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.case.fields.Core_IPS_BackendID__c.isUpdateable()){
                        cs.Core_IPS_BackendID__c = caseMap.get(cs.CaseNumber);
                    }
                    if(Schema.sObjectType.case.fields.Core_IPS_BES_Promote_Status__c.isUpdateable()){
                        if(!String.isBlank(cs.Core_IPS_BackendID__c) && cs.Core_IPS_BackendID__c != '' && cs.Core_IPS_New_Backend_System__c !=null)
                        cs.Core_IPS_BES_Promote_Status__c = 'Done';
                    }
                        //cs.Core_IPS_Backend_Rev__c = '1';
                    
                    caseList.add(cs);
                } 
            }
	/*START - Commented as part of Code Refactor TWC745-6459
            if (Case.SObjectType.getDescribe().isUpdateable()){
                update caseList;
            }
            if(revisionMap.size()>0){
            	Core_IPS_BES_InboundMessage.updateRevision(revisionMap,sourceDetailsMap);
            }*/
        } catch(Exception e) {
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join((Iterable<String>)inboudJSONList,','));
        }    
        
    }
  
}