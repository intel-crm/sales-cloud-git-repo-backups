({
	doInit: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        //component.set("v.loaded", true);
        console.log('####rec--aura'+component.get("v.recordId"));
        var whichOne = event.getSource().getLocalId();
        console.log('BUTTON'+whichOne);
        //console.log('##AA--aura'+component.get("v.pageReference").state.c__recordId);
    },

    handleClose: function (component, event, helper) {
        console.log('##rec'+component.get("v.recordId"));
    $A.get("e.force:refreshView").fire();
    $A.get("e.force:closeQuickAction").fire();
    }
});