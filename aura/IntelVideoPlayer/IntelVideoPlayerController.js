({

	handlePause : function(component, event, helper) {
		document.getElementById('video').pause();
		component.find('video').getElement().pause();
	},

	handlePlay : function(component, event, hepler) {
		document.getElementById('video').play();
		component.find('video').getElement().play();

	}
})