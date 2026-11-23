@isTest 
public with sharing class Core_MDF_PPSM_Test {
    @isTest
    public static void testgetAllObjects() {
        
        List<ObjectPermissions> objPermissions= Core_MDF_PPSM.getAllObjects();
        
        System.assert(objPermissions.size() > 0,'Invalid Object Permissions');
    }
    
    @isTest
    public static void testgetFields() {
        
        String fields= Core_MDF_PPSM.getFields('Account');
        
        System.assert(fields != '[]' ,'Not Able to find fields for giving FLS in Account Object');
        
        //Exception Testing
        try{
            Core_MDF_PPSM.getFields('Account1');
        }
        catch(exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
    }   
    
    @isTest
    public static void testgetObjectPermissions() {
        
        List<ObjectPermissions> objPermissions= Core_MDF_PPSM.getObjectPermissions('Account');
        
        System.assert(objPermissions.size() > 0,'Invalid Object Permissions for Account');
    }
    
    @isTest
    public static void testgetFieldPermissions() {
        
        List<FieldPermissions> fieldPermissionsFrAccType= Core_MDF_PPSM.getFieldPermissions('Account','Account.Type');
        
        System.assert(fieldPermissionsFrAccType.size() > 0,'Invalid Field Permissions for Account Type');
    }
    
    @isTest
    public static void testgetPermissionSets() {
        
        List<PermissionSet> permissionSets= Core_MDF_PPSM.getPermissionSets();
        
        System.assert(permissionSets.size() > 0,'Invalid Permission Sets for the Org');
    }
    
    @isTest
    public static void testupsertPermissions() {
        
        List<ObjectPermissions> objPermissions = Core_MDF_PPSM.getObjectPermissions('Account');
        
        List<String> results= Core_MDF_PPSM.upsertPermissions(JSON.serialize(new List<ObjectPermissions>{objPermissions[0]}),true);
        System.assert(JSON.serialize(results).contains('true'),'Upsert Object Permissions Failed');
        
        //Duplicate record testing
        objPermissions[0].Id = null;
        results= Core_MDF_PPSM.upsertPermissions(JSON.serialize(new List<ObjectPermissions>{objPermissions[0]}),true);
        System.assert(JSON.serialize(results).contains('false'),'Negative/Duplicate Object Permissions Failed');
        
        List<FieldPermissions> fieldPermissions = Core_MDF_PPSM.getFieldPermissions('Account','Account.Type');
        results= Core_MDF_PPSM.upsertPermissions(JSON.serialize(new List<FieldPermissions>{fieldPermissions[0]}),false);
        System.assert(JSON.serialize(results).contains('true'),'Upsert Field Permissions Failed');
        
        try{
            Core_MDF_PPSM.upsertPermissions(null,true);  
        }
        catch(exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'),'Exception Coverage Failed!!');
        }
    }  
}