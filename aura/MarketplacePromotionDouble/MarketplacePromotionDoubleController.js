({
	doInit : function(component, event, helper) {
    helper.addScreenSizeChangeHandler(component, helper);
    component.set('v.mapStateToAttributes', function(state) {
      return {
        currentScreenSize: state.currentScreenSize
      };
    });
		window.setTimeout($A.getCallback(function() {
			helper.resetHeight(component);
		}));
	},

})