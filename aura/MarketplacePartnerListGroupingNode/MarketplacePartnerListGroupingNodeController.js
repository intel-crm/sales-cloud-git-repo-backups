({
	doInit : function(component, event, helper) {

		component.set('v.mapStateToAttributes', function(state) {
			var id = component.get('v.id');
      var  isOpen = state.partnerFiltersExpanded.indexOf(id) > -1;
      return {
        open: isOpen
      };
    });
	},

	handleToggleOpenPartnerGroup : function(component, event, helper) {
		event.preventDefault();

    helper.dispatch(component, 'togglePartnerFilterMobileNode', {
      value: component.get('v.id')
    });
	}
})