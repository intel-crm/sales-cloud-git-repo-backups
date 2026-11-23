({
    checkOldFCRecords : function(component, event, helper) {
        helper.showSpinner(component);
        var action = component.get('c.checkOldFCRecords');
        
        action.setParams({
            "opportunityId" : component.get("v.recordId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                //component.set("v.spinner", false);
                var message = a.getReturnValue();
                if(JSON.stringify(message) == "true"){
                	var modal = component.find("woWarningModal");
                    $A.util.removeClass(modal,"slds-hide");
                    let button = component.find("OKbuttonid");
                    button.set("v.disabled",true);
                    let Cnbutton = component.find("Cancelbuttonid");
                    Cnbutton.set("v.disabled",true);
                }
                else{
                	helper.saveData(component, event, helper);
                }
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
        
    },
    
	saveData : function(component, event, helper) {
        helper.showSpinner(component);
        var modal = component.find("woWarningModal");
        $A.util.addClass(modal,"slds-hide");
		var action = component.get('c.submitData'); 
        
        action.setParams({
            "startDate" : component.get("v.startDate"),
            "selectedQuarters" : component.get("v.selectedQuarters"),
            "opportunityId" : component.get("v.recordId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                debugger;
                var message = a.getReturnValue();
                if(message.message == ''){
                    component.set("v.isModalOpen", false);
                    helper.showToast(component, event, helper,"Successfully Scheduled","success");
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    helper.showToast(component, event, helper,message.message,"error");
                }
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
	},
    /*checkDate : function(component, event, helper) {
        helper.showSpinner(component);
        var action = component.get('c.checkDate');
        action.setParams({
            "startDate" : component.get("v.startDate"),
            "selectedQuarters" : component.get("v.selectedQuarters"),
            "opportunityId" : component.get("v.recordId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                //component.set("v.spinner", false);
                var message = a.getReturnValue();
                if(!message.allowSave){
                    let button = component.find("OKbuttonid");
        			button.set("v.disabled",true);
                    helper.showToast(component, event, helper,message,"error");
                }
                else if(message.allowSave){
                    let button = component.find("OKbuttonid");
        			button.set("v.disabled",false);
                }
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },*/
    
    showQuarterField : function(component, event, helper,message,type) {
        debugger;
        helper.showSpinner(component);
		var action = component.get('c.showQuarters');
        action.setParams({
            "opportunityId" : component.get("v.recordId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var message = a.getReturnValue();
                if(message.message ==""){
                    component.set("v.displayQuarters",message.qrtrsValues);
                }
                else{
                    let button = component.find("OKbuttonid");
        			button.set("v.disabled",true);
                    helper.showToast(component, event, helper,message.message,"error");
                }
            }else{
                var errors = a.getError();
                if (errors) {
                    console.log(errors);
                    if (errors[0] && errors[0].message) {
                        console.log("Error on submit quarter for approval "+errors[0].message);
                        helper.toastMessage(component, "error", errors[0].message);
                    }
                }  
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);        
    },
    
    showToast : function(component, event, helper,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": message.message
        });
        toastEvent.fire(); 
    },
    showSpinner: function(component) {
		var spinnerMain =  component.find("Spinner");
		$A.util.removeClass(spinnerMain, "slds-hide");
	},
 
	hideSpinner : function(component) {
		var spinnerMain =  component.find("Spinner");
		$A.util.addClass(spinnerMain, "slds-hide");
	},
})