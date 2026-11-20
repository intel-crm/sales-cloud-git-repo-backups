({
	doInit : function(component, event, helper) {
        
        var isBasic = false;
        var isEnhanced = false;
        var isPartnerUser = false;
        var is_Intel_Admin_Profile = false;
        var is_PMP_Manage_Leads = false;
        var is_PMP_Manage_Offerings = false;
        var is_PMP_Manage_Partners = false;
        var is_PMP_View_Dashboard = false;

        
        var actionPermissionSet = component.get("c.checkForCustomPermission");
        //actionPermissionSet.setParams({ "userId" : "0050n000002XO02" })

        actionPermissionSet.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
 
                if(storeResponse != null){
                   	
                    if(storeResponse.PMP_Manage_Leads !== undefined){
                        is_PMP_Manage_Leads = true;
                    }
                }
                if(storeResponse != null){
                   	
                    if(storeResponse.PMP_Manage_Offerings !== undefined){
                        is_PMP_Manage_Offerings = true;
                    }
                }
                if(storeResponse != null){
                   	
                    if(storeResponse.PMP_Manage_Partners !== undefined){
                        is_PMP_Manage_Partners = true;
                    }
                }
                if(storeResponse != null){
                   	
                    if(storeResponse.PMP_View_Dashboard !== undefined){
                        is_PMP_View_Dashboard = true;
                    }
                }
                
                var action = component.get("c.checkBenefitLevel");
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var storeResponse = response.getReturnValue();
                        
                        if(storeResponse != null && storeResponse.includes("Enhanced")){
                            isEnhanced = true;
                        }else if(storeResponse != null && storeResponse.includes("Basic")){
                            isBasic = true;
                        }
                        
                        var actionInternalPermCheck = component.get("c.fetchPermissionSetName");
                        actionInternalPermCheck.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var storeResponse = response.getReturnValue();
                                
                                 if(storeResponse != null && storeResponse.includes("PMP_Internal_Intel_Admin")){
                                    is_Intel_Admin_Profile = true;
                                }
                                
                                var actionFetchUserDetails = component.get("c.fetchUser");
     
                                actionFetchUserDetails.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        	var storeResponse = response.getReturnValue();
                                            if(storeResponse != null && storeResponse.ContactId !== undefined
                                              && storeResponse.ContactId != null){
                                                isPartnerUser = true;
                                                component.set('v.userName',storeResponse.Name);
                                            }
											component.set('v.userName',storeResponse.Name);

                                        //Visibility of buttons logic
                                        if(isPartnerUser == false){
                                            if(is_PMP_Manage_Offerings == true)
                                            	component.set('v.showManageOfferings', true);
                                        	if(is_PMP_Manage_Leads == true)
                                            	component.set('v.showManageLeads', true);
                                        	if(is_PMP_View_Dashboard == true)
                                            	component.set('v.showDashboard', true);
                                            if(is_PMP_Manage_Partners == true)
                                            	component.set('v.showManagedPartners', true);
                                        }else{
                                            if(is_PMP_Manage_Offerings == true && isEnhanced == true)
                                                component.set('v.showManageOfferings', true);
                                            if(is_PMP_Manage_Leads == true)
                                                component.set('v.showManageLeads', true);
                                            if(is_PMP_View_Dashboard == true)
                                                component.set('v.showDashboard', true);
                                        }
                                    
                                        
                                     }
                                });
                                $A.enqueueAction(actionFetchUserDetails);
                                
                                
                                
                                
                            }
                        });
                        //
						$A.enqueueAction(actionInternalPermCheck);

                    }
                });
                $A.enqueueAction(action);     
                
			}
        });
        $A.enqueueAction(actionPermissionSet);
	}
})