/** **************************************************************
ClassName: Core_IPS_InternalCaseExport --- DeveloperName: Minhaj Ameen Created Date: 09/10/22

Description: controller for LWC case_List_Export component to handle case list export in Lex
************************************************************************** **/ 
public with sharing class Core_IPS_InternalCaseExport {
    
    public static String strQuery; 
    
    @AuraEnabled
    public static ResultWrapper getListViewOptions(String strfilterId){
        String queryStr;
        if(strfilterId == null || strfilterId == ''){
            ListView recentlyViewList = [SELECT Id, Name, DeveloperName FROM ListView where SobjectType= 'Case' and  DeveloperName = 'RecentlyViewedCases' ];
             queryStr = recentlyViewList.id;
        }else{
            queryStr = String.escapeSingleQuotes(strfilterId);
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CaseExportToPDF/services/data/v54.0/sobjects/Case/listviews/'+ queryStr + '/describe');
        req.setMethod('GET');      
        Http h = new Http();
        HttpResponse res = h.send(req);
        //Exception Handline for : Invalid conversion from runtime type List<ANY> to Map<String,ANY> -Phani
        ResultWrapper result = new ResultWrapper();
        if(res.getStatusCode() == 200){
            Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());     
            strQuery = (String)root.get('query') + ' LIMIT 10000';
            strQuery.replaceAll('SystemModstamp,', '');
            List<sObject> lstSObj = Database.Query(strQuery);
            Map<String, String> fieldNameToLabelMap = getFieldNameToLabelMap();        
            result.sObjectList = lstSObj;
            result.fieldNameToLabelMap = fieldNameToLabelMap;             
        }
        return result;
    } 
    
    public static Map<String, String> getFieldNameToLabelMap() {
        Map<String, String> fieldNameToLabelMap = new Map<String, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Case');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            fieldNameToLabelMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
        }
        return fieldNameToLabelMap;
    }
    
    @AuraEnabled
    public static String getRecentlyViewListCaseId(){
        ListView recentlyViewList = [SELECT Id, Name, DeveloperName FROM ListView where SobjectType= 'Case' and  DeveloperName = 'RecentlyViewedCases' ];
        return recentlyViewList.Id;
    }
    
    public class ResultWrapper {
        @AuraEnabled
        public List<sObject> sObjectList;
        @AuraEnabled
        public Map<String, String> fieldNameToLabelMap;
    }
}