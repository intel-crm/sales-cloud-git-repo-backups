({
  getQStatus: function (component, event, helper) {
    let action = component.get("c.getQuoteStatus");  // NOSONAR
    let rid = component.get("v.recordId");  // NOSONAR
    action.setParams({ recordId: rid });
    action.setCallback(this, function (response) {
      let state = response.getState();   // NOSONAR
      if (state === "SUCCESS") {
        component.set("v.quoteStatus", response.getReturnValue());
      } else {
        console.log("Error in getting Quote Status");
      }
    });
    $A.enqueueAction(action);
  }
});