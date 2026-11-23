({
    callAuraMethod : function(component, event, helper) {
        var alertMsg = $A.get("$Label.c.Core_MDF_Error_Potenial_Winner");        
        var childCmp = component.find("utilComp");
        console.log(childCmp);
        childCmp.ToastMessageUtility(alertMsg,"Error!","error");
    }
})