({
    
    doInit : function(component, event, helper) {
        
       //var currentState = component.get('v.state');
       //console.log('State selectedFilters : ', currentState.selectedFilters);  
        // build url w/ search params
        // Current Setup:
        // search for all products/partners
        // using a search keyword of the partner name
        var urlParams = {
            //type: 'all',
            type: 'product',
            selectedFilters:{Partner:[component.get('v.dataObj').id]}
            //q: component.get('v.dataObj').name
        };
        
        
        var pageName = 'search';
        
        var searchUrlParams = encodeURIComponent(JSON.stringify(urlParams));
        
        
        component.set('v.allOfferingsUrl', '/' + pageName + '?search=' + searchUrlParams);
        window.setTimeout(function() {
            component.set("v.renderAttribute", true);
        });
       
    },
    handleOnImageLoad: function(component, event, helper) {
        var onImageLoaded = component.get('v.onImageLoaded');
        var image = event.currentTarget;
        // If image aspect ratio is > 16:9 we have to stretch it vertically
        // 16:9 = 1.77   Image Ratio
        if (image.naturalWidth/image.naturalHeight < 1.77) {
            component.set('v.orientation', 'stretchHeight');
        }
        
        if (typeof onImageLoaded === 'function') {
            onImageLoaded(component, event, helper);
        }
    },
    
    
})