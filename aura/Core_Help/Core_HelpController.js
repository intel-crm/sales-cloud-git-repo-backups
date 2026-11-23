({
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
        
    },
    
	openQuery : function(component, event, helper) {
        //component.set("v.isSpinner",true);
        component.set("v.isFeedbackOpen",false);
        component.set("v.mainDiv",false);
        component.set("v.isQueryOpen",true);
        //component.set("v.isSpinner",false);
	},
    
    openFeedback : function(component, event, helper) {
        component.set("v.isQueryOpen",false);
        component.set("v.mainDiv",false);
        component.set("v.isFeedbackOpen",true);
    },
   
    handleSave : function(component, event, helper) {
        helper.saveFeedback(component, event, helper);
    },
    
    handleURLClick : function(component, event, helper) {
        debugger;
        var clickedBtn = event.getSource().get("v.value");
       
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            'url': clickedBtn
        });
        urlEvent.fire();
    },
    handleMainMenu : function(component, event, helper) {
        component.set("v.isQueryOpen",false);
        component.set("v.mainDiv",true);
        component.set("v.isFeedbackOpen",false);
        component.set("v.isSuccess",false);
    },
    
    showToolTip : function(component, event, helper) {
        component.set("v.tooltip" , true);
        var clickedBtn = event.currentTarget.name;
        component.set("v.tooltipMessage",clickedBtn)
        //component.set("v.notooltip" , false);

    },
    hideToolTip : function(component, event, helper) {
        //component.set("v.notooltip" , true);
        component.set("v.tooltip" , false);

    },
})