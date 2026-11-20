({
    
    init: function(component, event, helper) {
        // Check user's profile 
        helper.checkUserProfile(component);
    },
    
    //Call cancelFromAura method in core_ReadOnlyFieldSet_Form lwc
    fireCancelEvent: function(component, event, helper) {
        component.find("leadForm").cancelFromAura();
    },
    //Call submitFromAura method in core_ReadOnlyFieldSet_Form lwc
    fireSaveEvent: function(component, event, helper) {
        console.log('Inside fire save event method');
      	component.find("leadForm").submitFromAura();
}
})