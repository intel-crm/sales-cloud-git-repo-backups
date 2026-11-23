({
    callComponent : function(component,event,helper){
        var apprRecId = component.get("v.recordId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:Core_MDF_CriteriaRule",
            componentAttributes :{recordId: apprRecId}
            
        });
       
    evt.fire();
    }
})