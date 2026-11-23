({
  
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"Success",
                    "message": "Order created successfully."
                });
                toastEvent.fire(); 
        
    	var payload = event.getParams().response;
		console.log(payload.id);
        var recId = JSON.stringify(payload.id);
        var recordId = JSON.parse(recId);
       	var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId":  recordId,
                "slideDevName": "related"
            });
            navEvt.fire();
           
    },

    handleOrderType : function(component, event, helper) {
        var selectValue= component.find('orderTypePicklist').get('v.value');
        if(selectValue == 'Corporate License Order'){
            component.set("v.showdiv", true);
        }
        else{
            component.set("v.showdiv", false);
        }
    },
    
    
    handleCloseModal: function(component, event, helper) {
         	var homeEvt = $A.get("e.force:navigateToObjectHome");
         	homeEvt.setParams({
                "scope": "Order"
            });
            homeEvt.fire();
         // component.set("v.order","");
    },
})