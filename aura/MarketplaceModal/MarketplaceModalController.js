({

	closeModal : function(component, event, helper) {
        console.log('closeModal invoked!!!');
		if (typeof component.get('v.closeModalCallback') == 'function') {
			component.get('v.closeModalCallback')();
		} else {
			component.set('v.isOpen', false);
		}
        console.log('closeModalCallback: '+component.get('v.closeModalCallback')+' isOpen: '+component.get('v.isOpen'));
	},

	handleScrollTo : function(component, event, helper) {
		var posY = event.getParams('arguments').posY || 0;
		component.find("modalContent").getElement().scrollTop = posY;
	},

})