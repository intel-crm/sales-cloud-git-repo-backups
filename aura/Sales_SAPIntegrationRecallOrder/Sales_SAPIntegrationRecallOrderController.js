({
    init : function(component, event, helper) {
        var action = component.get("c.updateOrderRecallStatus");
        action.setParams({"orderId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                if(response.getReturnValue()){
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Order Cancelled from SAP",
                     "type": "success"
                });
                toastEvent.fire();
                }
                else{
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Failure!",
                        "message": "Order Recall failed",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                window.setTimeout(function(){ 
                    location.reload(true);
                }, 2000);
            } else {
                var errors = response.getError();
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": errors[0].message,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})