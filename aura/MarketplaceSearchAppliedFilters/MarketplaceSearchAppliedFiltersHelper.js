({
	setOpen : function(component) {
		var filterOpen = component.get('v.filterOpen');
		var filterName = component.get('v.filterName');
		if (filterOpen && filterOpen[filterName] === true) {
			component.set('v.open', true);
		}
	},
    
    setCount : function(component) {
		var filterGroupCount = component.get('v.filterGroupCount');
		var filterName = component.get('v.filterName');
		var count = 0;
		if (filterGroupCount && filterGroupCount[filterName]) {
			count = filterGroupCount[filterName]
		}
		component.set('v.count',count);
	}
})