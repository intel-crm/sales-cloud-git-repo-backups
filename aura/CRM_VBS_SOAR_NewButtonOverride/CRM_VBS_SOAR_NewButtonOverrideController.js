({
	doInit: function (component, event, helper) {
        //component.set("v.loaded", true);
        console.log('####rec--aura'+component.get("v.recordId"));
        console.log('##AA--aura'+component.get("v.pageReference").state.c__recordId);
    }
})