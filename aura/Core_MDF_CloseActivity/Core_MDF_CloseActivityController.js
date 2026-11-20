({
  // method called on click of inactivate account button
  doInit: function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        if(pageReference != null){
            component.set("v.recordId", pageReference.state.c__recordId);
        }
        helper.incloseactivity(component, event, helper);
        helper.checkOutcomebaseActivity(component, event, helper);
    },
    activityEligibiltyForClose: function(component, event, helper) {
        helper.activityEligibiltyForClose(component, event, helper);
    },
    closeModel: function(component, event, helper) {
        var isOutcome = component.get("v.isOutcomeBased");
        var recordId = component.get("v.recordId");
        var communityBaseUrl = $A.get("$Label.c.Core_MDF_PFRCommunityLink");
        var path = window.location.pathname;
        if (isOutcome) {
            var isCommunity = path.includes('/s/');
            if (isCommunity) {
                window.location.href =
                    communityBaseUrl + 's/outcome-based-campaign-details?recordId=' + recordId;
            } else {
                window.location.href =
                    '/lightning/n/Core_MDF_Outcome_Based_Campaign_Detail?c__recordId=' + recordId;
            }
        }
        else {
            var navEvt = $A.get("e.force:navigateToSObject");
            if (navEvt) {
                navEvt.setParams({
                    recordId: recordId,
                    slideDevName: "detail"
                });
                navEvt.fire();
            }
            
            var closeEvt = $A.get("e.force:closeQuickAction");
            if (closeEvt) {
                closeEvt.fire();
            }
        }
    }
});