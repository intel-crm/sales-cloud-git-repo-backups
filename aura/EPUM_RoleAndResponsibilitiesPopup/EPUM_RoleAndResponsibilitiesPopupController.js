({
    
    doInit: function(component,event,helper){
       //After integration logic in openmodel will be put over here
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
        helper.getData(component);
        
    },
    openModel: function(component, event, helper) {
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        //on click of close, it should navigate to homepage of mp-- Need to update logic
        var viewRecordEvent = $A.get("e.force:navigateToURL");
        viewRecordEvent.setParams({
            "url": "/" + event.target.id
        });
        viewRecordEvent.fire();
    },   
    gotoURL: function(component,event,helper){
        var childCmp = component.find("child");
        childCmp.gotoEPUMRnRPage();
    }
})