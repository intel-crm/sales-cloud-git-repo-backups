({

	handleToggleSpoke : function(component, event, helper) {
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
  }
})