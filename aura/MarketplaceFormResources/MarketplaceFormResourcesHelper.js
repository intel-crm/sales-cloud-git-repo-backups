({
	
	checkValidity : function(component) {
		var res = component.get('v.rows').length,
			min = component.get('v.min'),
			max = component.get('v.max');
		var valid = res >= min && res <= max;
		component.set('v.valid', valid);
	}

})