({
  doInit: function (component, event, helper) {
    let removeCommunityPageNameFromUrl = false;
    let isExternalUser = component.get("c.isPartnerUser");  // NOSONAR
    isExternalUser.setCallback(this, function (response) {
      let state = response.getState();  // NOSONAR
      if (state === "SUCCESS") {
        let communityUser = response.getReturnValue();  // NOSONAR
        removeCommunityPageNameFromUrl = !communityUser;
        helper.getDocumentUrl(component, event, removeCommunityPageNameFromUrl);
      } else {
        console.log("Error in getDocumentId");
      }
    });
    $A.enqueueAction(isExternalUser);
  }
});