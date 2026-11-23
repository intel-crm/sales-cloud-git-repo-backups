global class BatchPOC implements Database.Batchable<sObject>,Database.Stateful{
    
    
	global List<PermissionSet> lstPermissionSet = new List<PermissionSet>();
	global Map<String,String> mapPermissionAPIWithPermissionName = new Map<String,String>();
    global Map<String,Integer> mapPermissionWithProfileCount = new Map<String,Integer>();
    global Map<String,Integer> mapPermissionWithPermissionSetCount = new Map<String,Integer>();
    global Map<String,Integer> mapPermissionWithActiveUserCount = new Map<String,Integer>();
	global Map<Id,String> mapPSIdWithEnabledPermissions = new Map<Id,String>();
	global Map<Id,String> mapUserIdWithEnabledPermission = new Map<Id,String>();


    
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
		String psQuery = 'SELECT Id,Name,ProfileId,IsOwnedByProfile,Type,Profile.PermissionsInstallMultiforce,Profile.PermissionsCreateMultiforce'+fields+' FROM PermissionSet WHERE (IsOwnedByProfile = true  and ( Profile.PermissionsCreateMultiforce = true or profile.PermissionsInstallMultiforce = true)) or '+condition + ' Limit 50000';
		psQuery = psQuery.replaceAll('removeMeBeforeQuery,','');
		psQuery = psQuery.replaceAll('removeMeBeforeQuery or','');
		System.debug('psQuery::'+psQuery);
		lstPermissionSet = Database.query(psQuery);
        String query = 'SELECT AssigneeId, PermissionSet.ProfileId,PermissionSetId, PermissionSet.Type FROM PermissionSetAssignment WHERE Assignee.isActive = true and PermissionSetId =: lstPermissionSet limit 400';
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
			System.debug('mapPSIdWithEnabledPermissions'+mapPSIdWithEnabledPermissions.size());
		}
		
		
		
		for(PermissionSetAssignment psaItem : lstPermSetAssign){	
		
				if(mapPSIdWithEnabledPermissions.containsKey(psaItem.PermissionSetId)){
					String availablePermission = mapPSIdWithEnabledPermissions.get(psaItem.PermissionSetId);
					if(mapUserIdWithEnabledPermission.containsKey(psaItem.AssigneeId)){
						availablePermission = mapUserIdWithEnabledPermission.get(psaItem.AssigneeId);
						availablePermission = availablePermission+','+mapPSIdWithEnabledPermissions.get(psaItem.PermissionSetId);
					}
					mapUserIdWithEnabledPermission.put(psaItem.AssigneeId,availablePermission);
				}
            if(mapUserIdWithEnabledPermission.containsKey(psaItem.AssigneeId)){
                String enabledPermission = mapUserIdWithEnabledPermission.get(psaItem.AssigneeId);
					for(String perm : mapPermissionAPIWithPermissionName.keySet()){
						if(enabledPermission.contains(perm)){
							count = 1;
							if(mapPermissionWithActiveUserCount.containsKey(perm)){
								count = mapPermissionWithActiveUserCount.get(perm);
								count = count +1;
							}
							mapPermissionWithActiveUserCount.put(perm,count);							
						}						
					}
            }
					
				
		}
		System.debug('mapPermissionWithPermissionSetCount'+mapPermissionWithPermissionSetCount.size());
		System.debug('mapPermissionWithProfileCount'+mapPermissionWithProfileCount.size());
		System.debug('mapPermissionWithActiveUserCount'+mapPermissionWithActiveUserCount.size());


         
    }
    global void finish(Database.BatchableContext context){
		System.debug('mapPermissionWithPermissionSetCount'+mapPermissionWithPermissionSetCount.size());
		System.debug('mapPermissionWithProfileCount'+mapPermissionWithProfileCount.size());
		System.debug('mapPermissionWithActiveUserCount'+mapPermissionWithActiveUserCount.size());
        list <SCRTY_Admin_Permission_Metrics__c> lstAdminPermObj =new list<SCRTY_Admin_Permission_Metrics__c>();
        Integer countPS=0;
        Integer countProfile=0;
        Integer countUsers=0;
         for(String perm : mapPermissionAPIWithPermissionName.KeySet()){
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
         // insert lstAdminPermObj;
	}
}