({
getDocumentUrl: function (component, event, removeCommunityPageName) {
  let action = component.get("c.getDocumentId"); // NOSONAR

  action.setParams({
    name: $A.get("$Label.c.Pricing_Tender_T_C_Document")
  });

  let url = $A.get("$Label.c.Pricing_Tender_File_Download_Url");
  const environment = $A.get("$Label.c.Pricing_IQR_SFDC_Environment");

  console.log("1. Base URL from Label:", url);
  console.log("2. Environment:", environment);

  if (removeCommunityPageName && environment != 'PRODUCTION') {
    url = url.split("/");
    url.splice(1, 1);
    url = url.join("/");
    console.log("3. Adjusted URL (Non-Prod):", url);
  }

  action.setCallback(this, function (response) {
    let state = response.getState(); // NOSONAR
    console.log("4. Apex Call State:", state);

    if (state === "SUCCESS") {
      let docId = response.getReturnValue();
      console.log("5. Document ID from Apex:", docId);

      url = url + docId;
      console.log("6. Final Complete URL:", encodeURI(url));

      component.set("v.url", encodeURI(url));
    } else {
      console.log("Error in getDocumentId:", response.getError());
    }
  });

  $A.enqueueAction(action);
}
});