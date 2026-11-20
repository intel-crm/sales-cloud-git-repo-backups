({
  handleClick: function (component, event, helper) {
    let createRecordEvent = $A.get("e.force:createRecord");  // NOSONAR
    createRecordEvent.setParams({
      entityApiName: "SBQQ__Quote__c"
    });
    createRecordEvent.fire();
  }
});