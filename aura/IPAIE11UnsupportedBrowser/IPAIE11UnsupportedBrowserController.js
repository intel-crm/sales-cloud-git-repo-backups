({
	doInit: function (component, event, helper) {

		// IF ITS IE, check cookie if not present open modal

		if (navigator.userAgent.indexOf('MSIE') !== -1
			|| navigator.appVersion.indexOf('Trident/') > -1) {
			/* Microsoft Internet Explorer detected in. */
			var hasBeenShownBefore = window.sessionStorage.getItem('ie11-unsupported-modal');
			if (!hasBeenShownBefore) {
				component.set('v.modalOpen', true);
				window.sessionStorage.setItem('ie11-unsupported-modal', new Date().getTime().toString());
			}
			component.set('v.isIE11', true);
		}
		helper.replaceBrowserLinks(component);

	},
	handleTextChange: function (component, event, helper) {
		helper.replaceBrowserLinks(component);
	},
	handleCloseOverlay: function (component, event, helper) {
		component.set('v.modalOpen', false);
		event.preventDefault();
	},

	handleOpenOverlay: function (component, event, helper) {
		component.set('v.modalOpen', true);
		event.preventDefault();
	}

})