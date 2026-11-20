({
    doInit: function (component, event, helper) {
        //console.log('docTypes in childComp:' + component.get('v.documentTypes'));
        let list = component.get('v.documentTypes') != '' && component.get('v.documentTypes') != undefined ? component.get('v.documentTypes').split(';') : "";
        if (list != "" && list.indexOf(component.get('v.element')) != -1) {
            component.set('v.condition', true);
            component.set('v.checkboxvalue', true);
            
        } else { component.set('v.condition', false); }
    },
    
    // Used for displaying the checked/unchecked document types in Claim creation table
    handleTable: function (component, event, helper) {
        if(component.get('v.disabled')){
            var checkboxValue = component.get('v.checkboxvalue');
            let list = component.get('v.documentTypes') != '' && component.get('v.documentTypes') != undefined ? component.get('v.documentTypes').split(';') : "";
            if (list != "" && list.indexOf(component.get('v.element')) != -1) {
                component.set('v.condition', true);
                component.set('v.checkboxvalue', checkboxValue);
                
            } else { component.set('v.condition', false); }
        }
    },
    
    fireParentEvent: function (component, event, helper) {
        //var changeEvent = $A.get('e.c:Core_MDF_checkboxChangeEvent');
        var changeEvent = component.getEvent('checkboxChangeEvent');
        component.set('v.checkboxvalue', event.getSource().get("v.checked"));
        changeEvent.setParams({
            "checkboxName": event.getSource().get("v.name")
        });
        console.log("inside fireParentEvent", event.getSource().get("v.name"));
        changeEvent.fire();
    }
})