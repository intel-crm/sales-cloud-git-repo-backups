public class Tooling_CustomFieldsCntrl {
    static List<String> recordIds = new List<String>();
    static String nextURL=null;
    
    static Boolean queryMore = false;
    
    
    @AuraEnabled
    public static List<String> getCustomFieldIds() {
        
        HttpRequest req = createToolingAPIRequest('query?q=select+id+from+CustomField+where+NamespacePrefix+=+null', 'GET', false);
        HttpResponse response = sendToolingAPIRequest(req);
        System.debug(' -->'+JSON.serialize(response.getBody()));
        
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> records = (List<Object>) jsonResponse.get('records');
        
        // Check if there are more records to fetch
        while(true){
            
            
            if (jsonResponse.containsKey('nextRecordsUrl') && !String.isBlank((String) jsonResponse.get('nextRecordsUrl'))) {
                nextURL=null;
                nextURL = (String) jsonResponse.get('nextRecordsUrl');
                
                req = createToolingAPIRequest(nextURL, 'GET', true);
                response = sendToolingAPIRequest(req);
                jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                records.addAll((List<Object>) jsonResponse.get('records'));
                System.debug('nextURL -->'+nextURL);
                
            } else {
                records.addAll((List<Object>) jsonResponse.get('records'));
                for (Object obj : records) {
                    Map<String, Object> objectMap = (Map<String, Object>) obj;
                    recordIds.add((String) objectMap.get('Id'));
                }
                break;
            }
        }
        
        return recordIds;
    }
    
    
    
    @AuraEnabled
    public static List<Tooling_FieldwrapperClass> getUnusedFields(List<String> fieldIds) {
        String ids = buildIdList(fieldIds);
        
        Map<String, Boolean> refMap = new Map<String, Boolean>();
        
        for (String fieldId : fieldIds) {
            refMap.put(fieldId, true);
        }
        
        HttpRequest req = createToolingAPIRequest('query?q=select+Id+,MetadataComponentId+,MetadataComponentNamespace+,MetadataComponentName+,MetadataComponentType+,RefMetadataComponentId+,RefMetadataComponentNamespace+,RefMetadataComponentName+,RefMetadataComponentType+from+MetadataComponentDependency+where+RefMetadataComponentId+in' + ids, 'GET', false);
        HttpResponse res = sendToolingAPIRequest(req);
        
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> relatedLists = (List<Object>) jsonResponse.get('records');
        List<Tooling_FieldwrapperClass> fieldWrapperList = new List<Tooling_FieldwrapperClass>();
        
        for (Object obj : relatedLists) {
            Map<String, Object> mapRelatedList = (Map<String, Object>) obj;
            String refMetadataComponentId = (String) mapRelatedList.get('RefMetadataComponentId');
            
            if (refMap.containsKey(refMetadataComponentId)) {
                refMap.put(refMetadataComponentId, false);
            }
            
            Tooling_FieldwrapperClass wrap = new Tooling_FieldwrapperClass();
            wrap.FieldName = (String) mapRelatedList.get('RefMetadataComponentName');
            wrap.OwnerName = (String) mapRelatedList.get('CreatedBy.Name');
            wrap.componentType = (String) mapRelatedList.get('MetadataComponentType');
            
            if (mapRelatedList.containsKey('EntityDefinition')) {
                Map<String, Object> objectNameMp = (Map<String, Object>) mapRelatedList.get('EntityDefinition');
                wrap.ObjectName = (String) objectNameMp.get('DeveloperName');
            }
            
            fieldWrapperList.add(wrap);
        }
        
        List<Id> unusedCustomFieldIds = new List<Id>();
        
        for (String fieldId : refMap.keySet()) {
            if (refMap.get(fieldId)) {
                unusedCustomFieldIds.add(fieldId);
            }
        }
        
        return getUnusedFieldDetails(unusedCustomFieldIds);
    }
    
    @AuraEnabled
    public static List<Tooling_FieldwrapperClass> getUnusedFieldDetails(List<Id> customFieldIds) {
        String ids = buildIdList(customFieldIds);
        
        HttpRequest req = createToolingAPIRequest('query?q=select+id+,DeveloperName+,EntityDefinition.Label+,EntityDefinition.DeveloperName+from+CustomField+where+id+in' + ids, 'GET', false);
        HttpResponse response = sendToolingAPIRequest(req);
        List<Tooling_FieldwrapperClass> fieldWrapperList = new List<Tooling_FieldwrapperClass>();
        
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> records = (List<Object>) jsonResponse.get('records');
        
        for (Object obj : records) {
            Tooling_FieldwrapperClass fieldWrapper = new Tooling_FieldwrapperClass();
            Map<String, Object> objectMap = (Map<String, Object>) obj;
            
            fieldWrapper.Id = (String) objectMap.get('Id');
            fieldWrapper.fieldURL = '/' + fieldWrapper.Id;
            fieldWrapper.FieldName = (String) objectMap.get('DeveloperName');
            
            if (objectMap.containsKey('EntityDefinition')) {
                Map<String, Object> objectDetails = (Map<String, Object>) objectMap.get('EntityDefinition');
                if (objectDetails != null && objectDetails.containsKey('Label')) {
                    fieldWrapper.ObjectName = (String) objectDetails.get('Label');
                    fieldWrapper.objectAPIName = (String) objectDetails.get('DeveloperName');
                }
            }
            
            fieldWrapperList.add(fieldWrapper);
        }
        
        return fieldWrapperList;
    }
    
    private static HttpRequest createToolingAPIRequest(String path, String method, Boolean recall) {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer {!$ToolingAPI.OAuthToken}');
        if(recall){
            req.setEndpoint('callout:ToolingAPI' + path);    
        }else{
            req.setEndpoint('callout:ToolingAPI/services/data/v56.0/tooling/' + path);
        }
        
        req.setMethod(method);
        return req;
    }
    
    private static HttpResponse sendToolingAPIRequest(HttpRequest request) {
        Http http = new Http();
        return http.send(request);
    }
    
    private static String buildIdList(List<String> ids) {
        String idList = '(';
        for (Integer i = 0; i < ids.size(); i++) {
            String id = ids[i];
            idList += '\'' + id + '\'';
            if (i < ids.size() - 1 && i <2000)  {
                idList += ',';
            }
            
        }
        idList += ')';
        return idList;
    }
    
    
}