({
    
    doInit : function(component, event, helper) {
        component.set('v.loading',true);
        component.set('v.currentPage', 1);
        component.set('v.touchSettings', {
            threshold: 100, //required min distance traveled to be considered swipe
            restraint: 100, // maximum distance allowed at the same time in perpendicular direction
            allowedTime: 800, // maximum time allowed to travel that distance
        });
        helper.addScreenSizeChangeHandler(component, helper);
        
        // if data is not empty do doIn
        if (component.get('v.featuredProducts').length){
            window.setTimeout($A.getCallback(function() {
                component.set('v.loading', false);
                // make sure the height is the same for all cards
                // helper.resetHeight(component);
                // resets the carousel
                helper.resetCarousel(component, helper);
                //helper.resetPages(component);
            }), 100);
        }
	
        if (component.get('v.render')) {
			window.setTimeout(function () {
				// helper.performanceLog(component, helper);
				component.set('v.alreadyRendered', true);
			});
		}
	
        component.set('v.ctaLink', '/search');
        // 	var debounceIndex = false;
        // 	component.set('v.onImageLoaded', $A.getCallback(function(){
        //   if(component.isValid()) {
        // 			window.clearTimeout(debounceIndex);
        // 			debounceIndex = window.setTimeout($A.getCallback(function() {
        // 				helper.resetHeight(component);
        // 			}), 50);
        //   }
        //   })
        // );
    },
    
    handleDataChange: function(component, event, helper) {
       //component.set('v.loading',true);
        window.setTimeout($A.getCallback(function() {
            component.set('v.loading', false);
            // make sure the height is the same for all cards
            // helper.resetHeight(component);
            // resets the carousel
            helper.resetCarousel(component, helper);
            // force reset the pages on data change
            helper.resetPages(component);
        }));
    },
	handleRenderChange: function (component, event, helper) {

		// switch already rendered to true so it doesn't re render
		if (component.get('v.render') && !component.get('v.alreadyRendered')) {
			// timeout needed here to not delay the switch on tabs
			window.setTimeout(function () {
				// helper.performanceLog(component, helper);
				component.set('v.alreadyRendered', true);
			});
		}
	},
    // handleResetHeight: function(component, event, helper) {
    // 	window.setTimeout($A.getCallback(function() {
    // 		// make sure the height is the same for all cards
    // 		helper.resetHeight(component);
    // 		// resets the carousel
    // 		helper.resetCarousel(component, helper);
    
    // 	}));
    // },
    handleClick: function(component, event, helper) {
        var href = component.get('v.ctaLink');
        var openInNewTab = component.get('v.ctaOpenInNewTab');
        var communityLink = component.get('v.communityLink');
        
        var onclick = component.get('v.ctaOnClick');
        
        if (typeof onclick === 'function') {
            onclick(component, event, helper);
            event.preventDefault();
        } else if (communityLink) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": communityLink
            });
            urlEvent.fire();
            event.preventDefault();
        }
    },
    
    
    /* handleClick: function(component, event, helper) {
       // alert('inside handleclick');
        var href = component.get('v.ctaLink');
        var openInNewTab = component.get('v.ctaOpenInNewTab');
        var communityLink = component.get('v.communityLink');
        
        var onclick = component.get('v.ctaOnClick');
        //component.set('v.ctaLink', '/Search');
        if (typeof onclick === 'function') {
            onclick(component, event, helper);
           
        } else if (communityLink) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": communityLink
              // "url": component.get('v.ctaLink')
            });
            urlEvent.fire();
            event.preventDefault();
        }
    },*/
    
    /*
    handleClick : function(component, event, helper) {
        
        event.preventDefault();
        var currentIndex = event.currentTarget.dataset.index;

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get('v.ctaLink')
        });
        urlEvent.fire();
    },
    */
    
    handleChangePage : function(component, event, helper) {
        var page = event.target.dataset.page;
        helper.changePage(component, helper, page);
    },
    
    handleTouchStart: function(component, event, helper) {
        var touchobj = event.changedTouches[0],
            swipedir = 'none',
            dist = 0,
            startX = touchobj.pageX,
            startY = touchobj.pageY,
            // record time when finger first makes contact with surface
            startTime = Date.now();
        component.set('v.touchData', {
            swipedir: swipedir,
            startX: startX,
            startY: startY,
            startTime: startTime
        });
    },
    
    handleTouchEnd: function(component, event, helper) {
        var touchobj = event.changedTouches[0],
            // get horizontal dist traveled by finger while in contact with surface
            distX = touchobj.pageX - component.get('v.touchData.startX'),
            // get vertical dist traveled by finger while in contact with surface
            distY = touchobj.pageY - component.get('v.touchData.startY'),
            // get time elapsed
            elapsedTime = Date.now() - component.get('v.touchData.startTime');
        
        // first condition for awipe met
        if (elapsedTime <= component.get('v.touchSettings.allowedTime')) {
            var threshold = component.get('v.touchSettings.threshold'),
                restraint = component.get('v.touchSettings.restraint');
            // 2nd condition for horizontal swipe met
            if (Math.abs(distX) >= threshold && Math.abs(distY) <= restraint) {
                var swipedir = (distX < 0) ? 'left' : 'right'; // if dist traveled is negative, it indicates left swipe
                // Page Logic
                var currentPage = parseInt(component.get('v.currentPage')),
                    numberOfPages = parseInt(component.get('v.numberOfPages'));
                if (swipedir == 'left' && currentPage < numberOfPages) {
                    helper.changePage(component, helper, currentPage + 1);
                } else if (swipedir == 'right' && currentPage > 1) {
                    helper.changePage(component, helper, currentPage - 1);
                }
            }
        }
    },
    
    handleScreenSizeChange : function(component, event, helper) {
        helper.resetPageValues(component);
    },
    
    /* handleSelectOption: function(component, event, helper) {
    var recordId = event.currentTarget.dataset.recordId;
    if (recordId && (recordId != "null")) {
      helper.navigateToRecord(component, recordId);
    }
    event.preventDefault();
  },*/
})