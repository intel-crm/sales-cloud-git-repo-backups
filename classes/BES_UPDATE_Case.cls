public class BES_UPDATE_Case {
/*    Existing Class Backup
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
public with sharing class Core_IPS_BES_UpdateCase {
    public class CustomException extends Exception {}
    public static Map<String,String> fieldMap = new Map<String, String>();*/
    /*Method signature changed by Tejaswini Harpanhalli - DCG Custom Logic */
   
    
    /*
     public static void updateCase(List<String> caseStringList, Map<String, String> userDetailsMap){
         System.debug('Chiru caseStringList :'+ caseStringList);
         System.debug('Chiru userDetailsMap :'+ JSON.serialize(userDetailsMap));
        //Map<String,String> fieldMap = new Map<String, String>(); //contains case object Map
        Map<String, String> additionalInfoMap = new Map<String, String >();//this map is used to store field-value mapping for those objects where checkbox is checked in custom setting
        Map<String,String> fieldMapEnv = new Map<String, String>(); //Contains Response object map(EDQ)
        Map<String,String> caseMap = new Map<String,String>();
        Map<String,String> caseIdMap = new Map<String,String>();
        Map<String,String> revisionMap = new Map<String,String>();
        
        
        String status,reason;
        Boolean isSameValue;
        String ownerInfo;        
        Set<String> listIdSId = new Set<String>();
        Map<String,String> sourceDetailsMap = new Map<String,String>();
        //System.debug('userDetailsMap: ' + userDetailsMap);
        try{
            if(IPS_Case_Fields__c.SObjectType.getDescribe().isQueryable()){
                List<IPS_Case_Fields__c> allCustomSettings =[Select id, Object_Name__c, API_Name__c, JSON_Field_Name__c,
                                                             Order__c,Additional_Info__c from IPS_Case_Fields__c order by Order__c DESC ];
                
                
                for(IPS_Case_Fields__c  cc : allCustomSettings) {
                    if(cc.Object_Name__c == 'Case') {
                        fieldMap.put(cc.JSON_Field_Name__c, cc.API_Name__c);
                    }
                }
            }
        System.debug('Chiru caseStringList :'+ caseStringList);
        System.debug('Chiru userDetailsMap :'+ JSON.serialize(userDetailsMap));
        System.debug('Chiru fieldMap :'+ fieldMap);
            for(String caseString :caseStringList){
                Map<String,Object> stringJSONMap = (Map<String,Object>) JSON.deserializeUntyped(caseString);
                Map<String,Object> systemDetailsMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(stringJSONMap.get('system_details')));
                System.debug('Chiru stringJSONMap :'+ stringJSONMap);
                System.debug('Chiru systemDetailsMap :'+ systemDetailsMap);  
                System.debug('Chiru systemDetailsMap.keySet() :'+ systemDetailsMap.keySet()); 
                
              //  System.debug('systemDetailsMap: ' + systemDetailsMap);
              //  
                for(String inboundJSON: systemDetailsMap.keySet()){
                    
                    caseMap.put((String)systemDetailsMap.get('target_id'), JSON.serialize(stringJSONMap.get('issue_information')));  
                    revisionMap.put((String)systemDetailsMap.get('target_id'), (String)systemDetailsMap.get('backend_rev'));
                    sourceDetailsMap.put((String)systemDetailsMap.get('target_id'),(String)systemDetailsMap.get('source_id'));
                    
                    
                    system.debug('sourceDetailsMap'+sourceDetailsMap);**/
                    
                    /* Tejaswini Harpanhalli - DCG Custom Logic update case agent info */
              /*      Map<string,Object> issueInfoMap = (Map<string,Object>) JSON.deserializeUntyped(JSON.serialize(stringJSONMap.get('issue_information')));
                    String idsid = Core_IPS_BES_HSD_CustomLogic.getUsersFromIssueInfo(issueInfoMap, false);
                    if(idsid != null){
                        listIdSId.add(idsid);
                    } */
                ///} 
               
           /// }
            /*Tejaswini Harpanhalli - DCG Custom Logic comment Author update */
    	//    userDetailsMap = Core_IPS_BES_HSD_CustomLogic.getUserDetailsUsingIdSid(listIdSId);
         /** System.debug('caseMap' + caseMap);
            if(Case.SObjectType.getDescribe().isAccessible()){
                for(Case cs: [SELECT ID, casenumber, Core_IPS_BackendID__c FROM case WHERE caseNumber IN : caseMap.keySet()]){
                    if(!String.isBlank(cs.Core_IPS_BackendID__c)){
                        caseIdMap.put(cs.Id,caseMap.get(cs.casenumber));
                    }
                }
            } 

        System.debug('Chiru caseMap :'+ caseMap);
        System.debug('Chiru caseMap size :'+ caseMap.size()); 
        System.debug('Chiru revisionMap :'+ revisionMap);
        System.debug('Chiru revisionMap size :'+ revisionMap.size()); 
        System.debug('Chiru sourceDetailsMap :'+ sourceDetailsMap);
        System.debug('Chiru sourceDetailsMap size :'+ sourceDetailsMap.size());
        System.debug('Chiru caseIdMap :'+ caseIdMap);
        System.debug('Chiru caseIdMap size :'+ caseIdMap.size());
            List<case> caseListUpdate =  new List<case>();
            List<Id> caseIds = new List<Id>();
            
            Map<String, Map<String, Object>> caseIdToJSONFldMap = new Map<String, Map<String, Object>>();
            Map<String, String> caseIdToOwnerMap = new Map<String, String>();
            Set<String> fldsToQuery = new Set<String>();

            String sObjectFields = '';
            for(String caseId: caseIdMap.keySet()){                
                Map<String,Object> issueInformationMap = (Map<String,Object>) JSON.deserializeUntyped(caseIdMap.get(caseId));**/
                /* Tejaswini Harpanhalli for DCG Custom logic change - update agents infor */
              /**  system.debug('issueInformationMap'+issueInformationMap);
                if(issueInformationMap.containsKey('owner_info')) {
                    ownerInfo = (String)issueInformationMap.get('owner_info');
                    caseIdToOwnerMap.put(caseId, ownerInfo);
                }                
                
                Map<String,Object> apiJsonFeildMap = new Map<String,Object>();
                for(String caseField : issueInformationMap.keySet()){
                    if(fieldMap.get(caseField) !=null &&   ( issueInformationMap.get(caseField)!='' ||  caseField.equalsIgnoreCase('hsd_mirror_reason') || caseField.equalsIgnoreCase('case_closure')) ){
                        apiJsonFeildMap.put(fieldMap.get(caseField), issueInformationMap.get(caseField));
                        fldsToQuery.add(fieldMap.get(caseField));
                    }
                }
                caseIdToJSONFldMap.put(caseId, apiJsonFeildMap);                
                caseIds.add(caseId);
                System.debug('Chiru fldsToQuery :'+ fldsToQuery);
                System.debug('Chiru apiJsonFeildMap :'+ apiJsonFeildMap);
            }

            
           // sObjectFields = String.join(new List<String>(apiJsonFeildMap.keySet()),',');
           sObjectFields = String.join(new List<String>(fldsToQuery),',');
            
            List<Case> caseObjList = new List<case>();
            if(!String.isBlank(sObjectFields)){
                String soqlQueryEnv = 'SELECT '+ sObjectFields +',Core_IPS_New_Backend_System__c,Core_IPS_New_Backend_System__r.Name,Core_IPS_BackendID__c,Core_IPS_BES_Promote_Status__c,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c,CaseNumber FROM case WHERE Id IN:caseIds';
                system.debug('Chiru soqlQueryEnv :'+soqlQueryEnv);
                caseObjList = Database.Query(soqlQueryEnv);
            }
        System.debug('Chiru caseIdToOwnerMap :'+ caseIdToOwnerMap);
        System.debug('Chiru caseIdToOwnerMap size :'+ caseIdToOwnerMap.size());
        System.debug('caseIdToJSONFldMap :'+ caseIdToJSONFldMap);
        System.debug('caseObjList :'+ caseObjList);
            
            
            Schema.DescribeSObjectResult objectDescribe = caseObjList.getSObjectType().getDescribe();
            
           // System.debug('@@@ mirror apiJsonFeildMap.keySet() ' + apiJsonFeildMap.keySet());
            
            Map<String, Schema.SObjectField> fields = objectDescribe.fields.getMap();
            List<String> newList = new List<String>();
            for(Case caseObj: caseObjList){
                // Added by Pavani for checking if the current value of HSD Mirror Status/Reason on the case and status/reason on the HSD are same or not TWC745-5487 - 26/02/2024
                status = '';
                reason ='';
                isSameValue = false;
                Map<String,Object> apiJsonFeildMapForCaseObj = caseIdToJSONFldMap.get(caseObj.Id); 
            System.debug('Chiru apiJsonFeildMapForCaseObj :' + apiJsonFeildMapForCaseObj);
                
             //   if(String.ValueOf(caseObj.get('HSD_Mirror_Status__c')) != String.valueOf(apiJsonFeildMap.get('HSD_Mirror_Status__c')) || String.ValueOf(caseObj.get('HSD_Mirror_Reason__c')) != String.valueOf(apiJsonFeildMap.get('HSD_Mirror_Reason__c'))){
                if(String.ValueOf(caseObj.get('HSD_Mirror_Status__c')) != String.valueOf(apiJsonFeildMapForCaseObj.get('HSD_Mirror_Status__c')) || String.ValueOf(caseObj.get('HSD_Mirror_Reason__c')) != String.valueOf(apiJsonFeildMapForCaseObj.get('HSD_Mirror_Reason__c'))){
                    isSameValue = false;
                  
                }
                else{
                    isSameValue = true;     
                }// End by Pavani - TWC745-5487 - 26/02/2024
                for(String fieldAPI: apiJsonFeildMapForCaseObj.keySet()){
                    //ChandraShekar -- uncomment this code to use the support update feature for inbound message.
                    //Map<String, Map<String,Core_IPS_Backend_Field_Map__c>> backendMap = supportUpdate(caseObj.Core_IPS_New_Backend_System__c);**/
                    /*if(fieldAPI != null 
&& backendMap.containsKey((String)caseObj.Core_IPS_New_Backend_System__c) 
&& backendMap.get((String)caseObj.Core_IPS_New_Backend_System__c).get(fieldAPI).Support_Update__c
) {*/				
                    
                  /*  Schema.SObjectField field = fields.get(fieldAPI);
                    String fieldType = schemaDisplayTypeMapping(field);
                    switch on fieldType{
                        when 'String'{ 
                            if(fieldAPI == 'Core_Issue_Description__c'){
                               // caseObj.put(fieldAPI,  String.valueOf(apiJsonFeildMap.get(fieldAPI)).replaceAll('jpg','jpeg'));
                                caseObj.put(fieldAPI,  String.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI)).replaceAll('jpg','jpeg'));
                            }
                            else{
                             //   caseObj.put(fieldAPI,  String.valueOf(apiJsonFeildMap.get(fieldAPI)));
                                caseObj.put(fieldAPI,  String.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI)));
                            }
                            if(fieldAPI == 'HSD_Mirror_Status__c'){
                              //  status = String.valueOf(apiJsonFeildMap.get(fieldAPI));
                                status = String.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI));
                            }
                            if(fieldAPI == 'HSD_Mirror_Reason__c'){
                              //  reason = String.valueOf(apiJsonFeildMap.get(fieldAPI));
                                reason = String.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI));
                            }
                            
                        }
                        when 'Boolean'{
                          //  caseObj.put(fieldAPI,  Boolean.valueOf(apiJsonFeildMap.get(fieldAPI)));
                            caseObj.put(fieldAPI,  Boolean.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI)));
                        }
                        when 'Integer'{
                         //   caseObj.put(fieldAPI,  Integer.valueOf(apiJsonFeildMap.get(fieldAPI)));
                            caseObj.put(fieldAPI,  Integer.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI)));
                        }
                        when 'Double'{
                          //  caseObj.put(fieldAPI,  Double.valueOf(apiJsonFeildMap.get(fieldAPI)));
                            caseObj.put(fieldAPI,  Double.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI)));
                        }
                    }
                    //}
                }
                
                //commented by pavani if(String.ValueOf(caseObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')).equalsIgnoreCase('CC - HSDES Client Platform') && (status!='' || reason!='')){
                if((status!='' || reason!='') && isSameValue == false){ // Added by Pavani - TWC745-5487 - 26/02/2024
                    
                    Map<String,String> statusSubStatusValue = Core_IPS_BES_CCG_CustomLogic.processStatusReasonLogic(status,reason,String.ValueOf(caseObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')),String.ValueOf(caseObj.get('Id')));
                    if(statusSubStatusValue.containsKey('Status') && statusSubStatusValue.get('Status')!=''){
                        caseObj.put('Status',statusSubStatusValue.get('Status'));
                    }
                    if(statusSubStatusValue.containsKey('Core_Sub_Status__c')  && statusSubStatusValue.get('Core_Sub_Status__c')!=''){
                        caseObj.put('Core_Sub_Status__c',statusSubStatusValue.get('Core_Sub_Status__c'));
                    }
                    
                }**/
                /*Added by Tejaswini to update agent infor based on owner_info in inbound */
              /*  System.debug('Chiru wrap.caseIdToOwnerMap : '+ caseIdToOwnerMap);
                System.debug('Chiru caseObj.Id : '+ caseObj.Id);
                String newOwner = caseIdToOwnerMap.get(caseObj.Id);
                //if(ownerInfo != null && ownerInfo!= ''){
                if(newOwner != null && newOwner!= ''){
                 System.debug('Chiru newOwner : '+ newOwner);
                  //  List<String> authDetails = userDetailsMap.get(ownerInfo)?.split('-');
                    List<String> authDetails = userDetailsMap.get(newOwner)?.split(';');
                    if(authdetails != null ){
                        String agentEmail = (authDetails.size() >= 1 &&authDetails[0] !='null') ? authDetails[0] : NULL;
                        caseObj.put('Core_IPS_Backend_System_Agent_Email__c', agentEmail);        
                        String agentName = (authDetails.size() > 2 && authDetails[2] !='null') ? authDetails[2] : NULL;
                            caseObj.put('Core_IPS_Backend_System_Agent_Name__c', agentName);
                    }                       
                }  
                system.debug('sourceDetailsMap 111'+sourceDetailsMap);
               //Ajith added this logic to restrict the Case Update, when Backend system is deactivated
              if(caseObj.Core_IPS_New_Backend_System__c != null && caseObj.Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c ==false && caseObj.Core_IPS_BES_Promote_Status__c =='Done' && caseObj.Core_IPS_BackendID__c!= null && sourceDetailsMap.get(caseObj.CaseNumber)==caseObj.Core_IPS_BackendID__c){
                  caseListUpdate.add(caseObj);
              }
                
            }
            
            
            if(caseListUpdate.size()>0){
                if(Case.SObjectType.getDescribe().isUpdateable()){
                    
                    List<Database.SaveResult> results = Database.update(caseListUpdate,false);
                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()){
                            for (Database.Error err : result.getErrors()){	
                                try{
                                    throw new CustomException(err.getMessage());
                                }
                                catch(Exception e){
                                    Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, '400', String.join((Iterable<String>)caseIdMap.keySet(),','));
                                }  
                            }
                        }
                    }
                }
            }
            if(revisionMap != null){
                Core_IPS_BES_InboundMessage.updateRevision(revisionMap,sourceDetailsMap);
            }
            
        }catch(Exception e){
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join((Iterable<String>)caseIdMap.keySet(),','));     
        }
    }
    
    
    public static String schemaDisplayTypeMapping(Schema.SObjectField field){
        DescribeFieldResult fielddesc = field.getDescribe();
        DisplayType fieldType = fielddesc.getType();
        //Boolean canUpdate = fielddesc.isUpdateable();
        
        // if(canUpdate == FALSE)
        //   return 'NOT UPDATEABLE';    
        if(fieldType == Schema.DisplayType.String || 
           fieldType == Schema.DisplayType.TextArea ||
           fieldType == Schema.DisplayType.Id ||
           fieldType == Schema.DisplayType.Picklist)
            return 'String';
        if(fieldType == Schema.DisplayType.Integer)
            return 'Integer';
        if(fieldType == Schema.DisplayType.Boolean)
            return 'Boolean';            
        //if(fieldType == Schema.DisplayType.anytype)
        //     return 'anytype';                                  
        return 'UNKNOWN';    
    }*/
    
    // Chandrashekar -- This method prepares a MAP which will be used to check whether a backend system's field map record has support update.
    /*public static Map<String,Map<String,Core_IPS_Backend_Field_Map__c>> supportUpdate(String backendString) {
Map<String,Map<String,Core_IPS_Backend_Field_Map__c>> fieldMapping = new Map<String,Map<String,Core_IPS_Backend_Field_Map__c>>();
List<Core_IPS_Backend_Field_Map__c> mappingRecords = new List<Core_IPS_Backend_Field_Map__c>();
if(Core_IPS_Backend_Field_Map__c.SObjectType.getDescribe().isQueryable()){
mappingRecords =[SELECT Id, Core_IPS_New_Backend_System__c, Core_IPS_Direction__c, Core_IPS_Source_Field__c, Core_IPS_Target_Field__c,
Support_Update__c FROM Core_IPS_Backend_Field_Map__c 
WHERE Core_IPS_New_Backend_System__c =: backendString  AND Core_IPS_Direction__c = 'Inbound'];
}
if(!mappingRecords.isEmpty()){
for(Core_IPS_Backend_Field_Map__c fieldMapRec : mappingRecords){
if(fieldMapping.get((String)fieldMapRec.Core_IPS_New_Backend_System__c) == null){
fieldMapping.put((String)fieldMapRec.Core_IPS_New_Backend_System__c, new Map<String,Core_IPS_Backend_Field_Map__c>{(String)fieldMap.get(fieldMapRec.Core_IPS_Source_Field__c) => fieldMapRec});
} else {
fieldMapping.get((String)fieldMapRec.Core_IPS_New_Backend_System__c).putAll(new Map<String,Core_IPS_Backend_Field_Map__c>{(String)fieldMap.get(fieldMapRec.Core_IPS_Source_Field__c) => fieldMapRec});
}
}
}
return fieldMapping;
}*/
}




/*                                           XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                    */





/****************public class BES_UPDATE_Case {
    public class CustomException extends Exception {}
    public static Map<String,String> fieldMap = new Map<String, String>();
    public static void dataProcessing(List<String> caseStringList, Map<String, String> userDetailsMap){
        Map<String,List<String>> caseMap = new Map<String,List<String>>();
        Map<String,List<String>> caseIdMap = new Map<String,List<String>>();
        Map<String,String> revisionMap = new Map<String,String>();
        Map<String,String> sourceDetailsMap = new Map<String,String>();
        
        List<IPS_Case_Fields__c> allCustomSettings =[Select id, Object_Name__c, API_Name__c, JSON_Field_Name__c,Order__c,Additional_Info__c from IPS_Case_Fields__c order by Order__c DESC ];
        for(IPS_Case_Fields__c  cc : allCustomSettings) {
            if(cc.Object_Name__c == 'Case') {
                fieldMap.put(cc.JSON_Field_Name__c, cc.API_Name__c);
            }
        }
        System.debug('Chiru caseStringList :'+ caseStringList[0]);
        System.debug('Chiru caseStringList 1 :'+ caseStringList[1]);
        System.debug('Chiru userDetailsMap :'+ JSON.serialize(userDetailsMap));
        System.debug('Chiru fieldMap :'+ fieldMap);
        
        for(String caseString :caseStringList){
            Map<String,Object> stringJSONMap = (Map<String,Object>) JSON.deserializeUntyped(caseString);
            Map<String,Object> systemDetailsMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(stringJSONMap.get('system_details')));
            System.debug('Chiru stringJSONMap :'+ stringJSONMap);
            System.debug('Chiru systemDetailsMap :'+ systemDetailsMap);  
            System.debug('Chiru systemDetailsMap.keySet() :'+ systemDetailsMap.keySet()); 
            String targetId = (String)systemDetailsMap.get('target_id');
            for(String inboundJSON: systemDetailsMap.keySet()){
                // caseMap Preparation
                if (!caseMap.containsKey(targetId)) {
                    List<String> stringJSONList = new List<String>();
                    stringJSONList.add(JSON.serialize(stringJSONMap.get('issue_information')));
                    caseMap.put(targetId, stringJSONList);
                } else if(caseMap.get(targetId).contains(JSON.serialize(stringJSONMap.get('issue_information'))) == false){
                    caseMap.get(targetId).add(JSON.serialize(stringJSONMap.get('issue_information')));
                }    
                
                revisionMap.put((String)systemDetailsMap.get('target_id'), (String)systemDetailsMap.get('backend_rev'));
                sourceDetailsMap.put((String)systemDetailsMap.get('target_id'),(String)systemDetailsMap.get('source_id'));
                
               
}
            
            for(Case cs: [SELECT ID, casenumber, Core_IPS_BackendID__c FROM case WHERE caseNumber IN : caseMap.keySet()]){
                if(!String.isBlank(cs.Core_IPS_BackendID__c)){
                    caseIdMap.put(cs.Id,caseMap.get(cs.casenumber));
                }
            }
        }
        System.debug('Chiru caseMap :'+ caseMap);
        System.debug('Chiru caseMap size :'+ caseMap.size()); 
        System.debug('Chiru revisionMap :'+ revisionMap);
        System.debug('Chiru revisionMap size :'+ revisionMap.size()); 
        System.debug('Chiru sourceDetailsMap :'+ sourceDetailsMap);
        System.debug('Chiru sourceDetailsMap size :'+ sourceDetailsMap.size());
        System.debug('Chiru caseIdMap :'+ caseIdMap);
        System.debug('Chiru caseIdMap size :'+ caseIdMap.size());
        
        
        Map<String, Map<String, Object>> caseIdToJSONFldMap = new Map<String, Map<String, Object>>();
        //List<String> ownerInfo = new List<String>();
        Map<String, List<String>> caseIdToOwnerMap = new Map<String, List<String>>();
        Set<String> fldsToQuery = new Set<String>();
        Set<Id> caseIds = new Set<Id>();
        String sObjectFields = '';
        
        for(String caseRecordId: caseIdMap.keySet()){ 
            for(String item : caseIdMap.get(caseRecordId)){
                Map<String,Object> issueInformationMap = (Map<String,Object>) JSON.deserializeUntyped(item);
                List<String> ownerInfo = new List<String>();
                System.debug('issueInformationMap '+ issueInformationMap);
                // ISSUE
                if(issueInformationMap.containsKey('owner_info')) {
                    ownerInfo.add((String)issueInformationMap.get('owner_info'));
                    caseIdToOwnerMap.put(caseRecordId, ownerInfo);
                }  
                
                Map<String,Object> apiJsonFeildMap = new Map<String,Object>();
                for(String caseField : issueInformationMap.keySet()){
                    if(fieldMap.get(caseField) !=null &&   ( issueInformationMap.get(caseField)!='' ||  caseField.equalsIgnoreCase('hsd_mirror_reason') || caseField.equalsIgnoreCase('case_closure')) ){
                        apiJsonFeildMap.put(fieldMap.get(caseField), issueInformationMap.get(caseField));
                        fldsToQuery.add(fieldMap.get(caseField));
                    }
                }
                
                caseIdToJSONFldMap.put(caseRecordId, apiJsonFeildMap);
                caseIds.add(caseRecordId);
                System.debug('fldsToQuery :'+ fldsToQuery);
                System.debug('apiJsonFeildMap :'+ apiJsonFeildMap);
            }
        }
        sObjectFields = String.join(new List<String>(fldsToQuery),',');
        List<Case> caseObjList = new List<case>();
        
        if(!String.isBlank(sObjectFields)){
            String soqlQueryEnv = 'SELECT '+ sObjectFields +',Core_IPS_New_Backend_System__c,Core_IPS_New_Backend_System__r.Name,Core_IPS_BackendID__c,Core_IPS_BES_Promote_Status__c,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c,CaseNumber FROM case WHERE Id IN:caseIds';
            system.debug('Chiru soqlQueryEnv :'+soqlQueryEnv);
            caseObjList = Database.Query(soqlQueryEnv);
        }
        Wrapper wrap = new Wrapper();
        wrap.caseIdToJSONFldMap = caseIdToJSONFldMap;
        wrap.caseObjList = caseObjList;
        wrap.caseIdToOwnerMap = caseIdToOwnerMap;
        wrap.userDetailsMap = userDetailsMap;
        wrap.sourceDetailsMap = sourceDetailsMap;
        wrap.revisionMap = revisionMap;
        wrap.caseIdMap = caseIdMap;
        System.debug('Chiru caseIdToOwnerMap :'+ caseIdToOwnerMap);
        System.debug('Chiru caseIdToOwnerMap size :'+ caseIdToOwnerMap.size());
        System.debug('caseIdToJSONFldMap :'+ caseIdToJSONFldMap);
        System.debug('caseObjList :'+ caseObjList);
        updatecase(wrap); 
    } 
    
    Public Static Void updateCase(Wrapper wrap){
        Schema.DescribeSObjectResult objectDescribe = wrap.caseObjList.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> fields = objectDescribe.fields.getMap();
        List<String> newList = new List<String>();
        List<case> caseListUpdate =  new List<case>();
        for(Case caseObj: wrap.caseObjList){
            String status = '';
            String reason ='';
            Boolean isSameValue = false;
            Map<String,Object> apiJsonFeildMapForCaseObj = wrap.caseIdToJSONFldMap.get(caseObj.Id);  
            System.debug('Chiru apiJsonFeildMapForCaseObj :' + apiJsonFeildMapForCaseObj);
            
            if(String.ValueOf(caseObj.get('HSD_Mirror_Status__c')) != String.valueOf(apiJsonFeildMapForCaseObj.get('HSD_Mirror_Status__c')) || String.ValueOf(caseObj.get('HSD_Mirror_Reason__c')) != String.valueOf(apiJsonFeildMapForCaseObj.get('HSD_Mirror_Reason__c'))){
                isSameValue = false;  
            } else {
                isSameValue = true;     
            }
            
            for(String fieldAPI: apiJsonFeildMapForCaseObj.keySet()){
                Schema.SObjectField field = fields.get(fieldAPI);
                String fieldType = schemaDisplayTypeMapping(field);
                switch on fieldType{
                    when 'String'{ 
                        if(fieldAPI == 'Core_Issue_Description__c'){
                            caseObj.put(fieldAPI,  String.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI)).replaceAll('jpg','jpeg'));
                        }
                        else{
                            caseObj.put(fieldAPI,  String.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI)));
                        }
                        if(fieldAPI == 'HSD_Mirror_Status__c'){
                            status = String.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI));
                        }
                        if(fieldAPI == 'HSD_Mirror_Reason__c'){
                            reason = String.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI));
                        }
                        
                    }
                    
                    when 'Boolean'{
                        caseObj.put(fieldAPI,  Boolean.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI)));
                    }
                    when 'Integer'{
                        caseObj.put(fieldAPI,  Integer.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI)));
                    }
                    when 'Double'{
                        caseObj.put(fieldAPI,  Double.valueOf(apiJsonFeildMapForCaseObj.get(fieldAPI)));
                    }}
            }
            
            if((status!='' || reason!='') && isSameValue == false){
                Map<String,String> statusSubStatusValue = Core_IPS_BES_CCG_CustomLogic.processStatusReasonLogic(status,reason,String.ValueOf(caseObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')),String.ValueOf(caseObj.get('Id')));
                if(statusSubStatusValue.containsKey('Status') && statusSubStatusValue.get('Status')!=''){
                    caseObj.put('Status',statusSubStatusValue.get('Status'));
                }
                if(statusSubStatusValue.containsKey('Core_Sub_Status__c')  && statusSubStatusValue.get('Core_Sub_Status__c')!=''){
                    caseObj.put('Core_Sub_Status__c',statusSubStatusValue.get('Core_Sub_Status__c'));
                }
            }
            // Same Case so Owner Will be same , List Not Required
            System.debug('Chiru wrap.caseIdToOwnerMap : '+ wrap.caseIdToOwnerMap);
            System.debug('Chiru caseObj.Id : '+ caseObj.Id);
            List<String> newOwnerList = new List<String>();
            if(wrap.caseIdToOwnerMap.get(caseObj.Id) != null){
                newOwnerList.add(wrap.caseIdToOwnerMap.get(caseObj.Id)[0]);
            }
            System.debug('Chiru newOwnerList : '+ newOwnerList);
            String newOwner;
            if(newOwnerList.size()>0){
             newOwner = newOwnerList[0];
            }
            System.debug('Chiru newOwner : '+ newOwner);
            
            if(newOwner != null && newOwner!= '' && wrap.userDetailsMap != null){
             List<String> authDetails = wrap.userDetailsMap.get(newOwner)?.split(';');
               if(authdetails != null ){
                  String agentEmail = (authDetails.size() >= 1 &&authDetails[0] !='null') ? authDetails[0] : NULL;
                  caseObj.put('Core_IPS_Backend_System_Agent_Email__c', agentEmail);        
                  String agentName = (authDetails.size() > 2 && authDetails[2] !='null') ? authDetails[2] : NULL;
                  caseObj.put('Core_IPS_Backend_System_Agent_Name__c', agentName);
                    }                       
                } 
            //backendId Same thats why Index 0
            if(caseObj.Core_IPS_New_Backend_System__c != null && caseObj.Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c ==false && caseObj.Core_IPS_BES_Promote_Status__c =='Done' && caseObj.Core_IPS_BackendID__c!= null && wrap.sourceDetailsMap.get(caseObj.CaseNumber)==caseObj.Core_IPS_BackendID__c){
                  caseListUpdate.add(caseObj);
            } 
        }
        
        if(caseListUpdate.size()>0){
                if(Case.SObjectType.getDescribe().isUpdateable()){
                    
                    List<Database.SaveResult> results = Database.update(caseListUpdate,false);
                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()){
                            for (Database.Error err : result.getErrors()){	
                                try{
                                    throw new CustomException(err.getMessage());
                                }
                                catch(Exception e){
                                    Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, '400', String.join((Iterable<String>)wrap.caseIdMap.keySet(),','));
                                }  
                            }
                        }
                    }
                }
            }
            if(wrap.revisionMap != null){
               Core_IPS_BES_InboundMessage.updateRevision(wrap.revisionMap,wrap.sourceDetailsMap);
               
            }
    }
  
    
    
    public class Wrapper {
        Public  Map<String, String> userDetailsMap;
        public Map<String, String> revisionMap;
        public Map<String, List<String>> caseIdMap;
        public Map<String, List<String>> caseIdToOwnerMap;
        public Map<String, String> sourceDetailsMap;
        public Map<String, Map<String, Object>> caseIdToJSONFldMap;
        List<Case> caseObjList;
        
    }
    public static String schemaDisplayTypeMapping(Schema.SObjectField field){
        DescribeFieldResult fielddesc = field.getDescribe();
        DisplayType fieldType = fielddesc.getType();    
        if(fieldType == Schema.DisplayType.String || 
           fieldType == Schema.DisplayType.TextArea ||
           fieldType == Schema.DisplayType.Id ||
           fieldType == Schema.DisplayType.Picklist)
            return 'String';
        if(fieldType == Schema.DisplayType.Integer)
            return 'Integer';
        if(fieldType == Schema.DisplayType.Boolean)
            return 'Boolean';            
        
        return 'UNKNOWN';    
    }
} *******************************/