({
    doInit: function(component, event, helper) {
        helper.onInit(component,event,helper);
    },
    callEditScorecard : function(component, event, helper){        
        var editRecordEvent = $A.get("e.force:editRecord");      
        editRecordEvent.setParams({
            "recordId": component.get("v.scoreCardId")
        });
        editRecordEvent.fire();        
    }
})