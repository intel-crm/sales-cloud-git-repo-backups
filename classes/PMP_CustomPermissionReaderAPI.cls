public with sharing class PMP_CustomPermissionReaderAPI {
    
    public static SObjectType managedObject;
    
    public static Set<String> customPermissionNames;
    
    public static Set<String> customPermissionsForCurrentUser;
    
    /**
* This default constructor will seek out all unmanaged/default namespace Custom Permissions 
**/
    /*public PMP_CustomPermissionReaderAPI() {
this(null);
}*/
    
    /**
* This constructor will load Custom Permissions associated with the namespace of the object passed in,
*   this is the best constructor to use if you are developing a managed AppExchange package! The object 
*   passed in does not matter so long as its one from the package itself.
*
*   If the object is running in a managed context (e.g. packaging org or installed package) namespace is used to constrain the query 
*   If the object is not running in a managed context (e.g. developer org not namespaced) the default namespace is used to query
**/
    /*public PMP_CustomPermissionReaderAPI(SObjectType managedObject) {
this.managedObject = managedObject;
}*/
    
    public static Map<String, Boolean> hasPermission(List<String> customPermissionNamesList, User usr) {
        
        Map<String, Boolean> assignedPermissionSetMap = new Map<String, Boolean>();
        // Demand load the custom permissions from the database?        
        if(customPermissionNames==null)
            checkPermission(usr);
        // Is this a valid custom permission name?
        for(String customPermissionName : customPermissionNamesList){
            if(customPermissionsForCurrentUser.contains(customPermissionName)){
                assignedPermissionSetMap.put(customPermissionName, true); 
            }
        }
        // Has this user been assigned this custom permission?
        return assignedPermissionSetMap;
    }
    
    /**
* Loads Custom Permissions sets for either the default namespace or 
*   the current namespace context (derived from the managed object reference)
**/
    public static void checkPermission(User usr) {
        
        customPermissionNames = new Set<String>();
        customPermissionsForCurrentUser = new Set<String>();
        
        // Determine the namespace context for the custom permissions via the SObject passed in?
        String namespacePrefix = null;
        /*if(managedObject!=null) {
DescribeSObjectResult describe = managedObject.getDescribe();
String name = describe.getName();
String localName = describe.getLocalName();
namespacePrefix = name.removeEnd(localName).removeEnd('__');
}*/
        
        // Query the full set of Custom Permissions for the given namespace
        Map<Id, String> customPermissionNamesById = new Map<Id, String>();
        List<CustomPermission> customPermissions = 
            [select Id, DeveloperName from CustomPermission where NamespacePrefix = :namespacePrefix];
        for(CustomPermission customPermission : customPermissions) {
            customPermissionNames.add(customPermission.DeveloperName);
            customPermissionNamesById.put(customPermission.Id, customPermission.DeveloperName);
        }
        
        System.debug('customPermissionNamesById = '+ customPermissionNamesById);
        
        // Query to determine which of these custome settings are assigned to this user
        
        List<SetupEntityAccess> setupEntities = 
            [SELECT SetupEntityId
             FROM SetupEntityAccess
             WHERE SetupEntityId in :customPermissionNamesById.keySet() AND
             ParentId
             IN (SELECT PermissionSetId 
                 FROM PermissionSetAssignment
                 WHERE AssigneeId = :usr.Id)];  /*'0050n000002XO02'*/
        for(SetupEntityAccess setupEntity : setupEntities)
            customPermissionsForCurrentUser.add(customPermissionNamesById.get(setupEntity.SetupEntityId));
        
    }
    
    public class CustomPermissionsException extends Exception {}
    
}