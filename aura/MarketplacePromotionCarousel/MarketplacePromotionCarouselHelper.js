({
     //ipa 2.0 priyas change for topic event
    /*getPromotionData : function(component,helper){
        return new Promise($A.getCallback(function(resolve,reject){
            var action = component.get("c.getPromotionData");
            action.setParams({
                userLanguage : $A.get("$Locale.langLocale")
            });
            
            action.setCallback(this, function(response) {
                var status = response.getState();
                
                if (status === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    
                    component.set('v.promotionData', returnValue);
                    resolve();
                } else if (status === "INCOMPLETE") {
                    reject();
                    // do something?
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        };
                    }
                    reject('Unknown error.');
                } else {
                    reject('Unknown error.');
                }
            });
            $A.enqueueAction(action);
        }));
        
    },*/ //ipa 2.0 priyas change for topic event
    
    changePage : function(component, helper, page) {
        component.set('v.currentPage', parseInt(page));
        helper.resetCarouselPosition(component, parseInt(page) - 1);
    },
    
    /*resetHeight : function(component) {
		var height = 0;
		var cards = component.find('card');
		if (cards && cards.length > 1) {
			cards.forEach(function(card) {
				if (card.getElement()) {
					card.getElement().style.height = '';
				}
			});
			cards.forEach(function(card) {
				if (card.getElement()) {
			   	height = (card.getElement().offsetHeight > height) ? card.getElement().offsetHeight : height;
			 	}
			});
			cards.forEach(function(card) {
				if (card.getElement()) {
					card.getElement().style.height = height + 'px';
				}
			});
		}
	},*/
    
    resetCarouselPosition : function(component, page) {
        var transform = 'translateX(' + (-100 * page) + '%)';
        component.find('carouselPosition').getElement().style.transform = transform;
    },
    
    /* addScreenSizeChangeHandler : function(component, helper) {
		if (!component.get('v.screenResizeHandler')){
			component.set('v.screenResizeHandler', true);
	    window.addEventListener('resize', $A.getCallback(function() {
	      if(component.isValid()) {
					helper.resetHeight(component);
	      } else {
	        // remove listener
	      }
	    }));
		}
  }*/
    
})