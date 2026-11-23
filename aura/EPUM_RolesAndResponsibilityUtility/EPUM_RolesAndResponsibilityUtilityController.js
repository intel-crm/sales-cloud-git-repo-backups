({
    gotoEPUMRnRPage : function(component, event, helper) {
        var epumRnRURLEvent = $A.get("e.force:navigateToURL");
        epumRnRURLEvent.setParams({
            "url": "/ipa/s/manage-responsibilities"
        });
        epumRnRURLEvent.fire();       
    },
    callAuraMethodController : function(component,event,helper){
        console.log("i am inside dofd");
        var params = event.getParams().arguments;
        var callerComponent = params.component;
        var controllerMethod = params.controllerMethod;
        var actionParameters = params.actionParameters;
        var successCallBack = params.successCallBack;
        console.log('actionParam'+component);
        helper.callAuraMethodHelper(component,callerComponent,controllerMethod,
                              actionParameters,successCallBack);
    }
   /* getLoggedInUserInfo : function(component,event,helper){
        var params = event.getParam('arguments');
        var callback;
        if (params) {
            callback = params.callback;
        }
        var action = component.get("c.getLoggedInUserRole"); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state::'+state);
            if (state === "SUCCESS") {
                
                var userInfo = response.getReturnValue();
                console.log("I am SUCCESS"+userInfo);
                //component.set("v.userInfo",userInfo);
                if (callback) callback(response.getReturnValue());
            }else{
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error message: " + errors[0].message);
                    }
                }else{
                    console.log("Unknown error");
                }
                return null;
            }
        });
         $A.enqueueAction(action);
    },
    getContactsWithRoleInfo : function(component,event,helper){
        var params = event.getParam('arguments');
        var data;
        var userInfo;
        if (params) {
            data = params.data;
            userInfo = params.userInfo;
        }
        console.log("i am inside"+JSON.stringify(userInfo));
        var action = component.get("c.getContactsWithRole"); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state::'+state);
            if (state === "SUCCESS") {
                var contactWithRoles = response.getReturnValue();
				var contactsWithRoles = [];
                //var myRoleDetail = component.get("v.userInfo");
                var myRoleDetail = userInfo;
                var primaryRole;
				var mapPrimaryContact = new Map();
				var rank = 9;
                console.log('myRoleDetail::'+myRoleDetail);
                switch (myRoleDetail.PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c){
                    case 'PRIMARY':
						primaryRole ='Primary Contact';
						mapPrimaryContact.set(myRoleDetail.PRM_Contact_Id__c);
                        break;
                    case 'PRIMCONTDEL':
                        primaryRole ='Primary Contact Delegate';
						mapPrimaryContact.set(myRoleDetail.PRM_Contact_Id__c);
                        break;
                }
				contactsWithRoles.push({
								name : myRoleDetail.PRM_Contact_Id__r.Name,
								phoneNumber : myRoleDetail.PRM_Contact_Id__r.Phone,
								responsibility : primaryRole
								});
				var mapContactWithRoles = new Map();
                for(var res in contactWithRoles){
                    var secCont = contactWithRoles[res];
                    var ceData = contactWithRoles[res].Contact_Entitlements__r;
					if(myRoleDetail.PRM_Contact_Id__c != secCont.Id){
						if(ceData && ceData.length >0){
							if(!mapPrimaryContact.has(secCont.Id)){
								for(var ce in ceData){
									var entRole = ceData[ce].Core_Entitlement_Id__r.Core_Display_Name__c;
									console.log('entRole::'+entRole);
									if(entRole === 'Primary Contact Delegate'){
										contactsWithRoles.push({
												name : secCont.Name,
												phoneNumber : secCont.Phone,
												responsibility : 'Primary Contact Delegate',
												rank : 2
												});
										mapPrimaryContact.set(secCont.Id);
									}else if (entRole === 'Primary Contact'){
										contactsWithRoles.push({
												name : secCont.Name,
												phoneNumber : secCont.Phone,
												responsibility : 'Primary Contact',
												rank : 1
										});
										mapPrimaryContact.set(secCont.Id);
									}else{
										var roles = entRole;
										if(mapContactWithRoles.has(ceData[ce].Core_Contact_Id__c)){
											roles = mapContactWithRoles.get(ceData[ce].Core_Contact_Id__c);
											roles = roles +', '+entRole;
										}
										mapContactWithRoles.set(secCont.Id,roles);
									}															
								}
								
							}							
                        }else{
                            /*contactsWithRoles.push({
										name : secCont.Name,
										phoneNumber : secCont.Phone,
										responsibility : "Employee",
										rank : 9
										
							});*//*
                        }
					}
					if(mapContactWithRoles.size > 0){
						if(mapContactWithRoles.has(secCont.Id) && !mapPrimaryContact.has(secCont.Id)){
							var roles = mapContactWithRoles.get(secCont.Id);
							contactsWithRoles.push({
										name : secCont.Name,
										phoneNumber : secCont.Phone,
										responsibility : roles,
										rank : 8
										
							});
						}
					}					
				}
                contactsWithRoles.sort();
                if(contactsWithRoles.length < 11){
                    //component.set("v.data",contactsWithRoles);
                    //component.set("v.isViewAllEnabled",false);
                }else{
                    var tempContactWithRoles = [];
                    for(var i=0;i<10;i++){
                        tempContactWithRoles.push(contactsWithRoles[i]);
                    }
                    //component.set("v.data",tempContactWithRoles);
                    //component.set("v.isViewAllEnabled",true);
                }
                if(data) data(contactsWithRoles);            
            }else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error message: " + errors[0].message);
                    }
                }else{
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },*/
    
})