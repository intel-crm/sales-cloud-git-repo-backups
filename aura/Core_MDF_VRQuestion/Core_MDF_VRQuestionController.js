({
  doInit: function(component) {
    $A.enqueueAction(component.get("c.handleResponse"));
  },

  loadQuestion: function(component,event) {
      
      var ques = component.getEvent("dynamicQuestionEvt");
      var attrValue = event.getSource().get("v.value");
      component.set("v.newPFRq.Core_MDF_Incentive_Opted_In_ind__c",attrValue);

    ques
      .setParams({
        valueOfDynamicQ: component.get("v.newPFRq")
      })
      .fire();
  },

  handleResponse: function(component,event) {
    var response = component.get("v.newPFRq.Core_MDF_Incentive_Question_ind__c");

    if (response == "Yes") {
     component.set("v.vrQuestionList[0].otherIncentive", true);
    } else if (response == "No") {
          component.set("v.vrQuestionList[0].otherIncentive", false);
      component.set("v.newPFRq.Core_MDF_Incentive_Opted_In_ind__c", "No");
    }

    //this.loadQuestion(component);
  }
});