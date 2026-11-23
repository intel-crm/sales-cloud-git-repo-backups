({   
    loadQuestion: function(component, event, helper) {
  var ques = component.getEvent("dynamicQuestionEvt");       
        ques.setParams({
            valueOfDynamicQ:component.get("v.newPFRq")
        }).fire();        
    }  
})