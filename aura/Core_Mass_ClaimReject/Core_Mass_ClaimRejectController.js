({
    doInit : function(component, event, helper) {
        if(component.get("v.alertMessage") == ""){
            var action = component.get("c.getPicklistValues");
            action.setParams({
                "objectType" : "Lead",
                "fieldName" : "Core_Rejection__c"
            });
            action.setCallback(this, function(response){
                var pickListVar = component.find("pickList");
                var state = response.getState();
                if(state === "SUCCESS"){
                    
                    var allValues = response.getReturnValue();
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
                    console.log("Error on fetching picklist values "+response.getError());
                }
            });
            $A.enqueueAction(action);
        }
        component.set("v.isOpen", true);
    },
    
    saveLeads : function(component, event, helper) {
        console.log(JSON.stringify(component.get("v.selectedLeads")));
        var action = component.get("c.rejectSelectedLeads");
        action.setParams({
            selectedLeads : component.get("v.selectedLeads"),
            rejectionReason : component.get("v.rejectionReason"),
            rejectionComments : component.get("v.rejectionComments")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var msg = $A.get("$Label.c.Core_RejectLead_Msg");
                component.set("v.alertMessage", msg);
            }else{
                console.log("Error on mass rejection of lead "+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModel : function(component, event, helper) {
        window.open(component.get("v.listViewUrl"),"_self");
    }
})