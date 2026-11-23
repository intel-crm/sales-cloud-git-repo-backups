({
    handleLoad: function(component,event){
    	component.set("v.disableSave",false);
    },
    
    handleSubmit: function(component,event){
        component.set("v.disableSave",true);
        event.preventDefault(); // stop the form from submitting
        var reason=component.find("reasonInput").get("v.value");
        console.log('reason>'+reason.length);
        if(reason.length>100){
           component.set("v.disableSave",false);
           component.set("v.errorMsg",'Please input a reason within 100 characters');
        }
        else{
            component.set("v.errorMsg",'');
            const fields = event.getParam("fields");
            fields["SBQQ__Status__c"] = 'Cancelled';
            component.find('updateStatus').submit(fields);
        }
    },
    
    handleSuccess: function(component,event){
		var closeAction = $A.get("e.force:closeQuickAction");
        closeAction.fire();
        $A.get('e.force:refreshView').fire();
        var errorMessage = 'Quote Request was successfully Cancelled';
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": errorMessage,
            "type": "success"
        });
        toastEvent.fire();
    },
     
    handleCancel: function(component,event){
        var closeAction = $A.get("e.force:closeQuickAction");
        closeAction.fire();
    }
})