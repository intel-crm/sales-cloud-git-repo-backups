({   
    doinit : function(component, event, helper) {
        // to check if activity is opal and if opal set the competitive elemnts value to default 'NO'
        if(component.get("v.isOpalActivity")){
           //component.set("v.newPFRq.Core_MDF_Competitive_Elements__c", $A.get("$Label.c.Core_MDF_DQNo"));         
           // component.set("v.newPFRq.Core_MDF_Competitive_Elements__c", 'No');
           //START .changes for DE123122           
           component.set("v.newPFRq.Core_MDF_Competitive_Elements__c", $A.get("$Label.c.Core_MDF_NonTranslateNo"));
           //END .changes for DE123122  
        }
	},
    loadQuestion: function(component, event, helper) {
  var ques = component.getEvent("dynamicQuestionEvt");       
        ques.setParams({
            valueOfDynamicQ:component.get("v.newPFRq")
        }).fire();   
    }  
})