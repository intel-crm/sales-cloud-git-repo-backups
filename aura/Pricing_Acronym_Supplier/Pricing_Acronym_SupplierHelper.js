({
    processRecord: function (component, event, helper, rpmUser) {
        if (rpmUser) {
            let integrationStatus = component.get("v.integrationStatus"); // NOSONAR
            let errorMessage = component.get("v.errorMessage"); // NOSONAR
            let quoteProgramType = component.get("v.programType"); // NOSONAR
            if (integrationStatus == "Complete"  && quoteProgramType == "Tender") {
                component.set("v.iconName", "utility:success");
                component.set("v.alternativeText", integrationStatus);
                component.set("v.variant", "Success");
            } else if ((integrationStatus == "Pending" || integrationStatus == "InProcess") && quoteProgramType == "Tender"){
                component.set("v.iconName", "utility:warning");
                component.set("v.alternativeText", integrationStatus);
                component.set("v.variant", "Warning");
            } else if (integrationStatus == "Error") {
                component.set("v.iconName", "utility:error");
                component.set("v.alternativeText", errorMessage);
                component.set("v.variant", "Error");
            }
        }
    }
})