({
	doInit: function(component, event, helper) {
        //console.log('Fetch picklist values');
        var op = component.get("v.options");
      
       helper.fetchMultiSelectVal(component,event);
     
	},
    /*test code start*/
    alertstatetotest : function(component, event, helper) {
      //  alert("selectedOptions"+component.get("v.selectedOptions"));
    }
    /*test code end*/
})