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

    getExistingData : function(component, event, helper) {
        var action = component.get("c.getExistingData");
        action.setParams({
            oppId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var resp = response.getReturnValue();
                debugger;
                if(resp != null){
                    component.set("v.isOppFeatures",resp.isOppFeatures);
                    component.set("v.isOppPtnrs",resp.isOppPtnrs);
                    component.set("v.isInactiveOppProduct",resp.inactiveOppProduct);
                    component.set("v.isOppPrdcts",resp.isOppPrdcts);
                    component.set("v.isAttachment",resp.isAttachment);
                    component.set("v.myTeamMemdata",resp.lstOppTeam);
                    component.set("v.myInactivePrdctdata",resp.inactiveOppProductList);
                    component.set("v.inactiveOppPartner",resp.inactiveOppPartner);
                    component.set("v.myInacPartnerdata",resp.inactiveOppPartnerList);
                }
            }
            else{
                console.log("Error on loading forecast record "+response.getError());
                helper.toastMessage(component, "error", JSON.stringify(response.getError()));
            }
            
        });
        $A.enqueueAction(action);
    },

    cloneOppHelper : function(component, event, helper) {
        var action = component.get("c.saveData");
        //var checkFeat = cmp.find("checkbox");
        action.setParams({
            oppId : component.get("v.recordId"),
            onCheckOppFeatures :component.get("v.onCheckOppFeatures"),
            onCheckOppPtnrs : component.get("v.onCheckOppPtnrs"),
            onCheckOppPrdcts : component.get("v.onCheckOppPrdcts"),
            onCheckAttachment : component.get("v.onCheckAttachment")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                helper.hideSpinner(component);
                $A.get("e.force:closeQuickAction").fire();
            }
            else{
                console.log("Error on loading forecast record "+response.getError());
                helper.toastMessage(component, "error", JSON.stringify(response.getError()));
            }
            
        });
        $A.enqueueAction(action);
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
})