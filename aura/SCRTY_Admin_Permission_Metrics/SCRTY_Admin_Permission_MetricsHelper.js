({
    validateDuplicateUser : function(cmp,lstUsers,lstPermissionSetAssignments,mapProfiles,mapPermissionSets,lstPermissions){
		var mapUserIdWithEnabledPermissions = new Map();
		var mapPermissonSetWithPermissions = new Map();

		var countPS = 0;
		var countProfile = 0;
		var countUsers = 0;

		var tempPermissionWithProfileCount = new Map();
		var tempPermissionWithPSCount = new Map();
		var tempUserWithPermissionCount = new Map();
		var userMap = new Map();
		var tempUserMap = new Map();

			
		//Build map that holds permissionSet with enabled permissions
		for(var psId of mapPermissionSets.keys()){
			var permissionSet = mapPermissionSets.get(psId);
				for(var cmItem of lstPermissions.keys()){
				var isEnabled = permissionSet[cmItem];
				var isProfile = permissionSet.IsOwnedByProfile;
					var isProfile = permissionSet.IsOwnedByProfile;
					if(isProfile){
						var profile = mapProfiles.get(permissionSet.ProfileId);
						var isProfileEnabled = profile[cmItem];
						if(isProfileEnabled){
							if(tempPermissionWithProfileCount.has(cmItem)){                       
								countProfile = tempPermissionWithProfileCount.get(cmItem);
								countProfile = countProfile+1;
								tempPermissionWithProfileCount.set(cmItem,countProfile);                                        
							}else{
								tempPermissionWithProfileCount.set(cmItem,1);
							}
							var enabledPermissions = cmItem;
							if(mapPermissonSetWithPermissions.has(psId)){
								enabledPermissions = mapPermissonSetWithPermissions.get(psId) + ';';
								enabledPermissions = enabledPermissions + cmItem;
							}
							mapPermissonSetWithPermissions.set(psId,enabledPermissions);
									
						}
					}else{	
						if(isEnabled){
							if(tempPermissionWithPSCount.has(cmItem)){                       
									countPS = tempPermissionWithPSCount.get(cmItem);
									countPS = countPS+1;
									tempPermissionWithPSCount.set(cmItem,countPS);                                        
							}else{
									tempPermissionWithPSCount.set(cmItem,1);
							}
							
							var enabledPermissions = cmItem;
								if(mapPermissonSetWithPermissions.has(psId)){
									enabledPermissions = mapPermissonSetWithPermissions.get(psId) + ';';
									enabledPermissions = enabledPermissions + cmItem;
								}
								mapPermissonSetWithPermissions.set(psId,enabledPermissions);
										
							}
					}

			}
		}	

		//Build map that holds AssigneedId with enabled permissions through PermissionSetAssignment
		for(var psItem of lstPermissionSetAssignments){			
			if(mapPermissonSetWithPermissions.has(psItem.PermissionSetId)){				
				var permissionSet = mapPermissionSets.get(psItem.PermissionSetId);
				var profile = mapProfiles.get(permissionSet.ProfileId);
				var isProfile = permissionSet.IsOwnedByProfile;
				var setUserData =[{
                        Id: psItem.AssigneeId,
                        FullName: 'ToBePopulated',
                        Active: 'TRUE',
                        EmployeeTypeCode: 'ToBePopulated',
                        LastLoginDate: 'ToBePopulated',
                            PermissionTypeName: (isProfile ? profile.Name : permissionSet.Label),
                            Type: permissionSet.Type,
                            FrozenStatus: 'False'
                    	}];
				var enabledPermissions = mapPermissonSetWithPermissions.get(psItem.PermissionSetId);
				if(mapUserIdWithEnabledPermissions.has(psItem.AssigneeId)){
					enabledPermissions = enabledPermissions+','+mapUserIdWithEnabledPermissions.get(psItem.AssigneeId);
					userSet = tempUserMap.get(psItem.AssigneeId);
				}
				mapUserIdWithEnabledPermissions.set(psItem.AssigneeId,enabledPermissions);
				tempUserMap.set(psItem.AssigneeId,setUserData);				
			}
		}
		for(var userId of mapUserIdWithEnabledPermissions.keys()){
			var permissionEnabledForUser = mapUserIdWithEnabledPermissions.get(userId);
			for(var key of lstPermissions.keys()){
				if(permissionEnabledForUser.includes(key)){
					var userSet = new Set();
					if(tempUserWithPermissionCount.has(key)){                            
                            countUsers = tempUserWithPermissionCount.get(key);
                            countUsers = countUsers+1;
                            tempUserWithPermissionCount.set(key,countUsers);
							userSet = userMap.get(key);
							userSet.add(tempUserMap.get(userId));
							userMap.set(key,userSet);
                    }else{
                            tempUserWithPermissionCount.set(key,1);
							userMap.set(key,userSet.add(tempUserMap.get(userId)));
                    }  
				}
			}
		}
		console.log('userMap Count'+userMap.size+'<--->'+tempUserMap.size);
		cmp.set("v.userMap",userMap);
        var dataMap = cmp.get("v.dataValueMap");
        if(!dataMap) dataMap = new Map();
		for(var key of lstPermissions.keys()){
			var temp=[];
            var criteriaForGreen = $A.get('$Label.c.SCRTY_Dashboard_Threshold_Count_Low');
            var criteriaForRed = $A.get('$Label.c.SCRTY_Dashboard_Threshold_Count_High');            
            var permissionSetCount = tempPermissionWithPSCount.get(key);
			var profileCount = tempPermissionWithProfileCount.get(key);
			var userCount = tempUserWithPermissionCount.get(key);
			var statusCode = (userCount<criteriaForGreen?'Green':(userCount<criteriaForRed?'Yellow':'Red'));

            if(typeof tempPermissionWithPSCount.get(key) === 'undefined' ){
                permissionSetCount = 0;
            }
			//console.log('permissionSetCount::'+permissionSetCount+'profileCount::'+profileCount+'userCount::'+userCount);

             temp.push({
                permissionAPIName:key,
                permissionName:lstPermissions.get(key),
                countPermissionSets:permissionSetCount,
                countProfiles: profileCount,
                countActiveUser: userCount,
                statusCode:statusCode
            });
            dataMap.set(lstPermissions.get(key),temp);
        }
        var dataVals = [];
        cmp.set("v.dataValueMap",dataMap);
        for(var key of dataMap.keys()){
            var dataVal = dataMap.get(key);
            for(var d of dataVal){
                dataVals.push(d);
            }
        }
        cmp.set("v.data",dataVals);
    },
    
    soql: function (cmp, query,ids,conFields) {
        return new Promise(function (resolve, reject) {
            var action = cmp.get("c.executeSOQL");
            action.setParams({soql: query,
                              ids: ids,
                              condition: conFields});
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                            reject(errors[0].message);
                        } else {
                            console.log("Unknown error");
                            reject("Unknown error");
                        }
                    }
            });
            $A.enqueueAction(action);
        });
        
        
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc'; 
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.data", data);
    }, 
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    downloadCSV: function(cmp, objectRecords) {
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        columnDivider = ',';
        lineDivider =  '\n';
        keys = ['Id','FullName','Active','PermissionTypeName','Type','EmployeeTypeCode','LastLoginDate','FrozenStatus'];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }  
                if(objectRecords[i]){
                    if(objectRecords[i][skey]){
                        csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                    }else{
                        csvStringResult += '"'+' '+'"';
                    }
                    
                }else{
                    csvStringResult += '"'+' '+'"';
                }
                
                counter++;
                
            } 
            csvStringResult += lineDivider;
        } 
        return csvStringResult;    
        
    },

})