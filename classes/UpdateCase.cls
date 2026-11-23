//under - development - Chandrashekar
public with sharing class UpdateCase {
    public static Map<String,String> fieldMap = new Map<String, String>();
    public static void caseUpdate(List<String> caseDetails){
        Map<String, String> additionalInfoMap = new Map<String, String >();
        Map<String,String> fieldMapEnv = new Map<String, String>();
        Map<String,String> caseMap = new Map<String,String>();
        Map<String,String> caseIdMap = new Map<String,String>();
        List<IPS_Case_Fields__c> allCustomSettings = new List<IPS_Case_Fields__c>();
        try{
            if(IPS_Case_Fields__c.SObjectType.getDescribe().isQueryable()){
                allCustomSettings =[Select id, Object_Name__c, API_Name__c, JSON_Field_Name__c,
                                    Order__c,Additional_Info__c from IPS_Case_Fields__c order by Order__c DESC ];
            }
            for(IPS_Case_Fields__c  cc : allCustomSettings) {
                if(cc.Object_Name__c == 'Case'){
                    fieldMap.put(cc.JSON_Field_Name__c, cc.API_Name__c);
                }
            }
            for(String caseString :caseDetails){
                Map<String,Object> stringJSONMap = (Map<String,Object>) JSON.deserializeUntyped(caseString);
                Map<String,Object> systemDetailsMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(stringJSONMap.get('system_details')));
                for(String inboundJSON: systemDetailsMap.keySet()){
                    caseMap.put((String)systemDetailsMap.get('target_id'), JSON.serialize(stringJSONMap.get('issue_information')));  
                }
            }
            for(Case cs: [SELECT ID, casenumber, Core_IPS_BackendID__c FROM case WHERE caseNumber IN : caseMap.keySet()]){
                caseIdMap.put(cs.Id,caseMap.get(cs.casenumber));
            } 
            Map<String,Map<String,Object>> issueInformationMap = new Map<String,Map<String,Object>>();
            Map<String,Map<String,Object>> apiJsonFeildMap = new Map<String,Map<String,Object>>();
            for(String caseId: caseIdMap.keySet()){
                issueInformationMap.put(caseId, (Map<String,Object>) JSON.deserializeUntyped(caseIdMap.get(caseId)));
            }
            for(String caseId : caseIdMap.keySet()){
                for(String caseField : issueInformationMap.get(caseId).keySet()){
                    apiJsonFeildMap.put(caseId, new Map<String,Object>{fieldMap.get(caseField) => issueInformationMap.get(caseId).get(caseField)});
                }
            }
            String sObjectFields = '';
            String soqlQueryEnv = '';
            List<Case> caseObjList = new List<Case>(); 
            for(String caseId : caseIdMap.keySet()){
                sObjectFields = String.join(new List<String>(apiJsonFeildMap.get(caseId).keySet()),',');
            }
            soqlQueryEnv = 'SELECT '+ sObjectFields +',Core_IPS_New_Backend_System__c FROM case WHERE Id IN:'+caseIdMap.keySet();
            caseObjList = Database.Query(soqlQueryEnv);
            Schema.DescribeSObjectResult objectDescribe = caseObjList.getSObjectType().getDescribe();
            Map<String, Schema.SObjectField> fields = objectDescribe.fields.getMap();
            for(Case caseObj: caseObjList){
                
            }
        } catch(Exception e){
            
        }
    }
}