({
    init: function (component, event, helper) {
        component.set('v.columns', [
            {label: 'Permission Name',fieldName:'permissionName', type: 'text', sortable: true, initialWidth: 350, cellAttributes:{ alignment: "left"}},
            {label: '# of Permission Sets',fieldName:'countPermissionSets', type: 'number', sortable: true, initialWidth: 250, cellAttributes:{ alignment: "center"}},
            {label: '# of Profiles',fieldName:'countProfiles',  type: 'number', sortable: true, initialWidth: 250, cellAttributes:{ alignment: "center"}},
            {label: '# of Active Users',fieldName:'countActiveUser' , type: 'number', sortable: true, initialWidth: 250, cellAttributes:{ alignment: "center"} },
            {label: 'Status', fieldName:'statusCode',type: 'text',initialWidth: 150, cellAttributes: {  alignment: "right",
                                                                                                      class: { fieldName: 'statusCode' }}},
            {label: 'Report link', type: 'button', initialWidth: 300, typeAttributes:
             {label: { fieldName: 'actionLabel'}, title: 'Click to Download', name: 'download_status', iconName: 'utility:download',initialWidth: 250, class: 'btn_next'},cellAttributes:{ alignment: "center"}},
        ]); 
        var fields;
        var conFields;
        var condition;
        //List of required Data    
        var lstPermissionSets=[];
        var lstPermissionSetAssignments =[];
        var lstProfiles=[];
        var lstUsers=[];
		var lstProfileIds =[];

                      
        //Map of required Data
        var mapUserIdWithEnabledPermission=[];
        var mapCustomMetadata = new Map();
		var mapProfiles= new Map();
		var mapPermissionSets = new Map();
        
        

        var soql = 'SELECT SCRTY_Permission_API_Nm__c,SCRTY_Inactive_Ind__c ,SCRTY_Permission_Nm__c FROM SCRTY_Admin_Permission_Mapping__mdt';
        helper.soql(component, soql)
        .then(function (customMetaDataValues) {
            for( var key in customMetaDataValues){
                var dataValue = customMetaDataValues[key];
               // console.log('datavalue===>'+dataValue.SCRTY_Permission_API_Nm__c);
                if(dataValue.SCRTY_Permission_API_Nm__c != 'PermissionsApiEnabled'){
                    if(dataValue.SCRTY_Inactive_Ind__c  == true){
                        mapCustomMetadata.set(dataValue.SCRTY_Permission_API_Nm__c,dataValue.SCRTY_Permission_Nm__c);
                        if(fields){                    
                            fields = fields + ','+dataValue.SCRTY_Permission_API_Nm__c;
                        }else{
                            fields = dataValue.SCRTY_Permission_API_Nm__c;
                        }
                        if(condition){
                            condition = condition +' or '+ dataValue.SCRTY_Permission_API_Nm__c+' = true';
                        }else{
                            condition=  dataValue.SCRTY_Permission_API_Nm__c + ' = true ';
                        }               
                    }
                }                
            }
            component.set('v.fields',fields);
            component.set('v.condition',condition);     
            
            soql = 'SELECT Id, Name,'+fields+' FROM Profile WHERE '+ condition +' Limit 1000';
            return helper.soql(component, soql);
        })     
        
        .then(function (profiles) {	
            lstProfiles = profiles;
            for(var pro of profiles){
                lstProfileIds.push(pro.Id);
				mapProfiles.set(pro.Id,pro);
            }
            console.log('profiles'+profiles.length);
            fields = fields.replace('PermissionsInstallMultiforce,','');
            fields = fields.replace('PermissionsCreateMultiforce,','');
            condition = condition.replace('PermissionsInstallMultiforce = true or','');
            condition = condition.replace('PermissionsCreateMultiforce = true or','');
            //condition = ' IsOwnedByProfile = false and (' +condition +' )';
            
            soql = 'SELECT Id,Name,label,Type,ProfileId,IsOwnedByProfile, '+fields+' FROM PermissionSet WHERE '+ condition +' Limit 1000';
            //console.log('soql'+soql);
            return helper.soql(component,soql);		              
        })      
        .then(function (permissionSets) {
            lstPermissionSets = permissionSets;
            console.log('profiles'+permissionSets.length);
            var psIds =[];            
            for(var ps of permissionSets){
                psIds.push(ps.Id);
                mapPermissionSets.set(ps.Id,ps);
            }
            
			var userLiscence="'Salesforce'";
			soql = 'SELECT AssigneeId, PermissionSet.ProfileId,PermissionSetId,PermissionSet.Profile.UserLicense.Name,PermissionSet.Type FROM PermissionSetAssignment';
			conFields =' WHERE Assignee.isActive = true and PermissionSet.Profile.UserLicense.Name='+ userLiscence +' and PermissionSetId =:';
            //console.log('***PSAQuery***'+soql);
            return helper.soql(component,soql,psIds,conFields);
        })
        .then(function (perSetAssignments){
            lstPermissionSetAssignments = perSetAssignments
            console.log('***PSA Count***'+perSetAssignments.length);
			helper.validateDuplicateUser(component,lstUsers,lstPermissionSetAssignments,mapProfiles,mapPermissionSets,mapCustomMetadata);
		})
		.catch(function (error) {
            console.log('error::'+error);
        });
        helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
        /*
            soql = 'SELECT Id,Name,isActive,Core_Employee_Type_Code__c,LastLoginDate,ProfileId,Profile.Name FROM User';
            conFields = ' WHERE isActive = true and ProfileId =:';
            return helper.soql(component,soql,lstProfileIds,conFields);	
        })
        .then(function(users){
			lstUsers = users;
            console.log('***User Count***'+users.length); 
			helper.validateDuplicateUser(component,lstUsers,lstPermissionSetAssignments,mapProfiles,mapPermissionSets,mapCustomMetadata);
            //helper.constructAuditData(component,lstProfiles,lstPermissionSets,lstUsers,mapCustomMetadata);
        })
        */
    },
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    handleRowAction: function (cmp, event, helper) {
        var eventAction = event.getParam('action');
        var row = event.getParam('row');
        var data = cmp.get('v.data');
        var index = data.indexOf(row);   
        console.log('row'+row.permissionAPIName+'<--->'+index);
        if(eventAction.name == 'download_status'){

            var userInfoData = cmp.get('v.userMap'); 
			console.log('row'+row.permissionAPIName+'<--->'+userInfoData.size);

            var dataReportMap = new Map();
            var ids = [];
            for(var key of userInfoData.keys()){
                if(key == row.permissionAPIName){
                    var resultData = userInfoData.get(key);
                    for(var usr of resultData.values()){
                        var setSize = usr.length;
                        if(setSize > 1){
                            for(var i=0;i<setSize;i++){
                                dataReportMap.set(usr[i].Id,usr[i]);
                                ids.push(usr[i].Id);
                            }
                        }else{
                            dataReportMap.set(usr[0].Id,usr[0]);
                            ids.push(usr[0].Id);
                        }
                    }
                }
            }
	
            var permissionName = row.permissionAPIName;
            Promise.all([helper.soql(cmp,'Select Id, userId, IsFrozen from Userlogin',ids,' Where userId=:'),
                         helper.soql(cmp,'SELECT Id,Name,isActive,Core_Employee_Type_Code__c,LastLoginDate from User',ids,' Where Id=:')]).then(function(data){
                var userloginData = data[0];
				var userData = data[1];
				var tempUserMap = new Map();
				for(var usr of userData){
					if(dataReportMap.has(usr.Id)){
                            var usrData = dataReportMap.get(usr.Id);
							usrData.FullName= usr.Name;
							usrData.EmployeeTypeCode = usr.Core_Employee_Type_Code__c;
							usrData.LastLoginDate = usr.LastLoginDate;
                        }   					
				}
				console.log('userloginData'+userloginData.length+'<---UserData--->'+userData.length);
                if(userloginData.length > 0){
                    for(var data of userloginData){
                        if(dataReportMap.has(data.UserId)){
                            var usr = dataReportMap.get(data.UserId);
							if(data.IsFrozen === true){
                                usr.FrozenStatus = 'True';
                            }else{
                                usr.FrozenStatus = 'False';
                            }                        
                        }                    
                    }
                }
                var dataToReport = Array.from(dataReportMap.values());
                var csv = helper.downloadCSV(cmp,dataToReport); 
                if (csv == null){return;} 
                var hiddenElement = document.createElement('a');
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
                hiddenElement.target = '_self'; // 
                hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
                document.body.appendChild(hiddenElement); // Required for FireFox browser
                hiddenElement.click(); // using click() js function to download csv file
            })
            .catch(function (error) {
                //do something about the error
                console.log('error::'+error);
            });
        }
        
        
    },
    showSpinner: function(component, event, helper) {
        // remove slds-hide class from mySpinner
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component,event,helper){
        // add slds-hide class from mySpinner    
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
    
})