({
    doInit : function(component, event, helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "leadId" : component.get("v.recordId"),
            "objectType" : "Lead",
            "fieldName" : "Core_Rejection__c"
        });
        action.setCallback(this, function(response){
            var pickListVar = component.find("pickList");
            var state = response.getState();
            if(state === "SUCCESS"){
                var message = response.getReturnValue().message;
                component.set("v.leadObject", response.getReturnValue().leadObj);
                if(message == "success"){
                    var allValues = response.getReturnValue().pickListValueList;
                    var opts = [];
                    if (allValues != undefined && allValues.length > 0) {
                        opts.push({
                            class: "optionClass",
                            label: "--- None ---",
                            value: ""
                        });
                    }
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
                    pickListVar.set("v.options", opts);
                }else{
                    component.set("v.alertMessage", message);
                }
            }else{
                console.log("Error on fetching picklist values "+response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    saveLead : function(component, event, helper) {
        var leadRecord = component.get("v.leadObject");
        console.log("leadRecord.Core_Rejection__c "+leadRecord.Core_Rejection__c);
        console.log("leadRecord.Core_Rejection_Comments__c "+leadRecord.Core_Rejection_Comments__c);
        if(leadRecord.Core_Rejection__c == null || leadRecord.Core_Rejection__c == "" || leadRecord.Core_Rejection_Comments__c == null || leadRecord.Core_Rejection_Comments__c == ""){
            var sMsg = 'Please enter some valid input. \n';
            sMsg += 'Input is not optional. \n You must enter a value.';
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: sMsg,
                type : 'Error'
            });
            toastEvent.fire();
            return null;
        }
        var action = component.get("c.updateToLead");
        action.setParams({
            "leadObj" : component.get("v.leadObject")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                
            }else{
                console.log("Error on updating lead "+response.getError());
            }
        });
        $A.enqueueAction(action);
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    }
})