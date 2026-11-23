({
    doInit: function (component, event, helper) {
        console.log('docTypes in childComp:' + component.get('v.documentTypes'));
        console.log('checkboxvalueindoint:' + component.get('v.checkboxvalue'));
        console.log("disabled::", component.get('v.disabled'));
        //if(component.get('v.disabled')){
            var checkboxValue = component.get('v.checkboxvalue');
            console.log('docTypes in childComp:' + component.get('v.documentTypes'));
            let list = component.get('v.documentTypes') != '' && component.get('v.documentTypes') != undefined ? component.get('v.documentTypes').split(';') : "";
            console.log('List is :', list);
            if (list != "" && list.indexOf(component.get('v.element')) != -1) {
                component.set('v.condition', true);
                component.set('v.checkboxvalue', checkboxValue);
                
            } else { component.set('v.condition', false); }
        //}
    },
    
    handleTable: function (component, event, helper) {
        console.log('docTypes in childComp@:' + component.get('v.documentTypes'));
        console.log('checkboxvalueindoint@:' + component.get('v.checkboxvalue'));
        console.log("disabled@::", component.get('v.disabled'));
        if(component.get('v.disabled')){
            var checkboxValue = component.get('v.checkboxvalue');
            console.log('docTypes in childComp:' + component.get('v.documentTypes'));
            let list = component.get('v.documentTypes') != '' && component.get('v.documentTypes') != undefined ? component.get('v.documentTypes').split(';') : "";
            console.log('List is :', list);
            if (list != "" && list.indexOf(component.get('v.element')) != -1) {
                component.set('v.condition', true);
                component.set('v.checkboxvalue', checkboxValue);
                
            } else { component.set('v.condition', false); }
        }
    },
    
    fireParentEvent: function (component, event, helper) {

        var changeEvent = $A.get('e.c:checkboxChangeEvent');
        console.log('Checked Value:'+event.getSource().get("v.checked"));
        component.set('v.checkboxvalue', event.getSource().get("v.checked"));
        changeEvent.setParams({
            "checkboxName": event.getSource().get("v.name")
        });
        changeEvent.fire();
    }
})