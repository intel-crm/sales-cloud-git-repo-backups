({
    doInit : function(component, event, helper) {
        debugger;
        helper.myAction(component,event,helper);
    },
    handleEv :function(component, event, helper){
        helper.triggerEv(component,event,helper);
    }
})