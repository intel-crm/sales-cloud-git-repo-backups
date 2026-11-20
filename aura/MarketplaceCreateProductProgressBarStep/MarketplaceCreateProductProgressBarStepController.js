({

	handleClick : function(component, event, helper) {
    var callback = component.get('v.onClickCallback');
		if (callback && typeof callback == 'function') {
      callback(component.get('v.idx'));
    }
	}

})