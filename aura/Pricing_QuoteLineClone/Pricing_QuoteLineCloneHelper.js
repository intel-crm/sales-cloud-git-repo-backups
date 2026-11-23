({
  cloneQuoteLine: function (component, event, helper) {
    let cloneAction = component.get("c.doClone");   // NOSONAR
    let quoteLineObject = component.get("v.quoteLine");  // NOSONAR
    console.log('QLI Record:'+JSON.stringify(component.get("v.quoteLine")));
    quoteLineObject.Id = component.get("v.recordId");

    cloneAction.setParams({
      quoteLine: quoteLineObject,
      action: component.get("v.action")
    });
    cloneAction.setCallback(this, function (response) {
      let state = response.getState();  // NOSONAR
      let returnValue = response.getReturnValue();  // NOSONAR
      if (component.isValid()) {
        if (state === "SUCCESS") {
          component.set("v.messageNotification", returnValue.messageResult);
          component.set("v.isSuccess", returnValue.isSuccess);
          component.find("mySpinner").set("v.class", "slds-hide");
        }
      }
    });

    $A.enqueueAction(cloneAction);
  }
});