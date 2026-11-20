({
	doInit: function(component, event, helper) {      
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
  
   getAvailableOptions : function(component, event){
       var availableOptions = event.getParam('value');
         if(!$A.util.isEmpty(availableOptions) && availableOptions != undefined){
             if(availableOptions.length >5){
                 component.set("v.dynamicSize",5);
             }else{
                 component.set("v.dynamicSize",availableOptions.length); 
             }
         }
    }
  
})