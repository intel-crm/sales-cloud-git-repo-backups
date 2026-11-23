global class SCRTY_Admin_Permission_Metrics_Batch1 implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    
    
    global List<PermissionSet> lstPermissionSet = new List<PermissionSet>();
    global Map<String,String> mapPermissionAPIWithPermissionName = new Map<String,String>();
    global Map<String,Integer> mapPermissionWithProfileCount = new Map<String,Integer>();
    global Map<String,Integer> mapPermissionWithPermissionSetCount = new Map<String,Integer>();
    global Map<String,Integer> mapPermissionWithActiveUserCount = new Map<String,Integer>();
    global Map<Id,String> mapPSIdWithEnabledPermissions = new Map<Id,String>();
    global Map<Id,String> mapUserIdWithEnabledPermission = new Map<Id,String>();
    global Map<Id,Integer> userDuplication = new Map<Id,Integer>();
    global Map<Id,Set<Id>> mapPermissionSetIdWithUserIdSet = new Map<Id,Set<Id>>();
    
    
    
    global database.QueryLocator start(Database.BatchableContext context){
        String condition = 'removeMeBeforeQuery'; 
        String fields = 'removeMeBeforeQuery';
        String byPassPermissions = 'PermissionsInstallMultiforce,PermissionsCreateMultiforce';
        List<SCRTY_Admin_Permission_Mapping__mdt > lstPermissions = [SELECT SCRTY_Permission_API_Nm__c,SCRTY_Permission_Nm__c,SCRTY_Inactive_Ind__c FROM SCRTY_Admin_Permission_Mapping__mdt];
        Map<String,String> permissionNameToAPIMap = new Map<String,String>();
        System.debug('lstPermissions***'+lstPermissions.size());
        for (SCRTY_Admin_Permission_Mapping__mdt permission : lstPermissions) {
            if(permission.SCRTY_Inactive_Ind__c){
                if(!byPassPermissions.contains(permission.SCRTY_Permission_API_Nm__c)){
                    fields = fields +','+ permission.SCRTY_Permission_API_Nm__c;
                    condition = condition +' or '+permission.SCRTY_Permission_API_Nm__c +' = true';
                }
                mapPermissionAPIWithPermissionName.put(permission.SCRTY_Permission_API_Nm__c,permission.SCRTY_Permission_Nm__c);
                
            }
        }
        String psQuery = 'SELECT Id,Name,ProfileId,IsOwnedByProfile,Type,Profile.PermissionsInstallMultiforce,Profile.PermissionsCreateMultiforce,'+fields+' FROM PermissionSet WHERE (IsOwnedByProfile = true  and ( Profile.PermissionsCreateMultiforce = true or profile.PermissionsInstallMultiforce = true)) or '+condition + ' Limit 50000';
        psQuery = psQuery.replaceAll('removeMeBeforeQuery,','');
        psQuery = psQuery.replaceAll('removeMeBeforeQuery or','');
        System.debug('psQuery::'+psQuery);
        lstPermissionSet = Database.query(psQuery);
        String query;
        if(Test.isRunningTest()){
        query = 'SELECT AssigneeId, PermissionSet.ProfileId,PermissionSetId, PermissionSet.Type FROM PermissionSetAssignment WHERE Assignee.isActive = true and PermissionSetId =: lstPermissionSet LIMIT 200';
        }
        else{
        query = 'SELECT AssigneeId, PermissionSet.ProfileId,PermissionSetId, PermissionSet.Type FROM PermissionSetAssignment WHERE Assignee.isActive = true and PermissionSetId =: lstPermissionSet';
        }
        return Database.getQueryLocator(query);   
    }
    global void execute(Database.BatchableContext context, List<PermissionSetAssignment> lstPermSetAssign){
        System.debug('mapPermissionAPIWithPermissionName***'+mapPermissionAPIWithPermissionName.size());
        System.debug('lstPermissionSet***'+lstPermissionSet.size());
        Integer Count = 0;
        if(mapPermissionWithPermissionSetCount.isEmpty()){			
            Integer CountPS = 0;
            String profileOnlyPermissions = 'PermissionsInstallMultiforce,PermissionsCreateMultiforce';
            for(PermissionSet psItem : lstPermissionSet){
                for(String perm : mapPermissionAPIWithPermissionName.keySet()){
                    String enabledPermission = perm;
                    if(profileOnlyPermissions.containsIgnoreCase(perm)){
                        if(psItem.getSObject('Profile')!=null && psItem.getSObject('Profile').get(Perm) == true){
                            if(mapPSIdWithEnabledPermissions.containsKey(psItem.Id)){
                                enabledPermission = mapPSIdWithEnabledPermissions.get(psItem.Id);
                                enabledPermission = enabledPermission +','+ perm;
                            }
                            mapPSIdWithEnabledPermissions.put(psItem.Id,enabledPermission);
                            count = 1;
                            if(mapPermissionWithProfileCount.containsKey(perm)){
                                count = mapPermissionWithProfileCount.get(perm);
                                count = count + 1;
                            }
                            mapPermissionWithProfileCount.put(perm,count);
                            
                        }
                    }else{
                        if(psItem.get(Perm) == true){
                            if(psItem.IsOwnedByProfile){
                                count = 1;
                                if(mapPermissionWithProfileCount.containsKey(perm)){
                                    count = mapPermissionWithProfileCount.get(perm);
                                    count = count + 1;
                                }
                                mapPermissionWithProfileCount.put(perm,count);
                                
                            }else{
                                count = 1;
                                if(mapPermissionWithPermissionSetCount.containsKey(perm)){
                                    count = mapPermissionWithPermissionSetCount.get(perm);
                                    count = count + 1;
                                }
                                mapPermissionWithPermissionSetCount.put(perm,count);
                            }
                            if(mapPSIdWithEnabledPermissions.containsKey(psItem.Id)){
                                enabledPermission = mapPSIdWithEnabledPermissions.get(psItem.Id);
                                enabledPermission = enabledPermission +','+ perm;
                            }
                            mapPSIdWithEnabledPermissions.put(psItem.Id,enabledPermission);
                        }
                    }
                }
            }
        }

        for(PermissionSetAssignment psaItem : lstPermSetAssign){	
          if(mapPSIdWithEnabledPermissions.containsKey(psaItem.PermissionSetId)){
              string enabled = mapPSIdWithEnabledPermissions.get(psaItem.PermissionSetId);
              if(mapUserIdWithEnabledPermission.containsKey(psaItem.AssigneeId)){
              		enabled = enabled+','+mapUserIdWithEnabledPermission.get(psaItem.AssigneeId);
          	   }
              mapUserIdWithEnabledPermission.put(psaItem.AssigneeId,enabled);
       		 }
        }
   }
    global void finish(Database.BatchableContext context){
        for(Id userId : mapUserIdWithEnabledPermission.keySet()){
            String availablePermission = mapUserIdWithEnabledPermission.get(userId);
                for(String perm : mapPermissionAPIWithPermissionName.keySet()){
                    if(availablePermission.contains(perm)){
                       Integer count = 1;
                       if(mapPermissionWithActiveUserCount.containsKey(perm)){
                                  count = mapPermissionWithActiveUserCount.get(perm);
                                  count = count + 1;
                             }
                        mapPermissionWithActiveUserCount.put(perm,count);
                    }				
                }           
        }
        list <SCRTY_Admin_Permission_Metrics__c> lstAdminPermObj =new list<SCRTY_Admin_Permission_Metrics__c>();        
        for(String perm : mapPermissionAPIWithPermissionName.KeySet()){
            Integer countPS=0;
            Integer countProfile=0;
            Integer countUsers=0;
            if(mapPermissionWithPermissionSetCount.containsKey(perm)){
                countPS = mapPermissionWithPermissionSetCount.get(perm);
            }
            if(mapPermissionWithProfileCount.containsKey(perm) ){
                countProfile = mapPermissionWithProfileCount.get(perm);
            }
            if(mapPermissionWithActiveUserCount.containsKey(perm)){
                countUsers = mapPermissionWithActiveUserCount.get(perm); 
            }
            SCRTY_Admin_Permission_Metrics__c adminPermObject =new SCRTY_Admin_Permission_Metrics__c();
            adminPermObject.SCRTY_Permission_Nm__c = mapPermissionAPIWithPermissionName.get(perm);
            adminPermObject.SCRTY_User_Cnt__c = countUsers;
            adminPermObject.SCRTY_Permission_Set_Cnt__c  = countPS;
            adminPermObject.SCRTY_Profile_Cnt__c = countProfile;
            lstAdminPermObj.add(adminPermObject);
        }
        insert lstAdminPermObj;
    }
    global void execute(SchedulableContext ctx) 
    {
        SCRTY_Admin_Permission_Metrics_Batch1 schduleBatch = new SCRTY_Admin_Permission_Metrics_Batch1();
        if(Test.isRunningTest()){
              ID jobID = Database.executeBatch(schduleBatch, 200);
      System.abortJob(jobID);
        }
        else{
            database.executebatch(schduleBatch);
        }
    }
}