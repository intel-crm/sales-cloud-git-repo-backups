({ 
	//  IPA2.0 + US TWC4497-1631
	/* doInit : function(component, event, helper) {
		window.addEventListener('resize', $A.getCallback(function() {
			helper.handleResize(component);
		}));
		window.setTimeout(function(){
				helper.handleResize(component, helper);
		});
        
		var debounceIndex = false;
		// Debounce Scroll event so it does the handle resize only every 500 ms
		var onScrollEvent = $A.getCallback(function() {
			if (component.isValid()){
				window.clearTimeout(debounceIndex);
				debounceIndex = window.setTimeout($A.getCallback(function() {
					helper.handleResize(component, helper);
				}), 500);
			}
		});

		window.addEventListener('scroll', onScrollEvent );

		window.setTimeout(function(){
			helper.handleResize(component, helper);
			// remove scroll event listener after 15 seconds
			window.removeEventListener('scroll', onScrollEvent );
		}, 15000);

        

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
	}*/
})