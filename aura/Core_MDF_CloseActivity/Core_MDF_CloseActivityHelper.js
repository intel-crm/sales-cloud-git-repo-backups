({
  incloseactivity: function (component, event, helper) {
    var permissionSetName;
    var permissionSets = [];

    permissionSetName = $A.get(
      "$Label.c.Core_MDF_Close_Activity_Allowed_Roles"
    );
    permissionSets = permissionSetName.split(",");
    var userperMap = component.get("v.userperMap");
    userperMap["closeactivity"] = permissionSets;

    var action = component.get("c.userEligibilitytoIncloseActivity");
    action.setParams({
      permissionsets: userperMap
    });

    action.setCallback(this, function (response) {
      if (
        response.getState() === "SUCCESS" &&
        response.getReturnValue() != null
      ) {
        if (response.getReturnValue()) {
          component.set("v.userEligible", true);
        } else {
          component.set("v.userEligible", false);
          component.set("v.activityNotEligibleToClose", true);
          component.set(
            "v.errorMsg",
            $A.get("$Label.c.Core_MDF_UserPermissiontoCloseActivity")
          );
        }
      }
    });
    $A.enqueueAction(action);
  },

  activityEligibiltyForClose: function (component, event, helper) {
    component.set("v.userEligible", false);
    component.set("v.activityNotEligibleToClose", false);
    component.set("v.activityhasActiveClaim", false);
    component.set("v.serverFilure", false);
    component.set("v.activityhasActiveClaim", '');

    var actionclose = component.get("c.checkActivityEligibiltyForClose");
    actionclose.setParams({
      activityId: component.get("v.recordId")
    });
    actionclose.setCallback(this, function (response) {
      if (
        response.getState() === "SUCCESS" &&
        response.getReturnValue() != null
      ) {

        var wrapInst = response.getReturnValue();
        if (wrapInst != null) {
          component.set("v.countOfClaimRecords", wrapInst.listOfClaim.length);
          if (!wrapInst.isValidActStatus && !wrapInst.retailActivity && !wrapInst.ipaActivity) {
            component.set("v.activityerrors", $A.get("$Label.c.Core_MDF_Close_Activity_InValidStatus_Error"));
          } else if(!wrapInst.isValidActStatus && wrapInst.retailActivity){
             component.set("v.activityerrors", $A.get("$Label.c.Core_MDF_Close_Activity_InValidStatus_Retail_Error"));
          } else if (!wrapInst.isValidActStatus && wrapInst.ipaActivity) {
            component.set("v.activityerrors", $A.get("$Label.c.Core_MDF_Close_Activity_InValidStatus_IPA_Error"));
          } else if (wrapInst.activityNotStarted) {
            component.set("v.activityerrors", $A.get("$Label.c.Core_MDF_Close_Activity_has_NotStarted"));
          } else if (wrapInst.isValidActivity && wrapInst.hasActiveClaims ) {
            component.set("v.activityhasActiveClaim", $A.get("$Label.c.Core_MDF_Activity_has_active_claims"));
          } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: $A.get("$Label.c.Core_MDF_CloseActivity_Success_Title"),
              type: 'success',
              message: $A.get("$Label.c.Core_MDF_CloseActivity_Success_Message")
            });
            toastEvent.fire();
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
              }
            $A.get("e.force:closeQuickAction").fire();
            setTimeout(function () {
              window.location.reload();
            }, 2500);
          }
        }
      } else {
        component.set("v.serverFilure", true);
        component.set(
          "v.errorMsg",
          $A.get("$Label.c.Core_MDF_ActivityCloseFail")
        );
        if (response.getError().length > 0) {
          component.set(
            "v.errorDetail",
            "Error Detail-" + response.getError()[0].message
          );
        }
      }
    });
    $A.enqueueAction(actionclose);
  },
    
    checkOutcomebaseActivity: function (component, event, helper) {
    var action = component.get("c.isOutcomeBasedActivity");
    action.setParams({
        "pfrId": component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var result = response.getReturnValue();
            component.set("v.isOutcomeBased", result);
        } 
        else {
            var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
            helper.fireToastEvent(component, errorMessage, "5000", "error");
        }
    });

    $A.enqueueAction(action);
}

});