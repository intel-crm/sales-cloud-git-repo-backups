({
	doInit : function(component, event, helper) {
		helper.setCount(component);
        helper.setOpen(component);
		if (component.get('v.showClearFiltersLink')) {
			var filterName = component.get('v.filterName'),
				clearFilterLabel = $A.get("$Label.c.PMP_L2_Search_Clear_Filters"); //default
			if (filterName == 'region') { // must be static for each filter w/ specific copy
				clearFilterLabel = $A.get("$Label.c.PMP_L2_Search_Clear_Filters_Region");
			}
			component.set('v.clearFilterLabel', clearFilterLabel);
		}
	},
    handleToggleOpen : function(component, event, helper) {
        component.set('v.open', !component.get('v.open'));
   		var filterOpen = component.get('v.filterOpen');
        if (filterOpen) {
         	filterOpen[component.get('v.filterName')] = component.get('v.open');   
        }
		event.preventDefault();
	},
	handleFilterGroupCount : function(component, event, helper) {
        helper.setCount(component);
	},
    handleFilterOpen : function(component, event, helper) {
        helper.setOpen(component);
	}
	

})