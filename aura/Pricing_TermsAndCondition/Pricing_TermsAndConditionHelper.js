({
  getDocumentUrl: function (component, event, removeCommunityPageName) {
    let action = component.get("c.getDocumentId"); // NOSONAR
    action.setParams({
      name: $A.get("$Label.c.Pricing_Tender_T_C_Document")
    });
    let url = $A.get("$Label.c.Pricing_Tender_File_Download_Url");
    const environment = $A.get("$Label.c.Pricing_IQR_SFDC_Environment");

    if (removeCommunityPageName && environment != 'PRODUCTION') {
      url = url.split("/");
      url.splice(1, 1);
      url = url.join("/");
    }

    action.setCallback(this, function (response) {
      let state = response.getState(); // NOSONAR
      if (state === "SUCCESS") {
        url = url + response.getReturnValue();
        component.set("v.url", url);
      } else {
        console.log("Error in getDocumentId");
      }
    });
    $A.enqueueAction(action);
  }
});