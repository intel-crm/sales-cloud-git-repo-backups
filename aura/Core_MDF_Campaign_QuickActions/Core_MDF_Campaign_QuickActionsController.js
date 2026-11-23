({
	doInit : function(component, event, helper) {
        var actionAPI = component.find("quickActionAPI");
        var origin= event.getSource();
        console.log('==>origin==>'+origin);
        var res = actionAPI.getSelectedActions();
        // is community or not checking
        var action = component.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue(); // do any operation needed here
            if(!isCommunity) {
                actionAPI.getSelectedActions().then(function(result){
                    console.log(result.actions[0].actionName);
                    if(result.actions[0].actionName == "Campaign.Clone"){
                        component.set('v.mode','clone');
                        component.set('v.modeLoaded','true');
                    }
                    
                }).catch(function(e){
                    if(e.errors){
                        component.set('v.mode','edit');
                        component.set('v.modeLoaded','true');
                        
                    }
                });
            } else {
                component.set('v.mode','clone');
        		component.set('v.modeLoaded','true');
            }
        });
        $A.enqueueAction(action);
        
		helper.fetchRecordInfo(component, event);
        console.log('recordInfoLoaded '+component.get("v.recordInfoLoaded"));
	},
    fetchFieldSetInfo : function(component, event, helper) {
        console.log('recordInfoLoaded '+component.get("v.recordInfoLoaded"));
        if(component.get("v.recordInfoLoaded")) {
        	helper.fetchFieldSetInfo(component, event);
        }
	},
})