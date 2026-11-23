({
   /* init : function(component, event, helper) {
        var orderIds=new Array();
        orderIds.push(component.get("v.recordId"))
        var action0 = component.get("c.verifyOrder");
        action0.setParams({"orderIds": orderIds});
        action0.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var action = component.get("c.updateSapOrderStatus");
                action.setParams({"orderIdList": orderIds});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(component.isValid() && state == "SUCCESS"){
                        if(response.getReturnValue()){
                            $A.get("e.force:closeQuickAction").fire();
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Failure!",
                                "message": "Order Submission failed",
                                "type": "error"
                            });
                            toastEvent.fire();
                        }
                        else{
                            $A.get("e.force:closeQuickAction").fire();
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "Order Submitted to SAP",
                                "type": "success"
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
                        if(!errors[0].message.includes('Invalid')){
                            var action1 = component.get("c.updateOrderStatusToFailure");
                            action1.setParams({"orderId": component.get("v.recordId"),"message": errors[0].message});
                            action1.setCallback(this, function(response) {
                                var state = response.getState();
                                if(component.isValid() && state == "SUCCESS"){
                                    console.log('Order updated');
                                }
                                else{
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
                            $A.enqueueAction(action1);
                            window.setTimeout(function(){ 
                                location.reload(true);
                            }, 2000); 
                        }
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                var errors = response.getError();
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "mode": "sticky",
                    "title": "Error!",
                    "message": errors[0].message,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action0);
    },*/
    
    closeModal : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})