({
    doInit : function(component, event, helper) {
        console.log('AA rec--aura'+component.get("v.recordId"));
        var PCC = component.get("c.showToast");
        PCC.setParams({
            "rebateClaimId" : component.get("v.recordId"),
        });
        PCC.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("AA Response : "+JSON.stringify(response.getReturnValue().noErrorToast));
                component.set("v.noErrorToast", response.getReturnValue().noErrorToast);
                if(response.getReturnValue().noErrorToast === false) {
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": response.getReturnValue().errorMsg,
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            }else{
                $A.get("e.force:closeQuickAction").fire();
                const errorMsgSer = response.getError()[0].message;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": errorMsgSer,
                    "type": "error"
                });
                toastEvent.fire();
                console.log("AA Error aura : "+JSON.stringify(response.getError())+ JSON.stringify(errorMsgSer));
            }
        });
        $A.enqueueAction(PCC); 
        //$A.get("e.force:closeQuickAction").fire();
    },
    handleClose: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
});