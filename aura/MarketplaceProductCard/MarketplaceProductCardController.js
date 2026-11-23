({
	doInit : function(component, event, helper) {
        
         window.setTimeout(function() {
            component.set('v.renderAttribute', true);
        });
        
        var data = {id: component.get('v.partner.id'),
                    autoPartnerId: component.get('v.partner.autoPartnerId'),
                    oid: component.get('v.dataObj.autoOffId'),
                    offRecId: component.get('v.dataObj.id'),
                    contactByEmail: false,
                    contactByForm: true,
                    requestAQuote: true,
                    name: component.get('v.partner.name'),
                    title:component.get('v.dataObj.title'),
                    categoryLabel: component.get('v.dataObj.categoryLabel')
                     };
        
        component.set("v.contactPartnerData",data);
       

	},
	handleOnImageLoad: function(component, event, helper) {
    var onImageLoaded = component.get('v.onImageLoaded');
		var image = event.currentTarget;
		// If image aspect ratio is > 16:9 we have to stretch it vertically
		// 16:9 = 1.77   Image Ratio
		if (image.naturalWidth/image.naturalHeight > 1.77) {
			component.set('v.orientation', 'stretchHeight');
		}

    if (typeof onImageLoaded === 'function') {
      onImageLoaded(component, event, helper);
    }
	},
})