({ /*
	handleResize : function(component, helper) {
		if (component.isValid()){
			var innerWidth = component.find('adminReview').getElement().clientWidth;
			var outerWidth = window.innerWidth;
			var innerHeight = 0;
			var innerContent = component.find('innerContent');
			var scale = 1;
			var height = ''
			var styleTransform = '';
			if (innerWidth < 1280 && outerWidth >= 768) {
				// do the scaling

				scale = innerWidth/outerWidth;
				styleTransform += 'width: ' + outerWidth + 'px;';
				styleTransform += 'max-width: ' + outerWidth + 'px;';
				styleTransform += 'transform:  scale('+ scale+');';

				if (innerContent && innerContent.getElement()) {
					innerHeight = innerContent.getElement().clientHeight;
					if (innerHeight > 0 ) {
						 height  = Math.ceil(innerHeight * scale) + 10 + 'px'
					}
				}

			}

			component.set('v.scale', scale);
			component.set('v.width', outerWidth);
			component.set('v.styleTransform', styleTransform);
			component.set('v.height', height );

			
		}
	} */
})

/*window.setTimeout($A.getCallback(function() {
				component.find("outerContainer").getElement().style.height = height;
				component.find("innerContent").getElement().style = styleTransform;
			}));*/