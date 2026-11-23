({
    //this method will be used to load all the matching exceptions. This is called from loadExceptionList method from the controller js
    onLoad: function(component, event) {
        console.log('Testing Error');
        //call apex class method
        var action = component.get('c.fetchUserType');
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
             component.set("v.isEnabled", response.getReturnValue());
                console.log('enabled' + component.get("v.isEnabled"));
                if(component.get("v.isEnabled") == false){
                    var toastEvent = $A.get("e.force:showToast");
                                       toastEvent.setParams({
                                           mode: 'sticky',
                                           message: 'You do not have access to map Exceptions to Case.',
                                           type : 'error'
                                       });

                                       toastEvent.fire();
                }
              this.fetchExceptionRecords(component,event);
            }
        });
        $A.enqueueAction(action);
        
    },
    fetchExceptionRecords : function(component,event){
        var action = component.get('c.fetchExceptionRecords');
		action.setParams({
            "caseRecordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in exceptionWrapperList attribute on component.
                if(!$A.util.isEmpty(response.getReturnValue())){
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
                        var toastEventSuccess = $A.get("e.force:showToast");
                        toastEventSuccess.setParams({
                            title: 'Success',
                            type: 'success',
                            message: $A.get("$Label.c.Core_MDF_ECMs_Created")//"Exception Case Mapping(s) created."
                        });
                        toastEventSuccess.fire();

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
                        var toastEventFail = $A.get("e.force:showToast");
                        toastEventFail.setParams({
                            title: 'Failed',
                            type: 'error',
                            message: $A.get("Exception Case Mapping(s) were not created.")
                        });
                        toastEventFail.fire();
                    }                    
                }
            }else{
                component.set("v.disableSave", false);
                component.set("v.saveECMsFailed", true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Failed',
                    type: 'error',
                    message: $A.get("Exception Case Mapping(s) were not created.")
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})