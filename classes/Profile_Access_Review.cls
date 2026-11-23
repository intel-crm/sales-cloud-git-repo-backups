public class Profile_Access_Review {
    
    @AuraEnabled
    public static List<String> getProfileNames()
    {
       	List<Profile> ProfileList = [Select Id, Name from Profile];
        List<String> profileNames = new List<String>();
        for(Profile profile : ProfileList)
        {
            profileNames.add(profile.Name);
        }
        System.debug('profileNames:'+profileNames);
        return profileNames;
    }
    @AuraEnabled
    public static List<string> getObjectNames()
    {
        
        List<String> sObjectList = new List<String>();
    for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values())
    {
        Schema.DescribeSObjectResult describeSObjectResultObj = objTyp.getDescribe();
            String name = objTyp.getDescribe().getLabel();
            // Exclude all the unwanted Sobjects e.g. History, Share etc.
            if(!name.containsignorecase('history') && !name.containsignorecase('tag')&&
             !name.containsignorecase('share') && !name.containsignorecase('feed'))
            {
                SobjectList.add(name);
            }
    }
    SobjectList.sort();
    system.debug('SObjectList****' + SObjectList);
    return sObjectList;
        
    }
    @AuraEnabled
    public static List<FieldPermissions> profileAccess(string profileName, List<String> objectName)
    {
       List<FieldPermissions> fieldPermissions = [SELECT Id, Field, toLabel(SobjectType) SObjectName, PermissionsRead, PermissionsEdit 
                                                  FROM FieldPermissions 
                                                  WHERE parentid in (select id from permissionset where PermissionSet.Profile.Name =: profileName) 
                                                  and SObjectType IN : objectName];
        System.debug('fieldPermissions:'+fieldPermissions);
        return fieldPermissions;
    }
   
    @AuraEnabled
    public static List<ObjectPermissions> profileCRUD(string profileName, List<String> objectName)
    {
        List<ObjectPermissions> objectPermissions = [SELECT Id, PermissionsCreate, toLabel(SobjectType) SObjectName, PermissionsRead, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords, PermissionsEdit 
                                                        FROM ObjectPermissions 
                                                        WHERE parentid in (select id from permissionset where PermissionSet.Profile.Name = : profileName)
                                                    	and SObjectType IN : objectName];
        System.debug('objectPermissions:'+objectPermissions);
        return objectPermissions;
    }
     
}