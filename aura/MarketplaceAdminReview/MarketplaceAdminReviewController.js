({
	doInit : function(component, event, helper) {
		window.addEventListener('resize', $A.getCallback(function() {
			helper.handleResize(component);
		}));
		window.setTimeout(function(){
				helper.handleResize(component, helper);
		});
		window.setTimeout(function(){
			// add height
			helper.handleResize(component, helper);
		}, 1500);

	},

	handleToggleModal : function(component, event, helper) {
		var modalOpen = component.get("v.modalOpen");
		var overlay = component.find('overlay');


		modalOpen = !modalOpen;
		component.set("v.modalOpen", modalOpen);

		if (modalOpen) {
			$A.util.removeClass(overlay, 'slds-hide');
			window.setTimeout(
				 $A.getCallback(function() {
						 $A.util.addClass(overlay, 'slds-show');

				 }), 5
		 );
		} else {
			$A.util.removeClass(overlay, 'slds-show');

			window.setTimeout(
				 $A.getCallback(function() {
					 $A.util.addClass(overlay, 'slds-hide');
				 }), 700
		 );


		}
		event.preventDefault();
  },
	handleClick: function(component, event, helper) {
		window.setTimeout(function(){
				helper.handleResize(component, helper);
		});
	}
})