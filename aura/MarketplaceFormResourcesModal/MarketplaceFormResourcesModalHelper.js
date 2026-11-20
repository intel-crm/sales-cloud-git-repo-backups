({
    processInput : function(component, helper) {
        var valid = component.find("input").reportValidity();
        component.set('v.valid', valid);
        helper.updateForm(component);
    },

    validate : function(component, helper) {
        var form = component.find('resourceForm');
        var valid= form.getElement().checkValidity();
        component.set("v.isFormValid", valid);
        if(!valid){
           component.set("v.hideButton",true); 
        }else{
           component.set("v.hideButton",false);
        }
    },
   
    checkUrlError : function(component, helper, label){
        
        component.set('v.hasError', true);
        component.set('v.errorUrlMessage',label);
        component.set('v.isFormValid', false);      
        
    },
 	checkNoError : function(component, helper){
        component.set('v.hasError', false);
        component.set('v.isFormValid', true); 
    },
    checkUrlNoError : function(component, helper){
       component.set('v.isValid', true);
       component.set('v.isFormValid', true);
       component.set('v.hasError', false);
    }
})