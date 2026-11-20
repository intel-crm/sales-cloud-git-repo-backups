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
    },
    processAIStatus: function (component, event, helper, isRPMUserAlpha) {
        if (isRPMUserAlpha) {
            let aiIntegrationStatus = component.get("v.aiIntegrationStatus"); 
            let quoteProgramType = component.get("v.programType"); 
            let quoteLineStatus = component.get("v.inputText");
            
            if (aiIntegrationStatus == "Success"  && quoteProgramType == "Tender" && quoteLineStatus == "Pending Further Intel Review") {
                component.set("v.aiIconName", "utility:check");
                component.set("v.aiAlternativeText", 'Application Agent Status: '+aiIntegrationStatus);
                component.set("v.aiVariant", "Success");
            } else if ((aiIntegrationStatus == "In Progress") && quoteProgramType == "Tender" && quoteLineStatus == "Pending Further Intel Review"){
                component.set("v.aiIconName", "utility:clock");
                component.set("v.aiAlternativeText", 'Application Agent Status: '+aiIntegrationStatus);
                component.set("v.aiVariant", "Warning");
            } else if (aiIntegrationStatus == "Failed" && quoteLineStatus == "Pending Further Intel Review") {
                component.set("v.aiIconName", "utility:close");
                component.set("v.aiAlternativeText", 'Application Agent Status: '+aiIntegrationStatus);
                component.set("v.aiVariant", "Error");
            }
        }
        
    }
})