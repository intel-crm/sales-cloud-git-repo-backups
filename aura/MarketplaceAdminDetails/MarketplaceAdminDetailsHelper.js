({
    /*Get Admin Details on init*/
	getAdminDetails : function(component,helper) {
        helper.callServer(component,
                          "getAdminDetails",
                          {"offeringId": component.get('v.offeringId'),
                          }).then( 
            function(response){
                console.log('Inside Hwlper Classs-------'+response);
                if(response && response.objectData!=undefined){
                    console.log(response);
                    console.log('In Helper----------'+response.objectData.businessSegment);
                    //Sandhya :US379001 - Get the  Business Segment response
                    if(response.objectData.businessSegment !=undefined){
                         console.log('In Helper inside if----------'+response.objectData.businessSegment);
                    	component.set("v.businessSegmentList",response.objectData.businessSegment);
                     } 
                    
                    //If no Admin has been assigned,then display currently logged in Admin else assigned Admin
                    if(response.objectData.currentAdmin.PMP_Intel_Admin_Nm__c!=undefined){
                        component.set("v.loggedInAdmin",response.objectData.currentAdmin.PMP_Intel_Admin_Nm__c);
                        component.set("v.selectedAdmin",response.objectData.currentAdmin.PMP_Intel_Admin_Id__c);
                    }
                    	
                    else{
                        component.set("v.loggedInAdmin",response.objectData.loggedInUser.Name);
                        component.set("v.selectedAdmin",response.objectData.loggedInUser.Id);
                    }
                    
                    //List of Admins from the public group
                    if(response.objectData.adminUsers!=undefined){
						component.set("v.admins",response.objectData.adminUsers);
                    } 
                    
                    if(response.objectData.pickListValuesMap){
                       var offeringStatus=[];
                       var map1 = new Map();
                       map1 = response.objectData.pickListValuesMap;
                       Object.keys(map1).forEach(function(key) {
                           if(key==$A.get("$Label.c.PMP_Admin_Review") || key==$A.get("$Label.c.PMP_Approved") || key==$A.get("$Label.c.PMP_Update_Required") || key==$A.get("$Label.c.PMP_Rejected")){
                              var offeringStatusObject=new Object(); 
                              offeringStatusObject.label = key;
                              offeringStatusObject.value = map1[key];
                              offeringStatusObject.selected=map1[key]==response.objectData.currentAdmin.PMP_Partner_Offering_Lifecycle_Status_Nm__c?true:false;
                              if(offeringStatusObject.selected){
                            	component.set("v.selectedOfferingStatus",key);
                        	  } 
                               
                              if((!response.objectData.currentAdmin.PMP_Partner_Offering_Lifecycle_Status_Nm__c || response.objectData.currentAdmin.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Draft')){
                                  offeringStatusObject.selected=map1[key];
                                  component.set('v.selectedOfferingStatus',map1[key]);
                               } 
                              offeringStatus.push(offeringStatusObject) 
                           }
    						console.log(key, map1[key]);
					  }); 
                      component.set("v.offerinStatusList",offeringStatus);  
                    }
                    
                    //Construct the Offering Status with defaut Selected Value
                   // var status=[$A.get("$Label.c.PMP_Admin_Review"),$A.get("$Label.c.PMP_Approved"),$A.get("$Label.c.PMP_Update_Required"),$A.get("$Label.c.PMP_Rejected")];
                    //var offeringStatus=[];
                    /*for(var idx=0;idx<status.length;idx++){
                        var offeringStatusObject=new Object();
                        offeringStatusObject.label=status[idx];
                        offeringStatusObject.value=status[idx];
                        offeringStatusObject.selected=status[idx]==response.objectData.currentAdmin.PMP_Partner_Offering_Lifecycle_Status_Nm__c?true:false;
                        if(offeringStatusObject.selected){
                            component.set("v.selectedOfferingStatus",status[idx]);
                        }
                        offeringStatus.push(offeringStatusObject)
                    }*/
                    //component.set("v.offerinStatusList",offeringStatus );
                    
                }
                
            }
        )
        
    },
    
    /*Show/Hide Modal*/
    handlerToggleModal:function(component,helper){
        component.set("v.isOpen",!component.get("v.isOpen"));  
    },
    
    /*Update changed details to offering (OfferingStatus, Admin)*/
    handlerSaveAdminChanges:function(component,event, helper){
        component.set('v.showSpinner', true);//Added for US535344,making showSpinner attribute as true to display the spinner when submit button is clicked.
        console.log(component.get('v.selectedOfferingStatus'));
        console.log(component.get('v.showSpinner'));
        helper.callServer(component,
                          "saveAdminDetails",
                          {"offeringId": component.get('v.offeringId'),
                           "selectedAdmin":component.get('v.selectedAdmin'),
                           "selectedOfferingStatus":component.get('v.selectedOfferingStatus'),
                          }).then( 
            function(response){
                console.log("response");
                console.log(response);
                if(response=="saved"){
                    var toastEvent = $A.get("e.force:showToast");
                    if(toastEvent){
                        console.log("toast");
                        toastEvent.setParams({
                            "title":$A.get("$Label.c.PMP_Success"),
                            "message":$A.get("$Label.c.PMP_offering_Updated_successfully"),
                            "type":"success"
                            
                        });
                    }
                    var urlEvent = $A.get("e.force:navigateToURL");
        			urlEvent.setParams({ "url": "/pmp-partner-offering/PMP_Partner_Offering__c" });
        			urlEvent.fire();
                    component.set('v.showSpinner', false);//Added for US535344,making showSpinner attribute as false to remove the spinner once the response from server is received. 
                }
                
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    if(toastEvent){
                        toastEvent.setParams({
                            "title":$A.get("$Label.c.PMP_Error"),
                            "message":$A.get("$Label.c.PMP_Offering_not_saved"),
                            "type":"error",
                            "mode":"dismissible"
                            
                        });
                    }    
                }
                
                if(toastEvent){
                    toastEvent.fire();
                }                
            });
    },
   
})