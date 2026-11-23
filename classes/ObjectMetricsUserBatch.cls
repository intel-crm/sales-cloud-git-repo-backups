global class ObjectMetricsUserBatch implements Database.Batchable<Sobject>,Database.Stateful {
    
    global String ObjectName;
    global Map<String,List<User>> UserPermMap;
    global Map<String,List<id>> Permission;
   global ObjectMetricsUserBatch(String ObjName){
       ObjectName=ObjName;
       UserPermMap=new Map<String,List<User>>();
       Permission=new Map<String,List<id>>();
    }
    
global Database.QueryLocator start(Database.BatchableContext BC) {
       List<ObjectPermissions> objectPerms= new List<ObjectPermissions>();
    objectPerms=[SELECT Parent.Profile.id,SObjectType,PermissionsRead,PermissionsCreate,PermissionsDelete,PermissionsEdit,PermissionsModifyAllRecords,PermissionsViewAllRecords FROM ObjectPermissions WHERE 
                                                     Parent.IsOwnedByProfile =true AND 
                                                     (PermissionsRead = true or PermissionsCreate =true or  PermissionsDelete =true or PermissionsEdit =true or PermissionsModifyAllRecords= true or PermissionsViewAllRecords=true) 
                                                      AND SObjectType=:ObjectName];
    List<Id> profId=new List<Id>();
    for(ObjectPermissions obprm:objectPerms){
        profId.add(obprm.Parent.Profile.id);
    }
       for(ObjectPermissions objects:objectPerms){
           if(objects.SObjectType==ObjectName){
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
         
        //String query = 'Select Id,Name,Email,FederationIdentifier,Profile.Name from User where isActive=true AND profile.id =:profileIds';
        return Database.getQueryLocator([Select Id,Name,Email,FederationIdentifier,Profile.Name,profile.id from User where isActive=true AND profile.id=:profId]);
    }
     
    global void execute(Database.BatchableContext BC, List<User> Users) {
        //System.debug(Users.size());
         for(User userRecord:Users){
             for(String ObjName:Permission.keySet()){
                 List<Id> ProfIds= Permission.get(ObjName);
                 for(Id profileId:ProfIds){
                     if(userRecord.profile.id==profileId){
                         if(UserPermMap.containsKey(ObjName)) {
                             List<User> UserList=UserPermMap.get(ObjName);
                             UserList.add(userRecord);
                             UserPermMap.put(ObjName, UserList);
                             
                         } 
                         else{
                             List <User> getUser=new List<User>();
                             getUser.add(userRecord);
                            UserPermMap.put(ObjName, getUser) ;
                         }
                     }
                     
                 }
             }
      // userList.add(Users[i]);
         }
       //System.debug('Hellooo'+userList.size());
    }   
     
    global void finish(Database.BatchableContext BC) {
        
        System.debug('Batch Is finished'+UserPermMap.size());
        SCRTY_Object_Permission_Metrics__c objperms=new SCRTY_Object_Permission_Metrics__c();
        List<SCRTY_Object_Permission_Metrics__c> ObjectPerms=new List<SCRTY_Object_Permission_Metrics__c>();
               
        	   objperms.Name=ObjectName;
               objperms.SCRTY_No_Of_Users_With_Read_Permission__c= UserPermMap.get('PermissionsRead').Size();
           
               objperms.SCRTY_No_Of_Users_With_Edit_Permission__c= UserPermMap.get('PermissionsEdit').Size();
            
               objperms.SCRTY_No_Of_Users_With_Create_Permission__c= UserPermMap.get('PermissionsCreate').Size();
          
               objperms.SCRTY_No_Of_Users_With_ViewAll_Perms__c= UserPermMap.get('PermissionsViewAllRecords').Size();
            
               objperms.SCRTY_No_Of_Users_With_Delete_Perms__c= UserPermMap.get('PermissionsDelete').Size();
           
               objperms.SCRTY_No_Of_Users_With_ModifyAll_Perms__c= UserPermMap.get('PermissionsModifyAllRecords').Size();
            
        try{
            insert objperms; 
        }
          catch(DmlException e) {
    System.debug('The following exception has occurred: ' + e.getMessage());  
        }
        
    }
}