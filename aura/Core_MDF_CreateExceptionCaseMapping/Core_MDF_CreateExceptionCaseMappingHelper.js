({
    //this method will be used to load all the matching exceptions. This is called from loadExceptionList method from the controller js
    onLoad: function(component, event) {
        //call apex class method
        var action = component.get('c.fetchExceptionRecords');
		action.setParams({
            "caseRecordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in exceptionWrapperList attribute on component.
                if(response.getReturnValue() != null ){
                    component.set("v.exceptionWrapperList", response.getReturnValue());
                    component.set("v.noMatchException", false);
                    component.set("v.disableSave", true);
                    component.set("v.selectedCount", 0);
                }else{
                    component.set("v.noMatchException", true);
                    component.set("v.disableSave", true);
                    component.set("v.selectedCount", 0);
                }
            }
        });
        $A.enqueueAction(action);
    },
    //this method will be used to save all the ECM records. This is called from saveECMRecords method from the controller js
    saveECMsHelper : function(component,event) {
        // call the apex class method 
        var action = component.get("c.saveECMRecordsCtrl");
        // set param to method  
        action.setParams({
            "caseRecordId": component.get("v.recordId"),
            "listToSaveString": JSON.stringify(component.get("v.exceptionWrapperList"))
        });
        //alert('Exception Wrapper List: ' + JSON.stringify(component.get("v.exceptionWrapperList")));
        // set a callBack
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === 'SUCCESS'){
                if(response.getReturnValue() != null){
                    if(response.getReturnValue() == true){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Success',
                            type: 'success',
                            message: $A.get("$Label.c.Core_MDF_ECMs_Created")//"Exception Case Mapping(s) created."
                        });
                        toastEvent.fire();

                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get('v.recordId'),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();

                        //alert('Settin time out');
                        setTimeout(function () {
                            window.location.reload();
                        }, 2000);
                    }
                    else{
                        component.set("v.saveECMsFailed", true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Failed',
                            type: 'failed',
                            message: $A.get("Exception Case Mapping(s) were not created.")
                        });
                        toastEvent.fire();
                    }                    
                }
            }else{
                component.set("v.disableSave", false);
                component.set("v.saveECMsFailed", true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Failed',
                    type: 'failed',
                    message: $A.get("Exception Case Mapping(s) were not created.")
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})