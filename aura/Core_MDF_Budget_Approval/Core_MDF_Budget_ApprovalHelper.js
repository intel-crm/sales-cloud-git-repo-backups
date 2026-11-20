({
	call : function(action, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            if(params){
                action.setParams(params);
            }
            action.setCallback(this, function(a){
                if(a.getState() == "SUCCESS"){
                    resolve(a.getReturnValue());
                } else {
                    reject(a.getError());
                }
           });
           $A.enqueueAction(action);
        }));
    },
    
    toastMessage : function(toastTitleLabel,toastTypeLabel,toastMessageLabel){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            //title: toastTitleLabel,
            type: toastTypeLabel,
            message: toastMessageLabel
        });
        toastEvent.fire();  
    },

    windowTimeOut : function(){
        window.setTimeout(
            $A.getCallback(function () {
                window.location.reload();
            }), 2400
        );
    }
})