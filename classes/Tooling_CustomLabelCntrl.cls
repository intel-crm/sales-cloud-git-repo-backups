public without sharing class Tooling_CustomLabelCntrl {
    static Map<String, String> customLabels = new Map<String, String>();
    static String nextURL=null;
    static integer counter = 0;
    static Boolean queryMore = false;
    
    @AuraEnabled
    public static List<String> getApexClassNames(){
        List<String> apexclassNmlst = new List<String>();
        try{
            for( ApexClass apx : [select Name from apexclass where namespaceprefix = null order by name asc]){
                apexclassNmlst.add(apx.Name);
            }}catch(Exception ex){System.debug('Error -->'+ex.getMessage());}
        return apexclassNmlst;
    }
    
    @AuraEnabled
    public static List<Tooling_CustomLabelWrapper> getApexBody(String className){
        List<Tooling_CustomLabelWrapper> resourceList = new List<Tooling_CustomLabelWrapper>();
        try{
            for(apexclass apexbody : [select body, Name from apexclass where NamespacePrefix = null and name >=:className limit 1000]){
                resourceList.add(returnWrapper(apexbody.body, apexbody.Name, 'ApexClass'));
            }}catch(Exception ex){System.debug('Error -->'+ex.getMessage());}
        
        return resourceList;
    }
    @AuraEnabled
    public static List<Tooling_CustomLabelWrapper> getApexTriggerBody(){
        List<Tooling_CustomLabelWrapper> resourceList = new List<Tooling_CustomLabelWrapper>();
        try{
            for(ApexTrigger triggerBody : [select body,Name from ApexTrigger where NamespacePrefix = null]){
                resourceList.add(returnWrapper(triggerBody.body, triggerBody.Name,'ApexTrigger'));
            }}catch(Exception ex){System.debug('Error -->'+ex.getMessage());}
        return resourceList;
    }
    
    @AuraEnabled
    public static List<Tooling_CustomLabelWrapper> getApexPageBody(){
        List<Tooling_CustomLabelWrapper> resourceList = new List<Tooling_CustomLabelWrapper>();
        try{
            for(ApexPage pagebody : [select Markup,Name from ApexPage where NamespacePrefix = null]){
                resourceList.add(returnWrapper(pagebody.markup, pagebody.Name, 'ApexPage'));
            }}catch(Exception ex){System.debug('Error -->'+ex.getMessage());}
        return resourceList;
    }
    
    @AuraEnabled
    public static List<Tooling_CustomLabelWrapper> getAuraCmpBody(){
        List<Tooling_CustomLabelWrapper> resourceList = new List<Tooling_CustomLabelWrapper>();
        try{
            for(AuraDefinition aurabody : [select Source,AuraDefinitionBundle.DeveloperName,DefType from AuraDefinition where AuraDefinitionBundle.NamespacePrefix = null]){
                resourceList.add(returnWrapper(aurabody.Source,aurabody.AuraDefinitionBundle.DeveloperName, auraBody.DefType));
            }}catch(Exception ex){System.debug('Error -->'+ex.getMessage());}
        return resourceList;
    }
    
    public static Tooling_CustomLabelWrapper returnWrapper(String body,String Name, String cmpType){
        Tooling_CustomLabelWrapper tc = new Tooling_CustomLabelWrapper();
        tc.source = body.toLowerCase();tc.MetadataComponentName = Name;
        tc.MetadataComponentType = cmpType;
        return tc;
    }
    
    @AuraEnabled
    public static List<String> getLWCNames(){
        List<String> resourceList = new List<String>();
        try{
            HttpRequest req = createToolingAPIRequest('query?q=select+DeveloperName+from+LightningComponentBundle+where+namespaceprefix+=+null', 'GET', false);
            HttpResponse response = sendToolingAPIRequest(req);
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<String> lwcBody = new list<String>();
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for (Object obj : records) {
                Map<String, Object> objectMap = (Map<String, Object>) obj;
                String source = (String) objectMap.get('DeveloperName');resourceList.add(source);
            }}catch(Exception ex){System.debug('Error -->'+ex.getMessage());}
        return resourceList;
    }
    
    
    @AuraEnabled
    public static List<Tooling_CustomLabelWrapper> getLWCResource(List<String> lwcNames){
        List<Tooling_CustomLabelWrapper> resourceList = new List<Tooling_CustomLabelWrapper>();
        String names = buildNameList(lwcNames);
        try{
            HttpRequest req = createToolingAPIRequest('query?q=select+Source+,LightningComponentBundle.DeveloperName+from+LightningComponentResource+where+LightningComponentBundle.NamespacePrefix+=+null+and+LightningComponentBundle.developername+in'+names, 'GET', false);
            HttpResponse response = sendToolingAPIRequest(req);
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<String> lwcBody = new list<String>();
            List<Object> records = (List<Object>) jsonResponse.get('records');        
            while(true){
                System.debug('Counter -->'+counter);
                counter++;
                if (jsonResponse.containsKey('nextRecordsUrl') && !String.isBlank((String) jsonResponse.get('nextRecordsUrl'))) {
                    nextURL=null;nextURL = (String) jsonResponse.get('nextRecordsUrl');
                    
                    records.addAll((List<Object>) jsonResponse.get('records'));req = createToolingAPIRequest(nextURL, 'GET', true);
                    response = sendToolingAPIRequest(req);jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    
                    System.debug('nextURL -->'+nextURL);
                    
                } else {
                    records.addAll((List<Object>) jsonResponse.get('records'));
                    for (Object obj : records) {
                        
                        Map<String, Object> objectMap = (Map<String, Object>) obj;String source = (String) objectMap.get('Source');
                        Map<String, Object> lightningComponentBundle = (Map<String, Object>) objectMap.get('LightningComponentBundle');
                        String developerName = (String) lightningComponentBundle.get('DeveloperName');resourceList.add(returnWrapper(source, developerName, 'LightningComponentBundle'));
                    }
                    break;
                }
            }}catch(Exception ex){System.debug('Error -->'+ex.getMessage());}
        return resourceList;
    }
    
    
    @AuraEnabled
    public static List<Tooling_FieldwrapperClass> getCustomLabels() {
        try{
            HttpRequest req = createToolingAPIRequest('query?q=select+name+,id+from+ExternalString+where+NamespacePrefix+=+null', 'GET', false);
            HttpResponse response = sendToolingAPIRequest(req);
            
            
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            
            
            while(true){
                System.debug('Counter -->'+counter);
                counter++;
                if (jsonResponse.containsKey('nextRecordsUrl') && !String.isBlank((String) jsonResponse.get('nextRecordsUrl'))) {
                    nextURL=null;
                    nextURL = (String) jsonResponse.get('nextRecordsUrl');
                    
                    records.addAll((List<Object>) jsonResponse.get('records'));
                    req = createToolingAPIRequest(nextURL, 'GET', true);response = sendToolingAPIRequest(req);
                    jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    System.debug('nextURL -->'+nextURL);
                    
                } else {
                    records.addAll((List<Object>) jsonResponse.get('records'));
                    for (Object obj : records) {
                        Map<String, Object> objectMap = (Map<String, Object>) obj;customLabels.put((String) objectMap.get('Id'), (String) objectMap.get('Name'));
                    }
                    break;
                }
            }}catch(Exception ex){System.debug('Error -->'+ex.getMessage());}
        
        
        
        return findUnusedCustomLabels(customLabels);
    }
    
    public static List<Tooling_FieldwrapperClass> findUnusedCustomLabels(Map<String, String> customLabels) {
        List<Tooling_FieldwrapperClass> instanceList = new List<Tooling_FieldwrapperClass>();
        try{
            HttpRequest req = createToolingAPIRequest('query?q=select+Id+,RefMetadataComponentId+from+MetadataComponentDependency', 'GET', false);
            HttpResponse response = sendToolingAPIRequest(req);
            
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> records = (List<Object>) jsonMap.get('records');
            
            for (Object obj : records) {
                Map<String, Object> objectMap = (Map<String, Object>) obj;
                String refMetadataComponentId = (String) objectMap.get('RefMetadataComponentId');
                if (customLabels.containsKey(refMetadataComponentId)) {customLabels.remove(refMetadataComponentId);}
            }
            
            
            
            for (String key : customLabels.keySet()) {
                Tooling_FieldwrapperClass fwc = new Tooling_FieldwrapperClass();
                fwc.Id = key;
                fwc.labelName = customLabels.get(key);
                instanceList.add(fwc);
            }}catch(Exception ex){System.debug('Error -->'+ex.getMessage());}
        
        return instanceList;
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
    private static String buildNameList(List<String> LWCNames) {
        String nameList = '(';
        for (Integer i = 0; i < LWCNames.size(); i++) {
            String name = LWCNames[i];
            nameList += '\'' + name + '\'';
            if (i < LWCNames.size() - 1 && i <2000)  {
                nameList += ',';
            }
            
        }
        nameList += ')';
        return nameList;
    }
    
    
}