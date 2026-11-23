({
    doInit : function(cmp,evt,hlpr){
        
        console.log("old value: " + evt.getParam("oldValue"));
        console.log("current value: " + evt.getParam("value"));
    	hlpr.callApex(cmp,evt,hlpr);
    },
    closeModel : function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
      helper.handleSkipFeedback(component, event, helper);
   },
    handleSave : function(component, event, helper) {
        helper.saveFeedback(component, event, helper);
    }
})