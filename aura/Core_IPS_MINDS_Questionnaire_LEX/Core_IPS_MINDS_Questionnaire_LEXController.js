({
	doInit : function(component, event, helper) {
		const pageReference = component.get("v.pageReference");
        var mode = pageReference.state.c__mode;
        if(mode=='minds'){
               component.set("v.MINDSQuestionnaire", true);
               
        }
	}
})