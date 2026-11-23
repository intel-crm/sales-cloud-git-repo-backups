({
  doInit: function(component) {
    $A.enqueueAction(component.get("c.handleResponse"));
  },

  loadQuestion: function(component) {
    var ques = component.getEvent("dynamicQuestionEvt");

    ques
      .setParams({
        valueOfDynamicQ: component.get("v.newPFRq")
      })
      .fire();
  },

  handleResponse: function(component) {
    var response = component.get(
      "v.newPFRq.Core_MDF_Incentive_Question_ind__c"
    );

    if (response == "Yes") {
      component.set("v.showVROptIn", true);
    } else if (response == "No") {
      component.set("v.showVROptIn", false);
      component.set("v.newPFRq.Core_MDF_Incentive_Opted_In_ind__c", "No");
    }

    //this.loadQuestion(component);
  }
});