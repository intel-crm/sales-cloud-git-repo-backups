({
    
    doInit : function(component, event, helper) { 
        
        
        helper.getPromotionData(component,event,helper).then($A.getCallback(function(){
            var promoData = component.get('v.promotionData')
            
            //component.set("v.promotionData",promoData);
            //var promoData = component.get('v.promotionData');
            
            
            component.set('v.currentPage', 1);
            component.set('v.touchSettings', {
                threshold: 100, //required min distance traveled to be considered swipe
                restraint: 100, // maximum distance allowed at the same time in perpendicular direction
                allowedTime: 800, // maximum time allowed to travel that distance
            });
            
            //helper.addScreenSizeChangeHandler(component, helper);
            
            if (promoData && promoData.length > 0) {
                component.set('v.loading', false);
                //helper.resetHeight(component);
            }else{
                component.destroy();
            }
        }));
        
    },
    handleDataChange: function(component, event, helper) {
        
        window.setTimeout($A.getCallback(function() {
            component.set('v.loading', false);
            // make sure the height is the same for all cards
            //helper.resetHeight(component);
        }));
    },
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
        // console.log('onTouchSTart', {
        // 	swipedir: swipedir,
        // 	startX: startX,
        // 	startY: startY,
        // 	startTime: startTime
        // });
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
                    numberOfPages = component.get('v.promotionData').length;
                
                if (swipedir == 'left' && currentPage < numberOfPages) {
                    helper.changePage(component, helper, currentPage + 1);
                } else if (swipedir == 'right' && currentPage > 1) {
                    helper.changePage(component, helper, currentPage - 1);
                }
            }
        }
    }
    
})