({
    doInit : function(component, event, helper) {
        var action = component.get("c.getUserInformation");
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            console.log('storeSucess'+state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // console.log('storeResponse'+storeResponse);
                if(storeResponse.Name!=null){
                    component.set("v.userName", storeResponse.Name);
                    component.set("v.userEmail", storeResponse.Email);
                    if(storeResponse.AccountId!=null){
                        component.set("v.accountName", storeResponse.Account.Name);
                        component.set("v.accountGeo", storeResponse.Account.Core_Geo__c);
                    }
				}
                console.log(component.get("v.userType"));
            }else{
                var errors = response.getError();
                console.log("Error message: " + errors[0].message);
            }
        });
        $A.enqueueAction(action);
        console.log(action);
    }
})