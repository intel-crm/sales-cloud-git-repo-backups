({
	replaceBrowserLinks : function(component) {
		var bodyText = component.get('v.bodyText');
		if (bodyText.length) {
			bodyText = bodyText.replace("{0}",'<a href="https://www.google.com/chrome/" target="_blank">Google Chrome</a>');
			bodyText = bodyText.replace("{1}",'<a href="https://www.mozilla.org/en-US/firefox/new/" target="_blank">Mozilla Firefox</a>');
			bodyText = bodyText.replace("{2}",'<a href="https://www.microsoft.com/en-us/windows/microsoft-edge" target="_blank">Microsoft Edge</a>');
			component.set('v._bodyText',bodyText);
		}

	}
})