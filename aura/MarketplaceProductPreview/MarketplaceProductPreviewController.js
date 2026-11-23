({

	doInit : function(component, event, helper) {
		helper.loadPreviewData(component);
		var myPageRef = component.get("v.pageReference");
		//console.log('PageReference',myPageRef);
	},
    onPageReferenceChange: function(component, event, helper) {
			var myPageRef = component.get("v.pageReference");
			console.log('onPageReferenceChange', JSON.parse(JSON.stringify(event)), myPageRef);

	}

})