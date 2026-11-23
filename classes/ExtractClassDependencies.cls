public with sharing class ExtractClassDependencies {
    
/* ----------------------------------------------------------------
* @Description
* The method findClsWithDependency() is used for calling the Tooling API which in turn returns a list of classes that are referenced elsewhere.
* Used in method findReferencedClasses() 
*-----------------------------------------------------------------------
*/
private ApexDependencyWrapper findClsWithDependency(){
    ApexDependencyWrapper classesWithDependency = new ApexDependencyWrapper(); 
    Http httpProtocol = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+
                    '/services/data/v47.0/tooling/query/?q='+
                    'SELECT+RefMetadataComponentName'+
                    '+FROM+MetadataComponentDependency'+
                    '+WHERE+RefMetadataComponentType=\'ApexClass\'');
    req.setMethod('GET');
    req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
    HttpResponse resp = httpProtocol.send(req);
    classesWithDependency  = (ApexDependencyWrapper) JSON.deserialize(resp.getBody(), ApexDependencyWrapper.Class);
    return classesWithDependency; 
}  


/* ----------------------------------------------------------------
* @Description
* The method findReferencedClasses() finds all classes which are referenced by another class (excluding test classes because they do not count against org char limit) 
* we are assuming here that the test classes in your org contain the 'test' keyword in their name.
* Used in method findUnreferencedClasses()
*-----------------------------------------------------------------------
*/
private set<String> findReferencedClasses(){   
    ApexDependencyWrapper classesWithDependency = new ApexDependencyWrapper(); 
    classesWithDependency = findClsWithDependency(); 
    set<String> classesReferenced = new set<String>();
    for(DependencyRecords apexDepRec : classesWithDependency.records){      
        if(apexDepRec.RefMetadataComponentName != null && !apexDepRec.RefMetadataComponentName.containsIgnoreCase('test') ){ 
            classesReferenced.add(apexDepRec.RefMetadataComponentName);
        }
    }
    system.debug(classesReferenced);
    return classesReferenced; 
}

/* ----------------------------------------------------------------
* @Description
* The method findUnreferencedClasses() finds all classes that are not referenced in the org  
* It is used to check if all classes apart from the classes containing any of the keywords supplied by the parameter are present in classesReferenced set 
* if not then add the class inside classesNotReferenced set.
*-----------------------------------------------------------------------
*/
public Void findUnreferencedClasses(String ignoreUnrefClsParam){    
      set<String> classesReferenced = findReferencedClasses();  
    //fetch all the custom classes (not from managed packages)
    list<ApexClass> allClasses = [select Name from ApexClass where NamespacePrefix = null limit 10000];
    set<String> classesNotReferenced = new set<String>();
    for(ApexClass apexName : allClasses){
        if(!classesReferenced.contains(apexName.Name) && ignoreUnrefClsTypes(apexName.Name, ignoreUnrefClsParam) ){ 
            system.debug('Class with no references--- '+ apexName.Name);        
            classesNotReferenced.add(apexName.Name);
        }
    }
    system.debug('Classes with no references rows ' + classesNotReferenced.size());
    
}   

/* ----------------------------------------------------------------
* @Description
* The helper method ignoreUnrefClsTypes() is used to check if any of the keywords supplied by the parameter in findUnreferencedClasses()
* is present in the class name - if not then return true.
* Used in method findUnreferencedClasses()
*-----------------------------------------------------------------------
*/
private Boolean ignoreUnrefClsTypes(String clsName, String ignoreUnrefClsParam){    
    list<String> ignoreUnrefCls = ignoreUnrefClsParam.split(',');    
    list<String> result = new list<String>(); 
    for(String clsTypes : ignoreUnrefCls){
        if(!clsName.containsIgnoreCase(clsTypes) ){
            result.add('true');
        }else{
            result.add('false');
        }
    }      
    Boolean output = result.contains('false') ? false : true;
    return output; 
}

/* ----------------------------------------------------------------
* @Description
* The wrapper classes ApexDependencyWrapper and DependencyRecords are used to deserialize the response from Tooling API query.
* Used in method findClsWithDependency() 
*-----------------------------------------------------------------------
*/

private class ApexDependencyWrapper { 
    private list<DependencyRecords> records = new list<DependencyRecords>(); 
}

private class DependencyRecords{
    private String RefMetadataComponentName; 
    private String MetadataComponentName; 
}

}