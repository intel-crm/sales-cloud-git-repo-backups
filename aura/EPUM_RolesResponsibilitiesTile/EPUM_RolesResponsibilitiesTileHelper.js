({
    successCallBackContacRoleInfo : function(component,response){
        //Static Constant 
        var STATIC_PRIMARY = 'PRIMARY';
        var STATIC_PRIMARYDELEGATE = 'PRIMCONTDEL';
        var STATIC_EMPLOYEE = 'Employee';
        var STATIC_LIMITDATASIZE = 10;
        var myRoleDetail = component.get("v.myRoleDetail");
        var data = [];
        if(response && response.length > 0){ 
            var rank = 1;
            var mapContactWithRoles = new Map();
            var mapContWithRole = new Map();
            var lstNonPrimaryContacts = [];
            console.log('Total Contact within OPID::'+response.length);
            for(var res in response){
                var contData = response[res];
                var acrData = response[res].Account_Contact_Relationships__r;
                var ceData = response[res].Contact_Entitlements__r;
                var contName = contData.Name;
                if(contData.Name.length > 30){
                    contName =contName.substring(0,30);
                }
                if(acrData && acrData.length > 0){
                    if(acrData[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c === STATIC_PRIMARY){
                        mapContWithRole.set(1,{
                            Id:contData.Id,
                            name : contName,
                            phoneNumber : contData.Phone,
                            responsibility :acrData[0].PRM_Relationship_Id__r.Name,
                            rank : 1
                        });
                    }
                    else if(acrData[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c === STATIC_PRIMARYDELEGATE){
                        rank = rank + 1;
                        mapContWithRole.set(rank,{
                            Id:contData.Id,
                            name : contName,
                            phoneNumber : contData.Phone,
                            responsibility :acrData[0].PRM_Relationship_Id__r.Name,
                            rank : rank
                        });
                    }else{
                        console.log('contact name'+contData.Name +'<---->'+(ceData));

                        if(ceData && ceData.length > 0){
                            lstNonPrimaryContacts.push(contData);
                            console.log('contact name'+contData.Name +'<---->'+ceData.length);
							var roles = STATIC_EMPLOYEE;
                            mapContactWithRoles.set(contData.Id,roles);
                            for(var ce in ceData){
                                var entRole = ceData[ce].Core_Entitlement_Id__r.Core_Display_Name__c;
                                console.log('entRole'+entRole);
                                if(entRole != STATIC_EMPLOYEE){
                                    roles = mapContactWithRoles.get(contData.Id);
                                    roles = roles +', '+entRole;
                                    mapContactWithRoles.set(contData.Id,roles);
                                 }
                           }
                        }
                    }
                }
            }
            rank = mapContWithRole.size;
                if( rank < STATIC_LIMITDATASIZE && mapContactWithRoles.size > 0){
                    for(var cont in lstNonPrimaryContacts){
                        var contName = contData.Name;
                        if(contData.Name.length > 30){
                                contName =contName.substring(0,30);
                        }
                        var contData = lstNonPrimaryContacts[cont];
                        console.log('mapContactWithRoles.size'+mapContactWithRoles.size);
                        if(mapContactWithRoles.size == 1){
                            mapContWithRole.set(rank,{
                                name : contName,
                                phoneNumber : contData.Phone,
                                responsibility :mapContactWithRoles.get(contData.Id),
                                rank : rank
                            });
                        }else{
                            if(mapContactWithRoles.has(contData.Id)){
                                var roles = mapContactWithRoles.get(contData.Id);
                                console.log('i am outside replace ::'+roles);
                                if(roles != STATIC_EMPLOYEE){
                                    var replaceStr = STATIC_EMPLOYEE+',';
                                    console.log('i am inside replace ::'+replaceStr);
                                    roles = roles.replace(replaceStr,"");
                                    console.log('i am inside replace ::'+roles);
                                }
                                rank = rank + 1;
                                mapContWithRole.set(rank,{
                                    name : contName,
                                    phoneNumber : contData.Phone,
                                    responsibility :roles,
                                    rank : rank
                                });
                            }

                        }
                        
                    }
                } 				
            
            var dataSize = mapContWithRole.size;
            component.set("v.totalRecords",dataSize);
            (dataSize <=10?dataSize:STATIC_LIMITDATASIZE);
            if(dataSize <= STATIC_LIMITDATASIZE){
                STATIC_LIMITDATASIZE = dataSize;
            }
            console.log('STATIC_LIMITDATASIZE'+STATIC_LIMITDATASIZE);

            var i;
            for(i = 1 ;i<=STATIC_LIMITDATASIZE;i++){
                data.push(mapContWithRole.get(i));
            }			
        }else{
            data.push({
                Id:myRoleDetail.PRM_Contact_Id__c,
                name : myRoleDetail.PRM_Contact_Id__r.Name,
                phoneNumber : myRoleDetail.PRM_Contact_Id__r.Phone,
                responsibility : myRoleDetail.PRM_Relationship_Id__r.Name
            });
        }
        component.set("v.data",data);
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    successCallbackUserInfo : function(component,response){
        if(response && response.length > 0){
            component.set("v.myRoleDetail",response[0]);  
            console.log("Success Callback User Info:"+JSON.stringify(response));   
        }
    }
    
    
})