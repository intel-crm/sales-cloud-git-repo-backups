({
	doInit: function(component, event, helper){
       
        console.log(component.get('v.availableOptions'));
        
        //console.log('Fetch picklist values');
        var op = component.get("v.options");
      
       helper.fetchMultiSelectVal(component,event);       
	},
    /*test code start*/
    alertstatetotest : function(component, event, helper) {
      //  alert("selectedOptions"+component.get("v.selectedOptions"));
    },
    /*test code end*/
    validateErrors: function (component, event) {
      	var multiselect = component.find("multiselect");
        var selectedValue = multiselect.get("v.value");
        if($A.util.isEmpty(selectedValue)){
            multiselect.setCustomValidity($A.get("$Label.c.Core_MDF_ActivitySubTypeError"));
        }else{
            multiselect.setCustomValidity("");
        } 
      	multiselect.reportValidity();
  },
    clear: function(component,event) {
        component.set("v.selectedOptions",[]);
    }
})