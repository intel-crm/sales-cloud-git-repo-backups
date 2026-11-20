({
	toastMessage : function(component, toastType, message) {
        var toastEvent = $A.get("e.force:showToast");
        var toastTitle = "";
        if(toastType == "success"){
            toastTitle = "Success!";
        }else{
            toastTitle = "Error!";
        }
        toastEvent.setParams({
            "title": toastTitle,
            "message": message,
            "type": toastType
        });
        toastEvent.fire();
	},
    
    toastMessageSticky : function(component, toastType, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        var toastTitle = "";
        var type = "";
        if(toastType == "success"){
            toastTitle = "Success!";
        }else{
            toastTitle = "Error!";
            type = "error";
        }
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "type": toastType,
            "mode": "sticky"
        });
        toastEvent.fire();
    },
    
    showToast : function(component, event, errorMessage1, errorMessage2){
        if(component.get("v.schQuantityError") == true && component.get("v.QuantityEditRestriction") == true){
            var combinedErrorMessage = errorMessage1 + '\n' + errorMessage2;
        }
        
        if(component.get("v.schQuantityError") == true && component.get("v.QuantityEditRestriction") == false){
            var combinedErrorMessage = errorMessage2;
        }
        
        if(component.get("v.schQuantityError") == false && component.get("v.QuantityEditRestriction") == true){
            var combinedErrorMessage = errorMessage1;
        }
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "message": combinedErrorMessage,
            "type": "error"
        });
        toastEvent.fire();
    }
})