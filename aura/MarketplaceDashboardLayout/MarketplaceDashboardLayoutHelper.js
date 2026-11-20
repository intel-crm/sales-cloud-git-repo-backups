({
   /* fetchPartnerList : function(component, helper) {
        var action = component.get("c.getAllPartnerList");
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.partnerList", returnValue);
                console.log("ReturnValue", returnValue);
            } else if (status === "INCOMPLETE") {
                // do something?
            } else if (status === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    };
                }
            } else {
                reject('Unknown error.');
            }
        });
        $A.enqueueAction(action);
    },
    
    updateOnePartnerId : function(component, helper, selectedOption){
        //var selectedOption = component.find("selectPartner").get("v.value");
        console.log('Option : ', selectedOption);
        
        var action = component.get("c.updateAdminOnePartnerId");
        action.setParams({
            partnerId : selectedOption
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.showSpinner", false);
            } else if (status === "INCOMPLETE") {
                // do something?
            } else if (status === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    };
                }
            } else {
                reject('Unknown error.');
            }
        });
        $A.enqueueAction(action);
        
    }	*/
})