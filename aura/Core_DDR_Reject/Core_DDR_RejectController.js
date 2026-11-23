({
    doInit : function(component, event, helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "designRegisId" : component.get("v.recordId"),
            "objectType" : "Core_Design_Registration__c",
            "fieldName" : "Core_Rejection_Reason_Nm__c"
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var message = response.getReturnValue().message;
                component.set("v.designRegisObject", response.getReturnValue().designRegisObj);
                if(message == "success"){
                    component.set("v.alertMessage", "success");
                    var allValues = response.getReturnValue().pickListValueList;
                    var opts = [];
                    if (allValues != undefined && allValues.length > 0) {
                        for (var i = 0; i < allValues.length; i++) {
                            if(i == 0){
                                opts.push({
                                    class: "optionClass",
                                    label: allValues[i],
                                    value: allValues[i],
                                    selected : true
                                });
                            }else{
                                opts.push({
                                    class: "optionClass",
                                    label: allValues[i],
                                    value: allValues[i]
                                });
                            }
                        }
                    }
                    component.find("pickList").set("v.options", opts);
                }else{
                    component.set("v.alertMessage", "error");
                    component.set("v.message", message);
                }
            }else{
                console.log("Error on fetching picklist values "+response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    saveDesignRegistration : function(component, event, helper) {
        var designObj = component.get("v.designRegisObject");
        if(typeof component.get("v.designRegisObject.Core_Rejection_Comment_Txt__c") == "undefined" || component.get("v.designRegisObject.Core_Rejection_Comment_Txt__c") == ''){
            var msg = 'Please enter some valid input. \n';
            msg += 'Input is not optional. \n';
            msg += 'You must enter a value.';
            var inputCmp = component.find("commentText");
            inputCmp.set("v.errors", [{message:msg}]);
        }else{
            component.set("v.commentError","");
            var action = component.get("c.updateDesignRegistration");
            action.setParams({
                "designRegis" : designObj
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    
                }else{
                    console.log("Error on updating design registration "+response.getError());
                }
            });
            $A.enqueueAction(action);
            $A.get("e.force:closeQuickAction").fire();
            $A.get("e.force:refreshView").fire();
        }
    },
    
    cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    waiting: function(component, event, helper) {
        document.getElementById("Accspinner").style.display = "block";
    },
    
    doneWaiting: function(component, event, helper) {
        document.getElementById("Accspinner").style.display = "none";
    },
})