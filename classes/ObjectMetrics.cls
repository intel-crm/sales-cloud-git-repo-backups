public with sharing class ObjectMetrics {
    
   @AuraEnabled(Cacheable=true)
    public static List<ObjectAPINameLabelMap__mdt> getObjectNames(){
        return [Select Object_API_Name__c,Object_Display_Name__c,Is_Selected__c from ObjectAPINameLabelMap__mdt];
    }
     @AuraEnabled(Cacheable=true)
   public static Map<String,List<User>> allowedUsers(String ObjectSelected){
       
       Map<String,List<User>> mapOfPermwithPermittedUsers=new Map<String,List<User>>();
       Map<String,List<id>> objectProfileMap=new Map<String,List<id>>();
       List<ObjectPermissions> profilesWithObjectPerms=new List<ObjectPermissions>();
       If(Test.isRunningTest()){
       profilesWithObjectPerms= [SELECT Parent.Profile.id,SObjectType,PermissionsRead,PermissionsCreate,PermissionsDelete,PermissionsEdit,PermissionsModifyAllRecords,PermissionsViewAllRecords FROM ObjectPermissions WHERE 
                                                     Parent.IsOwnedByProfile =true AND 
                                                     (PermissionsRead = true or PermissionsCreate =true or  PermissionsDelete =true or PermissionsEdit =true or PermissionsModifyAllRecords= true or PermissionsViewAllRecords=true) 
                                                     AND SObjectType=:ObjectSelected LIMIT 50];
       }else{
       profilesWithObjectPerms= [SELECT Parent.Profile.id,SObjectType,PermissionsRead,PermissionsCreate,PermissionsDelete,PermissionsEdit,PermissionsModifyAllRecords,PermissionsViewAllRecords FROM ObjectPermissions WHERE 
                                                     Parent.IsOwnedByProfile =true AND 
                                                     (PermissionsRead = true or PermissionsCreate =true or  PermissionsDelete =true or PermissionsEdit =true or PermissionsModifyAllRecords= true or PermissionsViewAllRecords=true) 
                                                     AND SObjectType=:ObjectSelected];
       }

       Map<String,List<id>> Permission=new Map<String,List<id>>();
       for(ObjectPermissions objects:profilesWithObjectPerms){
           if(objects.SObjectType==ObjectSelected){
               if(objects.PermissionsRead){
                  if(Permission.containsKey('PermissionsRead')){
           List<id> tempIds=Permission.get('PermissionsRead');
           tempIds.add(objects.Parent.Profile.id);
                      Permission.put('PermissionsRead',tempIds);
        }
        else{
            List<id> profIds=new List<id>();
            profIds.add(objects.Parent.Profile.id);
            Permission.put('PermissionsRead',profIds);
        }  
               }
               if(objects.PermissionsEdit){
                  if(Permission.containsKey('PermissionsEdit')){
           List<id> tempIds=Permission.get('PermissionsEdit');
           tempIds.add(objects.Parent.Profile.id);
                      Permission.put('PermissionsEdit',tempIds);
        }
        else{
            List<id> profIds=new List<id>();
            profIds.add(objects.Parent.Profile.id);
            Permission.put('PermissionsEdit',profIds);
        }  
               }
               
               
                    if(objects.PermissionsViewAllRecords){
                  if(Permission.containsKey('PermissionsViewAllRecords')){
           List<id> tempIds=Permission.get('PermissionsViewAllRecords');
           tempIds.add(objects.Parent.Profile.id);
                      Permission.put('PermissionsViewAllRecords',tempIds);
        }
        else{
            List<id> profIds=new List<id>();
            profIds.add(objects.Parent.Profile.id);
            Permission.put('PermissionsViewAllRecords',profIds);
        }  
               }
               
               
               if(objects.PermissionsCreate){
                  if(Permission.containsKey('PermissionsCreate')){
           List<id> tempIds=Permission.get('PermissionsCreate');
           tempIds.add(objects.Parent.Profile.id);
                      Permission.put('PermissionsCreate',tempIds);
        }
        else{
            List<id> profIds=new List<id>();
            profIds.add(objects.Parent.Profile.id);
            Permission.put('PermissionsCreate',profIds);
        }  
               }
               
           
           if(objects.PermissionsDelete){
                  if(Permission.containsKey('PermissionsDelete')){
           List<id> tempIds=Permission.get('PermissionsDelete');
           tempIds.add(objects.Parent.Profile.id);
                      Permission.put('PermissionsDelete',tempIds);
        }
        else{
            List<id> profIds=new List<id>();
            profIds.add(objects.Parent.Profile.id);
            Permission.put('PermissionsDelete',profIds);
        }  
               }
              
               
            if(objects.PermissionsModifyAllRecords){
                  if(Permission.containsKey('PermissionsModifyAllRecords')){
           List<id> tempIds=Permission.get('PermissionsModifyAllRecords');
           tempIds.add(objects.Parent.Profile.id);
                      Permission.put('PermissionsModifyAllRecords',tempIds);
        }
        else{
            List<id> profIds=new List<id>();
            profIds.add(objects.Parent.Profile.id);
            Permission.put('PermissionsModifyAllRecords',profIds);
        }  
                    }
           }
           
       }
               
       for(String objectperm:Permission.keySet()){
           List<User> UserRecordList=ObjectMetrics.getUsersForProfiles(Permission.get(objectperm));
         mapOfPermwithPermittedUsers.put(objectperm,UserRecordList);
       }
         
     //system.debug('Final Map'+mapOfPermwithPermittedUsers);

       return mapOfPermwithPermittedUsers;
}
    public static List<User> getUsersForProfiles(List<Id> Ids){
        List<User> UserRecordList=new  List<User>();
       for( User UserRecord:[Select Id,Name,Email,FederationIdentifier,Profile.Name from User where isActive=true AND profile.id =:Ids]){
       UserRecordList.add(UserRecord);
       //system.debug('FOR LOOP'+UserRecordList+'USer Record'+UserRecord);
    }  
        return UserRecordList;
    }

		@AuraEnabled(Cacheable=true)
   public static Map<String,List<User>>getUsers(boolean selectedType){
       List<PermissionSetAssignment> UserLists=new List<PermissionSetAssignment>();
       If(Test.isRunningTest()){
        UserLists= [SELECT Assignee.Id,Assignee.Name, Assignee.FederationIdentifier,Assignee.Email,PermissionSet.IsOwnedByProfile,Assignee.IsActive,PermissionSet.Profile.Name,PermissionSet.Name FROM PermissionSetAssignment Where PermissionSet.IsOwnedByProfile=:selectedType LIMIT 5];
       }
       else{
        UserLists= [SELECT Assignee.Id,Assignee.Name, Assignee.FederationIdentifier,Assignee.Email,PermissionSet.IsOwnedByProfile,Assignee.IsActive,PermissionSet.Profile.Name,PermissionSet.Name FROM PermissionSetAssignment Where PermissionSet.IsOwnedByProfile=:selectedType];
       }
           Map<String,List<User>> objectProfilelMap=new Map<String,List<User>>();
       for(PermissionSetAssignment ob:UserLists){
           String permissionSetTypeName;
           if(selectedType==true){
               permissionSetTypeName=ob.PermissionSet.Profile.Name;
               //System.debug(permissionSetTypeName);
           }
           else if(selectedType==false){
               permissionSetTypeName=ob.PermissionSet.Name;
               //System.debug(permissionSetTypeName);
           }
           if(objectProfilelMap.containsKey(permissionSetTypeName)){
               List<User> temp=objectProfilelMap.get(permissionSetTypeName);
               user obj=new user();
               obj.ID=ob.AssigneeId;
               obj.Firstname=ob.Assignee.Name;
               obj.Email=ob.Assignee.Email;
               obj.FederationIdentifier=ob.Assignee.FederationIdentifier;
               obj.IsActive=ob.Assignee.IsActive;
                temp.add(obj);
               objectProfilelMap.put(permissionSetTypeName,temp);
           }
           else{
               List<User> Users=new List<User>();
               user obj=new user();
               obj.ID=ob.AssigneeId;
               obj.Firstname=ob.Assignee.Name;
               obj.Email=ob.Assignee.Email;
               obj.FederationIdentifier=ob.Assignee.FederationIdentifier;
               obj.IsActive=ob.Assignee.IsActive;
               Users.add(obj);
               objectProfilelMap.put(permissionSetTypeName, Users);
               
               
           }
       }
       //system.debug(objectProfilelMap);
      return objectProfilelMap;
   }
    @AuraEnabled(Cacheable=true)
    public static List<UserLicense> getUserLicence(){
        return [Select Name ,Status,TotalLicenses, UsedLicenses from UserLicense ];
    }
}