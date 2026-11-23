({
    doInit: function (component, event, helper) {
        const recordId = component.get("v.recordId");
        const str = recordId.substring(0, 15);
        component.set("v.recordId", str);
        
        /*let action = component.get("c.reportingURLValue"); // NOSONAR
        action.setParams({ quoteIdPara: recordId });
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.cbaseURL", response.getReturnValue());
                let el = document.createElement("a"); // NOSONAR
                el.href = component.get("v.cbaseURL");
                if (el.protocol !== "https:") {
                    component.set("v.cbaseURL", null);
                }
            }
        });
        $A.enqueueAction(action);*/
        
    },

    closeWindow: function (component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    }
})