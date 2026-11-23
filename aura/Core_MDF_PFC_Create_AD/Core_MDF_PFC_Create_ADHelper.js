({  
    //This helper function first checks isPFR and redirect to page accordingly
    closeModel: function (component,docIds) {
        //page url
        var sPageURL = decodeURIComponent(window.location.href);
        var objName;
        if ((sPageURL.toLowerCase()).includes(($A.get("$Label.c.Core_MDF_PFRText")).toLowerCase())) {
            var homeEvent = $A.get("e.force:navigateToSObject");
            homeEvent.setParams({
                "recordId": component.get("v.recordId")
            });
            homeEvent.fire();
        }else if(!$A.util.isUndefinedOrNull(component.get("v.batchRecordId"))){
            var homeEvent = $A.get("e.force:navigateToSObject");
            homeEvent.setParams({
                "recordId": component.get("v.batchRecordId")
            });
            homeEvent.fire();            
        }else {
            if(component.get("v.escalationId")!=null && component.get("v.escalationId")!=''
               && component.get("v.escalationId")!=undefined){
                var homeEvent = $A.get("e.force:navigateToSObject");
                homeEvent.setParams({
                    "recordId": component.get("v.escalationId")
                }); 
            }else{
                if(!component.get("v.isClaimEdit")){
                    objName = $A.get("$Label.c.Core_MDF_PFCText");
                    var homeEvent = $A.get("e.force:navigateToObjectHome");
                    homeEvent.setParams({
                        "scope": objName
                    });            
                }else{
                    var homeEvent = $A.get("e.force:navigateToSObject");
                    homeEvent.setParams({
                        "recordId": component.get("v.simpleNewClaim.Id")
                    });  
                }
            }
            homeEvent.fire();
        }           
    },
    
    //To show generic error message
    handleServerExceptions: function(component, returnValue) {
        // Error! Show Validation message through a toast UI message
        // Show error Modal
        var errorToastModal = component.find('errorToast');
        $A.util.removeClass(errorToastModal, "slds-hide");
        component.set("v.Spinner", false);
        var exceptionerrors = returnValue;
        
        // check if exceptionerrors is null or not
        if (exceptionerrors != null 
            && (exceptionerrors.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION') 
                || exceptionerrors.includes('INVALID_FIELD_FOR_INSERT_UPDATE'))) {
            // process the error message here
            // if its validation error message
            var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf(',') + 1);
            var errorMsg = splittedMessage.substring(0, splittedMessage.indexOf(":"));
            component.set("v.claimErrorMsg", errorMsg);    
        } else {
            // show general error message
            var genericMsg = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
            component.set("v.claimErrorMsg", genericMsg);
        }
        
        
        //Auto hide error modal after 4sec
        window.setTimeout($A.getCallback(function () {
            if (component.isValid()) {
                $A.util.addClass(errorToastModal, "slds-hide");
            }
        }), 4000);
        component.set("v.isSaveDisabled", false);
    },
})